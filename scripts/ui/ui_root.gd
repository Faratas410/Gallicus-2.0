extends CanvasLayer

const FAST_SELECTION_SECONDS: int = 12
const MODAL_FADE_SECONDS: float = 0.2
const BETTING_CIRCLE_SCENE_PATH: String = "res://scenes/ui/BettingCircle.tscn"

@onready var coins_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/CoinsRow/CoinsContent/CoinsLabel") as Label
@onready var tokens_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/TokensRow/TokensLabel") as Label
@onready var level_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/LevelRow/LevelLabel") as Label
@onready var bet_info_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/BetRow/BetContent/BetInfoLabel") as Label
@onready var xp_bar: ProgressBar = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/XPRow/XPBar") as ProgressBar
@onready var xp_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/XPRow/XPLabel") as Label
@onready var player_hp_bar: ProgressBar = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/PlayerHPRow/PlayerHPContent/PlayerHPBar") as ProgressBar
@onready var player_hp_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/PlayerHPRow/PlayerHPContent/PlayerHPLabel") as Label
@onready var seed_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/SeedRow/SeedLabel") as Label
@onready var bet_modal: Control = _req("Modals/BetModal") as Control
@onready var betting_circle: BettingCircleUI = get_node_or_null("Modals/BettingCircle") as BettingCircleUI
@onready var modals_root: Control = get_node_or_null("Modals") as Control
@onready var pact_sealed_modal: Control = get_node_or_null("Modals/PactSealedModal") as Control
@onready var pact_sealed_panel: Panel = get_node_or_null("Modals/PactSealedModal/PactSealedPanel") as Panel
@onready var pact_sealed_title: Label = get_node_or_null("Modals/PactSealedModal/PactSealedPanel/PactSealedVBox/PactSealedTitle") as Label
@onready var pact_sealed_subtitle: Label = get_node_or_null("Modals/PactSealedModal/PactSealedPanel/PactSealedVBox/PactSealedSubtitle") as Label
@onready var resolve_ritual_modal: Control = get_node_or_null("Modals/ResolveRitualModal") as Control
@onready var resolve_ritual_panel: Panel = get_node_or_null("Modals/ResolveRitualModal/ResolveRitualPanel") as Panel
@onready var resolve_ritual_title: Label = get_node_or_null("Modals/ResolveRitualModal/ResolveRitualPanel/ResolveRitualVBox/ResolveRitualTitle") as Label
@onready var resolve_ritual_subtitle: Label = get_node_or_null("Modals/ResolveRitualModal/ResolveRitualPanel/ResolveRitualVBox/ResolveRitualSubtitle") as Label
@onready var bet_panel: Panel = _req("Modals/BetModal/BetPanel") as Panel
@onready var buy_token_button: Button = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/BuyTokenRow/BuyTokenVBox/BuyTokenButton") as Button
@onready var buy_token_info: Label = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/BuyTokenRow/BuyTokenInfo") as Label
@onready var buy_token_note: Label = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/BuyTokenRow/BuyTokenVBox/BuyTokenNote") as Label
@onready var coins_icon: TextureRect = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/CoinsRow/CoinsContent/CoinIcon") as TextureRect
@onready var tokens_icon: TextureRect = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/TokensRow/TokenIcon") as TextureRect
@onready var modal_dimmer: ColorRect = get_node_or_null("Modals/ModalDimmer") as ColorRect
@onready var stake_row: Control = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/StakeRow") as Control
@onready var stake_input: SpinBox = _req("Modals/BetModal/BetPanel/BetScroll/BetVBox/StakeRow/StakeInput") as SpinBox
@onready var bet_buttons_container: VBoxContainer = _req("Modals/BetModal/BetPanel/BetScroll/BetVBox/BetButtons") as VBoxContainer
@onready var special_arena_label: Label = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/SpecialArenaLabel") as Label
@onready var condanna_focus_label: Label = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/CondannaFocusLabel") as Label
@onready var bet_confirm_row: Control = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/BetConfirmRow") as Control
@onready var bet_confirm_label: Label = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/BetConfirmRow/BetConfirmLabel") as Label
@onready var bet_confirm_button: Button = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/BetConfirmRow/BetConfirmButton") as Button
@onready var seed_input: LineEdit = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/SeedRow/SeedInput") as LineEdit
@onready var seed_apply_button: Button = get_node_or_null("Modals/BetModal/BetPanel/BetScroll/BetVBox/SeedRow/SeedButton") as Button
@onready var debug_overlay: Label = get_node_or_null("HUD/DebugOverlay") as Label
@onready var debug_tools_panel: Panel = get_node_or_null("HUD/DebugTools") as Panel
@onready var debug_seed_input: LineEdit = get_node_or_null("HUD/DebugTools/DebugToolsVBox/SeedRow/SeedInput") as LineEdit
@onready var debug_seed_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/SeedRow/SeedButton") as Button
@onready var debug_restart_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/DebugButtons/RestartRunButton") as Button
@onready var debug_skip_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/DebugButtons/SkipArenaButton") as Button
@onready var debug_copy_log_button: Button = get_node_or_null("HUD/DebugTools/DebugToolsVBox/CopyLogButton") as Button
@onready var level_up_popup: Label = get_node_or_null("HUD/LevelUpPopup") as Label
@onready var scar_popup: RichTextLabel = get_node_or_null("HUD/ScarPopup") as RichTextLabel
@onready var arena_resolution_label: Label = get_node_or_null("HUD/ArenaResolutionOverlay") as Label
@onready var sfx_level_up: AudioStreamPlayer = get_node_or_null("SFX/SfxLevelUp") as AudioStreamPlayer
@onready var sfx_buy_token: AudioStreamPlayer = get_node_or_null("SFX/SfxBuyToken") as AudioStreamPlayer
@onready var game_over_modal: Control = get_node_or_null("Modals/GameOverModal") as Control
@onready var game_over_panel: Panel = get_node_or_null("Modals/GameOverModal/GameOverPanel") as Panel
@onready var push_luck_modal: Control = get_node_or_null("Modals/PushLuckModal") as Control
@onready var push_luck_panel: Panel = get_node_or_null("Modals/PushLuckModal/PushLuckPanel") as Panel
@onready var push_luck_title: Label = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckTitle") as Label
@onready var push_luck_info: Label = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckInfo") as Label
@onready var push_luck_details: Label = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckDetails") as Label
@onready var push_luck_cashout_button: Button = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckButtons/PushLuckCashoutBox/PushLuckCashoutButton") as Button
@onready var push_luck_cashout_note: Label = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckButtons/PushLuckCashoutBox/PushLuckCashoutNote") as Label
@onready var push_luck_double_button: Button = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckButtons/PushLuckDoubleBox/PushLuckDoubleButton") as Button
@onready var push_luck_double_note: Label = get_node_or_null("Modals/PushLuckModal/PushLuckPanel/PushLuckVBox/PushLuckButtons/PushLuckDoubleBox/PushLuckDoubleNote") as Label
@onready var game_over_title: Label = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/GameOverTitle") as Label
@onready var game_over_epilogue: Label = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/GameOverEpilogue") as Label
@onready var game_over_scars: Label = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/GameOverScars") as Label
@onready var game_over_meta: Label = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/GameOverMeta") as Label
@onready var game_over_hint: Label = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/GameOverHint") as Label
@onready var restart_button: Button = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/RestartButton") as Button
@onready var next_bet_button: Button = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/NextBetButton") as Button
@onready var quit_button: Button = get_node_or_null("Modals/GameOverModal/GameOverPanel/GameOverVBox/QuitButton") as Button
@onready var controls_hint_panel: Panel = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ControlsHintPanel") as Panel
@onready var scars_panel: Panel = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ScarsPanel") as Panel
@onready var scars_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ScarsPanel/ScarsVBox/ScarsScroll/ScarsLabel") as Label
@onready var countdown_label: Label = get_node_or_null("Modals/CountdownLabel") as Label
@onready var fast_countdown_label: Label = get_node_or_null("Modals/FastCountdownLabel") as Label
@onready var fast_blink_timer: Timer = get_node_or_null("Modals/FastBlinkTimer") as Timer
@onready var enemy_bars: Control = get_node_or_null("WorldUI/EnemyBars") as Control
@onready var scars_detail_panel: Panel = get_node_or_null("Modals/ScarsDetailPanel") as Panel
@onready var scars_detail_text: Label = get_node_or_null("Modals/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailText") as Label
@onready var scars_detail_close: Button = get_node_or_null("Modals/ScarsDetailPanel/ScarsDetailVBox/ScarsDetailClose") as Button

