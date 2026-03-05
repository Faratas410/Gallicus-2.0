extends Node

const RunPhaseContractScript = preload("res://scripts/contracts/run_phase_contract.gd")

const SILENT_DB: float = -60.0
const FADE_SECONDS: float = 1.25
const MUSIC_BUS_NAME: String = "Music"

var MENU_TRACK_PATHS: Array[String] = [
	"res://Music/Ambient1.mp3",
	"res://Music/CreditsOrCutscene1.mp3",
]
var RUN_SAFE_TRACK_PATHS: Array[String] = [
	"res://Music/Ambient2.mp3",
	"res://Music/Ambient3.mp3",
]
var RUN_TENSE_TRACK_PATHS: Array[String] = [
	"res://Music/Ambient4.mp3",
	"res://Music/Darkness.mp3",
	"res://Music/EternalDescent.mp3",
]
var RUN_CLIMAX_TRACK_PATHS: Array[String] = [
	"res://Music/Infernal.mp3",
	"res://Music/Doomfire.mp3",
	"res://Music/Havoc.mp3",
]
var ENDING_TRACK_PATHS: Array[String] = [
	"res://Music/LamentOfTheFallen.mp3",
	"res://Music/CreditsOrCutscene1.mp3",
]

const MENU_TARGET_DB: float = -14.0
const SAFE_TARGET_DB: float = -18.0
const TENSE_TARGET_DB: float = -16.0
const CLIMAX_TARGET_DB: float = -13.5
const ENDING_TARGET_DB: float = -15.0

@export var menu_player_path: NodePath = NodePath("MenuLayer/MenuThemePlayer")
@export var run_player_path: NodePath = NodePath("RunThemePlayer")
@export var fade_seconds: float = FADE_SECONDS

enum TrackSet {
	MENU,
	SAFE,
	TENSE,
	CLIMAX,
	ENDING,
}

var _menu_player: AudioStreamPlayer = null
var _run_player: AudioStreamPlayer = null
var _fade_tween: Tween = null
var _active_track_set: int = TrackSet.MENU
var _track_map: Dictionary = {}
var _track_index: Dictionary = {}
var _volume_scale: float = 1.0
var _music_bus_index: int = -1

func _ready() -> void:
	_menu_player = _resolve_player(menu_player_path, "MenuThemePlayer")
	_run_player = _resolve_player(run_player_path, "RunThemePlayer")
	if _menu_player == null or _run_player == null:
		push_warning("MusicDirector: missing audio players, music disabled.")
		return
	_ensure_music_bus()
	_initialize_track_sets()
	_wire_events()
	_apply_saved_music_volume()
	_play_menu_music_immediate()

func _resolve_player(path: NodePath, fallback_name: String) -> AudioStreamPlayer:
	var by_path: AudioStreamPlayer = get_node_or_null(path) as AudioStreamPlayer
	if by_path != null:
		return by_path
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	var scene_root: Node = tree.current_scene
	if scene_root == null:
		scene_root = tree.root
	if scene_root == null:
		return null
	return scene_root.find_child(fallback_name, true, false) as AudioStreamPlayer

func _ensure_music_bus() -> void:
	_music_bus_index = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	if _music_bus_index < 0:
		AudioServer.add_bus(AudioServer.bus_count)
		_music_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_music_bus_index, MUSIC_BUS_NAME)
		AudioServer.set_bus_send(_music_bus_index, "Master")
	_menu_player.bus = MUSIC_BUS_NAME
	_run_player.bus = MUSIC_BUS_NAME

func _initialize_track_sets() -> void:
	_track_map.clear()
	_track_index.clear()
	_track_map[TrackSet.MENU] = _load_tracks(MENU_TRACK_PATHS)
	_track_map[TrackSet.SAFE] = _load_tracks(RUN_SAFE_TRACK_PATHS)
	_track_map[TrackSet.TENSE] = _load_tracks(RUN_TENSE_TRACK_PATHS)
	_track_map[TrackSet.CLIMAX] = _load_tracks(RUN_CLIMAX_TRACK_PATHS)
	_track_map[TrackSet.ENDING] = _load_tracks(ENDING_TRACK_PATHS)
	for key in _track_map.keys():
		_track_index[key] = -1

