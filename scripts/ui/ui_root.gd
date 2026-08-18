extends CanvasLayer

# -----------------------------------------------------------------------------
# ROLE / OWNERSHIP
# - This script is responsible for: Rendering UI based on run/game state signals.
# - This script must NOT: decide gameplay outcomes or mutate run state directly.
#
# FLOW CONTRACT (high level)
# - Inputs (signals/events it listens to): GameEvents.run_started/run_failed/etc. (state updates)
# - Outputs (signals/events it emits): GameEvents.request_* intents, GameEvents.modal_opened/closed
# - Critical invariants: UI is reactive; RunManager and systems own state changes.
# -----------------------------------------------------------------------------


const FAST_SELECTION_SECONDS: int = 12
const MIN_MODAL_READ_TIME_SEC: float = 1.25
const SENTENCE_BANNER_SECONDS: float = 1.2
const REGISTER_ANNOTATION_FALLBACK_SECONDS: float = 1.2
const FADE_IN_SEC: float = 0.22
const FADE_OUT_SEC: float = 0.18
const ENDING_FADE_IN_SEC: float = 0.46
const ENDING_FADE_OUT_SEC: float = 0.34
const SIGN_LOCK_FEEDBACK_SECONDS: float = 0.18
const SIGN_LOCK_DARKEN_RGB: float = 0.76
const SIGN_PREVIEW_SCALE: float = 1.015
const MOTION_KIND_STANDARD: String = "standard"
const MOTION_KIND_RITUAL: String = "ritual"
const MOTION_KIND_ENDING: String = "ending"
const MOTION_BASE_POSITION_META: StringName = &"motion_base_position"
const BACKDROP_BASE_SCALE_META: StringName = &"backdrop_base_scale"
const BACKDROP_SHADE_ALPHA_META: StringName = &"backdrop_shade_alpha"
const PUSH_LUCK_DETAILS_MAX_LINES: int = 3
const PUSH_LUCK_DETAIL_MAX_CHARS: int = 72
const QUICK_CUT_MAX_SECONDS: float = 1.5
const VERDICT_REVEAL_STEP_SECONDS: float = 0.34
const VERDICT_REVEAL_HOLD_SECONDS: float = 0.12
const VERDICT_STAGE_SUBTITLE_DELAY_SECONDS: float = 0.38
const VERDICT_STAGE_BODY_DELAY_SECONDS: float = 0.44
const VERDICT_STAGE_DETAILS_DELAY_SECONDS: float = 0.36
const VERDICT_STAGE_BUTTONS_DELAY_SECONDS: float = 0.30
const RESOLUTION_RITUAL_STRIKES_REQUIRED: int = 3
const RESOLUTION_RITUAL_BEAT_SECONDS: float = 0.9
const RESOLUTION_RITUAL_HIT_WINDOW_SECONDS: float = 0.18
const BUTTON_STYLE_PRIMARY_NORMAL_PATH: String = "res://assets/ui/official/styleboxes/sb_button_primary_normal.tres"
const BUTTON_STYLE_PRIMARY_HOVER_PATH: String = "res://assets/ui/official/styleboxes/sb_button_primary_hover.tres"
const BUTTON_STYLE_PRIMARY_PRESSED_PATH: String = "res://assets/ui/official/styleboxes/sb_button_primary_pressed.tres"
const BUTTON_STYLE_PRIMARY_DISABLED_PATH: String = "res://assets/ui/official/styleboxes/sb_button_primary_disabled.tres"
const RECEIPT_STYLE_PRESSED: StyleBox = preload("res://assets/ui/official/objects/receipt/sb_registry_receipt_pressed.tres")
const RECEIPT_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/receipt/sb_registry_receipt_disabled.tres")
const RECEIPT_TAKEN_META: StringName = &"registry_receipt_taken"
const CONDEMNATION_MARK_STYLE_REGISTERED: StyleBox = preload("res://assets/ui/official/objects/condemnation_mark/sb_registry_condemnation_mark_registered.tres")
const CONDEMNATION_MARK_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/condemnation_mark/sb_registry_condemnation_mark_disabled.tres")
const CONDEMNATION_MARK_REGISTERED_META: StringName = &"registry_condemnation_mark_registered"
const SECOND_INCISION_STYLE_SEALED: StyleBox = preload("res://assets/ui/official/objects/second_incision/sb_registry_second_incision_sealed.tres")
const SECOND_INCISION_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/second_incision/sb_registry_second_incision_disabled.tres")
const SECOND_INCISION_SEALED_META: StringName = &"registry_second_incision_sealed"
const PACT_TABLET_STYLE_VALIDATED: StyleBox = preload("res://assets/ui/official/objects/pact_tablet/sb_registry_pact_tablet_validated.tres")
const PACT_TABLET_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/pact_tablet/sb_registry_pact_tablet_disabled.tres")
const PACT_TABLET_VALIDATED_META: StringName = &"registry_pact_tablet_validated"
const PACT_TABLET_WATCHDOG_SECONDS: float = 1.25
const GESTURE_PLACA_STYLE_SELECTED: StyleBox = preload("res://assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_selected.tres")
const GESTURE_PLACA_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_disabled.tres")
const GESTURE_PROVOCA_STYLE_SELECTED: StyleBox = preload("res://assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_selected.tres")
const GESTURE_PROVOCA_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_disabled.tres")
const GESTURE_CHOICE_STATE_META: StringName = &"arena_gesture_choice_state"
const GESTURE_CHOICE_WATCHDOG_SECONDS: float = 1.25
const JUDGMENT_SEAL_STYLE_NORMAL: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_normal.tres")
const JUDGMENT_SEAL_STYLE_FOCUS: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_focus.tres")
const JUDGMENT_SEAL_STYLE_PRESSED: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_pressed.tres")
const JUDGMENT_SEAL_STYLE_STRIKE_1: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_strike_1.tres")
const JUDGMENT_SEAL_STYLE_STRIKE_2: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_strike_2.tres")
const JUDGMENT_SEAL_STYLE_RESOLVED: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_resolved.tres")
const JUDGMENT_SEAL_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_disabled.tres")
const JUDGMENT_SEAL_STATE_META: StringName = &"registry_judgment_seal_state"
const JUDGMENT_SEAL_WATCHDOG_SECONDS: float = 1.25
const FINAL_DOSSIER_STYLE_OPEN: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_open.tres")
const FINAL_DOSSIER_STYLE_UPDATED: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_updated.tres")
const FINAL_DOSSIER_STYLE_CLOSED: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_closed.tres")
const FINAL_DOSSIER_TAB_STYLE_NORMAL: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_normal.tres")
const FINAL_DOSSIER_TAB_STYLE_FOCUS: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_focus.tres")
const FINAL_DOSSIER_TAB_STYLE_PRESSED: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_pressed.tres")
const FINAL_DOSSIER_TAB_STYLE_SELECTED: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_selected.tres")
const FINAL_DOSSIER_TAB_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_disabled.tres")
const FINAL_DOSSIER_ROUTE_SELECTED_META: StringName = &"registry_final_dossier_route_selected"
const FINAL_DOSSIER_STATE_OPEN: StringName = &"open"
const FINAL_DOSSIER_STATE_UPDATED: StringName = &"updated"
const FINAL_DOSSIER_STATE_CLOSED: StringName = &"closed"
const FINAL_DOSSIER_WATCHDOG_SECONDS: float = 1.5
const CondannaDataScript = preload("res://data/condanne.gd")
const VerdictLinesScript = preload("res://data/verdict_lines.gd")
const RunUiPayloadScript = preload("res://scripts/ui/run_ui_payload.gd")
const SCARS_PANEL_BASE_HEIGHT: float = 72.0
const SCARS_PANEL_ROW_HEIGHT: float = 24.0
const SCARS_PANEL_MIN_HEIGHT: float = 102.0
const SCARS_PANEL_MAX_HEIGHT: float = 168.0
const ENDING_ICON_FALLBACK_PATH: String = "res://assets/ui/icons/icon_sentence.png"
const _BOOT_FAIL_CONTRACT_PATHS: Array[Dictionary] = [
	{"label": "Modals/BetModal", "fallback": "UI_RunRoot/Phase_INTRO"},
	{"label": "Modals/PactSealedModal", "fallback": "UI_RunRoot/Phase_FIRST_REACTION"},
	{"label": "Modals/ResolveRitualModal", "fallback": "UI_RunRoot/Phase_RESOLUTION"},
	{"label": "Modals/GameOverModal", "fallback": "UI_RunRoot/Phase_END_RUN"},
]
const ENDING_UI_MAP: Dictionary = {
	"ending_corruption": {
		"title": "FASCICOLO CHIUSO - COMPROMISSIONE",
		"icon": "res://assets/ui/icons/icon_sentence.png",
	},
	"ending_glory": {
		"title": "FASCICOLO CHIUSO - ASCESA",
		"icon": "res://assets/ui/icons/icon_payout.png",
	},
	"ending_scars": {
		"title": "FASCICOLO CHIUSO - CONSUMO",
		"icon": "res://assets/ui/icons/icon_token_16.png",
	},
	"ending_pattern": {
		"title": "FASCICOLO CHIUSO - PATTERN",
		"icon": "res://assets/ui/icons/icon_sentence.png",
	},
}
const _PHASE_CONTAINER_PATHS: Array[String] = [
	"UI_RunRoot/Phase_INTRO",
	"UI_RunRoot/Phase_FIRST_REACTION",
	"UI_RunRoot/Phase_MID_CHOICE",
	"UI_RunRoot/Phase_PUSH_YOUR_LUCK",
	"UI_RunRoot/Phase_RESOLUTION",
	"UI_RunRoot/Phase_END_RUN",
]
const _GAME_EVENT_WIRING_REQUIRED: Array[Dictionary] = [
	{"signal": &"bet_placed", "handler": &"_on_bet_placed"},
	{"signal": &"run_started", "handler": &"_on_run_started"},
	{"signal": &"run_failed", "handler": &"_on_run_failed"},
	{"signal": &"bet_failed", "handler": &"_on_bet_failed"},
	{"signal": &"bet_ui_opened", "handler": &"_on_bet_ui_opened"},
	{"signal": &"bet_ui_closed", "handler": &"_on_bet_ui_closed"},
	{"signal": &"arena_started", "handler": &"_on_arena_started"},
	{"signal": &"betting_opened", "handler": &"_on_betting_opened"},
	{"signal": &"countdown_requested", "handler": &"_on_countdown_requested"},
]
const _GAME_EVENT_WIRING_GUARDED: Array[Dictionary] = [
	{"signal": &"run_ended", "handler": &"_on_run_ended"},
	{"signal": &"run_finale_selected", "handler": &"_on_run_finale_selected"},
	{"signal": &"sentence_banner_requested", "handler": &"_on_sentence_banner_requested"},
	{"signal": &"audience_context_line_emitted", "handler": &"_on_audience_context_line_emitted"},
	{"signal": &"register_annotation", "handler": &"_on_register_annotation"},
	{"signal": &"micro_interpretive_quick_cut_requested", "handler": &"_on_micro_interpretive_quick_cut_requested"},
	{"signal": &"escalation_changed", "handler": &"_on_escalation_changed"},
	{"signal": &"special_arena_started", "handler": &"_on_special_arena_started"},
	{"signal": &"arena_theme_changed", "handler": &"_on_arena_theme_changed"},
	{"signal": &"bet_selected", "handler": &"_on_bet_selected"},
	{"signal": &"pact_sealed_opened", "handler": &"_on_pact_sealed_opened"},
	{"signal": &"pact_sealed_closed", "handler": &"_on_pact_sealed_closed"},
	{"signal": &"resolve_ritual_opened", "handler": &"_on_resolve_ritual_opened"},
	{"signal": &"resolve_ritual_closed", "handler": &"_on_resolve_ritual_closed"},
	{"signal": &"push_luck_opened", "handler": &"_on_push_luck_opened"},
	{"signal": &"push_luck_closed", "handler": &"_on_push_luck_closed"},
	{"signal": &"scars_updated", "handler": &"_on_scars_updated"},
	{"signal": &"scar_applied", "handler": &"_on_scar_applied"},
]
const _ERA2_THEME_IDS: Array[StringName] = [
	&"ARENA_BLOOD",
]
const _ERA3_THEME_IDS: Array[StringName] = []
const _SILENCE_THEME_ID: StringName = &"ARENA_SILENCE"
const _SILENCE_OVERLAY_ALPHA: float = 0.24
const _ERA2_PANEL_MATERIAL: Material = preload("res://assets/ui/official/era2/materials/era2_grade_noise.tres")
const _ERA3_GLOBAL_MATERIAL: Material = preload("res://assets/ui/official/era3/materials/era3_global_grade_noise.tres")
const _SILENCE_OVERLAY_MATERIAL: Material = preload("res://assets/ui/official/silence/materials/silence_overlay_noise.tres")
const _VISUAL_TIER_BASE: int = 0
const _VISUAL_TIER_ERA2: int = 1
const _VISUAL_TIER_ERA3: int = 2

var _active_visual_tier: int = _VISUAL_TIER_BASE
var _silence_overlay_active: bool = false

# Restored UI/state declarations (were dropped, causing wide "identifier not declared" parse failures).
var _run_manager_port: RunManagerUiPort = null
var _arena: Node = null
var _phase_node_map: Dictionary = {}
var _last_shown_phase: int = -1

var _button_style_primary_normal: StyleBox = null
var _button_style_primary_hover: StyleBox = null
var _button_style_primary_pressed: StyleBox = null
var _button_style_primary_disabled: StyleBox = null

var _glory: int = 0
var _escalation_level: int = 0
var _escalation_max: int = 0
var _selected_bet_id: StringName = &""
var _pending_confirm_bet_id: StringName = &""
var _current_bet_offer: Array[Dictionary] = []
var _require_bet_confirm: bool = false
var _ending_mode_active: bool = false
var _current_modal: Control = null
var _is_signing: bool = false

var _pending_bets: Array = []
var _bets_by_id: Dictionary = {}
var _bet_buttons: Array = []
var _bet_select_buttons_by_id: Dictionary = {}
var _bet_signature_buttons_by_id: Dictionary = {}
var _pyl_locked_buttons: Array = []
var _sign_feedback_buttons: Array = []
var _sign_feedback_panel: Control = null

var _pyl_locked: bool = false
var _pyl_request_sequence_id: int = 0
var _fast_countdown_active: bool = false
var _has_seen_controls: bool = false
var _controls_first_run_active: bool = true
var _sentence_banner_sequence_id: int = 0

var _special_arena_payload: Dictionary = {}
var _arena_theme_payload: Dictionary = {}
var _last_ritual_outcome_snapshot: Dictionary = {}

var _last_finale_title: String = ""
var _last_finale_title_key: String = ""
var _last_finale_text: String = ""
var _last_final_report: Dictionary = {}
var _last_finale_scars: Array = []
var _last_finale_ending_id: String = ""
var _last_finale_seed: int = 0
var _last_finale_stats: Dictionary = {}
var _last_finale_hint: String = ""
var _last_ending_icon_path: String = ENDING_ICON_FALLBACK_PATH
var _last_next_bet_enabled: bool = false
var _last_register_message: String = ""
var _last_register_message_key: String = ""
var _last_register_final: bool = false
var _last_register_ending_key: String = ""
var _last_verdict_outcome: StringName = &"LOSS"
var _last_verdict_sentence: String = ""
var _last_verdict_charge: String = ""
var _last_verdict_crowd_line: String = ""
var _last_verdict_crowd_line_key: String = ""
var _last_verdict_pacts: Array[String] = []
var _last_verdict_condanne: Array[String] = []
var _final_dossier_state: StringName = FINAL_DOSSIER_STATE_OPEN
var _final_dossier_route_locked: bool = false
var _final_dossier_request_sequence_id: int = 0
var _scars_detail_text: String = ""
var _bet_confirm_default_text: String = ""

var _arena_resolution_tween: Tween = null
var _scar_popup_tween: Tween = null
var _register_annotation_tween: Tween = null
var _quick_cut_tween: Tween = null
var _sign_feedback_tween: Tween = null
var _pyl_lock_feedback_tween: Tween = null
var _bet_modal_fade_tween: Tween = null
var _pact_sealed_modal_fade_tween: Tween = null
var _resolve_ritual_modal_fade_tween: Tween = null
var _intermediate_choice_modal_fade_tween: Tween = null
var _push_luck_modal_fade_tween: Tween = null
var _game_over_modal_fade_tween: Tween = null
var _verdict_reveal_tween: Tween = null
var _verdict_reveal_sequence_id: int = 0
var _pressure_pulse_tween: Tween = null

var _betting_overlay_hud_visibility_cached: bool = false
var _betting_overlay_hud_visible_before: bool = true
var _betting_overlay_bet_badge_visible_before: bool = true
var _betting_overlay_glory_visible_before: bool = true
var _betting_overlay_scars_visible_before: bool = true
var _betting_overlay_scars_visibility_cached: bool = false
var _betting_overlay_theme_visibility_cached: bool = false
var _betting_overlay_theme_title_visible_before: bool = true
var _betting_overlay_theme_subtitle_visible_before: bool = true

var boot_fail_overlay: Control = null
var boot_fail_body: Label = null
var boot_fail_button: Button = null
var controls_hint_panel: Control = null
var hud_root: Control = null
var modals_root: Control = null
var modal_dimmer: ColorRect = null
var hud_top_left_stats_box: Control = null
var run_safe_margin: Control = null

var glory_value_label: Label = null
var bet_badge_value_label: Label = null
var escalation_row: Control = null
var escalation_label: Label = null
var escalation_bar: Range = null
var pressure_state_label: Label = null
var _pressure_fill_style: StyleBoxFlat = null
var _pressure_background_style: StyleBoxFlat = null
var special_arena_label: Label = null
var condanna_focus_label: Label = null
var audience_context_panel: Control = null
var audience_context_label: Label = null
var countdown_label: Label = null
var countdown_panel: Control = null

var scars_panel: Control = null
var scars_label: Label = null
var scars_detail_panel: Control = null
var scars_detail_text: RichTextLabel = null
var scars_detail_close: Button = null

var sentence_banner: Control = null
var sentence_title_label: Label = null
var sentence_rule_label: Label = null
var sentence_doom_label: Label = null
var register_blocker: Control = null
var register_annotation_label: Label = null
var quick_cut_blocker: Control = null
var quick_cut_shade: ColorRect = null
var quick_cut_label_panel: Control = null
var quick_cut_label: Label = null
var silence_overlay: ColorRect = null
var torch_flicker_overlay: ColorRect = null
var torch_flicker_player: AnimationPlayer = null
var ending_background: Control = null

var arena_theme_title_panel: Control = null
var arena_theme_title_label: Label = null
var arena_theme_subtitle_panel: Control = null
var arena_theme_subtitle_label: Label = null
var arena_resolution_panel: Control = null
var arena_resolution_label: Label = null
var _pending_resolution_context_line: String = ""
var _resolve_ritual_base_body: String = ""

var bet_panel: Control = null
var bet_modal: Control = null
var stake_row: Control = null
var stake_input: SpinBox = null
var bet_buttons_container: Control = null
var bet_confirm_row: Control = null
var bet_confirm_label: Label = null
var bet_confirm_button: Button = null
var betting_circle: BettingCircleUI = null

var pact_sealed_modal: Control = null
var pact_sealed_panel: Control = null
var pact_sealed_title: Label = null
var pact_sealed_subtitle: Label = null
var resolve_ritual_modal: Control = null
var resolve_ritual_panel: Control = null
var resolve_ritual_title: Label = null
var resolve_ritual_subtitle: Label = null
var resolve_ritual_prompt: Label = null
var resolve_ritual_strike_button: Button = null
var resolve_ritual_strike_marks: Array[Label] = []
var pact_sealed_advance_button: Button = null
var resolve_ritual_advance_button: Button = null
var _pact_tablet_locked: bool = false
var _pact_tablet_request_sequence_id: int = 0
var _resolve_ritual_strike_count: int = 0
var _resolve_ritual_started_msec: int = 0
var _resolve_ritual_pulse_tween: Tween = null
var _resolve_ritual_hit_tween: Tween = null
var _judgment_seal_locked: bool = false
var _judgment_seal_request_sequence_id: int = 0

var intermediate_choice_modal: Control = null
var intermediate_choice_panel: Control = null
var intermediate_choice_label: Label = null
var intermediate_choice_audience_label: Label = null
var intermediate_choice_placa_button: Button = null
var intermediate_choice_provoca_button: Button = null
var _gesture_choice_locked: bool = false
var _gesture_choice_request_sequence_id: int = 0

var push_luck_modal: Control = null
var push_luck_panel: Control = null
var push_luck_title: Label = null
var push_luck_info: Label = null
var push_luck_details: Label = null
var push_luck_audience_label: Label = null
var push_luck_audience_reason: Label = null
var push_luck_cashout_button: Button = null
var push_luck_cashout_note: Label = null
var push_luck_condanna_button: Button = null
var push_luck_condanna_note: Label = null
var push_luck_double_button: Button = null
var push_luck_double_note: Label = null

var game_over_modal: Control = null
var game_over_panel: Control = null
var game_over_scroll: ScrollContainer = null
var ending_text: RichTextLabel = null
var verdict_header: Label = null
var verdict_outcome: Label = null
var verdict_icon: TextureRect = null
var verdict_sentence_label: Label = null
var verdict_charge_label: Label = null
var verdict_sections: Control = null
var verdict_pacts_text: RichTextLabel = null
var verdict_condanne_text: RichTextLabel = null
var verdict_crowd_section: Control = null
var verdict_crowd_text: Label = null
var next_bet_button: Button = null
var restart_button: Button = null
var quit_button: Button = null

var fast_countdown_panel: Control = null
var fast_countdown_label: Label = null
var fast_blink_timer: Timer = null

var intro_select_win_button: Button = null
var intro_select_fast_button: Button = null
var _lbl_intro_title: Label = null
var _lbl_intro_subtitle: Label = null
var _lbl_intro_body: Label = null
var _lbl_intro_body_stake: Label = null
var _lbl_intro_footer: Label = null

