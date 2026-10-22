extends Node

const RunPhaseContractScript = preload("res://scripts/contracts/run_phase_contract.gd")
const SILENT_DB: float = -60.0
const FADE_SECONDS: float = 2.2
const MUSIC_BUS_NAME: String = "Music"
const AMBIENCE_BUS_NAME: String = "Ambience"
# Five loops of the same length, tempo and mode (80 s, 72 BPM, D Dorian):
# a section change keeps the beat by starting at the outgoing position.
const TRACKS: Dictionary = {
	"menu": "res://assets/audio/score/atrium.ogg",
	"safe": "res://assets/audio/score/registry.ogg",
	"tense": "res://assets/audio/score/inscription.ogg",
	"climax": "res://assets/audio/score/threshold.ogg",
	"ending": "res://assets/audio/score/dossier.ogg",
}
# The gradinata: talk at rest, stomps and claps on the score's grid when it presses.
const CROWD_TRACKS: Dictionary = {
	"murmur": "res://assets/audio/score/gradinata_murmur.ogg",
	"rhythm": "res://assets/audio/score/gradinata_rhythm.ogg",
}
const CROWD_SECTIONS: Array[String] = ["safe", "tense", "climax"]
const CROWD_FADE_SECONDS: float = 1.8
const TARGET_DB: float = -14.0

@export var menu_player_path: NodePath = NodePath("../MenuLayer/MenuThemePlayer")
@export var run_player_path: NodePath = NodePath("../RunThemePlayer")
@export var fade_seconds: float = FADE_SECONDS

var _players: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _active: int = 0
var _active_key: String = ""
var _fade_tween: Tween
var _music_bus_index: int = -1
var _registry_silent: bool = false
var _port: RunManagerUiPort
var _campaign_attenuation: float = 0.0
var _crowd: Dictionary = {}
var _crowd_targets: Dictionary = {}
var _crowd_tween: Tween
var _pressure: float = 0.0

func _ready() -> void:
	_port = RunManagerUiPort.new(get_tree())
	_players = [get_node(menu_player_path) as AudioStreamPlayer, get_node(run_player_path) as AudioStreamPlayer]
	_music_bus_index = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if _music_bus_index < 0:
		AudioServer.add_bus()
		_music_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_music_bus_index, MUSIC_BUS_NAME)
		AudioServer.set_bus_send(_music_bus_index, "Master")
	for player: AudioStreamPlayer in _players:
		player.bus = MUSIC_BUS_NAME
		player.volume_db = SILENT_DB
	for key: String in TRACKS:
		_streams[key] = _load_loop(TRACKS[key])
	_ensure_ambience_bus()
	for key: String in CROWD_TRACKS:
		var crowd_player: AudioStreamPlayer = AudioStreamPlayer.new()
		crowd_player.name = "Gradinata_" + key
		crowd_player.bus = AMBIENCE_BUS_NAME
		crowd_player.volume_db = SILENT_DB
		crowd_player.stream = _load_loop(CROWD_TRACKS[key])
		add_child(crowd_player)
		_crowd[key] = crowd_player
		_crowd_targets[key] = SILENT_DB
	GameEvents.run_phase_changed.connect(_on_run_phase_changed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.betting_opened.connect(_on_score_section.bind("safe"))
	GameEvents.pact_sealed_opened.connect(_on_score_section.bind("tense"))
	GameEvents.resolve_ritual_opened.connect(_on_ritual_opened)
	GameEvents.request_show_main_menu.connect(_on_request_show_main_menu)
	GameEvents.run_ended.connect(_on_registry_run_ended)
	GameEvents.settings_changed.connect(_on_settings_changed)
	GameEvents.escalation_changed.connect(_on_escalation_changed)
	_apply_music_volume_linear(SaveManager.get_music_volume())
	if _port.can_start_run():
		_transition("menu")

# The phase bus carries runtime gates (PREP/LIVE/GAME_OVER), not ritual steps.
# Existing presentation events carry the musical section within each gate.
func _on_run_phase_changed(phase: int) -> void:
	if phase == RunPhaseContractScript.GAME_OVER:
		_on_score_section("ending")

func _on_score_section(key: String) -> void:
	if not _registry_silent and _port.can_start_run():
		_transition(key)

func _on_ritual_opened(_payload: Dictionary) -> void:
	_on_score_section("tense")

func apply_run_ui_payload(payload: RunUiPayload) -> void:
	match payload.phase:
		RunPhaseContractScript.MAIN_MENU: _on_score_section("menu")
		RunPhaseContractScript.BET_PRESENT, RunPhaseContractScript.NEXT_BET: _on_score_section("safe")
		RunPhaseContractScript.BET_COMMITTED, RunPhaseContractScript.INTERMEDIATE_CHOICE: _on_score_section("tense")
		RunPhaseContractScript.PUSH_YOUR_LUCK: _on_score_section("climax")
		RunPhaseContractScript.GAME_OVER: _on_score_section("ending")

func _on_run_started() -> void:
	_registry_silent = false
	if _port.can_start_run():
		_transition("safe")

func _on_request_show_main_menu() -> void:
	if not _port.can_start_run():
		return
	_registry_silent = false
	_transition("menu")

func _on_registry_run_ended(reason: String, _summary: Dictionary) -> void:
	if reason not in ["REGISTRY_SILENCE", "REGISTRY_ABSENCE"]:
		return
	_registry_silent = true
	_kill_fade()
	for player: AudioStreamPlayer in _players:
		player.stop()
		player.volume_db = SILENT_DB
	_active_key = ""
	_stop_crowd()

func _on_escalation_changed(level: int, max_value: int) -> void:
	_pressure = clampf(float(level) / float(maxi(max_value, 1)), 0.0, 1.0)
	_update_crowd()

func _transition(key: String) -> void:
	# Use the same gradual environmental presentation as the chamber. Never
	# change the SFX bus: critical gestures keep their original intelligibility.
	_campaign_attenuation = float(_port.get_registry_presentation().get("material_fade", 0.0)) * 28.0
	var target_db: float = TARGET_DB - _campaign_attenuation
	if key == _active_key and _players[_active].playing:
		if _fade_tween == null or not _fade_tween.is_running():
			_players[_active].volume_db = target_db
		_update_crowd()
		return
	_kill_fade()
	# Alternate players for every change, including transitions within a run.
	var outgoing: AudioStreamPlayer = _players[_active]
	_active = 1 - _active
	var incoming: AudioStreamPlayer = _players[_active]
	incoming.stop()
	incoming.stream = _streams[key] as AudioStream
	incoming.volume_db = SILENT_DB
	incoming.play(_beat_position(outgoing, incoming.stream))
	_active_key = key
	_update_crowd()
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(incoming, "volume_db", target_db, fade_seconds)
	_fade_tween.parallel().tween_property(outgoing, "volume_db", SILENT_DB, fade_seconds)
	_fade_tween.tween_callback(outgoing.stop)

func _load_loop(path: String) -> AudioStream:
	var stream: AudioStream = load(path) as AudioStream
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		var wav: AudioStreamWAV = stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	return stream

func _beat_position(outgoing: AudioStreamPlayer, incoming_stream: AudioStream) -> float:
	# Same-length loops on one grid: carry the bar position across the change.
	if outgoing == null or not outgoing.playing or outgoing.stream == null:
		return 0.0
	var length: float = incoming_stream.get_length()
	if length <= 0.0 or not is_equal_approx(outgoing.stream.get_length(), length):
		return 0.0
	return fposmod(outgoing.get_playback_position(), length)

func _ensure_ambience_bus() -> void:
	# The gradinata is part of the scene, so it answers to the effects slider.
	var index: int = AudioServer.get_bus_index(AMBIENCE_BUS_NAME)
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, AMBIENCE_BUS_NAME)
	AudioServer.set_bus_send(index, "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master")

