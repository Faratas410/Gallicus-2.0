extends CanvasLayer

@onready var coins_label: Label = %CoinsLabel
@onready var bet_info_label: Label = %BetInfoLabel
@onready var bet_panel: Panel = %BetPanel
@onready var stake_input: SpinBox = %StakeInput
@onready var bet_win_button: Button = %BetWinButton
@onready var bet_no_hit_button: Button = %BetNoHitButton
@onready var bet_fast_button: Button = %BetFastButton

var _bets_by_id: Dictionary = {}
var _bet_manager: Node

func _ready() -> void:
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.bet_ui_opened.connect(_on_bet_ui_opened)
	GameEvents.bet_ui_closed.connect(_on_bet_ui_closed)

	bet_win_button.pressed.connect(func() -> void: _place_bet("WIN"))
	bet_no_hit_button.pressed.connect(func() -> void: _place_bet("NO_HIT"))
	bet_fast_button.pressed.connect(func() -> void: _place_bet("FAST"))
	bet_panel.visible = false

func _on_run_started() -> void:
	coins_label.text = "Coins: 0"
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

func _get_bet_manager() -> Node:
	if _bet_manager and is_instance_valid(_bet_manager):
		return _bet_manager
	_bet_manager = get_tree().get_first_node_in_group("bet_manager")
	return _bet_manager