var scar_popup_panel: Control = null
var scar_popup: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run_manager_port = RunManagerUiPort.new(get_tree())
	_bind_scene_nodes()
	if boot_fail_button != null:
		var boot_fail_callable: Callable = Callable(self, "_on_boot_fail_back_to_menu")
		if not boot_fail_button.pressed.is_connected(boot_fail_callable):
			boot_fail_button.pressed.connect(boot_fail_callable)
	if not _validate_ui_boot():
		return
	if not _validate_ui_contract_or_show_boot_fail():
		return
	_button_style_primary_normal = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_NORMAL_PATH)
	_button_style_primary_hover = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_HOVER_PATH)
	_button_style_primary_pressed = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_PRESSED_PATH)
	_button_style_primary_disabled = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_DISABLED_PATH)
	if controls_hint_panel != null:
		controls_hint_panel.visible = true
		_has_seen_controls = false
		_controls_first_run_active = true
	_init_phase_node_map()
	_verify_phase_paths()
	_wire_standard_game_event_signals()
	_refresh_scars_ui([])

	if bet_panel == null:
		push_warning("Bet UI missing, disabling betting panel.")
	else:
		_set_bet_modal(false)
		if stake_input == null or bet_buttons_container == null:
			push_warning("Bet UI nodes incomplete, disabling betting panel.")
			_set_bet_modal(false)
		else:
			if stake_row != null:
				stake_row.visible = false
			stake_input.editable = false
			stake_input.value = 0
			_clear_bet_buttons()
			_reset_bet_confirmation()
			if bet_confirm_button != null:
				var confirm_callable: Callable = Callable(self, "_on_bet_confirm_pressed")
				if not bet_confirm_button.pressed.is_connected(confirm_callable):
					bet_confirm_button.pressed.connect(confirm_callable)
				_wire_sign_preview(bet_confirm_button)

	if scar_popup_panel != null:
		scar_popup_panel.visible = false
	if arena_resolution_label != null:
		arena_resolution_label.visible = false
	if arena_resolution_panel != null:
		arena_resolution_panel.visible = false

	if fast_blink_timer != null:
		var blink_callable: Callable = Callable(self, "_on_fast_blink_tick")
		if not fast_blink_timer.timeout.is_connected(blink_callable):
			fast_blink_timer.timeout.connect(blink_callable)

	if restart_button != null:
		if not restart_button.pressed.is_connected(Callable(self, "_on_restart_pressed")):
			restart_button.pressed.connect(Callable(self, "_on_restart_pressed"))
		_wire_sign_preview(restart_button)
	if next_bet_button != null:
		if not next_bet_button.pressed.is_connected(Callable(self, "_on_retry_pressed")):
			next_bet_button.pressed.connect(Callable(self, "_on_retry_pressed"))
		_wire_sign_preview(next_bet_button)
	if quit_button != null:
		if not quit_button.pressed.is_connected(Callable(self, "_on_quit_pressed")):
			quit_button.pressed.connect(Callable(self, "_on_quit_pressed"))
		_wire_sign_preview(quit_button)
	if push_luck_panel != null:
		_set_push_luck_modal(false)
	if modal_dimmer != null:
		modal_dimmer.visible = false
		modal_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if scars_panel != null:
		var scars_gui_callable: Callable = Callable(self, "_on_scars_panel_gui_input")
		if not scars_panel.gui_input.is_connected(scars_gui_callable):
			scars_panel.gui_input.connect(scars_gui_callable)
	if scars_detail_panel != null:
		scars_detail_panel.visible = false
		if scars_detail_close != null:
			var close_callable: Callable = Callable(self, "_on_scars_detail_closed")
			if not scars_detail_close.pressed.is_connected(close_callable):
				scars_detail_close.pressed.connect(close_callable)
			_wire_sign_preview(scars_detail_close)
	_wire_intermediate_choice_buttons()
	_wire_push_luck_buttons()
	_wire_ritual_advance_buttons()
	_wire_intro_phase_buttons()

	_refresh_runtime_group_cache(true)

func _wire_standard_game_event_signals() -> void:
	for required_spec: Dictionary in _GAME_EVENT_WIRING_REQUIRED:
		var required_signal_name: StringName = StringName(str(required_spec.get("signal", "")))
		var required_handler_name: StringName = StringName(str(required_spec.get("handler", "")))
		_connect_game_event_signal(required_signal_name, required_handler_name, false)
	for guarded_spec: Dictionary in _GAME_EVENT_WIRING_GUARDED:
		var guarded_signal_name: StringName = StringName(str(guarded_spec.get("signal", "")))
		var guarded_handler_name: StringName = StringName(str(guarded_spec.get("handler", "")))
		_connect_game_event_signal(guarded_signal_name, guarded_handler_name, true)

func _connect_game_event_signal(signal_name: StringName, handler_name: StringName, require_has_signal: bool) -> void:
	if signal_name == StringName() or handler_name == StringName():
		return
	var signal_name_text: String = str(signal_name)
	if not GameEvents.has_signal(signal_name_text):
		if require_has_signal:
			return
		push_error("UI wiring missing required GameEvents signal: %s" % signal_name_text)
		return
	var handler_callable: Callable = Callable(self, handler_name)
	if GameEvents.is_connected(signal_name, handler_callable):
		return
	var connect_error: int = GameEvents.connect(signal_name, handler_callable)
	if connect_error != OK:
		push_error("UI wiring failed for GameEvents.%s -> %s (error=%d)" % [
			signal_name_text,
			str(handler_name),
			connect_error,
		])

func _emit_game_event_signal_if_available(signal_name: StringName, args: Array = []) -> bool:
	if GameEvents == null:
		return false
	var signal_name_text: String = str(signal_name)
	if signal_name_text == "":
		return false
	if not GameEvents.has_signal(signal_name_text):
		return false
	var emit_payload: Array = [signal_name_text]
	emit_payload.append_array(args)
	GameEvents.callv("emit_signal", emit_payload)
	return true

func _has_game_event_signal(signal_name: StringName) -> bool:
	if GameEvents == null:
		return false
	var signal_name_text: String = str(signal_name)
	if signal_name_text == "":
		return false
	return GameEvents.has_signal(signal_name_text)

func _emit_modal_telemetry(modal_key: String, active: bool) -> void:
	if active:
		_emit_game_event_signal_if_available(&"modal_opened", [modal_key])
	else:
		_emit_game_event_signal_if_available(&"modal_closed", [modal_key])

func _bind_scene_nodes() -> void:
	# Core roots / overlays
	hud_root = get_node_or_null("HUD") as Control
	modals_root = get_node_or_null("UI_RunRoot") as Control
	modal_dimmer = get_node_or_null("UI_RunRoot/ModalDimmer") as ColorRect
	run_safe_margin = get_node_or_null("UI_RunRoot/SafeMargin") as Control
	controls_hint_panel = get_node_or_null("UI_RunRoot/SafeMargin/Grid/BottomHintRow") as Control
	boot_fail_overlay = get_node_or_null("UI_RunRoot/Overlays/BootFailOverlay") as Control
	boot_fail_body = get_node_or_null("UI_RunRoot/Overlays/BootFailOverlay/Center/Panel/VBox/Lbl_BootFail_Body") as Label
	boot_fail_button = get_node_or_null("UI_RunRoot/Overlays/BootFailOverlay/Center/Panel/VBox/Btn_BootFail_BackToMenu") as Button
	silence_overlay = get_node_or_null("UI_RunRoot/Overlays/SilenceOverlay/SilenceRect") as ColorRect
	torch_flicker_overlay = get_node_or_null("UI_RunRoot/TorchFlickerOverlay") as ColorRect
	torch_flicker_player = get_node_or_null("UI_RunRoot/TorchFlickerPlayer") as AnimationPlayer
	ending_background = get_node_or_null("UI_RunRoot/EndingBackground") as Control

	# HUD labels
	bet_badge_value_label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeValuePanel/BetBadgeValue") as Label
	glory_value_label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/GloryPanel/GloryMargin/GloryContent/GloryValuePanel/GloryValueLabel") as Label
	hud_top_left_stats_box = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn") as Control
	escalation_row = get_node_or_null("HUD/PressureRail") as Control
	escalation_label = get_node_or_null("HUD/PressureRail/PressureRailMargin/EscalationRow/EscalationLabelPanel/EscalationLabel") as Label
	escalation_bar = get_node_or_null("HUD/PressureRail/PressureRailMargin/EscalationRow/EscalationBar") as Range
	pressure_state_label = get_node_or_null("HUD/PressureRail/PressureRailMargin/EscalationRow/PressureStateLabelPanel/PressureStateLabel") as Label
	scars_panel = get_node_or_null("HUD/ScarsPanel") as Control
	scars_label = get_node_or_null("HUD/ScarsPanel/ScarsVBox/ScarsScroll/ScarsEntries/ScarsLabelPanel/ScarsLabel") as Label
	audience_context_panel = get_node_or_null("HUD/AudienceContextLabelPanel") as Control
	audience_context_label = get_node_or_null("HUD/AudienceContextLabelPanel/AudienceContextLabel") as Label
	register_blocker = get_node_or_null("HUD/RegisterAnnotationBlocker") as Control
	register_annotation_label = get_node_or_null("HUD/RegisterAnnotationBlocker/RegisterAnnotationLabelPanel/RegisterAnnotationLabel") as Label
	quick_cut_blocker = get_node_or_null("HUD/QuickCutBlocker") as Control
	quick_cut_shade = get_node_or_null("HUD/QuickCutBlocker/QuickCutShade") as ColorRect
	quick_cut_label_panel = get_node_or_null("HUD/QuickCutBlocker/QuickCutLabelPanel") as Control
	quick_cut_label = get_node_or_null("HUD/QuickCutBlocker/QuickCutLabelPanel/QuickCutLabel") as Label
	sentence_banner = get_node_or_null("HUD/SentenceBanner") as Control
	sentence_title_label = get_node_or_null("HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceTitlePanel/SentenceTitle") as Label
	sentence_rule_label = get_node_or_null("HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceRulePanel/SentenceRule") as Label
	sentence_doom_label = get_node_or_null("HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceDoomPanel/SentenceDoom") as Label
	arena_theme_title_panel = get_node_or_null("HUD/ArenaThemeTitleLabelPanel") as Control
	arena_theme_title_label = get_node_or_null("HUD/ArenaThemeTitleLabelPanel/ArenaThemeTitleLabel") as Label
	arena_theme_subtitle_panel = get_node_or_null("HUD/ArenaThemeSubtitleLabelPanel") as Control
	arena_theme_subtitle_label = get_node_or_null("HUD/ArenaThemeSubtitleLabelPanel/ArenaThemeSubtitleLabel") as Label
	special_arena_label = arena_theme_title_label
	condanna_focus_label = arena_theme_subtitle_label

	# Intro / betting
	bet_modal = get_node_or_null("UI_RunRoot/Phase_INTRO") as Control
	bet_panel = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO") as Control
	bet_buttons_container = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons") as Control
	stake_row = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/StakeRow") as Control
	stake_input = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/StakeRow/StakeInput") as SpinBox
	bet_confirm_row = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow") as Control
	bet_confirm_label = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Lbl_INTRO_FOOTERPanel/Lbl_INTRO_FOOTER") as Label
	bet_confirm_button = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Btn_INTRO_CONFIRM") as Button
	betting_circle = get_node_or_null("UI_RunRoot/BettingCircle") as BettingCircleUI

	# Pact / resolve
	pact_sealed_modal = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION") as Control
	pact_sealed_panel = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION") as Control
	pact_sealed_title = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_TITLEPanel/Lbl_FIRST_REACTION_TITLE") as Label
	pact_sealed_subtitle = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_BODYPanel/Lbl_FIRST_REACTION_BODY") as Label
	pact_sealed_advance_button = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Btn_FIRST_REACTION_NEXT") as Button
	resolve_ritual_modal = get_node_or_null("UI_RunRoot/Phase_RESOLUTION") as Control
	resolve_ritual_panel = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION") as Control
	resolve_ritual_title = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_TITLEPanel/Lbl_RESOLUTION_TITLE") as Label
	resolve_ritual_subtitle = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_BODYPanel/Lbl_RESOLUTION_BODY") as Label
	resolve_ritual_prompt = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_RITUAL_PROMPTPanel/Lbl_RESOLUTION_RITUAL_PROMPT") as Label
	resolve_ritual_strike_button = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Btn_RESOLUTION_STRIKE") as Button
	resolve_ritual_strike_marks = [
		get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/ResolutionStrikeRow/ResolutionStrikeMark1") as Label,
		get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/ResolutionStrikeRow/ResolutionStrikeMark2") as Label,
		get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/ResolutionStrikeRow/ResolutionStrikeMark3") as Label,
	]
	resolve_ritual_advance_button = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Btn_RESOLUTION_NEXT") as Button

	# Mid choice
	intermediate_choice_modal = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE") as Control
	intermediate_choice_panel = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE") as Control
	intermediate_choice_label = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Lbl_MID_CHOICE_TITLEPanel/Lbl_MID_CHOICE_TITLE") as Label
	intermediate_choice_audience_label = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Lbl_MID_CHOICE_AUDIENCEPanel/Lbl_MID_CHOICE_AUDIENCE") as Label
	intermediate_choice_placa_button = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0") as Button
	intermediate_choice_provoca_button = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_1") as Button

	# Push your luck
	push_luck_modal = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK") as Control
	push_luck_panel = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK") as Control
	push_luck_title = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_TITLEPanel/Lbl_PUSH_YOUR_LUCK_TITLE") as Label
	push_luck_info = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_BODYPanel/Lbl_PUSH_YOUR_LUCK_BODY") as Label
	push_luck_details = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_SUBTITLEPanel/Lbl_PUSH_YOUR_LUCK_SUBTITLE") as Label
	push_luck_audience_label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_HINTPanel/Lbl_PUSH_YOUR_LUCK_HINT") as Label
	push_luck_audience_reason = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_FOOTERPanel/Lbl_PUSH_YOUR_LUCK_FOOTER") as Label
	push_luck_cashout_button = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Btn_PUSH_YOUR_LUCK_CASHOUT") as Button
	push_luck_cashout_note = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Lbl_PUSH_YOUR_LUCK_CHOICE_0Panel/Lbl_PUSH_YOUR_LUCK_CHOICE_0") as Label
	push_luck_condanna_button = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Btn_PUSH_YOUR_LUCK_CONDANNA") as Button
	push_luck_condanna_note = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Lbl_PUSH_YOUR_LUCK_CHOICE_1Panel/Lbl_PUSH_YOUR_LUCK_CHOICE_1") as Label
	push_luck_double_button = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Btn_PUSH_YOUR_LUCK_DOUBLE") as Button
	push_luck_double_note = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICEPanel/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICE") as Label

	# End run
	scars_detail_panel = get_node_or_null("UI_RunRoot/ScarsDetailPanel") as Control
	scars_detail_text = get_node_or_null("UI_RunRoot/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailTextPanel/ScarsDetailText") as RichTextLabel
	scars_detail_close = get_node_or_null("UI_RunRoot/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailClose") as Button
	game_over_modal = get_node_or_null("UI_RunRoot/Phase_END_RUN") as Control
	game_over_panel = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN") as Control
	verdict_header = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_TITLE") as Label
	verdict_icon = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndingIcon") as TextureRect
	verdict_outcome = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_SUBTITLEPanel/Lbl_END_RUN_SUBTITLE") as Label
	verdict_sentence_label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_BODY") as Label
	verdict_charge_label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_HINTPanel/Lbl_END_RUN_HINT") as Label
	game_over_scroll = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL") as ScrollContainer
	ending_text = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL/Box_END_RUN_MARGIN/Lbl_END_RUN_FOOTERPanel/Lbl_END_RUN_FOOTER") as RichTextLabel
	verdict_sections = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS") as Control
	verdict_pacts_text = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_PACTS/Lbl_END_RUN_PACTS_BODYPanel/Lbl_END_RUN_PACTS_BODY") as RichTextLabel
	verdict_condanne_text = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CONDANNE/Lbl_END_RUN_CONDANNE_BODYPanel/Lbl_END_RUN_CONDANNE_BODY") as RichTextLabel
	verdict_crowd_section = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD") as Control
	verdict_crowd_text = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_BODYPanel/Lbl_END_RUN_CROWD_BODY") as Label
	restart_button = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_RESTART") as Button
	next_bet_button = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_NEXT_BET") as Button
	quit_button = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_QUIT") as Button

func _init_phase_node_map() -> void:
	_phase_node_map = {
		RunPhaseContract.MAIN_MENU: bet_modal,
		RunPhaseContract.RUN_INIT: bet_modal,
		RunPhaseContract.BET_PRESENT: bet_modal,
		RunPhaseContract.BET_COMMITTED: pact_sealed_modal,
		RunPhaseContract.INTERMEDIATE_CHOICE: intermediate_choice_modal,
		RunPhaseContract.PUSH_YOUR_LUCK: push_luck_modal,
		RunPhaseContract.NEXT_BET: bet_modal,
		RunPhaseContract.GAME_OVER: game_over_modal,
	}

func _verify_phase_paths() -> void:
	if get_node_or_null("UI_RunRoot") == null:
		push_error("UI: missing node UI_RunRoot")
	for path: String in _PHASE_CONTAINER_PATHS:
		if get_node_or_null(path) == null:
			push_error("UI: missing node %s" % path)
	for phase_key: Variant in _phase_node_map.keys():
		var mapped_phase: int = int(phase_key)
		var mapped_node: Control = _phase_node_map.get(mapped_phase, null) as Control
		if mapped_node == null:
			push_error("UI: missing phase mapping target for %s" % RunPhaseContract.get_phase_name(mapped_phase))

func show_phase(phase: int) -> void:
	_last_shown_phase = phase
	if _phase_node_map.is_empty():
		push_error("UI: missing phase mapping for %s" % RunPhaseContract.get_phase_name(phase))
		return
	for mapped_phase_key: Variant in _phase_node_map.keys():
		var mapped_phase: int = int(mapped_phase_key)
		var phase_node: Control = _phase_node_map.get(mapped_phase, null) as Control
		if phase_node != null:
			phase_node.visible = false
	var target: Control = _phase_node_map.get(phase, null) as Control
	if target == null:
		push_error("UI: unmapped phase %s" % RunPhaseContract.get_phase_name(phase))
		_refresh_modal_dimmer()
		return
	target.visible = true
	_current_modal = target
	_reset_sign_feedback()
	_reset_pyl_lock_state()
	_reset_pact_tablet_state()
	_reset_gesture_choice_state()
	_reset_judgment_seal_state()
	if phase == RunPhaseContract.BET_PRESENT or phase == RunPhaseContract.NEXT_BET:
		_reset_decision_surface(bet_panel, _bet_buttons, condanna_focus_label)
	elif phase == RunPhaseContract.PUSH_YOUR_LUCK:
		_reset_decision_surface(push_luck_panel, _collect_pyl_buttons(), push_luck_audience_reason)
	if hud_top_left_stats_box != null:
		hud_top_left_stats_box.visible = phase != RunPhaseContract.GAME_OVER
	if arena_theme_title_panel != null:
		arena_theme_title_panel.visible = false
	if arena_theme_subtitle_panel != null:
		arena_theme_subtitle_panel.visible = false
	_apply_visual_tier(_active_visual_tier)
	_set_silence_overlay_active(_silence_overlay_active)
	_refresh_modal_dimmer()

func _validate_ui_boot() -> bool:
	var errors: Array[String] = []
	if get_node_or_null("UI_RunRoot/BettingCircle") == null:
		errors.append("UI_RunRoot/BettingCircle")
	var ending_text_path: String = "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL/Box_END_RUN_MARGIN/Lbl_END_RUN_FOOTERPanel/Lbl_END_RUN_FOOTER"
	if get_node_or_null(ending_text_path) == null:
		errors.append(ending_text_path)
	var required_nodes: Array[String] = [
		"UI_RunRoot/Phase_INTRO",
		"UI_RunRoot/Phase_RESOLUTION",
		"UI_RunRoot/Phase_MID_CHOICE",
		"UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE",
		"UI_RunRoot/Phase_PUSH_YOUR_LUCK",
		"UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK",
		"UI_RunRoot/Phase_END_RUN",
		"UI_RunRoot/Phase_END_RUN/Panel_END_RUN",
		"HUD/PressureRail/PressureRailMargin/EscalationRow/EscalationLabelPanel/EscalationLabel",
		"HUD/PressureRail/PressureRailMargin/EscalationRow/PressureStateLabelPanel/PressureStateLabel",
		"UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons",
	]
	for node_path: String in required_nodes:
		if get_node_or_null(node_path) == null:
			errors.append(node_path)
	if errors.size() > 0:
		_show_boot_fail(errors)
		return false
	return true

func _disable_ui_interactions() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	set_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)

func _validate_ui_contract_or_show_boot_fail() -> bool:
	var missing: Array[String] = []
	for contract_path in _BOOT_FAIL_CONTRACT_PATHS:
		var label_path: String = str(contract_path.get("label", ""))
		var fallback_path: String = str(contract_path.get("fallback", ""))
		if label_path == "":
			continue
		var has_primary: bool = has_node(label_path)
		var has_fallback: bool = fallback_path != "" and has_node(fallback_path)
		if not has_primary and not has_fallback:
			missing.append(label_path)
	if missing.is_empty():
		return true
	_show_boot_fail(missing)
	return false

func _show_boot_fail(missing: Array[String]) -> void:
	if run_safe_margin != null:
		run_safe_margin.visible = false
	if modal_dimmer != null:
		modal_dimmer.visible = false
	for path: String in _PHASE_CONTAINER_PATHS:
		var phase_node: Control = get_node_or_null(path) as Control
		if phase_node != null:
			phase_node.visible = false
	if boot_fail_body != null:
		boot_fail_body.text = "%s\n%s\n- %s\n\n%s" % [
			tr("Interfaccia non inizializzata."),
			tr("Elementi mancanti:"),
			"\n- ".join(missing),
			tr("Torna al menu e riavvia."),
		]
	if boot_fail_overlay != null:
		boot_fail_overlay.visible = true
	push_error("UI BOOT FAIL: missing=%s" % ", ".join(missing))

func _on_boot_fail_back_to_menu() -> void:
	_play_sfx(&"button_click")
	_emit_game_event_signal_if_available(&"request_show_main_menu")

func _wire_intro_phase_buttons() -> void:
	if intro_select_win_button != null:
		var win_callable: Callable = Callable(self, "_on_bet_win_pressed")
		if not intro_select_win_button.pressed.is_connected(win_callable):
			intro_select_win_button.pressed.connect(win_callable)
		_wire_sign_preview(intro_select_win_button)
	if intro_select_fast_button != null:
		var fast_callable: Callable = Callable(self, "_on_bet_fast_pressed")
		if not intro_select_fast_button.pressed.is_connected(fast_callable):
			intro_select_fast_button.pressed.connect(fast_callable)
		_wire_sign_preview(intro_select_fast_button)

func _show_scar_popup(scar: Dictionary) -> void:
	if scar_popup == null:
		return
	var scar_name: String = str(scar.get("name", ""))
	if scar_name == "":
		scar_name = str(scar.get("id", "Scar"))
	var scar_story: String = str(scar.get("narrative_text", ""))
	if scar_story == "":
		scar_story = str(scar.get("story", ""))
	var effect_text: String = str(scar.get("effect_text", ""))
	if effect_text == "":
		effect_text = str(scar.get("effect", ""))
	var text_lines: Array[String] = ["[center][b]%s[/b][/center]" % scar_name]
	if scar_story != "":
		text_lines.append("[i]%s[/i]" % scar_story)
	if effect_text != "":
		text_lines.append(tr("[b]Effetto:[/b] %s") % effect_text)
	scar_popup.text = "\n".join(text_lines)
	if scar_popup_panel == null:
		return
	scar_popup_panel.visible = true
	scar_popup_panel.modulate.a = 0.0
	scar_popup_panel.scale = Vector2(0.96, 0.96)
	if _scar_popup_tween != null and _scar_popup_tween.is_valid():
		_scar_popup_tween.kill()
	_scar_popup_tween = create_tween()
	_scar_popup_tween.set_trans(Tween.TRANS_QUAD)
	_scar_popup_tween.set_ease(Tween.EASE_OUT)
	_scar_popup_tween.tween_property(scar_popup_panel, "modulate:a", 1.0, 0.15)
	_scar_popup_tween.parallel().tween_property(scar_popup_panel, "scale", Vector2(1.02, 1.02), 0.15)
	_scar_popup_tween.tween_interval(1.0)
	_scar_popup_tween.set_ease(Tween.EASE_IN)
	_scar_popup_tween.tween_property(scar_popup_panel, "modulate:a", 0.0, 0.25)
	_scar_popup_tween.parallel().tween_property(scar_popup_panel, "scale", Vector2(0.98, 0.98), 0.25)
	_scar_popup_tween.tween_callback(Callable(self, "_hide_scar_popup"))

func _hide_scar_popup() -> void:
	if scar_popup_panel != null:
		scar_popup_panel.visible = false

func _should_show_arena_resolution_overlay() -> bool:
	if arena_resolution_label == null:
		return false
	if _run_manager_port == null:
		return false
	return _run_manager_port.is_visual_only()

