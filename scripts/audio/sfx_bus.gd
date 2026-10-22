extends Node

const DEFAULT_VOLUME_DB: float = -11.0
const SFX_BUS_NAME: String = "SFX"
const POOL_SIZE: int = 6
const HOVER_INTERVAL_MS: int = 120
# Files are levelled by family in tools/audio/compose.py; these gains only trim.
const CUE_VOLUME_DB: Dictionary = {
	&"button_hover": -11.0,
	&"button_click": -11.0,
	&"cursor_move": -11.0,
	&"cursor_select": -11.0,
	&"player_damage": -11.0,
	&"enemy_hit": -12.0,
	&"enemy_death": -10.0,
	&"pickup": -12.0,
	&"level_up": -11.0,
	&"stage_complete": -11.0,
	&"registry_receipt_take": -11.0,
	&"registry_condemnation_mark": -10.5,
	&"registry_second_incision": -11.0,
	&"arena_threshold_cross": -11.0,
	&"registry_table_open": -11.0,
	&"registry_promise_sign": -11.0,
	&"registry_pact_validate": -10.5,
	&"arena_gesture_placa": -11.0,
	&"arena_gesture_provoca": -10.5,
	&"registry_judgment_seal_strike": -10.5,
	&"registry_judgment_seal_resolve": -10.0,
	&"registry_dossier_update": -11.0,
	&"registry_dossier_close": -10.0,
	&"registry_dossier_route": -11.0,
	&"game_over": -10.0,
	&"crowd_favor_up": -12.0,
	&"crowd_favor_down": -12.0,
	&"crowd_triumph": -11.0,
	&"crowd_riot": -11.0,
	&"coins_gain": -12.0,
	&"coins_loss": -12.0,
	&"bando_closed": -11.0,
}
const SFX_PATHS: Dictionary = {
	&"button_hover": "res://assets/audio/sfx/button_hover.wav",
	&"button_click": "res://assets/audio/sfx/button_click.wav",
	&"cursor_move": "res://assets/audio/sfx/cursor_move.wav",
	&"cursor_select": "res://assets/audio/sfx/cursor_select.wav",
	&"player_damage": "res://assets/audio/sfx/player_damage.wav",
	&"enemy_hit": "res://assets/audio/sfx/enemy_hit.wav",
	&"enemy_death": "res://assets/audio/sfx/enemy_death.wav",
	&"pickup": "res://assets/audio/sfx/pickup.wav",
	&"level_up": "res://assets/audio/sfx/level_up.wav",
	&"stage_complete": "res://assets/audio/sfx/stage_complete.wav",
	&"registry_receipt_take": "res://assets/audio/sfx/registry_receipt_take.wav",
	&"registry_condemnation_mark": "res://assets/audio/sfx/registry_condemnation_mark.wav",
	&"registry_second_incision": "res://assets/audio/sfx/registry_second_incision.wav",
	&"arena_threshold_cross": "res://assets/audio/sfx/arena_threshold_cross.wav",
	&"registry_table_open": "res://assets/audio/sfx/registry_table_open.wav",
	&"registry_promise_sign": "res://assets/audio/sfx/registry_promise_sign.wav",
	&"registry_pact_validate": "res://assets/audio/sfx/registry_pact_validate.wav",
	&"arena_gesture_placa": "res://assets/audio/sfx/arena_gesture_placa.wav",
	&"arena_gesture_provoca": "res://assets/audio/sfx/arena_gesture_provoca.wav",
	&"registry_judgment_seal_strike": "res://assets/audio/sfx/registry_judgment_seal_strike.wav",
	&"registry_judgment_seal_resolve": "res://assets/audio/sfx/registry_judgment_seal_resolve.wav",
	&"registry_dossier_update": "res://assets/audio/sfx/registry_dossier_update.wav",
	&"registry_dossier_close": "res://assets/audio/sfx/registry_dossier_close.wav",
	&"registry_dossier_route": "res://assets/audio/sfx/registry_dossier_route.wav",
	&"game_over": "res://assets/audio/sfx/game_over.wav",
	&"crowd_favor_up": "res://assets/audio/sfx/crowd_favor_up.wav",
	&"crowd_favor_down": "res://assets/audio/sfx/crowd_favor_down.wav",
	&"crowd_triumph": "res://assets/audio/sfx/crowd_triumph.wav",
	&"crowd_riot": "res://assets/audio/sfx/crowd_riot.wav",
	&"coins_gain": "res://assets/audio/sfx/coins_gain.wav",
	&"coins_loss": "res://assets/audio/sfx/coins_loss.wav",
	&"bando_closed": "res://assets/audio/sfx/bando_closed.wav",
}
# Repeated gestures should not sound identical: a small random pitch per play.
const CUE_PITCH_JITTER: Dictionary = {
	&"button_hover": 0.03,
	&"cursor_move": 0.03,
	&"registry_judgment_seal_strike": 0.04,
	&"coins_gain": 0.05,
	&"coins_loss": 0.04,
}
# The gradinata answers a little after the gesture that moved it.
const CROWD_REACTION_DELAY: float = 0.35
const COIN_COOLDOWN_MS: int = 1200

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _sfx_bus_index: int = -1
var _last_hover_ms: int = -120
var _last_favor: int = 0
var _last_cue_ms: Dictionary = {}
var _silenced_at_ms: int = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_sfx_bus()
	for index: int in range(POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		player.volume_db = DEFAULT_VOLUME_DB
		player.bus = SFX_BUS_NAME
		add_child(player)
		_players.append(player)
	_preload_streams()
	_apply_saved_sfx_volume()
	GameEvents.run_ended.connect(_on_run_ended)
	GameEvents.crowd_favor_changed.connect(_on_crowd_favor_changed)
	GameEvents.ledger_changed.connect(_on_ledger_changed)
	GameEvents.bando_changed.connect(_on_bando_changed)
	if GameEvents != null and GameEvents.has_signal("settings_changed"):
		var settings_callable: Callable = Callable(self, "_on_settings_changed")
		if not GameEvents.settings_changed.is_connected(settings_callable):
			GameEvents.settings_changed.connect(settings_callable)

func _ensure_sfx_bus() -> void:
	_sfx_bus_index = AudioServer.get_bus_index(SFX_BUS_NAME)
	if _sfx_bus_index < 0:
		AudioServer.add_bus()
		_sfx_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_sfx_bus_index, SFX_BUS_NAME)
	AudioServer.set_bus_send(_sfx_bus_index, "Master")
	# One limiter on Master keeps stacked crowd, coins and score below clipping.
	var master: int = AudioServer.get_bus_index("Master")
	for effect_index: int in range(AudioServer.get_bus_effect_count(master)):
		if AudioServer.get_bus_effect(master, effect_index) is AudioEffectHardLimiter:
			return
	var limiter: AudioEffectHardLimiter = AudioEffectHardLimiter.new()
	limiter.ceiling_db = -1.0
	AudioServer.add_bus_effect(master, limiter)

