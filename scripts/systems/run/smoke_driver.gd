class_name SmokeDriver
extends RefCounted

const SCENARIO_BET_PRESENT: String = "BET_PRESENT"
const SCENARIO_FULL_RUN: String = "FULL_RUN"
const FULL_RUN_TARGET_BETS: int = 3

var _new_run_requested: bool = false
var _step_logged_run_init: bool = false
var _gate_quit_requested: bool = false
var _full_run_action_phase: String = ""

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
	_full_run_action_phase = ""
	if get_scenario() == SCENARIO_FULL_RUN:
		return PackedStringArray(["SMOKE:STEP=SCENARIO_FULL_RUN_START"])
	return PackedStringArray(["SMOKE:STEP=SCENARIO_BET_PRESENT_START"])


func on_tick(phase_name: String, selected_bet_id: String, completed_bets: int, register_final: bool) -> Dictionary:
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
	if get_scenario() == SCENARIO_FULL_RUN:
		return _on_full_run_tick(result, phase_name, selected_bet_id, completed_bets, register_final)
	return _on_bet_present_tick(result, phase_name)


func _on_bet_present_tick(result: Dictionary, phase_name: String) -> Dictionary:
	if phase_name == "BET_PRESENT":
		_append_log(result, "SMOKE:STEP=BET_PRESENT_REACHED")
		if not _gate_quit_requested:
			_gate_quit_requested = true
			_append_log(result, "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
			result["request_quit_gate"] = true
		result["stop_driver"] = true
		return result
	if phase_name == "RUN_INIT" and not _step_logged_run_init:
		_step_logged_run_init = true
		_append_log(result, "SMOKE:STEP=RUN_INIT_SEEN")
	if phase_name == "MAIN_MENU" and not _new_run_requested:
		_new_run_requested = true
		_append_log(result, "SMOKE:STEP=REQUEST_NEW_RUN")
		_append_log(result, "SMOKE:NEW_RUN_REQUESTED")
		_append_log(result, "SMOKE:REQ=request_new_run")
		result["request_new_run"] = true
	return result


func _on_full_run_tick(result: Dictionary, phase_name: String, selected_bet_id: String, completed_bets: int, register_final: bool) -> Dictionary:
	if phase_name == "MAIN_MENU" and not _new_run_requested:
		_new_run_requested = true
		_append_log(result, "SMOKE:STEP=REQUEST_NEW_RUN")
		_append_log(result, "SMOKE:NEW_RUN_REQUESTED")
		_append_log(result, "SMOKE:REQ=request_new_run")
		result["request_new_run"] = true
		return result
	if phase_name == "RUN_INIT" and not _step_logged_run_init:
		_step_logged_run_init = true
		_append_log(result, "SMOKE:STEP=RUN_INIT_SEEN")
		return result
	if phase_name == "BET_PRESENT" and _full_run_action_phase != "BET_PRESENT":
		if selected_bet_id != "":
			_full_run_action_phase = "BET_PRESENT"
			_append_log(result, "SMOKE:REQ=request_place_bet bet_id=%s" % selected_bet_id)
			result["request_place_bet"] = true
			result["place_bet_id"] = selected_bet_id
		return result
	if phase_name == "INTERMEDIATE_CHOICE" and _full_run_action_phase != "INTERMEDIATE_CHOICE":
		_full_run_action_phase = "INTERMEDIATE_CHOICE"
		_append_log(result, "SMOKE:REQ=request_mid_choice_select index=0")
		result["request_mid_choice_select"] = true
		result["mid_choice_index"] = 0
		return result
	if phase_name == "PUSH_YOUR_LUCK" and _full_run_action_phase != "PUSH_YOUR_LUCK":
		_full_run_action_phase = "PUSH_YOUR_LUCK"
		if completed_bets < FULL_RUN_TARGET_BETS:
			_append_log(result, "SMOKE:REQ=request_pyl_double")
			result["request_pyl_double"] = true
		else:
			_append_log(result, "SMOKE:REQ=request_pyl_cashout")
			result["request_pyl_cashout"] = true
		return result
	if phase_name == "GAME_OVER" and register_final and not _gate_quit_requested:
		_gate_quit_requested = true
		_append_log(result, "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
		result["request_quit_gate"] = true
		result["stop_driver"] = true
	return result


func _append_log(step_result: Dictionary, line: String) -> void:
	var logs: PackedStringArray = step_result["logs"] as PackedStringArray
	logs.append(line)
	step_result["logs"] = logs
