extends RunPhaseHandlerBase
class_name PhaseBetPresentHandler

func build_ui_payload(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return {
		"arena_index": run_state.arena_index,
		"coins": int(inputs.get("coins", 0)),
		"corruption": run_state.corruption,
		"glory": run_state.glory,
	}

func build_view(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return build_ui_payload(run_state, inputs)


func can_accept_request(request_name: String) -> bool:
	match request_name:
		"request_place_bet":
			return true
		_:
			return false

func handle_request(request_name: String, _run_state: RunState, request_payload: Dictionary) -> PhaseResult:
	var res: PhaseResult = PhaseResult.new()
	if not can_accept_request(request_name):
		return res
	res.handled = true
	res.action = "PLACE_BET"
	var bet_id: Variant = request_payload.get("bet_id", null)
	if bet_id == null:
		res.handled = false
		res.reason = "Missing bet_id"
		return res
	res.ui_payload = request_payload.duplicate(true)
	res.mutation_plan.append({"type": "APPLY_STATE_MUTATION", "name": "BETP_PLACE_BET", "bet_id": bet_id})
	return res
