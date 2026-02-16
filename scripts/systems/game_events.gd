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
# - run_ended: emitted by RunManager; consumed by UIRoot/UI.
# - run_finale_selected: emitted by RunManager; consumed by UIRoot.
# - run_debug_state_updated: emitted by RunManager; consumed by UIRoot (debug).
# - run_log_ready: emitted by RunManager; consumed by UIRoot (debug).
# - special_arena_started: emitted by RunManager; consumed by UIRoot.
# - arena_theme_changed: emitted by RunManager; consumed by UIRoot.
# - sentence_banner_requested: emitted by RunManager; consumed by UIRoot.
# - audience_context_line_emitted: emitted by RunManager; consumed by UIRoot.
# - register_annotation: emitted by RunManager; consumed by UIRoot.
# - condanna_registered: emitted by RunManager; consumed by MainMenu.
# - bet_failed: emitted by RunManager; consumed by UIRoot.
# - coins_changed: emitted by RunManager; consumed by UIRoot.
# - enemy_killed: emitted by Arena/combat; consumed by RunManager.
# - escalation_changed: emitted by RunManager; consumed by UIRoot.
# - bet_placed: emitted by RunManager; consumed by UIRoot.
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
# - request_place_bet: emitted by UIRoot; consumed by RunManager.
# - request_new_run: emitted by MainMenu; consumed by RunManager.
# - request_reset_run: emitted by UI/debug; consumed by RunManager.
# - request_retry_run: emitted by UI; consumed by RunManager.
# - request_continue_run: emitted by MainMenu; consumed by RunManager.
# - request_push_luck_cashout: emitted by UI; consumed by RunManager.
# - request_push_luck_double: emitted by UI; consumed by RunManager.
# - request_intermediate_choice: emitted by UI; consumed by RunManager.
# - request_set_run_seed: emitted by UI/debug; consumed by RunManager.
# - request_clear_run_seed: emitted by UI; consumed by RunManager.
# - request_skip_arena_resolution: emitted by UI/debug; consumed by RunManager.
# - request_show_main_menu: emitted by UI; consumed by RunManager.
# - request_fail_run: emitted by gameplay systems; consumed by RunManager.

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal run_ended(reason: String, summary: Dictionary)
signal run_finale_selected(payload: Dictionary)
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
signal enemy_killed(exp: int)
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
signal request_place_bet(bet_id: String, stake: int)
# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
# Preconditions: GameEvents autoload exists; RunManager listens to request_new_run.
# Postconditions: RunManager starts a new run and emits run_started for UI refresh.
signal request_new_run
signal request_reset_run
signal request_retry_run
signal request_continue_run
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

func _ready() -> void:
	_connect_noop(run_started)
	_connect_noop(arena_started)
	_connect_noop(arena_completed)
	_connect_noop(run_failed)
	_connect_noop(run_ended)
	_connect_noop(run_finale_selected)
	_connect_noop(run_debug_state_updated)
	_connect_noop(run_log_ready)
	_connect_noop(special_arena_started)
	_connect_noop(arena_theme_changed)
	_connect_noop(sentence_banner_requested)
	_connect_noop(audience_context_line_emitted)
	_connect_noop(register_annotation)
	_connect_noop(condanna_registered)
	_connect_noop(bet_failed)
	_connect_noop(coins_changed)
	_connect_noop(enemy_killed)
	_connect_noop(escalation_changed)
	_connect_noop(bet_placed)
	_connect_noop(bet_confirmed)
	_connect_noop(bet_sealed)
	_connect_noop(bet_selected)
	_connect_noop(bet_ui_opened)
	_connect_noop(bet_ui_closed)
	_connect_noop(betting_opened)
	_connect_noop(betting_closed)
	_connect_noop(bet_opened)
	_connect_noop(bet_closed)
	_connect_noop(pact_sealed_opened)
	_connect_noop(pact_sealed_closed)
	_connect_noop(resolve_ritual_opened)
	_connect_noop(resolve_ritual_closed)
	_connect_noop(intermediate_choice_opened)
	_connect_noop(push_luck_opened)
	_connect_noop(push_luck_closed)
	_connect_noop(post_arena_choice_selected)
	_connect_noop(player_damaged)
	_connect_noop(run_phase_changed)
	_connect_noop(countdown_requested)
	_connect_noop(gameplay_enabled_changed)
	_connect_noop(modal_opened)
	_connect_noop(modal_closed)
	_connect_noop(scars_updated)
	_connect_noop(scar_applied)
	_connect_noop(settings_opened)
	_connect_noop(settings_closed)
	_connect_noop(settings_changed)
	_connect_noop(difficulty_tier_changed)
	_connect_noop(request_place_bet)
	_connect_noop(request_new_run)
	_connect_noop(request_reset_run)
	_connect_noop(request_retry_run)
	_connect_noop(request_continue_run)
	_connect_noop(request_push_luck_cashout)
	_connect_noop(request_push_luck_double)
	_connect_noop(request_intermediate_choice)
	_connect_noop(request_intro_apply_seed)
	_connect_noop(request_intro_select_bet)
	_connect_noop(request_intro_confirm)
	_connect_noop(request_mid_choice_select)
	_connect_noop(request_pyl_cashout)
	_connect_noop(request_pyl_condanna)
	_connect_noop(request_pyl_double)
	_connect_noop(request_end_run_restart)
	_connect_noop(request_end_run_next_bet)
	_connect_noop(request_end_run_quit)
	_connect_noop(request_set_run_seed)
	_connect_noop(request_clear_run_seed)
	_connect_noop(request_skip_arena_resolution)
	_connect_noop(request_show_main_menu)
	_connect_noop(request_fail_run)

func _connect_noop(target_signal: Signal) -> void:
	var handler: Callable = Callable(self, "_noop")
	if not target_signal.is_connected(handler):
		target_signal.connect(handler)

func _noop(_a: Variant = null, _b: Variant = null, _c: Variant = null, _d: Variant = null) -> void:
	pass

func set_gameplay_enabled(enabled: bool) -> void:
	if gameplay_enabled == enabled:
		return
	gameplay_enabled = enabled
	gameplay_enabled_changed.emit(enabled)
