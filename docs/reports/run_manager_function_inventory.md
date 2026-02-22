# RunManager Function Inventory (Auto-generated)

- Source: `scripts/systems/run_manager.gd`
- Scan date: `2026-02-21`
- Total functions: **307**
- Scope: inventory for analysis/audit, non-canonical support report.

## Category counts

- `arena_enemy_runtime`: **30**
- `audience`: **8**
- `betting_pacts`: **49**
- `diagnostics`: **23**
- `other`: **87**
- `phase_flow`: **24**
- `request_api`: **27**
- `run_end`: **15**
- `save_continue`: **11**
- `scar_register_corruption`: **33**

## Purge catalog (dead_end / level3 / unknown)

Catalogazione aggiuntiva per facilitare il purge in modo organizzato. Regole applicate in ordine: `level3` -> `dead_end` -> `unknown`.

| Purge bucket | Regola operativa | Funzioni |
|---|---|---:|
| `dead_end` | Flow terminale (`run_end`) o nome funzione con marker terminali (`end_run`, `game_over`, `run_failed`, `run_ended`, `run_finale`) | **21** |
| `level3` | Nome funzione con token `level3` (path runtime L3) | **24** |
| `unknown` | Categoria originale `other` non classificata nelle bucket precedenti | **78** |

### dead_end index

| Line | Function | Base category |
|---:|---|---|
| 518 | `record_run_end_annotation` | `run_end` |
| 1604 | `start_new_run` | `run_end` |
| 1607 | `_start_new_run` | `run_end` |
| 1616 | `start_run` | `run_end` |
| 1947 | `end_run` | `run_end` |
| 1959 | `reset_run` | `run_end` |
| 2824 | `_end_run_from_pyl` | `run_end` |
| 2966 | `_on_request_end_run_restart` | `request_api` |
| 2971 | `_on_request_end_run_next_bet` | `betting_pacts` |
| 2976 | `_on_request_end_run_quit` | `request_api` |
| 3711 | `_enter_end_run` | `phase_flow` |
| 3723 | `_enter_game_over` | `phase_flow` |
| 3768 | `_emit_run_failed` | `run_end` |
| 3776 | `_emit_run_ended` | `run_end` |
| 3801 | `_emit_run_finale` | `run_end` |
| 3890 | `_build_game_over_stats_payload` | `run_end` |
| 3900 | `_build_game_over_anomaly_flow_tag` | `run_end` |
| 3913 | `_build_game_over_finale_inputs` | `run_end` |
| 3932 | `_build_game_over_copy_inputs` | `run_end` |
| 3938 | `_select_run_finale` | `run_end` |
| 4235 | `_enter_end_run_phase` | `phase_flow` |

### level3 index

| Line | Function | Base category |
|---:|---|---|
| 1619 | `_start_level3_run` | `other` |
| 1968 | `_open_level3_bet_ui` | `betting_pacts` |
| 1986 | `_build_level3_bet_offer` | `betting_pacts` |
| 2014 | `_get_available_level3_bets` | `betting_pacts` |
| 2037 | `_is_level3_bet_unlocked` | `betting_pacts` |
| 2043 | `_is_level3_bet_allowed` | `betting_pacts` |
| 2066 | `_compute_level3_seed` | `other` |
| 2078 | `_compute_level3_offer_seed` | `other` |
| 2511 | `_compute_level3_enemy_seed` | `arena_enemy_runtime` |
| 2518 | `_log_level3_arena_result` | `arena_enemy_runtime` |
| 2547 | `_resolve_level3_arena` | `arena_enemy_runtime` |
| 2571 | `_get_level3_bet_behavior` | `betting_pacts` |
| 2575 | `_handle_level3_win` | `other` |
| 2582 | `_handle_level3_loss` | `other` |
| 2628 | `_handle_level3_loss_ritual` | `other` |
| 2674 | `_apply_level3_reward` | `other` |
| 2684 | `_apply_level3_scar` | `scar_register_corruption` |
| 3184 | `_debug_skip_level3_step` | `diagnostics` |
| 3672 | `_get_level3_bet_name` | `betting_pacts` |
| 3679 | `_get_level3_doom_short` | `other` |
| 4046 | `get_available_level3_pacts` | `betting_pacts` |
| 4057 | `get_level3_pact_title` | `betting_pacts` |
| 4065 | `get_level3_pact_reveal_text` | `betting_pacts` |
| 4103 | `is_level3_mode` | `other` |

