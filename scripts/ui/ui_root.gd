extends CanvasLayer

const FAST_SELECTION_SECONDS := 12
const UPGRADE_FLASH_TIME := 0.10

@onready var coins_label: Label = get_node_or_null("HUD/Panel/VBox/CoinsRow/CoinsLabel") as Label
@onready var tokens_label: Label = get_node_or_null("HUD/Panel/VBox/TokensRow/TokensLabel") as Label
@onready var level_label: Label = get_node_or_null("HUD/Panel/VBox/LevelLabel") as Label
@onready var bet_info_label: Label = get_node_or_null("HUD/Panel/VBox/BetInfoLabel") as Label
@onready var xp_bar: ProgressBar = get_node_or_null("HUD/Panel/VBox/XPBar") as ProgressBar
@onready var xp_label: Label = get_node_or_null("HUD/Panel/VBox/XPLabel") as Label
@onready var player_hp_bar: ProgressBar = $HUD/Panel/VBox/PlayerHPBar
@onready var player_hp_label: Label = $HUD/Panel/VBox/PlayerHPLabel
@onready var bet_panel: Panel = _req("HUD/BetPanel") as Panel
@onready var buy_token_button: Button = get_node_or_null("HUD/BetPanel/BetVBox/BuyTokenRow/BuyTokenButton") as Button
@onready var buy_token_info: Label = get_node_or_null("HUD/BetPanel/BetVBox/BuyTokenRow/BuyTokenInfo") as Label
@onready var coins_icon: TextureRect = get_node_or_null("HUD/Panel/VBox/CoinsRow/CoinIcon") as TextureRect
@onready var tokens_icon: TextureRect = get_node_or_null("HUD/Panel/VBox/TokensRow/TokenIcon") as TextureRect
@onready var modal_dimmer: ColorRect = get_node_or_null("HUD/ModalDimmer") as ColorRect
@onready var upgrade_panel: Panel = get_node_or_null("HUD/UpgradePanel") as Panel
@onready var upgrade_root: Control = get_node_or_null("HUD/UpgradePanel") as Control
@onready var upgrade_bg: TextureRect = get_node_or_null("HUD/UpgradePanel/UpgradeBG") as TextureRect
@onready var upgrade_content_area: Control = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea") as Control
@onready var upgrade_vbox: VBoxContainer = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox") as VBoxContainer
@onready var upgrade_tokens_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeCoinsLabel") as Label
@onready var upgrade_hp_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeHPRow/UpgradeHPRowHBox/UpgradeHPLabel") as Label
@onready var upgrade_light_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeLightRow/UpgradeLightRowHBox/UpgradeLightLabel") as Label
@onready var upgrade_heavy_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeHeavyRow/UpgradeHeavyRowHBox/UpgradeHeavyLabel") as Label
@onready var upgrade_hp_row: Control = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeHPRow") as Control
@onready var upgrade_light_row: Control = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeLightRow") as Control
@onready var upgrade_heavy_row: Control = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeHeavyRow") as Control
@onready var upgrade_hp_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeHPRow/UpgradeHPRowHBox/UpgradeHPButton") as Button
@onready var upgrade_light_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeLightRow/UpgradeLightRowHBox/UpgradeLightButton") as Button
@onready var upgrade_heavy_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeRows/UpgradeHeavyRow/UpgradeHeavyRowHBox/UpgradeHeavyButton") as Button
@onready var upgrade_continue_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeContentArea/UpgradeVBox/UpgradeContinueButton") as Button
@onready var stake_input: SpinBox = _req("HUD/BetPanel/BetVBox/StakeRow/StakeInput") as SpinBox
@onready var bet_win_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetWinButton") as Button
@onready var bet_no_hit_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetNoHitButton") as Button
@onready var bet_fast_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetFastButton") as Button
@onready var debug_overlay: Label = get_node_or_null("HUD/DebugOverlay") as Label
@onready var level_up_popup: Label = get_node_or_null("HUD/LevelUpPopup") as Label
@onready var sfx_level_up: AudioStreamPlayer = get_node_or_null("SFX/SfxLevelUp") as AudioStreamPlayer
@onready var sfx_buy_token: AudioStreamPlayer = get_node_or_null("SFX/SfxBuyToken") as AudioStreamPlayer
@onready var sfx_upgrade_buy: AudioStreamPlayer = get_node_or_null("SFX/SfxUpgradeBuy") as AudioStreamPlayer
@onready var game_over_panel: Panel = $HUD/GameOverPanel
@onready var game_over_title: Label = get_node_or_null("HUD/GameOverPanel/GameOverVBox/GameOverTitle") as Label
@onready var game_over_hint: Label = get_node_or_null("HUD/GameOverPanel/GameOverVBox/GameOverHint") as Label
@onready var restart_button: Button = $HUD/GameOverPanel/GameOverVBox/RestartButton
@onready var next_bet_button: Button = $HUD/GameOverPanel/GameOverVBox/NextBetButton
@onready var quit_button: Button = $HUD/GameOverPanel/GameOverVBox/QuitButton
@onready var controls_hint_panel: Panel = $HUD/ControlsHintPanel
@onready var countdown_label: Label = get_node_or_null("HUD/CountdownLabel") as Label
@onready var fast_countdown_label: Label = get_node_or_null("HUD/FastCountdownLabel") as Label
@onready var fast_blink_timer: Timer = get_node_or_null("HUD/FastBlinkTimer") as Timer

