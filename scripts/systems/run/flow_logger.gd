class_name FlowLogger
extends RefCounted

func log(tag: String, details: String = "") -> void:
	print_debug("[FLOW] %s :: %s" % [tag, details])
