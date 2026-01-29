extends Node

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal run_finale_selected(payload: Dictionary)
signal run_debug_state_updated(payload: Dictionary)
signal run_log_ready(log_text: String)
signal special_arena_started(payload: Dictionary)
signal sentence_banner_requested(payload: Dictionary)
signal audience_context_line_emitted(text: String)
signal condanna_registered(id: StringName)
signal bet_failed(can_retry: bool)
signal coins_changed(coins: int)
signal tokens_changed(tokens: int)
signal enemy_killed(exp: int)
signal escalation_changed(level: int, max_value: int)
signal level_changed(level: int)
signal xp_changed(xp: int, xp_required: int)
signal bet_placed(bet_id: String, stake: int, odds: float)
signal bet_confirmed(pact_id: StringName, condition_id: StringName, sentence_id: StringName)
signal bet_sealed(bet_choice: Dictionary)
signal bet_selected(bet_id: String)
signal bet_ui_opened(bets: Array)
signal bet_ui_closed
signal betting_opened
signal betting_closed
signal bet_opened
signal bet_closed
signal pact_sealed_opened
signal pact_sealed_closed
signal resolve_ritual_opened(payload: Dictionary)
signal resolve_ritual_closed
signal intermediate_choice_opened
signal push_luck_opened(payload: Dictionary)
signal push_luck_closed
signal post_arena_choice_selected(choice_id: StringName)
signal player_damaged
signal run_phase_changed(phase: int)
signal countdown_requested(seconds: int)
signal gameplay_enabled_changed(enabled: bool)
signal modal_opened(kind: String)
signal modal_closed(kind: String)
signal scars_updated(scars: Array)
signal scar_applied(scar: Dictionary)

# --- Progression / Difficulty ---
signal difficulty_tier_changed(tier: int, multiplier: float)
signal player_xp_changed(xp: int, xp_to_next: int)
signal player_level_changed(level: int)
signal upgrade_tokens_changed(tokens: int)
signal request_purchase_upgrade(upgrade_key: String)
signal request_purchase_token
signal request_place_bet(bet_id: String, stake: int)
signal request_open_bet_ui
signal request_consume_upgrade_shop
signal request_reset_run
signal request_retry_run
signal request_continue_run
signal request_next_bet
signal request_add_coins(amount: int)
signal request_push_luck_cashout
signal request_push_luck_double
signal request_intermediate_choice(choice_id: String)
signal request_set_run_seed(seed: int)
signal request_clear_run_seed
signal request_skip_arena_resolution

var gameplay_enabled: bool = true

func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		return
	gameplay_enabled = enabled
	gameplay_enabled_changed.emit(enabled)