@export var sfx_level_up_path: String = "res://assets/audio/ui/level_up.ogg"
@export var sfx_buy_token_path: String = "res://assets/audio/ui/buy_token.ogg"
@export var sfx_upgrade_buy_path: String = "res://assets/audio/ui/upgrade_buy.ogg"

var _bets_by_id: Dictionary = {}
var _bet_manager: Node
var _run_manager: Node
var _arena: Node
var _player: Node = null
var _has_seen_controls: bool = false
var _fast_countdown_active: bool = false
var _selected_bet_id: String = ""
var _pending_bets: Array = []
var _upgrade_modal_active: bool = false
var _controls_hint_was_visible: bool = false
var _countdown_was_visible: bool = false
var _fast_countdown_was_visible: bool = false
var _fast_blink_was_running: bool = false
var _xp_current: int = 0
var _xp_to_next: int = 6
var _level: int = 1
var _tokens: int = 0
var _coins: int = 0
var _popup_tween: Tween = null
var _last_level: int = 1
var _last_tokens: int = 0
var _xp_anim_tween: Tween
var _xp_punch_tween: Tween
var _last_xp_to_next: int = 0

func _ready() -> void:
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.run_started.connect(_on_run_started_ui)
	GameEvents.run_failed.connect(_on_run_failed)
	GameEvents.bet_failed.connect(_on_bet_failed)
	GameEvents.run_started.connect(_on_run_started_controls)
	GameEvents.run_failed.connect(_on_run_failed_controls)
	GameEvents.bet_ui_opened.connect(_on_bet_ui_opened)
	GameEvents.bet_ui_closed.connect(_on_bet_ui_closed)
	GameEvents.betting_opened.connect(_on_betting_opened)
	GameEvents.countdown_requested.connect(_on_countdown_requested)
	GameEvents.coins_changed.connect(_on_ui_coins_refresh_upgrade)
	GameEvents.player_level_changed.connect(_on_player_level_changed)
	GameEvents.player_xp_changed.connect(_on_player_xp_changed)
	GameEvents.level_changed.connect(_on_player_level_changed)
	GameEvents.xp_changed.connect(_on_player_xp_changed)
	GameEvents.upgrade_tokens_changed.connect(_on_upgrade_tokens_changed)
	GameEvents.tokens_changed.connect(_on_tokens_changed)
	_ensure_token_icons()
	_refresh_progression_ui()

	_wire_buy_token_button()
	_refresh_buy_token_ui()
	_wire_upgrade_buttons()
	_try_load_sfx_streams()
	_refresh_upgrade_shop_ui()

	if bet_panel == null:
		push_warning("Bet UI missing, disabling betting panel.")
	else:
		bet_panel.visible = false
		if stake_input == null or bet_win_button == null or bet_no_hit_button == null or bet_fast_button == null:
			push_warning("Bet UI nodes incomplete, disabling betting panel.")
			bet_panel.visible = false
		else:
			bet_win_button.pressed.connect(func() -> void: _place_bet("WIN"))
			bet_no_hit_button.pressed.connect(func() -> void: _place_bet("NO_HIT"))
			bet_fast_button.pressed.connect(func() -> void: _place_bet("FAST"))

	if debug_overlay != null:
		debug_overlay.visible = false
	if level_up_popup != null:
		level_up_popup.visible = false

	if fast_blink_timer != null:
		fast_blink_timer.timeout.connect(_on_fast_blink_tick)

	if restart_button != null:
		restart_button.pressed.connect(_on_restart_pressed)
	if next_bet_button != null:
		next_bet_button.pressed.connect(_on_retry_pressed)
	if quit_button != null:
		quit_button.pressed.connect(_on_quit_pressed)
	if upgrade_panel != null:
		upgrade_panel.visible = false
	if modal_dimmer != null:
		modal_dimmer.visible = false
	if upgrade_continue_button != null:
		upgrade_continue_button.pressed.connect(_on_upgrade_continue_pressed)
	_update_upgrade_costs()

	var arena: Node = get_tree().get_first_node_in_group("arena")
	if arena != null and arena.has_signal("player_spawned"):
		arena.player_spawned.connect(_on_player_spawned)

	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null:
		_bind_player(p)

	print("UI ready: coins=%s bet_panel=%s debug=%s" % [coins_label != null, bet_panel != null, debug_overlay != null])

