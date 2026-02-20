extends RunPhaseHandlerBase
class_name PhaseIntermediateChoiceHandler

func build_choice_copy(_run_state: RunState) -> Dictionary:
	return {
		"title": "SCEGLI IL GESTO",
		"choices": ["placa", "provoca"],
	}

func build_ui_payload(_run_state: RunState, _inputs: Dictionary = {}) -> Dictionary:
	var payload: Dictionary = build_choice_copy(_run_state)
	payload["show_mid_choice"] = true
	return payload

func build_view(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return build_ui_payload(run_state, inputs)

func can_accept_request(request_name: String) -> bool:
	match request_name:
		"request_mid_choice_select":
			return true
		_:
			return false

func handle_request(request_name: String, _run_state: RunState, request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if not can_accept_request(request_name):
		return res
	res.handled = true
	res.action = "MID_CHOICE_SELECT"
	var index_value: Variant = request_payload.get("index", null)
	if index_value == null:
		res.handled = false
		res.reason = "Missing index"
		return res
	res.ui_payload = request_payload.duplicate(true)
	res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "INTM_SELECT", "index": int(index_value)})
	return res