@export var sfx_level_up_path: String = ""
@export var sfx_buy_token_path: String = ""

var _enemy_bar_scene: PackedScene = preload("res://scenes/ui/EnemyHealthBar.tscn")
var _bets_by_id: Dictionary = {}
var _bet_manager: Node
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
var _xp_current: int = 0
var _xp_to_next: int = 6
var _level: int = 1
var _tokens: int = 0
var _coins: int = 0
var _popup_tween: Tween = null
var _scar_popup_tween: Tween = null
var _arena_resolution_tween: Tween = null
var _bet_modal_fade_tween: Tween = null
var _pact_sealed_modal_fade_tween: Tween = null
var _resolve_ritual_modal_fade_tween: Tween = null
var _push_luck_modal_fade_tween: Tween = null
var _game_over_modal_fade_tween: Tween = null
var _last_level: int = 1
var _last_tokens: int = 0
var _xp_anim_tween: Tween = null
var _xp_punch_tween: Tween = null
var _last_xp_to_next: int = 0
var _enemy_bar_nodes: Dictionary = {}
var _last_finale_title: String = "RUN FAILED"
var _last_finale_text: String = ""
var _last_finale_scars: Array = []
var _last_finale_ending_id: String = ""
var _last_finale_seed: int = 0
var _last_finale_stats: Dictionary = {}
var _special_arena_payload: Dictionary = {}
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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _validate_ui_boot():
		_disable_ui_interactions()
		return
	if controls_hint_panel != null:
		controls_hint_panel.visible = true
		_has_seen_controls = false
		_controls_first_run_active = true
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
	var run_finale_callable: Callable = Callable(self, "_on_run_finale_selected")
	if GameEvents.has_signal("run_finale_selected") and not GameEvents.run_finale_selected.is_connected(run_finale_callable):
		GameEvents.run_finale_selected.connect(run_finale_callable)
	var run_debug_callable: Callable = Callable(self, "_on_run_debug_state_updated")
	if GameEvents.has_signal("run_debug_state_updated") and not GameEvents.run_debug_state_updated.is_connected(run_debug_callable):
		GameEvents.run_debug_state_updated.connect(run_debug_callable)
	var run_log_callable: Callable = Callable(self, "_on_run_log_ready")
	if GameEvents.has_signal("run_log_ready") and not GameEvents.run_log_ready.is_connected(run_log_callable):
		GameEvents.run_log_ready.connect(run_log_callable)
	var special_arena_callable: Callable = Callable(self, "_on_special_arena_started")
	if GameEvents.has_signal("special_arena_started") and not GameEvents.special_arena_started.is_connected(special_arena_callable):
		GameEvents.special_arena_started.connect(special_arena_callable)
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
	var player_level_callable: Callable = Callable(self, "_on_player_level_changed")
	if not GameEvents.player_level_changed.is_connected(player_level_callable):
		GameEvents.player_level_changed.connect(player_level_callable)
	var player_xp_callable: Callable = Callable(self, "_on_player_xp_changed")
	if not GameEvents.player_xp_changed.is_connected(player_xp_callable):
		GameEvents.player_xp_changed.connect(player_xp_callable)
	var level_changed_callable: Callable = Callable(self, "_on_player_level_changed")
	if not GameEvents.level_changed.is_connected(level_changed_callable):
		GameEvents.level_changed.connect(level_changed_callable)
	var xp_changed_callable: Callable = Callable(self, "_on_player_xp_changed")
	if not GameEvents.xp_changed.is_connected(xp_changed_callable):
		GameEvents.xp_changed.connect(xp_changed_callable)
	var tokens_changed_callable: Callable = Callable(self, "_on_tokens_changed")
	if not GameEvents.tokens_changed.is_connected(tokens_changed_callable):
		GameEvents.tokens_changed.connect(tokens_changed_callable)
	var scars_updated_callable: Callable = Callable(self, "_on_scars_updated")
	if GameEvents.has_signal("scars_updated") and not GameEvents.scars_updated.is_connected(scars_updated_callable):
		GameEvents.scars_updated.connect(scars_updated_callable)
	var scar_applied_callable: Callable = Callable(self, "_on_scar_applied")
	if GameEvents.has_signal("scar_applied") and not GameEvents.scar_applied.is_connected(scar_applied_callable):
		GameEvents.scar_applied.connect(scar_applied_callable)
	_ensure_token_icons()
	_refresh_progression_ui()
	_refresh_scars_ui([])

	_wire_buy_token_button()
	_refresh_buy_token_ui()
	_try_load_sfx_streams()

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

	if debug_overlay != null:
		debug_overlay.visible = false
	if debug_tools_panel != null:
		debug_tools_panel.visible = OS.is_debug_build()
		_wire_debug_tools()
	if level_up_popup != null:
		level_up_popup.visible = false
	if scar_popup != null:
		scar_popup.visible = false
	if arena_resolution_label != null:
		arena_resolution_label.visible = false

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
	_wire_push_luck_buttons()

	var arena: Node = get_tree().get_first_node_in_group("arena")
	if arena != null and arena.has_signal("player_spawned"):
		var arena_player_callable: Callable = Callable(self, "_on_player_spawned")
		if not arena.player_spawned.is_connected(arena_player_callable):
			arena.player_spawned.connect(arena_player_callable)
		if arena.has_signal("enemy_spawned"):
			var enemy_spawn_callable: Callable = Callable(self, "_on_enemy_spawned")
			if not arena.enemy_spawned.is_connected(enemy_spawn_callable):
				arena.enemy_spawned.connect(enemy_spawn_callable)
		if arena.has_signal("enemy_despawned"):
			var enemy_despawn_callable: Callable = Callable(self, "_on_enemy_despawned")
			if not arena.enemy_despawned.is_connected(enemy_despawn_callable):
				arena.enemy_despawned.connect(enemy_despawn_callable)
		_sync_enemy_bars()

	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null:
		_bind_player(p)

	print("UI ready: coins=%s bet_panel=%s debug=%s" % [coins_label != null, bet_panel != null, debug_overlay != null])

