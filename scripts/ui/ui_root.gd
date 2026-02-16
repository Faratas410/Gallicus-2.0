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

signal arena_message_queue_completed

const FAST_SELECTION_SECONDS: int = 12
const MIN_MODAL_READ_TIME_SEC: float = 1.25
const POST_BET_MESSAGE_TIME_SEC: float = 3.5
const SENTENCE_BANNER_SECONDS: float = 1.2
const REGISTER_ANNOTATION_FALLBACK_SECONDS: float = 1.2
const FADE_IN_SEC: float = 0.25
const FADE_OUT_SEC: float = 0.25
const BETTING_CIRCLE_SCENE_PATH: String = "res://scenes/ui/BettingCircle.tscn"
const BUTTON_STYLE_PRIMARY_NORMAL_PATH: String = "res://ui/official/styleboxes/sb_button_primary_normal.tres"
const BUTTON_STYLE_PRIMARY_HOVER_PATH: String = "res://ui/official/styleboxes/sb_button_primary_hover.tres"
const BUTTON_STYLE_PRIMARY_PRESSED_PATH: String = "res://ui/official/styleboxes/sb_button_primary_pressed.tres"
const BUTTON_STYLE_PRIMARY_DISABLED_PATH: String = "res://ui/official/styleboxes/sb_button_primary_disabled.tres"
const CondannaDataScript = preload("res://data/condanne.gd")
const VerdictLinesScript = preload("res://data/verdict_lines.gd")
const RunUiPayloadScript = preload("res://scripts/ui/run_ui_payload.gd")
const CondannaData = preload("res://data/condanne.gd")
const RunUiPayload = preload("res://scripts/ui/run_ui_payload.gd")
const BettingCircleUI = preload("res://scripts/ui/betting_circle_ui.gd")
const SCARS_PANEL_BASE_HEIGHT: float = 140.0
const SCARS_PANEL_ROW_HEIGHT: float = 28.0
const SCARS_PANEL_MIN_HEIGHT: float = 180.0
const SCARS_PANEL_MAX_HEIGHT: float = 360.0
const RUN_PHASE_MAIN_MENU: int = 10
const RUN_PHASE_RUN_INIT: int = 11
const RUN_PHASE_BET_PRESENT: int = 12
const RUN_PHASE_BET_COMMITTED: int = 13
const RUN_PHASE_FIRST_REACTION: int = 14
const RUN_PHASE_MID_CHOICE: int = 15
const RUN_PHASE_PUSH_YOUR_LUCK: int = 16
const RUN_PHASE_NEXT_BET: int = 17
const RUN_PHASE_RESOLUTION: int = 18
const RUN_PHASE_END_RUN: int = 2
const POST_BET_TEXTS: Dictionary = {
	"CASH_OUT": [
		"Hai incassato. La folla mormora.",
		"Te ne vai con il bottino. Sguardi bassi.",
		"Meglio vivi che leggendari.",
	],
	"FLAWLESS_BLOOD": [
		"Sangue integro. Nessuno osa fiatare.",
		"Hai promesso pulizia. La folla osserva.",
		"Un passo pulito. Il silenzio si stringe.",
	],
	"DOUBLE_OR_DIE": [
		"Hai rilanciato. La folla trattiene il fiato.",
		"Nessun ritorno. I volti restano fermi.",
		"Hai scelto il sangue invece dell'oro.",
	],
}

@onready var coins_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/CoinsRow/CoinsContent/CoinsLabel") as Label
@onready var bet_badge_value_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeValuePanel/BetBadgeValue") as Label
@onready var glory_value_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/GloryPanel/GloryMargin/GloryContent/GloryValuePanel/GloryValueLabel") as Label
@onready var escalation_bar: ProgressBar = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/EscalationRow/EscalationBar") as ProgressBar
@onready var hud_root: Control = get_node_or_null("HUD") as Control
@onready var bet_modal: Control = _req("UI_RunRoot/Phase_INTRO") as Control
@onready var betting_circle: BettingCircleUI = get_node_or_null("UI_RunRoot/BettingCircle") as BettingCircleUI
@onready var modals_root: Control = get_node_or_null("UI_RunRoot") as Control
@onready var pact_sealed_modal: Control = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION") as Control
@onready var pact_sealed_panel: Panel = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION") as Panel
@onready var pact_sealed_title: Label = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_TITLEPanel/Lbl_FIRST_REACTION_TITLE") as Label
@onready var pact_sealed_subtitle: Label = get_node_or_null("UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_BODYPanel/Lbl_FIRST_REACTION_BODY") as Label
@onready var resolve_ritual_modal: Control = get_node_or_null("UI_RunRoot/Phase_RESOLUTION") as Control
@onready var resolve_ritual_panel: Panel = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION") as Panel
@onready var resolve_ritual_title: Label = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_TITLEPanel/Lbl_RESOLUTION_TITLE") as Label
@onready var resolve_ritual_subtitle: Label = get_node_or_null("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_BODYPanel/Lbl_RESOLUTION_BODY") as Label
@onready var intermediate_choice_modal: Control = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE") as Control
@onready var intermediate_choice_panel: Panel = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE") as Panel
@onready var intermediate_choice_label: Label = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Lbl_MID_CHOICE_TITLEPanel/Lbl_MID_CHOICE_TITLE") as Label
@onready var intermediate_choice_placa_button: Button = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0") as Button
@onready var intermediate_choice_provoca_button: Button = get_node_or_null("UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_1") as Button
@onready var bet_panel: Panel = _req("UI_RunRoot/Phase_INTRO/Panel_INTRO") as Panel
@onready var modal_dimmer: ColorRect = get_node_or_null("UI_RunRoot/ModalDimmer") as ColorRect
@onready var stake_row: Control = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/StakeRow") as Control
@onready var stake_input: SpinBox = _req("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/StakeRow/StakeInput") as SpinBox
@onready var bet_buttons_container: VBoxContainer = _req("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons") as VBoxContainer
@onready var special_arena_label: Label = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_SUBTITLEPanel/Lbl_INTRO_SUBTITLE") as Label
@onready var condanna_focus_label: Label = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_HINTPanel/Lbl_INTRO_HINT") as Label
@onready var bet_confirm_row: Control = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow") as Control
@onready var bet_confirm_label: Label = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Lbl_INTRO_FOOTERPanel/Lbl_INTRO_FOOTER") as Label
@onready var bet_confirm_button: Button = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Btn_INTRO_CONFIRM") as Button
@onready var intro_select_win_button: Button = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons/Btn_INTRO_SELECT_WIN") as Button
@onready var intro_select_no_hit_button: Button = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons/Btn_INTRO_SELECT_NO_HIT") as Button
@onready var intro_select_fast_button: Button = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons/Btn_INTRO_SELECT_FAST") as Button
@onready var seed_input: LineEdit = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/SeedRow/SeedInput") as LineEdit
@onready var seed_apply_button: Button = get_node_or_null("UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/SeedRow/Btn_INTRO_APPLY_SEED") as Button
@onready var _debug_overlay: Control = %DebugOverlay
@onready var _debug_label: RichTextLabel = %Lbl_DebugOverlay
@onready var debug_tools_panel: Panel = get_node_or_null("HUD/DebugTools") as Panel
@onready var debug_seed_input: LineEdit = get_node_or_null("HUD/DebugTools/DebugToolsVBox/SeedRow/SeedInput") as LineEdit
@onready var debug_seed_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/SeedRow/SeedButton") as Button
@onready var debug_restart_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/DebugButtons/RestartRunButton") as Button
@onready var debug_skip_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/DebugButtons/SkipArenaButton") as Button
@onready var debug_copy_log_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/CopyLogButton") as Button
@onready var scar_popup_panel: PanelContainer = get_node_or_null("HUD/ScarPopupPanel") as PanelContainer
@onready var scar_popup: RichTextLabel = get_node_or_null("HUD/ScarPopupPanel/ScarPopupMargin/ScarPopupTextPanel/ScarPopup") as RichTextLabel
@onready var arena_resolution_panel: PanelContainer = get_node_or_null("HUD/ArenaResolutionOverlayPanel") as PanelContainer
@onready var arena_resolution_label: Label = get_node_or_null("HUD/ArenaResolutionOverlayPanel/ArenaResolutionOverlay") as Label
@onready var audience_context_panel: PanelContainer = get_node_or_null("HUD/AudienceContextLabelPanel") as PanelContainer
@onready var audience_context_label: Label = get_node_or_null("HUD/AudienceContextLabelPanel/AudienceContextLabel") as Label
@onready var register_blocker: Control = get_node_or_null("HUD/RegisterAnnotationBlocker") as Control
@onready var register_annotation_label: Label = get_node_or_null("HUD/RegisterAnnotationBlocker/RegisterAnnotationLabelPanel/RegisterAnnotationLabel") as Label
@onready var arena_theme_title_panel: PanelContainer = get_node_or_null("HUD/ArenaThemeTitleLabelPanel") as PanelContainer
@onready var arena_theme_title_label: Label = get_node_or_null("HUD/ArenaThemeTitleLabelPanel/ArenaThemeTitleLabel") as Label
@onready var arena_theme_subtitle_panel: PanelContainer = get_node_or_null("HUD/ArenaThemeSubtitleLabelPanel") as PanelContainer
@onready var arena_theme_subtitle_label: Label = get_node_or_null("HUD/ArenaThemeSubtitleLabelPanel/ArenaThemeSubtitleLabel") as Label
@onready var sentence_banner: Control = get_node_or_null("HUD/SentenceBanner") as Control
@onready var sentence_title_label: Label = get_node_or_null("HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceTitlePanel/SentenceTitle") as Label
@onready var sentence_rule_label: Label = get_node_or_null("HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceRulePanel/SentenceRule") as Label
@onready var sentence_doom_label: Label = get_node_or_null("HUD/SentenceBanner/SentencePanel/SentenceMargin/SentenceVBox/SentenceDoomPanel/SentenceDoom") as Label
@onready var game_over_modal: Control = get_node_or_null("UI_RunRoot/Phase_END_RUN") as Control
@onready var game_over_panel: TextureRect = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN") as TextureRect
@onready var ending_background: TextureRect = get_node_or_null("UI_RunRoot/EndingBackground") as TextureRect
@onready var torch_flicker_overlay: TextureRect = get_node_or_null("UI_RunRoot/TorchFlickerOverlay") as TextureRect
@onready var torch_flicker_player: AnimationPlayer = get_node_or_null("UI_RunRoot/TorchFlickerPlayer") as AnimationPlayer
@onready var push_luck_modal: Control = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK") as Control
@onready var push_luck_panel: Panel = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK") as Panel
@onready var push_luck_title: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_TITLEPanel/Lbl_PUSH_YOUR_LUCK_TITLE") as Label
@onready var push_luck_info: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_BODYPanel/Lbl_PUSH_YOUR_LUCK_BODY") as Label
@onready var push_luck_audience_label: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_SUBTITLEPanel/Lbl_PUSH_YOUR_LUCK_SUBTITLE") as Label
@onready var push_luck_audience_reason: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_HINTPanel/Lbl_PUSH_YOUR_LUCK_HINT") as Label
@onready var push_luck_details: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_FOOTERPanel/Lbl_PUSH_YOUR_LUCK_FOOTER") as Label
@onready var push_luck_cashout_button: Button = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Btn_PUSH_YOUR_LUCK_CASHOUT") as Button
@onready var push_luck_cashout_note: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Lbl_PUSH_YOUR_LUCK_CHOICE_0Panel/Lbl_PUSH_YOUR_LUCK_CHOICE_0") as Label
@onready var push_luck_condanna_button: Button = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Btn_PUSH_YOUR_LUCK_CONDANNA") as Button
@onready var push_luck_condanna_note: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Lbl_PUSH_YOUR_LUCK_CHOICE_1Panel/Lbl_PUSH_YOUR_LUCK_CHOICE_1") as Label
@onready var push_luck_double_button: Button = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Btn_PUSH_YOUR_LUCK_DOUBLE") as Button
@onready var push_luck_double_note: Label = get_node_or_null("UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICEPanel/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICE") as Label
@onready var verdict_header: Label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_TITLEPanel/Lbl_END_RUN_TITLE") as Label
@onready var verdict_outcome: Label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_SUBTITLEPanel/Lbl_END_RUN_SUBTITLE") as Label
@onready var verdict_sentence_label: Label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_BODYPanel/Lbl_END_RUN_BODY") as Label
@onready var verdict_charge_label: Label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_HINTPanel/Lbl_END_RUN_HINT") as Label
@onready var verdict_sections: VBoxContainer = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS") as VBoxContainer
@onready var verdict_pacts_text: RichTextLabel = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_PACTS_BODYPanel/Lbl_END_RUN_PACTS_BODY") as RichTextLabel
@onready var verdict_condanne_text: RichTextLabel = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_CONDANNE_BODYPanel/Lbl_END_RUN_CONDANNE_BODY") as RichTextLabel
@onready var verdict_crowd_section: VBoxContainer = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD") as VBoxContainer
@onready var verdict_crowd_text: Label = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_BODYPanel/Lbl_END_RUN_CROWD_BODY") as Label
@onready var game_over_scroll: ScrollContainer = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL") as ScrollContainer
@onready var ending_text: RichTextLabel = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL/Box_END_RUN_MARGIN/Lbl_END_RUN_FOOTERPanel/Lbl_END_RUN_FOOTER") as RichTextLabel
@onready var restart_button: Button = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Btn_END_RUN_RESTART") as Button
@onready var next_bet_button: Button = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Btn_END_RUN_NEXT_BET") as Button
@onready var quit_button: Button = get_node_or_null("UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Btn_END_RUN_QUIT") as Button
@onready var controls_hint_panel: Panel = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ControlsHintPanel") as Panel
@onready var scars_panel: Panel = get_node_or_null("HUD/ScarsPanel") as Panel
@onready var scars_label: Label = get_node_or_null("HUD/ScarsPanel/ScarsVBox/ScarsScroll/ScarsEntries/ScarsLabelPanel/ScarsLabel") as Label
@onready var countdown_panel: PanelContainer = get_node_or_null("UI_RunRoot/CountdownLabelPanel") as PanelContainer
@onready var countdown_label: Label = get_node_or_null("UI_RunRoot/CountdownLabelPanel/CountdownLabel") as Label
@onready var fast_countdown_panel: PanelContainer = get_node_or_null("UI_RunRoot/FastCountdownLabelPanel") as PanelContainer
@onready var fast_countdown_label: Label = get_node_or_null("UI_RunRoot/FastCountdownLabelPanel/FastCountdownLabel") as Label
@onready var fast_blink_timer: Timer = get_node_or_null("UI_RunRoot/FastBlinkTimer") as Timer
@onready var scars_detail_panel: Panel = get_node_or_null("UI_RunRoot/ScarsDetailPanel") as Panel
@onready var scars_detail_text: Label = get_node_or_null("UI_RunRoot/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailTextPanel/ScarsDetailText") as Label
@onready var scars_detail_close: Button = get_node_or_null("UI_RunRoot/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailClose") as Button