func _show_arena_resolution_overlay() -> void:
	if arena_resolution_label == null:
		return
	if resolve_ritual_modal != null and resolve_ritual_modal.visible:
		return
	arena_resolution_label.visible = true
	if arena_resolution_panel != null:
		arena_resolution_panel.visible = true
	arena_resolution_label.modulate.a = 0.0
	if _arena_resolution_tween != null and _arena_resolution_tween.is_valid():
		_arena_resolution_tween.kill()
	_arena_resolution_tween = create_tween()
	_arena_resolution_tween.set_trans(Tween.TRANS_QUAD)
	_arena_resolution_tween.set_ease(Tween.EASE_OUT)
	_arena_resolution_tween.tween_property(arena_resolution_label, "modulate:a", 1.0, 0.18)
	_arena_resolution_tween.tween_interval(0.7)
	_arena_resolution_tween.set_ease(Tween.EASE_IN)
	_arena_resolution_tween.tween_property(arena_resolution_label, "modulate:a", 0.0, 0.25)
	_arena_resolution_tween.tween_callback(Callable(self, "_hide_arena_resolution_overlay"))

func _hide_arena_resolution_overlay() -> void:
	if arena_resolution_label != null:
		arena_resolution_label.visible = false
	if arena_resolution_panel != null:
		arena_resolution_panel.visible = false

func _build_resolution_body(primary_text: String) -> String:
	var body: String = primary_text.strip_edges()
	var context_line: String = tr(_pending_resolution_context_line.strip_edges())
	if context_line == "":
		return body
	if body == "" or body == context_line:
		return context_line
	return "%s\n%s" % [context_line, body]

func _set_resolve_ritual_body(primary_text: String) -> void:
	if resolve_ritual_subtitle == null:
		return
	resolve_ritual_subtitle.text = _build_resolution_body(primary_text)
	_force_label_readable(resolve_ritual_subtitle)

func _force_label_readable(label: Label) -> void:
	if label == null:
		return
	label.visible = true
	label.modulate.a = 1.0
	label.clip_text = false
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 0.0
	label.offset_top = 0.0
	label.offset_right = 0.0
	label.offset_bottom = 0.0
	label.custom_minimum_size = Vector2(0.0, 72.0)
	var parent_canvas := label.get_parent() as CanvasItem
	if parent_canvas != null:
		parent_canvas.visible = true
		parent_canvas.modulate.a = 1.0
	if audience_context_label != null:
		audience_context_label.visible = false
	if audience_context_panel != null:
		audience_context_panel.visible = false
	_hide_arena_resolution_overlay()

