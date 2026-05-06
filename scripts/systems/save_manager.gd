extends Node

const PROFILE_VERSION: int = 3
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
var _meta: Dictionary = {}

const DEFAULT_LANGUAGE: String = "it"
const DEFAULT_BRIGHTNESS: float = 1.0
const DEFAULT_MASTER_VOLUME: float = 0.8
const DEFAULT_MUSIC_VOLUME: float = 0.75
const DEFAULT_FULLSCREEN: bool = false
const DEFAULT_WINDOW_RESOLUTION: String = "1280x720"
const BRIGHTNESS_MIN: float = 0.6
const BRIGHTNESS_MAX: float = 1.4
const VOLUME_MIN: float = 0.0
const VOLUME_MAX: float = 1.0
const ALLOWED_WINDOW_RESOLUTIONS: Array[String] = [
	"960x540",
	"1280x720",
	"1600x900",
	"1920x1080",
]

func _ready() -> void:
	load_profile()

func load_profile() -> void:
	if _profile_loaded:
		return
	_profile_loaded = true
	_unlocked_ids = []
	_settings = _get_default_settings()
	_meta = _get_default_meta()
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
		"meta": _serialize_meta(),
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

func get_music_volume() -> float:
	if not _profile_loaded:
		load_profile()
	return float(_settings.get("music_volume", DEFAULT_MUSIC_VOLUME))

func get_fullscreen() -> bool:
	if not _profile_loaded:
		load_profile()
	return bool(_settings.get("fullscreen", DEFAULT_FULLSCREEN))

func get_window_resolution() -> String:
	if not _profile_loaded:
		load_profile()
	return str(_settings.get("window_resolution", DEFAULT_WINDOW_RESOLUTION))

func get_registry_pressure() -> float:
	if not _profile_loaded:
		load_profile()
	return float(_meta.get("registry_pressure", 0.0))

func get_registry_era() -> int:
	if not _profile_loaded:
		load_profile()
	return int(_meta.get("registry_era", 0))

func set_registry_state(pressure: float, era: int) -> void:
	if not _profile_loaded:
		load_profile()
	var sanitized_pressure: float = _sanitize_registry_pressure(pressure)
	var sanitized_era: int = _sanitize_registry_era(era)
	var current_pressure: float = float(_meta.get("registry_pressure", 0.0))
	var current_era: int = int(_meta.get("registry_era", 0))
	if is_equal_approx(current_pressure, sanitized_pressure) and current_era == sanitized_era:
		return
	_meta["registry_pressure"] = sanitized_pressure
	_meta["registry_era"] = sanitized_era
	_profile_dirty = true
	save_profile()

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

func set_music_volume(value: float) -> void:
	if not _profile_loaded:
		load_profile()
	var sanitized: float = _sanitize_music_volume(value)
	if is_equal_approx(float(_settings.get("music_volume", DEFAULT_MUSIC_VOLUME)), sanitized):
		return
	_settings["music_volume"] = sanitized
	_profile_dirty = true
	save_profile()

func set_fullscreen(value: bool) -> void:
	if not _profile_loaded:
		load_profile()
	var current: bool = bool(_settings.get("fullscreen", DEFAULT_FULLSCREEN))
	if current == value:
		return
	_settings["fullscreen"] = value
	_profile_dirty = true
	save_profile()

func set_window_resolution(value: String) -> void:
	if not _profile_loaded:
		load_profile()
	var sanitized: String = _sanitize_window_resolution(value)
	if str(_settings.get("window_resolution", DEFAULT_WINDOW_RESOLUTION)) == sanitized:
		return
	_settings["window_resolution"] = sanitized
	_profile_dirty = true
	save_profile()

func _serialize_unlocked_ids() -> Array[String]:
	var items: Array[String] = []
	for id in _unlocked_ids:
		items.append(String(id))
	return items

func _serialize_settings() -> Dictionary:
	return _settings.duplicate(true)

func _serialize_meta() -> Dictionary:
	return _meta.duplicate(true)

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
	_load_meta_from_profile(data)
	return true