func _on_ui_coins_refresh_upgrade(_coins: int) -> void:
	if upgrade_panel != null and upgrade_panel.visible:
		_update_upgrade_costs()

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
		xp_label.text = "XP: %d/%d" % [_xp_current, _xp_to_next]

func _on_upgrade_tokens_changed(tokens: int) -> void:
	_on_tokens_changed(tokens)

func _on_tokens_changed(tokens: int) -> void:
	_tokens = maxi(tokens, 0)
	if tokens_label != null:
		tokens_label.text = "Tokens: %d" % _tokens
	if upgrade_tokens_label != null:
		var coins := _coins
		var rm := _get_run_manager()
		if rm != null and rm.has_method("get_coins"):
			coins = int(rm.call("get_coins"))
		upgrade_tokens_label.text = "Coins: %d | Tokens: %d" % [coins, tokens]
	_last_tokens = _tokens
	_refresh_buy_token_ui()
	_refresh_upgrade_shop_ui()
	if upgrade_panel != null and upgrade_panel.visible:
		_update_upgrade_costs()

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
	if not buy_token_button.pressed.is_connected(_on_buy_token_pressed):
		buy_token_button.pressed.connect(_on_buy_token_pressed)

func _refresh_buy_token_ui() -> void:
	if buy_token_button == null:
		return
	var manager := _get_run_manager()
	if manager == null:
		buy_token_button.disabled = true
		buy_token_button.text = "BUY TOKEN"
		if buy_token_info != null:
			buy_token_info.text = "-"
		return

	var cost := 100
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

	var coins := _coins
	if manager.has_method("get_coins"):
		coins = int(manager.call("get_coins"))

	buy_token_button.text = "BUY TOKEN (%dc)" % cost
	buy_token_button.disabled = coins < cost
	if buy_token_info != null:
		buy_token_info.text = "Coins: %d" % coins

func _wire_upgrade_buttons() -> void:
	if upgrade_hp_button != null and not upgrade_hp_button.pressed.is_connected(_on_upgrade_hp_pressed):
		upgrade_hp_button.pressed.connect(_on_upgrade_hp_pressed)
	if upgrade_light_button != null and not upgrade_light_button.pressed.is_connected(_on_upgrade_light_pressed):
		upgrade_light_button.pressed.connect(_on_upgrade_light_pressed)
	if upgrade_heavy_button != null and not upgrade_heavy_button.pressed.is_connected(_on_upgrade_heavy_pressed):
		upgrade_heavy_button.pressed.connect(_on_upgrade_heavy_pressed)

func _on_upgrade_hp_pressed() -> void:
	_try_purchase_upgrade("hp")

func _on_upgrade_light_pressed() -> void:
	_try_purchase_upgrade("light")

func _on_upgrade_heavy_pressed() -> void:
	_try_purchase_upgrade("heavy")

func _try_purchase_upgrade(kind: String) -> void:
	_purchase_upgrade(kind)

