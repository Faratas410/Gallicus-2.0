# RunManager Function Inventory (Auto-generated)

- Source: `scripts/systems/run_manager.gd`
- Total functions: **326**
- Scope: inventory for analysis/audit, non-canonical support report.

## Category counts

- `arena_enemy_runtime`: **42**
- `audience`: **10**
- `betting_pacts`: **52**
- `diagnostics`: **22**
- `other`: **85**
- `phase_flow`: **18**
- `request_api`: **30**
- `run_end`: **24**
- `save_continue`: **10**
- `scar_register_corruption`: **33**

## Action gameplay references (light/heavy attack etc.)

- L1066: `@export var bet_pure_light_bonus: int = 2`
- L1067: `@export var bet_pure_heavy_bonus: int = 2`
- L1818: `_run_state.last_action_was_rilancio = false`
- L1978: `_run_state.last_action_was_rilancio = false`
- L2739: `_run_state.last_action_was_rilancio = false`
- L3028: `"attack_light": [KEY_J],`
- L3029: `"attack_heavy": [KEY_K],`
- L3030: `"block": [KEY_L],`
- L3031: `"dodge": [KEY_SPACE],`
- L3393: `_run_state.last_action_was_rilancio = false`
- L3438: `_run_state.last_action_was_rilancio = false`
- L3481: `_run_state.last_action_was_rilancio = true`
- L4203: `bet_pure_light_bonus,`
- L4204: `bet_pure_heavy_bonus`
- L4218: `bet_pure_light_bonus,`
- L4219: `bet_pure_heavy_bonus`
- L4270: `if not p.has_method("get_damage_values"):`
- L4272: `var damage_values: Array = p.call("get_damage_values") as Array`
- L4343: `if _run_state.run_end_reason != "CASH_OUT" and _run_state.last_action_was_rilancio:`

## Full function index

