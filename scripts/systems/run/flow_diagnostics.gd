extends RefCounted
class_name FlowDiagnostics


func build_run_debug_payload(
	run_seed: int,
	arena_index: int,
	escalation_level: int,
	active_bet_id: String,
	enemy_profile: String,
	scars: Array[String],
	special_arena_id: String,
	special_arena_active: bool,
	is_hunted_by_crowd: bool,
	glory: int,
	corruption: int,
	scar_double_count: int,
	scar_pact_count: int,
	volatility: int,
	last_resolve_debug: Dictionary = {}
) -> Dictionary:
	return {
		"seed": run_seed,
		"arena_index": arena_index,
		"escalation_level": escalation_level,
		"active_bet_id": active_bet_id,
		"enemy_profile": enemy_profile,
		"scars": scars,
		"special_arena_id": special_arena_id,
		"special_arena_active": special_arena_active,
		"is_hunted_by_crowd": is_hunted_by_crowd,
		"glory": glory,
		"corruption": corruption,
		"scar_double_count": scar_double_count,
		"scar_pact_count": scar_pact_count,
		"volatility": volatility,
		"last_resolve_debug": last_resolve_debug.duplicate(true),
	}


func format_wrong_phase_request_error(
	request_name: String,
	phase_value: String,
	allowed_phases: String,
	last_flow: String,
	snapshot: String
) -> String:
	return "RunManager: %s in wrong phase %s (allowed=%s)\nLAST_FLOW:\n%s\nSNAPSHOT:\n%s" % [request_name, phase_value, allowed_phases, last_flow, snapshot]


func format_missing_enter_phase_error(phase_value: String, last_flow: String) -> String:
	return "RunManager: missing _enter_* for phase %s\nLAST_FLOW:\n%s" % [phase_value, last_flow]


func format_watchdog_stall_error(stall_ms: int, hint: String, snapshot: String) -> String:
	return "WATCHDOG: stalled for %dms | hint=%s | %s" % [stall_ms, hint, snapshot]


func format_phase_debug_line(phase_name: String, reason: String) -> String:
	return "RunManager flow phase: %s - %s" % [phase_name, reason]