var _bets_by_id: Dictionary = {}
var _run_manager: Node
var _arena: Node
var _player: Node = null
var _has_seen_controls: bool = false
var _fast_countdown_active: bool = false
var _controls_first_run_active: bool = true
var _selected_bet_id: String = ""
var _pending_confirm_bet_id: String = ""
var _pending_bets: Array = []
var _current_bet_offer: Array[Dictionary] = []
var _bet_buttons: Array[Button] = []
var _coins: int = 0
var _glory: int = 0
var _escalation_level: int = 0
var _escalation_max: int = 0
var _scar_popup_tween: Tween = null
var _arena_resolution_tween: Tween = null
var _register_annotation_tween: Tween = null
var _bet_modal_fade_tween: Tween = null
var _pact_sealed_modal_fade_tween: Tween = null
var _resolve_ritual_modal_fade_tween: Tween = null
var _intermediate_choice_modal_fade_tween: Tween = null
var _push_luck_modal_fade_tween: Tween = null
var _game_over_modal_fade_tween: Tween = null
var _current_modal: Control = null
var _last_finale_title: String = "RUN FAILED"
var _last_finale_text: String = ""
var _last_finale_scars: Array = []
var _last_finale_ending_id: String = ""
var _last_finale_seed: int = 0
var _last_finale_stats: Dictionary = {}
var _last_finale_hint: String = ""
var _last_verdict_pacts: Array[String] = []
var _last_verdict_condanne: Array[String] = []
var _last_verdict_crowd_line: String = ""
var _last_verdict_outcome: StringName = &"LOSS"
var _last_verdict_sentence: String = ""
var _last_verdict_charge: String = ""
var _special_arena_payload: Dictionary = {}
var _arena_theme_payload: Dictionary = {}
var _require_bet_confirm: bool = false
var _scars_detail_text: String = ""
var _debug_run_log: String = ""
var _debug_seed: int = 0
var _debug_arena_index: int = 0
var _debug_escalation: int = 0
var _debug_active_bet: String = ""
var _debug_enemy_profile: String = ""
var _debug_scars: Array[String] = []
var _debug_special_arena: String = ""
var _ending_mode_active: bool = false
var _post_bet_text_last_index: Dictionary = {}
var _post_bet_queue: Array[Dictionary] = []
var _post_bet_running: bool = false
var _post_bet_log_index: int = 0
var _sentence_banner_sequence_id: int = 0
var _is_signing: bool = false
var _bet_confirm_default_text: String = ""
var _phase_node_map: Dictionary = {}
var _button_style_primary_normal: StyleBox = null
var _button_style_primary_hover: StyleBox = null
var _button_style_primary_pressed: StyleBox = null
var _button_style_primary_disabled: StyleBox = null
const _PHASE_CONTAINER_PATHS: Array[String] = [
	"UI_RunRoot/Phase_INTRO",
	"UI_RunRoot/Phase_FIRST_REACTION",
	"UI_RunRoot/Phase_MID_CHOICE",
	"UI_RunRoot/Phase_PUSH_YOUR_LUCK",
	"UI_RunRoot/Phase_RESOLUTION",
	"UI_RunRoot/Phase_END_RUN",
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _validate_ui_boot():
		_disable_ui_interactions()
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
	var coins_changed_callable: Callable = Callable(self, "_on_coins_changed")
	if not GameEvents.coins_changed.is_connected(coins_changed_callable):
		GameEvents.coins_changed.connect(coins_changed_callable)
	var bet_placed_callable: Callable = Callable(self, "_on_bet_placed")
	if not GameEvents.bet_placed.is_connected(bet_placed_callable):
		GameEvents.bet_placed.connect(bet_placed_callable)
	var run_started_callable: Callable = Callable(self, "_on_run_started")
	if not GameEvents.run_started.is_connected(run_started_callable):
		GameEvents.run_started.connect(run_started_callable)
	var run_started_ui_callable: Callable = Callable(self, "_on_run_started_ui")
	if not GameEvents.run_started.is_connected(run_started_ui_callable):
		GameEvents.run_started.connect(run_started_ui_callable)
	var run_failed_callable: Callable = Callable(self, "_on_run_failed")
	if not GameEvents.run_failed.is_connected(run_failed_callable):
		GameEvents.run_failed.connect(run_failed_callable)
	var run_ended_callable: Callable = Callable(self, "_on_run_ended")
	if GameEvents.has_signal("run_ended") and not GameEvents.run_ended.is_connected(run_ended_callable):
		GameEvents.run_ended.connect(run_ended_callable)
	var run_finale_callable: Callable = Callable(self, "_on_run_finale_selected")
	if GameEvents.has_signal("run_finale_selected") and not GameEvents.run_finale_selected.is_connected(run_finale_callable):
		GameEvents.run_finale_selected.connect(run_finale_callable)
	var run_debug_callable: Callable = Callable(self, "_on_run_debug_state_updated")
	if GameEvents.has_signal("run_debug_state_updated") and not GameEvents.run_debug_state_updated.is_connected(run_debug_callable):
		GameEvents.run_debug_state_updated.connect(run_debug_callable)
	var sentence_banner_callable: Callable = Callable(self, "_on_sentence_banner_requested")
	if GameEvents.has_signal("sentence_banner_requested") and not GameEvents.sentence_banner_requested.is_connected(sentence_banner_callable):
		GameEvents.sentence_banner_requested.connect(sentence_banner_callable)
	var audience_context_callable: Callable = Callable(self, "_on_audience_context_line_emitted")
	if GameEvents.has_signal("audience_context_line_emitted") and not GameEvents.audience_context_line_emitted.is_connected(audience_context_callable):
		GameEvents.audience_context_line_emitted.connect(audience_context_callable)
	var register_annotation_callable: Callable = Callable(self, "_on_register_annotation")
	if GameEvents.has_signal("register_annotation") and not GameEvents.register_annotation.is_connected(register_annotation_callable):
		GameEvents.register_annotation.connect(register_annotation_callable)
	var escalation_changed_callable: Callable = Callable(self, "_on_escalation_changed")
	if GameEvents.has_signal("escalation_changed") and not GameEvents.escalation_changed.is_connected(escalation_changed_callable):
		GameEvents.escalation_changed.connect(escalation_changed_callable)
	var run_log_callable: Callable = Callable(self, "_on_run_log_ready")
	if GameEvents.has_signal("run_log_ready") and not GameEvents.run_log_ready.is_connected(run_log_callable):
		GameEvents.run_log_ready.connect(run_log_callable)
	var special_arena_callable: Callable = Callable(self, "_on_special_arena_started")
	if GameEvents.has_signal("special_arena_started") and not GameEvents.special_arena_started.is_connected(special_arena_callable):
		GameEvents.special_arena_started.connect(special_arena_callable)
	var arena_theme_callable: Callable = Callable(self, "_on_arena_theme_changed")
	if GameEvents.has_signal("arena_theme_changed") and not GameEvents.arena_theme_changed.is_connected(arena_theme_callable):
		GameEvents.arena_theme_changed.connect(arena_theme_callable)
	var bet_failed_callable: Callable = Callable(self, "_on_bet_failed")
	if not GameEvents.bet_failed.is_connected(bet_failed_callable):
		GameEvents.bet_failed.connect(bet_failed_callable)
	var run_started_controls_callable: Callable = Callable(self, "_on_run_started_controls")
	if not GameEvents.run_started.is_connected(run_started_controls_callable):
		GameEvents.run_started.connect(run_started_controls_callable)
	var run_failed_controls_callable: Callable = Callable(self, "_on_run_failed_controls")
	if not GameEvents.run_failed.is_connected(run_failed_controls_callable):
		GameEvents.run_failed.connect(run_failed_controls_callable)
	var bet_ui_opened_callable: Callable = Callable(self, "_on_bet_ui_opened")
	if not GameEvents.bet_ui_opened.is_connected(bet_ui_opened_callable):
		GameEvents.bet_ui_opened.connect(bet_ui_opened_callable)
	var bet_selected_callable: Callable = Callable(self, "_on_bet_selected")
	if GameEvents.has_signal("bet_selected") and not GameEvents.bet_selected.is_connected(bet_selected_callable):
		GameEvents.bet_selected.connect(bet_selected_callable)
	var bet_ui_closed_callable: Callable = Callable(self, "_on_bet_ui_closed")
	if not GameEvents.bet_ui_closed.is_connected(bet_ui_closed_callable):
		GameEvents.bet_ui_closed.connect(bet_ui_closed_callable)
	var pact_sealed_opened_callable: Callable = Callable(self, "_on_pact_sealed_opened")
	if GameEvents.has_signal("pact_sealed_opened") and not GameEvents.pact_sealed_opened.is_connected(pact_sealed_opened_callable):
		GameEvents.pact_sealed_opened.connect(pact_sealed_opened_callable)
	var pact_sealed_closed_callable: Callable = Callable(self, "_on_pact_sealed_closed")
	if GameEvents.has_signal("pact_sealed_closed") and not GameEvents.pact_sealed_closed.is_connected(pact_sealed_closed_callable):
		GameEvents.pact_sealed_closed.connect(pact_sealed_closed_callable)
	var resolve_ritual_opened_callable: Callable = Callable(self, "_on_resolve_ritual_opened")
	if GameEvents.has_signal("resolve_ritual_opened") and not GameEvents.resolve_ritual_opened.is_connected(resolve_ritual_opened_callable):
		GameEvents.resolve_ritual_opened.connect(resolve_ritual_opened_callable)
	var resolve_ritual_closed_callable: Callable = Callable(self, "_on_resolve_ritual_closed")
	if GameEvents.has_signal("resolve_ritual_closed") and not GameEvents.resolve_ritual_closed.is_connected(resolve_ritual_closed_callable):
		GameEvents.resolve_ritual_closed.connect(resolve_ritual_closed_callable)
	var intermediate_choice_opened_callable: Callable = Callable(self, "_on_intermediate_choice_opened")
	if GameEvents.has_signal("intermediate_choice_opened") and not GameEvents.intermediate_choice_opened.is_connected(intermediate_choice_opened_callable):
		GameEvents.intermediate_choice_opened.connect(intermediate_choice_opened_callable)
	var arena_started_callable: Callable = Callable(self, "_on_arena_started")
	if not GameEvents.arena_started.is_connected(arena_started_callable):
		GameEvents.arena_started.connect(arena_started_callable)
	var betting_opened_callable: Callable = Callable(self, "_on_betting_opened")
	if not GameEvents.betting_opened.is_connected(betting_opened_callable):
		GameEvents.betting_opened.connect(betting_opened_callable)
	var push_luck_opened_callable: Callable = Callable(self, "_on_push_luck_opened")
	if GameEvents.has_signal("push_luck_opened") and not GameEvents.push_luck_opened.is_connected(push_luck_opened_callable):
		GameEvents.push_luck_opened.connect(push_luck_opened_callable)
	var push_luck_closed_callable: Callable = Callable(self, "_on_push_luck_closed")
	if GameEvents.has_signal("push_luck_closed") and not GameEvents.push_luck_closed.is_connected(push_luck_closed_callable):
		GameEvents.push_luck_closed.connect(push_luck_closed_callable)
	var countdown_callable: Callable = Callable(self, "_on_countdown_requested")
	if not GameEvents.countdown_requested.is_connected(countdown_callable):
		GameEvents.countdown_requested.connect(countdown_callable)
	var scars_updated_callable: Callable = Callable(self, "_on_scars_updated")
	if GameEvents.has_signal("scars_updated") and not GameEvents.scars_updated.is_connected(scars_updated_callable):
		GameEvents.scars_updated.connect(scars_updated_callable)
	var scar_applied_callable: Callable = Callable(self, "_on_scar_applied")
	if GameEvents.has_signal("scar_applied") and not GameEvents.scar_applied.is_connected(scar_applied_callable):
		GameEvents.scar_applied.connect(scar_applied_callable)
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
			_wire_seed_input()

	if _debug_overlay != null:
		_debug_overlay.visible = false
	if debug_tools_panel != null:
		debug_tools_panel.visible = OS.is_debug_build()
		_wire_debug_tools()
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
	if next_bet_button != null:
		if not next_bet_button.pressed.is_connected(Callable(self, "_on_retry_pressed")):
			next_bet_button.pressed.connect(Callable(self, "_on_retry_pressed"))
	if quit_button != null:
		if not quit_button.pressed.is_connected(Callable(self, "_on_quit_pressed")):
			quit_button.pressed.connect(Callable(self, "_on_quit_pressed"))
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
	_wire_intermediate_choice_buttons()
	_wire_push_luck_buttons()
	_wire_intro_phase_buttons()

	var arena: Node = get_tree().get_first_node_in_group("arena")
	if arena != null and arena.has_signal("player_spawned"):
		var arena_player_callable: Callable = Callable(self, "_on_player_spawned")
		if not arena.player_spawned.is_connected(arena_player_callable):
			arena.player_spawned.connect(arena_player_callable)

	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null:
		_bind_player(p)

	print("UI ready: coins=%s bet_panel=%s debug=%s" % [coins_label != null, bet_panel != null, _debug_overlay != null])

func _init_phase_node_map() -> void:
	_phase_node_map = {
		RUN_PHASE_MAIN_MENU: bet_modal,
		RUN_PHASE_RUN_INIT: bet_modal,
		RUN_PHASE_BET_PRESENT: bet_modal,
		RUN_PHASE_BET_COMMITTED: pact_sealed_modal,
		RUN_PHASE_FIRST_REACTION: pact_sealed_modal,
		RUN_PHASE_MID_CHOICE: intermediate_choice_modal,
		RUN_PHASE_PUSH_YOUR_LUCK: push_luck_modal,
		RUN_PHASE_NEXT_BET: bet_modal,
		RUN_PHASE_RESOLUTION: resolve_ritual_modal,
		RUN_PHASE_END_RUN: game_over_modal,
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
			push_error("UI: missing phase mapping target for %s" % str(mapped_phase))

func show_phase(phase: int) -> void:
	if _phase_node_map.is_empty():
		push_error("UI: missing phase mapping for %s" % str(phase))
		return
	for mapped_phase_key: Variant in _phase_node_map.keys():
		var mapped_phase: int = int(mapped_phase_key)
		var phase_node: Control = _phase_node_map.get(mapped_phase, null) as Control
		if phase_node != null:
			phase_node.visible = false
	var target: Control = _phase_node_map.get(phase, null) as Control
	if target == null:
		push_error("UI: unmapped phase %s" % str(phase))
		_refresh_modal_dimmer()
		return
	target.visible = true
	_current_modal = target
	print_debug("[FLOW][UI] show_phase=%d node=%s" % [phase, String(target.name)])
	_refresh_modal_dimmer()

func _validate_ui_boot() -> bool:
	var errors: Array[String] = []
	if get_node_or_null("UI_RunRoot/BettingCircle") == null and not ResourceLoader.exists(BETTING_CIRCLE_SCENE_PATH):
		push_error("SANITY FAIL UI: BetCircle missing")
		return false
	var ending_text_path: String = "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL/Box_END_RUN_MARGIN/Lbl_END_RUN_FOOTERPanel/Lbl_END_RUN_FOOTER"
	if get_node_or_null(ending_text_path) == null:
		push_error("SANITY FAIL UI: Ending nodes missing %s" % ending_text_path)
		return false
	var required_nodes: Array[String] = [
		"UI_RunRoot/Phase_INTRO",
		"UI_RunRoot/Phase_RESOLUTION",
		"UI_RunRoot/Phase_MID_CHOICE",
		"UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE",
		"UI_RunRoot/Phase_PUSH_YOUR_LUCK",
		"UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK",
		"UI_RunRoot/Phase_END_RUN",
		"UI_RunRoot/Phase_END_RUN/Panel_END_RUN",
		"UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons",
	]
	for node_path: String in required_nodes:
		if get_node_or_null(node_path) == null:
			errors.append("missing node path %s" % node_path)
	if errors.size() > 0:
		push_error("SANITY FAIL UI: %s" % "; ".join(errors))
		return false
	return true

func _disable_ui_interactions() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	set_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)

func _wire_seed_input() -> void:
	if seed_apply_button == null:
		return
	var seed_callable: Callable = Callable(self, "_on_seed_apply_pressed")
	if not seed_apply_button.pressed.is_connected(seed_callable):
		seed_apply_button.pressed.connect(seed_callable)

func _wire_intro_phase_buttons() -> void:
	if intro_select_win_button != null:
		var win_callable: Callable = Callable(self, "_on_bet_win_pressed")
		if not intro_select_win_button.pressed.is_connected(win_callable):
			intro_select_win_button.pressed.connect(win_callable)
	if intro_select_no_hit_button != null:
		var no_hit_callable: Callable = Callable(self, "_on_bet_no_hit_pressed")
		if not intro_select_no_hit_button.pressed.is_connected(no_hit_callable):
			intro_select_no_hit_button.pressed.connect(no_hit_callable)
	if intro_select_fast_button != null:
		var fast_callable: Callable = Callable(self, "_on_bet_fast_pressed")
		if not intro_select_fast_button.pressed.is_connected(fast_callable):
			intro_select_fast_button.pressed.connect(fast_callable)

func _show_scar_popup(scar: Dictionary) -> void:
	if scar_popup == null:
		return
	var scar_name: String = str(scar.get("name", "Cicatrice"))
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
		text_lines.append("[b]Effetto:[/b] %s" % effect_text)
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
	var manager: Node = get_tree().get_first_node_in_group("run_manager")
	if manager != null and manager.has_method("is_visual_only"):
		return bool(manager.call("is_visual_only"))
	return false

func _show_arena_resolution_overlay() -> void:
	if arena_resolution_label == null:
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

func _on_seed_apply_pressed() -> void:
	if seed_input == null:
		return
	var text_value: String = seed_input.text.strip_edges()
	if GameEvents.has_signal("request_intro_apply_seed"):
		GameEvents.request_intro_apply_seed.emit(text_value)

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
	if coins_label != null:
		coins_label.text = "Coins: 0"
	if escalation_bar != null:
		escalation_bar.visible = true
	_escalation_level = 0
	_update_escalation_bar()
	set_active_bet_text("—")
	_set_bet_modal(false)
	_reset_bet_confirmation()
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
	_set_game_over_modal(false)
	if next_bet_button != null:
		next_bet_button.visible = false
	_last_finale_title = "RUN FAILED"
	_last_finale_text = ""
	_last_finale_scars = []
	_last_finale_ending_id = ""
	_last_finale_seed = 0
	_last_finale_stats = {}
	_last_finale_hint = ""
	_last_verdict_pacts = []
	_last_verdict_condanne = []
	_last_verdict_crowd_line = ""
	_last_verdict_outcome = &"LOSS"
	_special_arena_payload = {}
	_debug_run_log = ""
	_debug_special_arena = ""
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

func _on_run_started_ui() -> void:
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node != null:
		_bind_player(player_node)

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
	audience_context_label.text = text
	audience_context_label.visible = text != ""
	if audience_context_panel != null:
		audience_context_panel.visible = text != ""



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

func _on_run_finale_selected(payload: Dictionary) -> void:
	if payload.has("title"):
		_last_finale_title = str(payload["title"])
	else:
		_last_finale_title = "RUN FAILED"
	if payload.has("text"):
		_last_finale_text = str(payload["text"])
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
	var pacts_payload: Array = []
	if payload.has("pacts_signed"):
		pacts_payload = payload.get("pacts_signed", []) as Array
	elif payload.has("pacts"):
		pacts_payload = payload.get("pacts", []) as Array
	_last_verdict_pacts = _coerce_string_list(pacts_payload)
	var condanne_payload: Array = payload.get("condanne_this_run", []) as Array
	_last_verdict_condanne = _coerce_string_list(condanne_payload)
	_last_verdict_crowd_line = str(payload.get("last_crowd_line", ""))
	var outcome_value: Variant = payload.get("outcome", &"LOSS")
	_last_verdict_outcome = StringName(str(outcome_value))
	var summary: Dictionary = _build_verdict_summary(payload, pacts_payload, condanne_payload)
	_last_verdict_sentence = VerdictLinesScript.pick_sentence(summary)
	_last_verdict_charge = VerdictLinesScript.pick_charge(summary)
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	_refresh_verdict_panel()

func _on_run_failed() -> void:
	_set_bet_modal(false)
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
		next_bet_button.visible = false
	if restart_button != null:
		restart_button.text = "NUOVA RUN"
	if quit_button != null:
		quit_button.text = "MENU"
	_last_finale_hint = ""
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	_refresh_verdict_panel()
	_reset_fast_countdown()
	var ending_read_buttons: Array[Button] = []
	if restart_button != null:
		ending_read_buttons.append(restart_button)
	if next_bet_button != null and next_bet_button.visible:
		ending_read_buttons.append(next_bet_button)
	if quit_button != null:
		ending_read_buttons.append(quit_button)
	_apply_modal_read_delay(ending_read_buttons)
	_refresh_modal_dimmer()
	_hide_scars_detail()

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

func _format_verdict_list(values: Array[String]) -> String:
	if values.is_empty():
		return "—"
	var lines: PackedStringArray = []
	for value in values:
		lines.append("• %s" % value)
	return "\n".join(lines)

func _format_verdict_pacts_list(values: Array[String]) -> String:
	if values.is_empty():
		return "Pattern registrato: nessuna firma persistente."
	return "Pattern registrato: %d condizioni accettate." % values.size()

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
		result.append(title)
	return result

func _refresh_verdict_panel() -> void:
	if verdict_header != null:
		verdict_header.text = "VERDETTO"
	if verdict_outcome != null:
		verdict_outcome.text = _get_verdict_outcome_text(_last_verdict_outcome)
	if verdict_sentence_label != null:
		var sentence_text: String = _last_verdict_sentence
		if sentence_text == "":
			sentence_text = "SENTENZA NON REGISTRATA."
		verdict_sentence_label.text = "SENTENZA: %s" % sentence_text
	if verdict_charge_label != null:
		var charge_text: String = _last_verdict_charge
		if charge_text == "":
			charge_text = "CAPO D'ACCUSA NON REGISTRATO."
		verdict_charge_label.text = "CAPO D’ACCUSA: %s" % charge_text
	if verdict_pacts_text != null:
		verdict_pacts_text.text = _format_verdict_pacts_list(_last_verdict_pacts)
	if verdict_condanne_text != null:
		var condanne_titles: Array[String] = _resolve_condanna_titles(_last_verdict_condanne)
		verdict_condanne_text.text = _format_verdict_list(condanne_titles)
	var crowd_line: String = _last_verdict_crowd_line.strip_edges()
	if verdict_crowd_section != null:
		verdict_crowd_section.visible = crowd_line != ""
	if verdict_crowd_text != null:
		verdict_crowd_text.text = crowd_line

func _set_verdict_mode(active: bool) -> void:
	if verdict_header != null:
		verdict_header.visible = active
	if verdict_outcome != null:
		verdict_outcome.visible = active
	if verdict_sentence_label != null:
		verdict_sentence_label.visible = active
	if verdict_charge_label != null:
		verdict_charge_label.visible = active
	if verdict_sections != null:
		verdict_sections.visible = active
	if verdict_crowd_section != null and active:
		verdict_crowd_section.visible = _last_verdict_crowd_line.strip_edges() != ""
	if game_over_scroll != null:
		game_over_scroll.visible = not active
	if ending_text != null:
		ending_text.visible = not active

func _get_verdict_outcome_text(outcome: StringName) -> String:
	match outcome:
		&"CASHOUT":
			return "HAI INCASSATO."
		&"WIN":
			return "HAI SUPERATO L'ARENA."
		_:
			return "SEI CADUTO."

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
	var manager: Node = _get_run_manager()
	if manager == null:
		return false
	var reveals_value: Variant = manager.get("LYING_PACT_REVEALS")
	if not (reveals_value is Dictionary):
		return false
	var reveals: Dictionary = reveals_value as Dictionary
	for pact in pacts_payload:
		var pact_key: StringName = StringName(str(pact))
		if reveals.has(pact_key) or reveals.has(str(pact)):
			return true
	return false

func _on_run_debug_state_updated(payload: Dictionary) -> void:
	_debug_seed = int(payload.get("seed", 0))
	_debug_arena_index = int(payload.get("arena_index", 0))
	_debug_escalation = int(payload.get("escalation_level", 0))
	_debug_active_bet = str(payload.get("active_bet_id", ""))
	_debug_enemy_profile = str(payload.get("enemy_profile", ""))
	_debug_special_arena = str(payload.get("special_arena_id", ""))
	_set_glory_value(int(payload.get("glory", 0)))
	var scars_value: Array = payload.get("scars", []) as Array
	_debug_scars = []
	for scar_value in scars_value:
		_debug_scars.append(str(scar_value))
	if _debug_overlay != null and _debug_overlay.visible:
		_refresh_debug_overlay()

func _on_escalation_changed(level: int, max_value: int) -> void:
	_escalation_level = level
	_escalation_max = max_value
	_update_escalation_bar()

func _update_escalation_bar() -> void:
	if escalation_bar == null:
		return
	var safe_max: float = float(maxi(_escalation_max, 1))
	escalation_bar.max_value = safe_max
	escalation_bar.value = clampf(float(_escalation_level), 0.0, safe_max)

func _on_run_log_ready(log_text: String) -> void:
	_debug_run_log = log_text

func _on_special_arena_started(payload: Dictionary) -> void:
	_special_arena_payload = payload.duplicate(true)
	if bet_panel != null and bet_panel.visible:
		_update_special_arena_ui()

func _on_arena_theme_changed(payload: Dictionary) -> void:
	_arena_theme_payload = payload.duplicate(true)
	_update_arena_theme_ui()

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

func _on_run_started_controls() -> void:
	if controls_hint_panel == null:
		return
	controls_hint_panel.visible = _controls_first_run_active and (not _has_seen_controls)

func _on_run_failed_controls() -> void:
	if controls_hint_panel != null and _has_seen_controls:
		controls_hint_panel.visible = false

func _on_coins_changed(coins: int) -> void:
	if coins_label != null:
		coins_label.text = "Coins: %d" % coins
	_coins = coins

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
	bet_badge_value_label.text = "%s · x%.1f" % [label, multiplier]

func set_active_bet_text(text: String) -> void:
	if bet_badge_value_label == null:
		return
	bet_badge_value_label.text = text

func _on_bet_ui_opened(bets: Array[Dictionary]) -> void:
	if bet_panel == null:
		return
	if betting_circle != null or ResourceLoader.exists(BETTING_CIRCLE_SCENE_PATH):
		open_bet_circle(bets)
		return
	if game_over_panel != null and game_over_panel.visible:
		return
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
	if bet_confirm_button != null:
		bet_read_buttons.append(bet_confirm_button)
	_apply_modal_read_delay(bet_read_buttons)

func _on_bet_ui_closed() -> void:
	_set_bet_modal(false)
	if betting_circle != null:
		betting_circle.close()
	_reset_bet_confirmation()
	if special_arena_label != null:
		special_arena_label.visible = false
	if condanna_focus_label != null:
		condanna_focus_label.visible = false

func _on_bet_selected(bet_id: String) -> void:
	_selected_bet_id = bet_id

func _on_pact_sealed_opened() -> void:
	var payload: Dictionary = {
		"kind": "pact_sealed",
		"title": "IL PATTO È SIGILLATO.",
		"subtitle": _select_post_bet_text(_selected_bet_id),
	}
	enqueue_post_bet_message(payload)

func _on_pact_sealed_closed() -> void:
	if _post_bet_running:
		return
	_set_pact_sealed_modal(false)
	_refresh_modal_dimmer()

func _on_resolve_ritual_opened(payload: Dictionary) -> void:
	var doom_short: String = str(payload.get("doom_short", ""))
	var subtitle: String = "CONDANNA: giudizio imminente."
	if doom_short != "":
		subtitle = "CONDANNA: %s" % doom_short
	var queue_payload: Dictionary = {
		"kind": "resolve_ritual",
		"title": "RITO DI GIUDIZIO",
		"subtitle": subtitle,
	}
	enqueue_post_bet_message(queue_payload)

func _on_resolve_ritual_closed() -> void:
	if _post_bet_running:
		return
	_set_resolve_ritual_modal(false)
	_refresh_modal_dimmer()

func _on_intermediate_choice_opened() -> void:
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = 15
	payload.title = "SCEGLI IL GESTO"
	payload.choices = ["placa", "provoca"]
	payload.show_mid_choice = true
	apply_run_ui_payload(payload)

func apply_run_ui_payload(payload: RunUiPayload) -> void:
	if payload == null:
		return
	show_phase(payload.phase)
	if payload.show_mid_choice:
		_apply_intermediate_choice_payload(payload)
	if payload.show_push_your_luck:
		_apply_push_luck_payload(payload)

func _apply_intermediate_choice_payload(payload: RunUiPayload) -> void:
	if intermediate_choice_panel == null:
		return
	_set_bet_modal(false)
	if intermediate_choice_label != null:
		var title: String = payload.title
		if title == "":
			title = "SCEGLI IL GESTO"
		intermediate_choice_label.text = title
	_set_intermediate_choice_modal(true)
	var choice_buttons: Array[Button] = []
	if intermediate_choice_placa_button != null:
		intermediate_choice_placa_button.visible = payload.choices.is_empty() or payload.choices.has("placa")
		choice_buttons.append(intermediate_choice_placa_button)
	if intermediate_choice_provoca_button != null:
		intermediate_choice_provoca_button.visible = payload.choices.is_empty() or payload.choices.has("provoca")
		choice_buttons.append(intermediate_choice_provoca_button)
	_apply_modal_read_delay(choice_buttons)

func _select_post_bet_text(bet_id: String) -> String:
	var options: Array = POST_BET_TEXTS.get(bet_id, []) as Array
	if options.is_empty():
		return "La folla trattiene il fiato."
	var last_index: int = int(_post_bet_text_last_index.get(bet_id, -1))
	var pick_index: int = randi() % options.size()
	if options.size() > 1 and pick_index == last_index:
		pick_index = (pick_index + 1) % options.size()
	_post_bet_text_last_index[bet_id] = pick_index
	return str(options[pick_index])

func enqueue_post_bet_message(payload: Dictionary) -> void:
	_post_bet_queue.append(payload)
	if not _post_bet_running:
		call_deferred("_run_post_bet_queue")

func _run_post_bet_queue() -> void:
	if _post_bet_running:
		return
	_post_bet_running = true
	while not _post_bet_queue.is_empty():
		var payload: Dictionary = _post_bet_queue.pop_front()
		_post_bet_log_index += 1
		payload["log_index"] = _post_bet_log_index
		_show_post_bet_payload(payload)
		await get_tree().create_timer(POST_BET_MESSAGE_TIME_SEC).timeout
		_hide_post_bet_payload(payload)
		await get_tree().create_timer(FADE_OUT_SEC).timeout
	_post_bet_running = false
	arena_message_queue_completed.emit()

func is_post_bet_queue_running() -> bool:
	return _post_bet_running

func _show_post_bet_payload(payload: Dictionary) -> void:
	var kind: String = str(payload.get("kind", ""))
	var log_index: int = int(payload.get("log_index", -1))
	if log_index >= 0:
		print_debug("[FLOW] audience_message_opened :: index=%d, text_id=%s" % [log_index, kind])
	if kind == "pact_sealed":
		if pact_sealed_title != null:
			pact_sealed_title.text = str(payload.get("title", "IL PATTO È SIGILLATO."))
		if pact_sealed_subtitle != null:
			pact_sealed_subtitle.text = str(payload.get("subtitle", ""))
		_set_pact_sealed_modal(true)
	elif kind == "resolve_ritual":
		if resolve_ritual_title != null:
			resolve_ritual_title.text = str(payload.get("title", "RITO DI GIUDIZIO"))
		if resolve_ritual_subtitle != null:
			resolve_ritual_subtitle.text = str(payload.get("subtitle", "CONDANNA: giudizio imminente."))
		_set_resolve_ritual_modal(true)
	_refresh_modal_dimmer()

func _hide_post_bet_payload(payload: Dictionary) -> void:
	var kind: String = str(payload.get("kind", ""))
	var log_index: int = int(payload.get("log_index", -1))
	if log_index >= 0:
		print_debug("[FLOW] audience_message_closed :: index=%d" % log_index)
	if kind == "pact_sealed":
		_set_pact_sealed_modal(false)
	elif kind == "resolve_ritual":
		_set_resolve_ritual_modal(false)
	_refresh_modal_dimmer()

func _update_special_arena_ui() -> void:
	if special_arena_label == null:
		return
	if _special_arena_payload.is_empty():
		special_arena_label.visible = false
		return
	var title: String = str(_special_arena_payload.get("title", "Arena speciale"))
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

func _on_scars_updated(scars: Array) -> void:
	_refresh_scars_ui(scars)

func _on_scar_applied(scar: Dictionary) -> void:
	_show_scar_popup(scar)

func _refresh_scars_ui(scars: Array) -> void:
	if scars_label == null:
		return
	if scars_panel != null:
		if _ending_mode_active:
			scars_panel.visible = false
			return
		scars_panel.visible = true
		var scar_count: int = scars.size()
		var clamped_count: int = maxi(scar_count, 1)
		var desired_height: float = SCARS_PANEL_BASE_HEIGHT + (SCARS_PANEL_ROW_HEIGHT * float(clamped_count))
		var clamped_height: float = clampf(desired_height, SCARS_PANEL_MIN_HEIGHT, SCARS_PANEL_MAX_HEIGHT)
		scars_panel.custom_minimum_size.y = clamped_height
		scars_panel.size.y = clamped_height
	if scars.is_empty():
		scars_label.text = "Nessuna cicatrice."
		scars_label.tooltip_text = ""
		if scars_panel != null:
			scars_panel.tooltip_text = ""
		_scars_detail_text = ""
		return
	var summary_lines: Array[String] = []
	var detail_lines: Array[String] = []
	for scar_value: Dictionary in scars:
		var scar: Dictionary = scar_value as Dictionary
		var scar_name: String = str(scar.get("name", "Cicatrice"))
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
			summary_lines.append("• %s %s" % [visual_tag, scar_name])
			detail_lines.append("• %s %s" % [visual_tag, scar_name])
		else:
			summary_lines.append("• %s" % scar_name)
			detail_lines.append("• %s" % scar_name)
		if short_desc != "":
			summary_lines.append("  %s" % short_desc)
			detail_lines.append("  %s" % short_desc)
		if story != "":
			var story_lines: PackedStringArray = story.split("\n")
			for line: String in story_lines:
				if line != "":
					detail_lines.append("  %s" % line)
		if effect_text != "":
			detail_lines.append("  Effetto: %s" % effect_text)
		if origin != "":
			detail_lines.append("  Origine: %s" % origin)
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
	_hide_scars_detail()

func _set_scars_detail_modal(active: bool) -> void:
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("scars_detail")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("scars_detail")
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
	lines.append("[b]Cicatrici rilevanti:[/b]")
	for scar_value: Dictionary in _last_finale_scars:
		var scar: Dictionary = scar_value as Dictionary
		var scar_name: String = "Cicatrice"
		if scar.has("name"):
			scar_name = str(scar["name"])
		lines.append("• %s" % scar_name)
	return "\n".join(lines)

func _build_ending_meta_section() -> String:
	var lines: Array[String] = []
	if _last_finale_seed != 0:
		lines.append("Traccia: %d" % _last_finale_seed)
	if lines.is_empty():
		return ""
	lines.insert(0, "[b]Registro:[/b]")
	return "\n".join(lines)

func _on_push_luck_opened(payload: Dictionary) -> void:
	var ui_payload: RunUiPayload = RunUiPayloadScript.new()
	ui_payload.phase = 16
	ui_payload.show_push_your_luck = true
	ui_payload.meta = payload
	ui_payload.title = "PUSH YOUR LUCK — %s" % str(payload.get("bet_name", ""))
	ui_payload.body = "La folla vuole di più. Puoi incassare… o rilanciare."
	ui_payload.choices = ["cashout", "condanna", "double"]
	apply_run_ui_payload(ui_payload)

func _apply_push_luck_payload(payload: RunUiPayload) -> void:
	if push_luck_panel == null:
		return
	_set_bet_modal(false)
	var meta: Dictionary = payload.meta
	var bet_name: String = str(meta.get("bet_name", ""))
	if push_luck_title != null:
		if payload.title != "":
			push_luck_title.text = payload.title
		else:
			push_luck_title.text = "PUSH YOUR LUCK — %s" % bet_name
	if push_luck_info != null:
		if payload.body != "":
			push_luck_info.text = payload.body
		else:
			push_luck_info.text = "La folla vuole di più. Puoi incassare… o rilanciare."
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
	var lines: Array[String] = []
	if doom_text != "":
		lines.append("❌ Condanna futura: %s" % doom_text)
	if condition_text != "":
		lines.append("⚠️ Condizione: %s" % condition_text)
	if pact_text != "":
		lines.append("✅ Patto potenziato: %s" % pact_text)
	if choice_note != "":
		lines.append("⚡ %s" % choice_note)
	if cashout_locked and cashout_reason != "":
		lines.append("⛔ Incasso bloccato: %s" % cashout_reason)
	if double_locked and double_reason != "":
		lines.append("⛔ Raddoppio bloccato: %s" % double_reason)
	if push_luck_details != null:
		push_luck_details.text = "\n".join(lines)
	if push_luck_audience_label != null:
		push_luck_audience_label.text = audience_label
		push_luck_audience_label.visible = audience_label != ""
	if push_luck_audience_reason != null:
		var reason_lines: Array[String] = []
		if audience_reason != "":
			reason_lines.append(audience_reason)
		if cashout_modifier_text != "":
			reason_lines.append(cashout_modifier_text)
		push_luck_audience_reason.text = "\n".join(reason_lines)
		push_luck_audience_reason.visible = reason_lines.size() > 0
	if push_luck_cashout_button != null:
		push_luck_cashout_button.disabled = cashout_locked
		if cashout_locked and cashout_reason != "":
			push_luck_cashout_button.tooltip_text = cashout_reason
		else:
			push_luck_cashout_button.tooltip_text = ""
	if push_luck_cashout_note != null:
		if cashout_locked:
			push_luck_cashout_note.text = _format_lock_note(cashout_reason, "Disponibile dopo l'arena in corso.")
			push_luck_cashout_note.visible = true
		else:
			push_luck_cashout_note.visible = false
	if push_luck_double_button != null:
		push_luck_double_button.disabled = double_locked
		if double_locked and double_reason != "":
			push_luck_double_button.tooltip_text = double_reason
		else:
			push_luck_double_button.tooltip_text = ""
	if push_luck_double_note != null:
		if double_locked:
			push_luck_double_note.text = _format_lock_note(double_reason, "Disponibile dopo l'arena in corso.")
			push_luck_double_note.visible = true
		else:
			push_luck_double_note.visible = false
	_set_push_luck_modal(true)
	var push_luck_read_buttons: Array[Button] = []
	if push_luck_cashout_button != null:
		push_luck_read_buttons.append(push_luck_cashout_button)
	if push_luck_condanna_button != null:
		push_luck_read_buttons.append(push_luck_condanna_button)
	if push_luck_double_button != null:
		push_luck_read_buttons.append(push_luck_double_button)
	_apply_modal_read_delay(push_luck_read_buttons)

func _on_push_luck_closed() -> void:
	_set_push_luck_modal(false)

func _wire_push_luck_buttons() -> void:
	if push_luck_cashout_button != null:
		var cashout_callable: Callable = Callable(self, "_on_push_luck_cashout_pressed")
		if not push_luck_cashout_button.pressed.is_connected(cashout_callable):
			push_luck_cashout_button.pressed.connect(cashout_callable)
	if push_luck_condanna_button != null:
		var condanna_callable: Callable = Callable(self, "_on_push_luck_condanna_pressed")
		if not push_luck_condanna_button.pressed.is_connected(condanna_callable):
			push_luck_condanna_button.pressed.connect(condanna_callable)
	if push_luck_double_button != null:
		var double_callable: Callable = Callable(self, "_on_push_luck_double_pressed")
		if not push_luck_double_button.pressed.is_connected(double_callable):
			push_luck_double_button.pressed.connect(double_callable)

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
	_set_intermediate_choice_modal(false)
	if GameEvents.has_signal("request_mid_choice_select"):
		GameEvents.request_mid_choice_select.emit(0)

func _on_intermediate_choice_provoca_pressed() -> void:
	_set_intermediate_choice_modal(false)
	if GameEvents.has_signal("request_mid_choice_select"):
		GameEvents.request_mid_choice_select.emit(1)

func _wire_debug_tools() -> void:
	if not OS.is_debug_build():
		return
	if debug_seed_button != null:
		var seed_callable: Callable = Callable(self, "_on_debug_seed_pressed")
		if not debug_seed_button.pressed.is_connected(seed_callable):
			debug_seed_button.pressed.connect(seed_callable)
	if debug_restart_button != null:
		var restart_callable: Callable = Callable(self, "_on_debug_restart_pressed")
		if not debug_restart_button.pressed.is_connected(restart_callable):
			debug_restart_button.pressed.connect(restart_callable)
	if debug_skip_button != null:
		var skip_callable: Callable = Callable(self, "_on_debug_skip_pressed")
		if not debug_skip_button.pressed.is_connected(skip_callable):
			debug_skip_button.pressed.connect(skip_callable)
	if debug_copy_log_button != null:
		var copy_callable: Callable = Callable(self, "_on_debug_copy_log_pressed")
		if not debug_copy_log_button.pressed.is_connected(copy_callable):
			debug_copy_log_button.pressed.connect(copy_callable)

func _on_debug_seed_pressed() -> void:
	if debug_seed_input == null:
		return
	var text_value: String = debug_seed_input.text.strip_edges()
	if not text_value.is_valid_int():
		return
	var seed_value: int = int(text_value)
	if GameEvents.has_signal("request_set_run_seed"):
		GameEvents.request_set_run_seed.emit(seed_value)

func _on_debug_restart_pressed() -> void:
	if GameEvents.has_signal("request_reset_run"):
		GameEvents.request_reset_run.emit()

func _on_debug_skip_pressed() -> void:
	if GameEvents.has_signal("request_skip_arena_resolution"):
		GameEvents.request_skip_arena_resolution.emit()

func _on_debug_copy_log_pressed() -> void:
	if _debug_run_log == "":
		return
	DisplayServer.clipboard_set(_debug_run_log)

func _on_push_luck_cashout_pressed() -> void:
	if GameEvents.has_signal("request_pyl_cashout"):
		GameEvents.request_pyl_cashout.emit()

func _on_push_luck_condanna_pressed() -> void:
	if GameEvents.has_signal("request_pyl_condanna"):
		GameEvents.request_pyl_condanna.emit()

func _on_push_luck_double_pressed() -> void:
	if GameEvents.has_signal("request_pyl_double"):
		GameEvents.request_pyl_double.emit()

func _on_bet_win_pressed() -> void:
	if GameEvents.has_signal("request_intro_select_bet"):
		GameEvents.request_intro_select_bet.emit("DOUBLE_OR_DIE")

func _on_bet_no_hit_pressed() -> void:
	if GameEvents.has_signal("request_intro_select_bet"):
		GameEvents.request_intro_select_bet.emit("FLAWLESS_BLOOD")

func _on_bet_fast_pressed() -> void:
	if GameEvents.has_signal("request_intro_select_bet"):
		GameEvents.request_intro_select_bet.emit("CASH_OUT")

func _on_restart_pressed() -> void:
	if GameEvents.has_signal("request_end_run_restart"):
		GameEvents.request_end_run_restart.emit()

func _on_retry_pressed() -> void:
	if GameEvents.has_signal("request_end_run_next_bet"):
		GameEvents.request_end_run_next_bet.emit()

func _request_reset() -> void:
	_set_game_over_modal(false)

	if GameEvents.has_signal("request_new_run"):
		GameEvents.request_new_run.emit()
	_hide_scars_detail()
	_refresh_modal_dimmer()

func _request_next_bet() -> void:
	# Legacy next-bet request removed; current flow advances via RunManager level-3 events.
	pass

func _request_retry() -> void:
	_set_game_over_modal(false)
	if GameEvents.has_signal("request_retry_run"):
		GameEvents.request_retry_run.emit()
	_hide_scars_detail()
	_refresh_modal_dimmer()

func _on_quit_pressed() -> void:
	if GameEvents.has_signal("request_end_run_quit"):
		GameEvents.request_end_run_quit.emit()

func _on_player_health_changed(current: int, max_value: int) -> void:
	if player_hp_bar == null or player_hp_label == null:
		return
	player_hp_bar.max_value = max_value
	player_hp_bar.value = current
	player_hp_label.text = "HP: %d/%d" % [current, max_value]

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

func _on_player_spawned(p: Node) -> void:
	_bind_player(p)

func _bind_player(p: Node) -> void:
	if _player != null and _player.has_signal("health_changed"):
		var health_callable: Callable = Callable(self, "_on_player_health_changed")
		if _player.health_changed.is_connected(health_callable):
			_player.health_changed.disconnect(health_callable)

	_player = p

	if _player != null and _player.has_signal("health_changed"):
		var health_callable: Callable = Callable(self, "_on_player_health_changed")
		if not _player.health_changed.is_connected(health_callable):
			_player.health_changed.connect(health_callable)

	if _player != null and _player.has_method("get_health"):
		var h: Array = _player.call("get_health")
		if h.size() >= 2:
			_on_player_health_changed(int(h[0]), int(h[1]))

func _build_bet_buttons(bets: Array[Dictionary]) -> void:
	if bet_buttons_container == null:
		return
	_clear_bet_buttons()
	var add_intro_note: bool = _get_arena_index() <= 1
	var intro_note: String = "Le cicatrici restano. Raddoppiare aumenta il rischio."
	var note_used: bool = false
	for bet_value: Dictionary in bets:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: String = str(bet.get("id", ""))
		if bet_id == "":
			continue
		var extra_note: String = ""
		if add_intro_note and not note_used:
			extra_note = intro_note
			note_used = true
		var button: Button = _create_bet_button(bet_id, bet, extra_note)
		bet_buttons_container.add_child(button)
		_bet_buttons.append(button)

func _safe_load_stylebox(path: String) -> StyleBox:
	if not ResourceLoader.exists(path, "StyleBox"):
		return null
	return load(path) as StyleBox

func _create_bet_button(bet_id: String, bet: Dictionary, extra_note: String) -> Button:
	var button: Button = Button.new()
	if _button_style_primary_normal != null:
		button.add_theme_stylebox_override("normal", _button_style_primary_normal)
	if _button_style_primary_hover != null:
		button.add_theme_stylebox_override("hover", _button_style_primary_hover)
		button.add_theme_stylebox_override("focus", _button_style_primary_hover)
	if _button_style_primary_pressed != null:
		button.add_theme_stylebox_override("pressed", _button_style_primary_pressed)
	if _button_style_primary_disabled != null:
		button.add_theme_stylebox_override("disabled", _button_style_primary_disabled)
	button.custom_minimum_size = Vector2(0, 190)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 20)
	button.text = _format_bet_button_text(bet_id, bet, extra_note)
	button.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
	button.disabled = false
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	var pressed_callable: Callable = Callable(self, "_on_bet_choice_pressed").bind(bet_id)
	if not button.pressed.is_connected(pressed_callable):
		button.pressed.connect(pressed_callable)
	_apply_bet_button_style(button, bet_id)
	return button

