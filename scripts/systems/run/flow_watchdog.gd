extends RefCounted
class_name FlowWatchdog


func build_snapshot(
	note: String,
	phase: String,
	last_request: String,
	last_phase_change_ms: int,
	last_ui_render_ms: int,
	last_activity_ms: int,
	flow_tail: String
) -> String:
	var lines: Array[String] = []
	lines.push_back("note=%s" % note)
	lines.push_back("phase=%s" % phase)
	lines.push_back("last_request=%s" % last_request)
	lines.push_back("last_phase_change_ms=%d" % last_phase_change_ms)
	lines.push_back("last_ui_render_ms=%d" % last_ui_render_ms)
	lines.push_back("last_activity_ms=%d" % last_activity_ms)
	lines.push_back("last_flow:\n%s" % flow_tail)
	return "\n".join(lines)


func watchdog_stall_hint(
	now_ms: int,
	last_phase_change_ms: int,
	last_ui_render_ms: int,
	last_activity_ms: int,
	last_request: String,
	stall_threshold_ms: int
) -> String:
	var phase_age_ms: int = now_ms - last_phase_change_ms
	var ui_age_ms: int = now_ms - last_ui_render_ms
	var activity_age_ms: int = now_ms - last_activity_ms
	if phase_age_ms > stall_threshold_ms and ui_age_ms > stall_threshold_ms:
		if last_request == "":
			return "request not received"
		return "phase handler missing"
	if phase_age_ms <= stall_threshold_ms and ui_age_ms > stall_threshold_ms:
		return "UI render missing"
	if phase_age_ms > stall_threshold_ms and ui_age_ms <= stall_threshold_ms:
		return "likely waiting for input"
	if activity_age_ms > stall_threshold_ms:
		return "request not received"
	return "unknown"


func should_report_stall(now_ms: int, last_activity_ms: int, stall_threshold_ms: int) -> bool:
	return now_ms - last_activity_ms > stall_threshold_ms
