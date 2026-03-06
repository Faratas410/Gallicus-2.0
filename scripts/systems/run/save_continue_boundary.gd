class_name SaveContinueBoundary
extends RefCounted

const SaveSystemScript := preload("res://scripts/systems/run/save_system.gd")
const RunStateScript := preload("res://scripts/systems/run/run_state.gd")

const LEVEL3_SCHEMA_VERSION: int = 2

var _save_system: SaveSystem = SaveSystemScript.new()

func build_save_payload(run_state: RunState, runtime_fields: Dictionary) -> Dictionary:
	if run_state == null:
		return {}
	var payload_state: RunState = RunStateScript.new()
	payload_state.reset()
	payload_state.from_dict(run_state.to_dict())
	if runtime_fields.has("scars") and runtime_fields["scars"] is Array:
		payload_state.scars = (runtime_fields["scars"] as Array).duplicate(true)
	if runtime_fields.has("pacts_log") and runtime_fields["pacts_log"] is Array:
		payload_state.pacts_log = (runtime_fields["pacts_log"] as Array).duplicate(true)
	var run_payload: Dictionary = _build_runtime_payload(runtime_fields)
	var scars_detail: Array[Dictionary] = []
	if runtime_fields.has("scars_detail") and runtime_fields["scars_detail"] is Array:
		scars_detail = (runtime_fields["scars_detail"] as Array).duplicate(true)
	return _save_system.build_level3_run_payload(payload_state, run_payload, scars_detail)


func validate_continue_payload(payload: Dictionary) -> Dictionary:
	if not payload.has("run") or not (payload.get("run") is Dictionary):
		return {"ok": false, "reason": "missing_run_payload"}
	var run_payload: Dictionary = payload.get("run", {}) as Dictionary
	if not run_payload.has("level3_schema") or typeof(run_payload.get("level3_schema", null)) != TYPE_INT:
		return {"ok": false, "reason": "missing_level3_schema"}
	if int(run_payload.get("level3_schema", 0)) != LEVEL3_SCHEMA_VERSION:
		return {"ok": false, "reason": "unsupported_level3_schema"}
	for key: String in SaveSystemScript.LEVEL3_FORBIDDEN_RUN_KEYS:
		if run_payload.has(key):
			return {"ok": false, "reason": "legacy_run_key:%s" % key}
	return _save_system.validate_level3_payload(payload)



func apply_payload_to_state(run_state: RunState, payload: Dictionary) -> Dictionary:
	if run_state == null:
		return {"ok": false, "reason": "missing_run_state_instance", "applied_runtime": {}}
	var validation: Dictionary = validate_continue_payload(payload)
	if not bool(validation.get("ok", false)):
		return {"ok": false, "reason": str(validation.get("reason", "invalid_continue_payload")), "applied_runtime": {}}
	var apply_result: Dictionary = _save_system.apply_level3_payload(run_state, payload)
	if not bool(apply_result.get("ok", false)):
		return {"ok": false, "reason": str(apply_result.get("reason", "invalid_continue_payload")), "applied_runtime": {}}
	var run_data: Dictionary = apply_result.get("run", {}) as Dictionary
	var applied_runtime: Dictionary = {
		"arena_index": int(run_data.get("arena_index", run_state.arena_index)),
		"corruption": int(run_data.get("corruption", 0)),
		"upgrades": {},
	}
	if run_data.has("upgrades") and run_data["upgrades"] is Dictionary:
		applied_runtime["upgrades"] = (run_data["upgrades"] as Dictionary).duplicate(true)
	return {
		"ok": true,
		"reason": "",
		"run_state": (apply_result.get("run_state", {}) as Dictionary).duplicate(true),
		"scars_detail": (apply_result.get("scars_detail", []) as Array).duplicate(true),
		"applied_runtime": applied_runtime,
	}

func _build_runtime_payload(runtime_fields: Dictionary) -> Dictionary:
	var upgrades: Dictionary = {}
	if runtime_fields.has("upgrades") and runtime_fields["upgrades"] is Dictionary:
		upgrades = (runtime_fields["upgrades"] as Dictionary).duplicate(true)
	return {
		"level3_schema": LEVEL3_SCHEMA_VERSION,
		"arena_index": int(runtime_fields.get("arena_index", 0)),
		"corruption": int(runtime_fields.get("corruption", 0)),
		"upgrades": upgrades,
	}
