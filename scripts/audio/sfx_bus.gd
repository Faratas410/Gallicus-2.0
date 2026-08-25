extends Node

const DEFAULT_VOLUME_DB: float = -10.0
const SFX_BUS_NAME: String = "SFX"
const POOL_SIZE: int = 8
const CUE_VOLUME_DB: Dictionary = {
	&"button_hover": -18.0,
	&"button_click": -13.0,
	&"cursor_move": -16.0,
	&"cursor_select": -11.0,
	&"player_damage": -9.0,
	&"enemy_hit": -12.0,
	&"enemy_death": -10.0,
	&"pickup": -12.0,
	&"level_up": -11.0,
	&"stage_complete": -9.0,
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
	&"game_over": -8.0,
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
}

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0
var _sfx_bus_index: int = -1

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

func play_cue(cue: StringName, volume_db: float = INF) -> void:
	if _players.is_empty():
		return
	var stream: AudioStream = _get_stream(cue)
	if stream == null:
		return
	var player: AudioStreamPlayer = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
	player.stop()
	player.stream = stream
	player.volume_db = float(CUE_VOLUME_DB.get(cue, DEFAULT_VOLUME_DB)) if is_inf(volume_db) else volume_db
	player.play()

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