func show_countdown(seconds: int = 3) -> void:
	if countdown_label == null:
		return
	countdown_label.visible = true
	if countdown_panel != null:
		countdown_panel.visible = true
	for i in range(seconds, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO"
	await get_tree().create_timer(0.5).timeout
	countdown_label.visible = false
	if countdown_panel != null:
		countdown_panel.visible = false

# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
# Preconditions: RunManager emitted GameEvents.run_started; UI nodes are initialized.
# Postconditions: HUD/modals reset and visible state reflects a fresh run.
func _on_run_started() -> void:
	_reset_pact_tablet_state()
	_reset_gesture_choice_state()
	_reset_final_dossier_route_interaction()
	_refresh_runtime_group_cache(false)
	if escalation_row != null:
		escalation_row.visible = true
	if escalation_bar != null:
		escalation_bar.visible = true
	_escalation_level = 0
	_update_escalation_bar()
	set_active_bet_text(tr("Nessuna scommessa attiva"))
	_set_bet_modal(false)
	_reset_bet_confirmation()
	# IMPORTANT: if the player picked FAST, we must keep the FAST timer state into the round.
	# countdown_requested will drive the actual seconds during the round.
	if not _fast_countdown_active:
		_reset_fast_countdown()
	else:
		if fast_countdown_label != null:
			fast_countdown_label.visible = true
			if fast_countdown_panel != null:
				fast_countdown_panel.visible = true
			fast_countdown_label.text = "FAST: %ds" % FAST_SELECTION_SECONDS
			fast_countdown_label.modulate.a = 1.0
	_set_push_luck_modal(false)
	_pending_bets = []
	_last_ritual_outcome_snapshot = {}
	_set_game_over_modal(false)
	_last_register_message = ""
	_last_register_message_key = ""
	_last_register_final = false
	_last_register_ending_key = ""
	_last_ending_icon_path = ""
	_last_next_bet_enabled = false
	if next_bet_button != null:
		next_bet_button.visible = false
		next_bet_button.disabled = true
	_last_finale_title = tr("PERCORSO FALLITO")
	_last_finale_title_key = "PERCORSO FALLITO"
	_last_finale_text = ""
	_last_final_report = {}
	_last_finale_scars = []
	_last_finale_ending_id = ""
	_last_finale_seed = 0
	_last_finale_stats = {}
	_last_finale_hint = ""
	_last_verdict_pacts = []
	_last_verdict_condanne = []
	_last_verdict_crowd_line = ""
	_last_verdict_crowd_line_key = ""
	_last_verdict_outcome = &"LOSS"
	_special_arena_payload = {}
	if special_arena_label != null:
		special_arena_label.visible = false
	if condanna_focus_label != null:
		condanna_focus_label.visible = false
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	if not _fast_countdown_active:
		_reset_fast_countdown()
	_refresh_modal_dimmer()
	_hide_scars_detail()
	if controls_hint_panel != null:
		controls_hint_panel.visible = _controls_first_run_active and (not _has_seen_controls)

func _on_sentence_banner_requested(payload: Dictionary) -> void:
	if sentence_banner == null:
		return
	if sentence_title_label == null or sentence_rule_label == null or sentence_doom_label == null:
		return
	var title: String = str(payload.get("sentence_title", "SENTENZA"))
	var rule: String = str(payload.get("sentence_rule", "VINCI"))
	var doom: String = str(payload.get("sentence_doom", ""))
	sentence_title_label.text = title
	sentence_rule_label.text = rule
	sentence_doom_label.text = doom
	sentence_banner.visible = true
	_sentence_banner_sequence_id += 1
	var sequence_id: int = _sentence_banner_sequence_id
	await get_tree().create_timer(SENTENCE_BANNER_SECONDS).timeout
	if sequence_id != _sentence_banner_sequence_id:
		return
	if sentence_banner != null:
		sentence_banner.visible = false

func _on_audience_context_line_emitted(text: String) -> void:
	if audience_context_label == null:
		return
	_pending_resolution_context_line = text.strip_edges()
	var localized_text: String = tr(_pending_resolution_context_line)
	if resolve_ritual_modal != null and resolve_ritual_modal.visible:
		_set_resolve_ritual_body(_resolve_ritual_base_body)
		return
	audience_context_label.text = localized_text
	audience_context_label.visible = localized_text != ""
	if audience_context_panel != null:
		audience_context_panel.visible = localized_text != ""

func _clear_audience_context_overlay() -> void:
	_pending_resolution_context_line = ""
	if audience_context_label != null:
		audience_context_label.text = ""
		audience_context_label.visible = false
	if audience_context_panel != null:
		audience_context_panel.visible = false



func _on_register_annotation(payload: Dictionary) -> void:
	if register_blocker == null or register_annotation_label == null:
		return
	var text: String = str(payload.get("text", "")).strip_edges()
	if text == "":
		return
	var duration: float = float(payload.get("duration", REGISTER_ANNOTATION_FALLBACK_SECONDS))
	if duration <= 0.0:
		duration = REGISTER_ANNOTATION_FALLBACK_SECONDS
	register_annotation_label.text = text
	register_blocker.visible = true
	register_blocker.modulate.a = 0.0
	if _register_annotation_tween != null and _register_annotation_tween.is_valid():
		_register_annotation_tween.kill()
	_register_annotation_tween = create_tween()
	_register_annotation_tween.set_trans(Tween.TRANS_QUAD)
	_register_annotation_tween.set_ease(Tween.EASE_OUT)
	_register_annotation_tween.tween_property(register_blocker, "modulate:a", 1.0, 0.12)
	_register_annotation_tween.tween_interval(duration)
	_register_annotation_tween.set_ease(Tween.EASE_IN)
	_register_annotation_tween.tween_property(register_blocker, "modulate:a", 0.0, 0.2)
	_register_annotation_tween.tween_callback(Callable(self, "_hide_register_annotation"))

func _hide_register_annotation() -> void:
	if register_blocker != null:
		register_blocker.visible = false

func _on_micro_interpretive_quick_cut_requested(payload: Dictionary) -> void:
	if quick_cut_blocker == null or quick_cut_shade == null or quick_cut_label == null or quick_cut_label_panel == null:
		return
	if _quick_cut_tween != null and _quick_cut_tween.is_valid():
		_quick_cut_tween.kill()
	var duration: float = clampf(float(payload.get("duration", 1.0)), 0.8, QUICK_CUT_MAX_SECONDS)
	var show_text: bool = bool(payload.get("show_text", true))
	quick_cut_blocker.visible = true
	quick_cut_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	var desaturation: float = clampf(float(payload.get("desaturation", 0.75)), 0.70, 0.85)
	var luminance_dim: float = clampf(float(payload.get("luminance_dim", 0.10)), 0.0, 0.15)
	var base: float = clampf(1.0 - luminance_dim, 0.0, 1.0)
	var neutral: float = clampf(base * (1.0 - desaturation) + 0.5 * desaturation, 0.0, 1.0)
	quick_cut_shade.color = Color(neutral, neutral, neutral, desaturation)
	quick_cut_label.visible = show_text
	quick_cut_label_panel.visible = show_text
	if show_text:
		var text: String = str(payload.get("text", "")).strip_edges()
		if text.length() > 60:
			text = text.substr(0, 60)
		quick_cut_label.text = text
		quick_cut_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		quick_cut_label.position = Vector2.ZERO
		quick_cut_label_panel.add_theme_constant_override("separation", 0)
		_apply_quick_cut_glitch(str(payload.get("glitch", "")))
	await get_tree().create_timer(duration).timeout
	if quick_cut_blocker != null:
		quick_cut_blocker.visible = false
		quick_cut_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _apply_quick_cut_glitch(glitch: String) -> void:
	if quick_cut_label == null:
		return
	match glitch:
		"text_shift":
			quick_cut_label.position = Vector2(1.0, 0.0)
			await get_tree().process_frame
			if quick_cut_label != null:
				quick_cut_label.position = Vector2.ZERO
		"char_offset":
			quick_cut_label.position = Vector2(0.0, -1.0)
			await get_tree().process_frame
			if quick_cut_label != null:
				quick_cut_label.position = Vector2.ZERO
		"opacity_jitter":
			quick_cut_label.modulate.a = 0.95
			await get_tree().create_timer(0.08).timeout
			if quick_cut_label != null:
				quick_cut_label.modulate.a = 1.0
		"kerning_compress":
			if quick_cut_label_panel != null:
				quick_cut_label_panel.add_theme_constant_override("separation", -1)
			await get_tree().process_frame
			if quick_cut_label_panel != null:
				quick_cut_label_panel.add_theme_constant_override("separation", 0)
		_:
			return

func _on_run_finale_selected(payload: Dictionary) -> void:
	if payload.has("title"):
		_last_finale_title_key = str(payload["title"])
	else:
		_last_finale_title_key = "PERCORSO FALLITO"
	_last_finale_title = tr(_last_finale_title_key)
	_last_final_report = (payload.get("final_report", {}) as Dictionary).duplicate(true)
	if payload.has("text"):
		_last_finale_text = _localize_final_report(_last_final_report, str(payload["text"]))
	else:
		_last_finale_text = ""
	if payload.has("scars"):
		_last_finale_scars = (payload["scars"] as Array).duplicate(true)
	else:
		_last_finale_scars = []
	if payload.has("ending_id"):
		_last_finale_ending_id = str(payload["ending_id"])
	else:
		_last_finale_ending_id = ""
	if payload.has("seed"):
		_last_finale_seed = int(payload["seed"])
	else:
		_last_finale_seed = 0
	if payload.has("stats"):
		_last_finale_stats = payload["stats"] as Dictionary
	else:
		_last_finale_stats = {}
	var finale_meta: Dictionary = payload.get("meta", {}) as Dictionary
	_last_register_message_key = str(finale_meta.get("register_message", ""))
	_last_register_message = tr(_last_register_message_key)
	_last_register_final = bool(finale_meta.get("register_final", false))
	_last_register_ending_key = str(finale_meta.get("register_ending_key", ""))
	if _last_register_final:
		var ending_ui_data: Dictionary = ENDING_UI_MAP.get(_last_register_ending_key, {}) as Dictionary
		_last_finale_title_key = str(ending_ui_data.get("title", "FASCICOLO CHIUSO"))
		_last_finale_title = tr(_last_finale_title_key)
		_last_ending_icon_path = str(ending_ui_data.get("icon", ENDING_ICON_FALLBACK_PATH))
	else:
		_last_finale_title_key = "AGGIORNAMENTO DEL REGISTRO"
		_last_finale_title = tr(_last_finale_title_key)
		_last_ending_icon_path = ""
	_last_next_bet_enabled = bool(finale_meta.get("next_bet_enabled", false))
	if next_bet_button != null:
		next_bet_button.visible = _last_next_bet_enabled
		next_bet_button.disabled = not _last_next_bet_enabled
		next_bet_button.text = tr("PROSSIMA SCOMMESSA")
	var pacts_payload: Array = []
	if payload.has("pacts_signed"):
		pacts_payload = payload.get("pacts_signed", []) as Array
	elif payload.has("pacts"):
		pacts_payload = payload.get("pacts", []) as Array
	_last_verdict_pacts = _coerce_string_list(pacts_payload)
	var condanne_payload: Array = payload.get("condanne_this_run", []) as Array
	_last_verdict_condanne = _coerce_string_list(condanne_payload)
	_last_verdict_crowd_line_key = str(payload.get("last_crowd_line", ""))
	_last_verdict_crowd_line = tr(_last_verdict_crowd_line_key)
	var outcome_value: Variant = payload.get("outcome", &"LOSS")
	_last_verdict_outcome = StringName(str(outcome_value))
	var summary: Dictionary = _build_verdict_summary(payload, pacts_payload, condanne_payload)
	_last_verdict_sentence = VerdictLinesScript.pick_sentence(summary)
	_last_verdict_charge = VerdictLinesScript.pick_charge(summary)
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	_set_final_dossier_state(FINAL_DOSSIER_STATE_OPEN)
	_reset_final_dossier_route_interaction()
	_refresh_verdict_panel()

func _on_run_failed() -> void:
	_reset_pact_tablet_state()
	_reset_gesture_choice_state()
	_set_bet_modal(false)
	if escalation_row != null:
		escalation_row.visible = false
	if escalation_bar != null:
		escalation_bar.visible = false
	if special_arena_label != null:
		special_arena_label.visible = false
	if condanna_focus_label != null:
		condanna_focus_label.visible = false
	_reset_fast_countdown()
	_set_push_luck_modal(false)
	_set_game_over_modal(true)
	_set_verdict_mode(true)
	if next_bet_button != null:
		next_bet_button.visible = _last_next_bet_enabled
		next_bet_button.disabled = not _last_next_bet_enabled
	if restart_button != null:
		restart_button.text = tr("NUOVO PERCORSO")
	if quit_button != null:
		quit_button.text = tr("TORNA AL MENU")
	_last_finale_hint = ""
	if _last_register_final and _last_register_message == "":
		_last_register_message_key = "fascicolo registrato"
		_last_register_message = fmt_system_state(tr(_last_register_message_key))
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	_refresh_verdict_panel()
	await _play_verdict_reveal_sequence()
	_reset_fast_countdown()
	_refresh_end_run_button_visuals()
	_refresh_modal_dimmer()
	_hide_scars_detail()
	if controls_hint_panel != null and _has_seen_controls:
		controls_hint_panel.visible = false

func _on_run_ended(_reason: String, _summary: Dictionary) -> void:
	if game_over_modal == null:
		return
	if game_over_modal.visible:
		return
	_set_game_over_modal(true)
	_refresh_modal_dimmer()

func _coerce_string_list(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text: String = str(value).strip_edges()
		if text != "":
			result.append(text)
	return result

func _localize_final_report(report: Dictionary, fallback_text: String = "") -> String:
	if report.is_empty():
		return tr(fallback_text)
	var opening: String = tr(str(report.get("opening", "")))
	var fracture: String = tr(str(report.get("fracture", "")))
	var final_state: String = tr(str(report.get("final_state", "")))
	var pattern_lines: PackedStringArray = []
	for pattern_value: Variant in report.get("patterns", []) as Array:
		pattern_lines.append(tr(str(pattern_value)))
	var sections: PackedStringArray = []
	sections.append("%s\n%s" % [tr("I. APERTURA - CONSTATAZIONE"), opening])
	sections.append("%s\n- %s" % [tr("II. CORPO - LETTURA DEI PATTERN"), "\n- ".join(pattern_lines)])
	if fracture != "":
		sections.append("%s\n%s" % [tr("III. FRATTURA"), fracture])
	sections.append(tr("Stato finale: %s.") % final_state)
	return "\n\n".join(sections)

func _format_verdict_list(values: Array[String]) -> String:
	if values.is_empty():
		return "-"
	var lines: PackedStringArray = []
	var visible_count: int = mini(values.size(), 2)
	for index: int in range(visible_count):
		lines.append("- %s" % values[index])
	if values.size() > visible_count:
		lines.append(tr("+%d altre") % (values.size() - visible_count))
	return "\n".join(lines)

func _format_verdict_pacts_list(values: Array[String]) -> String:
	if values.is_empty():
		return fmt_register_line(tr("rinunciato"), tr("continuato"))
	return fmt_register_line(tr("accettato"), tr("%d condizioni registrate") % values.size())

func _build_smart_register_summary() -> String:
	var pact_count: int = _last_verdict_pacts.size()
	var condanna_count: int = _last_verdict_condanne.size()
	var pressure_peak: int = _resolve_final_pressure_max()
	var outcome_line: String = tr("Il Registro conserva la traccia del percorso.")
	if _last_register_final:
		outcome_line = tr("Il Registro chiude il fascicolo e classifica l'esito.")
	elif _last_verdict_outcome == &"CASHOUT":
		outcome_line = tr("Hai lasciato l'arena con la posta riconosciuta.")
	elif _last_verdict_outcome == &"WIN":
		outcome_line = tr("Il patto regge: il percorso puo proseguire.")
	else:
		outcome_line = tr("La condanna viene accettata e il percorso resta segnato.")
	var pressure_line: String = tr("Pressione massima: %d/%d.") % [pressure_peak, _get_pressure_max(_escalation_max)]
	var unlock_line: String = tr("Patti e sblocchi sono stati aggiornati nell'Archivio.")
	if condanna_count > 0:
		unlock_line = tr("%d condanne archiviate; il dettaglio resta nell'Archivio.") % condanna_count
	if pact_count > 0:
		return "%s\n%s %s" % [outcome_line, pressure_line, unlock_line]
	return "%s\n%s %s" % [outcome_line, pressure_line, tr("Nessun patto aggiuntivo da elencare: consulta l'Archivio per gli sblocchi.")]

func _resolve_condanna_titles(values: Array[String]) -> Array[String]:
	if values.is_empty():
		return []
	var entries: Array[CondannaData] = CondannaDataScript.defaults()
	var titles_by_id: Dictionary = {}
	for entry in entries:
		titles_by_id[str(entry.id)] = entry.title
	var result: Array[String] = []
	for value in values:
		var key: String = value
		var title: String = str(titles_by_id.get(key, ""))
		if title == "":
			title = value
		result.append(tr(title))
	return result

func _refresh_verdict_panel() -> void:
	if _last_finale_title_key != "":
		_last_finale_title = tr(_last_finale_title_key)
	if not _last_final_report.is_empty():
		_last_finale_text = _localize_final_report(_last_final_report, _last_finale_text)
	if _last_register_message_key != "":
		_last_register_message = tr(_last_register_message_key)
	if _last_verdict_crowd_line_key != "":
		_last_verdict_crowd_line = tr(_last_verdict_crowd_line_key)
	if restart_button != null:
		restart_button.text = tr("NUOVO PERCORSO")
	if next_bet_button != null:
		next_bet_button.text = tr("PROSSIMA SCOMMESSA")
	if quit_button != null:
		quit_button.text = tr("TORNA AL MENU")
	var pacts_title := get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_PACTS/Lbl_END_RUN_PACTS_TITLEPanel/Lbl_END_RUN_PACTS_TITLE") as Label
	if pacts_title != null:
		pacts_title.text = tr("PATTI FIRMATI")
	var condanne_title := get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CONDANNE/Lbl_END_RUN_CONDANNE_TITLEPanel/Lbl_END_RUN_CONDANNE_TITLE") as Label
	if condanne_title != null:
		condanne_title.text = tr("CONDANNE")
	var crowd_title := get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_TITLEPanel/Lbl_END_RUN_CROWD_TITLE") as Label
	if crowd_title != null:
		crowd_title.text = tr("ULTIMA VOCE")
	if verdict_header != null:
		var title_text: String = _last_finale_title.strip_edges()
		if title_text == "":
			title_text = tr("AGGIORNAMENTO DEL REGISTRO")
		verdict_header.text = title_text
	if verdict_outcome != null:
		if _last_register_final:
			verdict_outcome.text = tr("Protocollo di classificazione completato.")
		elif _last_verdict_outcome == &"CASHOUT":
			verdict_outcome.text = tr("Incasso registrato.")
		elif _last_verdict_outcome == &"WIN":
			verdict_outcome.text = tr("Arena superata.")
		else:
			verdict_outcome.text = tr("Condanna registrata.")
	if verdict_icon != null:
		if _last_register_final:
			var icon_path: String = _last_ending_icon_path
			if icon_path == "" or not ResourceLoader.exists(icon_path, "Texture2D"):
				icon_path = ENDING_ICON_FALLBACK_PATH
			var icon_texture: Texture2D = ResourceLoader.load(icon_path, "Texture2D") as Texture2D
			verdict_icon.texture = icon_texture
			verdict_icon.visible = icon_texture != null
		else:
			verdict_icon.texture = null
			verdict_icon.visible = false
	if verdict_sentence_label != null:
		verdict_sentence_label.text = _build_smart_register_summary()
	if verdict_charge_label != null:
		var status_text: String = tr("Il dettaglio degli sblocchi resta consultabile nell'Archivio.")
		if _last_next_bet_enabled:
			status_text = tr("Il Registro resta aperto: scegli se proseguire o lasciare l'arena.")
		verdict_charge_label.text = status_text
	if ending_text != null:
		_refresh_ending_text()
		if ending_text.text.strip_edges() == "":
			ending_text.text = tr("[center][i]Sigillo del Registro - la folla arretra, il verbale resta.[/i][/center]")
	if verdict_pacts_text != null:
		var pacts_text: String = _format_verdict_pacts_list(_last_verdict_pacts).strip_edges()
		verdict_pacts_text.text = pacts_text
		var pacts_panel := verdict_pacts_text.get_parent() as CanvasItem
		if pacts_panel != null:
			pacts_panel.visible = true
			var pacts_title_panel := pacts_panel.get_parent().get_node_or_null("Lbl_END_RUN_PACTS_TITLEPanel") as CanvasItem
			if pacts_title_panel != null:
				pacts_title_panel.visible = true
	if verdict_condanne_text != null:
		var condanne_titles: Array[String] = _resolve_condanna_titles(_last_verdict_condanne)
		var condanne_text: String = _format_verdict_list(condanne_titles).strip_edges()
		verdict_condanne_text.text = condanne_text
		var condanne_panel := verdict_condanne_text.get_parent() as CanvasItem
		if condanne_panel != null:
			condanne_panel.visible = true
			var condanne_title_panel := condanne_panel.get_parent().get_node_or_null("Lbl_END_RUN_CONDANNE_TITLEPanel") as CanvasItem
			if condanne_title_panel != null:
				condanne_title_panel.visible = true
	var crowd_line: String = _last_verdict_crowd_line.strip_edges()
	if verdict_crowd_section != null:
		verdict_crowd_section.visible = true
	if verdict_crowd_text != null:
		verdict_crowd_text.text = crowd_line if crowd_line != "" else "-"
	if verdict_sections != null:
		verdict_sections.visible = true
	if game_over_scroll != null:
		game_over_scroll.visible = false
	if ending_text != null:
		ending_text.visible = false
	_apply_final_dossier_palette()

func _set_verdict_canvas_alpha(alpha: float) -> void:
	var targets: Array[CanvasItem] = []
	if verdict_header != null:
		targets.append(verdict_header)
	if verdict_outcome != null:
		targets.append(verdict_outcome)
	if verdict_icon != null and verdict_icon.visible:
		targets.append(verdict_icon)
	if verdict_sentence_label != null:
		targets.append(verdict_sentence_label)
	if verdict_charge_label != null:
		targets.append(verdict_charge_label)
	if verdict_sections != null:
		targets.append(verdict_sections)
	if ending_text != null:
		targets.append(ending_text)
	for node in targets:
		node.modulate.a = alpha

func _reveal_verdict_group(group: Array[CanvasItem], sequence_id: int) -> bool:
	var reveal_targets: Array[CanvasItem] = []
	for node in group:
		if node != null and node.visible:
			node.modulate.a = 0.0
			reveal_targets.append(node)
	if reveal_targets.is_empty():
		return sequence_id == _verdict_reveal_sequence_id
	if _verdict_reveal_tween != null and _verdict_reveal_tween.is_valid():
		_verdict_reveal_tween.kill()
	_verdict_reveal_tween = create_tween()
	_verdict_reveal_tween.set_trans(Tween.TRANS_SINE)
	_verdict_reveal_tween.set_ease(Tween.EASE_OUT)
	for node in reveal_targets:
		_verdict_reveal_tween.parallel().tween_property(node, "modulate:a", 1.0, VERDICT_REVEAL_STEP_SECONDS)
	await _verdict_reveal_tween.finished
	if sequence_id != _verdict_reveal_sequence_id:
		return false
	await get_tree().create_timer(VERDICT_REVEAL_HOLD_SECONDS).timeout
	return sequence_id == _verdict_reveal_sequence_id

func _play_verdict_reveal_sequence() -> void:
	_verdict_reveal_sequence_id += 1
	_set_verdict_canvas_alpha(1.0)
	_set_end_run_buttons_enabled(true)

func _wait_verdict_delay(seconds: float, sequence_id: int) -> bool:
	if seconds <= 0.0:
		return sequence_id == _verdict_reveal_sequence_id
	await get_tree().create_timer(seconds).timeout
	return sequence_id == _verdict_reveal_sequence_id

func _set_end_run_buttons_enabled(enabled: bool) -> void:
	if restart_button != null:
		restart_button.visible = true
		restart_button.disabled = not enabled
	if quit_button != null:
		quit_button.visible = true
		quit_button.disabled = not enabled
	if next_bet_button != null:
		next_bet_button.visible = _last_next_bet_enabled
		next_bet_button.disabled = (not enabled) or (not _last_next_bet_enabled)
	_refresh_end_run_button_visuals()

func _refresh_end_run_button_visuals() -> void:
	_apply_end_run_button_visual(restart_button, true)
	_apply_end_run_button_visual(quit_button, true)
	_apply_end_run_button_visual(next_bet_button, _last_next_bet_enabled)

func _apply_end_run_button_visual(button: Button, can_be_active: bool) -> void:
	if button == null:
		return
	var active: bool = button.visible and can_be_active and not button.disabled
	var selected: bool = bool(button.get_meta(FINAL_DOSSIER_ROUTE_SELECTED_META, false))
	button.scale = Vector2.ONE
	button.modulate = Color.WHITE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if active else Control.CURSOR_ARROW
	button.add_theme_stylebox_override("normal", FINAL_DOSSIER_TAB_STYLE_SELECTED if selected else FINAL_DOSSIER_TAB_STYLE_NORMAL)
	button.add_theme_stylebox_override("hover", FINAL_DOSSIER_TAB_STYLE_SELECTED if selected else FINAL_DOSSIER_TAB_STYLE_FOCUS)
	button.add_theme_stylebox_override("focus", FINAL_DOSSIER_TAB_STYLE_SELECTED if selected else FINAL_DOSSIER_TAB_STYLE_FOCUS)
	button.add_theme_stylebox_override("pressed", FINAL_DOSSIER_TAB_STYLE_SELECTED if selected else FINAL_DOSSIER_TAB_STYLE_PRESSED)
	button.add_theme_stylebox_override("disabled", FINAL_DOSSIER_TAB_STYLE_SELECTED if selected else FINAL_DOSSIER_TAB_STYLE_DISABLED)
	button.add_theme_color_override("font_color", Color(0.18, 0.12, 0.08, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.1, 0.06, 0.03, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.93, 0.74, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(1.0, 0.92, 0.72, 1.0) if selected else Color(0.5, 0.46, 0.41, 0.86))

func _set_final_dossier_state(state: StringName) -> void:
	_final_dossier_state = state
	if game_over_panel == null:
		return
	var style: StyleBox = FINAL_DOSSIER_STYLE_OPEN
	match state:
		FINAL_DOSSIER_STATE_UPDATED:
			style = FINAL_DOSSIER_STYLE_UPDATED
		FINAL_DOSSIER_STATE_CLOSED:
			style = FINAL_DOSSIER_STYLE_CLOSED
		_:
			_final_dossier_state = FINAL_DOSSIER_STATE_OPEN
	game_over_panel.add_theme_stylebox_override("panel", style)
	_apply_final_dossier_palette()

func _apply_final_dossier_palette() -> void:
	var closed: bool = _final_dossier_state == FINAL_DOSSIER_STATE_CLOSED
	var heading_color: Color = Color(0.98, 0.9, 0.7, 1.0) if closed else Color(0.19, 0.12, 0.08, 1.0)
	var body_color: Color = Color(0.9, 0.82, 0.68, 1.0) if closed else Color(0.28, 0.2, 0.14, 1.0)
	var detail_color: Color = Color(0.86, 0.77, 0.61, 1.0) if closed else Color(0.12, 0.08, 0.05, 1.0)
	for label: Label in [verdict_header, verdict_outcome, verdict_charge_label]:
		if label != null:
			label.add_theme_color_override("font_color", heading_color)
	if verdict_sentence_label != null:
		verdict_sentence_label.add_theme_color_override("font_color", body_color)
	for rich_label: RichTextLabel in [verdict_pacts_text, verdict_condanne_text]:
		if rich_label != null:
			rich_label.add_theme_color_override("default_color", detail_color)
	if verdict_crowd_text != null:
		verdict_crowd_text.add_theme_color_override("font_color", detail_color)
	for title_path: String in [
		"UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_PACTS/Lbl_END_RUN_PACTS_TITLEPanel/Lbl_END_RUN_PACTS_TITLE",
		"UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CONDANNE/Lbl_END_RUN_CONDANNE_TITLEPanel/Lbl_END_RUN_CONDANNE_TITLE",
		"UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_TITLEPanel/Lbl_END_RUN_CROWD_TITLE",
	]:
		var title_label := get_node_or_null(title_path) as Label
		if title_label != null:
			title_label.add_theme_color_override("font_color", heading_color)

func _apply_final_dossier_meta_state(sequence_id: int) -> void:
	if sequence_id != _final_dossier_request_sequence_id or game_over_modal == null or not game_over_modal.visible:
		return
	if _last_register_final:
		_set_final_dossier_state(FINAL_DOSSIER_STATE_CLOSED)
		_play_sfx(&"registry_dossier_close")
	else:
		_set_final_dossier_state(FINAL_DOSSIER_STATE_UPDATED)
		_play_sfx(&"registry_dossier_update")

func _reset_final_dossier_route_interaction(restore_buttons: bool = true) -> void:
	_final_dossier_request_sequence_id += 1
	_final_dossier_route_locked = false
	for button: Button in [restart_button, next_bet_button, quit_button]:
		if button != null:
			button.set_meta(FINAL_DOSSIER_ROUTE_SELECTED_META, false)
	if restore_buttons:
		_set_end_run_buttons_enabled(true)
	else:
		_set_end_run_buttons_enabled(false)

func _select_final_dossier_route(button: Button) -> void:
	for route_button: Button in [restart_button, next_bet_button, quit_button]:
		if route_button != null:
			route_button.set_meta(FINAL_DOSSIER_ROUTE_SELECTED_META, route_button == button)
	_refresh_end_run_button_visuals()

func _on_final_dossier_watchdog(sequence_id: int) -> void:
	if sequence_id != _final_dossier_request_sequence_id:
		return
	_reset_final_dossier_route_interaction()

func _activate_final_dossier_route(button: Button, signal_name: StringName) -> void:
	if _final_dossier_route_locked or button == null or button.disabled or not button.visible:
		return
	_select_final_dossier_route(button)
	_final_dossier_route_locked = true
	_set_end_run_buttons_enabled(false)
	_play_sfx(&"registry_dossier_route")
	if not _emit_game_event_signal_if_available(signal_name):
		_reset_final_dossier_route_interaction()
		return
	_final_dossier_request_sequence_id += 1
	var sequence_id: int = _final_dossier_request_sequence_id
	get_tree().create_timer(FINAL_DOSSIER_WATCHDOG_SECONDS).timeout.connect(
		Callable(self, "_on_final_dossier_watchdog").bind(sequence_id),
		CONNECT_ONE_SHOT
	)

func _set_verdict_mode(active: bool) -> void:
	if verdict_header != null:
		verdict_header.visible = active
	if verdict_outcome != null:
		verdict_outcome.visible = active
	if verdict_icon != null:
		verdict_icon.visible = active and verdict_icon.texture != null
	if verdict_sentence_label != null:
		verdict_sentence_label.visible = active
	if verdict_charge_label != null:
		verdict_charge_label.visible = active
	if verdict_sections != null:
		verdict_sections.visible = active
	if verdict_crowd_section != null and active:
		verdict_crowd_section.visible = _last_verdict_crowd_line.strip_edges() != ""
	if game_over_scroll != null:
		game_over_scroll.visible = false
	if ending_text != null:
		ending_text.visible = active

func _get_verdict_outcome_text(outcome: StringName) -> String:
	match outcome:
		&"CASHOUT":
			return fmt_system_state(tr("incasso accettato"))
		&"WIN":
			return fmt_system_state(tr("arena continuata"))
		_:
			return fmt_system_state(tr("percorso registrato"))

func _build_verdict_summary(payload: Dictionary, pacts_payload: Array, condanne_payload: Array) -> Dictionary:
	var stats_payload: Dictionary = payload.get("stats", {}) as Dictionary
	var max_escalation: int = int(stats_payload.get("max_escalation", payload.get("max_escalation", 0)))
	var refuse_cashout: int = int(stats_payload.get("refuse_cashout_count_this_run", payload.get("refuse_cashout_count_this_run", 0)))
	var seed_value: int = int(payload.get("seed", 0))
	var summary: Dictionary = {
		"outcome": str(payload.get("outcome", "LOSS")),
		"pacts_signed_count": pacts_payload.size(),
		"condanne_this_run_count": condanne_payload.size(),
		"max_escalation": max_escalation,
		"refuse_cashout_count": refuse_cashout,
		"lying_pact_present": _payload_has_lying_pact(pacts_payload),
		"seed": seed_value,
	}
	return summary

func _payload_has_lying_pact(pacts_payload: Array) -> bool:
	if pacts_payload.is_empty():
		return false
	if _run_manager_port == null:
		return false
	for pact in pacts_payload:
		var pact_key: StringName = StringName(str(pact))
		if _run_manager_port.has_lying_pact_reveal(pact_key):
			return true
	return false

func _on_escalation_changed(level: int, max_value: int) -> void:
	var previous_level: int = _escalation_level
	_escalation_level = level
	_escalation_max = max_value
	_update_escalation_bar()
	_pulse_pressure_indicator(previous_level, _escalation_level)

func _update_escalation_bar() -> void:
	var safe_max: int = _get_pressure_max(_escalation_max)
	var clamped_level: int = clampi(_escalation_level, 0, safe_max)
	if escalation_label != null:
		escalation_label.text = _format_pressure_label(clamped_level, safe_max)
	if pressure_state_label != null:
		pressure_state_label.text = _get_pressure_state_text(clamped_level)
	if escalation_bar != null:
		escalation_bar.max_value = float(safe_max)
		escalation_bar.value = float(clamped_level)
		_apply_pressure_bar_color(_get_pressure_color(clamped_level))

func _get_pressure_max(max_value: int) -> int:
	return maxi(max_value, 10)

func _format_pressure_label(level: int, max_value: int) -> String:
	var safe_max: int = _get_pressure_max(max_value)
	return tr("PRESSIONE %d/%d") % [clampi(level, 0, safe_max), safe_max]

func _get_pressure_state_text(level: int) -> String:
	if level <= 2:
		return tr("Sotto controllo")
	if level <= 5:
		return tr("La folla si scalda")
	if level <= 8:
		return tr("Rischio alto")
	return tr("Fuori controllo")

func _get_pressure_color(level: int) -> Color:
	if level <= 2:
		return Color(0.72, 0.55, 0.22, 1.0)
	if level <= 5:
		return Color(0.82, 0.43, 0.12, 1.0)
	if level <= 8:
		return Color(0.64, 0.16, 0.08, 1.0)
	return Color(0.35, 0.03, 0.02, 1.0)

func _apply_pressure_bar_color(color: Color) -> void:
	if escalation_bar == null:
		return
	if _pressure_background_style == null:
		_pressure_background_style = StyleBoxFlat.new()
		_pressure_background_style.bg_color = Color(0.10, 0.055, 0.035, 0.92)
		_pressure_background_style.corner_radius_top_left = 3
		_pressure_background_style.corner_radius_top_right = 3
		_pressure_background_style.corner_radius_bottom_left = 3
		_pressure_background_style.corner_radius_bottom_right = 3
		escalation_bar.add_theme_stylebox_override("background", _pressure_background_style)
	if _pressure_fill_style == null:
		_pressure_fill_style = StyleBoxFlat.new()
		_pressure_fill_style.corner_radius_top_left = 3
		_pressure_fill_style.corner_radius_top_right = 3
		_pressure_fill_style.corner_radius_bottom_left = 3
		_pressure_fill_style.corner_radius_bottom_right = 3
		escalation_bar.add_theme_stylebox_override("fill", _pressure_fill_style)
	_pressure_fill_style.bg_color = color

func _pulse_pressure_indicator(previous: int, next: int) -> void:
	if previous == next or escalation_row == null:
		return
	if _pressure_pulse_tween != null and _pressure_pulse_tween.is_valid():
		_pressure_pulse_tween.kill()
	var increasing: bool = next > previous
	var pulse_color: Color = Color(0.88, 0.26, 0.12, 1.0) if increasing else Color(0.92, 0.68, 0.28, 1.0)
	var pulse_scale: Vector2 = Vector2(1.045, 1.045) if increasing else Vector2(1.025, 1.025)
	var pulse_seconds: float = 0.18 if increasing else 0.22
	escalation_row.pivot_offset = escalation_row.size * 0.5
	escalation_row.scale = pulse_scale
	if escalation_label != null:
		escalation_label.modulate = pulse_color
	if pressure_state_label != null:
		pressure_state_label.modulate = pulse_color
	_pressure_pulse_tween = create_tween()
	_pressure_pulse_tween.set_trans(Tween.TRANS_QUAD)
	_pressure_pulse_tween.set_ease(Tween.EASE_OUT)
	_pressure_pulse_tween.tween_property(escalation_row, "scale", Vector2.ONE, pulse_seconds)
	if escalation_label != null:
		_pressure_pulse_tween.parallel().tween_property(escalation_label, "modulate", Color.WHITE, pulse_seconds)
	if pressure_state_label != null:
		_pressure_pulse_tween.parallel().tween_property(pressure_state_label, "modulate", Color.WHITE, pulse_seconds)

func _on_special_arena_started(payload: Dictionary) -> void:
	_special_arena_payload = payload.duplicate(true)
	if bet_panel != null and bet_panel.visible:
		_update_special_arena_ui()

func _on_arena_theme_changed(payload: Dictionary) -> void:
	_arena_theme_payload = payload.duplicate(true)
	var theme_id: StringName = _extract_theme_id(payload)
	_active_visual_tier = _resolve_visual_tier_from_theme(theme_id)
	_silence_overlay_active = theme_id == _SILENCE_THEME_ID
	_apply_visual_tier(_active_visual_tier)
	_set_silence_overlay_active(_silence_overlay_active)
	_update_arena_theme_ui()

func _extract_theme_id(payload: Dictionary) -> StringName:
	if payload.has("theme_id"):
		return StringName(payload.get("theme_id", &""))
	return &""

func _resolve_visual_tier_from_theme(theme_id: StringName) -> int:
	if _ERA3_THEME_IDS.has(theme_id):
		return _VISUAL_TIER_ERA3
	if _ERA2_THEME_IDS.has(theme_id):
		return _VISUAL_TIER_ERA2
	return _VISUAL_TIER_BASE

func _set_silence_overlay_active(active: bool) -> void:
	if silence_overlay == null:
		return
	silence_overlay.visible = active
	# Apply shader-based overlay to SilenceRect if present.
	# SilenceOverlay is a container; SilenceRect is the ColorRect child.
	var rect := silence_overlay.get_node_or_null("SilenceRect") as CanvasItem
	if rect != null:
		rect.material = _SILENCE_OVERLAY_MATERIAL
	if active:
		silence_overlay.modulate = Color(1.0, 1.0, 1.0, _SILENCE_OVERLAY_ALPHA)
	else:
		silence_overlay.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _apply_visual_tier(tier: int) -> void:
	var use_alt: bool = tier == _VISUAL_TIER_ERA2
	var use_global: bool = tier == _VISUAL_TIER_ERA3
	var arena_panel_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
	var end_run_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
	var hud_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
	var ui_root_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
	var torch_overlay_modulate: Color = Color(1.0, 1.0, 1.0, 0.0)
	var resolution_overlay_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
	if use_alt:
		arena_panel_modulate = Color(0.78, 0.78, 0.78, 1.0)
		end_run_modulate = Color(1.0, 1.0, 1.0, 0.92)
	elif use_global:
		arena_panel_modulate = Color(0.74, 0.74, 0.74, 1.0)
		end_run_modulate = Color(1.0, 1.0, 1.0, 0.94)
		hud_modulate = Color(0.9, 0.9, 0.9, 1.0)
		ui_root_modulate = Color(0.9, 0.9, 0.9, 1.0)
		torch_overlay_modulate = Color(1.0, 1.0, 1.0, 0.22)
		resolution_overlay_modulate = Color(1.0, 1.0, 1.0, 0.85)
	if arena_theme_title_panel != null:
		arena_theme_title_panel.modulate = arena_panel_modulate
		arena_theme_title_panel.material = _ERA2_PANEL_MATERIAL if tier == _VISUAL_TIER_ERA2 else null
	if arena_theme_subtitle_panel != null:
		arena_theme_subtitle_panel.modulate = arena_panel_modulate
		arena_theme_subtitle_panel.material = _ERA2_PANEL_MATERIAL if tier == _VISUAL_TIER_ERA2 else null
	if game_over_panel != null:
		game_over_panel.modulate = end_run_modulate
		game_over_panel.material = _ERA2_PANEL_MATERIAL if tier == _VISUAL_TIER_ERA2 else null
	if hud_root != null:
		hud_root.modulate = hud_modulate
		hud_root.material = _ERA3_GLOBAL_MATERIAL if tier == _VISUAL_TIER_ERA3 else null
	if modals_root != null:
		modals_root.modulate = ui_root_modulate
		modals_root.material = _ERA3_GLOBAL_MATERIAL if tier == _VISUAL_TIER_ERA3 else null
	if torch_flicker_overlay != null:
		torch_flicker_overlay.modulate = torch_overlay_modulate
	if arena_resolution_panel != null:
		arena_resolution_panel.modulate = resolution_overlay_modulate
	if verdict_header != null:
		verdict_header.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if verdict_sentence_label != null:
		verdict_sentence_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if verdict_outcome != null:
		verdict_outcome.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_betting_opened() -> void:
	if game_over_panel != null and game_over_panel.visible:
		_set_bet_modal(false)
		return
	if push_luck_panel != null and push_luck_panel.visible:
		return
	open_bet_circle([] as Array[Dictionary])

func _on_arena_started(arena_index: int) -> void:
	if not _special_arena_payload.is_empty():
		var special_index: int = int(_special_arena_payload.get("arena_index", -1))
		if arena_index >= special_index and special_index > 0:
			_special_arena_payload = {}
	if _should_show_arena_resolution_overlay():
		_show_arena_resolution_overlay()

func _on_countdown_requested(seconds: int) -> void:
	# FAST countdown must be visible during the round ONLY if the player selected FAST.
	if _fast_countdown_active:
		_handle_fast_countdown(mini(seconds, FAST_SELECTION_SECONDS))
		return
	if seconds <= 0:
		return
	if seconds > 3:
		return
	await show_countdown(seconds)

func _set_glory_value(glory: int) -> void:
	_glory = maxi(glory, 0)
	if glory_value_label != null:
		glory_value_label.text = str(_glory)

func _on_bet_placed(_bet_id: String, _stake: int, _odds: float) -> void:
	var bet_label: String = _get_bet_name(_bet_id)
	set_active_bet(bet_label, _odds)

func set_active_bet(label: String, multiplier: float) -> void:
	if bet_badge_value_label == null:
		return
	bet_badge_value_label.text = "%s x%.1f" % [label, multiplier]

func set_active_bet_text(text: String) -> void:
	if bet_badge_value_label == null:
		return
	bet_badge_value_label.text = text

func _on_bet_ui_opened(bets: Array[Dictionary]) -> void:
	if bet_panel == null:
		return
	if not bets.is_empty():
		var intro_payload: Dictionary = {
			"title": str(bets[0].get("title", bets[0].get("name", ""))),
			"subtitle": str(bets[0].get("subtitle", bets[0].get("archetype_label", ""))),
			"body": str(bets[0].get("body", bets[0].get("condition", ""))),
			"stake_text": str(bets[0].get("stake_text", bets[0].get("pact", ""))),
			"footer": str(bets[0].get("footer", bets[0].get("doom", ""))),
		}
		if _lbl_intro_title != null:
			_lbl_intro_title.text = str(intro_payload.get("title", ""))
		if _lbl_intro_subtitle != null:
			_lbl_intro_subtitle.text = str(intro_payload.get("subtitle", ""))
		if _lbl_intro_body != null:
			_lbl_intro_body.text = str(intro_payload.get("body", ""))
		if _lbl_intro_body_stake != null:
			_lbl_intro_body_stake.text = str(intro_payload.get("stake_text", ""))
		if _lbl_intro_footer != null:
			_lbl_intro_footer.text = str(intro_payload.get("footer", ""))
	if betting_circle != null:
		open_bet_circle(bets)
		return
	if game_over_panel != null and game_over_panel.visible:
		return
	_reset_sign_feedback()
	if push_luck_panel != null and push_luck_panel.visible:
		_pending_bets = bets
		return
	_bets_by_id.clear()
	_current_bet_offer = []
	_require_bet_confirm = false
	for bet_value: Dictionary in bets:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: String = str(bet.get("id", ""))
		_bets_by_id[bet_id] = bet
		_current_bet_offer.append(bet)
	_build_bet_buttons(_current_bet_offer)
	_reset_bet_confirmation()
	_set_bet_modal(true)
	_update_special_arena_ui()
	_update_condanna_focus()
	_reset_fast_countdown()
	_refresh_modal_dimmer()
	var bet_read_buttons: Array[Button] = []
	bet_read_buttons.append_array(_bet_buttons)
	_apply_modal_read_delay(bet_read_buttons)

func _on_bet_ui_closed() -> void:
	_reset_sign_feedback()
	_set_bet_modal(false)
	if betting_circle != null:
		betting_circle.close()
	_restore_betting_overlay_visual_suppression()
	_reset_bet_confirmation()
	if special_arena_label != null:
		special_arena_label.visible = false
	if condanna_focus_label != null:
		condanna_focus_label.visible = false

func _on_bet_selected(bet_id: String) -> void:
	_selected_bet_id = bet_id

func _on_pact_sealed_opened() -> void:
	_reset_sign_feedback()
	_reset_pact_tablet_state()
	_clear_betting_transient_overlays()
	if pact_sealed_title != null:
		pact_sealed_title.text = tr("PATTO SIGILLATO")
	if pact_sealed_subtitle != null:
		pact_sealed_subtitle.text = "%s\n%s" % [
			tr("La pietra ha preso la firma."),
			tr("La gradinata attende il gesto."),
		]
		_force_label_readable(pact_sealed_subtitle)
	if pact_sealed_advance_button != null:
		pact_sealed_advance_button.text = tr("MOSTRA IL PATTO")
	_set_pact_sealed_modal(true)
	_refresh_modal_dimmer()

func _on_pact_sealed_closed() -> void:
	_reset_pact_tablet_state()
	_set_pact_sealed_modal(false)
	_refresh_modal_dimmer()

func _on_pact_ritual_next_pressed() -> void:
	if _pact_tablet_locked or pact_sealed_advance_button == null:
		return
	_set_pact_tablet_validated_state(true)
	_pact_tablet_locked = true
	var pact_buttons: Array[Button] = [pact_sealed_advance_button]
	_apply_decision_lock(pact_sealed_panel, pact_buttons, null, null, false)
	_play_sfx(&"registry_pact_validate")
	if not _emit_game_event_signal_if_available(&"request_ritual_advance", ["pact"]):
		_recover_pact_tablet_request_lock()
		return
	_start_pact_tablet_request_watchdog()

func _start_pact_tablet_request_watchdog() -> void:
	_pact_tablet_request_sequence_id += 1
	var request_id: int = _pact_tablet_request_sequence_id
	var timer: SceneTreeTimer = get_tree().create_timer(PACT_TABLET_WATCHDOG_SECONDS)
	timer.timeout.connect(Callable(self, "_recover_pact_tablet_request_if_still_open").bind(request_id), CONNECT_ONE_SHOT)

func _recover_pact_tablet_request_if_still_open(request_id: int) -> void:
	if request_id != _pact_tablet_request_sequence_id:
		return
	if not _pact_tablet_locked:
		return
	if pact_sealed_modal == null or not pact_sealed_modal.visible:
		return
	_recover_pact_tablet_request_lock()

func _recover_pact_tablet_request_lock() -> void:
	_reset_pact_tablet_state()

func _reset_pact_tablet_state() -> void:
	_pact_tablet_request_sequence_id += 1
	_pact_tablet_locked = false
	_set_pact_tablet_validated_state(false)
	if pact_sealed_advance_button == null:
		return
	var pact_buttons: Array[Button] = [pact_sealed_advance_button]
	_reset_decision_surface(pact_sealed_panel, pact_buttons, null)

func _set_pact_tablet_validated_state(validated: bool) -> void:
	if pact_sealed_advance_button == null:
		return
	pact_sealed_advance_button.set_meta(PACT_TABLET_VALIDATED_META, validated)
	pact_sealed_advance_button.add_theme_stylebox_override(
		"disabled",
		PACT_TABLET_STYLE_VALIDATED if validated else PACT_TABLET_STYLE_DISABLED
	)
	pact_sealed_advance_button.add_theme_color_override(
		"font_disabled_color",
		Color(1.0, 0.9, 0.72, 1.0) if validated else Color(0.76, 0.72, 0.64, 1.0)
	)

func _on_resolve_ritual_opened(payload: Dictionary) -> void:
	_reset_sign_feedback()
	_pre_resolve_tension_boost()
	_last_ritual_outcome_snapshot = _extract_ritual_outcome_snapshot(payload)
	var doom_short: String = str(payload.get("doom_short", ""))
	var subtitle: String = "%s\n%s" % [
		tr("Il Registro pesa il patto."),
		tr("Colpisci tre volte il sigillo quando pulsa."),
	]
	if doom_short != "":
		subtitle = "%s\n%s" % [
			tr("CONDANNA: %s") % doom_short,
			tr("Tre colpi chiudono il verbale."),
		]
	enqueue_post_bet_message({
		"kind": "resolve_ritual",
		"title": tr("RITO DI GIUDIZIO"),
		"subtitle": subtitle,
	})

func _on_resolve_ritual_closed() -> void:
	_reset_judgment_seal_state()
	_set_resolve_ritual_modal(false)
	_pending_resolution_context_line = ""
	_resolve_ritual_base_body = ""
	_refresh_modal_dimmer()

func _on_resolve_ritual_next_pressed() -> void:
	if resolve_ritual_modal != null and resolve_ritual_modal.visible:
		_on_resolve_ritual_strike_pressed()
		return

func _on_resolve_ritual_strike_pressed() -> void:
	if resolve_ritual_modal == null or not resolve_ritual_modal.visible:
		return
	if _judgment_seal_locked:
		return
	if _resolve_ritual_strike_count >= RESOLUTION_RITUAL_STRIKES_REQUIRED:
		return
	var on_beat: bool = _is_resolution_ritual_on_beat()
	_resolve_ritual_strike_count += 1
	_apply_resolution_ritual_strike_feedback(on_beat)
	if _resolve_ritual_strike_count >= RESOLUTION_RITUAL_STRIKES_REQUIRED:
		_complete_resolution_ritual_interaction()
	else:
		_play_sfx(&"registry_judgment_seal_strike")

func _reset_resolution_ritual_interaction() -> void:
	_resolve_ritual_strike_count = 0
	_resolve_ritual_started_msec = Time.get_ticks_msec()
	_reset_judgment_seal_state()
	if resolve_ritual_prompt != null:
		resolve_ritual_prompt.text = tr("COLPISCI IL SIGILLO A TEMPO")
	if resolve_ritual_strike_button != null:
		resolve_ritual_strike_button.visible = true
		resolve_ritual_strike_button.disabled = false
		resolve_ritual_strike_button.text = tr("COLPISCI")
	if resolve_ritual_advance_button != null:
		resolve_ritual_advance_button.visible = false
		resolve_ritual_advance_button.disabled = true
	for mark: Label in resolve_ritual_strike_marks:
		if mark == null:
			continue
		mark.modulate = Color(0.34, 0.33, 0.31, 1.0)
		mark.scale = Vector2.ONE
	_start_resolution_ritual_pulse()

func _stop_resolution_ritual_interaction() -> void:
	if _resolve_ritual_pulse_tween != null and _resolve_ritual_pulse_tween.is_valid():
		_resolve_ritual_pulse_tween.kill()
	if _resolve_ritual_hit_tween != null and _resolve_ritual_hit_tween.is_valid():
		_resolve_ritual_hit_tween.kill()
	if resolve_ritual_strike_button != null:
		resolve_ritual_strike_button.scale = Vector2.ONE

func _start_resolution_ritual_pulse() -> void:
	if resolve_ritual_strike_button == null:
		return
	if _resolve_ritual_pulse_tween != null and _resolve_ritual_pulse_tween.is_valid():
		_resolve_ritual_pulse_tween.kill()
	_resolve_ritual_pulse_tween = create_tween()
	_resolve_ritual_pulse_tween.set_loops()
	_resolve_ritual_pulse_tween.set_trans(Tween.TRANS_SINE)
	_resolve_ritual_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_resolve_ritual_pulse_tween.tween_property(resolve_ritual_strike_button, "modulate", Color(1.0, 0.9, 0.7, 1.0), 0.42)
	_resolve_ritual_pulse_tween.tween_property(resolve_ritual_strike_button, "modulate", Color.WHITE, 0.48)

func _is_resolution_ritual_on_beat() -> bool:
	if _resolve_ritual_started_msec <= 0:
		return false
	var elapsed: float = float(Time.get_ticks_msec() - _resolve_ritual_started_msec) / 1000.0
	var beat_position: float = fmod(elapsed, RESOLUTION_RITUAL_BEAT_SECONDS)
	var beat_distance: float = minf(beat_position, RESOLUTION_RITUAL_BEAT_SECONDS - beat_position)
	return beat_distance <= RESOLUTION_RITUAL_HIT_WINDOW_SECONDS

func _apply_resolution_ritual_strike_feedback(on_beat: bool) -> void:
	var mark_index: int = _resolve_ritual_strike_count - 1
	if mark_index >= 0 and mark_index < resolve_ritual_strike_marks.size():
		var mark: Label = resolve_ritual_strike_marks[mark_index]
		if mark != null:
			mark.modulate = Color(0.98, 0.82, 0.46, 1.0) if on_beat else Color(0.76, 0.68, 0.5, 1.0)
			mark.scale = Vector2(1.18, 1.18) if on_beat else Vector2(1.08, 1.08)
	if resolve_ritual_prompt != null:
		var prompts: Array[String] = [
			tr("PRIMO COLPO - VERDETTO INCISO"),
			tr("SECONDO COLPO - CONDANNA INCISA"),
			tr("TERZO COLPO - SIGILLO CHIUSO"),
		]
		resolve_ritual_prompt.text = prompts[mini(_resolve_ritual_strike_count - 1, prompts.size() - 1)]
	if resolve_ritual_strike_button != null:
		resolve_ritual_strike_button.text = tr("COLPISCI ANCORA") if _resolve_ritual_strike_count < RESOLUTION_RITUAL_STRIKES_REQUIRED else tr("SIGILLATO")
		_set_judgment_seal_state(_resolve_ritual_strike_count)

func _complete_resolution_ritual_interaction() -> void:
	if _resolve_ritual_pulse_tween != null and _resolve_ritual_pulse_tween.is_valid():
		_resolve_ritual_pulse_tween.kill()
	if resolve_ritual_prompt != null:
		resolve_ritual_prompt.text = tr("VERBALE INCISO - IL REGISTRO PUO AVANZARE")
	_set_judgment_seal_state(RESOLUTION_RITUAL_STRIKES_REQUIRED)
	_judgment_seal_locked = true
	if resolve_ritual_strike_button != null:
		resolve_ritual_strike_button.disabled = true
	if resolve_ritual_advance_button != null:
		resolve_ritual_advance_button.visible = false
		resolve_ritual_advance_button.disabled = true
	_play_sfx(&"registry_judgment_seal_resolve")
	if not _emit_game_event_signal_if_available(&"request_ritual_advance", ["resolve"]):
		_recover_judgment_seal_request_lock()
	else:
		_start_judgment_seal_request_watchdog()

func _start_judgment_seal_request_watchdog() -> void:
	_judgment_seal_request_sequence_id += 1
	var request_id: int = _judgment_seal_request_sequence_id
	var timer := get_tree().create_timer(JUDGMENT_SEAL_WATCHDOG_SECONDS)
	timer.timeout.connect(Callable(self, "_recover_judgment_seal_request_if_still_open").bind(request_id), CONNECT_ONE_SHOT)

func _recover_judgment_seal_request_if_still_open(request_id: int) -> void:
	if request_id != _judgment_seal_request_sequence_id:
		return
	if not _judgment_seal_locked:
		return
	if resolve_ritual_modal == null or not resolve_ritual_modal.visible:
		return
	_recover_judgment_seal_request_lock()

func _recover_judgment_seal_request_lock() -> void:
	_reset_resolution_ritual_interaction()

func _reset_judgment_seal_state() -> void:
	_judgment_seal_request_sequence_id += 1
	_judgment_seal_locked = false
	if resolve_ritual_strike_button == null:
		return
	resolve_ritual_strike_button.set_meta(JUDGMENT_SEAL_STATE_META, 0)
	resolve_ritual_strike_button.modulate = Color.WHITE
	resolve_ritual_strike_button.scale = Vector2.ONE
	resolve_ritual_strike_button.add_theme_stylebox_override("normal", JUDGMENT_SEAL_STYLE_NORMAL)
	resolve_ritual_strike_button.add_theme_stylebox_override("hover", JUDGMENT_SEAL_STYLE_FOCUS)
	resolve_ritual_strike_button.add_theme_stylebox_override("focus", JUDGMENT_SEAL_STYLE_FOCUS)
	resolve_ritual_strike_button.add_theme_stylebox_override("pressed", JUDGMENT_SEAL_STYLE_PRESSED)
	resolve_ritual_strike_button.add_theme_stylebox_override("disabled", JUDGMENT_SEAL_STYLE_DISABLED)

func _set_judgment_seal_state(strike_count: int) -> void:
	if resolve_ritual_strike_button == null:
		return
	resolve_ritual_strike_button.set_meta(JUDGMENT_SEAL_STATE_META, strike_count)
	var style: StyleBox = null
	if strike_count == 1:
		style = JUDGMENT_SEAL_STYLE_STRIKE_1
	elif strike_count == 2:
		style = JUDGMENT_SEAL_STYLE_STRIKE_2
	elif strike_count >= RESOLUTION_RITUAL_STRIKES_REQUIRED:
		style = JUDGMENT_SEAL_STYLE_RESOLVED
	if style == null:
		_reset_judgment_seal_state()
		return
	resolve_ritual_strike_button.add_theme_stylebox_override("normal", style)
	resolve_ritual_strike_button.add_theme_stylebox_override("hover", style)
	resolve_ritual_strike_button.add_theme_stylebox_override("focus", style)
	resolve_ritual_strike_button.add_theme_stylebox_override("pressed", style)
	resolve_ritual_strike_button.add_theme_stylebox_override("disabled", style if strike_count >= RESOLUTION_RITUAL_STRIKES_REQUIRED else JUDGMENT_SEAL_STYLE_DISABLED)

func enqueue_post_bet_message(payload: Dictionary) -> void:
	_show_post_bet_payload(payload)

func _show_post_bet_payload(payload: Dictionary) -> void:
	var kind: String = str(payload.get("kind", ""))
	if kind == "pact_sealed":
		_reset_pact_tablet_state()
		if pact_sealed_title != null:
			pact_sealed_title.text = tr(str(payload.get("title", "PATTO SIGILLATO")))
		if pact_sealed_subtitle != null:
			var pact_subtitle: String = str(payload.get(
				"subtitle",
				"La pietra ha preso la firma.\nLa gradinata attende il gesto."
			))
			pact_sealed_subtitle.text = _translate_multiline_copy(pact_subtitle)
			_force_label_readable(pact_sealed_subtitle)
		if pact_sealed_advance_button != null:
			pact_sealed_advance_button.text = tr("MOSTRA IL PATTO")
		_set_pact_sealed_modal(true)
	elif kind == "resolve_ritual":
		if resolve_ritual_title != null:
			resolve_ritual_title.text = str(payload.get("title", tr("RITO DI GIUDIZIO")))
		_resolve_ritual_base_body = str(payload.get("subtitle", fmt_system_state(tr("condanna registrata"))))
		_set_resolve_ritual_body(_resolve_ritual_base_body)
		_force_label_readable(resolve_ritual_subtitle)
		_set_resolve_ritual_modal(true)
	_refresh_modal_dimmer()

func _on_intermediate_choice_opened() -> void:
	_reset_sign_feedback()
	_reset_gesture_choice_state()
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = RunPhaseContract.INTERMEDIATE_CHOICE
	payload.title = tr("ATTO DAVANTI ALLA GRADINATA")
	payload.meta = {
		"audience_message": tr("La gradinata pesa il tuo respiro."),
	}
	payload.choices = ["placa", "provoca"]
	payload.show_mid_choice = true
	apply_run_ui_payload(payload)

func apply_run_ui_payload(payload: RunUiPayload) -> void:
	if payload == null:
		return
	var target_phase: int = payload.phase
	if payload.show_mid_choice and target_phase != RunPhaseContract.INTERMEDIATE_CHOICE:
		target_phase = RunPhaseContract.INTERMEDIATE_CHOICE
	show_phase(target_phase)
	if payload.show_mid_choice:
		_apply_intermediate_choice_payload(payload)
	if payload.show_push_your_luck:
		_apply_push_luck_payload(payload)

func _apply_intermediate_choice_payload(payload: RunUiPayload) -> void:
	_reset_gesture_choice_state()
	if intermediate_choice_panel == null:
		return
	_set_bet_modal(false)
	var audience_line: String = ""
	if payload.meta.has("audience_message"):
		audience_line = str(payload.meta.get("audience_message", "")).strip_edges()
	var title: String = payload.title.strip_edges()
	if title == "":
		title = tr("ATTO DAVANTI ALLA GRADINATA")
	if title.find("\n") >= 0:
		var parts: PackedStringArray = title.split("\n")
		if audience_line == "" and parts.size() > 0:
			audience_line = parts[0].strip_edges()
		title = parts[parts.size() - 1].strip_edges()
	audience_line = tr(audience_line) if audience_line != "" else ""
	title = tr(title) if title != "" else tr("ATTO DAVANTI ALLA GRADINATA")
	if intermediate_choice_audience_label != null:
		intermediate_choice_audience_label.text = audience_line
		intermediate_choice_audience_label.visible = audience_line != ""
	if intermediate_choice_label != null:
		intermediate_choice_label.text = title
	_set_intermediate_choice_modal(true)
	var choice_buttons: Array[Button] = []
	if intermediate_choice_placa_button != null:
		intermediate_choice_placa_button.visible = payload.choices.is_empty() or payload.choices.has("placa")
		choice_buttons.append(intermediate_choice_placa_button)
	if intermediate_choice_provoca_button != null:
		intermediate_choice_provoca_button.visible = payload.choices.is_empty() or payload.choices.has("provoca")
		choice_buttons.append(intermediate_choice_provoca_button)
	_refresh_gesture_choice_copy()
	_apply_modal_read_delay(choice_buttons)

func _translate_multiline_copy(source: String) -> String:
	var localized_lines: PackedStringArray = []
	for line: String in source.split("\n"):
		localized_lines.append(tr(line.strip_edges()))
	return "\n".join(localized_lines)

func _refresh_gesture_choice_copy() -> void:
	if intermediate_choice_placa_button != null:
		intermediate_choice_placa_button.text = "%s\n%s\n%s" % [
			tr("ABBASSA LO SGUARDO"),
			tr("Pressione -1."),
			tr("Il Registro annota misura."),
		]
	if intermediate_choice_provoca_button != null:
		intermediate_choice_provoca_button.text = "%s\n%s\n%s" % [
			tr("SFIDA LA GRADINATA"),
			tr("Pressione +1."),
			tr("Il Registro annota esposizione."),
		]

func _update_special_arena_ui() -> void:
	if special_arena_label == null:
		return
	if _special_arena_payload.is_empty():
		special_arena_label.visible = false
		return
	var title: String = str(_special_arena_payload.get("title", tr("Arena speciale")))
	var desc: String = str(_special_arena_payload.get("description", ""))
	if desc != "":
		special_arena_label.text = "%s\n%s" % [title, desc]
	else:
		special_arena_label.text = title
	special_arena_label.visible = true

func _update_arena_theme_ui() -> void:
	if arena_theme_title_label == null and arena_theme_subtitle_label == null:
		return
	if _arena_theme_payload.is_empty():
		if arena_theme_title_label != null:
			arena_theme_title_label.visible = false
		if arena_theme_title_panel != null:
			arena_theme_title_panel.visible = false
		if arena_theme_subtitle_label != null:
			arena_theme_subtitle_label.visible = false
		if arena_theme_subtitle_panel != null:
			arena_theme_subtitle_panel.visible = false
		return
	var title: String = str(_arena_theme_payload.get("title", ""))
	var subtitle: String = str(_arena_theme_payload.get("subtitle", ""))
	if arena_theme_title_label != null:
		arena_theme_title_label.text = title
		arena_theme_title_label.visible = title != ""
		if arena_theme_title_panel != null:
			arena_theme_title_panel.visible = title != ""
	if arena_theme_subtitle_label != null:
		arena_theme_subtitle_label.text = subtitle
		arena_theme_subtitle_label.visible = subtitle != ""
		if arena_theme_subtitle_panel != null:
			arena_theme_subtitle_panel.visible = subtitle != ""

func _update_condanna_focus() -> void:
	if condanna_focus_label == null:
		return
	var arena_index: int = _get_arena_index()
	condanna_focus_label.visible = arena_index <= 1
	if condanna_focus_label.visible:
		_update_bet_focus_telegraph()

func _update_bet_focus_telegraph() -> void:
	if condanna_focus_label == null or not condanna_focus_label.visible:
		return
	if _selected_bet_id == "":
		condanna_focus_label.text = tr("Firma una via. Il Registro annota il prezzo.")
		return
	var bet: Dictionary = _bets_by_id.get(_selected_bet_id, {}) as Dictionary
	if bet.is_empty():
		condanna_focus_label.text = tr("Firma una via. Il Registro annota il prezzo.")
		return
	var title_text: String = str(bet.get("display_title", bet.get("name", _selected_bet_id))).strip_edges()
	var doom_text: String = str(bet.get("doom_short", bet.get("doom", ""))).strip_edges()
	if doom_text == "":
		doom_text = tr("Clausola non esposta.")
	condanna_focus_label.text = tr("Firma focus: %s | Clausola: %s") % [title_text, doom_text]

func _on_scars_updated(scars: Array) -> void:
	_refresh_scars_ui(scars)

func _on_scar_applied(scar: Dictionary) -> void:
	_play_sfx(&"player_damage")
	_show_scar_popup(scar)

func _refresh_scars_ui(scars: Array) -> void:
	if scars_label == null:
		return
	var suppress_for_betting: bool = betting_circle != null and betting_circle.visible
	if scars_panel != null:
		if _ending_mode_active:
			scars_panel.visible = false
			return
		scars_panel.visible = not suppress_for_betting
		if not suppress_for_betting:
			var scar_count: int = scars.size()
			var clamped_count: int = maxi(scar_count, 1)
			var desired_height: float = SCARS_PANEL_BASE_HEIGHT + (SCARS_PANEL_ROW_HEIGHT * float(clamped_count))
			var clamped_height: float = clampf(desired_height, SCARS_PANEL_MIN_HEIGHT, SCARS_PANEL_MAX_HEIGHT)
			scars_panel.custom_minimum_size.y = clamped_height
			scars_panel.size.y = clamped_height
	if scars.is_empty():
		scars_label.text = tr("Registro pulito: nessun segno inciso.")
		scars_label.tooltip_text = ""
		if scars_panel != null:
			scars_panel.tooltip_text = ""
		_scars_detail_text = ""
		return
	var summary_lines: Array[String] = []
	var detail_lines: Array[String] = []
	for scar_value: Dictionary in scars:
		var scar: Dictionary = scar_value as Dictionary
		var visual_tag: String = str(scar.get("visual_tag", ""))
		var short_desc: String = str(scar.get("short_desc", ""))
		var story: String = str(scar.get("narrative_text", ""))
		if story == "":
			story = str(scar.get("story", ""))
		var effect_text: String = str(scar.get("effect_text", ""))
		if effect_text == "":
			effect_text = str(scar.get("effect", ""))
		var origin: String = str(scar.get("origin", ""))
		if visual_tag != "":
			summary_lines.append("- %s" % visual_tag)
			detail_lines.append("- %s" % visual_tag)
		else:
			summary_lines.append("- %s" % tr("Cicatrice"))
			detail_lines.append("- %s" % tr("Cicatrice"))
		if short_desc != "":
			summary_lines.append("  %s" % short_desc)
			detail_lines.append("  %s" % short_desc)
		if story != "":
			var story_lines: PackedStringArray = story.split("\n")
			for line: String in story_lines:
				if line != "":
					detail_lines.append("  %s" % line)
		if effect_text != "":
			detail_lines.append(tr("  Effetto: %s") % effect_text)
		if origin != "":
			detail_lines.append(tr("  Origine: %s") % origin)
		summary_lines.append("")
		detail_lines.append("")
	if summary_lines.size() > 0 and summary_lines[summary_lines.size() - 1] == "":
		summary_lines.remove_at(summary_lines.size() - 1)
	if detail_lines.size() > 0 and detail_lines[detail_lines.size() - 1] == "":
		detail_lines.remove_at(detail_lines.size() - 1)
	var summary_text: String = "\n".join(summary_lines)
	var detail_text: String = "\n".join(detail_lines)
	scars_label.text = summary_text
	scars_label.tooltip_text = summary_text
	_scars_detail_text = detail_text
	if scars_panel != null:
		scars_panel.tooltip_text = summary_text
	# If FAST was selected, keep the FAST countdown state for the round.
	# The label is driven by countdown_requested during the round.
	if not _fast_countdown_active:
		_reset_fast_countdown()
	get_viewport().gui_release_focus()
	_refresh_modal_dimmer()

func _on_scars_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_scars_detail()

func _show_scars_detail() -> void:
	if scars_detail_panel == null or scars_detail_text == null:
		return
	if _scars_detail_text == "":
		return
	show_modal(scars_detail_panel)
	scars_detail_text.text = _scars_detail_text
	_set_scars_detail_modal(true)

func _hide_scars_detail() -> void:
	if scars_detail_panel == null:
		return
	scars_detail_panel.visible = false
	_set_scars_detail_modal(false)

func _on_scars_detail_closed() -> void:
	_play_sfx(&"button_click")
	_hide_scars_detail()

func _set_scars_detail_modal(active: bool) -> void:
	_emit_modal_telemetry("scars_detail", active)
	_refresh_modal_dimmer()

func _refresh_game_over_scars() -> void:
	_refresh_ending_text()

func _refresh_game_over_meta() -> void:
	_refresh_ending_text()

func _refresh_ending_text() -> void:
	if ending_text == null:
		return
	var sections: Array[String] = []
	var title_text: String = _last_finale_title.strip_edges()
	if title_text != "":
		sections.append("[center][b][font_size=32]%s[/font_size][/b][/center]" % title_text)
	if _last_finale_text != "":
		sections.append(_last_finale_text)
	var scars_section: String = _build_ending_scars_section()
	if scars_section != "":
		sections.append(scars_section)
	var meta_section: String = _build_ending_meta_section()
	if meta_section != "":
		sections.append(meta_section)
	if _last_finale_hint != "":
		sections.append("[i]%s[/i]" % _last_finale_hint)
	ending_text.text = "\n\n".join(sections)

func _build_ending_scars_section() -> String:
	if _last_finale_scars.is_empty():
		return ""
	var lines: Array[String] = []
	lines.append(tr("[b]Cicatrici rilevanti:[/b]"))
	for scar_value: Dictionary in _last_finale_scars:
		var scar: Dictionary = scar_value as Dictionary
		var scar_name: String = tr("Cicatrice")
		if scar.has("name"):
			scar_name = str(scar["name"])
		lines.append("- %s" % scar_name)
	return "\n".join(lines)

func _build_ending_meta_section() -> String:
	var lines: Array[String] = []
	if _last_register_ending_key != "":
		lines.append(tr("FINAL: %s") % _get_register_ending_title(_last_register_ending_key))
	var max_pressure: int = _resolve_final_pressure_max()
	lines.append(tr("Pressione massima: %d/%d") % [max_pressure, _get_pressure_max(_escalation_max)])
	if max_pressure >= 6:
		lines.append(tr("La folla ha spinto il percorso oltre il margine."))
	elif max_pressure <= 2:
		lines.append(tr("La pressione è rimasta sotto controllo."))
	if _last_finale_ending_id != "":
		lines.append(tr("ENDING ID: %s") % _last_finale_ending_id)
	if _last_ending_icon_path != "":
		lines.append(tr("ICONA: %s") % _last_ending_icon_path)
	if lines.is_empty():
		return ""
	lines.insert(0, tr("[b]Registro Finale[/b]"))
	return "\n".join(lines)

func _resolve_final_pressure_max() -> int:
	var safe_max: int = _get_pressure_max(_escalation_max)
	var raw_value: Variant = _last_finale_stats.get("max_escalation", _escalation_level)
	return clampi(int(raw_value), 0, safe_max)

func _get_register_ending_title(ending_key: String) -> String:
	match ending_key:
		"ending_corruption":
			return tr("Corruzione")
		"ending_glory":
			return tr("Gloria")
		"ending_scars":
			return tr("Cicatrici")
		"ending_pattern":
			return tr("Pattern")
		_:
			return tr("Fascicolo chiuso")

func _on_push_luck_opened(payload: Dictionary) -> void:
	_reset_sign_feedback()
	var ui_payload: RunUiPayload = RunUiPayloadScript.new()
	ui_payload.phase = RunPhaseContract.PUSH_YOUR_LUCK
	ui_payload.show_push_your_luck = true
	ui_payload.meta = payload
	ui_payload.title = tr("SPINGI LA SORTE")
	ui_payload.subtitle = str(payload.get("subtitle", tr("Il registro è aperto.")))
	ui_payload.body = str(payload.get("body", tr("Incassa ora o aumenta esposizione.")))
	ui_payload.hint = str(payload.get("hint", tr("La condanna chiude il ciclo senza premio.")))
	ui_payload.footer = str(payload.get("footer", tr("Scegli un atto. La firma è irrevocabile.")))
	ui_payload.choices = ["cashout", "condanna", "double"]
	apply_run_ui_payload(ui_payload)

func _format_push_luck_detail_text(lines: Array[String]) -> String:
	if lines.is_empty():
		return tr("Nessun dettaglio.")
	var visible_lines: Array[String] = []
	var visible_count: int = mini(lines.size(), PUSH_LUCK_DETAILS_MAX_LINES)
	for i: int in range(visible_count):
		visible_lines.append(_compact_push_luck_detail_line(lines[i]))
	if lines.size() > PUSH_LUCK_DETAILS_MAX_LINES:
		var hidden_count: int = lines.size() - PUSH_LUCK_DETAILS_MAX_LINES
		visible_lines.append(tr("+ %d dettagli nel registro.") % hidden_count)
	return "- " + "\n- ".join(visible_lines)

func _compact_push_luck_detail_line(line: String) -> String:
	var trimmed: String = line.strip_edges()
	if trimmed.length() <= PUSH_LUCK_DETAIL_MAX_CHARS:
		return trimmed
	return "%s..." % trimmed.substr(0, PUSH_LUCK_DETAIL_MAX_CHARS - 3).strip_edges()

func _format_push_luck_receipt_text(meta: Dictionary) -> String:
	var stake_glory: int = maxi(int(meta.get("stake_glory", 0)), 0)
	var current_glory: int = maxi(int(meta.get("current_glory", _glory)), 0)
	var current_corruption: int = maxi(int(meta.get("current_corruption", 0)), 0)
	var lines: Array[String] = [
		tr("POSTA VIVA: +%d Gloria") % stake_glory,
		tr("GLORIA: %d") % current_glory,
		tr("CORRUZIONE: %d") % current_corruption,
		_format_pressure_label(_escalation_level, _escalation_max),
	]
	return "\n".join(lines)

func _format_cashout_note(cashout_glory_delta: int, cashout_corruption_delta: int) -> String:
	var parts: Array[String] = []
	parts.append(tr("Ottieni +%d Gloria") % maxi(cashout_glory_delta, 0))
	if cashout_corruption_delta > 0:
		parts.append(tr("Corruzione -%d") % cashout_corruption_delta)
	parts.append(tr("chiudi il registro"))
	return " | ".join(parts)

func _format_double_note(double_next_stake_glory: int, double_pressure_delta: int) -> String:
	return tr("Prossima posta +%d Gloria | Pressione +%d") % [
		maxi(double_next_stake_glory, 0),
		maxi(double_pressure_delta, 1),
	]

func _format_condanna_note(stake_glory: int) -> String:
	return tr("Perdi la posta +%d Gloria | il Registro chiude il percorso") % maxi(stake_glory, 0)

func _apply_push_luck_payload(payload: RunUiPayload) -> void:
	if push_luck_panel == null:
		return
	_reset_pyl_lock_state()
	_clear_audience_context_overlay()
	_set_bet_modal(false)
	var meta: Dictionary = payload.meta
	if push_luck_title != null:
		push_luck_title.text = str(payload.title if payload.title != "" else tr("SPINGI LA SORTE"))
	if push_luck_info != null:
		push_luck_info.text = str(payload.body if payload.body != "" else tr("Incassa ora o aumenta esposizione."))
	var doom_text: String = str(meta.get("next_doom", ""))
	var condition_text: String = str(meta.get("condition", ""))
	var pact_text: String = str(meta.get("next_pact", ""))
	var cashout_locked: bool = bool(meta.get("cashout_locked", false))
	var cashout_reason: String = str(meta.get("cashout_lock_reason", ""))
	var double_locked: bool = bool(meta.get("double_locked", false))
	var double_reason: String = str(meta.get("double_lock_reason", ""))
	var choice_note: String = str(meta.get("choice_note", ""))
	var audience_label: String = str(meta.get("audience_label", ""))
	var audience_reason: String = str(meta.get("audience_reason", ""))
	var cashout_modifier_text: String = str(meta.get("cashout_modifier_text", ""))
	var stake_glory: int = maxi(int(meta.get("stake_glory", 0)), 0)
	var cashout_glory_delta: int = maxi(int(meta.get("cashout_glory_delta", 0)), 0)
	var cashout_corruption_delta: int = maxi(int(meta.get("cashout_corruption_delta", 0)), 0)
	var double_next_stake_glory: int = maxi(int(meta.get("double_next_stake_glory", 0)), 0)
	var double_pressure_delta: int = maxi(int(meta.get("double_pressure_delta", 1)), 1)
	var lines: Array[String] = []
	if doom_text != "":
		lines.append(tr("CONDANNA: %s") % doom_text)
	if condition_text != "":
		lines.append(tr("CONDIZIONE: %s") % condition_text)
	if pact_text != "":
		lines.append(tr("PATTO: %s") % pact_text)
	if choice_note != "":
		lines.append(tr("NOTA: %s") % choice_note)
	if cashout_locked and cashout_reason != "":
		lines.append(tr("INCASSO BLOCCATO: %s") % cashout_reason)
	if double_locked and double_reason != "":
		lines.append(tr("RADDOPPIO BLOCCATO: %s") % double_reason)
	if audience_reason != "":
		lines.append(tr("CONTESTO: %s") % audience_reason)
	if cashout_modifier_text != "":
		lines.append(tr("MODIFICA INCASSO: %s") % cashout_modifier_text)
	if push_luck_details != null:
		push_luck_details.text = _format_push_luck_receipt_text(meta)
		push_luck_details.tooltip_text = _format_push_luck_detail_text(lines)
		var details_panel := push_luck_details.get_parent() as CanvasItem
		if details_panel != null:
			details_panel.visible = true
	if push_luck_audience_label != null:
		push_luck_audience_label.text = audience_label
		push_luck_audience_label.visible = audience_label != ""
		var audience_panel := push_luck_audience_label.get_parent() as CanvasItem
		if audience_panel != null:
			audience_panel.visible = audience_label != ""
	if push_luck_audience_reason != null:
		var state_line: String = str(meta.get("state_line", "")).strip_edges()
		if state_line == "":
			state_line = tr("Stato: in attesa di scelta.")
		push_luck_audience_reason.text = "%s\n%s" % [_get_pressure_state_text(_escalation_level), state_line]
		push_luck_audience_reason.visible = true
	if push_luck_cashout_button != null:
		push_luck_cashout_button.disabled = cashout_locked
		if cashout_locked and cashout_reason != "":
			push_luck_cashout_button.tooltip_text = cashout_reason
		else:
			push_luck_cashout_button.tooltip_text = ""
	if push_luck_cashout_note != null:
		if cashout_locked:
			push_luck_cashout_note.text = _format_lock_note(cashout_reason, tr("Disponibile dopo l'arena in corso."))
			push_luck_cashout_note.visible = true
		else:
			push_luck_cashout_note.text = _format_cashout_note(cashout_glory_delta, cashout_corruption_delta)
			push_luck_cashout_note.visible = true
	if push_luck_condanna_note != null:
		push_luck_condanna_note.text = _format_condanna_note(stake_glory)
		push_luck_condanna_note.visible = true
	if push_luck_double_button != null:
		push_luck_double_button.disabled = double_locked
		if double_locked and double_reason != "":
			push_luck_double_button.tooltip_text = double_reason
		else:
			push_luck_double_button.tooltip_text = ""
	if push_luck_double_note != null:
		if double_locked:
			push_luck_double_note.text = _format_lock_note(double_reason, tr("Disponibile dopo l'arena in corso."))
			push_luck_double_note.visible = true
		else:
			push_luck_double_note.text = _format_double_note(double_next_stake_glory, double_pressure_delta)
			push_luck_double_note.visible = true
	_set_push_luck_modal(true)
	_refresh_push_luck_button_visuals()

func _on_push_luck_closed() -> void:
	_reset_pyl_lock_state()
	_set_push_luck_modal(false)

func _wire_push_luck_buttons() -> void:
	if push_luck_cashout_button != null:
		var cashout_callable: Callable = Callable(self, "_on_push_luck_cashout_pressed")
		if not push_luck_cashout_button.pressed.is_connected(cashout_callable):
			push_luck_cashout_button.pressed.connect(cashout_callable)
		_wire_sign_preview(push_luck_cashout_button)
	if push_luck_condanna_button != null:
		var condanna_callable: Callable = Callable(self, "_on_push_luck_condanna_pressed")
		if not push_luck_condanna_button.pressed.is_connected(condanna_callable):
			push_luck_condanna_button.pressed.connect(condanna_callable)
		_wire_sign_preview(push_luck_condanna_button)
	if push_luck_double_button != null:
		var double_callable: Callable = Callable(self, "_on_push_luck_double_pressed")
		if not push_luck_double_button.pressed.is_connected(double_callable):
			push_luck_double_button.pressed.connect(double_callable)
		_wire_sign_preview(push_luck_double_button)

func _wire_ritual_advance_buttons() -> void:
	if pact_sealed_advance_button != null:
		var pact_callable: Callable = Callable(self, "_on_pact_ritual_next_pressed")
		if not pact_sealed_advance_button.pressed.is_connected(pact_callable):
			pact_sealed_advance_button.pressed.connect(pact_callable)
		_wire_sign_preview(pact_sealed_advance_button)
	if resolve_ritual_advance_button != null:
		var resolve_callable: Callable = Callable(self, "_on_resolve_ritual_next_pressed")
		if not resolve_ritual_advance_button.pressed.is_connected(resolve_callable):
			resolve_ritual_advance_button.pressed.connect(resolve_callable)
		_wire_sign_preview(resolve_ritual_advance_button)
	if resolve_ritual_strike_button != null:
		var strike_callable: Callable = Callable(self, "_on_resolve_ritual_strike_pressed")
		if not resolve_ritual_strike_button.pressed.is_connected(strike_callable):
			resolve_ritual_strike_button.pressed.connect(strike_callable)

func _wire_intermediate_choice_buttons() -> void:
	if intermediate_choice_placa_button != null:
		var placa_callable: Callable = Callable(self, "_on_intermediate_choice_placa_pressed")
		if not intermediate_choice_placa_button.pressed.is_connected(placa_callable):
			intermediate_choice_placa_button.pressed.connect(placa_callable)
	if intermediate_choice_provoca_button != null:
		var provoca_callable: Callable = Callable(self, "_on_intermediate_choice_provoca_pressed")
		if not intermediate_choice_provoca_button.pressed.is_connected(provoca_callable):
			intermediate_choice_provoca_button.pressed.connect(provoca_callable)

func _on_intermediate_choice_placa_pressed() -> void:
	if _gesture_choice_locked:
		return
	_set_gesture_choice_selected_state(0)
	_gesture_choice_locked = true
	_apply_decision_lock(
		intermediate_choice_panel,
		[intermediate_choice_placa_button, intermediate_choice_provoca_button],
		null,
		intermediate_choice_placa_button,
		false,
		false
	)
	_play_sfx(&"arena_gesture_placa")
	if not _emit_game_event_signal_if_available(&"request_mid_choice_select", [0]):
		_recover_gesture_choice_request_lock()
		return
	_start_gesture_choice_request_watchdog()

func _on_intermediate_choice_provoca_pressed() -> void:
	if _gesture_choice_locked:
		return
	_set_gesture_choice_selected_state(1)
	_gesture_choice_locked = true
	_apply_decision_lock(
		intermediate_choice_panel,
		[intermediate_choice_placa_button, intermediate_choice_provoca_button],
		null,
		intermediate_choice_provoca_button,
		false,
		false
	)
	_play_sfx(&"arena_gesture_provoca")
	if not _emit_game_event_signal_if_available(&"request_mid_choice_select", [1]):
		_recover_gesture_choice_request_lock()
		return
	_start_gesture_choice_request_watchdog()

func _start_gesture_choice_request_watchdog() -> void:
	_gesture_choice_request_sequence_id += 1
	var request_id: int = _gesture_choice_request_sequence_id
	var timer: SceneTreeTimer = get_tree().create_timer(GESTURE_CHOICE_WATCHDOG_SECONDS)
	timer.timeout.connect(Callable(self, "_recover_gesture_choice_request_if_still_open").bind(request_id), CONNECT_ONE_SHOT)

func _recover_gesture_choice_request_if_still_open(request_id: int) -> void:
	if request_id != _gesture_choice_request_sequence_id:
		return
	if not _gesture_choice_locked:
		return
	if intermediate_choice_modal == null or not intermediate_choice_modal.visible:
		return
	_recover_gesture_choice_request_lock()

func _recover_gesture_choice_request_lock() -> void:
	_reset_gesture_choice_state()

func _reset_gesture_choice_state() -> void:
	_gesture_choice_request_sequence_id += 1
	_gesture_choice_locked = false
	_set_gesture_choice_selected_state(-1)
	_reset_decision_surface(
		intermediate_choice_panel,
		[intermediate_choice_placa_button, intermediate_choice_provoca_button],
		null
	)

func _set_gesture_choice_selected_state(selected_index: int) -> void:
	var buttons: Array[Button] = [intermediate_choice_placa_button, intermediate_choice_provoca_button]
	var selected_styles: Array[StyleBox] = [GESTURE_PLACA_STYLE_SELECTED, GESTURE_PROVOCA_STYLE_SELECTED]
	var disabled_styles: Array[StyleBox] = [GESTURE_PLACA_STYLE_DISABLED, GESTURE_PROVOCA_STYLE_DISABLED]
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		if button == null:
			continue
		var selected: bool = index == selected_index
		button.set_meta(GESTURE_CHOICE_STATE_META, &"selected" if selected else &"normal")
		button.add_theme_stylebox_override("disabled", selected_styles[index] if selected else disabled_styles[index])
		button.add_theme_color_override(
			"font_disabled_color",
			Color(1.0, 0.91, 0.7, 1.0) if selected else Color(0.72, 0.69, 0.63, 1.0)
		)

func _on_push_luck_cashout_pressed() -> void:
	if _pyl_locked:
		return
	_play_sfx(&"registry_receipt_take")
	_pyl_locked = true
	_set_receipt_taken_state(true)
	_apply_decision_lock(push_luck_panel, _collect_pyl_buttons(), push_luck_audience_reason, push_luck_cashout_button)
	_pulse_pyl_panel(Color(0.55, 0.46, 0.28, 1.0))
	if not _emit_game_event_signal_if_available(&"request_pyl_cashout"):
		_recover_pyl_request_lock(tr("Stato: richiesta incasso non disponibile."))
		return
	_start_pyl_request_watchdog()

func _on_push_luck_condanna_pressed() -> void:
	if _pyl_locked:
		return
	_play_sfx(&"registry_condemnation_mark")
	_pyl_locked = true
	_set_condemnation_mark_registered_state(true)
	_apply_decision_lock(push_luck_panel, _collect_pyl_buttons(), push_luck_audience_reason, push_luck_condanna_button)
	_pulse_pyl_panel(Color(0.43, 0.13, 0.11, 1.0))
	if not _emit_game_event_signal_if_available(&"request_pyl_condanna"):
		_recover_pyl_request_lock(tr("Stato: richiesta condanna non disponibile."))
		return
	_start_pyl_request_watchdog()

func _on_push_luck_double_pressed() -> void:
	if _pyl_locked:
		return
	_play_sfx(&"registry_second_incision")
	_pyl_locked = true
	_set_second_incision_sealed_state(true)
	_apply_decision_lock(push_luck_panel, _collect_pyl_buttons(), push_luck_audience_reason, push_luck_double_button)
	_pulse_pyl_panel(Color(0.66, 0.25, 0.12, 1.0))
	if not _emit_game_event_signal_if_available(&"request_pyl_double"):
		_recover_pyl_request_lock(tr("Stato: richiesta rilancio non disponibile."))
		return
	_start_pyl_request_watchdog()

func _start_pyl_request_watchdog() -> void:
	_pyl_request_sequence_id += 1
	var request_id: int = _pyl_request_sequence_id
	var timer: SceneTreeTimer = get_tree().create_timer(1.25)
	timer.timeout.connect(Callable(self, "_recover_pyl_request_if_still_open").bind(request_id), CONNECT_ONE_SHOT)

func _recover_pyl_request_if_still_open(request_id: int) -> void:
	if request_id != _pyl_request_sequence_id:
		return
	if not _pyl_locked:
		return
	if push_luck_modal == null or not push_luck_modal.visible:
		return
	_recover_pyl_request_lock(tr("Stato: richiesta non accettata. Scegli di nuovo."))

func _recover_pyl_request_lock(message: String) -> void:
	_reset_pyl_lock_state()
	if push_luck_audience_reason != null:
		push_luck_audience_reason.text = message
		push_luck_audience_reason.visible = true

func _is_pyl_button(button: Button) -> bool:
	if button == null or push_luck_panel == null:
		return false
	return push_luck_panel == button or push_luck_panel.is_ancestor_of(button)

func _collect_pyl_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	if push_luck_panel == null:
		return buttons
	var descendants: Array[Node] = push_luck_panel.find_children("*", "Button", true, false)
	for node: Node in descendants:
		var button: Button = node as Button
		if button == null:
			continue
		buttons.append(button)
	return buttons

func _set_pyl_buttons_enabled(enabled: bool) -> void:
	if enabled:
		for button: Button in _pyl_locked_buttons:
			if button == null:
				continue
			button.disabled = false
		_pyl_locked_buttons.clear()
		return
	_pyl_locked_buttons.clear()
	for button: Button in _collect_pyl_buttons():
		if button == null or not button.visible or button.disabled:
			continue
		button.disabled = true
		_pyl_locked_buttons.append(button)

func _pulse_pyl_panel(pulse_color: Color = Color(SIGN_LOCK_DARKEN_RGB, SIGN_LOCK_DARKEN_RGB, SIGN_LOCK_DARKEN_RGB, 1.0)) -> void:
	if push_luck_panel == null:
		return
	if _pyl_lock_feedback_tween != null and _pyl_lock_feedback_tween.is_valid():
		_pyl_lock_feedback_tween.kill()
	var panel_color: Color = push_luck_panel.modulate
	push_luck_panel.modulate = Color(pulse_color.r, pulse_color.g, pulse_color.b, panel_color.a)
	_pyl_lock_feedback_tween = create_tween()
	_pyl_lock_feedback_tween.set_trans(Tween.TRANS_QUAD)
	_pyl_lock_feedback_tween.set_ease(Tween.EASE_OUT)
	_pyl_lock_feedback_tween.tween_property(push_luck_panel, "modulate:r", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
	_pyl_lock_feedback_tween.parallel().tween_property(push_luck_panel, "modulate:g", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
	_pyl_lock_feedback_tween.parallel().tween_property(push_luck_panel, "modulate:b", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)

func _reset_pyl_lock_state() -> void:
	if _pyl_lock_feedback_tween != null and _pyl_lock_feedback_tween.is_valid():
		_pyl_lock_feedback_tween.kill()
	if push_luck_panel != null:
		var panel_color: Color = push_luck_panel.modulate
		push_luck_panel.modulate = Color(1.0, 1.0, 1.0, panel_color.a)
	_pyl_locked = false
	_set_receipt_taken_state(false)
	_set_condemnation_mark_registered_state(false)
	_set_second_incision_sealed_state(false)
	_set_pyl_buttons_enabled(true)

func _set_receipt_taken_state(taken: bool) -> void:
	if push_luck_cashout_button == null:
		return
	push_luck_cashout_button.set_meta(RECEIPT_TAKEN_META, taken)
	push_luck_cashout_button.add_theme_stylebox_override(
		"disabled",
		RECEIPT_STYLE_PRESSED if taken else RECEIPT_STYLE_DISABLED
	)
	push_luck_cashout_button.add_theme_color_override(
		"font_disabled_color",
		Color(0.95, 0.91, 0.78, 1.0) if taken else Color(0.54, 0.52, 0.48, 1.0)
	)

func _set_condemnation_mark_registered_state(registered: bool) -> void:
	if push_luck_condanna_button == null:
		return
	push_luck_condanna_button.set_meta(CONDEMNATION_MARK_REGISTERED_META, registered)
	push_luck_condanna_button.add_theme_stylebox_override(
		"disabled",
		CONDEMNATION_MARK_STYLE_REGISTERED if registered else CONDEMNATION_MARK_STYLE_DISABLED
	)
	push_luck_condanna_button.add_theme_color_override(
		"font_disabled_color",
		Color(1.0, 0.82, 0.68, 1.0) if registered else Color(0.54, 0.52, 0.48, 1.0)
	)

func _set_second_incision_sealed_state(sealed: bool) -> void:
	if push_luck_double_button == null:
		return
	push_luck_double_button.set_meta(SECOND_INCISION_SEALED_META, sealed)
	push_luck_double_button.add_theme_stylebox_override(
		"disabled",
		SECOND_INCISION_STYLE_SEALED if sealed else SECOND_INCISION_STYLE_DISABLED
	)
	push_luck_double_button.add_theme_color_override(
		"font_disabled_color",
		Color(1.0, 0.84, 0.66, 1.0) if sealed else Color(0.54, 0.52, 0.48, 1.0)
	)

func _on_bet_win_pressed() -> void:
	_play_sfx(&"cursor_select")
	_emit_intro_bet_request(0)

func _on_bet_fast_pressed() -> void:
	_play_sfx(&"cursor_select")
	_emit_intro_bet_request(1)

func _emit_intro_bet_request(slot_index: int) -> void:
	if not _has_game_event_signal(&"request_place_bet"):
		return
	var bet_ids: PackedStringArray = BetCatalog.level3_bet_ids()
	if slot_index < 0 or slot_index >= bet_ids.size():
		push_error("UIRoot: intro bet slot out of range (%d/%d)" % [slot_index, bet_ids.size()])
		return
	var bet_id: String = bet_ids[slot_index]
	if bet_id == "":
		push_error("UIRoot: intro bet id empty at slot %d" % slot_index)
		return
	_emit_game_event_signal_if_available(&"request_place_bet", [bet_id, 0])

func _on_restart_pressed() -> void:
	_activate_final_dossier_route(restart_button, &"request_end_run_restart")

func _on_retry_pressed() -> void:
	_activate_final_dossier_route(next_bet_button, &"request_end_run_next_bet")

func _request_reset() -> void:
	_set_game_over_modal(false)

	_emit_game_event_signal_if_available(&"request_new_run")
	_hide_scars_detail()
	_refresh_modal_dimmer()

func _request_next_bet() -> void:
	# Legacy next-bet request removed; current flow advances via RunManager level-3 events.
	pass

func _request_retry() -> void:
	_set_game_over_modal(false)
	_emit_game_event_signal_if_available(&"request_retry_run")
	_hide_scars_detail()
	_refresh_modal_dimmer()

func _on_quit_pressed() -> void:
	_activate_final_dossier_route(quit_button, &"request_end_run_quit")

func _handle_fast_countdown(seconds: int) -> void:
	if fast_countdown_label == null:
		return
	if not _fast_countdown_active:
		_stop_fast_blink()
		fast_countdown_label.visible = false
		if fast_countdown_panel != null:
			fast_countdown_panel.visible = false
		return
	if seconds <= 0:
		_reset_fast_countdown()
		return
	fast_countdown_label.visible = true
	if fast_countdown_panel != null:
		fast_countdown_panel.visible = true
	fast_countdown_label.text = "FAST: %ds" % seconds
	if seconds <= 5:
		_start_fast_blink()
	else:
		_stop_fast_blink()
		fast_countdown_label.modulate.a = 1.0

func _start_fast_blink() -> void:
	if fast_blink_timer == null:
		return
	if not fast_blink_timer.is_stopped():
		return
	fast_blink_timer.start()

func _stop_fast_blink() -> void:
	if fast_blink_timer != null and not fast_blink_timer.is_stopped():
		fast_blink_timer.stop()
	if fast_countdown_label != null:
		fast_countdown_label.modulate.a = 1.0

func _on_fast_blink_tick() -> void:
	if fast_countdown_label == null:
		return
	var next_alpha: float = 1.0
	if fast_countdown_label.modulate.a > 0.6:
		next_alpha = 0.2
	fast_countdown_label.modulate.a = next_alpha

func _refresh_runtime_group_cache(log_missing: bool) -> void:
	if _run_manager_port != null:
		_run_manager_port.has_manager()
	if log_missing and (_run_manager_port == null or not _run_manager_port.has_manager()):
		push_error("UI: missing run_manager group node")
	if _run_manager_port != null:
		_arena = _run_manager_port.get_arena()
	if _arena == null:
		_arena = get_tree().get_first_node_in_group("arena")

func _build_bet_buttons(bets: Array[Dictionary]) -> void:
	if bet_buttons_container == null:
		return
	_clear_bet_buttons()
	var add_intro_note: bool = _get_arena_index() <= 1
	var intro_note: String = fmt_system_state("cicatrici registrate; raddoppio continuato")
	var note_used: bool = false
	var first_bet_id: String = ""
	for bet_value: Dictionary in bets:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: String = str(bet.get("id", ""))
		if bet_id == "":
			continue
		if first_bet_id == "":
			first_bet_id = bet_id
		var extra_note: String = ""
		if add_intro_note and not note_used:
			extra_note = intro_note
			note_used = true
		var option_node: VBoxContainer = _create_bet_option(bet_id, bet, extra_note)
		bet_buttons_container.add_child(option_node)
	if first_bet_id != "":
		_selected_bet_id = first_bet_id
	_refresh_bet_selection_visuals()
	_update_bet_focus_telegraph()

func _safe_load_stylebox(path: String) -> StyleBox:
	if not ResourceLoader.exists(path, "StyleBox"):
		return null
	return load(path) as StyleBox

func _create_bet_option(bet_id: String, bet: Dictionary, extra_note: String) -> VBoxContainer:
	var option_box: VBoxContainer = VBoxContainer.new()
	option_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	option_box.custom_minimum_size = Vector2(0, 280)
	option_box.add_theme_constant_override("separation", 10)

	var select_button: Button = _create_bet_button(bet_id, bet, extra_note)
	option_box.add_child(select_button)
	_bet_select_buttons_by_id[bet_id] = select_button
	_bet_buttons.append(select_button)

	var signature_button: Button = _create_signature_button(bet_id)
	option_box.add_child(signature_button)
	_bet_signature_buttons_by_id[bet_id] = signature_button
	_bet_buttons.append(signature_button)

	return option_box

func _create_bet_button(bet_id: String, bet: Dictionary, extra_note: String) -> Button:
	var button: Button = Button.new()
	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 230)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 20)
	button.text = _format_bet_button_text(bet_id, bet, extra_note)
	button.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
	button.vertical_icon_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_TOP
	button.disabled = false
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	var normal_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_NORMAL_PATH)
	var hover_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_HOVER_PATH)
	var pressed_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_PRESSED_PATH)
	var disabled_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_DISABLED_PATH)
	if normal_style != null:
		button.add_theme_stylebox_override("normal", normal_style)
	if hover_style != null:
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("focus", hover_style)
	if pressed_style != null:
		button.add_theme_stylebox_override("pressed", pressed_style)
	if disabled_style != null:
		button.add_theme_stylebox_override("disabled", disabled_style)
	var pressed_callable: Callable = Callable(self, "_on_bet_choice_pressed").bind(bet_id)
	if not button.pressed.is_connected(pressed_callable):
		button.pressed.connect(pressed_callable)
	_wire_sign_preview(button)
	return button

