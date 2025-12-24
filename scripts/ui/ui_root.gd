extends CanvasLayer

@onready var coins_label: Label = get_node_or_null("HUD/Panel/VBox/CoinsLabel") as Label
@onready var bet_info_label: Label = get_node_or_null("HUD/Panel/VBox/BetInfoLabel") as Label
@onready var player_hp_bar: ProgressBar = $HUD/Panel/VBox/PlayerHPBar
@onready var player_hp_label: Label = $HUD/Panel/VBox/PlayerHPLabel
@onready var bet_panel: Panel = _req("HUD/BetPanel") as Panel
@onready var upgrade_panel: Panel = get_node_or_null("HUD/UpgradePanel") as Panel
@onready var upgrade_bg: TextureRect = get_node_or_null("HUD/UpgradePanel/UpgradeBG") as TextureRect
@onready var upgrade_coins_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeCoinsLabel") as Label
@onready var upgrade_hp_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeHPRow/UpgradeHPLabel") as Label
@onready var upgrade_light_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeLightRow/UpgradeLightLabel") as Label
@onready var upgrade_heavy_label: Label = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeHeavyRow/UpgradeHeavyLabel") as Label
@onready var upgrade_hp_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeHPRow/UpgradeHPButton") as Button
@onready var upgrade_light_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeLightRow/UpgradeLightButton") as Button
@onready var upgrade_heavy_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeHeavyRow/UpgradeHeavyButton") as Button
@onready var upgrade_continue_button: Button = get_node_or_null("HUD/UpgradePanel/UpgradeVBox/UpgradeContinueButton") as Button
@onready var stake_input: SpinBox = _req("HUD/BetPanel/BetVBox/StakeRow/StakeInput") as SpinBox
@onready var bet_win_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetWinButton") as Button
@onready var bet_no_hit_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetNoHitButton") as Button
@onready var bet_fast_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetFastButton") as Button
@onready var debug_overlay: Label = get_node_or_null("HUD/DebugOverlay") as Label
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

var _bets_by_id: Dictionary = {}
var _bet_manager: Node
var _run_manager: Node
var _arena: Node
var _player: Node = null
var _has_seen_controls: bool = false
var _fast_countdown_active: bool = false
var _pending_bets: Array = []
var _upgrade_center_pending: bool = false
var _upgrade_panel_target_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.run_failed.connect(_on_run_failed)
	GameEvents.bet_failed.connect(_on_bet_failed)
	GameEvents.run_started.connect(_on_run_started_controls)
	GameEvents.run_failed.connect(_on_run_failed_controls)
	GameEvents.bet_ui_opened.connect(_on_bet_ui_opened)
	GameEvents.bet_ui_closed.connect(_on_bet_ui_closed)
	GameEvents.betting_opened.connect(_on_betting_opened)
	GameEvents.countdown_requested.connect(_on_countdown_requested)

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
	if upgrade_hp_button != null:
		upgrade_hp_button.pressed.connect(func() -> void: _purchase_upgrade("hp"))
	if upgrade_light_button != null:
		upgrade_light_button.pressed.connect(func() -> void: _purchase_upgrade("light"))
	if upgrade_heavy_button != null:
		upgrade_heavy_button.pressed.connect(func() -> void: _purchase_upgrade("heavy"))
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
	if upgrade_panel != null:
		upgrade_panel.visible = false
	_pending_bets = []
	if game_over_panel != null:
		game_over_panel.visible = false
	if next_bet_button != null:
		next_bet_button.visible = true
	_handle_fast_countdown(0)

func _on_run_failed() -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	if bet_panel != null:
		bet_panel.visible = false
	if upgrade_panel != null:
		upgrade_panel.visible = false
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
	_handle_fast_countdown(0)

func _on_betting_opened() -> void:
	if game_over_panel != null and game_over_panel.visible:
		if bet_panel != null:
			bet_panel.visible = false
		return
	var manager := _get_run_manager()
	if manager != null and manager.has_method("should_show_upgrade_shop") and manager.should_show_upgrade_shop():
		_show_upgrade_panel()

