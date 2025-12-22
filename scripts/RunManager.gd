extends Node

signal gold_changed(amount: int)
signal bet_changed(amount: int)
signal state_changed(betting_open: bool)
signal countdown_requested(seconds: int)
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
var _countdown_active: bool = false

func _ready() -> void:
	_ensure_input_map()
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
	if _countdown_active:
		return
	if not _player_alive:
		return
	if _betting_open and Input.is_action_just_pressed("interact"):
		_cycle_bet()
	if _betting_open and Input.is_action_just_pressed("start_wave"):
		_try_start_wave()

func start_new_run() -> void:
	_gold = starting_gold
	_bet_index = 0
	_betting_open = true
	_player_alive = true
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	if _get_live_player() == null and _arena:
		if _arena.has_method("ensure_player"):
			_arena.call("ensure_player")
	gold_changed.emit(_gold)
	bet_changed.emit(get_current_bet())
	state_changed.emit(_betting_open)
	_start_countdown()

func start_next_bet_round() -> void:
	if not _player_alive:
		return
	_betting_open = true
	_bet_index = 0
	bet_changed.emit(get_current_bet())
	state_changed.emit(_betting_open)

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
		var died_callable := Callable(self, "_on_player_died")
		if not player.is_connected("died", died_callable):
			player.connect("died", died_callable)

func _on_player_died() -> void:
	_player_alive = false
	_betting_open = false
	state_changed.emit(_betting_open)
	run_over.emit()

func get_current_bet() -> int:
	return bet_steps[_bet_index]

func is_betting_open() -> bool:
	return _betting_open

func _ensure_input_map() -> void:
	if not InputMap.has_action("start_wave"):
		InputMap.add_action("start_wave")
	var has_enter := false
	var has_kp_enter := false
	for ev in InputMap.action_get_events("start_wave"):
		if ev is InputEventKey:
			if ev.keycode == Key.ENTER:
				has_enter = true
			elif ev.keycode == Key.KP_ENTER:
				has_kp_enter = true
	if not has_enter:
		var iev := InputEventKey.new()
		iev.keycode = Key.ENTER
		InputMap.action_add_event("start_wave", iev)
	if not has_kp_enter:
		var iev := InputEventKey.new()
		iev.keycode = Key.KP_ENTER
		InputMap.action_add_event("start_wave", iev)

func _get_live_player() -> Node:
	var p := get_tree().get_first_node_in_group("player")
	if p != null and p.is_inside_tree() and not p.is_queued_for_deletion():
		return p
	return null

func _start_countdown() -> void:
	_countdown_active = true
	_betting_open = false
	state_changed.emit(_betting_open)
	var game_events := get_node_or_null("/root/GameEvents")
	if game_events and game_events.has_signal("countdown_requested"):
		game_events.emit_signal("countdown_requested", 3)
	else:
		countdown_requested.emit(3)
	for _i in range(3):
		await get_tree().create_timer(1.0).timeout
	_countdown_active = false
	_betting_open = true
	state_changed.emit(_betting_open)