func _format_bet_button_text(bet_id: String, bet: Dictionary, extra_note: String) -> String:
	var name_text: String = str(bet.get("name", bet_id))
	var condition_text: String = str(bet.get("condition", ""))
	var pact_text: String = str(bet.get("pact", ""))
	var doom_text: String = str(bet.get("doom", ""))
	var archetype_label: String = str(bet.get("archetype_label", ""))
	var lines: Array[String] = []
	if doom_text != "":
		lines.append("❌ Condanna — %s" % name_text)
		lines.append("%s" % doom_text)
	else:
		lines.append("❌ Condanna — %s" % name_text)
	if archetype_label != "":
		lines.append(archetype_label)
	if condition_text != "":
		lines.append("⚠️ Condizione: %s" % condition_text)
	if pact_text != "":
		lines.append("✅ Patto: %s" % pact_text)
	if extra_note != "":
		lines.append("ℹ️ %s" % extra_note)
	return "\n".join(lines)

func _format_lock_note(reason: String, fallback: String) -> String:
	var text: String = reason.strip_edges()
	if text == "":
		text = fallback
	if not text.ends_with("."):
		text += "."
	return text

func _clear_bet_buttons() -> void:
	_bet_buttons.clear()
	if bet_buttons_container == null:
		return
	for child in bet_buttons_container.get_children():
		if child is Node:
			child.queue_free()