func _refresh_upgrade_shop_ui() -> void:
	var rm := _get_run_manager()
	if rm == null or not rm.has_method("get_upgrade_offer"):
		return
	var offer: Dictionary = rm.call("get_upgrade_offer")
	var tokens := int(offer.get("tokens", 0))
	if upgrade_tokens_label != null:
		var coins := _coins
		if rm.has_method("get_coins"):
			coins = int(rm.call("get_coins"))
		upgrade_tokens_label.text = "Coins: %d | Tokens: %d" % [coins, tokens]
	var hp: Dictionary = offer.get("hp", {})
	var light: Dictionary = offer.get("light", {})
	var heavy: Dictionary = offer.get("heavy", {})

	if upgrade_hp_label != null:
		upgrade_hp_label.text = "HP +%d | Total: %d → %d | Cost: %dT" % [
			int(hp.get("add", 0)),
			int(hp.get("current_total", 0)),
			int(hp.get("next_total", 0)),
			int(hp.get("cost", 1)),
		]
	if upgrade_light_label != null:
		upgrade_light_label.text = "LIGHT +%d | Total: %d → %d | Cost: %dT" % [
			int(light.get("add", 0)),
			int(light.get("current_total", 0)),
			int(light.get("next_total", 0)),
			int(light.get("cost", 1)),
		]
	if upgrade_heavy_label != null:
		upgrade_heavy_label.text = "HEAVY +%d | Total: %d → %d | Cost: %dT" % [
			int(heavy.get("add", 0)),
			int(heavy.get("current_total", 0)),
			int(heavy.get("next_total", 0)),
			int(heavy.get("cost", 1)),
		]

	if upgrade_hp_button != null:
		upgrade_hp_button.disabled = not bool(hp.get("affordable", tokens >= int(hp.get("cost", 1))))
	if upgrade_light_button != null:
		upgrade_light_button.disabled = not bool(light.get("affordable", tokens >= int(light.get("cost", 1))))
	if upgrade_heavy_button != null:
		upgrade_heavy_button.disabled = not bool(heavy.get("affordable", tokens >= int(heavy.get("cost", 1))))

func _animate_xp_bar(xp: int, xp_to_next: int) -> void:
	if xp_bar == null:
		return
	_xp_current = maxi(xp, 0)
	_xp_to_next = maxi(xp_to_next, 1)
	var maxv := float(_xp_to_next)
	xp_bar.max_value = maxv

	var changed_curve := xp_to_next != _last_xp_to_next and _last_xp_to_next != 0
	_last_xp_to_next = xp_to_next

	var target := float(clamp(_xp_current, 0, _xp_to_next))
	var current := float(xp_bar.value)

	_kill_xp_tweens()

	if target < current:
		_xp_anim_tween = create_tween()
		_xp_anim_tween.set_trans(Tween.TRANS_QUAD)
		_xp_anim_tween.set_ease(Tween.EASE_OUT)
		var anim_duration := 0.14
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
	_safe_assign_stream(sfx_upgrade_buy, sfx_upgrade_buy_path)

func _safe_assign_stream(player: AudioStreamPlayer, path: String) -> void:
	if player == null:
		return
	if path == "":
		return
	if ResourceLoader.exists(path):
		var stream := load(path)
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

func _on_buy_token_pressed() -> void:
	var rm := _get_run_manager()
	if rm == null:
		return
	var ok := false
	if rm.has_method("purchase_token"):
		ok = bool(rm.call("purchase_token"))
	elif rm.has_method("buy_token"):
		ok = bool(rm.call("buy_token"))
	elif rm.has_method("purchaseToken"):
		ok = bool(rm.call("purchaseToken"))
	if ok:
		_show_level_up_popup("TOKEN +1")
		_play_sfx(sfx_buy_token)
	_refresh_buy_token_ui()
	_refresh_upgrade_shop_ui()

func _ensure_token_icons() -> void:
	if coins_icon != null and coins_icon.texture == null:
		coins_icon.texture = _make_solid_icon(Color(1.0, 0.85, 0.25, 1.0))
	if tokens_icon != null and tokens_icon.texture == null:
		tokens_icon.texture = _make_solid_icon(Color(0.55, 0.85, 1.0, 1.0))

func _make_solid_icon(c: Color) -> Texture2D:
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
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
	if bet_panel != null:
		bet_panel.visible = false
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
	if upgrade_panel != null:
		upgrade_panel.visible = false
	_set_upgrade_modal(false)
	_pending_bets = []
	if game_over_panel != null:
		game_over_panel.visible = false
	if next_bet_button != null:
		next_bet_button.visible = true
	if not _fast_countdown_active:
		_reset_fast_countdown()

func _on_run_started_ui() -> void:
	_last_level = 1
	_last_tokens = 0
	_last_xp_to_next = 0
	_kill_xp_tweens()
	_xp_current = 0
	if xp_bar != null:
		xp_bar.value = 0
	_refresh_buy_token_ui()
	_refresh_upgrade_shop_ui()
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node != null:
		_bind_player(player_node)

