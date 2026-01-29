extends Node

const SCHEMA_VERSION: int = 1
const PROFILE_PATH: String = "user://profile.save"
const TMP_PATH: String = "%s.tmp" % PROFILE_PATH
const BAK_PATH: String = "%s.bak" % PROFILE_PATH
const BAK2_PATH: String = "%s.bak2" % PROFILE_PATH

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
	if FileAccess.file_exists(PROFILE_PATH):
		if _load_profile_from_path(PROFILE_PATH):
			if _profile_dirty:
				save_profile()
			return
		_backup_corrupt_profile()
		if FileAccess.file_exists(BAK_PATH) and _load_profile_from_path(BAK_PATH):
			_profile_dirty = true
			save_profile()
			return
		_profile_dirty = true
		save_profile()
		return
	if FileAccess.file_exists(BAK_PATH) and _load_profile_from_path(BAK_PATH):
		_profile_dirty = true
		save_profile()
		return
	_profile_dirty = true
	save_profile()

func save_profile() -> void:
	if not _profile_loaded:
		load_profile()
	if not _profile_dirty:
		return
	var payload: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"unlocked_ids": _serialize_unlocked_ids(),
	}
	var json_text: String = JSON.stringify(payload)
	var file: FileAccess = FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(json_text)
	file.close()
	var tmp_abs: String = ProjectSettings.globalize_path(TMP_PATH)
	var profile_abs: String = ProjectSettings.globalize_path(PROFILE_PATH)
	var bak_abs: String = ProjectSettings.globalize_path(BAK_PATH)
	var bak2_abs: String = ProjectSettings.globalize_path(BAK2_PATH)
	if FileAccess.file_exists(BAK2_PATH):
		DirAccess.remove_absolute(bak2_abs)
	if FileAccess.file_exists(BAK_PATH):
		DirAccess.rename_absolute(bak_abs, bak2_abs)
	var can_replace: bool = true
	if FileAccess.file_exists(PROFILE_PATH):
		var move_err: Error = DirAccess.rename_absolute(profile_abs, bak_abs)
		if move_err != OK:
			can_replace = false
	if can_replace:
		var replace_err: Error = DirAccess.rename_absolute(tmp_abs, profile_abs)
		if replace_err == OK:
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
	var timestamp: int = int(Time.get_unix_time_from_system())
	var corrupt_path: String = "user://profile.corrupt.%d.save" % timestamp
	var profile_abs: String = ProjectSettings.globalize_path(PROFILE_PATH)
	var corrupt_abs: String = ProjectSettings.globalize_path(corrupt_path)
	DirAccess.rename_absolute(profile_abs, corrupt_abs)

func _load_profile_from_path(path: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed as Dictionary
	if not _validate_profile_dict(data):
		return false
	var version_value: Variant = data.get("schema_version", data.get("version", SCHEMA_VERSION))
	var from_version: int = int(version_value)
	if from_version <= 0:
		from_version = 1
	if from_version < SCHEMA_VERSION:
		data = _migrate(data, from_version)
		_profile_dirty = true
	var unlocked_values: Array = []
	if data.has("unlocked_ids") and data["unlocked_ids"] is Array:
		unlocked_values = data["unlocked_ids"] as Array
	for value in unlocked_values:
		var id_text: String = str(value).strip_edges()
		if id_text != "":
			var id: StringName = StringName(id_text)
			if not _unlocked_ids.has(id):
				_unlocked_ids.append(id)
	return true

func _validate_profile_dict(data: Dictionary) -> bool:
	if data.has("unlocked_ids") and not (data["unlocked_ids"] is Array):
		return false
	return true

func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	var current: Dictionary = data
	var working_version: int = from_version
	while working_version < SCHEMA_VERSION:
		match working_version:
			1:
				current = _migrate_v1_to_v2(current)
			_:
				break
		working_version += 1
	return current

func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
	return data
