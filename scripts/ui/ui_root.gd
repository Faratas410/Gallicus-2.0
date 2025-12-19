extends CanvasLayer

@onready var coins_label: Label = %CoinsLabel
@onready var bet_info_label: Label = %BetInfoLabel

func _ready() -> void:
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_started.connect(_on_run_started)

func _on_run_started() -> void:
	coins_label.text = "Coins: 0"
	bet_info_label.text = "Bet: -"

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Coins: %d" % coins

func _on_bet_placed(bet_id: String, stake: int, odds: float) -> void:
	bet_info_label.text = "Bet: %s | %d @ %.2f" % [bet_id, stake, odds]
