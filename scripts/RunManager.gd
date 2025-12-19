extends Node

signal gold_changed(amount: int)
signal bet_changed(amount: int)
signal state_changed(betting_open: bool)
signal run_over

@export var arena_path: NodePath
@export var starting_gold: int = 100
@export var bet_steps: Array[int] = [0, 10, 25, 50]
@export var payout_multiplier: float = 2.0

var _arena: Node
var _gold: int
var _bet_index: int = 0
var _betting_open: bool = true
var _player_alive: bool = true

func _ready() -> void:
	_gold = starting_gold
	_arena = get_node_or_null(arena_path)
	if _arena:
		_arena.connect("wave_cleared", _on_wave_cleared)
		_arena.connect("wave_started", _on_wave_started)
		_arena.connect("player_spawned", _on_player_spawned)
	gold_changed.emit(_gold)
	bet_changed.emit(get_current_bet())
	state_changed.emit(_betting_open)

func _process(_delta: float) -> void:
	if not _player_alive:
		return
	if _betting_open and Input.is_action_just_pressed("interact"):
		_cycle_bet()
	if _betting_open and Input.is_action_just_pressed("attack_light"):
		_try_start_wave()

func _cycle_bet() -> void:
	_bet_index = (_bet_index + 1) % bet_steps.size()
	bet_changed.emit(get_current_bet())

func _try_start_wave() -> void:
	if _arena == null:
		return
	var bet := get_current_bet()
	if bet > _gold:
		return
	_gold -= bet
	gold_changed.emit(_gold)
	_betting_open = false
	state_changed.emit(_betting_open)
	_arena.call("start_next_wave")

func _on_wave_started(_wave: int) -> void:
	_betting_open = false
	state_changed.emit(_betting_open)

func _on_wave_cleared(_wave: int) -> void:
	var bet := get_current_bet()
	if bet > 0:
		var payout := int(round(bet * payout_multiplier))
		_gold += payout
		gold_changed.emit(_gold)
	_betting_open = true
	_bet_index = 0
	bet_changed.emit(get_current_bet())
	state_changed.emit(_betting_open)

func _on_player_spawned(player: Node) -> void:
	if player and player.has_signal("died"):
		player.connect("died", _on_player_died)

func _on_player_died() -> void:
	_player_alive = false
	run_over.emit()

func get_current_bet() -> int:
	return bet_steps[_bet_index]

func is_betting_open() -> bool:
	return _betting_open