func _on_run_failed() -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	if bet_panel != null:
		bet_panel.visible = false
	if level_up_popup != null:
		level_up_popup.visible = false
	_reset_fast_countdown()
	if upgrade_panel != null:
		upgrade_panel.visible = false
	_set_upgrade_modal(false)
	if game_over_panel != null:
		game_over_panel.visible = true
	if next_bet_button != null:
		next_bet_button.visible = false
	if game_over_title != null:
		game_over_title.text = "RUN FAILED"
	if game_over_hint != null:
		game_over_hint.text = "Vuoi riprovare?"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
	_reset_fast_countdown()

func _on_betting_opened() -> void:
	if game_over_panel != null and game_over_panel.visible:
		if bet_panel != null:
			bet_panel.visible = false
		return
	var manager := _get_run_manager()
	if manager != null and manager.has_method("should_show_upgrade_shop") and manager.should_show_upgrade_shop():
		_show_upgrade_panel()

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
	if not _has_seen_controls:
		controls_hint_panel.visible = true
		_has_seen_controls = true
	else:
		controls_hint_panel.visible = false

func _on_run_failed_controls() -> void:
	if controls_hint_panel != null and _has_seen_controls:
		controls_hint_panel.visible = false

func _on_coins_changed(coins: int) -> void:
	if coins_label != null:
		coins_label.text = "Coins: %d" % coins
	_coins = coins
	if upgrade_tokens_label != null:
		upgrade_tokens_label.text = "Coins: %d | Tokens: %d" % [coins, _last_tokens]
	_refresh_buy_token_ui()
	_refresh_upgrade_shop_ui()

func _on_bet_placed(bet_id: String, stake: int, odds: float) -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: %s | %d @ %.2f" % [bet_id, stake, odds]

func _on_bet_ui_opened(bets: Array) -> void:
	if bet_panel == null:
		return
	if game_over_panel != null and game_over_panel.visible:
		return
	if upgrade_panel != null and upgrade_panel.visible:
		_pending_bets = bets
		return
	_bets_by_id.clear()
	for bet in bets:
		_bets_by_id[bet.get("id", "")] = bet
	_update_bet_buttons()
	bet_panel.visible = true
	_reset_fast_countdown()
	_refresh_buy_token_ui()
	_refresh_upgrade_shop_ui()

func _on_bet_ui_closed() -> void:
	if bet_panel != null:
		bet_panel.visible = false
	# If FAST was selected, keep the FAST countdown state for the round.
	# The label is driven by countdown_requested during the round.
	if not _fast_countdown_active:
		_reset_fast_countdown()
	get_viewport().gui_release_focus()

func _on_restart_pressed() -> void:
	_request_reset()

func _on_retry_pressed() -> void:
	_request_retry()

func _request_reset() -> void:
	if game_over_panel != null:
		game_over_panel.visible = false

	var rm: Node = get_tree().get_first_node_in_group("run_manager")
	if rm != null and rm.has_method("start_new_run"):
		rm.call("start_new_run")
	else:
		push_warning("RunManager not found or no restart method.")

func _request_next_bet() -> void:
	if game_over_panel != null and game_over_panel.visible:
		return

	var rm: Node = get_tree().get_first_node_in_group("run_manager")
	if rm != null and rm.has_method("start_next_bet_round"):
		rm.call("start_next_bet_round")
	else:
		push_warning("RunManager not found or no restart method.")

func _request_retry() -> void:
	if game_over_panel != null:
		game_over_panel.visible = false
	var rm: Node = get_tree().get_first_node_in_group("run_manager")
	if rm != null and rm.has_method("retry_current_bet"):
		rm.call("retry_current_bet")
	else:
		push_warning("RunManager not found or no retry method.")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_player_health_changed(current: int, max: int) -> void:
	player_hp_bar.max_value = max
	player_hp_bar.value = current
	player_hp_label.text = "HP: %d/%d" % [current, max]

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
	var next_alpha := 1.0
	if fast_countdown_label.modulate.a > 0.6:
		next_alpha = 0.2
	fast_countdown_label.modulate.a = next_alpha

func _on_player_spawned(p: Node) -> void:
	_bind_player(p)

