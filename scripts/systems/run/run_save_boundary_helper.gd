extends RefCounted
class_name RunSaveBoundaryHelper

# Boundary helper puro:
# - Nessun accesso a get_tree()
# - Nessuna emissione GameEvents
# - Nessuna mutazione fase
# - Solo trasformazioni Dictionary <-> RunState-like data


func build_run_payload(run_state: RunState, runtime_run: Dictionary) -> Dictionary:
	var payload: Dictionary = {}

	payload["arena_index"] = int(runtime_run.get("arena_index", run_state.arena_index))
	payload["corruption"] = int(runtime_run.get("corruption", run_state.corruption))
	payload["glory"] = run_state.glory
	payload["upgrades"] = {}
	payload["level3_schema"] = 2

	return payload


func apply_run_payload(run_state: RunState, runtime_run: Dictionary, payload: Dictionary) -> void:
	if payload.has("arena_index"):
		run_state.arena_index = int(payload["arena_index"])
		runtime_run["arena_index"] = run_state.arena_index


	if payload.has("corruption"):
		run_state.corruption = clampi(int(payload["corruption"]), 0, 100)
		runtime_run["corruption"] = run_state.corruption

	if payload.has("glory"):
		run_state.glory = int(payload["glory"])

	# Level 3 contract: upgrades sanitized
	runtime_run["upgrades"] = {}
