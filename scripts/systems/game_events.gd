extends Node

signal run_started
signal arena_started(arena_index: int)
signal arena_completed(arena_index: int)
signal run_failed
signal coins_changed(coins: int)
signal bet_placed(bet_id: String, stake: int, odds: float)
