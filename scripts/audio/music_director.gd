extends Node

const RunPhaseContractScript = preload("res://scripts/contracts/run_phase_contract.gd")
const SILENT_DB: float = -60.0
const FADE_SECONDS: float = 2.2
const MUSIC_BUS_NAME: String = "Music"
const TRACKS: Dictionary = {
	"menu": "res://assets/audio/original/atrium.wav",
	"safe": "res://assets/audio/original/registry.wav",
	"tense": "res://assets/audio/original/inscription.wav",
	"climax": "res://assets/audio/original/threshold.wav",
	"ending": "res://assets/audio/original/dossier.wav",
}
const TARGET_DB: float = -7.0

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
		var stream: AudioStreamWAV = load(TRACKS[key]) as AudioStreamWAV
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
		_streams[key] = stream
	GameEvents.run_phase_changed.connect(_on_run_phase_changed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.request_show_main_menu.connect(_on_request_show_main_menu)
	GameEvents.run_ended.connect(_on_registry_run_ended)
	GameEvents.settings_changed.connect(_on_settings_changed)
	_apply_music_volume_linear(SaveManager.get_music_volume())
	if _port.can_start_run():
		_transition("menu")

func _phase_key(phase: int) -> String:
	match phase:
		RunPhaseContractScript.MAIN_MENU: return "menu"
		RunPhaseContractScript.BET_COMMITTED, RunPhaseContractScript.INTERMEDIATE_CHOICE: return "tense"
		RunPhaseContractScript.PUSH_YOUR_LUCK: return "climax"
		RunPhaseContractScript.GAME_OVER: return "ending"
		_: return "safe"

func _on_run_phase_changed(phase: int) -> void:
	if _registry_silent or not _port.can_start_run():
		return
	_transition(_phase_key(phase))

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

func _transition(key: String) -> void:
	if key == _active_key and _players[_active].playing:
		return
	_kill_fade()
	# Alternate players for every change, including transitions within a run.
	var outgoing: AudioStreamPlayer = _players[_active]
	_active = 1 - _active
	var incoming: AudioStreamPlayer = _players[_active]
	incoming.stop()
	incoming.stream = _streams[key] as AudioStream
	incoming.volume_db = SILENT_DB
	incoming.play()
	_active_key = key
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(incoming, "volume_db", TARGET_DB, fade_seconds)
	_fade_tween.parallel().tween_property(outgoing, "volume_db", SILENT_DB, fade_seconds)
	_fade_tween.tween_callback(outgoing.stop)

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
	for player: AudioStreamPlayer in _players:
		if is_instance_valid(player):
			player.stop()
