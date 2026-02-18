class_name SmokeDriver
extends RefCounted

var _new_run_requested: bool = false
var _step_logged_run_init: bool = false
var _gate_quit_requested: bool = false

func is_smoke_mode() -> bool:
	return OS.get_environment("GALLICUS_SMOKE") == "1"


func get_timeout_seconds() -> float:
	var timeout_sec: float = 10.0
	var raw_timeout: String = OS.get_environment("GALLICUS_SMOKE_TIMEOUT_SEC")
	if raw_timeout != "":
		timeout_sec = max(raw_timeout.to_float(), 0.1)
	return timeout_sec


func should_start_bet_present_scenario() -> bool:
	return is_smoke_mode() and OS.get_environment("GALLICUS_SMOKE_SCENARIO") == "BET_PRESENT"


func begin_bet_present_scenario() -> PackedStringArray:
	_new_run_requested = false
	_step_logged_run_init = false
	_gate_quit_requested = false
	return PackedStringArray(["SMOKE:STEP=SCENARIO_BET_PRESENT_START"])


func on_bet_present_tick(is_run_init: bool, is_main_menu: bool, is_bet_present: bool) -> Dictionary:
	var result: Dictionary = {
		"logs": PackedStringArray(),
		"request_new_run": false,
		"request_quit_gate": false,
		"stop_driver": false,
	}
	if not should_start_bet_present_scenario():
		result["stop_driver"] = true
		return result
	if is_bet_present:
		_append_log(result, "SMOKE:STEP=BET_PRESENT_REACHED")
		if not _gate_quit_requested:
			_gate_quit_requested = true
			_append_log(result, "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
			result["request_quit_gate"] = true
		result["stop_driver"] = true
		return result
	if is_run_init and not _step_logged_run_init:
		_step_logged_run_init = true
		_append_log(result, "SMOKE:STEP=RUN_INIT_SEEN")
	if is_main_menu and not _new_run_requested:
		_new_run_requested = true
		_append_log(result, "SMOKE:STEP=REQUEST_NEW_RUN")
		_append_log(result, "SMOKE:NEW_RUN_REQUESTED")
		_append_log(result, "SMOKE:REQ=request_new_run")
		result["request_new_run"] = true
	return result


func _append_log(step_result: Dictionary, line: String) -> void:
	var logs: PackedStringArray = step_result["logs"] as PackedStringArray
	logs.append(line)
	step_result["logs"] = logs