func _apply_saved_sfx_volume() -> void:
	var value: float = 1.0
	if SaveManager != null and SaveManager.has_method("get_sfx_volume"):
		value = float(SaveManager.get_sfx_volume())
	_apply_sfx_volume_linear(value)

func _on_settings_changed(payload: Dictionary) -> void:
	if payload.has("sfx_volume"):
		_apply_sfx_volume_linear(float(payload.get("sfx_volume", 1.0)))

func _apply_sfx_volume_linear(value: float) -> void:
	if _sfx_bus_index < 0:
		_ensure_sfx_bus()
	var volume_scale: float = clamp(value, 0.0, 1.0)
	var db_value: float = -80.0 if volume_scale <= 0.001 else linear_to_db(volume_scale)
	AudioServer.set_bus_volume_db(_sfx_bus_index, db_value)
	AudioServer.set_bus_mute(_sfx_bus_index, volume_scale <= 0.001)

func play_cue(cue: StringName, volume_db: float = INF) -> void:
	var is_hover: bool = cue == &"button_hover" or cue == &"cursor_move"
	if is_hover:
		var now: int = Time.get_ticks_msec()
		if now - _last_hover_ms < HOVER_INTERVAL_MS:
			return
		_last_hover_ms = now
	if _players.is_empty():
		return
	var stream: AudioStream = _get_stream(cue)
	if stream == null:
		return
	# Prefer an idle voice. Hover never steals an audible ritual confirmation.
	var free_index: int = -1
	for offset: int in range(_players.size()):
		var index: int = (_next_player_index + offset) % _players.size()
		if not _players[index].playing:
			free_index = index
			break
	if free_index < 0 and is_hover:
		return
	if free_index >= 0:
		_next_player_index = free_index
	var player: AudioStreamPlayer = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
	player.stop()
	player.stream = stream
	player.volume_db = float(CUE_VOLUME_DB.get(cue, DEFAULT_VOLUME_DB)) if is_inf(volume_db) else volume_db
	var jitter: float = float(CUE_PITCH_JITTER.get(cue, 0.0))
	player.pitch_scale = 1.0 + randf_range(-jitter, jitter) if jitter > 0.0 else 1.0
	player.play()
	_last_cue_ms[cue] = Time.get_ticks_msec()

