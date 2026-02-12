# RunManager Function Inventory Report

- Scope: `scripts/systems/run_manager.gd` (read-only audit).
- Total functions: **303**.
- Signals defined in RunManager: **0**.
- GameEvents connections in `_connect_gameevents()`: **34**.

## Summary

- Inventario completo delle funzioni con firma, linea, visibilità, chiamanti interni (quando rilevabili).
- Classificazione one-tag per responsabilità operativa (FLOW/UI/BET/SCAR/SAVE/etc.).
- Mappa dei collegamenti `GameEvents.<signal> -> handler` effettuati dal RunManager.
- Lista prioritaria di candidati di ottimizzazione/legacy senza modifiche runtime.

## Signals defined in RunManager

- Nessun `signal` dichiarato direttamente in `run_manager.gd`.

## GameEvents connections (`signal -> handler`)

| Signal | Handler | Line |
|---|---|---:|
| `bet_placed` | `_on_bet_placed` | 1207 |
| `bet_sealed` | `_on_bet_sealed` | 1210 |
| `bet_confirmed` | `_on_bet_confirmed` | 1213 |
| `request_place_bet` | `_on_request_place_bet` | 1216 |
| `betting_opened` | `_on_betting_opened` | 1219 |
| `run_failed` | `_on_run_failed` | 1222 |
| `enemy_killed` | `_on_enemy_killed` | 1225 |
| `request_new_run` | `_on_request_new_run` | 1228 |
| `request_push_luck_cashout` | `_on_request_push_luck_cashout` | 1231 |
| `request_push_luck_double` | `_on_request_push_luck_double` | 1234 |
| `post_arena_choice_selected` | `_on_post_arena_choice_selected` | 1237 |
| `request_intermediate_choice` | `_on_request_intermediate_choice` | 1240 |
| `request_intro_apply_seed` | `_on_request_intro_apply_seed` | 1243 |
| `request_intro_select_bet` | `_on_request_intro_select_bet` | 1246 |
| `request_intro_confirm` | `_on_request_intro_confirm` | 1249 |
| `request_intro_buy_token` | `_on_request_intro_buy_token` | 1252 |
| `request_mid_choice_select` | `_on_request_mid_choice_select` | 1255 |
| `request_pyl_cashout` | `_on_request_pyl_cashout` | 1258 |
| `request_pyl_condanna` | `_on_request_pyl_condanna` | 1261 |
| `request_pyl_double` | `_on_request_pyl_double` | 1264 |
| `request_end_run_restart` | `_on_request_end_run_restart` | 1267 |
| `request_end_run_next_bet` | `_on_request_end_run_next_bet` | 1270 |
| `request_end_run_quit` | `_on_request_end_run_quit` | 1273 |
| `request_reset_run` | `_on_request_reset_run` | 1276 |
| `request_retry_run` | `_on_request_retry_run` | 1279 |
| `request_continue_run` | `_on_request_continue_run` | 1282 |
| `request_show_main_menu` | `_on_request_show_main_menu` | 1285 |
| `request_fail_run` | `_on_request_fail_run` | 1288 |
| `request_set_run_seed` | `_on_request_set_run_seed` | 1291 |
| `request_clear_run_seed` | `_on_request_clear_run_seed` | 1294 |
| `request_skip_arena_resolution` | `_on_request_skip_arena_resolution` | 1297 |
| `modal_opened` | `_on_modal_opened` | 1300 |
| `modal_closed` | `_on_modal_closed` | 1303 |
| `settings_changed` | `_on_settings_changed` | 1306 |

## Inventory table

