class_name RunState
extends RefCounted

var run_seed: int = 0
var arena_index: int = 0
var escalation_level: int = 0
var active_bet_id: StringName = &""
var enemy_profile: StringName = &""
var enemy_profiles: Array[StringName] = []
var scars: Array = []
var scars_history: Array[StringName] = []
var bets_history: Array[StringName] = []
var pacts_log: Array = []
var cashouts: int = 0
var doubles: int = 0
var max_escalation: int = 0
var arenas_cleared: int = 0
var audience_score: int = 0
var refuse_cashout_count_this_run: int = 0
var last_action_was_rilancio: bool = false
var run_is_over: bool = false
var is_hunted_by_crowd: bool = false
var last_signed_pact_id: StringName = &""
var risky_choice_made_recently: bool = false
var irreversible_bet_scar_registered: bool = false
var refused_closure_scar_registered: bool = false
var risk_threshold_scar_registered: bool = false
var last_scar_arena_index: int = -1000

var bet_chain_level: int = 1
var current_bet_id: String = ""
var scars_payload: Array[Dictionary] = []
var level3_reward_tier: int = 1
var level3_next_loss_hp_penalty: int = 0
var level3_target_arenas: int = 0
var level3_min_cashout_arenas: int = 5
var cashout_lock_remaining: int = 0
var last_selected_bet_id: StringName = &""
var last_bet_offers: Array[StringName] = []
var last_enemy_profile: StringName = &""
var level3_current_offer: Array[Dictionary] = []
var special_arena_index: int = 0
var special_arena_id: StringName = &""
var special_arena_active: bool = false
var special_arena_effect_applied: bool = false
var arena_theme_id: StringName = &"ARENA_WAX_SEAL"
var level3_cashouts: int = 0
var level3_doubles: int = 0
var level3_bets_used: Array[StringName] = []
var level3_max_escalation: int = 0
var level3_cashout_streak: int = 0
var level3_cashout_streak_max: int = 0
var level3_cashed_after_high_escalation: bool = false
var scar_heal_multiplier: float = 1.0
var scar_dodge_cooldown_multiplier: float = 1.0
var scar_dodge_speed_multiplier: float = 1.0
var push_luck_cashouts: int = 0
var push_luck_doubles: int = 0
var max_push_luck_chain: int = 1
var post_bet_pending_bet_id: StringName = &""
var post_bet_sequence_id: int = 0
var intermediate_pending_bet_id: StringName = &""
var intermediate_double_disabled_once: bool = false
var intermediate_bonus_tier: int = 0
var intermediate_choice_note: String = ""
var intermediate_loss_penalty_pending: bool = false
var provoke_armed: bool = false
var failed_high_risk_bets: int = 0
var run_end_reason: String = ""
var run_end_public_reason: String = ""
var run_finale_emitted: bool = false
var registry_silence_evaluated: bool = false
var registry_silence_active: bool = false
var condanne_this_run: Array[StringName] = []
var last_audience_context_line: String = ""
var forced_ending_id: StringName = &""
var forced_next_pact_archetype: StringName = &""
var special_arena_cashout_lock_reason: String = ""
var seen_by_crowd_before_run: bool = false
var debug_seed_override_active: bool = false
var debug_seed_override: int = 0
var run_start_time_msec: int = 0
var run_save_flow_step: StringName = &""
var run_save_flow_bet_id: StringName = &""
var glory: int = 0
var corruption: int = 0
var scar_double_count: int = 0
var scar_pact_count: int = 0
var volatility: int = 0
var scar_rng_state: int = 0
var scar_roll_index: int = 0
var last_pact_corruption_arena_index: int = -1
var last_pact_corruption_bet_id: StringName = &""

