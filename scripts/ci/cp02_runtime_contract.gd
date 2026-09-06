extends SceneTree

const SaveManagerScript = preload("res://scripts/systems/save_manager.gd")
const SaveSystemScript = preload("res://scripts/systems/run/save_system.gd")
const FlowStepContractScript = preload("res://scripts/contracts/run_save_flow_step_contract.gd")

var _failed: bool = false

func _initialize() -> void:
	_run_contract()
	if _failed:
		quit(1)
		return
	print("CP02_RUNTIME_CONTRACT_OK")
	quit(0)

func _run_contract() -> void:
	_clear_profile_files()
	var v3_profile: Dictionary = {
		"version": 3,
		"unlocked_ids": ["CONDANNA_TEST"],
		"settings": {
			"language": "es",
			"brightness": 1.2,
			"master_volume": 0.6,
			"music_volume": 0.4,
			"fullscreen": true,
			"window_resolution": "1920x1080",
		},
		"meta": {"registry_pressure": 3.5, "registry_era": 2},
	}
	_write_text("user://profile.save", JSON.stringify(v3_profile))
	var profile: Node = SaveManagerScript.new()
	profile.call("load_profile")
	_expect(profile.call("get_language") == "es", "v3 language was not preserved")
	_expect(is_equal_approx(float(profile.call("get_sfx_volume")), 1.0), "v3->v4 SFX default missing")
	_expect(not bool(profile.call("get_reduced_motion")), "v3->v4 reduced-motion default must be false")
	_expect(bool(profile.call("get_fullscreen")), "v3 fullscreen was not preserved")
	_expect(profile.call("get_window_resolution") == "1920x1080", "v3 resolution was not preserved")
	_expect(profile.call("has_unlocked", &"CONDANNA_TEST"), "v3 unlock was not preserved")
	_expect(is_equal_approx(float(profile.call("get_registry_pressure")), 3.5), "v3 meta was not preserved")

	profile.call("set_sfx_volume", -4.0)
	_expect(is_equal_approx(float(profile.call("get_sfx_volume")), 0.0), "SFX lower clamp failed")
	profile.call("set_sfx_volume", 4.0)
	_expect(is_equal_approx(float(profile.call("get_sfx_volume")), 1.0), "SFX upper clamp failed")
	profile.call("set_sfx_volume", 0.42)
	profile.call("set_reduced_motion", true)
	var reloaded_profile: Node = SaveManagerScript.new()
	reloaded_profile.call("load_profile")
	_expect(is_equal_approx(float(reloaded_profile.call("get_sfx_volume")), 0.42), "SFX round-trip failed")
	_expect(bool(reloaded_profile.call("get_reduced_motion")), "reduced-motion round-trip failed")
	var saved_profile: Dictionary = _read_json_dictionary("user://profile.save")
	_expect(int(saved_profile.get("version", 0)) == SaveManagerScript.PROFILE_VERSION, "migrated profile was not persisted at current version")

	var save_system: SaveSystem = SaveSystemScript.new()
	save_system.clear_run()
	var backup_payload: Dictionary = {"contract_id": "backup", "value": 1}
	var primary_payload: Dictionary = {"contract_id": "primary", "value": 2}
	_expect(save_system.save_run_payload(backup_payload), "could not write recovery backup fixture")
	_expect(save_system.save_run_payload(primary_payload), "could not write recovery primary fixture")
	_write_text(SaveSystem.RUN_PATH, "{broken-json")
	var recovery: Dictionary = save_system.load_run_payload_result()
	_expect(bool(recovery.get("ok", false)), "backup recovery did not succeed: %s" % str(recovery))
	_expect(str(recovery.get("source", "")) == "backup", "backup recovery source was not reported")
	_expect(str((recovery.get("payload", {}) as Dictionary).get("contract_id", "")) == "backup", "wrong backup payload recovered")
	var regenerated: Dictionary = {}
	_expect(save_system._load_run_from_path(SaveSystem.RUN_PATH, regenerated), "primary was not regenerated after recovery")

	save_system.clear_run()
	var incompatible_wrapper: Dictionary = {"schema_version": 99, "payload": {"contract_id": "incompatible"}}
	_write_text(SaveSystem.RUN_PATH, JSON.stringify(incompatible_wrapper))
	_write_text(SaveSystem.RUN_BAK_PATH, JSON.stringify(incompatible_wrapper))
	var rejected: Dictionary = save_system.load_run_payload_result()
	_expect(not bool(rejected.get("ok", true)), "incompatible save set was accepted")
	_expect(str(rejected.get("reason", "")) == "unsupported_save_wrapper_schema", "incompatible reason was not preserved: %s" % str(rejected))
	_expect(not FileAccess.file_exists(SaveSystem.RUN_PATH), "incompatible primary was not quarantined")
	_expect(not FileAccess.file_exists(SaveSystem.RUN_BAK_PATH), "incompatible backup was not quarantined")
	_expect(_count_quarantine_files() >= 2, "quarantine files were not preserved")

	_expect(
		FlowStepContractScript.normalize_boundary_value(&"14", false, true) == FlowStepContractScript.INTERMEDIATE_CHOICE,
		"legacy numeric flow step was not normalized"
	)
	_expect(
		FlowStepContractScript.normalize_boundary_value(&"POST_BET_MESSAGES", false, true) == FlowStepContractScript.INTERMEDIATE_CHOICE,
		"legacy named flow step was not normalized"
	)
	_expect(FlowStepContractScript.normalize_boundary_value(&"UNKNOWN_STEP", false, true) == &"", "unknown flow step was not rejected")

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("CP02_RUNTIME_CONTRACT_FAIL: %s" % message)

func _write_text(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_expect(false, "could not open fixture path: %s" % path)
		return
	file.store_string(text)
	file.close()

func _read_json_dictionary(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}

func _clear_profile_files() -> void:
	for path: String in ["user://profile.save", "user://profile.save.tmp", "user://profile.save.bak", "user://profile.save.bak2"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _count_quarantine_files() -> int:
	var directory: DirAccess = DirAccess.open("user://")
	if directory == null:
		return 0
	var count: int = 0
	for file_name: String in directory.get_files():
		if ".quarantine." in file_name:
			count += 1
	return count
