extends RunPhaseHandlerBase
class_name PhasePushYourLuckHandler

func build_choice_copy(_run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	var bet_name: String = str(inputs.get("bet_name", ""))
	return {
		"title": "PUSH YOUR LUCK — %s" % bet_name,
		"body": "La folla vuole di più. Puoi incassare… o rilanciare.",
		"choices": ["cashout", "condanna", "double"],
	}

func build_ui_payload(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	var payload: Dictionary = build_choice_copy(run_state, inputs)
	payload["show_push_your_luck"] = true
	payload["glory"] = run_state.glory
	payload["corruption"] = run_state.corruption
	return payload

func build_view(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return build_ui_payload(run_state, inputs)


func can_accept_request(request_name: String) -> bool:
	match request_name:
		"request_pyl_cashout":
			return true
		"request_pyl_condanna":
			return true
		"request_pyl_double":
			return true
		_:
			return false

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if not can_accept_request(request_name):
		return res
	res.handled = true
	match request_name:
		"request_pyl_cashout":
			res.action = "PYL_CASHOUT"
			res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "PYL_CASHOUT"})
		"request_pyl_condanna":
			res.action = "PYL_CONDANNA"
			res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "PYL_CONDANNA"})
		"request_pyl_double":
			res.action = "PYL_DOUBLE"
			res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "PYL_DOUBLE"})
		_:
			res.handled = false
	return res

