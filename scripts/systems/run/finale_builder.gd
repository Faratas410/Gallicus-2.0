extends RefCounted
class_name FinaleBuilder

const EndingRulesScript = preload("res://data/ending_rules.gd")


func build_finale_payload(inputs: Dictionary) -> Dictionary:
	var ending_id: StringName = StringName(str(inputs.get("ending_id", "")))
	var run_end_reason: String = str(inputs.get("run_end_reason", ""))
	var run_is_over: bool = bool(inputs.get("run_is_over", false))
	var bets_history_count: int = int(inputs.get("bets_history_count", 0))
	var refuse_cashout_count_this_run: int = int(inputs.get("refuse_cashout_count_this_run", 0))
	var scars_history_count: int = int(inputs.get("scars_history_count", 0))
	var max_escalation: int = int(inputs.get("max_escalation", 0))
	var is_anomalous: bool = bool(inputs.get("is_anomalous", false))
	var register_flow_phase: String = str(inputs.get("register_flow_phase", ""))
	var anomaly_flow_tag: String = str(inputs.get("anomaly_flow_tag", ""))
	var run_completed: bool = bool(inputs.get("run_completed", false))
	var title: String = _get_title(ending_id)
	var final_report: Dictionary = _build_final_report(ending_id, run_end_reason, run_is_over, bets_history_count, refuse_cashout_count_this_run, scars_history_count, max_escalation, is_anomalous, register_flow_phase, anomaly_flow_tag)
	var text: String = _final_report_text(final_report)
	var outcome: StringName = &"LOSS"
	if run_end_reason == "CASH_OUT":
		outcome = &"CASHOUT"
	elif run_completed:
		outcome = &"WIN"
	return {
		"title": title,
		"text": text,
		"final_report": final_report,
		"scars": (inputs.get("scars", []) as Array).duplicate(true),
		"ending_id": String(ending_id),
		"seed": int(inputs.get("seed", 0)),
		"stats": (inputs.get("stats", {}) as Dictionary).duplicate(true),
		"pacts_signed": (inputs.get("pacts_signed", []) as Array).duplicate(true),
		"condanne_this_run": (inputs.get("condanne_this_run", []) as Array).duplicate(true),
		"last_crowd_line": str(inputs.get("last_crowd_line", "")),
		"outcome": outcome,
		"classified_terminal": ending_id != &"",
		"glory": int(inputs.get("glory", 0)),
		"corruption": int(inputs.get("corruption", 0)),
	}


func select_level3_ending_key(run_state: RunState, trace: Dictionary) -> Dictionary:
	var enriched_trace: Dictionary = trace.duplicate(true)
	enriched_trace["corruption"] = run_state.corruption
	enriched_trace["glory"] = run_state.glory
	enriched_trace["corruption_tier"] = _compute_corruption_tier(run_state.corruption)
	enriched_trace["glory_tier"] = _compute_glory_tier(run_state.glory)
	var dominant_match: Dictionary = _pick_best_rule(EndingRulesScript.dominant_rules(), enriched_trace)
	if not dominant_match.is_empty():
		return dominant_match
	var morale_match: Dictionary = _pick_best_rule(EndingRulesScript.morale_fallback_rules(), enriched_trace)
	if not morale_match.is_empty():
		return morale_match
	return {}


func _pick_best_rule(rules: Array[Dictionary], trace: Dictionary) -> Dictionary:
	var best_priority: int = -999999
	var best_index: int = 2147483647
	var best_rule: Dictionary = {}
	for idx: int in range(rules.size()):
		var rule: Dictionary = rules[idx] as Dictionary
		if _rule_matches(rule, trace):
			var priority: int = int(rule.get("priority", 0))
			var better_priority: bool = priority > best_priority
			var same_priority_earlier: bool = priority == best_priority and idx < best_index
			if better_priority or same_priority_earlier:
				best_priority = priority
				best_index = idx
				best_rule = rule
	return best_rule