func _apply_bet_button_style(button: Button, bet_id: String) -> void:
	if button == null:
		return
	if bet_id == "DOUBLE_OR_DIE":
		button.modulate = Color(1.0, 0.75, 0.75, 1.0)
		button.add_theme_color_override("font_color", Color(0.75, 0.05, 0.05, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.9, 0.2, 0.2, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.9, 0.2, 0.2, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.35, 0.35, 1.0))
		return
	if bet_id == "LAST_BREATH":
		button.modulate = Color(1.0, 0.78, 0.7, 1.0)
		button.add_theme_color_override("font_color", Color(0.6, 0.12, 0.12, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.8, 0.2, 0.2, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.8, 0.2, 0.2, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.9, 0.25, 0.25, 1.0))
		return
	if bet_id == "FLAWLESS_BLOOD":
		button.modulate = Color(1.0, 0.95, 0.8, 1.0)
		button.add_theme_color_override("font_color", Color(0.6, 0.45, 0.0, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.75, 0.55, 0.1, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.75, 0.55, 0.1, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.9, 0.65, 0.15, 1.0))
		return
	if bet_id == "BLOOD_TAX":
		button.modulate = Color(1.0, 0.9, 0.82, 1.0)
		button.add_theme_color_override("font_color", Color(0.55, 0.2, 0.1, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.7, 0.3, 0.15, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.7, 0.3, 0.15, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.85, 0.4, 0.2, 1.0))
		return
	if bet_id == "DEBT_CHAIN":
		button.modulate = Color(0.95, 0.9, 1.0, 1.0)
		button.add_theme_color_override("font_color", Color(0.3, 0.2, 0.55, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.45, 0.3, 0.7, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.45, 0.3, 0.7, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.55, 0.35, 0.8, 1.0))
		return
	if bet_id == "CROW_PLEASER":
		button.modulate = Color(1.0, 0.98, 0.86, 1.0)
		button.add_theme_color_override("font_color", Color(0.45, 0.35, 0.0, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.6, 0.45, 0.1, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.6, 0.45, 0.1, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.75, 0.55, 0.2, 1.0))
		return
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.remove_theme_color_override("font_color")
	button.remove_theme_color_override("font_hover_color")
	button.remove_theme_color_override("font_focus_color")
	button.remove_theme_color_override("font_pressed_color")

