class_name SaveSystem
extends RefCounted

const RUN_SCHEMA_VERSION: int = 1
const RUN_PATH: String = "user://run.save"
const RUN_TMP_PATH: String = "%s.tmp" % RUN_PATH
const RUN_BAK_PATH: String = "%s.bak" % RUN_PATH
const RUN_BAK2_PATH: String = "%s.bak2" % RUN_PATH

func has_run_save() -> bool:
	return FileAccess.file_exists(RUN_PATH) or FileAccess.file_exists(RUN_BAK_PATH)


func save_run(state: RunState, run_payload: Dictionary = {}, scars_detail: Array[Dictionary] = [], run_state_schema_version: int = 1) -> bool:
	if state == null:
		return false
	var payload: Dictionary = {
		"schema_version": run_state_schema_version,
		"run": run_payload,
		"run_state": state.to_dict(),
		"scars_detail": scars_detail,
	}
	return save_run_payload(payload)

func load_run() -> Dictionary:
	var payload: Dictionary = load_run_payload()
	if payload.is_empty():
		return {}
	if not payload.has("run_state") or not (payload["run_state"] is Dictionary):
		return {}
	var state: RunState = RunState.new()
	state.reset()
	state.from_dict(payload["run_state"] as Dictionary)
	return {
		"ok": true,
		"state": state,
		"payload": payload,
	}
func save_run_payload(payload: Dictionary) -> bool:
	var wrapped_payload: Dictionary = {
		"schema_version": RUN_SCHEMA_VERSION,
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"payload": payload,
	}
	var json_text: String = JSON.stringify(wrapped_payload)
	var file: FileAccess = FileAccess.open(RUN_TMP_PATH, FileAccess.WRITE)
	if file == null:
		return false
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
	if not can_replace:
		return false
	var replace_err: Error = DirAccess.rename_absolute(tmp_abs, run_abs)
	return replace_err == OK

func load_run_payload() -> Dictionary:
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
	if not data.has("schema_version") or typeof(data.get("schema_version")) != TYPE_INT:
		return false
	if not data.has("payload") or not (data.get("payload") is Dictionary):
		return false
	var version_value: int = int(data.get("schema_version", RUN_SCHEMA_VERSION))
	if version_value != RUN_SCHEMA_VERSION:
		return false
	out_payload.clear()
	out_payload.merge(data.get("payload", {}) as Dictionary, true)
	return true