func _validate_profile_dict(data: Dictionary) -> bool:
	if data.has("unlocked_ids") and not (data["unlocked_ids"] is Array):
		return false
	if data.has("meta") and not (data["meta"] is Dictionary):
		return false
	return true

func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	var current: Dictionary = data
	var working_version: int = from_version
	while working_version < PROFILE_VERSION:
		match working_version:
			1:
				current = _migrate_v1_to_v2(current)
			2:
				current = _migrate_v2_to_v3(current)
			_:
				break
		working_version += 1
	return current

func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
	return data

func _migrate_v2_to_v3(data: Dictionary) -> Dictionary:
	return data

func _get_default_settings() -> Dictionary:
	return {
		"language": DEFAULT_LANGUAGE,
		"brightness": DEFAULT_BRIGHTNESS,
		"master_volume": DEFAULT_MASTER_VOLUME,
		"music_volume": DEFAULT_MUSIC_VOLUME,
		"fullscreen": DEFAULT_FULLSCREEN,
		"window_resolution": DEFAULT_WINDOW_RESOLUTION,
	}

func _get_default_meta() -> Dictionary:
	return {
		"registry_pressure": 0.0,
		"registry_era": 0,
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

func _sanitize_music_volume(value: float) -> float:
	return clamp(value, VOLUME_MIN, VOLUME_MAX)

func _sanitize_window_resolution(value: String) -> String:
	var resolution: String = value.strip_edges().to_lower()
	if not ALLOWED_WINDOW_RESOLUTIONS.has(resolution):
		return DEFAULT_WINDOW_RESOLUTION
	return resolution

func _sanitize_registry_pressure(value: float) -> float:
	return maxf(value, 0.0)

func _sanitize_registry_era(value: int) -> int:
	# Canon range is finite and monotonic: 0..4 (4 = Absence).
	# Legacy values >= 5 are capped to 4 for in-place compatible migration.
	return clampi(value, 0, 4)

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
	if settings_value.has("music_volume"):
		sanitized["music_volume"] = _sanitize_music_volume(float(settings_value.get("music_volume", DEFAULT_MUSIC_VOLUME)))
	else:
		needs_save = true
	if settings_value.has("fullscreen"):
		sanitized["fullscreen"] = bool(settings_value.get("fullscreen", DEFAULT_FULLSCREEN))
	else:
		needs_save = true
	if settings_value.has("window_resolution"):
		sanitized["window_resolution"] = _sanitize_window_resolution(str(settings_value.get("window_resolution", DEFAULT_WINDOW_RESOLUTION)))
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
		if not is_equal_approx(float(settings_value.get("music_volume", DEFAULT_MUSIC_VOLUME)), float(sanitized["music_volume"])):
			needs_save = true
		if bool(settings_value.get("fullscreen", DEFAULT_FULLSCREEN)) != bool(sanitized["fullscreen"]):
			needs_save = true
		if str(settings_value.get("window_resolution", DEFAULT_WINDOW_RESOLUTION)) != str(sanitized["window_resolution"]):
			needs_save = true
	_settings = sanitized
	if needs_save:
		_profile_dirty = true

func _load_meta_from_profile(data: Dictionary) -> void:
	var needs_save: bool = false
	var meta_value: Dictionary = {}
	if data.has("meta") and data["meta"] is Dictionary:
		meta_value = data["meta"] as Dictionary
	else:
		needs_save = true
	var sanitized: Dictionary = _get_default_meta()
	if meta_value.has("registry_pressure"):
		sanitized["registry_pressure"] = _sanitize_registry_pressure(float(meta_value.get("registry_pressure", 0.0)))
	else:
		needs_save = true
	if meta_value.has("registry_era"):
		sanitized["registry_era"] = _sanitize_registry_era(int(meta_value.get("registry_era", 0)))
	else:
		needs_save = true
	if not needs_save:
		if not is_equal_approx(float(meta_value.get("registry_pressure", 0.0)), float(sanitized["registry_pressure"])):
			needs_save = true
		if int(meta_value.get("registry_era", 0)) != int(sanitized["registry_era"]):
			needs_save = true
	_meta = sanitized
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
