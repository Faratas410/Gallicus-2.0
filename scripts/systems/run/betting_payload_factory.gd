extends RefCounted
class_name BettingPayloadFactory

# SCHEMA SNAPSHOT (payload stability contract)
# - build_bet_offer_payload() MUST output key: ["offer"]
# - build_pyl_offer_payload() MUST output keys:
#   ["bet_id", "bet_name", "current_level", "next_level", "condition", "next_pact", "next_doom",
#    "cashout_locked", "cashout_lock_reason", "double_locked", "double_lock_reason", "choice_note",
#    "arena_index", "arena_target", "audience_label", "audience_reason", "cashout_modifier", "cashout_modifier_text"]
# - No optional keys in factory output: every key above is always emitted with explicit defaults.

func build_bet_offer_payload(inputs: Dictionary) -> Dictionary:
	var offer: Array[Dictionary] = inputs.get("offer", []) as Array[Dictionary]
	return {
		"offer": offer,
	}

func build_pyl_offer_payload(inputs: Dictionary) -> Dictionary:
	var bet_id: String = str(inputs.get("bet_id", ""))
	var bet_data: Dictionary = inputs.get("bet_data", {}) as Dictionary
	var bet_name: String = bet_id
	var condition_text: String = ""
	if not bet_data.is_empty():
		bet_name = str(bet_data.get("name", bet_id))
		condition_text = str(bet_data.get("condition", ""))
	var current_level: int = int(inputs.get("bet_chain_level", 1))
	var next_level: int = current_level + 1
	if bool(inputs.get("level3_enabled", false)):
		current_level = maxi(int(inputs.get("escalation_level", 0)) + 1, 1)
		next_level = current_level + 1
	var cashout_enabled: bool = bool(inputs.get("cashout_enabled", true))
	var cashout_lock_reason: String = str(inputs.get("cashout_lock_reason", ""))
	var cashout_locked: bool = cashout_lock_reason != ""
	if not cashout_enabled:
		cashout_locked = true
		cashout_lock_reason = str(inputs.get("audience_cashout_lock_reason", cashout_lock_reason))
	var double_lock_reason: String = str(inputs.get("double_lock_reason", ""))
	return {
		"bet_id": bet_id,
		"bet_name": bet_name,
		"current_level": current_level,
		"next_level": next_level,
		"condition": condition_text,
		"next_pact": str(inputs.get("next_pact", "")),
		"next_doom": str(inputs.get("next_doom", "")),
		"cashout_locked": cashout_locked,
		"cashout_lock_reason": cashout_lock_reason,
		"double_locked": double_lock_reason != "",
		"double_lock_reason": double_lock_reason,
		"choice_note": str(inputs.get("choice_note", "")),
		"arena_index": int(inputs.get("arena_index", 0)),
		"arena_target": int(inputs.get("arena_target", 0)),
		"audience_label": str(inputs.get("audience_label", "")),
		"audience_reason": str(inputs.get("audience_reason", "")),
		"cashout_modifier": float(inputs.get("cashout_modifier", 1.0)),
		"cashout_modifier_text": str(inputs.get("cashout_modifier_text", "")),
	}

func build_audience_payload_fragments(inputs: Dictionary) -> Dictionary:
	return {
		"audience_label": str(inputs.get("audience_label", "")),
		"audience_reason": str(inputs.get("audience_reason", "")),
		"cashout_enabled": bool(inputs.get("cashout_enabled", true)),
		"cashout_lock_reason": str(inputs.get("cashout_lock_reason", "")),
		"cashout_modifier": float(inputs.get("cashout_modifier", 1.0)),
		"cashout_modifier_text": str(inputs.get("cashout_modifier_text", "")),
	}