func _bind_player(p: Node) -> void:
	if _player != null and _player.has_signal("health_changed"):
		if _player.health_changed.is_connected(_on_player_health_changed):
			_player.health_changed.disconnect(_on_player_health_changed)

	_player = p

	if _player != null and _player.has_signal("health_changed"):
		_player.health_changed.connect(_on_player_health_changed)

	if _player != null and _player.has_method("get_health"):
		var h: Array = _player.call("get_health")
		if h.size() >= 2:
			_on_player_health_changed(int(h[0]), int(h[1]))

func _update_bet_buttons() -> void:
	if bet_win_button == null or bet_no_hit_button == null or bet_fast_button == null:
		return
	_set_bet_button_text(bet_win_button, "WIN")
	_set_bet_button_text(bet_no_hit_button, "NO_HIT")
	_set_bet_button_text(bet_fast_button, "FAST")

func _set_bet_button_text(button: Button, bet_id: String) -> void:
	if not _bets_by_id.has(bet_id):
		button.text = bet_id
		return
	var bet: Dictionary = _bets_by_id.get(bet_id, {})
	if bet.is_empty():
		push_warning("Bet id not found: %s" % bet_id)
		return
	button.text = "%s x%.1f" % [bet.get("label", bet_id), float(bet.get("odds", 1.0))]

func _on_bet_failed(can_retry: bool) -> void:
	if bet_panel != null:
		bet_panel.visible = false
	_reset_fast_countdown()
	if upgrade_panel != null:
		upgrade_panel.visible = false
	_set_upgrade_modal(false)
	if game_over_panel != null:
		game_over_panel.visible = true
	if game_over_title != null:
		game_over_title.text = "RUN FAILED"
		if can_retry:
			game_over_title.text = "BET FAILED"
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

func _show_upgrade_panel() -> void:
	if upgrade_panel == null:
		return
	if bet_panel != null:
		bet_panel.visible = false
	_reset_fast_countdown()
	_update_upgrade_costs()
	_set_upgrade_modal(true)
	upgrade_panel.visible = true
	# Defer once to avoid redundant layout passes; _center_upgrade_panel_to_texture queues centering.
	call_deferred("_center_upgrade_panel_to_texture")

func _on_upgrade_continue_pressed() -> void:
	if upgrade_panel != null:
		upgrade_panel.visible = false
	_set_upgrade_modal(false)
	get_viewport().gui_release_focus()
	var manager := _get_run_manager()
	if manager != null and manager.has_method("consume_upgrade_shop"):
		manager.consume_upgrade_shop()
	if _pending_bets.size() > 0:
		print("Upgrade continue: reopening pending bets (%d)" % _pending_bets.size())
		_on_bet_ui_opened(_pending_bets)
		_pending_bets = []
	else:
		var bet_manager := _get_bet_manager()
		if bet_manager != null and bet_manager.has_method("open_bet_ui_before_arena"):
			print("Upgrade continue: opening bet UI before arena")
			bet_manager.open_bet_ui_before_arena()
		elif Engine.has_singleton("GameEvents") and GameEvents != null:
			print("Upgrade continue: emitting betting_opened fallback")
			GameEvents.betting_opened.emit()
		else:
			push_warning("Upgrade continue: no pending bets and BetManager missing; bet UI may not open.")

func _purchase_upgrade(upgrade_type: String) -> void:
	var manager := _get_run_manager()
	if manager == null or not manager.has_method("purchase_upgrade"):
		return
	# Safety: se bottone disabilitato non dovrebbe arrivare qui, ma teniamo fallback.
	var ok := bool(manager.purchase_upgrade(upgrade_type))
	if not ok:
		_flash_upgrade_row(upgrade_type)
		_update_upgrade_costs()
		return
	_play_sfx(sfx_upgrade_buy)
	_update_upgrade_costs()
	_refresh_upgrade_shop_ui()

func _flash_upgrade_row(upgrade_type: String) -> void:
	var row: Control = null
	match upgrade_type:
		"hp": row = upgrade_hp_row
		"light": row = upgrade_light_row
		"heavy": row = upgrade_heavy_row
		_: row = null
	if row == null:
		return
	var base := row.modulate
	row.modulate = Color(1, 0.35, 0.35, 1)
	await get_tree().create_timer(UPGRADE_FLASH_TIME).timeout
	if row != null and is_instance_valid(row):
		row.modulate = base