func _on_bet_failed(can_retry: bool) -> void:
	_set_bet_modal(false)
	_reset_bet_confirmation()
	_reset_fast_countdown()
	_set_game_over_modal(true)
	_set_verdict_mode(false)
	_last_finale_title = "RUN FAILED"
	if can_retry:
		_last_finale_title = "BET FAILED"
	_last_finale_text = ""
	_last_finale_scars = []
	_last_finale_ending_id = ""
	_last_finale_seed = 0
	_last_finale_stats = {}
	_last_finale_hint = "Vuoi riprovare?"
	if can_retry:
		_last_finale_hint = "Riprova la scommessa?"
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	if next_bet_button != null:
		next_bet_button.visible = can_retry
		next_bet_button.text = "RETRY BET"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
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
	if _require_bet_confirm:
		_pending_confirm_bet_id = bet_id
		if bet_confirm_label != null:
			bet_confirm_label.text = "Selezione: %s" % _get_bet_name(bet_id)
		if bet_confirm_row != null:
			bet_confirm_row.visible = true
		get_viewport().gui_release_focus()
		return
	_place_bet(bet_id)

func _on_bet_confirm_pressed() -> void:
	if GameEvents.has_signal("request_intro_confirm"):
		GameEvents.request_intro_confirm.emit()

