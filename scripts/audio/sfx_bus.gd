extends Node

const DEFAULT_VOLUME_DB: float = -10.0
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
	&"game_over": "res://assets/audio/sfx/game_over.wav",
}

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player_index: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index: int in range(POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		player.volume_db = DEFAULT_VOLUME_DB
		add_child(player)
		_players.append(player)
	_preload_streams()

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
