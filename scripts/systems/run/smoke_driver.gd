class_name SmokeDriver
extends RefCounted

const RunPhaseContractScript = preload("res://scripts/contracts/run_phase_contract.gd")
const SCENARIO_BET_PRESENT: String = "BET_PRESENT"
const SCENARIO_FULL_RUN: String = "FULL_RUN"
var _phase_name_main_menu: String = RunPhaseContract.get_name(RunPhaseContractScript.MAIN_MENU)
var _phase_name_run_init: String = RunPhaseContract.get_name(RunPhaseContractScript.RUN_INIT)
var _phase_name_bet_present: String = RunPhaseContract.get_name(RunPhaseContractScript.BET_PRESENT)

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


func get_scenario() -> String:
	return OS.get_environment("GALLICUS_SMOKE_SCENARIO")


func should_start_driver_scenario() -> bool:
	if not is_smoke_mode():
		return false
	var scenario: String = get_scenario()
	return scenario == SCENARIO_BET_PRESENT or scenario == SCENARIO_FULL_RUN


func begin_scenario() -> PackedStringArray:
	_new_run_requested = false
	_step_logged_run_init = false
	_gate_quit_requested = false
	if get_scenario() == SCENARIO_FULL_RUN:
		return PackedStringArray(["SMOKE:STEP=SCENARIO_FULL_RUN_START"])
	return PackedStringArray(["SMOKE:STEP=SCENARIO_BET_PRESENT_START"])


func on_tick(phase_name: String, _selected_bet_id: String, _completed_bets: int, _register_final: bool) -> Dictionary:
	var result: Dictionary = {
		"logs": PackedStringArray(),
		"request_new_run": false,
		"request_quit_gate": false,
		"request_place_bet": false,
		"place_bet_id": "",
		"request_mid_choice_select": false,
		"mid_choice_index": 0,
		"request_pyl_double": false,
		"request_pyl_cashout": false,
		"stop_driver": false,
	}
	if not should_start_driver_scenario():
		result["stop_driver"] = true
		return result
	return _on_bet_present_tick(result, phase_name)


func _on_bet_present_tick(result: Dictionary, phase_name: String) -> Dictionary:
	if phase_name == _phase_name_bet_present:
		_append_log(result, "SMOKE:STEP=BET_PRESENT_REACHED")
		if not _gate_quit_requested:
			_gate_quit_requested = true
			_append_log(result, "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
			result["request_quit_gate"] = true
		result["stop_driver"] = true
		return result
	if phase_name == _phase_name_run_init and not _step_logged_run_init:
		_step_logged_run_init = true
		_append_log(result, "SMOKE:STEP=RUN_INIT_SEEN")
	if phase_name == _phase_name_main_menu and not _new_run_requested:
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