func _place_bet(bet_id: String) -> void:
	_selected_bet_id = bet_id
	_reset_fast_countdown()
	_reset_bet_confirmation()
	if GameEvents.has_signal("request_place_bet"):
		GameEvents.request_place_bet.emit(bet_id, 0)

func _get_bet_name(bet_id: String) -> String:
	if not _bets_by_id.has(bet_id):
		return bet_id
	var bet: Dictionary = _bets_by_id.get(bet_id, {}) as Dictionary
	if bet.is_empty():
		return bet_id
	return str(bet.get("name", bet_id))

func _apply_modal_read_delay(buttons: Array[Button]) -> void:
	if buttons.is_empty():
		return
	var initial_states: Array[bool] = []
	initial_states.resize(buttons.size())
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		initial_states[index] = button.disabled
		button.disabled = true
	await get_tree().create_timer(MIN_MODAL_READ_TIME_SEC).timeout
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		button.disabled = initial_states[index]

func _fade_modal(panel: CanvasItem, modal: Control, active: bool, tween: Tween) -> Tween:
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
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(panel, "modulate:a", 1.0, FADE_IN_SEC)
	else:
		if not panel.visible:
			modal.visible = false
			return tween
		tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(panel, "modulate:a", 0.0, FADE_OUT_SEC)
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
		panel.visible = false
		panel.modulate.a = 1.0
	if modal != null:
		modal.visible = false
		if modal == _current_modal:
			_current_modal = null
	_refresh_modal_dimmer()

