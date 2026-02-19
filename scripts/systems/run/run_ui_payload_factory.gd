extends RefCounted
class_name RunUiPayloadFactory

# Nessuna emissione eventi
# Nessun accesso scene tree
# Nessuna mutazione RunState
# Solo costruzione Dictionary UI


func build_intro_payload(run_state: RunState, coins: int) -> Dictionary:
	var payload: Dictionary = {}
	payload["arena_index"] = run_state.arena_index
	payload["coins"] = coins
	payload["corruption"] = run_state.corruption
	payload["glory"] = run_state.glory
	return payload


func build_intermediate_choice_payload(run_state: RunState, choice_0_text: String, choice_1_text: String) -> Dictionary:
	return {
		"title": "SCELTA",
		"choice_0_text": choice_0_text,
		"choice_1_text": choice_1_text,
		"arena_index": run_state.arena_index,
	}


func build_push_luck_payload(run_state: RunState, cashout_text: String, double_text: String, condanna_text: String) -> Dictionary:
	return {
		"title": "PUSH YOUR LUCK",
		"cashout_text": cashout_text,
		"double_text": double_text,
		"condanna_text": condanna_text,
		"glory": run_state.glory,
		"corruption": run_state.corruption,
	}


func build_resolution_payload(title: String, body: String) -> Dictionary:
	return {
		"title": title,
		"body": body,
	}


func build_end_run_payload(title: String, subtitle: String, body: String, pacts_text: String, condanne_text: String, crowd_text: String) -> Dictionary:
	return {
		"title": title,
		"subtitle": subtitle,
		"body": body,
		"pacts_text": pacts_text,
		"condanne_text": condanne_text,
		"crowd_text": crowd_text,
	}


func build_resolve_ritual_payload(bet_id: StringName, bet_name: String, doom_short: String) -> Dictionary:
	return {
		"bet_id": String(bet_id),
		"bet_name": bet_name,
		"doom_short": doom_short,
	}


func build_arena_theme_payload(theme_id: StringName, title: String, subtitle: String, bg_path: String, overlay_path: String) -> Dictionary:
	return {
		"theme_id": theme_id,
		"title": title,
		"subtitle": subtitle,
		"bg_path": bg_path,
		"overlay_path": overlay_path,
	}


func build_special_arena_payload(special_id: StringName, title: String, description: String, arena_index: int) -> Dictionary:
	return {
		"id": String(special_id),
		"title": title,
		"description": description,
		"arena_index": arena_index,
	}


func build_sentence_payload(sentence_title: String, sentence_rule: String, sentence_doom: String, bet_id: StringName) -> Dictionary:
	return {
		"sentence_title": sentence_title,
		"sentence_rule": sentence_rule,
		"sentence_doom": sentence_doom,
		"bet_id": String(bet_id),
	}