func _update_upgrade_costs() -> void:
	var manager := _get_run_manager()
	if manager == null:
		return
	# Preferisci l'API "offer" (UI-ready). Fallback su config vecchio se non presente.
	if manager.has_method("get_upgrade_offer"):
		var offer: Dictionary = manager.get_upgrade_offer()
		var tokens: int = int(offer.get("tokens", 0))
		if upgrade_tokens_label != null:
			var coins := _coins
			if manager.has_method("get_coins"):
				coins = int(manager.call("get_coins"))
			upgrade_tokens_label.text = "Coins: %d | Tokens: %d" % [coins, tokens]

		var hp: Dictionary = offer.get("hp", {})
		var light: Dictionary = offer.get("light", {})
		var heavy: Dictionary = offer.get("heavy", {})

		if upgrade_hp_label != null:
			upgrade_hp_label.text = "HP +%d | Total: %d → %d | Cost: %dT" % [
				int(hp.get("add", 0)),
				int(hp.get("current_total", 0)),
				int(hp.get("next_total", 0)),
				int(hp.get("cost", 1)),
			]
		if upgrade_light_label != null:
			upgrade_light_label.text = "LIGHT +%d | Total: %d → %d | Cost: %dT" % [
				int(light.get("add", 0)),
				int(light.get("current_total", 0)),
				int(light.get("next_total", 0)),
				int(light.get("cost", 1)),
			]
		if upgrade_heavy_label != null:
			upgrade_heavy_label.text = "HEAVY +%d | Total: %d → %d | Cost: %dT" % [
				int(heavy.get("add", 0)),
				int(heavy.get("current_total", 0)),
				int(heavy.get("next_total", 0)),
				int(heavy.get("cost", 1)),
			]

		if upgrade_hp_button != null:
			upgrade_hp_button.disabled = not bool(hp.get("affordable", tokens >= int(hp.get("cost", 1))))
		if upgrade_light_button != null:
			upgrade_light_button.disabled = not bool(light.get("affordable", tokens >= int(light.get("cost", 1))))
		if upgrade_heavy_button != null:
			upgrade_heavy_button.disabled = not bool(heavy.get("affordable", tokens >= int(heavy.get("cost", 1))))
		return

	if not manager.has_method("get_upgrade_config"):
		return
	# Fallback legacy
	var config: Dictionary = manager.get_upgrade_config()
	if upgrade_hp_label != null:
		upgrade_hp_label.text = "HP +%d (Cost: %dT)" % [int(config.get("hp_bonus", 0)), int(config.get("hp_cost", 0))]
	if upgrade_light_label != null:
		upgrade_light_label.text = "LIGHT +%d (Cost: %dT)" % [int(config.get("light_bonus", 0)), int(config.get("light_cost", 0))]
	if upgrade_heavy_label != null:
		upgrade_heavy_label.text = "HEAVY +%d (Cost: %dT)" % [int(config.get("heavy_bonus", 0)), int(config.get("heavy_cost", 0))]

	# Se non abbiamo offer, non sappiamo affordability (manteniamo abilitati)

func _place_bet(bet_id: String) -> void:
	var manager := _get_bet_manager()
	if manager == null or stake_input == null:
		return
	_selected_bet_id = bet_id
	if bet_id == "FAST":
		_fast_countdown_active = true
		# Show immediately (so the player understands the rule), then it will keep updating during the round.
		if fast_countdown_label != null:
			fast_countdown_label.visible = true
			fast_countdown_label.text = "FAST: %ds" % FAST_SELECTION_SECONDS
			fast_countdown_label.modulate.a = 1.0
	else:
		_reset_fast_countdown()
	var stake := int(stake_input.value)
	manager.place_bet(bet_id, stake)

