extends RunPhaseHandlerBase
class_name PhasePushYourLuckHandler

func build_ui_payload(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return {
		"show_push_your_luck": true,
		"body": "La folla vuole di più. Puoi incassare… o rilanciare.",
		"choices": ["cashout", "condanna", "double"],
		"glory": run_state.glory,
		"corruption": run_state.corruption,
	}

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if request_name == "request_pyl_cashout":
		res.handled = true
		res.action = "CASHOUT"
		return res
	if request_name == "request_pyl_double":
		res.handled = true
		res.action = "DOUBLE"
		return res
	return res
