extends RunPhaseHandlerBase
class_name PhaseBetPresentHandler

func build_ui_payload(run_state: RunState) -> Dictionary:
	return {
		"arena_index": run_state.arena_index,
		"coins": run_state.coins,
		"corruption": run_state.corruption,
		"glory": run_state.glory,
	}

func handle_request(request_name: String, _run_state: RunState, request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if request_name != "request_place_bet":
		return res
	res.handled = true
	res.action = "PLACE_BET"
	res.ui_payload = request_payload.duplicate(true)
	return res