func _on_countdown_requested(seconds: int) -> void:
	if seconds > 3 or _fast_countdown_active:
		_handle_fast_countdown(seconds)
		return
	if seconds <= 0:
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
	if upgrade_coins_label != null:
		upgrade_coins_label.text = "Coins: %d" % coins

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

func _on_bet_ui_closed() -> void:
	if bet_panel != null:
		bet_panel.visible = false
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
	if seconds <= 0:
		fast_countdown_label.visible = false
		_fast_countdown_active = false
		_stop_fast_blink()
		return
	_fast_countdown_active = true
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
		fast_countdown_label.visible = true

func _on_fast_blink_tick() -> void:
	if fast_countdown_label == null:
		return
	var next_alpha := 0.2 if fast_countdown_label.modulate.a > 0.6 else 1.0
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
	if upgrade_panel != null:
		upgrade_panel.visible = false
	if game_over_panel != null:
		game_over_panel.visible = true
	if game_over_title != null:
		game_over_title.text = "BET FAILED" if can_retry else "RUN FAILED"
	if game_over_hint != null:
		game_over_hint.text = "Riprova la scommessa?" if can_retry else "Vuoi riprovare?"
	if next_bet_button != null:
		next_bet_button.visible = can_retry
		next_bet_button.text = "RETRY BET"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
	_handle_fast_countdown(0)

func _show_upgrade_panel() -> void:
	if upgrade_panel == null:
		return
	if bet_panel != null:
		bet_panel.visible = false
	_update_upgrade_costs()
	upgrade_panel.visible = true
	# Defer once to avoid redundant layout passes; _center_upgrade_panel_to_texture queues centering.
	call_deferred("_center_upgrade_panel_to_texture")

func _on_upgrade_continue_pressed() -> void:
	if upgrade_panel != null:
		upgrade_panel.visible = false
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
	manager.purchase_upgrade(upgrade_type)
	_update_upgrade_costs()

func _update_upgrade_costs() -> void:
	var manager := _get_run_manager()
	if manager == null or not manager.has_method("get_upgrade_config"):
		return
	var config: Dictionary = manager.get_upgrade_config()
	if upgrade_hp_label != null:
		upgrade_hp_label.text = "HP +%d (Cost: %d)" % [
			int(config.get("hp_bonus", 0)),
			int(config.get("hp_cost", 0))
		]
	if upgrade_light_label != null:
		upgrade_light_label.text = "LIGHT +%d (Cost: %d)" % [
			int(config.get("light_bonus", 0)),
			int(config.get("light_cost", 0))
		]
	if upgrade_heavy_label != null:
		upgrade_heavy_label.text = "HEAVY +%d (Cost: %d)" % [
			int(config.get("heavy_bonus", 0)),
			int(config.get("heavy_cost", 0))
		]

func _place_bet(bet_id: String) -> void:
	var manager := _get_bet_manager()
	if manager == null or stake_input == null:
		return
	var stake := int(stake_input.value)
	manager.place_bet(bet_id, stake)

func _center_upgrade_panel_to_texture() -> void:
	if upgrade_panel == null or upgrade_bg == null:
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
	size.x = min(size.x, max_size.x)
	size.y = min(size.y, max_size.y)
	if size.x <= 0.0 or size.y <= 0.0:
		return
	_upgrade_panel_target_size = size
	upgrade_panel.custom_minimum_size = size
	upgrade_panel.size = size
	upgrade_panel.queue_sort()
	_request_upgrade_panel_center()

func _request_upgrade_panel_center() -> void:
	if _upgrade_center_pending:
		return
	_upgrade_center_pending = true
	call_deferred("_apply_upgrade_panel_center")

func _apply_upgrade_panel_center() -> void:
	_upgrade_center_pending = false
	if upgrade_panel == null or not upgrade_panel.visible:
		return
	var size := upgrade_panel.size
	if size.x <= 0.0 or size.y <= 0.0:
		size = _upgrade_panel_target_size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var half := size * 0.5
	upgrade_panel.offset_left = -half.x
	upgrade_panel.offset_top = -half.y
	upgrade_panel.offset_right = half.x
	upgrade_panel.offset_bottom = half.y

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
