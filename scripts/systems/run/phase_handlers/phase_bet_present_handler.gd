extends RunPhaseHandlerBase
class_name PhaseBetPresentHandler

func build_ui_payload(run_state: RunState, _inputs: Dictionary = {}) -> Dictionary:
	return {
		"arena_index": run_state.arena_index,
		"corruption": run_state.corruption,
		"glory": run_state.glory,
	}

func build_view(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return build_ui_payload(run_state, inputs)


func can_accept_request(request_name: String) -> bool:
	return request_name == "request_intro_confirm"

func handle_request(request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if can_accept_request(request_name):
		res.handled = true
		res.action = "INTRO_CONFIRM"
		res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "INTRO_CONFIRM"})
	return res
