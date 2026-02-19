extends RefCounted
class_name RunPhaseHandlerBase

# Contract:
# - no GameEvents
# - no get_tree
# - no phase mutation
# - build UI payload only (Dictionary keys must stay identical)

func build_ui_payload(_run_state: RunState, _inputs: Dictionary = {}) -> Dictionary:
	return {}

func handle_request(_request_name: String, _run_state: RunState, _request_payload: Dictionary) -> PhaseResult:
	return PhaseResult.new()
