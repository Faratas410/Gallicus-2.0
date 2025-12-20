extends CanvasLayer

@onready var coins_label: Label = get_node_or_null("HUD/Panel/VBox/CoinsLabel") as Label
@onready var bet_info_label: Label = get_node_or_null("HUD/Panel/VBox/BetInfoLabel") as Label
@onready var player_hp_bar: ProgressBar = $HUD/Panel/VBox/PlayerHPBar
@onready var player_hp_label: Label = $HUD/Panel/VBox/PlayerHPLabel
@onready var bet_panel: Panel = _req("HUD/BetPanel") as Panel
@onready var stake_input: SpinBox = _req("HUD/BetPanel/BetVBox/StakeRow/StakeInput") as SpinBox
@onready var bet_win_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetWinButton") as Button
@onready var bet_no_hit_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetNoHitButton") as Button
@onready var bet_fast_button: Button = _req("HUD/BetPanel/BetVBox/BetButtons/BetFastButton") as Button
@onready var debug_overlay: Label = get_node_or_null("HUD/DebugOverlay") as Label
@onready var game_over_panel: Panel = $HUD/GameOverPanel
@onready var restart_button: Button = $HUD/GameOverPanel/GameOverVBox/RestartButton
@onready var next_bet_button: Button = $HUD/GameOverPanel/GameOverVBox/NextBetButton
@onready var quit_button: Button = $HUD/GameOverPanel/GameOverVBox/QuitButton
@onready var controls_hint_panel: Panel = $HUD/ControlsHintPanel

var _bets_by_id: Dictionary = {}
var _bet_manager: Node
var _run_manager: Node
var _arena: Node
var _player: Node = null
var _has_seen_controls: bool = false

func _ready() -> void:
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.run_failed.connect(_on_run_failed)
	GameEvents.run_started.connect(_on_run_started_controls)
	GameEvents.run_failed.connect(_on_run_failed_controls)
	GameEvents.bet_ui_opened.connect(_on_bet_ui_opened)
	GameEvents.bet_ui_closed.connect(_on_bet_ui_closed)

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

	if restart_button != null:
		restart_button.pressed.connect(_on_restart_pressed)
	if next_bet_button != null:
		next_bet_button.pressed.connect(_on_next_bet_pressed)
	if quit_button != null:
		quit_button.pressed.connect(_on_quit_pressed)

	var arena: Node = get_tree().get_first_node_in_group("arena")
	if arena != null and arena.has_signal("player_spawned"):
		arena.player_spawned.connect(_on_player_spawned)

	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null:
		_bind_player(p)

	print("UI ready: coins=%s bet_panel=%s debug=%s" % [coins_label != null, bet_panel != null, debug_overlay != null])

func _on_run_started() -> void:
	if coins_label != null:
		coins_label.text = "Coins: 0"
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	if bet_panel != null:
		bet_panel.visible = false
	if game_over_panel != null:
		game_over_panel.visible = false

func _on_run_failed() -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	if bet_panel != null:
		bet_panel.visible = false
	if game_over_panel != null:
		game_over_panel.visible = true

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

func _on_bet_placed(bet_id: String, stake: int, odds: float) -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: %s | %d @ %.2f" % [bet_id, stake, odds]

func _on_bet_ui_opened(bets: Array) -> void:
	if bet_panel == null:
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

func _on_next_bet_pressed() -> void:
	_request_next_bet()

func _request_reset() -> void:
	if game_over_panel != null:
		game_over_panel.visible = false

	var rm: Node = get_tree().get_first_node_in_group("run_manager")
	if rm != null and rm.has_method("reset_run"):
		rm.call("reset_run")
	elif rm != null and rm.has_method("restart_run"):
		rm.call("restart_run", false)
	elif rm != null and rm.has_method("start_new_run"):
		rm.call("start_new_run")
	else:
		push_warning("RunManager not found or no restart method.")

func _request_next_bet() -> void:
	if game_over_panel != null:
		game_over_panel.visible = false

	var rm: Node = get_tree().get_first_node_in_group("run_manager")
	if rm != null and rm.has_method("restart_run"):
		rm.call("restart_run", true)
	else:
		push_warning("RunManager not found or no restart method.")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_player_health_changed(current: int, max: int) -> void:
	player_hp_bar.max_value = max
	player_hp_bar.value = current
	player_hp_label.text = "HP: %d/%d" % [current, max]

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

func _place_bet(bet_id: String) -> void:
	var manager := _get_bet_manager()
	if manager == null or stake_input == null:
		return
	var stake := int(stake_input.value)
	manager.place_bet(bet_id, stake)

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