func _update_crowd() -> void:
	if _crowd.is_empty():
		return
	var present: bool = not _registry_silent and _active_key in CROWD_SECTIONS
	# The stands thin out with the same ramp as the chamber; they never vanish mid-run.
	var thin: float = _campaign_attenuation * 1.5
	var drive: float = clampf((_pressure - 0.4) / 0.6 + (0.35 if _active_key == "climax" else 0.0), 0.0, 1.0)
	var targets: Dictionary = {
		"murmur": lerpf(-19.0, -9.0, _pressure) - thin if present else SILENT_DB,
		"rhythm": lerpf(-24.0, -8.0, drive) - thin if present and drive > 0.0 else SILENT_DB,
	}
	if targets == _crowd_targets:
		return
	_crowd_targets = targets
	if _crowd_tween != null and _crowd_tween.is_valid():
		_crowd_tween.kill()
	_crowd_tween = create_tween().set_parallel(true)
	_crowd_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for key: String in _crowd:
		var player: AudioStreamPlayer = _crowd[key]
		var target: float = float(targets[key])
		if target > SILENT_DB and not player.playing:
			player.volume_db = SILENT_DB
			player.play(_beat_position(_players[_active], player.stream) if key == "rhythm" else randf() * player.stream.get_length())
		if player.playing:
			_crowd_tween.tween_property(player, "volume_db", target, CROWD_FADE_SECONDS)
	_crowd_tween.chain().tween_callback(_stop_silent_crowd)

func _stop_silent_crowd() -> void:
	for key: String in _crowd:
		if float(_crowd_targets[key]) <= SILENT_DB:
			(_crowd[key] as AudioStreamPlayer).stop()

func _stop_crowd() -> void:
	if _crowd_tween != null and _crowd_tween.is_valid():
		_crowd_tween.kill()
	for key: String in _crowd:
		var player: AudioStreamPlayer = _crowd[key]
		player.stop()
		player.volume_db = SILENT_DB
		_crowd_targets[key] = SILENT_DB

func _on_settings_changed(payload: Dictionary) -> void:
	if payload.has("music_volume"):
		_apply_music_volume_linear(float(payload.music_volume))

func _apply_music_volume_linear(value: float) -> void:
	var volume: float = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(_music_bus_index, -80.0 if volume <= 0.001 else linear_to_db(volume))
	AudioServer.set_bus_mute(_music_bus_index, volume <= 0.001)

func _kill_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null

func _exit_tree() -> void:
	_kill_fade()
	_stop_crowd()
	for player: AudioStreamPlayer in _players:
		if is_instance_valid(player):
			player.stop()
