extends CanvasLayer

@onready var coins_label: Label = $CoinsLabel
@onready var bet_info_label: Label = $BetInfoLabel

func _ready() -> void:
	coins_label.text = "Coins: 0"
	bet_info_label.text = "Bet: -"
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.bet_placed.connect(_on_bet_placed)

func _on_coins_changed(coins: int) -> void:
	coins_label.text = "Coins: %d" % coins

func _on_bet_placed(bet_id: String, stake: int, odds: float) -> void:
	bet_info_label.text = "Bet: %s | Stake: %d | Odds: %.2f" % [bet_id, stake, odds]
