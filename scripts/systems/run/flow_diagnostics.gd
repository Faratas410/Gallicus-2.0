extends RefCounted
class_name FlowDiagnostics


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

