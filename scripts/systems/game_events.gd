extends Node

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal run_ended(reason: String, summary: Dictionary)
signal run_finale_selected(payload: Dictionary)
signal meta_progress_unlocked(ending_key: String)
signal achievement_unlocked(achievement_id: String)
signal archive_entry_unlocked(entry_id: String)
signal run_debug_state_updated(payload: Dictionary)
signal run_log_ready(log_text: String)
signal special_arena_started(payload: Dictionary)
signal arena_theme_changed(payload: Dictionary)
signal sentence_banner_requested(payload: Dictionary)
signal audience_context_line_emitted(text: String)
signal register_annotation(payload: Dictionary)
signal condanna_registered(id: StringName)
signal bet_failed(can_retry: bool)
signal coins_changed(coins: int)
signal escalation_changed(level: int, max_value: int)
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
signal micro_interpretive_quick_cut_requested(payload: Dictionary)
signal intermediate_choice_opened
signal push_luck_opened(payload: Dictionary)
signal push_luck_closed
signal post_arena_choice_selected(choice_id: StringName)
signal run_phase_changed(phase: int)
signal countdown_requested(seconds: int)
signal gameplay_enabled_changed(enabled: bool)
signal modal_opened(kind: String)
signal modal_closed(kind: String)
signal scars_updated(scars: Array)
signal scar_applied(scar: Dictionary)
signal settings_opened
signal settings_closed
signal settings_changed(payload: Dictionary)
signal difficulty_tier_changed(tier: int, multiplier: float)
signal request_place_bet(bet_id: String, stake: int)
signal request_new_run
signal request_reset_run
signal request_retry_run
signal request_continue_run
signal continue_rejected(reason: String)
signal request_push_luck_cashout
signal request_push_luck_double
signal request_intermediate_choice(choice_id: String)
signal request_intro_apply_seed(seed_text: String)
signal request_intro_select_bet(bet_id: String)
signal request_intro_confirm
signal request_mid_choice_select(index: int)
signal request_pyl_cashout
signal request_pyl_condanna
signal request_pyl_double
signal request_end_run_restart
signal request_end_run_next_bet
signal request_end_run_quit
signal request_set_run_seed(seed: int)
signal request_clear_run_seed
signal request_skip_arena_resolution
signal request_show_main_menu
signal request_fail_run(reason: String)

var gameplay_enabled: bool = true

func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		return
	gameplay_enabled = enabled
	gameplay_enabled_changed.emit(enabled)
