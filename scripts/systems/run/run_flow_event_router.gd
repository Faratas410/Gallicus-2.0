extends RefCounted
class_name RunFlowEventRouter

var _emitters: Dictionary = {}

func register_emitter(event_name: String, emitter: Callable) -> void:
	_emitters[event_name] = emitter

func emit_by_name(event_name: String, payload: Dictionary) -> void:
	var emitter: Callable = _emitters.get(event_name, Callable()) as Callable
	if emitter.is_valid():
		emitter.call(payload)
		return
	push_error("Unknown event name: %s" % event_name)