| Function | Signature | Line | Visibility | Called by (internal, up to 3) | Category |
|---|---|---:|---|---|---|
| `_flow_log` | `func _flow_log(tag: String, details: String = "") -> void:` | 192 | private | `_start_level3_run`, `_start_pact_sealed_ritual`, `_start_resolve_ritual` | `DEBUG_GUARDS` |
| `to_dict` | `func to_dict() -> Dictionary:` | 402 | public | `to_dict`, `_build_run_save_payload`, `_serialize_run_scars` | `DATA_TRANSFORM` |
| `to_dict` | `func to_dict() -> Dictionary:` | 417 | public | `to_dict`, `_build_run_save_payload`, `_serialize_run_scars` | `DATA_TRANSFORM` |
| `_update_flow_phase` | `func _update_flow_phase(metrics: Dictionary) -> void:` | 457 | private | `record_scar_annotation`, `record_run_end_annotation` | `PHASE_HELPER` |
| `record_scar_annotation` | `func record_scar_annotation(scar_id: StringName, _arena_index: int, metrics: Dictionary) -> Dictionary:` | 499 | public | `_emit_register_annotation_from_scar` | `SCAR_LOGIC` |
| `record_run_end_annotation` | `func record_run_end_annotation(reason: String, scar_count: int, metrics: Dictionary) -> Dictionary:` | 525 | public | `_emit_register_annotation_from_run_end` | `DATA_TRANSFORM` |
| `to_text` | `func to_text() -> String:` | 563 | public | `_select_run_finale` | `DATA_TRANSFORM` |
| `to_dict` | `func to_dict() -> Dictionary:` | 572 | public | `to_dict`, `_build_run_save_payload`, `_serialize_run_scars` | `DATA_TRANSFORM` |
| `_ready` | `func _ready() -> void:` | 1189 | private | unknown | `FLOW_AUTHORITY` |
| `_connect_gameevents` | `func _connect_gameevents() -> void:` | 1200 | private | `_ready` | `UI_WIRING` |
| `_apply_saved_language` | `func _apply_saved_language() -> void:` | 1308 | private | `_ready` | `SAVE_LOAD` |
| `_apply_language` | `func _apply_language(locale: String) -> void:` | 1312 | private | `_apply_saved_language`, `_on_settings_changed` | `LOCALIZATION` |
| `_on_settings_changed` | `func _on_settings_changed(payload: Dictionary) -> void:` | 1318 | private | unknown | `LOCALIZATION` |
| `_boot` | `func _boot() -> void:` | 1324 | private | unknown | `FLOW_AUTHORITY` |
| `_validate_game_events_signals` | `func _validate_game_events_signals() -> bool:` | 1355 | private | `_ready` | `DEBUG_GUARDS` |
| `_validate_boot` | `func _validate_boot() -> bool:` | 1389 | private | `_boot` | `FLOW_AUTHORITY` |
| `_connect_ui_queue_signals` | `func _connect_ui_queue_signals() -> void:` | 1424 | private | `_boot` | `UI_WIRING` |
| `_abort_sanity` | `func _abort_sanity(message: String) -> void:` | 1433 | private | `_validate_game_events_signals`, `_validate_boot` | `DEBUG_GUARDS` |
| `_refresh_sanity_ui_root` | `func _refresh_sanity_ui_root() -> void:` | 1438 | private | `_ensure_flow_panel`, `_emit_ui`, `_enter_game_over` | `UI_WIRING` |
| `_ensure_flow_panel` | `func _ensure_flow_panel(path: String, context: String) -> bool:` | 1450 | private | `_start_resolve_ritual`, `_enter_mid_choice`, `_enter_push_your_luck` | `UI_WIRING` |
| `_fail_flow` | `func _fail_flow(message: String) -> void:` | 1460 | private | `_ensure_flow_panel` | `FLOW_AUTHORITY` |
| `request_new_game` | `func request_new_game() -> void:` | 1467 | public | `start_new_run`, `start_run`, `_on_request_new_run` | `FLOW_AUTHORITY` |
| `_guard_request_phase` | `func _guard_request_phase(request_name: String, allowed_phases: Array[RunPhase]) -> bool:` | 1472 | private | `_on_request_new_run`, `_on_request_reset_run`, `_on_request_retry_run` | `FLOW_AUTHORITY` |
| `request_confirm_pact` | `func request_confirm_pact() -> void:` | 1479 | public | `_on_request_intro_confirm` | `FLOW_AUTHORITY` |
| `request_choose_mid` | `func request_choose_mid(index: int) -> void:` | 1489 | public | `_on_request_mid_choice_select`, `_on_request_intermediate_choice` | `FLOW_AUTHORITY` |
| `request_push_your_luck` | `func request_push_your_luck() -> void:` | 1501 | public | `_on_request_pyl_double`, `_on_request_push_luck_double` | `FLOW_AUTHORITY` |
| `request_take_payout` | `func request_take_payout() -> void:` | 1507 | public | `_on_request_pyl_cashout`, `_on_request_push_luck_cashout` | `FLOW_AUTHORITY` |
| `request_quit_to_menu` | `func request_quit_to_menu() -> void:` | 1513 | public | `_on_request_show_main_menu`, `_on_request_end_run_quit` | `FLOW_AUTHORITY` |
| `request_load_continue` | `func request_load_continue() -> void:` | 1517 | public | `_on_request_continue_run` | `FLOW_AUTHORITY` |
| `start_new_run` | `func start_new_run() -> void:` | 1529 | public | `_boot`, `reset_run`, `restart_run` | `FLOW_AUTHORITY` |
| `_start_new_run` | `func _start_new_run() -> void:` | 1532 | private | `request_new_game` | `FLOW_AUTHORITY` |
| `start_run` | `func start_run() -> void:` | 1624 | public | unknown | `FLOW_AUTHORITY` |
| `_start_level3_run` | `func _start_level3_run() -> void:` | 1627 | private | `_start_new_run`, `_on_request_retry_run`, `_on_request_end_run_next_bet` | `FLOW_AUTHORITY` |
| `start_arena` | `func start_arena() -> void:` | 1727 | public | `_start_level3_run`, `start_next_bet_round`, `_handle_level3_loss` | `FLOW_AUTHORITY` |
| `select_bet` | `func select_bet(bet_id: StringName) -> void:` | 1745 | public | `_on_request_place_bet`, `_debug_skip_level3_step` | `BET_LOGIC` |
| `_confirm_pact_with_bet_id` | `func _confirm_pact_with_bet_id(bet_id: StringName) -> void:` | 1751 | private | `request_confirm_pact`, `select_bet` | `BET_LOGIC` |
| `_register_level3_bet_choice` | `func _register_level3_bet_choice(bet_id: StringName) -> void:` | 1789 | private | unknown | `BET_LOGIC` |
| `_start_pact_sealed_ritual` | `func _start_pact_sealed_ritual(bet_id: StringName) -> void:` | 1816 | private | `_resume_run_from_save` | `BET_LOGIC` |
| `_start_resolve_ritual` | `func _start_resolve_ritual(bet_id: StringName) -> void:` | 1832 | private | `_start_pact_sealed_ritual` | `FLOW_AUTHORITY` |
| `_resolve_ritual_outcome` | `func _resolve_ritual_outcome(bet_id: StringName) -> void:` | 1857 | private | `_start_resolve_ritual` | `FLOW_AUTHORITY` |
| `resolve_arena` | `func resolve_arena() -> void:` | 1910 | public | `_confirm_pact_with_bet_id` | `FLOW_AUTHORITY` |
| `_enter_resolution` | `func _enter_resolution() -> void:` | 1914 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `apply_scar` | `func apply_scar(scar_id: StringName) -> void:` | 1969 | public | unknown | `SCAR_LOGIC` |
| `_play_arena_resolution_fx` | `func _play_arena_resolution_fx() -> void:` | 1972 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `UI_WIRING` |
| `end_run` | `func end_run(ending_id: StringName) -> void:` | 1992 | public | `_handle_level3_loss`, `_handle_level3_loss_ritual`, `_take_payout` | `FLOW_AUTHORITY` |
| `start_next_bet_round` | `func start_next_bet_round() -> void:` | 2001 | public | unknown | `BET_LOGIC` |
| `reset_run` | `func reset_run() -> void:` | 2017 | public | unknown | `FLOW_AUTHORITY` |
| `restart_run` | `func restart_run(preserve_coins: bool = true) -> void:` | 2023 | public | unknown | `FLOW_AUTHORITY` |
| `_open_bet_ui` | `func _open_bet_ui(_from_victory: bool = false) -> void:` | 2032 | private | `_start_new_run`, `_resume_run_from_save`, `_take_payout` | `UI_WIRING` |
| `_open_level3_bet_ui` | `func _open_level3_bet_ui() -> void:` | 2047 | private | `_start_level3_run`, `start_arena`, `_open_bet_ui` | `UI_WIRING` |
| `_build_level3_bet_offer` | `func _build_level3_bet_offer() -> Array[Dictionary]:` | 2063 | private | `_open_level3_bet_ui` | `UI_WIRING` |
| `_get_available_level3_bets` | `func _get_available_level3_bets() -> Array[Dictionary]:` | 2078 | private | `_build_level3_bet_offer` | `BET_LOGIC` |
| `_is_level3_bet_unlocked` | `func _is_level3_bet_unlocked(bet_id: StringName) -> bool:` | 2101 | private | `_is_level3_bet_allowed`, `get_available_level3_pacts` | `BET_LOGIC` |
| `_is_level3_bet_allowed` | `func _is_level3_bet_allowed(bet: Dictionary) -> bool:` | 2108 | private | `_get_available_level3_bets` | `BET_LOGIC` |
| `_filter_recent_bets` | `func _filter_recent_bets(bets: Array[Dictionary], desired_count: int) -> Array[Dictionary]:` | 2126 | private | `_build_level3_bet_offer` | `BET_LOGIC` |
| `_pick_weighted_bets` | `func _pick_weighted_bets(bets: Array[Dictionary], desired_count: int) -> Array[Dictionary]:` | 2145 | private | `_build_level3_bet_offer` | `BET_LOGIC` |
| `_weighted_pick_index` | `func _weighted_pick_index(pool: Array[Dictionary]) -> int:` | 2159 | private | `_pick_weighted_bets` | `RNG_HELPER` |
| `_get_run_seed_value` | `func _get_run_seed_value() -> int:` | 2177 | private | `_start_level3_run` | `RNG_HELPER` |
| `_compute_level3_seed` | `func _compute_level3_seed(bet_id: StringName) -> int:` | 2182 | private | `_resolve_level3_arena` | `RNG_HELPER` |
| `_compute_level3_offer_seed` | `func _compute_level3_offer_seed() -> int:` | 2194 | private | `_build_level3_bet_offer` | `RNG_HELPER` |
| `_emit_run_debug_state` | `func _emit_run_debug_state() -> void:` | 2202 | private | `_start_level3_run`, `start_arena`, `_confirm_pact_with_bet_id` | `DEBUG_GUARDS` |
| `_autosave_run_checkpoint` | `func _autosave_run_checkpoint(flow_step: StringName, bet_id: StringName) -> void:` | 2219 | private | `_confirm_pact_with_bet_id`, `_resolve_ritual_outcome`, `_enter_resolution` | `SAVE_LOAD` |
| `_build_run_save_payload` | `func _build_run_save_payload() -> Dictionary:` | 2226 | private | `_autosave_run_checkpoint` | `UI_WIRING` |
| `_apply_run_save_payload` | `func _apply_run_save_payload(payload: Dictionary) -> bool:` | 2257 | private | `request_load_continue` | `UI_WIRING` |
| `_resume_run_from_save` | `func _resume_run_from_save(flow_step: StringName, bet_id: StringName) -> void:` | 2333 | private | `request_load_continue` | `SAVE_LOAD` |
| `_serialize_stringname_array` | `func _serialize_stringname_array(items: Array) -> Array[String]:` | 2358 | private | `_emit_run_debug_state` | `SAVE_LOAD` |
| `_serialize_run_scars` | `func _serialize_run_scars(items: Array[Scar]) -> Array[Dictionary]:` | 2367 | private | `_build_run_save_payload` | `SCAR_LOGIC` |
| `_parse_stringname_array` | `func _parse_stringname_array(items: Array) -> Array[StringName]:` | 2373 | private | unknown | `SAVE_LOAD` |
| `_parse_run_scars` | `func _parse_run_scars(items: Array) -> Array[Scar]:` | 2382 | private | `_apply_run_save_payload` | `SCAR_LOGIC` |
| `_serialize_scars_detail` | `func _serialize_scars_detail() -> Array[Dictionary]:` | 2394 | private | `_build_run_save_payload` | `SCAR_LOGIC` |
| `_apply_scars_detail` | `func _apply_scars_detail(details: Array) -> void:` | 2403 | private | `_apply_run_save_payload` | `SCAR_LOGIC` |
| `_parse_pacts_log` | `func _parse_pacts_log(values: Variant) -> Array[PactLogEntry]:` | 2414 | private | `_apply_run_save_payload` | `BET_LOGIC` |
| `_emit_escalation_changed` | `func _emit_escalation_changed() -> void:` | 2431 | private | `_start_level3_run`, `_apply_run_save_payload`, `_apply_special_arena_pre_resolution` | `UI_WIRING` |
| `_get_current_arena_index` | `func _get_current_arena_index() -> int:` | 2436 | private | `_pick_next_arena_theme`, `_append_pact_log_entry` | `INTERNAL_UTIL` |
| `_get_available_arena_theme_ids` | `func _get_available_arena_theme_ids() -> Array[StringName]:` | 2442 | private | `_pick_next_arena_theme`, `get_available_arena_themes` | `FLOW_AUTHORITY` |
| `_pick_next_arena_theme` | `func _pick_next_arena_theme() -> StringName:` | 2453 | private | `_emit_arena_theme_changed` | `RNG_HELPER` |
| `_emit_arena_theme_changed` | `func _emit_arena_theme_changed() -> void:` | 2459 | private | `start_arena` | `UI_WIRING` |
| `_append_pact_log_entry` | `func _append_pact_log_entry(bet_id: StringName, bet_name: String) -> void:` | 2473 | private | `_confirm_pact_with_bet_id`, `_register_level3_bet_choice`, `_on_bet_placed` | `BET_LOGIC` |
| `_update_last_pact_outcome` | `func _update_last_pact_outcome(bet_id: StringName, won: bool) -> void:` | 2483 | private | `_resolve_ritual_outcome`, `_enter_resolution`, `_on_wave_cleared` | `BET_LOGIC` |
| `_pick_special_arena_index` | `func _pick_special_arena_index(target_arenas: int) -> int:` | 2493 | private | `_start_level3_run`, `_apply_run_save_payload` | `RNG_HELPER` |
| `_maybe_activate_special_arena` | `func _maybe_activate_special_arena() -> void:` | 2501 | private | `start_arena` | `FLOW_AUTHORITY` |
| `_emit_special_arena_started` | `func _emit_special_arena_started() -> void:` | 2522 | private | `_maybe_activate_special_arena` | `UI_WIRING` |
| `_get_special_arena_title` | `func _get_special_arena_title(arena_id: StringName) -> String:` | 2535 | private | `_emit_special_arena_started`, `_build_run_log` | `LOCALIZATION` |
| `_get_special_arena_description` | `func _get_special_arena_description(arena_id: StringName) -> String:` | 2548 | private | `_emit_special_arena_started` | `LOCALIZATION` |
| `_apply_special_arena_pre_resolution` | `func _apply_special_arena_pre_resolution() -> void:` | 2561 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `FLOW_AUTHORITY` |
| `_apply_special_arena_post_resolution` | `func _apply_special_arena_post_resolution(result: ArenaResult, failed: bool) -> void:` | 2575 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `FLOW_AUTHORITY` |
| `_apply_special_arena_ash_reward` | `func _apply_special_arena_ash_reward(result: ArenaResult, failed: bool) -> void:` | 2588 | private | `_apply_special_arena_post_resolution` | `BET_LOGIC` |
| `_pick_special_arena_scar` | `func _pick_special_arena_scar() -> StringName:` | 2599 | private | `_apply_special_arena_ash_reward` | `SCAR_LOGIC` |
| `_select_enemy_profile` | `func _select_enemy_profile() -> void:` | 2606 | private | `start_arena` | `RNG_HELPER` |
| `_weighted_pick_enemy_index` | `func _weighted_pick_enemy_index(pool: Array[Dictionary]) -> int:` | 2626 | private | `_select_enemy_profile` | `RNG_HELPER` |
| `_compute_level3_enemy_seed` | `func _compute_level3_enemy_seed() -> int:` | 2644 | private | `_select_enemy_profile` | `RNG_HELPER` |
| `_get_enemy_profile_def` | `func _get_enemy_profile_def(profile_id: StringName) -> Dictionary:` | 2651 | private | unknown | `DATA_TRANSFORM` |
| `_log_level3_arena_result` | `func _log_level3_arena_result(bet_id: StringName, result: ArenaResult, scars_applied: Array[StringName]) -> void:` | 2658 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `DATA_TRANSFORM` |
| `_get_active_scar_ids` | `func _get_active_scar_ids() -> Array[StringName]:` | 2679 | private | `_resolve_level3_arena` | `SCAR_LOGIC` |
| `_resolve_level3_arena` | `func _resolve_level3_arena() -> ArenaResult:` | 2687 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `FLOW_AUTHORITY` |
| `_get_level3_bet_behavior` | `func _get_level3_bet_behavior(bet_id: StringName) -> StringName:` | 2705 | private | `_handle_level3_loss`, `_handle_level3_loss_ritual`, `_apply_level3_reward` | `BET_LOGIC` |
| `_handle_level3_win` | `func _handle_level3_win(bet_id: StringName, _result: ArenaResult) -> void:` | 2709 | private | `_enter_resolution` | `FLOW_AUTHORITY` |
| `_handle_level3_loss` | `func _handle_level3_loss(bet_id: StringName, _result: ArenaResult) -> Array[StringName]:` | 2716 | private | `_enter_resolution` | `FLOW_AUTHORITY` |
| `_handle_level3_loss_ritual` | `func _handle_level3_loss_ritual(bet_id: StringName, _result: ArenaResult) -> Array[StringName]:` | 2761 | private | `_resolve_ritual_outcome` | `FLOW_AUTHORITY` |
| `_apply_max_hp_loss` | `func _apply_max_hp_loss(amount: int) -> void:` | 2806 | private | `_handle_level3_loss`, `_handle_level3_loss_ritual` | `INTERNAL_UTIL` |
| `_apply_level3_reward` | `func _apply_level3_reward(bet_id: StringName, reward_tier: int) -> void:` | 2818 | private | `_resolve_ritual_outcome`, `_take_payout` | `BET_LOGIC` |
| `_apply_level3_scar` | `func _apply_level3_scar(scar_id: StringName, origin: String) -> void:` | 2828 | private | `apply_scar`, `_apply_special_arena_ash_reward`, `_handle_level3_loss` | `SCAR_LOGIC` |
| `_get_scar_def` | `func _get_scar_def(scar_id: StringName) -> Dictionary:` | 2848 | private | `_apply_level3_scar`, `_try_apply_open_wound_scar`, `_try_apply_cracked_bones_scar` | `SCAR_LOGIC` |
| `_determine_level3_ending_id` | `func _determine_level3_ending_id() -> StringName:` | 2851 | private | unknown | `BET_LOGIC` |
| `_ensure_arena_and_player` | `func _ensure_arena_and_player() -> void:` | 2859 | private | `_boot`, `_start_new_run`, `start_arena` | `FLOW_AUTHORITY` |
| `pick_next_arena_scene` | `func pick_next_arena_scene() -> PackedScene:` | 2907 | public | `load_next_arena` | `RNG_HELPER` |
| `_ensure_arena_layout_container` | `func _ensure_arena_layout_container() -> void:` | 2913 | private | `load_next_arena` | `UI_WIRING` |
| `_remove_default_arena_layout` | `func _remove_default_arena_layout() -> void:` | 2932 | private | `load_next_arena` | `UI_WIRING` |
| `load_next_arena` | `func load_next_arena() -> void:` | 2942 | public | `start_arena`, `_on_bet_placed`, `_handle_bet_sealed` | `FLOW_AUTHORITY` |
| `_reset_or_respawn_player_full` | `func _reset_or_respawn_player_full() -> void:` | 2966 | private | `_start_new_run`, `retry_current_bet` | `FLOW_AUTHORITY` |
| `_clear_enemies` | `func _clear_enemies() -> void:` | 3001 | private | `_start_new_run`, `start_arena`, `start_next_bet_round` | `PHASE_HELPER` |
| `_spawn_wave_or_enemies` | `func _spawn_wave_or_enemies() -> void:` | 3006 | private | `start_next_bet_round`, `_push_your_luck` | `LEGACY_SUSPECT` |
| `_ensure_input_map` | `func _ensure_input_map() -> void:` | 3013 | private | `_on_settings_changed` | `UI_WIRING` |
| `_start_next_arena` | `func _start_next_arena() -> void:` | 3049 | private | `_spawn_wave_or_enemies`, `_on_bet_placed`, `_handle_bet_sealed` | `FLOW_AUTHORITY` |
| `_on_request_new_run` | `func _on_request_new_run() -> void:` | 3062 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_reset_run` | `func _on_request_reset_run() -> void:` | 3068 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_retry_run` | `func _on_request_retry_run() -> void:` | 3074 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_continue_run` | `func _on_request_continue_run() -> void:` | 3082 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_show_main_menu` | `func _on_request_show_main_menu() -> void:` | 3085 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_intro_apply_seed` | `func _on_request_intro_apply_seed(seed_text: String) -> void:` | 3091 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_intro_select_bet` | `func _on_request_intro_select_bet(bet_id: String) -> void:` | 3108 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_intro_confirm` | `func _on_request_intro_confirm() -> void:` | 3128 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_intro_buy_token` | `func _on_request_intro_buy_token() -> void:` | 3131 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_mid_choice_select` | `func _on_request_mid_choice_select(index: int) -> void:` | 3143 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_pyl_cashout` | `func _on_request_pyl_cashout() -> void:` | 3148 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_pyl_condanna` | `func _on_request_pyl_condanna() -> void:` | 3153 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_pyl_double` | `func _on_request_pyl_double() -> void:` | 3159 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_end_run_restart` | `func _on_request_end_run_restart() -> void:` | 3164 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_end_run_next_bet` | `func _on_request_end_run_next_bet() -> void:` | 3170 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_end_run_quit` | `func _on_request_end_run_quit() -> void:` | 3179 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_place_bet` | `func _on_request_place_bet(bet_id: String, _stake: int) -> void:` | 3185 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_intermediate_choice` | `func _on_request_intermediate_choice(choice_id: String) -> void:` | 3193 | private | unknown | `FLOW_AUTHORITY` |
| `_apply_intermediate_choice` | `func _apply_intermediate_choice(choice_id: String) -> void:` | 3205 | private | `request_choose_mid` | `BET_LOGIC` |
| `_on_post_arena_choice_selected` | `func _on_post_arena_choice_selected(choice_id: StringName) -> void:` | 3243 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_push_luck_cashout` | `func _on_request_push_luck_cashout() -> void:` | 3248 | private | unknown | `FLOW_AUTHORITY` |
| `_take_payout` | `func _take_payout() -> void:` | 3253 | private | `request_take_payout` | `BET_LOGIC` |
| `_handle_push_luck_condanna` | `func _handle_push_luck_condanna() -> void:` | 3306 | private | `_on_request_pyl_condanna`, `_on_post_arena_choice_selected` | `BET_LOGIC` |
| `_on_request_push_luck_double` | `func _on_request_push_luck_double() -> void:` | 3330 | private | `_debug_skip_level3_step` | `FLOW_AUTHORITY` |
| `_push_your_luck` | `func _push_your_luck() -> void:` | 3335 | private | `request_push_your_luck` | `BET_LOGIC` |
| `_on_request_set_run_seed` | `func _on_request_set_run_seed(run_seed: int) -> void:` | 3403 | private | `_on_request_intro_apply_seed` | `FLOW_AUTHORITY` |
| `_on_request_clear_run_seed` | `func _on_request_clear_run_seed() -> void:` | 3410 | private | `_on_request_intro_apply_seed` | `FLOW_AUTHORITY` |
| `_on_request_skip_arena_resolution` | `func _on_request_skip_arena_resolution() -> void:` | 3417 | private | unknown | `FLOW_AUTHORITY` |
| `_debug_skip_level3_step` | `func _debug_skip_level3_step() -> void:` | 3431 | private | `_on_request_skip_arena_resolution` | `DEBUG_GUARDS` |
| `_get_debug_default_bet` | `func _get_debug_default_bet() -> StringName:` | 3440 | private | `_debug_skip_level3_step` | `BET_LOGIC` |
| `_on_modal_opened` | `func _on_modal_opened(_kind: String) -> void:` | 3446 | private | unknown | `UI_WIRING` |
| `_on_modal_closed` | `func _on_modal_closed(_kind: String) -> void:` | 3450 | private | unknown | `UI_WIRING` |
| `_apply_modal_lock` | `func _apply_modal_lock() -> void:` | 3454 | private | `_on_modal_opened`, `_on_modal_closed` | `UI_WIRING` |
| `_set_arena_suspended` | `func _set_arena_suspended(suspended: bool) -> void:` | 3473 | private | `_ensure_arena_and_player`, `_apply_modal_lock` | `UI_WIRING` |
| `add_coins` | `func add_coins(amount: int) -> void:` | 3485 | public | `_apply_special_arena_ash_reward`, `_apply_level3_reward`, `_on_wave_cleared` | `LEGACY_SUSPECT` |
| `spend_coins` | `func spend_coins(amount: int) -> bool:` | 3491 | public | `purchase_token`, `_apply_intermediate_loss_penalty_if_needed` | `LEGACY_SUSPECT` |
| `get_coins` | `func get_coins() -> int:` | 3500 | public | unknown | `LEGACY_SUSPECT` |
| `get_tokens` | `func get_tokens() -> int:` | 3503 | public | unknown | `LEGACY_SUSPECT` |
| `get_buy_token_cost` | `func get_buy_token_cost() -> int:` | 3506 | public | unknown | `LEGACY_SUSPECT` |
| `get_token_buy_cost` | `func get_token_buy_cost() -> int:` | 3509 | public | unknown | `LEGACY_SUSPECT` |
| `buy_token` | `func buy_token() -> bool:` | 3512 | public | unknown | `LEGACY_SUSPECT` |
| `spend_tokens` | `func spend_tokens(amount: int) -> bool:` | 3515 | public | unknown | `LEGACY_SUSPECT` |
| `purchase_token` | `func purchase_token() -> bool:` | 3525 | public | `_on_request_intro_buy_token`, `buy_token` | `LEGACY_SUSPECT` |
| `_on_bet_placed` | `func _on_bet_placed(_bet_id: String, _stake: int, _odds: float) -> void:` | 3536 | private | unknown | `BET_LOGIC` |
| `_on_bet_confirmed` | `func _on_bet_confirmed(pact_id: StringName, condition_id: StringName, sentence_id: StringName) -> void:` | 3553 | private | unknown | `BET_LOGIC` |
| `_on_bet_sealed` | `func _on_bet_sealed(bet_choice: Dictionary) -> void:` | 3556 | private | unknown | `BET_LOGIC` |
| `_handle_bet_sealed` | `func _handle_bet_sealed(pact_id: StringName, condition_id: StringName, sentence_id: StringName) -> void:` | 3562 | private | `_on_bet_confirmed`, `_on_bet_sealed` | `BET_LOGIC` |
| `_on_betting_opened` | `func _on_betting_opened() -> void:` | 3585 | private | unknown | `BET_LOGIC` |
| `_on_wave_started` | `func _on_wave_started(_wave: int) -> void:` | 3588 | private | unknown | `LEGACY_SUSPECT` |
| `_on_wave_cleared` | `func _on_wave_cleared(_wave: int) -> void:` | 3596 | private | `_on_request_skip_arena_resolution` | `LEGACY_SUSPECT` |
| `_on_player_spawned` | `func _on_player_spawned(player: Node) -> void:` | 3615 | private | unknown | `PHASE_HELPER` |
| `_on_enemy_killed` | `func _on_enemy_killed(exp_value: int) -> void:` | 3622 | private | unknown | `FLOW_AUTHORITY` |
| `_xp_needed_for_next` | `func _xp_needed_for_next(level: int) -> int:` | 3638 | private | `_check_level_up`, `_emit_xp_level_ui` | `INTERNAL_UTIL` |
| `_check_level_up` | `func _check_level_up() -> bool:` | 3650 | private | `_on_enemy_killed` | `FLOW_AUTHORITY` |
| `_emit_xp_level_ui` | `func _emit_xp_level_ui() -> void:` | 3665 | private | `_start_new_run`, `_on_enemy_killed` | `UI_WIRING` |
| `get_level` | `func get_level() -> int:` | 3676 | public | unknown | `INTERNAL_UTIL` |
| `get_difficulty_tier` | `func get_difficulty_tier() -> int:` | 3679 | public | `get_difficulty_multiplier`, `_apply_enemy_difficulty_to_arena` | `INTERNAL_UTIL` |
| `get_difficulty_multiplier` | `func get_difficulty_multiplier() -> float:` | 3682 | public | `_recompute_difficulty_tier`, `_apply_enemy_difficulty_to_arena` | `INTERNAL_UTIL` |
| `get_upgrade_tokens` | `func get_upgrade_tokens() -> int:` | 3690 | public | unknown | `LEGACY_SUSPECT` |
| `consume_upgrade_token` | `func consume_upgrade_token() -> bool:` | 3693 | public | unknown | `LEGACY_SUSPECT` |
| `_recompute_difficulty_tier` | `func _recompute_difficulty_tier(force_emit: bool) -> void:` | 3702 | private | `_on_enemy_killed`, `_reset_progression` | `FLOW_AUTHORITY` |
| `_apply_enemy_difficulty_to_arena` | `func _apply_enemy_difficulty_to_arena() -> void:` | 3715 | private | `_on_wave_started` | `FLOW_AUTHORITY` |
| `_resolve_player` | `func _resolve_player() -> Node:` | 3724 | private | `_start_new_run`, `_resolve_ritual_outcome`, `_enter_resolution` | `INTERNAL_UTIL` |
| `_connect_player_signals` | `func _connect_player_signals() -> void:` | 3755 | private | `_boot`, `_reset_or_respawn_player_full`, `_on_player_spawned` | `UI_WIRING` |
| `_on_run_failed` | `func _on_run_failed() -> void:` | 3769 | private | unknown | `FLOW_AUTHORITY` |
| `_on_request_fail_run` | `func _on_request_fail_run(reason: String = "") -> void:` | 3772 | private | `_on_run_failed` | `FLOW_AUTHORITY` |
| `_on_player_died` | `func _on_player_died() -> void:` | 3781 | private | unknown | `FLOW_AUTHORITY` |
| `_soft_reset` | `func _soft_reset() -> void:` | 3784 | private | unknown | `LEGACY_SUSPECT` |
| `handle_bet_failed` | `func handle_bet_failed(bet_id: String) -> void:` | 3792 | public | unknown | `BET_LOGIC` |
| `_apply_pure_bet_penalty` | `func _apply_pure_bet_penalty(chain_level: int) -> void:` | 3813 | private | `handle_bet_failed` | `BET_LOGIC` |
| `_get_bet_chain_doom_scale` | `func _get_bet_chain_doom_scale(chain_level: int) -> int:` | 3824 | private | `_apply_pure_bet_penalty` | `BET_LOGIC` |
| `_get_bet_chain_reward_scale` | `func _get_bet_chain_reward_scale(chain_level: int) -> int:` | 3827 | private | `_build_push_luck_payload` | `BET_LOGIC` |
| `_apply_bet_result` | `func _apply_bet_result(result: Dictionary) -> void:` | 3830 | private | unknown | `BET_LOGIC` |
| `_reset_bet_chain` | `func _reset_bet_chain() -> void:` | 3839 | private | `_start_new_run`, `_take_payout`, `_handle_push_luck_condanna` | `BET_LOGIC` |
| `_reset_intermediate_choice_modifiers` | `func _reset_intermediate_choice_modifiers() -> void:` | 3846 | private | `_push_your_luck`, `_reset_bet_chain`, `_consume_intermediate_choice_bonus` | `BET_LOGIC` |
| `_consume_intermediate_choice_bonus` | `func _consume_intermediate_choice_bonus() -> int:` | 3851 | private | `_take_payout`, `_handle_push_luck_condanna` | `LEGACY_SUSPECT` |
| `_apply_intermediate_loss_penalty_if_needed` | `func _apply_intermediate_loss_penalty_if_needed() -> void:` | 3856 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `BET_LOGIC` |
| `_open_intermediate_choice` | `func _open_intermediate_choice(bet_id: StringName) -> void:` | 3864 | private | `_resume_run_from_save`, `_enter_first_reaction`, `_on_arena_message_queue_completed` | `UI_WIRING` |
| `_enter_mid_choice` | `func _enter_mid_choice() -> void:` | 3868 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_open_push_luck_choice` | `func _open_push_luck_choice(bet_id: StringName) -> void:` | 3879 | private | `_resume_run_from_save`, `_handle_level3_win`, `_apply_intermediate_choice` | `UI_WIRING` |
| `_enter_push_your_luck` | `func _enter_push_your_luck() -> void:` | 3883 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_refresh_push_luck_choice` | `func _refresh_push_luck_choice(bet_id: StringName) -> void:` | 3896 | private | `_take_payout` | `BET_LOGIC` |
| `_build_intermediate_choice_ui_payload` | `func _build_intermediate_choice_ui_payload() -> RunUiPayload:` | 3899 | private | `_enter_mid_choice` | `UI_WIRING` |
| `_build_push_luck_ui_payload` | `func _build_push_luck_ui_payload(bet_id: StringName) -> RunUiPayload:` | 3907 | private | `_enter_push_your_luck`, `_refresh_push_luck_choice` | `UI_WIRING` |
| `_emit_ui` | `func _emit_ui(payload: RunUiPayload) -> void:` | 3917 | private | `_enter_resolution`, `_enter_mid_choice`, `_enter_push_your_luck` | `UI_WIRING` |
| `_build_phase_ui_payload` | `func _build_phase_ui_payload(target_phase: RunPhase, title: String = "", body: String = "") -> RunUiPayload:` | 3926 | private | `_enter_resolution`, `_enter_first_reaction`, `_enter_main_menu` | `UI_WIRING` |
| `_build_push_luck_payload` | `func _build_push_luck_payload(bet_id: StringName) -> Dictionary:` | 3933 | private | `_build_push_luck_ui_payload` | `UI_WIRING` |
| `_emit_sentence_banner_for_bet` | `func _emit_sentence_banner_for_bet(bet_id: StringName) -> void:` | 3985 | private | `_enter_resolution`, `_start_next_arena` | `UI_WIRING` |
| `_build_sentence_payload` | `func _build_sentence_payload(bet_id: StringName) -> Dictionary:` | 3993 | private | `_emit_sentence_banner_for_bet` | `UI_WIRING` |
| `_get_sentence_rule` | `func _get_sentence_rule(bet_id: StringName) -> String:` | 4009 | private | `_build_sentence_payload` | `BET_LOGIC` |
| `_get_sentence_doom` | `func _get_sentence_doom(bet_id: StringName) -> String:` | 4021 | private | `_build_sentence_payload` | `BET_LOGIC` |
| `_queue_push_luck_choice` | `func _queue_push_luck_choice(bet_id: StringName) -> void:` | 4044 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `UI_WIRING` |
| `_enter_first_reaction` | `func _enter_first_reaction() -> void:` | 4048 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_on_arena_message_queue_completed` | `func _on_arena_message_queue_completed() -> void:` | 4065 | private | unknown | `UI_WIRING` |
| `_force_post_bet_choice_fallback` | `func _force_post_bet_choice_fallback(sequence_id: int) -> void:` | 4072 | private | unknown | `BET_LOGIC` |
| `_get_cashout_lock_reason` | `func _get_cashout_lock_reason() -> String:` | 4082 | private | `_take_payout`, `_build_push_luck_payload` | `BET_LOGIC` |
| `_get_double_lock_reason` | `func _get_double_lock_reason() -> String:` | 4093 | private | `_push_your_luck`, `_build_push_luck_payload` | `BET_LOGIC` |
| `_update_audience_after_arena` | `func _update_audience_after_arena(result: ArenaResult) -> void:` | 4100 | private | `_resolve_ritual_outcome`, `_enter_resolution` | `UI_WIRING` |
| `_check_audience_condanne` | `func _check_audience_condanne() -> void:` | 4116 | private | `_update_audience_after_arena`, `_recompute_scar_synergies` | `UI_WIRING` |
| `_get_audience_label` | `func _get_audience_label(score: int) -> String:` | 4122 | private | `_build_push_luck_payload` | `UI_WIRING` |
| `_get_audience_reason` | `func _get_audience_reason(score: int) -> String:` | 4133 | private | `_build_push_luck_payload` | `UI_WIRING` |
| `_pick_audience_phrase` | `func _pick_audience_phrase(mood: String) -> String:` | 4140 | private | `_get_audience_reason` | `UI_WIRING` |
| `_get_audience_context_mood` | `func _get_audience_context_mood(score: int) -> StringName:` | 4149 | private | `_pick_audience_context_line` | `UI_WIRING` |
| `_pick_audience_context_line` | `func _pick_audience_context_line(context: StringName) -> String:` | 4156 | private | `_emit_audience_context_line` | `UI_WIRING` |
| `_emit_audience_context_line` | `func _emit_audience_context_line(context: StringName) -> void:` | 4176 | private | `_apply_intermediate_choice`, `_take_payout`, `_push_your_luck` | `UI_WIRING` |
| `_close_audience_context_line` | `func _close_audience_context_line() -> void:` | 4185 | private | `_start_pact_sealed_ritual`, `_enter_mid_choice`, `_enter_push_your_luck` | `UI_WIRING` |
| `_get_audience_cashout_modifier` | `func _get_audience_cashout_modifier() -> float:` | 4190 | private | `_apply_level3_reward` | `UI_WIRING` |
| `_get_audience_cashout_policy` | `func _get_audience_cashout_policy() -> Dictionary:` | 4195 | private | `_take_payout`, `_build_push_luck_payload` | `UI_WIRING` |
| `_apply_bet_reward_scaled` | `func _apply_bet_reward_scaled(bet_id: String, chain_level: int) -> void:` | 4213 | private | `_take_payout`, `_apply_bet_result` | `BET_LOGIC` |
| `_apply_pure_bet_reward_scaled` | `func _apply_pure_bet_reward_scaled(scale: int) -> void:` | 4226 | private | `_apply_bet_reward_scaled` | `BET_LOGIC` |
| `_build_bet_pact_text` | `func _build_bet_pact_text(bet_id: String, chain_level: int) -> String:` | 4236 | private | `_build_push_luck_payload` | `UI_WIRING` |
| `_build_bet_doom_text` | `func _build_bet_doom_text(bet_id: String, chain_level: int) -> String:` | 4251 | private | `_build_push_luck_payload` | `UI_WIRING` |
| `_get_bet_data` | `func _get_bet_data(bet_id: String) -> Dictionary:` | 4262 | private | `_confirm_pact_with_bet_id`, `_register_level3_bet_choice`, `_resolve_ritual_outcome` | `BET_LOGIC` |
| `_get_level3_bet_name` | `func _get_level3_bet_name(bet_id: StringName) -> String:` | 4270 | private | `_confirm_pact_with_bet_id`, `_register_level3_bet_choice`, `_start_resolve_ritual` | `BET_LOGIC` |
| `_get_level3_doom_short` | `func _get_level3_doom_short(bet_id: StringName) -> String:` | 4277 | private | `_start_resolve_ritual`, `_get_sentence_doom` | `BET_LOGIC` |
| `_apply_double_or_die_reward_scaled` | `func _apply_double_or_die_reward_scaled(scale: int) -> void:` | 4293 | private | `_apply_bet_reward_scaled` | `BET_LOGIC` |
| `retry_current_bet` | `func retry_current_bet() -> void:` | 4309 | public | `_on_request_retry_run`, `_on_request_end_run_next_bet` | `BET_LOGIC` |
| `_force_game_over_if_dead` | `func _force_game_over_if_dead() -> bool:` | 4324 | private | `start_next_bet_round`, `_open_bet_ui`, `_on_betting_opened` | `FLOW_AUTHORITY` |
| `_get_player_health_value` | `func _get_player_health_value(p: Node) -> int:` | 4334 | private | `_resolve_ritual_outcome`, `_enter_resolution`, `_push_your_luck` | `INTERNAL_UTIL` |
| `_get_player_max_health_value` | `func _get_player_max_health_value(p: Node) -> int:` | 4345 | private | `_resolve_ritual_outcome`, `_enter_resolution`, `_apply_max_hp_loss` | `INTERNAL_UTIL` |
| `_enter_end_run` | `func _enter_end_run(reason: String) -> void:` | 4356 | private | `_fail_flow`, `end_run`, `_handle_level3_loss` | `FLOW_AUTHORITY` |
| `_enter_game_over` | `func _enter_game_over() -> void:` | 4368 | private | `_enter_end_run` | `FLOW_AUTHORITY` |
| `_emit_run_failed` | `func _emit_run_failed() -> void:` | 4412 | private | `_enter_game_over` | `FLOW_AUTHORITY` |
| `_emit_run_ended` | `func _emit_run_ended() -> void:` | 4420 | private | `_enter_game_over` | `FLOW_AUTHORITY` |
| `_register_run_end` | `func _register_run_end(reason: String) -> void:` | 4439 | private | `end_run`, `_handle_level3_loss`, `_handle_level3_loss_ritual` | `FLOW_AUTHORITY` |
| `_emit_run_finale` | `func _emit_run_finale() -> void:` | 4445 | private | `_enter_game_over` | `FLOW_AUTHORITY` |
| `_should_emit_registry_silence` | `func _should_emit_registry_silence() -> bool:` | 4458 | private | `_emit_run_ended`, `_emit_run_finale` | `DEBUG_GUARDS` |
| `_emit_run_log` | `func _emit_run_log(finale: Dictionary) -> void:` | 4470 | private | `_emit_run_finale` | `DATA_TRANSFORM` |
| `_build_run_log` | `func _build_run_log(finale: Dictionary) -> String:` | 4476 | private | `_emit_run_log` | `UI_WIRING` |
| `_export_run_summary` | `func _export_run_summary(finale: Dictionary) -> void:` | 4499 | private | `_emit_run_finale` | `SAVE_LOAD` |
| `_build_run_summary` | `func _build_run_summary(finale: Dictionary) -> Dictionary:` | 4510 | private | `_emit_run_ended`, `_export_run_summary` | `UI_WIRING` |
| `_select_run_finale` | `func _select_run_finale() -> Dictionary:` | 4543 | private | `_emit_run_ended`, `_emit_run_finale` | `DATA_TRANSFORM` |
| `_build_final_report` | `func _build_final_report(ending_id: StringName) -> FinalReport:` | 4622 | private | `_select_run_finale` | `UI_WIRING` |
| `_get_final_state_label` | `func _get_final_state_label(ending_id: StringName) -> String:` | 4667 | private | `_build_final_report` | `UI_WIRING` |
| `_has_used_bet` | `func _has_used_bet(bet_id: StringName) -> bool:` | 4684 | private | unknown | `BET_LOGIC` |
| `_count_scars_with_tag` | `func _count_scars_with_tag(tag: StringName) -> int:` | 4690 | private | `_select_run_finale`, `_recompute_scar_synergies` | `SCAR_LOGIC` |
| `get_available_level3_pacts` | `func get_available_level3_pacts() -> Array[StringName]:` | 4700 | public | unknown | `BET_LOGIC` |
| `get_level3_pact_title` | `func get_level3_pact_title(pact_id: StringName) -> String:` | 4711 | public | unknown | `BET_LOGIC` |
| `get_pact_reveal_line` | `func get_pact_reveal_line(pact_id: StringName) -> String:` | 4719 | public | unknown | `BET_LOGIC` |
| `get_available_arena_themes` | `func get_available_arena_themes() -> Array[StringName]:` | 4724 | public | unknown | `FLOW_AUTHORITY` |
| `is_harsh_crowd_unlocked` | `func is_harsh_crowd_unlocked() -> bool:` | 4727 | public | unknown | `INTERNAL_UTIL` |
| `get_crowd_line_count_base` | `func get_crowd_line_count_base() -> int:` | 4730 | public | unknown | `INTERNAL_UTIL` |
| `get_crowd_line_count_harsh` | `func get_crowd_line_count_harsh() -> int:` | 4733 | public | unknown | `INTERNAL_UTIL` |
| `_count_crowd_lines` | `func _count_crowd_lines(source: Dictionary) -> int:` | 4736 | private | `get_crowd_line_count_base`, `get_crowd_line_count_harsh` | `DATA_TRANSFORM` |
| `get_arena` | `func get_arena() -> Node:` | 4745 | public | unknown | `INTERNAL_UTIL` |
| `get_arena_index` | `func get_arena_index() -> int:` | 4748 | public | unknown | `INTERNAL_UTIL` |
| `is_live` | `func is_live() -> bool:` | 4751 | public | unknown | `INTERNAL_UTIL` |
| `is_level3_mode` | `func is_level3_mode() -> bool:` | 4754 | public | unknown | `INTERNAL_UTIL` |
| `is_visual_only` | `func is_visual_only() -> bool:` | 4757 | public | `_apply_phase`, `_update_arena_visual_only` | `INTERNAL_UTIL` |
| `_set_phase` | `func _set_phase(next: RunPhase, reason: String) -> void:` | 4762 | private | `request_quit_to_menu`, `_start_new_run`, `_start_level3_run` | `FLOW_AUTHORITY` |
| `_run_enter_phase` | `func _run_enter_phase(next: RunPhase) -> bool:` | 4772 | private | `_set_phase` | `FLOW_AUTHORITY` |
| `_enter_main_menu` | `func _enter_main_menu() -> void:` | 4807 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_enter_intro` | `func _enter_intro() -> void:` | 4810 | private | `_on_request_intro_apply_seed`, `_on_request_intro_buy_token`, `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_enter_bet_present` | `func _enter_bet_present() -> void:` | 4813 | private | `_on_request_intro_apply_seed`, `_on_request_intro_select_bet`, `_on_request_intro_buy_token` | `FLOW_AUTHORITY` |
| `_enter_bet_committed` | `func _enter_bet_committed() -> void:` | 4816 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_enter_next_bet` | `func _enter_next_bet() -> void:` | 4819 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `_enter_end_run_phase` | `func _enter_end_run_phase() -> void:` | 4822 | private | `_run_enter_phase` | `FLOW_AUTHORITY` |
| `set_phase` | `func set_phase(p: Variant) -> void:` | 4825 | public | `request_quit_to_menu`, `_start_new_run`, `_start_level3_run` | `PHASE_HELPER` |
| `_apply_phase` | `func _apply_phase() -> void:` | 4834 | private | `_on_wave_started`, `_on_player_spawned`, `set_phase` | `PHASE_HELPER` |
| `_update_arena_visual_only` | `func _update_arena_visual_only() -> void:` | 4839 | private | `_start_new_run`, `_start_level3_run`, `_confirm_pact_with_bet_id` | `UI_WIRING` |
| `_position_player_after_respawn` | `func _position_player_after_respawn() -> void:` | 4850 | private | `_reset_or_respawn_player_full`, `_on_player_spawned` | `UI_WIRING` |
| `_reset_upgrades` | `func _reset_upgrades() -> void:` | 4866 | private | `_start_new_run`, `_start_level3_run` | `LEGACY_SUSPECT` |
| `_reset_upgrade_costs` | `func _reset_upgrade_costs() -> void:` | 4873 | private | `_start_new_run`, `_start_level3_run` | `LEGACY_SUSPECT` |
| `_reset_progression` | `func _reset_progression() -> void:` | 4880 | private | `_start_new_run` | `FLOW_AUTHORITY` |
| `_register_condanna` | `func _register_condanna(id: StringName) -> void:` | 4887 | private | `_start_new_run`, `_start_level3_run`, `_confirm_pact_with_bet_id` | `BET_LOGIC` |
| `_is_unlocked` | `func _is_unlocked(id: StringName) -> bool:` | 4898 | private | `_is_level3_bet_unlocked`, `_get_available_arena_theme_ids`, `_pick_audience_context_line` | `INTERNAL_UTIL` |
| `_reset_scars` | `func _reset_scars() -> void:` | 4901 | private | `_start_new_run`, `_start_level3_run` | `SCAR_LOGIC` |
| `_emit_scars_updated` | `func _emit_scars_updated() -> void:` | 4913 | private | `_apply_run_save_payload`, `_apply_scars_detail`, `_reset_scars` | `SCAR_LOGIC` |
| `_has_scar` | `func _has_scar(scar_id: StringName) -> bool:` | 4917 | private | `_is_level3_bet_allowed`, `_pick_special_arena_scar`, `_select_run_finale` | `SCAR_LOGIC` |
| `_add_scar` | `func _add_scar(scar: Dictionary) -> void:` | 4923 | private | `_apply_level3_scar`, `_try_apply_open_wound_scar`, `_try_apply_cracked_bones_scar` | `SCAR_LOGIC` |
| `_emit_register_annotation_from_scar` | `func _emit_register_annotation_from_scar(scar_id: StringName) -> void:` | 4940 | private | `_register_run_scar` | `SCAR_LOGIC` |
| `_emit_register_annotation_from_run_end` | `func _emit_register_annotation_from_run_end(reason: String) -> void:` | 4948 | private | `_emit_run_ended` | `SCAR_LOGIC` |
| `_build_register_metrics` | `func _build_register_metrics() -> Dictionary:` | 4956 | private | `_emit_register_annotation_from_scar`, `_emit_register_annotation_from_run_end` | `UI_WIRING` |
| `_build_run_scar` | `func _build_run_scar(scar_id: StringName, origin: String, trigger: StringName) -> Scar:` | 4972 | private | `_register_run_scar` | `UI_WIRING` |
| `_register_run_scar` | `func _register_run_scar(scar_id: StringName, origin: String, trigger: StringName) -> void:` | 4981 | private | `_add_scar`, `_try_register_irreversible_bet_scar`, `_try_register_refused_closure_scar` | `SCAR_LOGIC` |
| `_can_register_trigger_scar` | `func _can_register_trigger_scar() -> bool:` | 4991 | private | `_try_register_irreversible_bet_scar`, `_try_register_refused_closure_scar`, `_try_register_risk_threshold_scar` | `SCAR_LOGIC` |
| `_try_register_irreversible_bet_scar` | `func _try_register_irreversible_bet_scar(bet_id: StringName) -> void:` | 4995 | private | unknown | `BET_LOGIC` |
| `_try_register_refused_closure_scar` | `func _try_register_refused_closure_scar() -> void:` | 5005 | private | `_push_your_luck` | `SCAR_LOGIC` |
| `_try_register_risk_threshold_scar` | `func _try_register_risk_threshold_scar() -> void:` | 5015 | private | `_apply_special_arena_pre_resolution`, `_push_your_luck` | `SCAR_LOGIC` |
| `_recompute_scar_modifiers` | `func _recompute_scar_modifiers() -> void:` | 5025 | private | `_add_scar` | `SCAR_LOGIC` |
| `_recompute_scar_synergies` | `func _recompute_scar_synergies() -> void:` | 5038 | private | `_add_scar` | `SCAR_LOGIC` |
| `_get_bet_display_name` | `func _get_bet_display_name(bet_id: String) -> String:` | 5046 | private | `_select_run_finale`, `_try_apply_open_wound_scar`, `_try_apply_cracked_bones_scar` | `BET_LOGIC` |
| `_try_apply_open_wound_scar` | `func _try_apply_open_wound_scar(chain_level: int) -> void:` | 5052 | private | `_apply_pure_bet_penalty` | `UI_WIRING` |
| `_try_apply_cracked_bones_scar` | `func _try_apply_cracked_bones_scar(bet_id: String, chain_level: int) -> void:` | 5068 | private | `_push_your_luck` | `SCAR_LOGIC` |
| `_apply_run_upgrades_to_player` | `func _apply_run_upgrades_to_player() -> void:` | 5086 | private | `_apply_max_hp_loss`, `_reset_or_respawn_player_full`, `_on_player_spawned` | `LEGACY_SUSPECT` |
| `_apply_scar_modifiers_to_player` | `func _apply_scar_modifiers_to_player() -> void:` | 5102 | private | `_apply_run_upgrades_to_player` | `SCAR_LOGIC` |
| `_get_spawn_position` | `func _get_spawn_position() -> Vector2:` | 5115 | private | `_position_player_after_respawn` | `INTERNAL_UTIL` |
| `_find_spawn_node` | `func _find_spawn_node(root: Node) -> Node:` | 5124 | private | `_get_spawn_position` | `INTERNAL_UTIL` |
| `_log_runtime_state` | `func _log_runtime_state(tag: String) -> void:` | 5136 | private | `_boot`, `_start_new_run` | `DEBUG_GUARDS` |

## Category breakdown

| Category | Count |
|---|---:|
| `FLOW_AUTHORITY` | 87 |
| `UI_WIRING` | 55 |
| `BET_LOGIC` | 55 |
| `SCAR_LOGIC` | 25 |
| `SAVE_LOAD` | 6 |
| `LOCALIZATION` | 4 |
| `DEBUG_GUARDS` | 7 |
| `LEGACY_SUSPECT` | 19 |
| `INTERNAL_UTIL` | 20 |
| `DATA_TRANSFORM` | 10 |
| `RNG_HELPER` | 10 |
| `PHASE_HELPER` | 5 |

## Category Drift Summary

| Category | Count |
|---|---:|
| `FLOW_AUTHORITY` | 87 |
| `UI_WIRING` | 55 |
| `BET_LOGIC` | 55 |
| `SCAR_LOGIC` | 25 |
| `SAVE_LOAD` | 6 |
| `LOCALIZATION` | 4 |
| `DEBUG_GUARDS` | 7 |
| `LEGACY_SUSPECT` | 19 |
| `INTERNAL_UTIL` | 20 |
| `DATA_TRANSFORM` | 10 |
| `RNG_HELPER` | 10 |
| `PHASE_HELPER` | 5 |

## Top 10 largest functions (>80 lines)

1. `_flow_log` (L192, ~997 lines)
2. `_connect_gameevents` (L1200, ~108 lines)
3. `_start_level3_run` (L1627, ~100 lines)
4. `_start_new_run` (L1532, ~92 lines)

## Top 10 most internally referenced functions

1. `_register_condanna` (L4854, ~27 internal references)
2. `_update_arena_visual_only` (L4806, ~23 internal references)
3. `set_phase` (L4792, ~19 internal references)
4. `_emit_run_debug_state` (L2202, ~15 internal references)
5. `_resolve_player` (L3699, ~13 internal references)
6. `_set_phase` (L4729, ~13 internal references)
7. `_guard_request_phase` (L1472, ~11 internal references)
8. `_emit_ui` (L3884, ~11 internal references)
9. `_get_bet_data` (L4229, ~11 internal references)
10. `_register_run_end` (L4406, ~11 internal references)

## Notes / limits

- `Called by` è una stima su chiamate interne a `run_manager.gd` (non call graph completo inter-file).
- Dove non rilevato, è marcato `unknown` e richiede analisi referenze dedicate.
- Top 10 funzioni più richiamate calcolata via occorrenze testuali `name(` nel file (stima conservativa).
- Nessuna modifica runtime effettuata: report-only.