| Line | Function | Category |
|---:|---|---|
| 190 | `_flow_log` | `diagnostics` |
| 1159 | `_smoke_init_if_needed` | `diagnostics` |
| 1165 | `_is_smoke_mode` | `diagnostics` |
| 1170 | `_phase_to_name` | `other` |
| 1202 | `_start_smoke_timeout_timer` | `diagnostics` |
| 1219 | `_smoke_start_scenario` | `diagnostics` |
| 1236 | `_stop_smoke_driver` | `diagnostics` |
| 1244 | `_on_smoke_driver_tick` | `diagnostics` |
| 1264 | `_smoke_quit_gate` | `diagnostics` |
| 1268 | `_ready` | `other` |
| 1305 | `_process` | `other` |
| 1309 | `_connect_gameevents` | `other` |
| 1360 | `_apply_saved_language` | `save_continue` |
| 1364 | `_apply_language` | `other` |
| 1370 | `_resolve_available_locale` | `other` |
| 1386 | `_on_settings_changed` | `other` |
| 1392 | `_boot` | `other` |
| 1431 | `_validate_game_events_signals` | `other` |
| 1464 | `_validate_boot` | `other` |
| 1499 | `_connect_ui_queue_signals` | `other` |
| 1508 | `_abort_sanity` | `other` |
| 1513 | `_refresh_sanity_ui_root` | `other` |
| 1525 | `_ensure_flow_panel` | `diagnostics` |
| 1535 | `_fail_flow` | `diagnostics` |
| 1542 | `request_new_game` | `request_api` |
| 1547 | `_guard_request_phase` | `other` |
| 1555 | `_require_phase` | `other` |
| 1561 | `_guard_phase` | `other` |
| 1576 | `_flow_snapshot` | `diagnostics` |
| 1588 | `request_confirm_pact` | `request_api` |
| 1598 | `request_choose_mid` | `request_api` |
| 1610 | `request_push_your_luck` | `request_api` |
| 1616 | `request_take_payout` | `request_api` |
| 1622 | `request_quit_to_menu` | `request_api` |
| 1626 | `request_load_continue` | `request_api` |
| 1639 | `start_new_run` | `run_end` |
| 1642 | `_start_new_run` | `run_end` |
| 1741 | `start_run` | `run_end` |
| 1744 | `_start_level3_run` | `run_end` |
| 1852 | `start_arena` | `arena_enemy_runtime` |
| 1870 | `select_bet` | `betting_pacts` |
| 1876 | `_confirm_pact_with_bet_id` | `betting_pacts` |
| 1915 | `_start_pact_sealed_ritual` | `betting_pacts` |
| 1931 | `_start_resolve_ritual` | `other` |
| 1956 | `_resolve_ritual_outcome` | `other` |
| 1999 | `_apply_resolution_advance_state` | `other` |
| 2041 | `resolve_arena` | `arena_enemy_runtime` |
| 2045 | `_enter_resolution` | `phase_flow` |
| 2056 | `apply_scar` | `scar_register_corruption` |
| 2059 | `_play_arena_resolution_fx` | `arena_enemy_runtime` |
| 2079 | `end_run` | `run_end` |
| 2088 | `start_next_bet_round` | `betting_pacts` |
| 2102 | `reset_run` | `run_end` |
| 2108 | `_open_bet_ui` | `betting_pacts` |
| 2121 | `_open_level3_bet_ui` | `betting_pacts` |
| 2139 | `_build_level3_bet_offer` | `betting_pacts` |
| 2167 | `_get_available_level3_bets` | `betting_pacts` |
| 2190 | `_is_level3_bet_unlocked` | `betting_pacts` |
| 2196 | `_is_level3_bet_allowed` | `betting_pacts` |
| 2214 | `_get_run_seed_value` | `run_end` |
| 2219 | `_compute_level3_seed` | `other` |
| 2231 | `_compute_level3_offer_seed` | `other` |
| 2239 | `_initialize_scar_rng_state` | `scar_register_corruption` |
| 2248 | `_scar_roll` | `scar_register_corruption` |
| 2258 | `_apply_corruption` | `scar_register_corruption` |
| 2266 | `_total_passive_scar_count` | `scar_register_corruption` |
| 2269 | `_double_scar_base_chance` | `scar_register_corruption` |
| 2273 | `_try_apply_double_scar_pool` | `scar_register_corruption` |
| 2287 | `_try_apply_pact_scar_pool` | `scar_register_corruption` |
| 2297 | `_compute_volatility_shift` | `other` |
| 2307 | `_emit_run_debug_state` | `diagnostics` |
| 2314 | `_apply_glory_on_success` | `other` |
| 2320 | `_update_glory_multiplier_from_doubles` | `betting_pacts` |
| 2325 | `_autosave_run_checkpoint` | `save_continue` |
| 2341 | `_apply_run_save_payload` | `save_continue` |
| 2409 | `_reject_invalid_continue_payload` | `other` |
| 2418 | `_resume_run_from_save` | `save_continue` |
| 2443 | `_serialize_stringname_array` | `save_continue` |
| 2452 | `_serialize_run_scars` | `save_continue` |
| 2458 | `_parse_run_scars` | `save_continue` |
| 2465 | `_serialize_scars_detail` | `save_continue` |
| 2474 | `_apply_scars_detail` | `scar_register_corruption` |
| 2485 | `_parse_pacts_log` | `save_continue` |
| 2502 | `_emit_escalation_changed` | `other` |
| 2507 | `_get_current_arena_index` | `arena_enemy_runtime` |
| 2513 | `_get_available_arena_theme_ids` | `arena_enemy_runtime` |
| 2518 | `_pick_next_arena_theme` | `arena_enemy_runtime` |
| 2523 | `_emit_arena_theme_changed` | `arena_enemy_runtime` |
| 2537 | `_append_pact_log_entry` | `betting_pacts` |
| 2547 | `_update_last_pact_outcome` | `betting_pacts` |
| 2557 | `_pick_special_arena_index` | `arena_enemy_runtime` |
| 2560 | `_maybe_activate_special_arena` | `arena_enemy_runtime` |
| 2570 | `_emit_special_arena_started` | `arena_enemy_runtime` |
| 2583 | `_get_special_arena_title` | `arena_enemy_runtime` |
| 2586 | `_get_special_arena_description` | `arena_enemy_runtime` |
| 2589 | `_apply_special_arena_pre_resolution` | `arena_enemy_runtime` |
| 2603 | `_apply_special_arena_post_resolution` | `arena_enemy_runtime` |
| 2616 | `_apply_special_arena_ash_reward` | `arena_enemy_runtime` |
| 2627 | `_pick_special_arena_scar` | `scar_register_corruption` |
| 2634 | `_select_enemy_profile` | `arena_enemy_runtime` |
| 2654 | `_weighted_pick_enemy_index` | `arena_enemy_runtime` |
| 2672 | `_compute_level3_enemy_seed` | `arena_enemy_runtime` |
| 2679 | `_log_level3_arena_result` | `arena_enemy_runtime` |
| 2700 | `_get_active_scar_ids` | `scar_register_corruption` |
| 2708 | `_resolve_level3_arena` | `arena_enemy_runtime` |
| 2732 | `_get_level3_bet_behavior` | `betting_pacts` |
| 2736 | `_handle_level3_win` | `other` |
| 2743 | `_handle_level3_loss` | `other` |
| 2789 | `_handle_level3_loss_ritual` | `other` |
| 2835 | `_apply_level3_reward` | `other` |
| 2845 | `_apply_level3_scar` | `scar_register_corruption` |
| 2865 | `_get_scar_def` | `scar_register_corruption` |
| 2868 | `_ensure_arena_and_player` | `arena_enemy_runtime` |
| 2916 | `pick_next_arena_scene` | `arena_enemy_runtime` |
| 2922 | `_ensure_arena_layout_container` | `arena_enemy_runtime` |
| 2941 | `_remove_default_arena_layout` | `arena_enemy_runtime` |
| 2951 | `load_next_arena` | `arena_enemy_runtime` |
| 2975 | `_reset_or_respawn_player_full` | `arena_enemy_runtime` |
| 3007 | `_clear_enemies` | `other` |
| 3012 | `_spawn_wave_or_enemies` | `arena_enemy_runtime` |
| 3019 | `_ensure_input_map` | `other` |
| 3055 | `_start_next_arena` | `arena_enemy_runtime` |
| 3066 | `_apply_phase_result` | `other` |
| 3074 | `_mut_pyl_cashout` | `betting_pacts` |
| 3077 | `_mut_pyl_double` | `betting_pacts` |
| 3080 | `_mut_pyl_condanna` | `other` |
| 3083 | `_mut_betp_place_bet` | `betting_pacts` |
| 3093 | `_mut_intro_select_bet` | `betting_pacts` |
| 3099 | `_mut_intro_confirm` | `other` |
| 3102 | `_mut_intm_select` | `other` |
| 3108 | `_mut_resolution_advance` | `other` |
| 3111 | `_mut_gameover_show_menu` | `other` |
| 3114 | `_mut_gameover_restart` | `other` |
| 3117 | `_mut_mainmenu_new_run` | `run_end` |
| 3121 | `_mut_mainmenu_continue_run` | `run_end` |
| 3124 | `_mut_mainmenu_show_menu` | `other` |
| 3128 | `_apply_state_mutation` | `other` |
| 3131 | `_build_flow_executor_hooks` | `diagnostics` |
| 3140 | `_apply_state_mutation_step` | `other` |
| 3143 | `_autosave_run_checkpoint_from_executor` | `save_continue` |
| 3146 | `_clear_run_from_executor` | `run_end` |
| 3149 | `_report_mutation_executor_error` | `other` |
| 3152 | `_debug_bet_choice_received` | `betting_pacts` |
| 3155 | `_debug_show_main_menu_received` | `diagnostics` |
| 3158 | `_end_run_from_pyl` | `run_end` |
| 3163 | `_apply_mutation_plan` | `other` |
| 3166 | `_route_guarded_phase_request` | `other` |
| 3192 | `_dispatch_phase_request` | `other` |
| 3207 | `_on_request_new_run` | `request_api` |
| 3211 | `_on_request_reset_run` | `request_api` |
| 3216 | `_on_request_retry_run` | `request_api` |
| 3221 | `_on_request_continue_run` | `request_api` |
| 3225 | `_on_request_show_main_menu` | `request_api` |
| 3229 | `_on_request_intro_apply_seed` | `request_api` |
| 3246 | `_on_request_intro_select_bet` | `request_api` |
| 3251 | `_apply_intro_select_bet_request` | `betting_pacts` |
| 3271 | `_on_request_intro_confirm` | `request_api` |
| 3276 | `_on_request_mid_choice_select` | `request_api` |
| 3282 | `_on_request_pyl_cashout` | `request_api` |
| 3288 | `_on_request_pyl_condanna` | `request_api` |
| 3294 | `_on_request_pyl_double` | `request_api` |
| 3300 | `_on_request_end_run_restart` | `request_api` |
| 3305 | `_on_request_end_run_next_bet` | `request_api` |
| 3310 | `_on_request_end_run_quit` | `request_api` |
| 3315 | `_on_request_place_bet` | `request_api` |
| 3319 | `_on_request_intermediate_choice` | `request_api` |
| 3332 | `_apply_intermediate_choice` | `other` |
| 3370 | `_on_post_arena_choice_selected` | `arena_enemy_runtime` |
| 3375 | `_on_request_push_luck_cashout` | `request_api` |
| 3380 | `_take_payout` | `other` |
| 3433 | `_handle_push_luck_condanna` | `betting_pacts` |
| 3457 | `_on_request_push_luck_double` | `request_api` |
| 3462 | `_push_your_luck` | `betting_pacts` |
| 3524 | `_on_request_set_run_seed` | `request_api` |
| 3534 | `_on_request_clear_run_seed` | `request_api` |
| 3544 | `_on_request_skip_arena_resolution` | `request_api` |
| 3561 | `_debug_skip_level3_step` | `diagnostics` |
| 3570 | `_get_debug_default_bet` | `betting_pacts` |
| 3576 | `_on_modal_opened` | `other` |
| 3580 | `_on_modal_closed` | `other` |
| 3584 | `_apply_modal_lock` | `other` |
| 3603 | `_set_arena_suspended` | `arena_enemy_runtime` |
| 3615 | `add_coins` | `other` |
| 3621 | `spend_coins` | `other` |
| 3630 | `_on_bet_placed` | `betting_pacts` |
| 3647 | `_on_bet_confirmed` | `betting_pacts` |
| 3650 | `_on_bet_sealed` | `betting_pacts` |
| 3656 | `_handle_bet_sealed` | `betting_pacts` |
| 3679 | `_on_betting_opened` | `betting_pacts` |
| 3682 | `_on_wave_started` | `other` |
| 3690 | `_on_wave_cleared` | `other` |
| 3709 | `_on_player_spawned` | `arena_enemy_runtime` |
| 3715 | `_on_enemy_killed` | `arena_enemy_runtime` |
| 3733 | `_xp_needed_for_next` | `other` |
| 3745 | `_check_level_up` | `other` |
| 3760 | `get_level` | `other` |
| 3763 | `get_difficulty_tier` | `other` |
| 3766 | `get_difficulty_multiplier` | `other` |
| 3774 | `_recompute_difficulty_tier` | `other` |
| 3787 | `_apply_enemy_difficulty_to_arena` | `arena_enemy_runtime` |
| 3796 | `_resolve_player` | `other` |
| 3827 | `_connect_player_signals` | `other` |
| 3843 | `_on_request_fail_run` | `request_api` |
| 3855 | `_on_player_died` | `other` |
| 3860 | `_get_bet_chain_reward_scale` | `betting_pacts` |
| 3863 | `_reset_bet_chain` | `betting_pacts` |
| 3870 | `_reset_intermediate_choice_modifiers` | `other` |
| 3875 | `_consume_intermediate_choice_bonus` | `other` |
| 3880 | `_apply_intermediate_loss_penalty_if_needed` | `other` |
| 3888 | `_open_intermediate_choice` | `other` |
| 3892 | `_enter_mid_choice` | `phase_flow` |
| 3897 | `_open_push_luck_choice` | `betting_pacts` |
| 3900 | `_enter_push_your_luck` | `phase_flow` |
| 3904 | `_refresh_push_luck_choice` | `betting_pacts` |
| 3907 | `_build_intermediate_choice_ui_payload` | `other` |
| 3919 | `_build_push_luck_ui_payload` | `betting_pacts` |
| 3937 | `_emit_ui` | `other` |
| 3950 | `_build_phase_ui_payload` | `other` |
| 3957 | `_build_push_luck_payload` | `betting_pacts` |
| 3992 | `_emit_sentence_banner_for_bet` | `betting_pacts` |
| 4000 | `_build_sentence_payload` | `other` |
| 4011 | `_get_sentence_rule` | `other` |
| 4023 | `_get_sentence_doom` | `other` |
| 4046 | `_queue_push_luck_choice` | `betting_pacts` |
| 4050 | `_enter_first_reaction` | `phase_flow` |
| 4067 | `_on_arena_message_queue_completed` | `arena_enemy_runtime` |
| 4074 | `_force_post_bet_choice_fallback` | `betting_pacts` |
| 4084 | `_get_cashout_lock_reason` | `betting_pacts` |
| 4095 | `_get_double_lock_reason` | `betting_pacts` |
| 4102 | `_update_audience_after_arena` | `arena_enemy_runtime` |
| 4118 | `_check_audience_condanne` | `audience` |
| 4124 | `_get_audience_context_mood` | `audience` |
| 4131 | `_pick_audience_context_line` | `audience` |
| 4151 | `_emit_audience_context_line` | `audience` |
| 4160 | `_close_audience_context_line` | `audience` |
| 4165 | `_get_audience_cashout_modifier` | `betting_pacts` |
| 4169 | `_build_audience_reward_text` | `audience` |
| 4182 | `_apply_bet_reward_scaled` | `betting_pacts` |
| 4195 | `_apply_pure_bet_reward_scaled` | `betting_pacts` |
| 4207 | `_build_bet_pact_text` | `betting_pacts` |
| 4222 | `_build_bet_doom_text` | `betting_pacts` |
| 4233 | `_get_bet_data` | `betting_pacts` |
| 4241 | `_get_level3_bet_name` | `betting_pacts` |
| 4248 | `_get_level3_doom_short` | `other` |
| 4264 | `_apply_double_or_die_reward_scaled` | `betting_pacts` |
| 4281 | `retry_current_bet` | `betting_pacts` |
| 4296 | `_enter_end_run` | `phase_flow` |
| 4308 | `_enter_game_over` | `phase_flow` |
| 4353 | `_emit_run_failed` | `run_end` |
| 4361 | `_emit_run_ended` | `run_end` |
| 4380 | `_register_run_end` | `scar_register_corruption` |
| 4386 | `_emit_run_finale` | `run_end` |
| 4403 | `_log_balance_terminal_metrics` | `other` |
| 4420 | `_should_emit_registry_silence` | `other` |
| 4432 | `_emit_run_log` | `run_end` |
| 4438 | `_build_run_log` | `run_end` |
| 4461 | `_export_run_summary` | `run_end` |
| 4472 | `_build_run_summary` | `run_end` |
| 4475 | `_build_game_over_stats_payload` | `run_end` |
| 4485 | `_build_game_over_anomaly_flow_tag` | `diagnostics` |
| 4498 | `_build_game_over_finale_inputs` | `run_end` |
| 4517 | `_build_game_over_copy_inputs` | `run_end` |
| 4523 | `_select_run_finale` | `run_end` |
| 4588 | `_update_hidden_run_metrics` | `run_end` |
| 4605 | `_is_high_risk_behavior` | `other` |
| 4608 | `_register_pact_corruption` | `scar_register_corruption` |
| 4621 | `_count_scars_with_tag` | `scar_register_corruption` |
| 4631 | `get_available_level3_pacts` | `betting_pacts` |
| 4642 | `get_level3_pact_title` | `betting_pacts` |
| 4650 | `get_pact_reveal_line` | `betting_pacts` |
| 4655 | `get_available_arena_themes` | `arena_enemy_runtime` |
| 4658 | `is_harsh_crowd_unlocked` | `audience` |
| 4661 | `get_crowd_line_count_base` | `audience` |
| 4664 | `get_crowd_line_count_harsh` | `audience` |
| 4667 | `_count_crowd_lines` | `audience` |
| 4676 | `get_arena` | `arena_enemy_runtime` |
| 4679 | `get_arena_index` | `arena_enemy_runtime` |
| 4682 | `is_live` | `other` |
| 4685 | `is_level3_mode` | `other` |
| 4688 | `is_visual_only` | `other` |
| 4693 | `get_debug_phase_name` | `diagnostics` |
| 4696 | `get_debug_last_request` | `diagnostics` |
| 4699 | `get_debug_last_ui_render_ms` | `diagnostics` |
| 4702 | `get_debug_flow_tail` | `diagnostics` |
| 4705 | `_set_phase` | `phase_flow` |
| 4725 | `_touch_request_activity` | `other` |
| 4729 | `_watchdog_stall_hint` | `diagnostics` |
| 4739 | `_watchdog_tick` | `diagnostics` |
| 4752 | `_has_enter_phase_handler` | `phase_flow` |
| 4759 | `_run_enter_phase` | `phase_flow` |
| 4794 | `_enter_main_menu` | `phase_flow` |
| 4797 | `_enter_intro` | `phase_flow` |
| 4803 | `_enter_bet_present` | `phase_flow` |
| 4813 | `_enter_bet_committed` | `phase_flow` |
| 4816 | `_enter_next_bet` | `phase_flow` |
| 4819 | `_enter_end_run_phase` | `phase_flow` |
| 4822 | `set_phase` | `phase_flow` |
| 4829 | `_set_runtime_gate_phase` | `phase_flow` |
| 4834 | `_apply_phase` | `phase_flow` |
| 4839 | `_update_arena_visual_only` | `arena_enemy_runtime` |
| 4850 | `_position_player_after_respawn` | `arena_enemy_runtime` |
| 4866 | `_reset_upgrades` | `other` |
| 4876 | `_reset_upgrade_costs` | `other` |
| 4883 | `_reset_progression` | `other` |
| 4890 | `_register_condanna` | `scar_register_corruption` |
| 4901 | `_is_unlocked` | `other` |
| 4904 | `_reset_scars` | `scar_register_corruption` |
| 4908 | `_emit_scars_updated` | `scar_register_corruption` |
| 4912 | `_has_scar` | `scar_register_corruption` |
| 4918 | `_add_scar` | `scar_register_corruption` |
| 4940 | `_emit_register_annotation_from_scar` | `scar_register_corruption` |
| 4948 | `_emit_register_annotation_from_run_end` | `scar_register_corruption` |
| 4956 | `_build_register_metrics` | `scar_register_corruption` |
| 4972 | `_build_run_scar` | `scar_register_corruption` |
| 4981 | `_register_run_scar` | `scar_register_corruption` |
| 4995 | `_try_register_refused_closure_scar` | `scar_register_corruption` |
| 5009 | `_try_register_risk_threshold_scar` | `scar_register_corruption` |
| 5023 | `_recompute_scar_modifiers` | `scar_register_corruption` |
| 5026 | `_recompute_scar_synergies` | `scar_register_corruption` |
| 5031 | `_get_bet_display_name` | `betting_pacts` |
| 5037 | `_try_apply_open_wound_scar` | `scar_register_corruption` |
| 5056 | `_try_apply_cracked_bones_scar` | `scar_register_corruption` |
| 5076 | `_apply_scar_modifiers_to_player` | `scar_register_corruption` |
| 5089 | `_get_spawn_position` | `arena_enemy_runtime` |
| 5098 | `_find_spawn_node` | `arena_enemy_runtime` |
| 5110 | `_log_runtime_state` | `run_end` |