func _set_bet_modal(active: bool) -> void:
	if active:
		show_modal(bet_modal)
	_bet_modal_fade_tween = _fade_modal(bet_panel, bet_modal, active, _bet_modal_fade_tween)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("bet")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("bet")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_pact_sealed_modal(active: bool) -> void:
	if active:
		show_modal(pact_sealed_modal)
	_pact_sealed_modal_fade_tween = _fade_modal(pact_sealed_panel, pact_sealed_modal, active, _pact_sealed_modal_fade_tween)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("pact_sealed")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("pact_sealed")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_resolve_ritual_modal(active: bool) -> void:
	if active:
		show_modal(resolve_ritual_modal)
	_resolve_ritual_modal_fade_tween = _fade_modal(resolve_ritual_panel, resolve_ritual_modal, active, _resolve_ritual_modal_fade_tween)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("resolve_ritual")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("resolve_ritual")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_intermediate_choice_modal(active: bool) -> void:
	if active:
		show_modal(intermediate_choice_modal)
	_intermediate_choice_modal_fade_tween = _fade_modal(
		intermediate_choice_panel,
		intermediate_choice_modal,
		active,
		_intermediate_choice_modal_fade_tween
	)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("intermediate_choice")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("intermediate_choice")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_push_luck_modal(active: bool) -> void:
	if active:
		show_modal(push_luck_modal)
	_push_luck_modal_fade_tween = _fade_modal(push_luck_panel, push_luck_modal, active, _push_luck_modal_fade_tween)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("push_luck")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("push_luck")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_game_over_modal(active: bool) -> void:
	if active:
		show_modal(game_over_modal)
	_game_over_modal_fade_tween = _fade_modal(game_over_panel, game_over_modal, active, _game_over_modal_fade_tween)
	if active:
		enter_ending_mode()
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("ending")
	else:
		exit_ending_mode()
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("ending")
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
	_is_signing = false
	if bet_confirm_label != null:
		bet_confirm_label.text = "Selezione: -"
	if bet_confirm_row != null:
		bet_confirm_row.visible = false
	if bet_confirm_button != null:
		if _bet_confirm_default_text == "":
			_bet_confirm_default_text = bet_confirm_button.text
		bet_confirm_button.text = _bet_confirm_default_text
		bet_confirm_button.disabled = false
	for button: Button in _bet_buttons:
		button.disabled = false

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

