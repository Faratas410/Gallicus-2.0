extends Node

var arena_index: int = 0
var coins: int = 0

func start_new_run() -> void:
	arena_index = 0
	coins = 0
	GameEvents.run_started.emit()
	GameEvents.arena_started.emit(arena_index)
	GameEvents.coins_changed.emit(coins)

func add_coins(amount: int) -> void:
	coins += amount
	GameEvents.coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	GameEvents.coins_changed.emit(coins)
	return true