func _create_signature_button(bet_id: String) -> Button:
	var button: Button = Button.new()
	button.text = tr("FIRMA")
	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 18)
	var normal_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_NORMAL_PATH)
	var hover_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_HOVER_PATH)
	var pressed_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_PRESSED_PATH)
	var disabled_style: StyleBox = _safe_load_stylebox(BUTTON_STYLE_PRIMARY_DISABLED_PATH)
	if normal_style != null:
		button.add_theme_stylebox_override("normal", normal_style)
	if hover_style != null:
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("focus", hover_style)
	if pressed_style != null:
		button.add_theme_stylebox_override("pressed", pressed_style)
	if disabled_style != null:
		button.add_theme_stylebox_override("disabled", disabled_style)
	button.disabled = true
	var pressed_callable: Callable = Callable(self, "_on_bet_signature_pressed").bind(bet_id)
	if not button.pressed.is_connected(pressed_callable):
		button.pressed.connect(pressed_callable)
	_wire_sign_preview(button)
	return button
func _format_bet_button_text(bet_id: String, bet: Dictionary, extra_note: String) -> String:
	var name_text: String = str(bet.get("display_title", bet.get("name", bet_id)))
	var subtitle_text: String = str(bet.get("display_subtitle", ""))
	var condition_text: String = str(bet.get("condition", ""))
	var pact_text: String = str(bet.get("pact", ""))
	var doom_text: String = str(bet.get("doom", ""))
	var archetype_label: String = str(bet.get("archetype_label", ""))
	var lines: Array[String] = []
	if doom_text != "":
		lines.append(tr("CONDANNA: %s") % name_text)
		lines.append(doom_text)
	else:
		lines.append(tr("CONDANNA: %s") % name_text)
	if archetype_label != "":
		lines.append(archetype_label)
	if subtitle_text != "":
		lines.append(subtitle_text)
	if condition_text != "":
		lines.append(tr("CONDIZIONE: %s") % condition_text)
	if pact_text != "":
		lines.append(tr("PATTO: %s") % pact_text)
	if extra_note != "":
		lines.append(tr("NOTA: %s") % extra_note)
	return "\n".join(lines)