## Canon/doc verification

- Scansione eseguita solo su `scripts/systems/run_manager.gd`.
- Nessuna modifica runtime applicata: nessun aggiornamento canon obbligatorio (RUN_ARCHITECTURE_CANON / MECHANICS_UNIFIED).
- Documentazione generale aggiornata con questo inventory report.

## Full function index

| Line | Function | Category |
|---:|---|---|
| 188 | `_flow_log` | `diagnostics` |
| 402 | `to_dict` | `other` |
| 417 | `to_dict` | `other` |
| 458 | `_update_flow_phase` | `phase_flow` |
| 500 | `record_scar_annotation` | `scar_register_corruption` |
| 518 | `record_run_end_annotation` | `run_end` |
| 1141 | `_smoke_init_if_needed` | `diagnostics` |
| 1147 | `_is_smoke_mode` | `diagnostics` |
| 1152 | `_phase_to_name` | `phase_flow` |
| 1184 | `_start_smoke_timeout_timer` | `diagnostics` |
| 1192 | `_smoke_start_scenario` | `diagnostics` |
| 1205 | `_stop_smoke_driver` | `diagnostics` |
| 1210 | `_on_smoke_driver_tick` | `diagnostics` |
| 1230 | `_smoke_quit_gate` | `diagnostics` |
| 1234 | `_smoke_tick` | `diagnostics` |
| 1249 | `_ready` | `other` |
| 1285 | `_process` | `other` |
| 1291 | `_connect_gameevents` | `other` |
| 1341 | `_apply_saved_language` | `save_continue` |
| 1345 | `_apply_language` | `other` |
| 1351 | `_resolve_available_locale` | `other` |
| 1367 | `_on_settings_changed` | `other` |
| 1373 | `_boot` | `other` |
| 1396 | `_validate_game_events_signals` | `diagnostics` |
| 1429 | `_validate_boot` | `diagnostics` |
| 1464 | `_connect_ui_queue_signals` | `other` |
| 1473 | `_abort_sanity` | `diagnostics` |
| 1478 | `_refresh_sanity_ui_root` | `diagnostics` |
| 1490 | `_ensure_flow_panel` | `other` |
| 1500 | `_fail_flow` | `other` |
| 1507 | `request_new_game` | `request_api` |
| 1512 | `_guard_request_phase` | `request_api` |
| 1520 | `_require_phase` | `phase_flow` |
| 1526 | `_guard_phase` | `phase_flow` |
| 1541 | `_flow_snapshot` | `other` |
| 1553 | `request_confirm_pact` | `betting_pacts` |
| 1563 | `request_choose_mid` | `request_api` |
| 1575 | `request_push_your_luck` | `request_api` |
| 1581 | `request_take_payout` | `request_api` |
| 1587 | `request_quit_to_menu` | `request_api` |
| 1591 | `request_load_continue` | `request_api` |
| 1604 | `start_new_run` | `run_end` |
| 1607 | `_start_new_run` | `run_end` |
| 1616 | `start_run` | `run_end` |
| 1619 | `_start_level3_run` | `other` |
| 1725 | `start_arena` | `arena_enemy_runtime` |
| 1738 | `select_bet` | `betting_pacts` |
| 1744 | `_confirm_pact_with_bet_id` | `betting_pacts` |
| 1783 | `_start_pact_sealed_ritual` | `betting_pacts` |
| 1799 | `_start_resolve_ritual` | `other` |
| 1824 | `_resolve_ritual_outcome` | `other` |
| 1867 | `_apply_resolution_advance_state` | `other` |
| 1909 | `resolve_arena` | `arena_enemy_runtime` |
| 1913 | `_enter_resolution` | `phase_flow` |
| 1924 | `apply_scar` | `scar_register_corruption` |
| 1927 | `_play_arena_resolution_fx` | `arena_enemy_runtime` |
| 1947 | `end_run` | `run_end` |
| 1956 | `start_next_bet_round` | `betting_pacts` |
| 1959 | `reset_run` | `run_end` |
| 1965 | `_open_bet_ui` | `betting_pacts` |
| 1968 | `_open_level3_bet_ui` | `betting_pacts` |
| 1986 | `_build_level3_bet_offer` | `betting_pacts` |
| 2014 | `_get_available_level3_bets` | `betting_pacts` |
| 2037 | `_is_level3_bet_unlocked` | `betting_pacts` |
| 2043 | `_is_level3_bet_allowed` | `betting_pacts` |
| 2061 | `_get_run_seed_value` | `other` |
| 2066 | `_compute_level3_seed` | `other` |
| 2078 | `_compute_level3_offer_seed` | `other` |
| 2086 | `_initialize_scar_rng_state` | `scar_register_corruption` |
| 2095 | `_scar_roll` | `scar_register_corruption` |
| 2105 | `_apply_corruption` | `scar_register_corruption` |
| 2113 | `_total_passive_scar_count` | `scar_register_corruption` |
| 2116 | `_double_scar_base_chance` | `scar_register_corruption` |
| 2120 | `_try_apply_double_scar_pool` | `scar_register_corruption` |
| 2134 | `_try_apply_pact_scar_pool` | `betting_pacts` |
| 2144 | `_compute_volatility_shift` | `other` |
| 2154 | `_emit_run_debug_state` | `diagnostics` |
| 2161 | `_apply_glory_on_success` | `other` |
| 2167 | `_update_glory_multiplier_from_doubles` | `other` |
| 2172 | `_autosave_run_checkpoint` | `save_continue` |
| 2186 | `_apply_run_save_payload` | `save_continue` |
| 2251 | `_reject_invalid_continue_payload` | `save_continue` |
| 2260 | `_resume_run_from_save` | `save_continue` |
| 2282 | `_serialize_stringname_array` | `other` |
| 2291 | `_serialize_run_scars` | `scar_register_corruption` |
| 2297 | `_parse_run_scars` | `scar_register_corruption` |
| 2304 | `_serialize_scars_detail` | `scar_register_corruption` |
| 2313 | `_apply_scars_detail` | `scar_register_corruption` |
| 2324 | `_parse_pacts_log` | `betting_pacts` |
| 2341 | `_emit_escalation_changed` | `other` |
| 2346 | `_get_current_arena_index` | `arena_enemy_runtime` |
| 2352 | `_get_available_arena_theme_ids` | `arena_enemy_runtime` |
| 2357 | `_pick_next_arena_theme` | `arena_enemy_runtime` |
| 2362 | `_emit_arena_theme_changed` | `arena_enemy_runtime` |
| 2376 | `_append_pact_log_entry` | `betting_pacts` |
| 2386 | `_update_last_pact_outcome` | `betting_pacts` |
| 2396 | `_pick_special_arena_index` | `arena_enemy_runtime` |
| 2399 | `_maybe_activate_special_arena` | `arena_enemy_runtime` |
| 2409 | `_emit_special_arena_started` | `arena_enemy_runtime` |
| 2422 | `_get_special_arena_title` | `arena_enemy_runtime` |
| 2425 | `_get_special_arena_description` | `arena_enemy_runtime` |
| 2428 | `_apply_special_arena_pre_resolution` | `arena_enemy_runtime` |
| 2442 | `_apply_special_arena_post_resolution` | `arena_enemy_runtime` |
| 2455 | `_apply_special_arena_ash_reward` | `arena_enemy_runtime` |
| 2466 | `_pick_special_arena_scar` | `arena_enemy_runtime` |
| 2473 | `_select_enemy_profile` | `arena_enemy_runtime` |
| 2493 | `_weighted_pick_enemy_index` | `arena_enemy_runtime` |
| 2511 | `_compute_level3_enemy_seed` | `arena_enemy_runtime` |
| 2518 | `_log_level3_arena_result` | `arena_enemy_runtime` |
| 2539 | `_get_active_scar_ids` | `scar_register_corruption` |
| 2547 | `_resolve_level3_arena` | `arena_enemy_runtime` |
| 2571 | `_get_level3_bet_behavior` | `betting_pacts` |
| 2575 | `_handle_level3_win` | `other` |
| 2582 | `_handle_level3_loss` | `other` |
| 2628 | `_handle_level3_loss_ritual` | `other` |
| 2674 | `_apply_level3_reward` | `other` |
| 2684 | `_apply_level3_scar` | `scar_register_corruption` |
| 2704 | `_get_scar_def` | `scar_register_corruption` |
| 2707 | `_ensure_arena_and_player` | `arena_enemy_runtime` |
| 2710 | `_ensure_input_map` | `other` |
| 2734 | `_apply_phase_result` | `phase_flow` |
| 2742 | `_mut_pyl_cashout` | `other` |
| 2745 | `_mut_pyl_double` | `other` |
| 2748 | `_mut_pyl_condanna` | `other` |
| 2751 | `_mut_betp_place_bet` | `betting_pacts` |
| 2759 | `_mut_intro_select_bet` | `betting_pacts` |
| 2765 | `_mut_intro_confirm` | `other` |
| 2768 | `_mut_intm_select` | `other` |
| 2774 | `_mut_resolution_advance` | `other` |
| 2777 | `_mut_gameover_show_menu` | `other` |
| 2780 | `_mut_gameover_restart` | `other` |
| 2783 | `_mut_mainmenu_new_run` | `other` |
| 2787 | `_mut_mainmenu_continue_run` | `save_continue` |
| 2790 | `_mut_mainmenu_show_menu` | `other` |
| 2794 | `_apply_state_mutation` | `other` |
| 2797 | `_build_flow_executor_hooks` | `other` |
| 2806 | `_apply_state_mutation_step` | `other` |
| 2809 | `_autosave_run_checkpoint_from_executor` | `save_continue` |
| 2812 | `_clear_run_from_executor` | `other` |
| 2815 | `_report_mutation_executor_error` | `other` |
| 2818 | `_debug_bet_choice_received` | `betting_pacts` |
| 2821 | `_debug_show_main_menu_received` | `diagnostics` |
| 2824 | `_end_run_from_pyl` | `run_end` |
| 2829 | `_apply_mutation_plan` | `other` |
| 2832 | `_route_guarded_phase_request` | `phase_flow` |
| 2858 | `_dispatch_phase_request` | `phase_flow` |
| 2873 | `_on_request_new_run` | `request_api` |
| 2877 | `_on_request_reset_run` | `request_api` |
| 2882 | `_on_request_retry_run` | `request_api` |
| 2887 | `_on_request_continue_run` | `request_api` |
| 2891 | `_on_request_show_main_menu` | `request_api` |
| 2895 | `_on_request_intro_apply_seed` | `request_api` |
| 2912 | `_on_request_intro_select_bet` | `betting_pacts` |
| 2917 | `_apply_intro_select_bet_request` | `betting_pacts` |
| 2937 | `_on_request_intro_confirm` | `request_api` |
| 2942 | `_on_request_mid_choice_select` | `request_api` |
| 2948 | `_on_request_pyl_cashout` | `request_api` |
| 2954 | `_on_request_pyl_condanna` | `request_api` |
| 2960 | `_on_request_pyl_double` | `request_api` |
| 2966 | `_on_request_end_run_restart` | `request_api` |
| 2971 | `_on_request_end_run_next_bet` | `betting_pacts` |
| 2976 | `_on_request_end_run_quit` | `request_api` |
| 2981 | `_on_request_place_bet` | `betting_pacts` |
| 2985 | `_on_request_intermediate_choice` | `request_api` |
| 2998 | `_apply_intermediate_choice` | `other` |
| 3036 | `_on_post_arena_choice_selected` | `arena_enemy_runtime` |
| 3041 | `_on_request_push_luck_cashout` | `request_api` |
| 3046 | `_take_payout` | `other` |
| 3085 | `_handle_push_luck_condanna` | `other` |
| 3105 | `_on_request_push_luck_double` | `request_api` |
| 3110 | `_push_your_luck` | `other` |
| 3154 | `_on_request_set_run_seed` | `request_api` |
| 3164 | `_on_request_clear_run_seed` | `request_api` |
| 3174 | `_on_request_skip_arena_resolution` | `arena_enemy_runtime` |
| 3184 | `_debug_skip_level3_step` | `diagnostics` |
| 3193 | `_get_debug_default_bet` | `betting_pacts` |
| 3199 | `_on_modal_opened` | `other` |
| 3203 | `_on_modal_closed` | `other` |
| 3207 | `_apply_modal_lock` | `other` |
| 3226 | `_set_arena_suspended` | `arena_enemy_runtime` |
| 3238 | `add_coins` | `other` |
| 3244 | `spend_coins` | `other` |
| 3253 | `_on_bet_placed` | `betting_pacts` |
| 3256 | `_on_bet_confirmed` | `betting_pacts` |
| 3259 | `_on_bet_sealed` | `betting_pacts` |
| 3265 | `_handle_bet_sealed` | `betting_pacts` |
| 3286 | `_on_betting_opened` | `betting_pacts` |
| 3289 | `_resolve_player` | `other` |
| 3298 | `_connect_player_signals` | `other` |
| 3309 | `_on_request_fail_run` | `request_api` |
| 3321 | `_get_bet_chain_reward_scale` | `betting_pacts` |
| 3324 | `_reset_bet_chain` | `betting_pacts` |
| 3331 | `_reset_intermediate_choice_modifiers` | `other` |
| 3336 | `_consume_intermediate_choice_bonus` | `other` |
| 3341 | `_apply_intermediate_loss_penalty_if_needed` | `other` |
| 3349 | `_open_intermediate_choice` | `other` |
| 3353 | `_enter_mid_choice` | `phase_flow` |
| 3358 | `_open_push_luck_choice` | `other` |
| 3361 | `_enter_push_your_luck` | `phase_flow` |
| 3365 | `_refresh_push_luck_choice` | `other` |
| 3368 | `_build_intermediate_choice_ui_payload` | `save_continue` |
| 3380 | `_build_push_luck_ui_payload` | `save_continue` |
| 3398 | `_emit_ui` | `other` |
| 3411 | `_build_phase_ui_payload` | `phase_flow` |
| 3418 | `_build_push_luck_payload` | `save_continue` |
| 3446 | `_emit_sentence_banner_for_bet` | `betting_pacts` |
| 3454 | `_build_sentence_payload` | `save_continue` |
| 3465 | `_get_sentence_rule` | `other` |
| 3477 | `_get_sentence_doom` | `other` |
| 3493 | `[removed_post_bet_queue_step]` | `other` |
| 3497 | `_enter_first_reaction` | `phase_flow` |
| 3514 | `[removed_post_bet_queue_callback]` | `arena_enemy_runtime` |
| 3521 | `_force_post_bet_choice_fallback` | `betting_pacts` |
| 3531 | `_get_cashout_lock_reason` | `other` |
| 3542 | `_get_double_lock_reason` | `other` |
| 3549 | `_update_audience_after_arena` | `audience` |
| 3565 | `_check_audience_condanne` | `audience` |
| 3571 | `_get_audience_context_mood` | `audience` |
| 3578 | `_pick_audience_context_line` | `audience` |
| 3598 | `_emit_audience_context_line` | `audience` |
| 3607 | `_close_audience_context_line` | `audience` |
| 3612 | `_get_audience_cashout_modifier` | `audience` |
| 3616 | `_build_audience_reward_text` | `audience` |
| 3629 | `_apply_bet_reward_scaled` | `betting_pacts` |
| 3642 | `_apply_pure_bet_reward_scaled` | `betting_pacts` |
| 3645 | `_build_bet_pact_text` | `betting_pacts` |
| 3654 | `_build_bet_doom_text` | `betting_pacts` |
| 3665 | `_get_bet_data` | `betting_pacts` |
| 3672 | `_get_level3_bet_name` | `betting_pacts` |
| 3679 | `_get_level3_doom_short` | `other` |
| 3695 | `_apply_double_or_die_reward_scaled` | `other` |
| 3698 | `retry_current_bet` | `betting_pacts` |
| 3711 | `_enter_end_run` | `phase_flow` |
| 3723 | `_enter_game_over` | `phase_flow` |
| 3768 | `_emit_run_failed` | `run_end` |
| 3776 | `_emit_run_ended` | `run_end` |
| 3795 | `_register_run_end` | `scar_register_corruption` |
| 3801 | `_emit_run_finale` | `run_end` |
| 3818 | `_log_balance_terminal_metrics` | `diagnostics` |
| 3835 | `_should_emit_registry_silence` | `other` |
| 3847 | `_emit_run_log` | `diagnostics` |
| 3853 | `_build_run_log` | `diagnostics` |
| 3876 | `_export_run_summary` | `other` |
| 3887 | `_build_run_summary` | `other` |
| 3890 | `_build_game_over_stats_payload` | `run_end` |
| 3900 | `_build_game_over_anomaly_flow_tag` | `run_end` |
| 3913 | `_build_game_over_finale_inputs` | `run_end` |
| 3932 | `_build_game_over_copy_inputs` | `run_end` |
| 3938 | `_select_run_finale` | `run_end` |
| 4003 | `_update_hidden_run_metrics` | `other` |
| 4020 | `_is_high_risk_behavior` | `other` |
| 4023 | `_register_pact_corruption` | `betting_pacts` |
| 4036 | `_count_scars_with_tag` | `scar_register_corruption` |
| 4046 | `get_available_level3_pacts` | `betting_pacts` |
| 4057 | `get_level3_pact_title` | `betting_pacts` |
| 4065 | `get_level3_pact_reveal_text` | `betting_pacts` |
| 4068 | `get_pact_reveal_line` | `betting_pacts` |
| 4073 | `get_available_arena_themes` | `arena_enemy_runtime` |
| 4076 | `is_harsh_crowd_unlocked` | `other` |
| 4079 | `get_crowd_line_count_base` | `other` |
| 4082 | `get_crowd_line_count_harsh` | `other` |
| 4085 | `_count_crowd_lines` | `other` |
| 4094 | `get_arena` | `arena_enemy_runtime` |
| 4097 | `get_arena_index` | `arena_enemy_runtime` |
| 4100 | `is_live` | `other` |
| 4103 | `is_level3_mode` | `other` |
| 4106 | `is_visual_only` | `other` |
| 4109 | `get_debug_phase_name` | `phase_flow` |
| 4112 | `get_debug_last_request` | `diagnostics` |
| 4115 | `get_debug_last_ui_render_ms` | `diagnostics` |
| 4118 | `get_debug_flow_tail` | `diagnostics` |
| 4121 | `_set_phase` | `phase_flow` |
| 4141 | `_touch_request_activity` | `request_api` |
| 4145 | `_watchdog_stall_hint` | `other` |
| 4155 | `_watchdog_tick` | `other` |
| 4168 | `_has_enter_phase_handler` | `phase_flow` |
| 4175 | `_run_enter_phase` | `phase_flow` |
| 4210 | `_enter_main_menu` | `phase_flow` |
| 4213 | `_enter_intro` | `phase_flow` |
| 4219 | `_enter_bet_present` | `betting_pacts` |
| 4229 | `_enter_bet_committed` | `betting_pacts` |
| 4232 | `_enter_next_bet` | `betting_pacts` |
| 4235 | `_enter_end_run_phase` | `phase_flow` |
| 4238 | `set_phase` | `phase_flow` |
| 4245 | `_set_runtime_gate_phase` | `phase_flow` |
| 4250 | `_apply_phase` | `phase_flow` |
| 4255 | `_update_arena_visual_only` | `arena_enemy_runtime` |
| 4266 | `_reset_upgrades` | `other` |
| 4269 | `_register_condanna` | `scar_register_corruption` |
| 4280 | `_is_unlocked` | `other` |
| 4283 | `_reset_scars` | `scar_register_corruption` |
| 4287 | `_emit_scars_updated` | `scar_register_corruption` |
| 4291 | `_has_scar` | `scar_register_corruption` |
| 4297 | `_add_scar` | `scar_register_corruption` |
| 4319 | `_emit_register_annotation_from_scar` | `scar_register_corruption` |
| 4327 | `_emit_register_annotation_from_run_end` | `scar_register_corruption` |
| 4335 | `_build_register_metrics` | `scar_register_corruption` |
| 4351 | `_build_run_scar` | `scar_register_corruption` |
| 4360 | `_register_run_scar` | `scar_register_corruption` |
| 4374 | `_try_register_refused_closure_scar` | `scar_register_corruption` |
| 4388 | `_try_register_risk_threshold_scar` | `scar_register_corruption` |
| 4402 | `_recompute_scar_modifiers` | `scar_register_corruption` |
| 4405 | `_recompute_scar_synergies` | `scar_register_corruption` |
| 4410 | `_get_bet_display_name` | `betting_pacts` |
| 4416 | `_try_apply_open_wound_scar` | `scar_register_corruption` |
| 4435 | `_try_apply_cracked_bones_scar` | `scar_register_corruption` |
| 4455 | `_log_runtime_state` | `diagnostics` |
