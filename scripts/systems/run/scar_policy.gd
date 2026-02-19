class_name ScarPolicy
extends RefCounted

const SCAR_OPEN_WOUND_ID: String = "OPEN_WOUND"
const SCAR_CRACKED_BONES_ID: String = "CRACKED_BONES"
const SCAR_EVENT_IRREVERSIBLE_PACT_ID: String = "EVENT_IRREVERSIBLE_PACT"
const SCAR_EVENT_REFUSED_CLOSURE_ID: String = "EVENT_REFUSED_CLOSURE"
const SCAR_EVENT_RISK_THRESHOLD_ID: String = "EVENT_RISK_THRESHOLD"

func should_try_scar(scar_id: String, inputs: Dictionary) -> bool:
	var existing_scar_ids: Array = inputs.get("existing_scar_ids", []) as Array
	if scar_id == SCAR_OPEN_WOUND_ID:
		return not _has_id(existing_scar_ids, SCAR_OPEN_WOUND_ID)
	if scar_id == SCAR_CRACKED_BONES_ID:
		var chain_level: int = int(inputs.get("chain_level", 0))
		if chain_level < 2:
			return false
		return not _has_id(existing_scar_ids, SCAR_CRACKED_BONES_ID)
	if scar_id == SCAR_EVENT_IRREVERSIBLE_PACT_ID:
		if bool(inputs.get("already_registered", false)):
			return false
		if not bool(inputs.get("is_irreversible_bet", false)):
			return false
		return _passes_arena_interval(inputs)
	if scar_id == SCAR_EVENT_REFUSED_CLOSURE_ID:
		if bool(inputs.get("already_registered", false)):
			return false
		var refuse_count: int = int(inputs.get("refuse_cashout_count_this_run", 0))
		var threshold: int = int(inputs.get("refuse_cashout_threshold", 0))
		if refuse_count < threshold:
			return false
		return _passes_arena_interval(inputs)
	if scar_id == SCAR_EVENT_RISK_THRESHOLD_ID:
		if bool(inputs.get("already_registered", false)):
			return false
		var escalation_level: int = int(inputs.get("escalation_level", 0))
		var threshold: int = int(inputs.get("risk_escalation_threshold", 0))
		if escalation_level < threshold:
			return false
		return _passes_arena_interval(inputs)
	return false

func pick_scar_to_try(context: Dictionary, candidates: Array[String]) -> String:
	for candidate: String in candidates:
		if should_try_scar(candidate, context):
			return candidate
	return ""

func build_scar_candidates(context: Dictionary) -> Array[String]:
	var candidates: Array[String] = []
	var include_open_wound: bool = bool(context.get("include_open_wound", false))
	var include_cracked_bones: bool = bool(context.get("include_cracked_bones", false))
	if include_open_wound:
		candidates.append(SCAR_OPEN_WOUND_ID)
	if include_cracked_bones:
		candidates.append(SCAR_CRACKED_BONES_ID)
	return candidates

func _passes_arena_interval(inputs: Dictionary) -> bool:
	var arena_index: int = int(inputs.get("arena_index", 0))
	var last_scar_arena_index: int = int(inputs.get("last_scar_arena_index", 0))
	var min_interval: int = int(inputs.get("min_arena_interval", 0))
	return (arena_index - last_scar_arena_index) >= min_interval

func _has_id(existing_scar_ids: Array, scar_id: String) -> bool:
	for value in existing_scar_ids:
		if str(value) == scar_id:
			return true
	return false
