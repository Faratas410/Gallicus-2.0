class_name FlowLogger
extends RefCounted

enum Level {
	OFF,
	ERROR,
	INFO,
	VERBOSE,
}

const BUFFER_SIZE: int = 200

var level: int = Level.INFO
var include_timestamp: bool = false
var include_context_ids: bool = true
var session_id: String = ""
var run_id: int = 0
var _buffer: Array[String] = []

func _ts() -> String:
	return str(Time.get_unix_time_from_system())

func set_session(id: String) -> void:
	session_id = id

func set_run_id(id: int) -> void:
	run_id = id

func _append(line: String) -> void:
	_buffer.push_back(line)
	if _buffer.size() > BUFFER_SIZE:
		_buffer.pop_front()

func log(tag: String, details: String = "") -> void:
	if level == Level.OFF:
		return
	var log_details: String = details
	if include_context_ids:
		log_details = "sid=%s rid=%d | %s" % [session_id, run_id, details]
	var line: String = "[FLOW] %s :: %s" % [tag, log_details]
	if include_timestamp:
		line = "[FLOW][%s] %s :: %s" % [_ts(), tag, log_details]
	_append(line)
	print_debug(line)

func log_phase(phase_name: String, note: String = "") -> void:
	log("PHASE", "%s :: %s" % [phase_name, note])

func log_request(name: String, note: String = "") -> void:
	log("REQ", "%s :: %s" % [name, note])

func log_ui(action: String, note: String = "") -> void:
	log("UI", "%s :: %s" % [action, note])

func dump_last(n: int = 50) -> String:
	var safe_n: int = maxi(0, n)
	if safe_n == 0 or _buffer.is_empty():
		return ""
	var start: int = maxi(_buffer.size() - safe_n, 0)
	var lines: Array[String] = []
	for index: int in range(start, _buffer.size()):
		lines.push_back(_buffer[index])
	return "\n".join(lines)
