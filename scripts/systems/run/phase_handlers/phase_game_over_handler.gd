extends RunPhaseHandlerBase
class_name PhaseGameOverHandler

func build_view(
	run_state: RunState,
	pacts_text: String,
	condanne_text: String,
	crowd_text: String,
	inputs: Dictionary = {}
) -> Dictionary:
	return {
		"title": str(inputs.get("title", "")),
		"subtitle": str(inputs.get("subtitle", "")),
		"body": str(inputs.get("body", "")),
		"hint": str(inputs.get("hint", "")),
		"footer": str(inputs.get("footer", "")),
		"pacts_text": pacts_text,
		"condanne_text": condanne_text,
		"crowd_text": crowd_text,
		"glory": run_state.glory,
		"corruption": run_state.corruption,
	}

func build_finale_copy(
	run_state: RunState,
	pacts_text: String,
	condanne_text: String,
	crowd_text: String,
	inputs: Dictionary = {}
) -> Dictionary:
	return {
		"title": str(inputs.get("title", "")),
		"subtitle": str(inputs.get("subtitle", "")),
		"body": str(inputs.get("body", "")),
		"hint": str(inputs.get("hint", "")),
		"footer": str(inputs.get("footer", "")),
		"pacts_text": pacts_text,
		"condanne_text": condanne_text,
		"crowd_text": crowd_text,
		"glory": run_state.glory,
		"corruption": run_state.corruption,
	}

func build_ui_payload(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return {
		"ending_id": str(inputs.get("ending_id", "")),
		"run_end_reason": run_state.run_end_reason,
		"run_is_over": run_state.run_is_over,
		"bets_history_count": run_state.bets_history.size(),
		"refuse_cashout_count_this_run": run_state.refuse_cashout_count_this_run,
		"scars_history_count": run_state.scars_history.size(),
		"max_escalation": run_state.max_escalation,
		"is_anomalous": bool(inputs.get("is_anomalous", false)),
		"register_flow_phase": str(inputs.get("register_flow_phase", "")),
		"anomaly_flow_tag": str(inputs.get("anomaly_flow_tag", "")),
		"run_completed": bool(inputs.get("run_completed", false)),
		"scars": (inputs.get("scars", []) as Array).duplicate(true),
		"seed": run_state.run_seed,
		"stats": (inputs.get("stats", {}) as Dictionary).duplicate(true),
		"pacts_signed": (inputs.get("pacts_signed", []) as Array).duplicate(true),
		"condanne_this_run": run_state.condanne_this_run.duplicate(),
		"last_crowd_line": run_state.last_audience_context_line,
		"glory": run_state.glory,
		"corruption": run_state.corruption,
	}

func can_accept_request(request_name: String) -> bool:
	return request_name == "request_end_run_quit" or request_name == "request_end_run_restart"

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if not can_accept_request(request_name):
		return res
	res.handled = true
	if request_name == "request_end_run_quit":
		res.action = "GAMEOVER_SHOW_MENU"
		res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "GAMEOVER_SHOW_MENU"})
		return res
	res.action = "GAMEOVER_RESTART"
	res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "GAMEOVER_RESTART"})
	return res
