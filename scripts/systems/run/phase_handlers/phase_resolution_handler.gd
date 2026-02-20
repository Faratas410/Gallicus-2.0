extends RunPhaseHandlerBase
class_name PhaseResolutionHandler

func build_resolution_copy(_run_state: RunState) -> Dictionary:
	return {
		"title": "RISOLUZIONE",
		"body": "L'arena decide il prezzo del patto.",
	}

func build_ui_payload(_run_state: RunState, _inputs: Dictionary = {}) -> Dictionary:
	return build_resolution_copy(_run_state)

func build_view(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return build_ui_payload(run_state, inputs)

func can_accept_request(request_name: String) -> bool:
	return request_name == "request_resolution_advance"

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if not can_accept_request(request_name):
		return res
	res.handled = true
	res.action = "RESOLUTION_ADVANCE"
	res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "RESOLUTION_ADVANCE"})
	return res