func reset() -> void:
	run_seed = 0
	arena_index = 0
	escalation_level = 0
	active_bet_id = &""
	enemy_profile = &""
	enemy_profiles = []
	scars = []
	scars_history = []
	bets_history = []
	pacts_log = []
	cashouts = 0
	doubles = 0
	max_escalation = 0
	arenas_cleared = 0
	audience_score = 0
	refuse_cashout_count_this_run = 0
	last_action_was_rilancio = false
	run_is_over = false
	is_hunted_by_crowd = false
	last_signed_pact_id = &""
	risky_choice_made_recently = false
	irreversible_bet_scar_registered = false
	refused_closure_scar_registered = false
	risk_threshold_scar_registered = false
	last_scar_arena_index = -1000

	bet_chain_level = 1
	current_bet_id = ""
	scars_payload = []
	level3_reward_tier = 1
	level3_next_loss_hp_penalty = 0
	level3_target_arenas = 0
	level3_min_cashout_arenas = 5
	cashout_lock_remaining = 0
	last_selected_bet_id = &""
	last_bet_offers = []
	last_enemy_profile = &""
	level3_current_offer = []
	special_arena_index = 0
	special_arena_id = &""
	special_arena_active = false
	special_arena_effect_applied = false
	arena_theme_id = &"ARENA_WAX_SEAL"
	level3_cashouts = 0
	level3_doubles = 0
	level3_bets_used = []
	level3_max_escalation = 0
	level3_cashout_streak = 0
	level3_cashout_streak_max = 0
	level3_cashed_after_high_escalation = false
	scar_heal_multiplier = 1.0
	scar_dodge_cooldown_multiplier = 1.0
	scar_dodge_speed_multiplier = 1.0
	push_luck_cashouts = 0
	push_luck_doubles = 0
	max_push_luck_chain = 1
	post_bet_pending_bet_id = &""
	post_bet_sequence_id = 0
	intermediate_pending_bet_id = &""
	intermediate_double_disabled_once = false
	intermediate_bonus_tier = 0
	intermediate_choice_note = ""
	intermediate_loss_penalty_pending = false
	provoke_armed = false
	failed_high_risk_bets = 0
	run_end_reason = ""
	run_end_public_reason = ""
	run_finale_emitted = false
	registry_silence_evaluated = false
	registry_silence_active = false
	condanne_this_run = []
	last_audience_context_line = ""
	forced_ending_id = &""
	forced_next_pact_archetype = &""
	special_arena_cashout_lock_reason = ""
	seen_by_crowd_before_run = false
	debug_seed_override_active = false
	debug_seed_override = 0
	run_start_time_msec = 0
	run_save_flow_step = &""
	run_save_flow_bet_id = &""
	glory = 0
	corruption = 0
	scar_double_count = 0
	scar_pact_count = 0
	volatility = 0
	scar_rng_state = 0
	scar_roll_index = 0
	last_pact_corruption_arena_index = -1
	last_pact_corruption_bet_id = &""

func to_dict() -> Dictionary:
	return {
		"run_seed": run_seed,
		"arena_index": arena_index,
		"escalation_level": escalation_level,
		"active_bet_id": String(active_bet_id),
		"enemy_profile": String(enemy_profile),
		"enemy_profiles": _serialize_stringname_array(enemy_profiles),
		"scars_history": _serialize_stringname_array(scars_history),
		"bets_history": _serialize_stringname_array(bets_history),
		"cashouts": cashouts,
		"doubles": doubles,
		"max_escalation": max_escalation,
		"arenas_cleared": arenas_cleared,
		"audience_score": audience_score,
		"refuse_cashout_count_this_run": refuse_cashout_count_this_run,
		"last_action_was_rilancio": last_action_was_rilancio,
		"run_is_over": run_is_over,
		"is_hunted_by_crowd": is_hunted_by_crowd,
		"last_signed_pact_id": String(last_signed_pact_id),
		"risky_choice_made_recently": risky_choice_made_recently,
		"irreversible_bet_scar_registered": irreversible_bet_scar_registered,
		"refused_closure_scar_registered": refused_closure_scar_registered,
		"risk_threshold_scar_registered": risk_threshold_scar_registered,
		"last_scar_arena_index": last_scar_arena_index,
		"bet_chain_level": bet_chain_level,
		"current_bet_id": current_bet_id,
		"level3_reward_tier": level3_reward_tier,
		"level3_next_loss_hp_penalty": level3_next_loss_hp_penalty,
		"level3_target_arenas": level3_target_arenas,
		"level3_min_cashout_arenas": level3_min_cashout_arenas,
		"cashout_lock_remaining": cashout_lock_remaining,
		"last_selected_bet_id": String(last_selected_bet_id),
		"last_bet_offers": _serialize_stringname_array(last_bet_offers),
		"last_enemy_profile": String(last_enemy_profile),
		"special_arena_index": special_arena_index,
		"special_arena_id": String(special_arena_id),
		"special_arena_active": special_arena_active,
		"special_arena_effect_applied": special_arena_effect_applied,
		"arena_theme_id": String(arena_theme_id),
		"level3_cashouts": level3_cashouts,
		"level3_doubles": level3_doubles,
		"level3_bets_used": _serialize_stringname_array(level3_bets_used),
		"level3_max_escalation": level3_max_escalation,
		"level3_cashout_streak": level3_cashout_streak,
		"level3_cashout_streak_max": level3_cashout_streak_max,
		"level3_cashed_after_high_escalation": level3_cashed_after_high_escalation,
		"scar_heal_multiplier": scar_heal_multiplier,
		"scar_dodge_cooldown_multiplier": scar_dodge_cooldown_multiplier,
		"scar_dodge_speed_multiplier": scar_dodge_speed_multiplier,
		"push_luck_cashouts": push_luck_cashouts,
		"push_luck_doubles": push_luck_doubles,
		"max_push_luck_chain": max_push_luck_chain,
		"post_bet_pending_bet_id": String(post_bet_pending_bet_id),
		"post_bet_sequence_id": post_bet_sequence_id,
		"intermediate_pending_bet_id": String(intermediate_pending_bet_id),
		"intermediate_double_disabled_once": intermediate_double_disabled_once,
		"intermediate_bonus_tier": intermediate_bonus_tier,
		"intermediate_choice_note": intermediate_choice_note,
		"intermediate_loss_penalty_pending": intermediate_loss_penalty_pending,
		"provoke_armed": provoke_armed,
		"failed_high_risk_bets": failed_high_risk_bets,
		"run_end_reason": run_end_reason,
		"run_end_public_reason": run_end_public_reason,
		"run_finale_emitted": run_finale_emitted,
		"registry_silence_evaluated": registry_silence_evaluated,
		"registry_silence_active": registry_silence_active,
		"condanne_this_run": _serialize_stringname_array(condanne_this_run),
		"last_audience_context_line": last_audience_context_line,
		"forced_ending_id": String(forced_ending_id),
		"forced_next_pact_archetype": String(forced_next_pact_archetype),
		"special_arena_cashout_lock_reason": special_arena_cashout_lock_reason,
		"seen_by_crowd_before_run": seen_by_crowd_before_run,
		"debug_seed_override_active": debug_seed_override_active,
		"debug_seed_override": debug_seed_override,
		"run_start_time_msec": run_start_time_msec,
		"run_save_flow_step": String(run_save_flow_step),
		"run_save_flow_bet_id": String(run_save_flow_bet_id),
		"glory": glory,
		"corruption": corruption,
		"scar_double_count": scar_double_count,
		"scar_pact_count": scar_pact_count,
		"volatility": volatility,
		"scar_rng_state": scar_rng_state,
		"scar_roll_index": scar_roll_index,
		"last_pact_corruption_arena_index": last_pact_corruption_arena_index,
		"last_pact_corruption_bet_id": String(last_pact_corruption_bet_id),
	}

