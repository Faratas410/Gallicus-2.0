extends RunPhaseHandlerBase
class_name PhaseIntermediateChoiceHandler

func build_ui_payload(_run_state: RunState, _inputs: Dictionary = {}) -> Dictionary:
	return {
		"title": "SCEGLI IL GESTO",
		"choices": ["placa", "provoca"],
		"show_mid_choice": true,
	}

func handle_request(request_name: String, _run_state: RunState, request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if request_name != "request_mid_choice_select":
		return res
	res.handled = true
	res.action = "MID_CHOICE_SELECT"
	res.ui_payload = request_payload.duplicate(true)
	return res