func _preload_streams() -> void:
	for cue: StringName in SFX_PATHS.keys():
		_get_stream(cue)

func _get_stream(cue: StringName) -> AudioStream:
	if _streams.has(cue):
		return _streams[cue] as AudioStream
	var path: String = str(SFX_PATHS.get(cue, ""))
	if path == "" or not ResourceLoader.exists(path):
		return null
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return null
	_streams[cue] = stream
	return stream

func _on_run_ended(reason: String, _summary: Dictionary) -> void:
	if reason == "REGISTRY_SILENCE" or reason == "REGISTRY_ABSENCE":
		_silenced_at_ms = Time.get_ticks_msec()
		for player: AudioStreamPlayer in _players:
			player.stop()

func _played_recently(cues: Array[StringName], window_ms: int) -> bool:
	var now: int = Time.get_ticks_msec()
	for cue: StringName in cues:
		if _last_cue_ms.has(cue) and now - int(_last_cue_ms[cue]) < window_ms:
			return true
	return false

func _play_later(cue: StringName, delay: float) -> void:
	var scheduled: int = Time.get_ticks_msec()
	await get_tree().create_timer(delay).timeout
	if _silenced_at_ms < scheduled:
		play_cue(cue)

func _on_crowd_favor_changed(payload: Dictionary) -> void:
	# Resets and reloads carry no note and no event: they only set the baseline.
	var favor: int = int(payload.get("favor", 0))
	var event: String = str(payload.get("event", ""))
	var moved: bool = event != "" or str(payload.get("note", "")) != ""
	var previous: int = _last_favor
	_last_favor = favor
	if not moved:
		return
	var cue: StringName = &""
	if event == "triumph":
		cue = &"crowd_triumph"
	elif event == "riot":
		cue = &"crowd_riot"
	elif favor > previous:
		cue = &"crowd_favor_up"
	elif favor < previous:
		cue = &"crowd_favor_down"
	if cue != &"":
		_play_later(cue, CROWD_REACTION_DELAY)

func _on_ledger_changed(payload: Dictionary) -> void:
	var delta: int = int(payload.get("delta", 0))
	if delta == 0:
		return
	# The quietanza and the bando already ring their own coins.
	if _played_recently([&"registry_receipt_take", &"bando_closed"], COIN_COOLDOWN_MS):
		return
	play_cue(&"coins_gain" if delta > 0 else &"coins_loss")

func _on_bando_changed(payload: Dictionary) -> void:
	if str(payload.get("note", "")) == "BANDO CHIUSO":
		play_cue(&"bando_closed")