func open_bet_circle(bets: Array[Dictionary]) -> void:
	_current_bet_offer = bets.duplicate()
	var circle: BettingCircleUI = betting_circle
	if circle == null:
		if modals_root == null:
			push_error("SANITY FAIL UI: BetCircle missing")
			return
		var circle_scene: PackedScene = load(BETTING_CIRCLE_SCENE_PATH) as PackedScene
		if circle_scene == null:
			push_error("SANITY FAIL UI: BetCircle missing")
			return
		var instance: Node = circle_scene.instantiate()
		if instance == null:
			push_error("SANITY FAIL UI: BetCircle missing")
			return
		instance.name = "BettingCircle"
		modals_root.add_child(instance)
		circle = instance as BettingCircleUI
		if circle == null:
			push_error("SANITY FAIL UI: BetCircle missing")
			return
		betting_circle = circle
	show_modal(circle)
	circle.modulate.a = 1.0
	circle.process_mode = Node.PROCESS_MODE_INHERIT
	circle.mouse_filter = Control.MOUSE_FILTER_STOP
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

func _update_debug_overlay(text: String) -> void:
	if _debug_label == null:
		return
	_debug_label.text = text

func _refresh_debug_overlay() -> void:
	if _debug_overlay == null:
		return
	var manager: Node = _get_run_manager()
	if manager == null:
		_update_debug_overlay("Phase: -\nLast request: -\nLast UI render ms: -\nFlow tail:\nRunManager not found")
		return
	var phase_name: String = "-"
	if manager.has_method("get_debug_phase_name"):
		phase_name = str(manager.call("get_debug_phase_name"))
	var last_request: String = "-"
	if manager.has_method("get_debug_last_request"):
		last_request = str(manager.call("get_debug_last_request"))
	var last_ui_render_ms: int = -1
	if manager.has_method("get_debug_last_ui_render_ms"):
		last_ui_render_ms = int(manager.call("get_debug_last_ui_render_ms"))
	var flow_tail: String = "-"
	if manager.has_method("get_debug_flow_tail"):
		flow_tail = str(manager.call("get_debug_flow_tail", 10))
	_update_debug_overlay("Phase: %s\nLast request: %s\nLast UI render ms: %d\nFlow tail:\n%s" % [
		phase_name,
		last_request,
		last_ui_render_ms,
		flow_tail,
	])

func _process(_delta: float) -> void:
	if _debug_overlay == null or not _debug_overlay.visible:
		return
	_refresh_debug_overlay()

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
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			if _debug_overlay != null:
				_debug_overlay.visible = not _debug_overlay.visible
				if _debug_overlay.visible:
					_refresh_debug_overlay()
		if OS.is_debug_build():
			if event.keycode == KEY_F2:
				DisplayServer.clipboard_set(str(_debug_seed))
			if event.keycode == KEY_F4:
				var clipboard_text: String = DisplayServer.clipboard_get()
				if clipboard_text.is_valid_int() and GameEvents.has_signal("request_set_run_seed"):
					GameEvents.request_set_run_seed.emit(int(clipboard_text))
			if event.keycode == KEY_F5:
				if GameEvents.has_signal("request_reset_run"):
					GameEvents.request_reset_run.emit()
			if event.keycode == KEY_F6:
				if GameEvents.has_signal("request_skip_arena_resolution"):
					GameEvents.request_skip_arena_resolution.emit()

func _req(path: String) -> Node:
	var n: Node = get_node_or_null(path)
	if n == null:
		push_error("UI missing node at path: %s" % path)
	return n

func _get_run_manager() -> Node:
	if _run_manager and is_instance_valid(_run_manager):
		return _run_manager
	_run_manager = get_tree().get_first_node_in_group("run_manager")
	return _run_manager

func _get_arena() -> Node:
	if _arena and is_instance_valid(_arena):
		return _arena
	var manager: Node = _get_run_manager()
	if manager and manager.has_method("get_arena"):
		_arena = manager.get_arena()
	if _arena:
		return _arena
	_arena = get_tree().get_first_node_in_group("arena")
	return _arena

func _get_arena_index() -> int:
	var manager: Node = _get_run_manager()
	if manager and manager.has_method("get_arena_index"):
		return manager.get_arena_index()
	return 0

func _get_enemies_alive() -> int:
	var arena: Node = _get_arena()
	if arena and arena.has_method("get_enemies_remaining"):
		return int(arena.get_enemies_remaining())
	return 0
