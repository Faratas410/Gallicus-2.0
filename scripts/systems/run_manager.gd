extends Node

var run := {
	"arena_index": 0,
	"coins": 0,
}

func start_new_run() -> void:
	run = {
		"arena_index": 0,
		"coins": 0,
	}
	GameEvents.run_started.emit()
	GameEvents.arena_started.emit(run.arena_index)
	GameEvents.coins_changed.emit(run.coins)

func add_coins(amount: int) -> void:
	run.coins += amount
	GameEvents.coins_changed.emit(run.coins)

func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return true
	if run.coins < amount:
		return false
	run.coins -= amount
	GameEvents.coins_changed.emit(run.coins)
	return true
