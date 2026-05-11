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

func log(tag: String, message: String = "") -> void:
	if level == Level.OFF:
		return
	var log_message: String = tag
	if not message.is_empty():
		log_message = "%s :: %s" % [tag, message]
	var log_details: String = log_message
	if include_context_ids:
		log_details = "sid=%s rid=%d | %s" % [session_id, run_id, log_message]
	var line: String = "[FLOW] %s" % log_details
	if include_timestamp:
		line = "[FLOW][%s] %s" % [_ts(), log_details]
	_append(line)

func log_phase(phase_name: String, note: String = "") -> void:
	var message: String = phase_name
	if not note.is_empty():
		message = "%s :: %s" % [phase_name, note]
	self.log("PHASE", message)

func log_request(name: String, note: String = "") -> void:
	var message: String = name
	if not note.is_empty():
		message = "%s :: %s" % [name, note]
	self.log("REQ", message)

func log_ui(action: String, note: String = "") -> void:
	var message: String = action
	if not note.is_empty():
		message = "%s :: %s" % [action, note]
	self.log("UI", message)

func dump_last(n: int = 50) -> String:
	var safe_n: int = maxi(0, n)
	if safe_n == 0 or _buffer.is_empty():
		return ""
	var start: int = maxi(_buffer.size() - safe_n, 0)
	var lines: Array[String] = []
	for index: int in range(start, _buffer.size()):
		lines.push_back(_buffer[index])
	return "\n".join(lines)