func _refresh_bet_selection_visuals() -> void:
	for bet_id_variant: Variant in _bet_select_buttons_by_id.keys():
		var bet_id: String = str(bet_id_variant)
		_set_bet_option_selected(bet_id, bet_id == _selected_bet_id)

func _set_bet_option_selected(bet_id: String, selected: bool) -> void:
	var select_button: Button = _bet_select_buttons_by_id.get(bet_id, null) as Button
	if select_button != null:
		select_button.add_theme_color_override("font_color", Color(0.98, 0.95, 0.9, 1.0) if selected else Color(0.93, 0.91, 0.87, 1.0))
		select_button.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.92, 1.0))
		select_button.add_theme_color_override("font_focus_color", Color(1.0, 0.97, 0.92, 1.0))
		select_button.add_theme_color_override("font_pressed_color", Color(0.98, 0.95, 0.9, 1.0))
		select_button.add_theme_constant_override("line_spacing", 6)
	var signature_button: Button = _bet_signature_buttons_by_id.get(bet_id, null) as Button
	if signature_button != null:
		signature_button.disabled = false
		signature_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if selected else Color(1.0, 1.0, 1.0, 0.92)

func _format_lock_note(reason: String, fallback: String) -> String:
	var text: String = reason.strip_edges()
	if text == "":
		text = fallback
	return fmt_system_state(text)