func _rule_matches(rule: Dictionary, trace: Dictionary) -> bool:
	var requires: Dictionary = rule.get("requires", {}) as Dictionary
	if requires.has("min_double") and int(trace.get("double_count", 0)) < int(requires.get("min_double", 0)):
		return false
	if requires.has("max_double") and int(trace.get("double_count", 0)) > int(requires.get("max_double", 999999)):
		return false
	if requires.has("min_cashout") and int(trace.get("cashout_count", 0)) < int(requires.get("min_cashout", 0)):
		return false
	if requires.has("max_cashout") and int(trace.get("cashout_count", 0)) > int(requires.get("max_cashout", 999999)):
		return false
	var condanna_count: int = int(trace.get("condanna_registry_count", trace.get("condanna_count", 0)))
	if requires.has("min_condanna") and condanna_count < int(requires.get("min_condanna", 0)):
		return false
	if requires.has("max_condanna") and condanna_count > int(requires.get("max_condanna", 999999)):
		return false
	if requires.has("min_glory") and int(trace.get("glory", 0)) < int(requires.get("min_glory", 0)):
		return false
	if requires.has("min_corruption") and int(trace.get("corruption", 0)) < int(requires.get("min_corruption", 0)):
		return false
	if requires.has("max_corruption") and int(trace.get("corruption", 0)) > int(requires.get("max_corruption", 999999)):
		return false
	if requires.has("min_path_debt") and int(trace.get("path_debt_count", 0)) < int(requires.get("min_path_debt", 0)):
		return false
	if requires.has("min_path_hubris") and int(trace.get("path_hubris_count", 0)) < int(requires.get("min_path_hubris", 0)):
		return false
	if bool(requires.get("requires_provoke_armed", false)) and not bool(trace.get("provoke_armed", false)):
		return false
	if requires.has("corruption_tier") and str(trace.get("corruption_tier", "")) != str(requires.get("corruption_tier", "")):
		return false
	if requires.has("glory_tier") and str(trace.get("glory_tier", "")) != str(requires.get("glory_tier", "")):
		return false
	return true


func _compute_corruption_tier(corruption_value: int) -> String:
	if corruption_value >= int(EndingRulesScript.CORRUPTION_THRESHOLDS.get("CORRUPT", 8)):
		if corruption_value >= int(EndingRulesScript.CORRUPTION_THRESHOLDS.get("CORRUPT", 8)) + 2:
			return "DAMNED"
		return "CORRUPT"
	if corruption_value >= int(EndingRulesScript.CORRUPTION_THRESHOLDS.get("TAINTED", 5)):
		return "TAINTED"
	return "PURE"


func _compute_glory_tier(glory_value: int) -> String:
	if glory_value >= int(EndingRulesScript.GLORY_THRESHOLDS.get("HIGH", 8)):
		if glory_value >= int(EndingRulesScript.GLORY_THRESHOLDS.get("HIGH", 8)) + 2:
			return "EXCESS"
		return "HIGH"
	if glory_value >= int(EndingRulesScript.GLORY_THRESHOLDS.get("MID", 5)):
		return "MID"
	return "LOW"


func _get_title(ending_id: StringName) -> String:
	match ending_id:
		&"THE_FOOL":
			return "LO STOLTO"
		&"THE_MARKED":
			return "IL SEGNATO"
		&"THE_BROKEN":
			return "IL SPEZZATO"
		&"THE_SURVIVOR":
			return "IL SOPRAVVISSUTO"
		&"THE_DEBTOR":
			return "IL DEBITORE"
		&"THE_CROWD_PET":
			return "IL BENEAMATO"
		&"THE_MARTYR":
			return "IL MARTIRE"
		&"THE_LIBERTY":
			return "LIBERTÀ"
		&"THE_FALL":
			return "CADUTA"
		_:
			return "IL SOPRAVVISSUTO"


