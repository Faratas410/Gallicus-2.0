extends CanvasLayer

@onready var coins_label: Label = %CoinsLabel
@onready var bet_info_label: Label = %BetInfoLabel
@onready var bet_panel: Panel = %BetPanel
@onready var stake_input: SpinBox = %StakeInput
@onready var bet_win_button: Button = %BetWinButton
@onready var bet_no_hit_button: Button = %BetNoHitButton
@onready var bet_fast_button: Button = %BetFastButton
@onready var debug_overlay: Label = %DebugOverlay

var _bets_by_id: Dictionary = {}
var _bet_manager: Node
var _run_manager: Node
var _arena: Node

func _ready() -> void:
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.run_failed.connect(_on_run_failed)
	GameEvents.bet_ui_opened.connect(_on_bet_ui_opened)
	GameEvents.bet_ui_closed.connect(_on_bet_ui_closed)

	bet_win_button.pressed.connect(func() -> void: _place_bet("WIN"))
	bet_no_hit_button.pressed.connect(func() -> void: _place_bet("NO_HIT"))
	bet_fast_button.pressed.connect(func() -> void: _place_bet("FAST"))
	bet_panel.visible = false
	debug_overlay.visible = false

func _on_run_started() -> void:
	coins_label.text = "Coins: 0"
	bet_info_label.text = "Bet: -"
	bet_panel.visible = false

func _on_run_failed() -> void:
	bet_info_label.text = "Bet: -"
	bet_panel.visible = false

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Coins: %d" % coins

func _on_bet_placed(bet_id: String, stake: int, odds: float) -> void:
	bet_info_label.text = "Bet: %s | %d @ %.2f" % [bet_id, stake, odds]

func _on_bet_ui_opened(bets: Array) -> void:
	_bets_by_id.clear()
	for bet in bets:
		_bets_by_id[bet.get("id", "")] = bet
	_update_bet_buttons()
	bet_panel.visible = true

func _on_bet_ui_closed() -> void:
	bet_panel.visible = false

func _update_bet_buttons() -> void:
	_set_bet_button_text(bet_win_button, "WIN")
	_set_bet_button_text(bet_no_hit_button, "NO_HIT")
	_set_bet_button_text(bet_fast_button, "FAST")

func _set_bet_button_text(button: Button, bet_id: String) -> void:
	if not _bets_by_id.has(bet_id):
		button.text = bet_id
		return
	var bet := _bets_by_id[bet_id]
	button.text = "%s x%.1f" % [bet.get("label", bet_id), float(bet.get("odds", 1.0))]

func _place_bet(bet_id: String) -> void:
	var manager := _get_bet_manager()
	if manager == null:
		return
	var stake := int(stake_input.value)
	manager.place_bet(bet_id, stake)

func _process(_delta: float) -> void:
	if not debug_overlay.visible:
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
		debug_overlay.visible = not debug_overlay.visible

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
