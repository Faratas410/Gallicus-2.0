extends Node

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal run_finale_selected(payload: Dictionary)
signal bet_failed(can_retry: bool)
signal coins_changed(coins: int)
signal tokens_changed(tokens: int)
signal enemy_killed(exp: int)
signal level_changed(level: int)
signal xp_changed(xp: int, xp_required: int)
signal bet_placed(bet_id: String, stake: int, odds: float)
signal bet_ui_opened(bets: Array)
signal bet_ui_closed
signal betting_opened
signal betting_closed
signal bet_opened
signal bet_closed
signal push_luck_opened(payload: Dictionary)
signal push_luck_closed
signal player_damaged
signal run_phase_changed(phase: int)
signal countdown_requested(seconds: int)
signal gameplay_enabled_changed(enabled: bool)
signal modal_opened(kind: String)
signal modal_closed(kind: String)
signal scars_updated(scars: Array)

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
signal request_next_bet
signal request_add_coins(amount: int)
signal request_push_luck_cashout
signal request_push_luck_double

var gameplay_enabled: bool = true

func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		return
	gameplay_enabled = enabled
	gameplay_enabled_changed.emit(enabled)
