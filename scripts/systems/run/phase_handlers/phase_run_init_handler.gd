extends RunPhaseHandlerBase
class_name PhaseRunInitHandler

func build_ui_payload(run_state: RunState) -> Dictionary:
	return {
		"arena_index": run_state.arena_index,
		"coins": run_state.coins,
		"corruption": run_state.corruption,
		"glory": run_state.glory,
	}