func _build_final_report(
	ending_id: StringName,
	run_end_reason: String,
	run_is_over: bool,
	bets_history_count: int,
	refuse_cashout_count_this_run: int,
	scars_history_count: int,
	max_escalation: int,
	is_anomalous: bool,
	register_flow_phase: String,
	anomaly_flow_tag: String
) -> Dictionary:
	var report: Dictionary = {
		"opening": "",
		"patterns": [],
		"fracture": "",
		"final_state": "",
		"is_anomalous": is_anomalous,
		"register_flow_phase": register_flow_phase,
	}
	if run_end_reason == "CASH_OUT":
		report["opening"] = "Il soggetto ha interrotto il ciclo prima della definizione."
	elif run_is_over:
		report["opening"] = "Il soggetto ha completato il ciclo operativo."
	else:
		report["opening"] = "Il soggetto presenta un profilo registrabile."

	var patterns: Array[String] = []
	if bets_history_count > 0:
		patterns.append("accettazione ricorrente di condizioni irreversibili")
	if refuse_cashout_count_this_run > 0:
		patterns.append("rifiuto della chiusura quando disponibile")
	if scars_history_count > 0:
		patterns.append("accumulo di Scar persistenti su più passaggi")
	if max_escalation >= 3:
		patterns.append("reiterazione oltre l'utile con esposizione crescente")
	if patterns.size() < 2:
		patterns.append("sacrificio di opzioni future registrato")
	report["patterns"] = patterns

	if is_anomalous:
		match anomaly_flow_tag:
			"ATTRITO":
				report["fracture"] = "Il profilo osservato eccede le soglie operative previste; classificazione mantenuta coerente."
				report["final_state"] = _get_final_state_label(ending_id)
			"DERIVA":
				report["fracture"] = "Il profilo osservato non rientra pienamente nelle classi disponibili. Classificazione coerente, ma non conclusiva."
				report["final_state"] = "classificazione non conclusiva"
			"MEMORIA":
				report["fracture"] = "Precedente rilevato in memoria storica. Applicabilità non determinabile; classificazione incompleta."
				report["final_state"] = "classificazione incompleta"
			"SOSPENSIONE":
				report["fracture"] = "Stato registrato con parametri attivi. Chiusura finale non applicabile."
				report["final_state"] = "registrato in sospensione"
			_:
				report["final_state"] = _get_final_state_label(ending_id)
	else:
		report["final_state"] = _get_final_state_label(ending_id)
	return report


func _get_final_state_label(ending_id: StringName) -> String:
	match ending_id:
		&"THE_FOOL":
			return "interruzione immediata"
		&"THE_MARKED":
			return "segnato"
		&"THE_BROKEN":
			return "compromesso"
		&"THE_DEBTOR":
			return "in debito attivo"
		&"THE_CROWD_PET":
			return "conforme al pubblico"
		&"THE_MARTYR":
			return "consumo completo"
		&"THE_LIBERTY":
			return "libertà registrata"
		&"THE_FALL":
			return "caduta amministrativa"
		_:
			return "non definito"


func _final_report_text(final_report: Dictionary) -> String:
	var opening: String = str(final_report.get("opening", ""))
	var fracture: String = str(final_report.get("fracture", ""))
	var final_state: String = str(final_report.get("final_state", ""))
	var patterns_src: Array = final_report.get("patterns", []) as Array
	var patterns: Array[String] = []
	for value in patterns_src:
		patterns.append(str(value))
	var sections: Array[String] = []
	sections.append("I. APERTURA — CONSTATAZIONE\n%s" % opening)
	sections.append("II. CORPO — LETTURA DEI PATTERN\n- %s" % "\n- ".join(patterns))
	if fracture != "":
		sections.append("III. FRATTURA\n%s" % fracture)
	sections.append("Stato finale: %s." % final_state)
	return "\n\n".join(sections)