func _load_tracks(paths: Array[String]) -> Array[AudioStream]:
	var tracks: Array[AudioStream] = []
	for path: String in paths:
		if not ResourceLoader.exists(path, "AudioStream"):
			continue
		var stream: AudioStream = load(path) as AudioStream
		if stream != null:
			tracks.append(stream)
	return tracks

func _wire_events() -> void:
	if _run_player != null:
		var run_finished_callable: Callable = Callable(self, "_on_run_track_finished")
		if not _run_player.finished.is_connected(run_finished_callable):
			_run_player.finished.connect(run_finished_callable)
	if _menu_player != null:
		var menu_finished_callable: Callable = Callable(self, "_on_menu_track_finished")
		if not _menu_player.finished.is_connected(menu_finished_callable):
			_menu_player.finished.connect(menu_finished_callable)
	if GameEvents.has_signal("run_phase_changed"):
		var phase_callable: Callable = Callable(self, "_on_run_phase_changed")
		if not GameEvents.run_phase_changed.is_connected(phase_callable):
			GameEvents.run_phase_changed.connect(phase_callable)
	if GameEvents.has_signal("run_started"):
		var started_callable: Callable = Callable(self, "_on_run_started")
		if not GameEvents.run_started.is_connected(started_callable):
			GameEvents.run_started.connect(started_callable)
	if GameEvents.has_signal("request_show_main_menu"):
		var menu_callable: Callable = Callable(self, "_on_request_show_main_menu")
		if not GameEvents.request_show_main_menu.is_connected(menu_callable):
			GameEvents.request_show_main_menu.connect(menu_callable)
	if GameEvents.has_signal("settings_changed"):
		var settings_callable: Callable = Callable(self, "_on_settings_changed")
		if not GameEvents.settings_changed.is_connected(settings_callable):
			GameEvents.settings_changed.connect(settings_callable)

func _apply_saved_music_volume() -> void:
	if SaveManager == null or not SaveManager.has_method("get_music_volume"):
		_apply_music_volume_linear(1.0)
		return
	_apply_music_volume_linear(float(SaveManager.get_music_volume()))

func _on_settings_changed(payload: Dictionary) -> void:
	if payload.has("music_volume"):
		_apply_music_volume_linear(float(payload.get("music_volume", 1.0)))

func _apply_music_volume_linear(value: float) -> void:
	_volume_scale = clamp(value, 0.0, 1.0)
	if _music_bus_index < 0:
		return
	var db_value: float = -80.0 if _volume_scale <= 0.001 else linear_to_db(_volume_scale)
	AudioServer.set_bus_volume_db(_music_bus_index, db_value)

func _on_run_phase_changed(phase: int) -> void:
	var set_id: int = _phase_to_track_set(phase)
	if set_id == TrackSet.MENU:
		_crossfade_to_menu()
		return
	_crossfade_to_run(set_id)

func _phase_to_track_set(phase: int) -> int:
	match phase:
		RunPhaseContractScript.MAIN_MENU:
			return TrackSet.MENU
		RunPhaseContractScript.RUN_INIT, RunPhaseContractScript.BET_PRESENT, RunPhaseContractScript.NEXT_BET:
			return TrackSet.SAFE
		RunPhaseContractScript.BET_COMMITTED, RunPhaseContractScript.POST_BET_MESSAGES, RunPhaseContractScript.INTERMEDIATE_CHOICE:
			return TrackSet.TENSE
		RunPhaseContractScript.PUSH_YOUR_LUCK, RunPhaseContractScript.RESOLUTION:
			return TrackSet.CLIMAX
		RunPhaseContractScript.GAME_OVER:
			return TrackSet.ENDING
		_:
			return TrackSet.SAFE