func from_dict(d: Dictionary) -> void:
	run_seed = int(d.get("run_seed", 0))
	arena_index = int(d.get("arena_index", 0))
	escalation_level = int(d.get("escalation_level", 0))
	active_bet_id = StringName(str(d.get("active_bet_id", "")))
	enemy_profile = StringName(str(d.get("enemy_profile", "")))
	enemy_profiles = _parse_stringname_array(d.get("enemy_profiles", []) as Array)
	scars_history = _parse_stringname_array(d.get("scars_history", []) as Array)
	bets_history = _parse_stringname_array(d.get("bets_history", []) as Array)
	cashouts = int(d.get("cashouts", 0))
	doubles = int(d.get("doubles", 0))
	max_escalation = int(d.get("max_escalation", 0))
	arenas_cleared = int(d.get("arenas_cleared", 0))
	audience_score = int(d.get("audience_score", 0))
	refuse_cashout_count_this_run = int(d.get("refuse_cashout_count_this_run", 0))
	last_action_was_rilancio = bool(d.get("last_action_was_rilancio", false))
	run_is_over = bool(d.get("run_is_over", false))
	is_hunted_by_crowd = bool(d.get("is_hunted_by_crowd", false))
	last_signed_pact_id = StringName(str(d.get("last_signed_pact_id", "")))
	risky_choice_made_recently = bool(d.get("risky_choice_made_recently", false))
	irreversible_bet_scar_registered = bool(d.get("irreversible_bet_scar_registered", false))
	refused_closure_scar_registered = bool(d.get("refused_closure_scar_registered", false))
	risk_threshold_scar_registered = bool(d.get("risk_threshold_scar_registered", false))
	last_scar_arena_index = int(d.get("last_scar_arena_index", -1000))
	bet_chain_level = int(d.get("bet_chain_level", 1))
	current_bet_id = str(d.get("current_bet_id", ""))
	level3_reward_tier = int(d.get("level3_reward_tier", 1))
	level3_next_loss_hp_penalty = int(d.get("level3_next_loss_hp_penalty", 0))
	level3_target_arenas = int(d.get("level3_target_arenas", 0))
	level3_min_cashout_arenas = int(d.get("level3_min_cashout_arenas", 5))
	cashout_lock_remaining = int(d.get("cashout_lock_remaining", 0))
	last_selected_bet_id = StringName(str(d.get("last_selected_bet_id", "")))
	last_bet_offers = _parse_stringname_array(d.get("last_bet_offers", []) as Array)
	last_enemy_profile = StringName(str(d.get("last_enemy_profile", "")))
	special_arena_index = int(d.get("special_arena_index", 0))
	special_arena_id = StringName(str(d.get("special_arena_id", "")))
	special_arena_active = bool(d.get("special_arena_active", false))
	special_arena_effect_applied = bool(d.get("special_arena_effect_applied", false))
	arena_theme_id = StringName(str(d.get("arena_theme_id", "ARENA_WAX_SEAL")))
	level3_cashouts = int(d.get("level3_cashouts", 0))
	level3_doubles = int(d.get("level3_doubles", 0))
	level3_bets_used = _parse_stringname_array(d.get("level3_bets_used", []) as Array)
	level3_max_escalation = int(d.get("level3_max_escalation", 0))
	level3_cashout_streak = int(d.get("level3_cashout_streak", 0))
	level3_cashout_streak_max = int(d.get("level3_cashout_streak_max", 0))
	level3_cashed_after_high_escalation = bool(d.get("level3_cashed_after_high_escalation", false))
	scar_heal_multiplier = float(d.get("scar_heal_multiplier", 1.0))
	scar_dodge_cooldown_multiplier = float(d.get("scar_dodge_cooldown_multiplier", 1.0))
	scar_dodge_speed_multiplier = float(d.get("scar_dodge_speed_multiplier", 1.0))
	push_luck_cashouts = int(d.get("push_luck_cashouts", 0))
	push_luck_doubles = int(d.get("push_luck_doubles", 0))
	max_push_luck_chain = int(d.get("max_push_luck_chain", 1))
	post_bet_pending_bet_id = StringName(str(d.get("post_bet_pending_bet_id", "")))
	post_bet_sequence_id = int(d.get("post_bet_sequence_id", 0))
	intermediate_pending_bet_id = StringName(str(d.get("intermediate_pending_bet_id", "")))
	intermediate_double_disabled_once = bool(d.get("intermediate_double_disabled_once", false))
	intermediate_bonus_tier = int(d.get("intermediate_bonus_tier", 0))
	intermediate_choice_note = str(d.get("intermediate_choice_note", ""))
	intermediate_loss_penalty_pending = bool(d.get("intermediate_loss_penalty_pending", false))
	provoke_armed = bool(d.get("provoke_armed", false))
	failed_high_risk_bets = int(d.get("failed_high_risk_bets", 0))
	run_end_reason = str(d.get("run_end_reason", ""))
	run_end_public_reason = str(d.get("run_end_public_reason", ""))
	run_finale_emitted = bool(d.get("run_finale_emitted", false))
	registry_silence_evaluated = bool(d.get("registry_silence_evaluated", false))
	registry_silence_active = bool(d.get("registry_silence_active", false))
	condanne_this_run = _parse_stringname_array(d.get("condanne_this_run", []) as Array)
	last_audience_context_line = str(d.get("last_audience_context_line", ""))
	forced_ending_id = StringName(str(d.get("forced_ending_id", "")))
	forced_next_pact_archetype = StringName(str(d.get("forced_next_pact_archetype", "")))
	special_arena_cashout_lock_reason = str(d.get("special_arena_cashout_lock_reason", ""))
	seen_by_crowd_before_run = bool(d.get("seen_by_crowd_before_run", false))
	debug_seed_override_active = bool(d.get("debug_seed_override_active", false))
	debug_seed_override = int(d.get("debug_seed_override", 0))
	run_start_time_msec = int(d.get("run_start_time_msec", 0))
	run_save_flow_step = StringName(str(d.get("run_save_flow_step", "")))
	run_save_flow_bet_id = StringName(str(d.get("run_save_flow_bet_id", "")))
	glory = int(d.get("glory", 0))
	corruption = int(d.get("corruption", 0))
	scar_double_count = int(d.get("scar_double_count", 0))
	scar_pact_count = int(d.get("scar_pact_count", 0))
	volatility = int(d.get("volatility", 0))
	scar_rng_state = int(d.get("scar_rng_state", 0))
	scar_roll_index = int(d.get("scar_roll_index", 0))
	last_pact_corruption_arena_index = int(d.get("last_pact_corruption_arena_index", -1))
	last_pact_corruption_bet_id = StringName(str(d.get("last_pact_corruption_bet_id", "")))

func _serialize_stringname_array(items: Array) -> Array[String]:
	var values: Array[String] = []
	for item: Variant in items:
		values.append(str(item))
	return values

func _parse_stringname_array(items: Array) -> Array[StringName]:
	var values: Array[StringName] = []
	for item: Variant in items:
		var text: String = str(item)
		if text == "":
			continue
		values.append(StringName(text))
	return values
