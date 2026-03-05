extends RunPhaseHandlerBase
class_name PhaseRunInitHandler

func build_ui_payload(run_state: RunState, inputs: Dictionary = {}) -> Dictionary:
	return {
		"arena_index": run_state.arena_index,
		"corruption": run_state.corruption,
		"glory": run_state.glory,
	}


func can_accept_request(_request_name: String) -> bool:
	return false
