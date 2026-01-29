extends Node

const PROFILE_VERSION: int = 1
const PROFILE_PATH: String = "user://profile.save"

var _profile_loaded: bool = false
var _profile_dirty: bool = false
var _unlocked_ids: Array[StringName] = []

func _ready() -> void:
	load_profile()

func load_profile() -> void:
	if _profile_loaded:
		return
	_profile_loaded = true
	_unlocked_ids = []
	_profile_dirty = false
	if not FileAccess.file_exists(PROFILE_PATH):
		_profile_dirty = true
		save_profile()
		return
	var file: FileAccess = FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if file == null:
		_profile_dirty = true
		save_profile()
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_backup_corrupt_profile()
		_profile_dirty = true
		save_profile()
		return
	var data: Dictionary = parsed as Dictionary
	var unlocked_values: Array = data.get("unlocked_ids", []) as Array
	for value in unlocked_values:
		var id_text: String = str(value).strip_edges()
		if id_text != "":
			var id: StringName = StringName(id_text)
			if not _unlocked_ids.has(id):
				_unlocked_ids.append(id)

func save_profile() -> void:
	if not _profile_loaded:
		load_profile()
	if not _profile_dirty:
		return
	var payload: Dictionary = {
		"version": PROFILE_VERSION,
		"unlocked_ids": _serialize_unlocked_ids(),
	}
	var json_text: String = JSON.stringify(payload)
	var file: FileAccess = FileAccess.open(PROFILE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(json_text)
	file.close()
	_profile_dirty = false

func has_unlocked(id: StringName) -> bool:
	if not _profile_loaded:
		load_profile()
	return _unlocked_ids.has(id)

func set_unlocked(id: StringName, unlocked: bool = true) -> void:
	if not _profile_loaded:
		load_profile()
	if id == &"":
		return
	var has_id: bool = _unlocked_ids.has(id)
	if unlocked:
		if has_id:
			return
		_unlocked_ids.append(id)
		_profile_dirty = true
		save_profile()
		return
	if not has_id:
		return
	_unlocked_ids.erase(id)
	_profile_dirty = true
	save_profile()

func get_unlocked_ids() -> Array[StringName]:
	if not _profile_loaded:
		load_profile()
	return _unlocked_ids.duplicate()

func _serialize_unlocked_ids() -> Array[String]:
	var items: Array[String] = []
	for id in _unlocked_ids:
		items.append(String(id))
	return items

func _backup_corrupt_profile() -> void:
	if not FileAccess.file_exists(PROFILE_PATH):
		return
	var backup_path: String = "%s.bak" % PROFILE_PATH
	DirAccess.rename_absolute(PROFILE_PATH, backup_path)