func _extract_ritual_outcome_snapshot(payload: Dictionary) -> Dictionary:
	return {
		"risk_profile": str(payload.get("risk_profile", "")),
		"pressure_mod": float(payload.get("pressure_mod", 0.0)),
		"failure_chance": float(payload.get("failure_chance", 0.0)),
		"outcome_tier": str(payload.get("outcome_tier", "")),
		"condemnation_flag": bool(payload.get("condemnation_flag", false)),
	}

func fmt_register_line(action: String, consequence: String) -> String:
	var action_text: String = action.strip_edges().to_lower()
	if action_text == "":
		action_text = tr("registrato")
	var consequence_text: String = consequence.strip_edges().to_lower()
	if consequence_text == "":
		consequence_text = tr("continuato")
	return tr("Atto registrato: %s. Stato: %s.") % [action_text, consequence_text]

func fmt_system_state(label: String) -> String:
	var text: String = label.strip_edges()
	if text == "":
		return ""
	if not text.ends_with("."):
		text += "."
	return text

func _clear_bet_buttons() -> void:
	_bet_buttons.clear()
	_bet_select_buttons_by_id.clear()
	_bet_signature_buttons_by_id.clear()
	_selected_bet_id = ""
	if bet_buttons_container == null:
		return
	for child in bet_buttons_container.get_children():
		if child is Node:
			child.queue_free()

func _on_bet_failed(can_retry: bool) -> void:
	_set_bet_modal(false)
	_reset_bet_confirmation()
	_reset_fast_countdown()
	_set_game_over_modal(true)
	_set_verdict_mode(false)
	_last_finale_title = tr("PERCORSO FALLITO")
	if can_retry:
		_last_finale_title = tr("PATTO FALLITO")
	_last_finale_text = ""
	_last_finale_scars = []
	_last_finale_ending_id = ""
	_last_finale_seed = 0
	_last_finale_stats = {}
	_last_finale_hint = fmt_system_state(tr("seleziona un'azione"))
	if can_retry:
		_last_finale_hint = fmt_system_state(tr("scommessa rinunciata"))
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	if next_bet_button != null:
		next_bet_button.visible = can_retry
		next_bet_button.text = tr("RIPROVA SCOMMESSA")
	if restart_button != null:
		restart_button.text = tr("NUOVO PERCORSO")
	_reset_fast_countdown()
	var bet_failed_read_buttons: Array[Button] = []
	if restart_button != null:
		bet_failed_read_buttons.append(restart_button)
	if next_bet_button != null and next_bet_button.visible:
		bet_failed_read_buttons.append(next_bet_button)
	if quit_button != null:
		bet_failed_read_buttons.append(quit_button)
	_apply_modal_read_delay(bet_failed_read_buttons)

func _on_bet_choice_pressed(bet_id: String) -> void:
	if bet_id == "":
		return
	_play_sfx(&"cursor_move")
	_selected_bet_id = bet_id
	_refresh_bet_selection_visuals()
	_update_bet_focus_telegraph()
	get_viewport().gui_release_focus()

func _on_bet_signature_pressed(bet_id: String) -> void:
	if bet_id == "":
		return
	_play_sfx(&"cursor_select")
	_selected_bet_id = bet_id
	_refresh_bet_selection_visuals()
	_place_bet(bet_id)

func _on_bet_confirm_pressed() -> void:
	_play_sfx(&"cursor_select")
	_emit_game_event_signal_if_available(&"request_intro_confirm")

func _place_bet(bet_id: String) -> void:
	_selected_bet_id = bet_id
	_reset_fast_countdown()
	_reset_bet_confirmation()
	var sign_buttons: Array[Button] = []
	sign_buttons.append_array(_bet_buttons)
	_apply_decision_lock(_resolve_bet_sign_panel() as Control, sign_buttons, condanna_focus_label)
	_emit_game_event_signal_if_available(&"request_place_bet", [bet_id, 0])

func _apply_decision_lock(panel: Control, buttons: Array[Button], hint_label: Label, selected_button: Button = null, play_feedback_sfx: bool = true, scale_selected: bool = true) -> void:
	for button: Button in buttons:
		if button == null or not button.visible or button.disabled:
			continue
		button.disabled = true
		if selected_button != null:
			button.modulate = Color(1.0, 1.0, 1.0, 1.0) if button == selected_button else Color(1.0, 1.0, 1.0, 0.45)
			button.scale = Vector2(1.025, 1.025) if button == selected_button and scale_selected else Vector2.ONE
		else:
			button.scale = Vector2.ONE
	if hint_label != null:
		hint_label.text = tr("Stato: scelta acquisita.")
		hint_label.visible = true
	if panel == null:
		return
	if _sign_feedback_tween != null and _sign_feedback_tween.is_valid():
		_sign_feedback_tween.kill()
	var panel_color: Color = panel.modulate
	panel.modulate = Color(SIGN_LOCK_DARKEN_RGB, SIGN_LOCK_DARKEN_RGB, SIGN_LOCK_DARKEN_RGB, panel_color.a)
	_sign_feedback_tween = create_tween()
	_sign_feedback_tween.set_trans(Tween.TRANS_QUAD)
	_sign_feedback_tween.set_ease(Tween.EASE_OUT)
	_sign_feedback_tween.tween_property(panel, "modulate:r", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
	_sign_feedback_tween.parallel().tween_property(panel, "modulate:g", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
	_sign_feedback_tween.parallel().tween_property(panel, "modulate:b", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
	if play_feedback_sfx:
		_play_sign_feedback_sfx_if_available()

func _reset_decision_surface(panel: Control, buttons: Array[Button], hint_label: Label) -> void:
	for button: Button in buttons:
		if button == null:
			continue
		button.disabled = false
		button.scale = Vector2.ONE
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if hint_label != null:
		hint_label.text = tr("Stato: in attesa di scelta.")
		hint_label.visible = true
	if panel != null:
		var panel_color: Color = panel.modulate
		panel.modulate = Color(1.0, 1.0, 1.0, panel_color.a)
	if not _bet_signature_buttons_by_id.is_empty():
		_refresh_bet_selection_visuals()

func _pre_resolve_tension_boost() -> void:
	if modals_root == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(modals_root, "modulate:a", 0.85, 0.08)
	tween.tween_property(modals_root, "modulate:a", 1.0, 0.12)

func _resolve_bet_sign_panel() -> CanvasItem:
	if betting_circle != null and betting_circle.visible:
		return betting_circle
	return bet_panel
func _wire_sign_preview(button: Button) -> void:
	if button == null:
		return
	var hover_entered_callable: Callable = Callable(self, "_on_sign_preview_entered").bind(button)
	if not button.mouse_entered.is_connected(hover_entered_callable):
		button.mouse_entered.connect(hover_entered_callable)
	var focus_entered_callable: Callable = Callable(self, "_on_sign_preview_entered").bind(button)
	if not button.focus_entered.is_connected(focus_entered_callable):
		button.focus_entered.connect(focus_entered_callable)
	var hover_exited_callable: Callable = Callable(self, "_on_sign_preview_exited").bind(button)
	if not button.mouse_exited.is_connected(hover_exited_callable):
		button.mouse_exited.connect(hover_exited_callable)
	var focus_exited_callable: Callable = Callable(self, "_on_sign_preview_exited").bind(button)
	if not button.focus_exited.is_connected(focus_exited_callable):
		button.focus_exited.connect(focus_exited_callable)

func _on_sign_preview_entered(button: Button) -> void:
	if button == null or button.disabled or _is_signing:
		return
	_play_sfx(&"button_hover")
	button.pivot_offset = button.size * 0.5
	button.scale = Vector2(SIGN_PREVIEW_SCALE, SIGN_PREVIEW_SCALE)

func _on_sign_preview_exited(button: Button) -> void:
	if button == null:
		return
	button.scale = Vector2.ONE

func begin_sign_feedback(buttons: Array[Button], panel: CanvasItem) -> void:
	if _is_signing:
		return
	_is_signing = true
	_sign_feedback_buttons.clear()
	for button: Button in buttons:
		if button == null:
			continue
		button.disabled = true
		button.scale = Vector2.ONE
		_sign_feedback_buttons.append(button)
	_sign_feedback_panel = panel
	if _sign_feedback_panel != null:
		if _sign_feedback_tween != null and _sign_feedback_tween.is_valid():
			_sign_feedback_tween.kill()
		var panel_color: Color = _sign_feedback_panel.modulate
		_sign_feedback_panel.modulate = Color(SIGN_LOCK_DARKEN_RGB, SIGN_LOCK_DARKEN_RGB, SIGN_LOCK_DARKEN_RGB, panel_color.a)
		_sign_feedback_tween = create_tween()
		_sign_feedback_tween.set_trans(Tween.TRANS_QUAD)
		_sign_feedback_tween.set_ease(Tween.EASE_OUT)
		_sign_feedback_tween.tween_property(_sign_feedback_panel, "modulate:r", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
		_sign_feedback_tween.parallel().tween_property(_sign_feedback_panel, "modulate:g", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
		_sign_feedback_tween.parallel().tween_property(_sign_feedback_panel, "modulate:b", 1.0, SIGN_LOCK_FEEDBACK_SECONDS)
	_play_sign_feedback_sfx_if_available()

func _play_sign_feedback_sfx_if_available() -> void:
	_play_sfx(&"cursor_select")

func _play_sfx(cue: StringName) -> void:
	var sfx_bus: Node = get_node_or_null("/root/SfxBus")
	if sfx_bus == null or not sfx_bus.has_method("play_cue"):
		return
	sfx_bus.call("play_cue", cue)

func _reset_sign_feedback() -> void:
	if _sign_feedback_tween != null and _sign_feedback_tween.is_valid():
		_sign_feedback_tween.kill()
	if _sign_feedback_panel != null:
		var panel_color: Color = _sign_feedback_panel.modulate
		_sign_feedback_panel.modulate = Color(1.0, 1.0, 1.0, panel_color.a)
	for button: Button in _sign_feedback_buttons:
		if button == null:
			continue
		button.disabled = false
		button.scale = Vector2.ONE
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_sign_feedback_buttons.clear()
	_sign_feedback_panel = null
	_is_signing = false

func _get_bet_name(bet_id: String) -> String:
	if not _bets_by_id.has(bet_id):
		return bet_id
	var bet: Dictionary = _bets_by_id.get(bet_id, {}) as Dictionary
	if bet.is_empty():
		return bet_id
	return str(bet.get("display_title", bet.get("name", bet_id)))

func _apply_modal_read_delay(buttons: Array[Button]) -> void:
	if buttons.is_empty():
		return
	var initial_states: Array[bool] = []
	initial_states.resize(buttons.size())
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		initial_states[index] = button.disabled
		button.disabled = true
		button.modulate = Color(0.92, 0.88, 0.78, 0.72)
	await get_tree().create_timer(MIN_MODAL_READ_TIME_SEC).timeout
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		var should_disable: bool = initial_states[index]
		if _pyl_locked and _is_pyl_button(button):
			should_disable = true
		button.disabled = should_disable
		button.modulate = Color(1.0, 0.98, 0.86, 1.0) if not should_disable else Color(0.86, 0.82, 0.74, 0.62)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not should_disable else Control.CURSOR_ARROW
		if _is_pyl_button(button):
			_apply_push_luck_button_visual(button)

func _refresh_push_luck_button_visuals() -> void:
	for button: Button in [push_luck_cashout_button, push_luck_condanna_button, push_luck_double_button]:
		_apply_push_luck_button_visual(button)

func _apply_push_luck_button_visual(button: Button) -> void:
	if button == null:
		return
	var active: bool = button.visible and not button.disabled
	button.modulate = Color(1.0, 0.98, 0.86, 1.0) if active else Color(0.82, 0.78, 0.7, 0.62)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if active else Control.CURSOR_ARROW
	if button == push_luck_cashout_button:
		var taken: bool = bool(button.get_meta(RECEIPT_TAKEN_META, false))
		button.add_theme_color_override("font_color", Color(0.16, 0.11, 0.06, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.08, 0.055, 0.03, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.08, 0.055, 0.03, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.95, 0.91, 0.78, 1.0))
		button.add_theme_color_override(
			"font_disabled_color",
			Color(0.95, 0.91, 0.78, 1.0) if taken else Color(0.54, 0.52, 0.48, 1.0)
		)
		return
	if button == push_luck_condanna_button:
		var registered: bool = bool(button.get_meta(CONDEMNATION_MARK_REGISTERED_META, false))
		button.add_theme_color_override("font_color", Color(0.98, 0.9, 0.78, 1.0) if active else Color(0.54, 0.52, 0.48, 1.0))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.84, 1.0))
		button.add_theme_color_override("font_focus_color", Color(1.0, 0.95, 0.84, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.68, 1.0))
		button.add_theme_color_override(
			"font_disabled_color",
			Color(1.0, 0.82, 0.68, 1.0) if registered else Color(0.54, 0.52, 0.48, 1.0)
		)
		return
	if button == push_luck_double_button:
		var sealed: bool = bool(button.get_meta(SECOND_INCISION_SEALED_META, false))
		button.add_theme_color_override("font_color", Color(0.98, 0.9, 0.66, 1.0) if active else Color(0.54, 0.52, 0.48, 1.0))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.72, 1.0))
		button.add_theme_color_override("font_focus_color", Color(1.0, 0.95, 0.72, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.84, 0.66, 1.0))
		button.add_theme_color_override(
			"font_disabled_color",
			Color(1.0, 0.84, 0.66, 1.0) if sealed else Color(0.54, 0.52, 0.48, 1.0)
		)

func _fade_modal(panel: CanvasItem, modal: Control, active: bool, tween: Tween, kind: String = MOTION_KIND_STANDARD) -> Tween:
	if panel == null or modal == null:
		if modal != null:
			modal.visible = active
		if panel != null:
			panel.visible = active
		return tween
	if tween != null and tween.is_valid():
		tween.kill()
	if active:
		modal.visible = true
		panel.visible = true
		panel.modulate.a = 0.0
		tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		var fade_in_seconds: float = ENDING_FADE_IN_SEC if kind == MOTION_KIND_ENDING else FADE_IN_SEC
		if kind == MOTION_KIND_RITUAL:
			fade_in_seconds = 0.32
		tween.tween_property(panel, "modulate:a", 1.0, fade_in_seconds)
	else:
		if not panel.visible:
			modal.visible = false
			return tween
		tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN)
		var fade_out_seconds: float = ENDING_FADE_OUT_SEC if kind == MOTION_KIND_ENDING else FADE_OUT_SEC
		if kind == MOTION_KIND_RITUAL:
			fade_out_seconds = 0.24
		tween.tween_property(panel, "modulate:a", 0.0, fade_out_seconds)
		tween.tween_callback(Callable(self, "_on_modal_fade_out_complete").bind(panel, modal))
	return tween

