extends Node

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal bet_failed(can_retry: bool)
signal coins_changed(coins: int)
signal bet_placed(bet_id: String, stake: int, odds: float)
signal bet_ui_opened(bets: Array)
signal bet_ui_closed
signal betting_opened
signal betting_closed
signal bet_opened
signal bet_closed
signal player_damaged
signal run_phase_changed(phase: int)
signal countdown_requested(seconds: int)
signal gameplay_enabled_changed(enabled: bool)

# --- Progression / Difficulty ---
signal enemy_killed(exp: int)
signal difficulty_tier_changed(tier: int, multiplier: float)
signal player_xp_changed(xp: int, xp_to_next: int)
signal player_level_changed(level: int)
signal upgrade_tokens_changed(tokens: int)
signal tokens_changed(tokens: int)

var gameplay_enabled: bool = true

func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		return
	gameplay_enabled = enabled
	gameplay_enabled_changed.emit(enabled)