func _validate_ui_boot() -> bool:
	var errors: Array[String] = []
	if get_node_or_null("Modals/BettingCircle") == null and not ResourceLoader.exists(BETTING_CIRCLE_SCENE_PATH):
		push_error("SANITY FAIL UI: BetCircle missing")
		return false
	if sfx_level_up_path != "" and not ResourceLoader.exists(sfx_level_up_path):
		errors.append("missing resource at %s" % sfx_level_up_path)
	if sfx_buy_token_path != "" and not ResourceLoader.exists(sfx_buy_token_path):
		errors.append("missing resource at %s" % sfx_buy_token_path)
	var required_nodes: Array[String] = [
		"Modals/BetModal",
		"Modals/ResolveRitualModal",
		"Modals/PushLuckModal",
		"Modals/PushLuckModal/PushLuckPanel",
		"Modals/GameOverModal",
		"Modals/GameOverModal/GameOverPanel",
		"Modals/BetModal/BetPanel/BetScroll/BetVBox/BetButtons",
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

func _sync_enemy_bars() -> void:
	if enemy_bars == null:
		return
	for enemy_node: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy_node is Node2D:
			_ensure_enemy_bar(enemy_node)

func _on_enemy_spawned(enemy: Node2D) -> void:
	_ensure_enemy_bar(enemy)

func _on_enemy_despawned(enemy: Node2D) -> void:
	_remove_enemy_bar(enemy)

func _on_enemy_tree_exited(enemy: Node2D) -> void:
	_remove_enemy_bar(enemy)

func _ensure_enemy_bar(enemy: Node2D) -> void:
	if enemy_bars == null:
		return
	if _enemy_bar_nodes.has(enemy):
		return
	var bar: Control = _enemy_bar_scene.instantiate() as Control
	if bar == null:
		return
	enemy_bars.add_child(bar)
	var anchor: Node2D = _get_enemy_anchor(enemy)
	if bar.has_method("set_target"):
		bar.call("set_target", enemy, anchor)
	if enemy.has_signal("health_changed") and bar.has_method("set_health"):
		var health_callable: Callable = Callable(bar, "set_health")
		if not enemy.health_changed.is_connected(health_callable):
			enemy.health_changed.connect(health_callable)
	if enemy.has_method("get_health") and bar.has_method("set_health"):
		var health: Array = enemy.call("get_health") as Array
		if health.size() >= 2:
			bar.call("set_health", int(health[0]), int(health[1]))
	_enemy_bar_nodes[enemy] = bar
	var exit_callable: Callable = Callable(self, "_on_enemy_tree_exited").bind(enemy)
	if not enemy.tree_exited.is_connected(exit_callable):
		enemy.tree_exited.connect(exit_callable)

func _remove_enemy_bar(enemy: Node2D) -> void:
	if not _enemy_bar_nodes.has(enemy):
		return
	var bar: Control = _enemy_bar_nodes[enemy] as Control
	_enemy_bar_nodes.erase(enemy)
	if bar != null and is_instance_valid(bar):
		bar.queue_free()

func _get_enemy_anchor(enemy: Node2D) -> Node2D:
	var anchor: Node2D = enemy.get_node_or_null("HpAnchor") as Node2D
	if anchor != null:
		return anchor
	return enemy

func _on_player_level_changed(level: int) -> void:
	_level = maxi(level, 1)
	if level_label != null:
		level_label.text = "Level: %d" % _level
	if _level > _last_level:
		_show_level_up_popup("+1 TOKEN")
		_play_sfx(sfx_level_up)
	_last_level = _level

func _on_player_xp_changed(xp: int, xp_to_next: int) -> void:
	_animate_xp_bar(xp, xp_to_next)
	if xp_label != null:
		xp_label.text = "XP: %d/%d" % [xp, xp_to_next]

func _on_tokens_changed(tokens: int) -> void:
	_tokens = maxi(tokens, 0)
	if tokens_label != null:
		tokens_label.text = "Tokens: %d" % _tokens
	_last_tokens = _tokens
	_refresh_buy_token_ui()

func _refresh_progression_ui() -> void:
	if level_label != null:
		level_label.text = "Level: %d" % _level
	if tokens_label != null:
		tokens_label.text = "Tokens: %d" % _tokens
	if xp_bar != null:
		xp_bar.max_value = float(maxi(_xp_to_next, 1))
	if xp_label != null:
		xp_label.text = "XP: %d/%d" % [_xp_current, _xp_to_next]

func _wire_buy_token_button() -> void:
	if buy_token_button == null:
		return
	var buy_token_callable: Callable = Callable(self, "_on_buy_token_pressed")
	if not buy_token_button.pressed.is_connected(buy_token_callable):
		buy_token_button.pressed.connect(buy_token_callable)

func _wire_seed_input() -> void:
	if seed_apply_button == null:
		return
	var seed_callable: Callable = Callable(self, "_on_seed_apply_pressed")
	if not seed_apply_button.pressed.is_connected(seed_callable):
		seed_apply_button.pressed.connect(seed_callable)

func _refresh_buy_token_ui() -> void:
	if buy_token_button == null:
		return
	var manager: Node = _get_run_manager()
	if manager == null:
		buy_token_button.disabled = true
		buy_token_button.text = "BUY TOKEN"
		if buy_token_info != null:
			buy_token_info.text = "-"
		if buy_token_note != null:
			buy_token_note.visible = false
		return

	var cost: int = 100
	if manager.has_method("get_token_buy_cost"):
		cost = int(manager.call("get_token_buy_cost"))
	elif manager.has_method("get_buy_token_cost"):
		cost = int(manager.call("get_buy_token_cost"))
	elif manager.has_method("get_token_purchase_cost"):
		cost = int(manager.call("get_token_purchase_cost"))
	elif manager.has_variable("token_buy_cost"):
		cost = int(manager.get("token_buy_cost"))
	elif manager.has_variable("token_purchase_cost_coins"):
		cost = int(manager.get("token_purchase_cost_coins"))

	var coins: int = _coins
	if manager.has_method("get_coins"):
		coins = int(manager.call("get_coins"))

	buy_token_button.text = "BUY TOKEN (%dc)" % cost
	var disabled: bool = coins < cost
	buy_token_button.disabled = disabled
	if buy_token_info != null:
		buy_token_info.text = "Coins: %d" % coins
	if buy_token_note != null:
		if disabled:
			buy_token_note.text = "Disponibile con %dc." % cost
			buy_token_note.visible = true
		else:
			buy_token_note.visible = false

func _animate_xp_bar(xp: int, xp_to_next: int) -> void:
	if xp_bar == null:
		return
	_xp_current = maxi(xp, 0)
	_xp_to_next = maxi(xp_to_next, 1)
	var maxv: float = float(_xp_to_next)
	xp_bar.max_value = maxv

	var changed_curve: bool = xp_to_next != _last_xp_to_next and _last_xp_to_next != 0
	_last_xp_to_next = xp_to_next

	var target: float = float(clamp(_xp_current, 0, _xp_to_next))
	var current: float = float(xp_bar.value)

	_kill_xp_tweens()

	if target < current:
		_xp_anim_tween = create_tween()
		_xp_anim_tween.set_trans(Tween.TRANS_QUAD)
		_xp_anim_tween.set_ease(Tween.EASE_OUT)
		var anim_duration: float = 0.14
		if changed_curve:
			anim_duration = 0.10
		_xp_anim_tween.tween_property(xp_bar, "value", target, anim_duration)
		return

	_xp_anim_tween = create_tween()
	_xp_anim_tween.set_trans(Tween.TRANS_QUAD)
	_xp_anim_tween.set_ease(Tween.EASE_OUT)
	_xp_anim_tween.tween_property(xp_bar, "value", target, 0.18)

	_xp_punch_tween = create_tween()
	_xp_punch_tween.set_trans(Tween.TRANS_BACK)
	_xp_punch_tween.set_ease(Tween.EASE_OUT)
	_xp_punch_tween.tween_property(xp_bar, "scale", Vector2(1.02, 1.02), 0.08)
	_xp_punch_tween.tween_property(xp_bar, "scale", Vector2.ONE, 0.10)

func _kill_xp_tweens() -> void:
	if _xp_anim_tween != null and is_instance_valid(_xp_anim_tween):
		_xp_anim_tween.kill()
	_xp_anim_tween = null
	if _xp_punch_tween != null and is_instance_valid(_xp_punch_tween):
		_xp_punch_tween.kill()
	_xp_punch_tween = null

func _try_load_sfx_streams() -> void:
	_safe_assign_stream(sfx_level_up, sfx_level_up_path)
	_safe_assign_stream(sfx_buy_token, sfx_buy_token_path)

func _safe_assign_stream(player: AudioStreamPlayer, path: String) -> void:
	if player == null:
		return
	if path == "":
		return
	if ResourceLoader.exists(path):
		var stream: Resource = load(path)
		if stream is AudioStream:
			player.stream = stream

func _play_sfx(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	player.stop()
	player.play()

func _show_level_up_popup(suffix: String) -> void:
	if level_up_popup == null:
		return
	level_up_popup.visible = true
	level_up_popup.text = "LEVEL UP! %s" % suffix
	level_up_popup.modulate.a = 0.0
	level_up_popup.scale = Vector2(0.92, 0.92)
	if _popup_tween != null and _popup_tween.is_valid():
		_popup_tween.kill()
	_popup_tween = create_tween()
	_popup_tween.set_trans(Tween.TRANS_QUAD)
	_popup_tween.set_ease(Tween.EASE_OUT)
	_popup_tween.tween_property(level_up_popup, "modulate:a", 1.0, 0.12)
	_popup_tween.parallel().tween_property(level_up_popup, "scale", Vector2(1.02, 1.02), 0.12)
	_popup_tween.tween_interval(0.55)
	_popup_tween.set_ease(Tween.EASE_IN)
	_popup_tween.tween_property(level_up_popup, "modulate:a", 0.0, 0.20)
	_popup_tween.parallel().tween_property(level_up_popup, "scale", Vector2(0.98, 0.98), 0.20)
	_popup_tween.tween_callback(Callable(self, "_hide_level_up_popup"))

func _hide_level_up_popup() -> void:
	if level_up_popup != null:
		level_up_popup.visible = false

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
	scar_popup.visible = true
	scar_popup.modulate.a = 0.0
	scar_popup.scale = Vector2(0.96, 0.96)
	if _scar_popup_tween != null and _scar_popup_tween.is_valid():
		_scar_popup_tween.kill()
	_scar_popup_tween = create_tween()
	_scar_popup_tween.set_trans(Tween.TRANS_QUAD)
	_scar_popup_tween.set_ease(Tween.EASE_OUT)
	_scar_popup_tween.tween_property(scar_popup, "modulate:a", 1.0, 0.15)
	_scar_popup_tween.parallel().tween_property(scar_popup, "scale", Vector2(1.02, 1.02), 0.15)
	_scar_popup_tween.tween_interval(1.0)
	_scar_popup_tween.set_ease(Tween.EASE_IN)
	_scar_popup_tween.tween_property(scar_popup, "modulate:a", 0.0, 0.25)
	_scar_popup_tween.parallel().tween_property(scar_popup, "scale", Vector2(0.98, 0.98), 0.25)
	_scar_popup_tween.tween_callback(Callable(self, "_hide_scar_popup"))

func _hide_scar_popup() -> void:
	if scar_popup != null:
		scar_popup.visible = false

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

func _on_buy_token_pressed() -> void:
	if GameEvents.has_signal("request_purchase_token"):
		GameEvents.request_purchase_token.emit()

func _on_seed_apply_pressed() -> void:
	if seed_input == null:
		return
	var text_value: String = seed_input.text.strip_edges()
	if text_value == "":
		if GameEvents.has_signal("request_clear_run_seed"):
			GameEvents.request_clear_run_seed.emit()
		return
	if not text_value.is_valid_int():
		return
	var seed_value: int = int(text_value)
	if GameEvents.has_signal("request_set_run_seed"):
		GameEvents.request_set_run_seed.emit(seed_value)

func _ensure_token_icons() -> void:
	if coins_icon != null and coins_icon.texture == null:
		coins_icon.texture = _make_solid_icon(Color(1.0, 0.85, 0.25, 1.0))
	if tokens_icon != null and tokens_icon.texture == null:
		tokens_icon.texture = _make_solid_icon(Color(0.55, 0.85, 1.0, 1.0))

func _make_solid_icon(c: Color) -> Texture2D:
	var image: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(c)
	for x in range(8):
		image.set_pixel(x, 0, Color(0, 0, 0, 1))
		image.set_pixel(x, 7, Color(0, 0, 0, 1))
	for y in range(8):
		image.set_pixel(0, y, Color(0, 0, 0, 1))
		image.set_pixel(7, y, Color(0, 0, 0, 1))
	return ImageTexture.create_from_image(image)

func show_countdown(seconds: int = 3) -> void:
	if countdown_label == null:
		return
	countdown_label.visible = true
	for i in range(seconds, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO"
	await get_tree().create_timer(0.5).timeout
	countdown_label.visible = false

func _on_run_started() -> void:
	if coins_label != null:
		coins_label.text = "Coins: 0"
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	_set_bet_modal(false)
	_reset_bet_confirmation()
	_reset_bet_confirmation()
	if level_up_popup != null:
		level_up_popup.visible = false
	_refresh_buy_token_ui()
	# IMPORTANT: if the player picked FAST, we must keep the FAST timer state into the round.
	# countdown_requested will drive the actual seconds during the round.
	if not _fast_countdown_active:
		_reset_fast_countdown()
	else:
		if fast_countdown_label != null:
			fast_countdown_label.visible = true
			fast_countdown_label.text = "FAST: %ds" % FAST_SELECTION_SECONDS
			fast_countdown_label.modulate.a = 1.0
	_set_push_luck_modal(false)
	_pending_bets = []
	_set_game_over_modal(false)
	if next_bet_button != null:
		next_bet_button.visible = true
	_last_finale_title = "RUN FAILED"
	_last_finale_text = ""
	_last_finale_scars = []
	_last_finale_ending_id = ""
	_last_finale_seed = 0
	_last_finale_stats = {}
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
	_last_level = 1
	_last_tokens = 0
	_last_xp_to_next = 0
	_kill_xp_tweens()
	_xp_current = 0
	if xp_bar != null:
		xp_bar.value = 0
	_refresh_buy_token_ui()
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node != null:
		_bind_player(player_node)

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
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	if game_over_title != null:
		game_over_title.text = _last_finale_title
	if game_over_epilogue != null:
		game_over_epilogue.text = _last_finale_text

func _on_run_failed() -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	_set_bet_modal(false)
	if level_up_popup != null:
		level_up_popup.visible = false
	if special_arena_label != null:
		special_arena_label.visible = false
	if condanna_focus_label != null:
		condanna_focus_label.visible = false
	_reset_fast_countdown()
	_set_push_luck_modal(false)
	_set_game_over_modal(true)
	if next_bet_button != null:
		next_bet_button.visible = false
	if game_over_title != null:
		game_over_title.text = _last_finale_title
	if game_over_epilogue != null:
		game_over_epilogue.text = _last_finale_text
	_refresh_game_over_scars()
	_refresh_game_over_meta()
	if game_over_hint != null:
		game_over_hint.text = "Vuoi riprovare?"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
	_reset_fast_countdown()
	_refresh_modal_dimmer()
	_hide_scars_detail()

func _on_run_debug_state_updated(payload: Dictionary) -> void:
	_debug_seed = int(payload.get("seed", 0))
	_debug_arena_index = int(payload.get("arena_index", 0))
	_debug_escalation = int(payload.get("escalation_level", 0))
	_debug_active_bet = str(payload.get("active_bet_id", ""))
	_debug_enemy_profile = str(payload.get("enemy_profile", ""))
	_debug_special_arena = str(payload.get("special_arena_id", ""))
	var scars_value: Array = payload.get("scars", []) as Array
	_debug_scars = []
	for scar_value in scars_value:
		_debug_scars.append(str(scar_value))
	if seed_label != null:
		seed_label.text = "Seed: %d" % _debug_seed
	_refresh_debug_overlay()

func _on_run_log_ready(log_text: String) -> void:
	_debug_run_log = log_text

func _on_special_arena_started(payload: Dictionary) -> void:
	_special_arena_payload = payload.duplicate(true)
	if bet_panel != null and bet_panel.visible:
		_update_special_arena_ui()

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
	_refresh_buy_token_ui()

func _on_bet_placed(bet_id: String, _stake: int, _odds: float) -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: %s" % _get_bet_name(bet_id)

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
	_refresh_buy_token_ui()
	_refresh_modal_dimmer()

func _on_bet_ui_closed() -> void:
	_set_bet_modal(false)
	if betting_circle != null:
		betting_circle.close()
	_reset_bet_confirmation()
	if special_arena_label != null:
		special_arena_label.visible = false
	if condanna_focus_label != null:
		condanna_focus_label.visible = false

func _on_pact_sealed_opened() -> void:
	if pact_sealed_title != null:
		pact_sealed_title.text = "IL PATTO È SIGILLATO."
	if pact_sealed_subtitle != null:
		pact_sealed_subtitle.text = "La folla trattiene il fiato."
	_set_pact_sealed_modal(true)
	_refresh_modal_dimmer()

func _on_pact_sealed_closed() -> void:
	_set_pact_sealed_modal(false)
	_refresh_modal_dimmer()

func _on_resolve_ritual_opened(payload: Dictionary) -> void:
	if resolve_ritual_title != null:
		resolve_ritual_title.text = "RITO DI GIUDIZIO"
	if resolve_ritual_subtitle != null:
		var doom_short: String = str(payload.get("doom_short", ""))
		if doom_short == "":
			resolve_ritual_subtitle.text = "CONDANNA: giudizio imminente."
		else:
			resolve_ritual_subtitle.text = "CONDANNA: %s" % doom_short
	_set_resolve_ritual_modal(true)
	_refresh_modal_dimmer()

func _on_resolve_ritual_closed() -> void:
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
		scars_panel.visible = true
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
	scars_detail_panel.visible = true
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
	if game_over_scars == null:
		return
	if _last_finale_scars.is_empty():
		game_over_scars.text = ""
		game_over_scars.visible = false
		return
	var lines: Array[String] = []
	lines.append("Cicatrici rilevanti:")
	for scar_value: Dictionary in _last_finale_scars:
		var scar: Dictionary = scar_value as Dictionary
		var scar_name: String = "Cicatrice"
		if scar.has("name"):
			scar_name = str(scar["name"])
		lines.append("• %s" % scar_name)
	game_over_scars.text = "\n".join(lines)
	game_over_scars.visible = true

func _refresh_game_over_meta() -> void:
	if game_over_meta == null:
		return
	var lines: Array[String] = []
	if _last_finale_ending_id != "":
		lines.append("Ending ID: %s" % _last_finale_ending_id)
	if _last_finale_ending_id != "" or _last_finale_seed != 0:
		lines.append("Seed: %d" % _last_finale_seed)
	if not _last_finale_stats.is_empty():
		var cashouts: int = int(_last_finale_stats.get("cashouts", 0))
		var doubles: int = int(_last_finale_stats.get("doubles", 0))
		var max_escalation: int = int(_last_finale_stats.get("max_escalation", 0))
		var arena_target: int = int(_last_finale_stats.get("arena_target", 0))
		var arena_count: int = int(_last_finale_stats.get("arena_count", 0))
		var scar_count: int = _last_finale_scars.size()
		lines.append("Hai affrontato %d arene, hai raddoppiato %d volte e hai scelto di incassare %d volte." % [
			arena_count,
			doubles,
			cashouts,
		])
		lines.append("Arene: %d" % arena_count)
		lines.append("Raddoppi: %d" % doubles)
		lines.append("Incassi: %d" % cashouts)
		lines.append("Cicatrici: %d" % scar_count)
		lines.append("Escalation max: %d" % max_escalation)
		if arena_target > 0:
			lines.append("Arene: %d/%d" % [arena_count, arena_target])
		var bet_list: Array = _last_finale_stats.get("bets", []) as Array
		if not bet_list.is_empty():
			var bet_names: Array[String] = []
			for bet_name_value in bet_list:
				bet_names.append(str(bet_name_value))
			lines.append("Bets: %s" % ", ".join(bet_names))
	if lines.is_empty():
		game_over_meta.text = ""
		game_over_meta.visible = false
		return
	game_over_meta.text = "\n".join(lines)
	game_over_meta.visible = true

func _on_push_luck_opened(payload: Dictionary) -> void:
	if push_luck_panel == null:
		return
	_set_bet_modal(false)
	var bet_name: String = str(payload.get("bet_name", ""))
	if push_luck_title != null:
		push_luck_title.text = "PUSH YOUR LUCK — %s" % bet_name
	if push_luck_info != null:
		push_luck_info.text = "La folla vuole di più. Puoi incassare… o rilanciare."
	var doom_text: String = str(payload.get("next_doom", ""))
	var condition_text: String = str(payload.get("condition", ""))
	var pact_text: String = str(payload.get("next_pact", ""))
	var cashout_locked: bool = bool(payload.get("cashout_locked", false))
	var cashout_reason: String = str(payload.get("cashout_lock_reason", ""))
	var double_locked: bool = bool(payload.get("double_locked", false))
	var double_reason: String = str(payload.get("double_lock_reason", ""))
	var lines: Array[String] = []
	if doom_text != "":
		lines.append("❌ Condanna futura: %s" % doom_text)
	if condition_text != "":
		lines.append("⚠️ Condizione: %s" % condition_text)
	if pact_text != "":
		lines.append("✅ Patto potenziato: %s" % pact_text)
	if cashout_locked and cashout_reason != "":
		lines.append("⛔ Incasso bloccato: %s" % cashout_reason)
	if double_locked and double_reason != "":
		lines.append("⛔ Raddoppio bloccato: %s" % double_reason)
	if push_luck_details != null:
		push_luck_details.text = "\n".join(lines)
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

func _on_push_luck_closed() -> void:
	_set_push_luck_modal(false)

func _wire_push_luck_buttons() -> void:
	if push_luck_cashout_button != null:
		var cashout_callable: Callable = Callable(self, "_on_push_luck_cashout_pressed")
		if not push_luck_cashout_button.pressed.is_connected(cashout_callable):
			push_luck_cashout_button.pressed.connect(cashout_callable)
	if push_luck_double_button != null:
		var double_callable: Callable = Callable(self, "_on_push_luck_double_pressed")
		if not push_luck_double_button.pressed.is_connected(double_callable):
			push_luck_double_button.pressed.connect(double_callable)

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
	if GameEvents.has_signal("request_push_luck_cashout"):
		GameEvents.request_push_luck_cashout.emit()

func _on_push_luck_double_pressed() -> void:
	if GameEvents.has_signal("request_push_luck_double"):
		GameEvents.request_push_luck_double.emit()

func _on_bet_win_pressed() -> void:
	_place_bet("DOUBLE_OR_DIE")

func _on_bet_no_hit_pressed() -> void:
	_place_bet("FLAWLESS_BLOOD")

func _on_bet_fast_pressed() -> void:
	_place_bet("CASH_OUT")

func _on_restart_pressed() -> void:
	_request_reset()

func _on_retry_pressed() -> void:
	_request_retry()

func _request_reset() -> void:
	_set_game_over_modal(false)

	if GameEvents.has_signal("request_reset_run"):
		GameEvents.request_reset_run.emit()
	_hide_scars_detail()
	_refresh_modal_dimmer()

func _request_next_bet() -> void:
	if game_over_panel != null and game_over_panel.visible:
		return

	if GameEvents.has_signal("request_next_bet"):
		GameEvents.request_next_bet.emit()

func _request_retry() -> void:
	_set_game_over_modal(false)
	if GameEvents.has_signal("request_retry_run"):
		GameEvents.request_retry_run.emit()
	_hide_scars_detail()
	_refresh_modal_dimmer()

func _on_quit_pressed() -> void:
	get_tree().quit()

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
		return
	if seconds <= 0:
		_reset_fast_countdown()
		return
	fast_countdown_label.visible = true
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

func _create_bet_button(bet_id: String, bet: Dictionary, extra_note: String) -> Button:
	var button: Button = Button.new()
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
	var lines: Array[String] = []
	if doom_text != "":
		lines.append("❌ Condanna — %s" % name_text)
		lines.append("%s" % doom_text)
	else:
		lines.append("❌ Condanna — %s" % name_text)
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
	if game_over_title != null:
		game_over_title.text = "RUN FAILED"
		if can_retry:
			game_over_title.text = "BET FAILED"
	if game_over_epilogue != null:
		game_over_epilogue.text = ""
	_last_finale_text = ""
	_last_finale_scars = []
	_refresh_game_over_scars()
	if game_over_hint != null:
		game_over_hint.text = "Vuoi riprovare?"
		if can_retry:
			game_over_hint.text = "Riprova la scommessa?"
	if next_bet_button != null:
		next_bet_button.visible = can_retry
		next_bet_button.text = "RETRY BET"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
	_reset_fast_countdown()

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
	if _pending_confirm_bet_id == "":
		return
	_place_bet(_pending_confirm_bet_id)

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
		tween.tween_property(panel, "modulate:a", 1.0, MODAL_FADE_SECONDS)
	else:
		if not panel.visible:
			modal.visible = false
			return tween
		tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(panel, "modulate:a", 0.0, MODAL_FADE_SECONDS)
		tween.tween_callback(Callable(self, "_on_modal_fade_out_complete").bind(panel, modal))
	return tween

func _on_modal_fade_out_complete(panel: CanvasItem, modal: Control) -> void:
	if panel != null:
		panel.visible = false
		panel.modulate.a = 1.0
	if modal != null:
		modal.visible = false
	_refresh_modal_dimmer()

func _set_bet_modal(active: bool) -> void:
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
	_resolve_ritual_modal_fade_tween = _fade_modal(resolve_ritual_panel, resolve_ritual_modal, active, _resolve_ritual_modal_fade_tween)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("resolve_ritual")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("resolve_ritual")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _set_push_luck_modal(active: bool) -> void:
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
	_game_over_modal_fade_tween = _fade_modal(game_over_panel, game_over_modal, active, _game_over_modal_fade_tween)
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("ending")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("ending")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _reset_bet_confirmation() -> void:
	_pending_confirm_bet_id = ""
	if bet_confirm_label != null:
		bet_confirm_label.text = "Selezione: -"
	if bet_confirm_row != null:
		bet_confirm_row.visible = false

func _refresh_modal_dimmer() -> void:
	if modal_dimmer == null:
		return
	var active: bool = false
	if bet_modal != null and bet_modal.visible:
		active = true
	if betting_circle != null and betting_circle.visible:
		active = true
	if pact_sealed_modal != null and pact_sealed_modal.visible:
		active = true
	if resolve_ritual_modal != null and resolve_ritual_modal.visible:
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
	circle.visible = true
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

func _refresh_debug_overlay() -> void:
	if debug_overlay == null:
		return
	var scars_text: String = "-"
	if _debug_scars.size() > 0:
		scars_text = ", ".join(_debug_scars)
	debug_overlay.text = "Seed: %d\nArena: %d\nEscalation: %d\nEnemy: %s\nActive Bet: %s\nScars: [%s]" % [
		_debug_seed,
		_debug_arena_index,
		_debug_escalation,
		_debug_enemy_profile,
		_debug_active_bet,
		scars_text
	]
	if _debug_special_arena != "":
		debug_overlay.text += "\nSpecial: %s" % _debug_special_arena

func _process(_delta: float) -> void:
	if debug_overlay == null or not debug_overlay.visible:
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
		if event.keycode == KEY_F1:
			if debug_overlay != null:
				debug_overlay.visible = not debug_overlay.visible
				_refresh_debug_overlay()
		if OS.is_debug_build():
			if event.keycode == KEY_F2:
				DisplayServer.clipboard_set(str(_debug_seed))
			if event.keycode == KEY_F3:
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

func _is_bet_active() -> bool:
	var manager: Node = _get_bet_manager()
	if manager and manager.has_method("is_bet_active"):
		return manager.is_bet_active()
	return false

func _get_bet_manager() -> Node:
	if _bet_manager and is_instance_valid(_bet_manager):
		return _bet_manager
	_bet_manager = get_tree().get_first_node_in_group("bet_manager")
	return _bet_manager
