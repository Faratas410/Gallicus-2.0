extends RefCounted
class_name RequestRouter

const PhaseResultScript = preload("res://scripts/systems/run/phase_handlers/phase_result.gd")

func route_guarded_phase_request(
	request_name: String,
	allowed_phases: Array,
	payload: Dictionary,
	run_state: RefCounted,
	guard_request_phase: Callable,
	handle_request: Callable,
	apply_mutation_plan: Callable
) -> bool:
	if not guard_request_phase.call(request_name, allowed_phases):
		return false
	var result_value: Variant = handle_request.call(request_name, run_state, payload)
	var res: PhaseResultScript = result_value as PhaseResultScript
	if res == null or not res.handled:
		return false
	apply_mutation_plan.call(res)
	return true
