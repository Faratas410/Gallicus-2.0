extends RefCounted
class_name RunRegisterAnnotationPolicy

# Policy helper:
# - NO get_tree / scene traversal
# - NO GameEvents emission
# - NO phase mutation
# - NO RunState mutation
# Restituisce solo stringhe/Dictionary descrittivi già pronti per il RunManager


func build_register_annotation_text(event_key: String, context: Dictionary) -> String:
	match event_key:
		"SCAR_APPLIED":
			return _format_scar_applied(context)
		"RUN_END":
			return _format_run_end(context)
		_:
			return ""


func build_register_metrics_payload(_context: Dictionary) -> Dictionary:
	return {}


func _format_scar_applied(context: Dictionary) -> String:
	var flow_phase: StringName = StringName(str(context.get("flow_phase", "")))
	match flow_phase:
		&"ATTRITO":
			return "Registrato: accettata una perdita che eccede le soglie operative previste."
		&"DERIVA":
			return "Registrato: condizione irreversibile acquisita in profilo coerente, ma non conclusivo."
		&"MEMORIA":
			return "Registrato: condizione irreversibile acquisita con precedenti in memoria operativa."
		&"SOSPENSIONE":
			return "Registrato: condizione irreversibile acquisita; classificazione mantenuta in stato sospeso."
		_:
			return "Registrato: accettata una condizione irreversibile."


func _format_run_end(context: Dictionary) -> String:
	var flow_phase: StringName = StringName(str(context.get("flow_phase", "")))
	var emit_reason: String = str(context.get("emit_reason", "unknown"))
	var scar_count: int = int(context.get("scar_count", 0))
	var felix_precedent_emitted: bool = bool(context.get("felix_precedent_emitted", false))
	match flow_phase:
		&"ATTRITO":
			return "Registrato: chiusura run (%s). Parametri estesi in attrito; tracce attive: %d." % [emit_reason, scar_count]
		&"DERIVA":
			return "Registrato: chiusura run (%s). Profilo coerente, ma non conclusivo." % [emit_reason]
		&"MEMORIA":
			if not felix_precedent_emitted:
				return "Registrato: chiusura run (%s). Precedente rilevato (Felix Gallicus). Applicabilità non determinabile." % [emit_reason]
			return "Registrato: chiusura run (%s). Precedente rilevato; applicabilità non determinabile." % [emit_reason]
		&"SOSPENSIONE":
			return "Registrato: stato run (%s). Chiusura non applicabile." % [emit_reason]
		_:
			return "Registrato: chiusura run (%s). Tracce attive: %d." % [emit_reason, scar_count]