func hide_all_modals() -> void:
	if _bet_modal_fade_tween != null and _bet_modal_fade_tween.is_valid():
		_bet_modal_fade_tween.kill()
	if _pact_sealed_modal_fade_tween != null and _pact_sealed_modal_fade_tween.is_valid():
		_pact_sealed_modal_fade_tween.kill()
	if _resolve_ritual_modal_fade_tween != null and _resolve_ritual_modal_fade_tween.is_valid():
		_resolve_ritual_modal_fade_tween.kill()
	if _intermediate_choice_modal_fade_tween != null and _intermediate_choice_modal_fade_tween.is_valid():
		_intermediate_choice_modal_fade_tween.kill()
	if _push_luck_modal_fade_tween != null and _push_luck_modal_fade_tween.is_valid():
		_push_luck_modal_fade_tween.kill()
	if _game_over_modal_fade_tween != null and _game_over_modal_fade_tween.is_valid():
		_game_over_modal_fade_tween.kill()
	if bet_panel != null:
		bet_panel.visible = false
	if bet_modal != null:
		bet_modal.visible = false
	if pact_sealed_panel != null:
		pact_sealed_panel.visible = false
	if pact_sealed_modal != null:
		pact_sealed_modal.visible = false
	if resolve_ritual_panel != null:
		resolve_ritual_panel.visible = false
	if resolve_ritual_modal != null:
		resolve_ritual_modal.visible = false
	_stop_resolution_ritual_interaction()
	if intermediate_choice_panel != null:
		intermediate_choice_panel.visible = false
	if intermediate_choice_modal != null:
		intermediate_choice_modal.visible = false
	if push_luck_panel != null:
		push_luck_panel.visible = false
	if push_luck_modal != null:
		push_luck_modal.visible = false
	if game_over_panel != null:
		game_over_panel.visible = false
	if game_over_modal != null:
		game_over_modal.visible = false
	if scars_detail_panel != null:
		scars_detail_panel.visible = false
	if betting_circle != null:
		betting_circle.visible = false
	_restore_betting_overlay_visual_suppression()
	exit_ending_mode()
	_current_modal = null
	_refresh_modal_dimmer()

func show_modal(modal: Control) -> void:
	hide_all_modals()
	if modal == null:
		return
	modal.visible = true
	modal.move_to_front()
	_current_modal = modal
	_refresh_modal_dimmer()

func _on_modal_fade_out_complete(panel: CanvasItem, modal: Control) -> void:
	if panel != null:
		_restore_panel_motion_base(panel)
		panel.visible = false
		panel.modulate.a = 1.0
	if modal != null:
		modal.visible = false
		if modal == _current_modal:
			_current_modal = null
	_refresh_modal_dimmer()

func _get_panel_motion_base_position(control: Control) -> Vector2:
	if control == null:
		return Vector2.ZERO
	if not control.has_meta(MOTION_BASE_POSITION_META):
		control.set_meta(MOTION_BASE_POSITION_META, control.position)
	return control.get_meta(MOTION_BASE_POSITION_META) as Vector2

func _restore_panel_motion_base(panel: CanvasItem) -> void:
	var control: Control = panel as Control
	if control == null:
		return
	control.position = _get_panel_motion_base_position(control)
	control.scale = Vector2.ONE

func _play_panel_enter(panel: CanvasItem, kind: String = MOTION_KIND_STANDARD) -> void:
	if panel == null:
		return
	var control: Control = panel as Control
	if control == null:
		return
	var base_position: Vector2 = _get_panel_motion_base_position(control)
	var start_scale: Vector2 = Vector2(0.985, 0.985)
	var start_position: Vector2 = base_position
	var seconds: float = 0.18
	match kind:
		MOTION_KIND_RITUAL:
			start_scale = Vector2(0.965, 0.965)
			start_position = base_position + Vector2(0.0, 18.0)
			seconds = 0.34
		MOTION_KIND_ENDING:
			start_scale = Vector2(0.975, 0.975)
			seconds = 0.24
		_:
			pass
	control.pivot_offset = control.size * 0.5
	control.position = start_position
	control.scale = start_scale
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, seconds)
	tween.parallel().tween_property(control, "position", base_position, seconds)

func _play_backdrop_enter(modal: Control, kind: String = MOTION_KIND_STANDARD) -> void:
	if modal == null:
		return
	var texture_backdrop: TextureRect = _find_modal_texture_backdrop(modal)
	if texture_backdrop != null:
		if not texture_backdrop.has_meta(BACKDROP_BASE_SCALE_META):
			texture_backdrop.set_meta(BACKDROP_BASE_SCALE_META, texture_backdrop.scale)
		var base_scale: Vector2 = texture_backdrop.get_meta(BACKDROP_BASE_SCALE_META) as Vector2
		texture_backdrop.pivot_offset = texture_backdrop.size * 0.5
		var start_scale: Vector2 = base_scale * (Vector2(1.018, 1.018) if kind == MOTION_KIND_ENDING else Vector2(1.012, 1.012))
		texture_backdrop.scale = start_scale
		var backdrop_tween: Tween = create_tween()
		backdrop_tween.set_trans(Tween.TRANS_SINE)
		backdrop_tween.set_ease(Tween.EASE_OUT)
		backdrop_tween.tween_property(texture_backdrop, "scale", base_scale, 1.15 if kind == MOTION_KIND_ENDING else 0.7)
	var shade: ColorRect = _find_modal_shade(modal)
	if shade == null:
		return
	if not shade.has_meta(BACKDROP_SHADE_ALPHA_META):
		shade.set_meta(BACKDROP_SHADE_ALPHA_META, shade.color.a)
	var base_alpha: float = float(shade.get_meta(BACKDROP_SHADE_ALPHA_META))
	var color: Color = shade.color
	color.a = clamp(base_alpha + (0.12 if kind == MOTION_KIND_ENDING else 0.08), 0.0, 0.86)
	shade.color = color
	var shade_tween: Tween = create_tween()
	shade_tween.set_trans(Tween.TRANS_SINE)
	shade_tween.set_ease(Tween.EASE_OUT)
	shade_tween.tween_property(shade, "color:a", base_alpha, 0.9 if kind == MOTION_KIND_ENDING else 0.55)

func _find_modal_texture_backdrop(modal: Control) -> TextureRect:
	var backdrops: Array[Node] = modal.find_children("*Backdrop*", "TextureRect", true, false)
	if backdrops.is_empty():
		backdrops = modal.find_children("*Background*", "TextureRect", true, false)
	for node: Node in backdrops:
		var texture_rect: TextureRect = node as TextureRect
		if texture_rect != null and texture_rect.visible:
			return texture_rect
	return null

func _find_modal_shade(modal: Control) -> ColorRect:
	var shades: Array[Node] = modal.find_children("*Shade*", "ColorRect", true, false)
	for node: Node in shades:
		var shade: ColorRect = node as ColorRect
		if shade != null and shade.visible:
			return shade
	return null

func _set_bet_modal(active: bool) -> void:
	if active:
		show_modal(bet_modal)
	_bet_modal_fade_tween = _fade_modal(bet_panel, bet_modal, active, _bet_modal_fade_tween, MOTION_KIND_STANDARD)
	if active:
		_play_panel_enter(bet_panel, MOTION_KIND_STANDARD)
	_emit_modal_telemetry("bet", active)
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_pact_sealed_modal(active: bool) -> void:
	if active:
		show_modal(pact_sealed_modal)
	_pact_sealed_modal_fade_tween = _fade_modal(pact_sealed_panel, pact_sealed_modal, active, _pact_sealed_modal_fade_tween, MOTION_KIND_RITUAL)
	if active:
		_play_backdrop_enter(pact_sealed_modal, MOTION_KIND_RITUAL)
		_play_sfx(&"pickup")
		_play_panel_enter(pact_sealed_panel, MOTION_KIND_RITUAL)
	_emit_modal_telemetry("pact_sealed", active)
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_resolve_ritual_modal(active: bool) -> void:
	if active:
		show_modal(resolve_ritual_modal)
		_reset_resolution_ritual_interaction()
	else:
		_stop_resolution_ritual_interaction()
	_resolve_ritual_modal_fade_tween = _fade_modal(resolve_ritual_panel, resolve_ritual_modal, active, _resolve_ritual_modal_fade_tween, MOTION_KIND_RITUAL)
	if active:
		_play_backdrop_enter(resolve_ritual_modal, MOTION_KIND_RITUAL)
		_play_sfx(&"cursor_move")
		_play_panel_enter(resolve_ritual_panel, MOTION_KIND_RITUAL)
	_emit_modal_telemetry("resolve_ritual", active)
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_intermediate_choice_modal(active: bool) -> void:
	if not active:
		_reset_gesture_choice_state()
	if active:
		show_modal(intermediate_choice_modal)
	_intermediate_choice_modal_fade_tween = _fade_modal(
		intermediate_choice_panel,
		intermediate_choice_modal,
		active,
		_intermediate_choice_modal_fade_tween,
		MOTION_KIND_RITUAL
	)
	if active:
		_play_backdrop_enter(intermediate_choice_modal, MOTION_KIND_RITUAL)
		_play_sfx(&"cursor_move")
		_play_panel_enter(intermediate_choice_panel, MOTION_KIND_RITUAL)
	_emit_modal_telemetry("intermediate_choice", active)
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_push_luck_modal(active: bool) -> void:
	if active:
		show_modal(push_luck_modal)
	_push_luck_modal_fade_tween = _fade_modal(push_luck_panel, push_luck_modal, active, _push_luck_modal_fade_tween, MOTION_KIND_RITUAL)
	if active:
		_play_backdrop_enter(push_luck_modal, MOTION_KIND_RITUAL)
		_play_sfx(&"level_up")
		_play_panel_enter(push_luck_panel, MOTION_KIND_RITUAL)
	_emit_modal_telemetry("push_luck", active)
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_game_over_modal(active: bool) -> void:
	if active:
		show_modal(game_over_modal)
		_reset_final_dossier_route_interaction()
		_set_final_dossier_state(FINAL_DOSSIER_STATE_OPEN)
	_game_over_modal_fade_tween = _fade_modal(game_over_panel, game_over_modal, active, _game_over_modal_fade_tween, MOTION_KIND_ENDING)
	if active:
		_play_backdrop_enter(game_over_modal, MOTION_KIND_ENDING)
		_play_panel_enter(game_over_panel, MOTION_KIND_ENDING)
		call_deferred("_apply_final_dossier_meta_state", _final_dossier_request_sequence_id)
		enter_ending_mode()
		_emit_modal_telemetry("ending", true)
	else:
		_reset_final_dossier_route_interaction(false)
		_set_final_dossier_state(FINAL_DOSSIER_STATE_OPEN)
		exit_ending_mode()
		_emit_modal_telemetry("ending", false)
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func enter_ending_mode() -> void:
	_ending_mode_active = true
	if hud_root != null:
		hud_root.visible = false
	if scars_panel != null:
		scars_panel.visible = false
	if ending_background != null:
		ending_background.visible = true
	if torch_flicker_overlay != null:
		torch_flicker_overlay.visible = true
	if torch_flicker_player != null and torch_flicker_player.has_animation("flicker"):
		torch_flicker_player.play("flicker")
	if modal_dimmer != null:
		modal_dimmer.visible = false
		modal_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func exit_ending_mode() -> void:
	_ending_mode_active = false
	if torch_flicker_player != null:
		torch_flicker_player.stop()
	if torch_flicker_overlay != null:
		torch_flicker_overlay.visible = false
	if ending_background != null:
		ending_background.visible = false
	if hud_root != null:
		hud_root.visible = true
	if scars_panel != null:
		scars_panel.visible = true

func _reset_bet_confirmation() -> void:
	_pending_confirm_bet_id = ""
	_reset_sign_feedback()
	if bet_confirm_label != null:
		bet_confirm_label.text = tr("Selezione: -")
	if bet_confirm_row != null:
		bet_confirm_row.visible = false
	if bet_confirm_button != null:
		if _bet_confirm_default_text == "":
			_bet_confirm_default_text = bet_confirm_button.text
		bet_confirm_button.text = _bet_confirm_default_text
		bet_confirm_button.disabled = true
	for button: Button in _bet_buttons:
		button.disabled = false
	if _selected_bet_id == "":
		for bet_id_variant: Variant in _bet_select_buttons_by_id.keys():
			_selected_bet_id = str(bet_id_variant)
			break
	_refresh_bet_selection_visuals()

func _refresh_modal_dimmer() -> void:
	if modal_dimmer == null:
		return
	if _ending_mode_active:
		modal_dimmer.visible = false
		modal_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return
	var active: bool = false
	if _current_modal != null and is_instance_valid(_current_modal) and _current_modal.visible:
		active = true
	if bet_modal != null and bet_modal.visible:
		active = true
	if betting_circle != null and betting_circle.visible:
		active = true
	if pact_sealed_modal != null and pact_sealed_modal.visible:
		active = true
	if resolve_ritual_modal != null and resolve_ritual_modal.visible:
		active = true
	if intermediate_choice_modal != null and intermediate_choice_modal.visible:
		active = true
	if push_luck_modal != null and push_luck_modal.visible:
		active = true
	if game_over_modal != null and game_over_modal.visible:
		active = true
	if scars_detail_panel != null and scars_detail_panel.visible:
		active = true
	modal_dimmer.visible = active
	modal_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP if active else Control.MOUSE_FILTER_IGNORE
	if hud_top_left_stats_box != null:
		var hide_left_hud: bool = false
		if pact_sealed_modal != null and pact_sealed_modal.visible:
			hide_left_hud = true
		if resolve_ritual_modal != null and resolve_ritual_modal.visible:
			hide_left_hud = true
		if intermediate_choice_modal != null and intermediate_choice_modal.visible:
			hide_left_hud = true
		if push_luck_modal != null and push_luck_modal.visible:
			hide_left_hud = true
		if game_over_modal != null and game_over_modal.visible:
			hide_left_hud = true
		hud_top_left_stats_box.visible = not hide_left_hud

func _apply_betting_overlay_visual_suppression() -> void:
	_clear_betting_transient_overlays()
	if hud_top_left_stats_box != null:
		_betting_overlay_hud_visible_before = hud_top_left_stats_box.visible
		_betting_overlay_hud_visibility_cached = true
		hud_top_left_stats_box.visible = true
		var bet_badge_panel := hud_top_left_stats_box.get_node_or_null("BetBadge") as CanvasItem
		var glory_panel := hud_top_left_stats_box.get_node_or_null("GloryPanel") as CanvasItem
		if bet_badge_panel != null:
			_betting_overlay_bet_badge_visible_before = bet_badge_panel.visible
			bet_badge_panel.visible = false
		if glory_panel != null:
			_betting_overlay_glory_visible_before = glory_panel.visible
			glory_panel.visible = false
		if escalation_row != null:
			escalation_row.visible = true
	if scars_panel != null:
		_betting_overlay_scars_visible_before = scars_panel.visible
		_betting_overlay_scars_visibility_cached = true
		scars_panel.visible = false
	if scars_detail_panel != null:
		scars_detail_panel.visible = false
	if arena_theme_title_panel != null:
		_betting_overlay_theme_title_visible_before = arena_theme_title_panel.visible
	if arena_theme_subtitle_panel != null:
		_betting_overlay_theme_subtitle_visible_before = arena_theme_subtitle_panel.visible
	if arena_theme_title_panel != null or arena_theme_subtitle_panel != null:
		_betting_overlay_theme_visibility_cached = true
	if arena_theme_title_panel != null:
		arena_theme_title_panel.visible = false
	if arena_theme_subtitle_panel != null:
		arena_theme_subtitle_panel.visible = false

func _restore_betting_overlay_visual_suppression() -> void:
	if hud_top_left_stats_box != null and _betting_overlay_hud_visibility_cached:
		var bet_badge_panel := hud_top_left_stats_box.get_node_or_null("BetBadge") as CanvasItem
		var glory_panel := hud_top_left_stats_box.get_node_or_null("GloryPanel") as CanvasItem
		if bet_badge_panel != null:
			bet_badge_panel.visible = _betting_overlay_bet_badge_visible_before
		if glory_panel != null:
			glory_panel.visible = _betting_overlay_glory_visible_before
		hud_top_left_stats_box.visible = _betting_overlay_hud_visible_before
	_betting_overlay_hud_visibility_cached = false
	if scars_panel != null and _betting_overlay_scars_visibility_cached:
		scars_panel.visible = _betting_overlay_scars_visible_before and not _ending_mode_active
	_betting_overlay_scars_visibility_cached = false
	if _betting_overlay_theme_visibility_cached:
		if arena_theme_title_panel != null:
			arena_theme_title_panel.visible = _betting_overlay_theme_title_visible_before
		if arena_theme_subtitle_panel != null:
			arena_theme_subtitle_panel.visible = _betting_overlay_theme_subtitle_visible_before
	_betting_overlay_theme_visibility_cached = false

func _clear_betting_transient_overlays() -> void:
	_sentence_banner_sequence_id += 1
	if sentence_banner != null:
		sentence_banner.visible = false
	_clear_audience_context_overlay()
	if _register_annotation_tween != null and _register_annotation_tween.is_valid():
		_register_annotation_tween.kill()
	if register_blocker != null:
		register_blocker.visible = false
	if _quick_cut_tween != null and _quick_cut_tween.is_valid():
		_quick_cut_tween.kill()
	if quick_cut_blocker != null:
		quick_cut_blocker.visible = false
		quick_cut_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _scar_popup_tween != null and _scar_popup_tween.is_valid():
		_scar_popup_tween.kill()
	if scar_popup_panel != null:
		scar_popup_panel.visible = false

func open_bet_circle(bets: Array[Dictionary]) -> void:
	_current_bet_offer = []
	_current_bet_offer.append_array(bets)
	var circle: BettingCircleUI = betting_circle
	if circle == null:
		push_error("SANITY FAIL UI: BetCircle missing")
		return
	circle.set_offers(bets)
	show_modal(circle)
	circle.modulate.a = 1.0
	circle.process_mode = Node.PROCESS_MODE_INHERIT
	circle.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_betting_overlay_visual_suppression()
	circle.open()
	_set_bet_modal(false)
	_refresh_modal_dimmer()

func _reset_fast_countdown() -> void:
	_selected_bet_id = ""
	_fast_countdown_active = false
	_stop_fast_blink()
	if fast_countdown_label != null:
		fast_countdown_label.visible = false
		if fast_countdown_panel != null:
			fast_countdown_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _controls_first_run_active and (not _has_seen_controls) and controls_hint_panel != null and controls_hint_panel.visible:
		var should_dismiss: bool = false
		if event is InputEventKey and event.pressed and not event.echo:
			should_dismiss = true
		elif event is InputEventMouseButton and event.pressed:
			should_dismiss = true
		elif event is InputEventJoypadButton and event.pressed:
			should_dismiss = true
		if should_dismiss:
			_has_seen_controls = true
			_controls_first_run_active = false
			controls_hint_panel.visible = false
	if _handle_resolution_ritual_input(event):
		get_viewport().set_input_as_handled()

func _handle_resolution_ritual_input(event: InputEvent) -> bool:
	if resolve_ritual_modal == null or not resolve_ritual_modal.visible:
		return false
	if _resolve_ritual_strike_count >= RESOLUTION_RITUAL_STRIKES_REQUIRED:
		return false
	var should_strike: bool = false
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		should_strike = key_event.pressed and not key_event.echo and (
			key_event.keycode == KEY_SPACE or key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER
		)
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		should_strike = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventJoypadButton:
		var joy_event: InputEventJoypadButton = event as InputEventJoypadButton
		should_strike = joy_event.pressed
	if not should_strike:
		return false
	_on_resolve_ritual_strike_pressed()
	return true
func _req(path: String) -> Node:
	var n: Node = get_node_or_null(path)
	if n == null:
		push_error("UI missing node at path: %s" % path)
	return n

func _get_arena() -> Node:
	if _arena != null and is_instance_valid(_arena):
		return _arena
	_refresh_runtime_group_cache(false)
	if _arena != null and is_instance_valid(_arena):
		return _arena
	return null

func _get_arena_index() -> int:
	if _run_manager_port != null:
		return _run_manager_port.get_arena_index()
	return 0


























