func _center_upgrade_panel_to_texture() -> void:
	if upgrade_panel == null or upgrade_bg == null:
		return
	if upgrade_vbox != null:
		upgrade_vbox.queue_sort()
	await get_tree().process_frame
	if upgrade_panel == null or not upgrade_panel.visible:
		return
	var size := upgrade_panel.custom_minimum_size
	var bg_texture := upgrade_bg.texture
	if bg_texture != null:
		var texture_size := bg_texture.get_size()
		if texture_size.x > size.x:
			size.x = texture_size.x
		if texture_size.y > size.y:
			size.y = texture_size.y
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var max_size := viewport_size * 0.95
	size.x = minf(size.x, max_size.x)
	size.y = minf(size.y, max_size.y)
	if size.x <= 0.0 or size.y <= 0.0:
		return
	upgrade_panel.custom_minimum_size = size
	upgrade_panel.size = size
	upgrade_panel.reset_size()
	var half := size * 0.5
	upgrade_panel.offset_left = -half.x
	upgrade_panel.offset_top = -half.y
	upgrade_panel.offset_right = half.x
	upgrade_panel.offset_bottom = half.y

	# Keep the interactive widgets INSIDE the painted "box" area of the background.
	# Use ratios so it scales with resolution/viewport.
	if upgrade_content_area != null:
		# These ratios are tuned for ui_upgrade_panel_gallicus.png:
		# content box starts below the rooster and ends above the bottom frame.
		var left_r := 0.14
		var right_r := 0.86
		var top_r := 0.33
		var bottom_r := 0.92

		var px_left := int(size.x * left_r)
		var px_right := int(size.x * right_r)
		var px_top := int(size.y * top_r)
		var px_bottom := int(size.y * bottom_r)

		upgrade_content_area.anchor_left = 0.0
		upgrade_content_area.anchor_top = 0.0
		upgrade_content_area.anchor_right = 0.0
		upgrade_content_area.anchor_bottom = 0.0
		upgrade_content_area.offset_left = px_left
		upgrade_content_area.offset_top = px_top
		upgrade_content_area.offset_right = px_right
		upgrade_content_area.offset_bottom = px_bottom

		if upgrade_vbox != null:
			upgrade_vbox.queue_sort()

func _set_upgrade_modal(active: bool) -> void:
	if modal_dimmer != null:
		modal_dimmer.visible = active
	if active:
		_controls_hint_was_visible = controls_hint_panel != null and controls_hint_panel.visible
		_countdown_was_visible = countdown_label != null and countdown_label.visible
		_fast_countdown_was_visible = fast_countdown_label != null and fast_countdown_label.visible
		_fast_blink_was_running = fast_blink_timer != null and not fast_blink_timer.is_stopped()
		_upgrade_modal_active = true
		if controls_hint_panel != null:
			controls_hint_panel.visible = false
		if countdown_label != null:
			countdown_label.visible = false
		if fast_countdown_label != null:
			fast_countdown_label.visible = false
		if fast_blink_timer != null and _fast_blink_was_running:
			fast_blink_timer.stop()
	else:
		if not _upgrade_modal_active:
			return
		if controls_hint_panel != null:
			controls_hint_panel.visible = _controls_hint_was_visible
		if countdown_label != null:
			countdown_label.visible = _countdown_was_visible
		if fast_countdown_label != null:
			fast_countdown_label.visible = _fast_countdown_was_visible
		if fast_blink_timer != null and _fast_blink_was_running and _fast_countdown_active:
			fast_blink_timer.start()
		_upgrade_modal_active = false
	get_viewport().gui_release_focus()

func _reset_fast_countdown() -> void:
	_selected_bet_id = ""
	_fast_countdown_active = false
	_stop_fast_blink()
	if fast_countdown_label != null:
		fast_countdown_label.visible = false

func _process(_delta: float) -> void:
	if debug_overlay == null or not debug_overlay.visible:
		return
	var fps := Engine.get_frames_per_second()
	var arena_index := _get_arena_index()
	var enemies_alive := _get_enemies_alive()
	var bet_active := _is_bet_active()
	debug_overlay.text = "FPS: %d\nArena: %d\nEnemies: %d\nBet active: %s" % [
		fps,
		arena_index,
		enemies_alive,
		str(bet_active)
	]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		if debug_overlay != null:
			debug_overlay.visible = not debug_overlay.visible

func _req(path: String) -> Node:
	var n := get_node_or_null(path)
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
	var manager := _get_run_manager()
	if manager and manager.has_method("get_arena"):
		_arena = manager.get_arena()
	if _arena:
		return _arena
	_arena = get_tree().get_first_node_in_group("arena")
	return _arena

func _get_arena_index() -> int:
	var manager := _get_run_manager()
	if manager and manager.has_method("get_arena_index"):
		return manager.get_arena_index()
	return 0

func _get_enemies_alive() -> int:
	var arena := _get_arena()
	if arena and arena.has_method("get_enemies_remaining"):
		return int(arena.get_enemies_remaining())
	return 0

func _is_bet_active() -> bool:
	var manager := _get_bet_manager()
	if manager and manager.has_method("is_bet_active"):
		return manager.is_bet_active()
	return false

func _get_bet_manager() -> Node:
	if _bet_manager and is_instance_valid(_bet_manager):
		return _bet_manager
	_bet_manager = get_tree().get_first_node_in_group("bet_manager")
	return _bet_manager
