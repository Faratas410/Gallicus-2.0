extends RefCounted
class_name RunFlowMutationRegistry

var _handlers: Dictionary = {}

func register_handler(mutation_name: String, handler: Callable) -> void:
	_handlers[mutation_name] = handler

func apply(step: Dictionary) -> void:
	var name: String = String(step.get("name", ""))
	var handler: Callable = _handlers.get(name, Callable()) as Callable
	if handler.is_valid():
		handler.call(step)
		return
	push_error("Unknown state mutation: %s" % name)
