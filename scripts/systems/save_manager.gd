extends Node

const PROFILE_VERSION: int = 2
const PROFILE_PATH: String = "user://profile.save"
const TMP_PATH: String = "%s.tmp" % PROFILE_PATH
const BAK_PATH: String = "%s.bak" % PROFILE_PATH
const BAK2_PATH: String = "%s.bak2" % PROFILE_PATH
const RUN_SCHEMA_VERSION: int = 1
const RUN_PATH: String = "user://run.save"
const RUN_TMP_PATH: String = "%s.tmp" % RUN_PATH
const RUN_BAK_PATH: String = "%s.bak" % RUN_PATH
const RUN_BAK2_PATH: String = "%s.bak2" % RUN_PATH

var _profile_loaded: bool = false
var _profile_dirty: bool = false
var _unlocked_ids: Array[StringName] = []
var _settings: Dictionary = {}

const DEFAULT_LANGUAGE: String = "it"
const DEFAULT_BRIGHTNESS: float = 1.0
const DEFAULT_MASTER_VOLUME: float = 0.8
const BRIGHTNESS_MIN: float = 0.6
const BRIGHTNESS_MAX: float = 1.4
const VOLUME_MIN: float = 0.0
const VOLUME_MAX: float = 1.0

func _ready() -> void:
	load_profile()

func load_profile() -> void:
	if _profile_loaded:
		return
	_profile_loaded = true
	_unlocked_ids = []
	_settings = _get_default_settings()
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
		"version": PROFILE_VERSION,
		"unlocked_ids": _serialize_unlocked_ids(),
		"settings": _serialize_settings(),
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

func get_settings() -> Dictionary:
	if not _profile_loaded:
		load_profile()
	return _settings.duplicate(true)

func get_language() -> String:
	if not _profile_loaded:
		load_profile()
	return str(_settings.get("language", DEFAULT_LANGUAGE))

func get_brightness() -> float:
	if not _profile_loaded:
		load_profile()
	return float(_settings.get("brightness", DEFAULT_BRIGHTNESS))

func get_master_volume() -> float:
	if not _profile_loaded:
		load_profile()
	return float(_settings.get("master_volume", DEFAULT_MASTER_VOLUME))

func set_language(value: String) -> void:
	if not _profile_loaded:
		load_profile()
	var sanitized: String = _sanitize_language(value)
	if str(_settings.get("language", DEFAULT_LANGUAGE)) == sanitized:
		return
	_settings["language"] = sanitized
	_profile_dirty = true
	save_profile()

func set_brightness(value: float) -> void:
	if not _profile_loaded:
		load_profile()
	var sanitized: float = _sanitize_brightness(value)
	if is_equal_approx(float(_settings.get("brightness", DEFAULT_BRIGHTNESS)), sanitized):
		return
	_settings["brightness"] = sanitized
	_profile_dirty = true
	save_profile()

func set_master_volume(value: float) -> void:
	if not _profile_loaded:
		load_profile()
	var sanitized: float = _sanitize_master_volume(value)
	if is_equal_approx(float(_settings.get("master_volume", DEFAULT_MASTER_VOLUME)), sanitized):
		return
	_settings["master_volume"] = sanitized
	_profile_dirty = true
	save_profile()

func _serialize_unlocked_ids() -> Array[String]:
	var items: Array[String] = []
	for id in _unlocked_ids:
		items.append(String(id))
	return items

func _serialize_settings() -> Dictionary:
	return _settings.duplicate(true)

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
	var version_value: Variant = data.get("version", data.get("schema_version", PROFILE_VERSION))
	var from_version: int = int(version_value)
	if from_version <= 0:
		from_version = 1
	if from_version < PROFILE_VERSION:
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
	_load_settings_from_profile(data)
	return true

func _validate_profile_dict(data: Dictionary) -> bool:
	if data.has("unlocked_ids") and not (data["unlocked_ids"] is Array):
		return false
	return true

func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	var current: Dictionary = data
	var working_version: int = from_version
	while working_version < PROFILE_VERSION:
		match working_version:
			1:
				current = _migrate_v1_to_v2(current)
			_:
				break
		working_version += 1
	return current

func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
	return data

func _get_default_settings() -> Dictionary:
	return {
		"language": DEFAULT_LANGUAGE,
		"brightness": DEFAULT_BRIGHTNESS,
		"master_volume": DEFAULT_MASTER_VOLUME,
	}

func _sanitize_language(value: String) -> String:
	var locale: String = value.strip_edges().to_lower()
	if locale != "it" and locale != "en":
		return DEFAULT_LANGUAGE
	return locale

func _sanitize_brightness(value: float) -> float:
	return clamp(value, BRIGHTNESS_MIN, BRIGHTNESS_MAX)

func _sanitize_master_volume(value: float) -> float:
	return clamp(value, VOLUME_MIN, VOLUME_MAX)

