extends Node

# -----------------------------------------------------------------------------
# ROLE / OWNERSHIP
# - This script is responsible for: Central event bus (autoload) for gameplay + UI.
# - This script must NOT: contain gameplay logic or state transitions.
#
# FLOW CONTRACT (high level)
# - Inputs (signals/events it listens to): none (signals are emitted by other scripts).
# - Outputs (signals/events it emits): declared signals below for UI/system coordination.
# - Critical invariants: must be autoload; single shared event bus for the project.
# -----------------------------------------------------------------------------

# Signals index
# - run_started: emitted by RunManager; consumed by UIRoot/UI.
# - arena_started: emitted by RunManager/Arena; consumed by UIRoot.
# - arena_completed: emitted by Arena/RunManager; consumed by RunManager/UI.
# - run_failed: emitted by RunManager; consumed by UIRoot/UI.
# - run_finale_selected: emitted by RunManager; consumed by UIRoot.
# - run_debug_state_updated: emitted by RunManager; consumed by UIRoot (debug).
# - run_log_ready: emitted by RunManager; consumed by UIRoot (debug).
# - special_arena_started: emitted by RunManager; consumed by UIRoot.
# - arena_theme_changed: emitted by RunManager; consumed by UIRoot.
# - sentence_banner_requested: emitted by RunManager; consumed by UIRoot.
# - audience_context_line_emitted: emitted by RunManager; consumed by UIRoot.
# - condanna_registered: emitted by RunManager; consumed by MainMenu.
# - bet_failed: emitted by RunManager/BetManager; consumed by UIRoot.
# - coins_changed: emitted by RunManager; consumed by UIRoot.
# - tokens_changed: emitted by RunManager; consumed by UIRoot.
# - enemy_killed: emitted by Arena/combat; consumed by RunManager.
# - escalation_changed: emitted by RunManager; consumed by UIRoot.
# - level_changed: emitted by RunManager; consumed by UIRoot.
# - xp_changed: emitted by RunManager; consumed by UIRoot.
# - bet_placed: emitted by RunManager/BetManager; consumed by UIRoot.
# - bet_confirmed: emitted by bet UI/flow; consumed by RunManager.
# - bet_sealed: emitted by RunManager; consumed by RunManager/UI.
# - bet_selected: emitted by UIRoot; consumed by RunManager.
# - bet_ui_opened: emitted by RunManager; consumed by UIRoot.
# - bet_ui_closed: emitted by UIRoot; consumed by RunManager.
# - betting_opened: emitted by RunManager; consumed by UIRoot.
# - betting_closed: emitted by RunManager; consumed by UIRoot.
# - bet_opened: emitted by RunManager; consumed by UIRoot.
# - bet_closed: emitted by RunManager; consumed by UIRoot.
# - pact_sealed_opened: emitted by RunManager; consumed by UIRoot.
# - pact_sealed_closed: emitted by RunManager; consumed by UIRoot.
# - resolve_ritual_opened: emitted by RunManager; consumed by UIRoot.
# - resolve_ritual_closed: emitted by RunManager; consumed by UIRoot.
# - intermediate_choice_opened: emitted by RunManager; consumed by UIRoot.
# - push_luck_opened: emitted by RunManager; consumed by UIRoot.
# - push_luck_closed: emitted by RunManager; consumed by UIRoot.
# - post_arena_choice_selected: emitted by UIRoot; consumed by RunManager.
# - player_damaged: emitted by combat systems; consumed by RunManager/UI.
# - run_phase_changed: emitted by RunManager; consumed by UI/systems.
# - countdown_requested: emitted by RunManager; consumed by UIRoot.
# - gameplay_enabled_changed: emitted by GameEvents.set_gameplay_enabled; consumed by UI/systems.
# - modal_opened: emitted by UIRoot; consumed by RunManager.
# - modal_closed: emitted by UIRoot; consumed by RunManager.
# - scars_updated: emitted by RunManager; consumed by UIRoot.
# - scar_applied: emitted by RunManager; consumed by UIRoot.
# - settings_opened: emitted by MainMenu/UI; consumed by UIRoot.
# - settings_closed: emitted by MainMenu/UI; consumed by UIRoot.
# - settings_changed: emitted by UI; consumed by RunManager.
# - difficulty_tier_changed: emitted by RunManager; consumed by UI/systems.
# - player_xp_changed: emitted by RunManager; consumed by UIRoot.
# - player_level_changed: emitted by RunManager; consumed by UIRoot.
# - upgrade_tokens_changed: emitted by RunManager; consumed by UIRoot.
# - request_purchase_upgrade: emitted by UI; consumed by RunManager.
# - request_purchase_token: emitted by UI; consumed by RunManager.
# - request_place_bet: emitted by UIRoot; consumed by RunManager.
# - request_open_bet_ui: emitted by UI; consumed by RunManager.
# - request_consume_upgrade_shop: emitted by UI; consumed by RunManager.
# - request_new_run: emitted by MainMenu; consumed by RunManager.
# - request_reset_run: emitted by UI/debug; consumed by RunManager.
# - request_retry_run: emitted by UI; consumed by RunManager.
# - request_continue_run: emitted by MainMenu; consumed by RunManager.
# - request_next_bet: emitted by UI; consumed by RunManager.
# - request_add_coins: emitted by UI/debug; consumed by RunManager.
# - request_push_luck_cashout: emitted by UI; consumed by RunManager.
# - request_push_luck_double: emitted by UI; consumed by RunManager.
# - request_intermediate_choice: emitted by UI; consumed by RunManager.
# - request_set_run_seed: emitted by UI/debug; consumed by RunManager.
# - request_clear_run_seed: emitted by UI; consumed by RunManager.
# - request_skip_arena_resolution: emitted by UI/debug; consumed by RunManager.
# - request_show_main_menu: emitted by UI; consumed by MainMenu.

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal run_finale_selected(payload: Dictionary)
signal run_debug_state_updated(payload: Dictionary)
signal run_log_ready(log_text: String)
signal special_arena_started(payload: Dictionary)
signal arena_theme_changed(payload: Dictionary)
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
signal settings_opened
signal settings_closed
signal settings_changed(payload: Dictionary)

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
# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
# Preconditions: GameEvents autoload exists; RunManager listens to request_new_run.
# Postconditions: RunManager starts a new run and emits run_started for UI refresh.
signal request_new_run
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
signal request_show_main_menu

var gameplay_enabled: bool = true

func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		return
	gameplay_enabled = enabled
	gameplay_enabled_changed.emit(enabled)
