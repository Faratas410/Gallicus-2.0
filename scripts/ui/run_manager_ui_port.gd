extends RefCounted
class_name RunManagerUiPort

var _tree: SceneTree
var _run_manager: Node = null

func _init(tree: SceneTree) -> void:
	_tree = tree

func _get_manager() -> Node:
	if _run_manager != null and is_instance_valid(_run_manager):
		return _run_manager
	if _tree == null:
		return null
	_run_manager = _tree.get_first_node_in_group("run_manager")
	return _run_manager

func has_manager() -> bool:
	return _get_manager() != null

func is_visual_only() -> bool:
	var manager: Node = _get_manager()
	if manager == null:
		return false
	return bool(manager.is_visual_only())

func get_arena() -> Node:
	var manager: Node = _get_manager()
	if manager == null:
		return null
	return manager.get_arena()

func get_arena_index() -> int:
	var manager: Node = _get_manager()
	if manager == null:
		return 0
	return int(manager.get_arena_index())

func has_lying_pact_reveal(pact_id: StringName) -> bool:
	var manager: Node = _get_manager()
	if manager == null:
		return false
	var reveal_text: String = str(manager.get_level3_pact_reveal_text(pact_id))
	return reveal_text != ""

func get_available_level3_pacts() -> Array[StringName]:
	var manager: Node = _get_manager()
	if manager == null:
		var empty: Array[StringName] = []
		return empty
	return manager.get_available_level3_pacts() as Array[StringName]

func get_available_arena_themes() -> Array[StringName]:
	var manager: Node = _get_manager()
	if manager == null:
		var empty: Array[StringName] = []
		return empty
	return manager.get_available_arena_themes() as Array[StringName]

func is_harsh_crowd_unlocked() -> bool:
	var manager: Node = _get_manager()
	if manager == null:
		return false
	return bool(manager.is_harsh_crowd_unlocked())

func get_crowd_line_count_base() -> int:
	var manager: Node = _get_manager()
	if manager == null:
		return 0
	return int(manager.get_crowd_line_count_base())

func get_crowd_line_count_harsh() -> int:
	var manager: Node = _get_manager()
	if manager == null:
		return 0
	return int(manager.get_crowd_line_count_harsh())

func get_level3_pact_title(pact_id: StringName) -> String:
	var manager: Node = _get_manager()
	if manager == null:
		return ""
	return str(manager.get_level3_pact_title(pact_id))