func _load_settings_from_profile(data: Dictionary) -> void:
	var needs_save: bool = false
	var settings_value: Dictionary = {}
	if data.has("settings") and data["settings"] is Dictionary:
		settings_value = data["settings"] as Dictionary
	else:
		needs_save = true
	var sanitized: Dictionary = _get_default_settings()
	var locale_value: String = DEFAULT_LANGUAGE
	if settings_value.has("language"):
		locale_value = _sanitize_language(str(settings_value.get("language", DEFAULT_LANGUAGE)))
	else:
		needs_save = true
	if settings_value.has("brightness"):
		sanitized["brightness"] = _sanitize_brightness(float(settings_value.get("brightness", DEFAULT_BRIGHTNESS)))
	else:
		needs_save = true
	if settings_value.has("master_volume"):
		sanitized["master_volume"] = _sanitize_master_volume(float(settings_value.get("master_volume", DEFAULT_MASTER_VOLUME)))
	else:
		needs_save = true
	sanitized["language"] = locale_value
	if not needs_save:
		if str(settings_value.get("language", "")) != str(sanitized["language"]):
			needs_save = true
		if not is_equal_approx(float(settings_value.get("brightness", DEFAULT_BRIGHTNESS)), float(sanitized["brightness"])):
			needs_save = true
		if not is_equal_approx(float(settings_value.get("master_volume", DEFAULT_MASTER_VOLUME)), float(sanitized["master_volume"])):
			needs_save = true
	_settings = sanitized
	if needs_save:
		_profile_dirty = true

func has_run_save() -> bool:
	return FileAccess.file_exists(RUN_PATH) or FileAccess.file_exists(RUN_BAK_PATH)

func load_run() -> Dictionary:
	var payload: Dictionary = {}
	if FileAccess.file_exists(RUN_PATH):
		if _load_run_from_path(RUN_PATH, payload):
			return payload
		_backup_corrupt_run()
		if FileAccess.file_exists(RUN_BAK_PATH) and _load_run_from_path(RUN_BAK_PATH, payload):
			return payload
		return {}
	if FileAccess.file_exists(RUN_BAK_PATH) and _load_run_from_path(RUN_BAK_PATH, payload):
		return payload
	return {}

func save_run(data: Dictionary) -> void:
	var payload: Dictionary = {
		"schema_version": RUN_SCHEMA_VERSION,
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"payload": data,
	}
	var json_text: String = JSON.stringify(payload)
	var file: FileAccess = FileAccess.open(RUN_TMP_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(json_text)
	file.close()
	var tmp_abs: String = ProjectSettings.globalize_path(RUN_TMP_PATH)
	var run_abs: String = ProjectSettings.globalize_path(RUN_PATH)
	var bak_abs: String = ProjectSettings.globalize_path(RUN_BAK_PATH)
	var bak2_abs: String = ProjectSettings.globalize_path(RUN_BAK2_PATH)
	if FileAccess.file_exists(RUN_BAK2_PATH):
		DirAccess.remove_absolute(bak2_abs)
	if FileAccess.file_exists(RUN_BAK_PATH):
		DirAccess.rename_absolute(bak_abs, bak2_abs)
	var can_replace: bool = true
	if FileAccess.file_exists(RUN_PATH):
		var move_err: Error = DirAccess.rename_absolute(run_abs, bak_abs)
		if move_err != OK:
			can_replace = false
	if can_replace:
		DirAccess.rename_absolute(tmp_abs, run_abs)

func clear_run() -> void:
	var tmp_abs: String = ProjectSettings.globalize_path(RUN_TMP_PATH)
	var run_abs: String = ProjectSettings.globalize_path(RUN_PATH)
	var bak_abs: String = ProjectSettings.globalize_path(RUN_BAK_PATH)
	var bak2_abs: String = ProjectSettings.globalize_path(RUN_BAK2_PATH)
	if FileAccess.file_exists(RUN_TMP_PATH):
		DirAccess.remove_absolute(tmp_abs)
	if FileAccess.file_exists(RUN_PATH):
		DirAccess.remove_absolute(run_abs)
	if FileAccess.file_exists(RUN_BAK_PATH):
		DirAccess.remove_absolute(bak_abs)
	if FileAccess.file_exists(RUN_BAK2_PATH):
		DirAccess.remove_absolute(bak2_abs)

func _backup_corrupt_run() -> void:
	if not FileAccess.file_exists(RUN_PATH):
		return
	var timestamp: int = int(Time.get_unix_time_from_system())
	var corrupt_path: String = "user://run.corrupt.%d.save" % timestamp
	var run_abs: String = ProjectSettings.globalize_path(RUN_PATH)
	var corrupt_abs: String = ProjectSettings.globalize_path(corrupt_path)
	DirAccess.rename_absolute(run_abs, corrupt_abs)

func _load_run_from_path(path: String, out_payload: Dictionary) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed as Dictionary
	if not _validate_run_dict(data):
		return false
	var version_value: Variant = data.get("schema_version", RUN_SCHEMA_VERSION)
	if typeof(version_value) != TYPE_INT:
		return false
	var from_version: int = int(version_value)
	if from_version <= 0:
		from_version = 1
	if from_version < RUN_SCHEMA_VERSION:
		data = _migrate_run(data, from_version)
	var payload_value: Variant = data.get("payload", {})
	if not (payload_value is Dictionary):
		return false
	out_payload.clear()
	out_payload.merge(payload_value as Dictionary, true)
	return true

func _validate_run_dict(data: Dictionary) -> bool:
	if not data.has("schema_version"):
		return false
	if typeof(data["schema_version"]) != TYPE_INT:
		return false
	if not data.has("payload"):
		return false
	if not (data["payload"] is Dictionary):
		return false
	return true

func _migrate_run(data: Dictionary, from_version: int) -> Dictionary:
	var current: Dictionary = data
	var working_version: int = from_version
	while working_version < RUN_SCHEMA_VERSION:
		match working_version:
			1:
				current = _migrate_run_v1_to_v2(current)
			_:
				break
		working_version += 1
	return current

func _migrate_run_v1_to_v2(data: Dictionary) -> Dictionary:
	return data