func _target_db_for_track_set(set_id: int) -> float:
	match set_id:
		TrackSet.MENU:
			return MENU_TARGET_DB
		TrackSet.SAFE:
			return SAFE_TARGET_DB
		TrackSet.TENSE:
			return TENSE_TARGET_DB
		TrackSet.CLIMAX:
			return CLIMAX_TARGET_DB
		TrackSet.ENDING:
			return ENDING_TARGET_DB
		_:
			return SAFE_TARGET_DB

func _on_run_started() -> void:
	_crossfade_to_run(TrackSet.SAFE)

func _on_request_show_main_menu() -> void:
	_crossfade_to_menu()

func _on_menu_track_finished() -> void:
	if _active_track_set == TrackSet.MENU:
		_assign_next_track(_menu_player, TrackSet.MENU)

func _on_run_track_finished() -> void:
	if _active_track_set == TrackSet.MENU:
		return
	_assign_next_track(_run_player, _active_track_set)

func _crossfade_to_menu() -> void:
	if _menu_player == null or _run_player == null:
		return
	_active_track_set = TrackSet.MENU
	_assign_next_track(_menu_player, TrackSet.MENU)
	if not _menu_player.playing:
		_menu_player.play()
	_kill_fade_tween()
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(_menu_player, "volume_db", MENU_TARGET_DB, fade_seconds)
	_fade_tween.parallel().tween_property(_run_player, "volume_db", SILENT_DB, fade_seconds)
	_fade_tween.tween_callback(Callable(self, "_stop_run_if_silent"))

func _crossfade_to_run(set_id: int) -> void:
	if _menu_player == null or _run_player == null:
		return
	_active_track_set = set_id
	_assign_next_track(_run_player, set_id)
	if not _run_player.playing:
		_run_player.play()
	_kill_fade_tween()
	_fade_tween = create_tween()
	_fade_tween.set_trans(Tween.TRANS_SINE)
	_fade_tween.set_ease(Tween.EASE_IN_OUT)
	_fade_tween.tween_property(_run_player, "volume_db", _target_db_for_track_set(set_id), fade_seconds)
	_fade_tween.parallel().tween_property(_menu_player, "volume_db", SILENT_DB, fade_seconds)
	_fade_tween.tween_callback(Callable(self, "_stop_menu_if_silent"))

func _play_menu_music_immediate() -> void:
	if _menu_player == null:
		return
	_active_track_set = TrackSet.MENU
	_assign_next_track(_menu_player, TrackSet.MENU)
	_menu_player.volume_db = MENU_TARGET_DB
	if not _menu_player.playing:
		_menu_player.play()
	if _run_player != null:
		_run_player.stop()
		_run_player.volume_db = SILENT_DB

func _assign_next_track(player: AudioStreamPlayer, set_id: int) -> void:
	if player == null:
		return
	var tracks: Array[AudioStream] = _track_map.get(set_id, []) as Array[AudioStream]
	if tracks.is_empty():
		return
	var idx: int = int(_track_index.get(set_id, -1))
	idx = (idx + 1) % tracks.size()
	_track_index[set_id] = idx
	player.stream = tracks[idx]

func _stop_menu_if_silent() -> void:
	if _menu_player == null:
		return
	if _menu_player.volume_db <= SILENT_DB + 0.1:
		_menu_player.stop()

func _stop_run_if_silent() -> void:
	if _run_player == null:
		return
	if _run_player.volume_db <= SILENT_DB + 0.1:
		_run_player.stop()

func _kill_fade_tween() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null

func _find_audio_player(node_name: String) -> AudioStreamPlayer:
	var root: Node = get_tree().current_scene if get_tree() != null else null
	if root == null:
		return null
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node != null and node.name == node_name and node is AudioStreamPlayer:
			return node as AudioStreamPlayer
		for child: Node in node.get_children():
			stack.append(child)
	return null



