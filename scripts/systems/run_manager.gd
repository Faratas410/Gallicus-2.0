extends Node

@export var arena_path: NodePath
@export var player_path: NodePath
@export var starting_coins: int = GameConstants.RUN_STARTING_COINS
@export var arena_clear_reward: int = GameConstants.ARENA_CLEAR_REWARD

var run := {
	"arena_index": 0,
	"coins": 0,
}

var _arena: Node
var _bet_manager: Node
var _waiting_for_bet: bool = false
var _player: Node

func _ready() -> void:
	add_to_group("run_manager")
	_arena = get_node_or_null(arena_path)
	_bet_manager = get_node_or_null("BetManager")
	if _arena:
		_arena.connect("wave_started", _on_wave_started)
		_arena.connect("wave_cleared", _on_wave_cleared)
		_arena.connect("player_spawned", _on_player_spawned)
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_failed.connect(_on_run_failed)
	start_new_run()

func start_new_run() -> void:
	run = {
		"arena_index": 0,
		"coins": starting_coins,
	}
	GameEvents.run_started.emit()
	GameEvents.coins_changed.emit(run.coins)
	_open_bet_ui()

func _open_bet_ui() -> void:
	_waiting_for_bet = true
	_set_gameplay_active(false)
	if _bet_manager and _bet_manager.has_method("open_bet_ui_before_arena"):
		_bet_manager.open_bet_ui_before_arena()

func _start_next_arena() -> void:
	if _arena == null:
		return
	run.arena_index += 1
	_arena.call("start_next_wave")

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

func _on_bet_placed(_bet_id: String, _stake: int, _odds: float) -> void:
	if not _waiting_for_bet:
		return
	_waiting_for_bet = false
	_start_next_arena()

func _on_wave_started(_wave: int) -> void:
	GameEvents.arena_started.emit(run.arena_index)
	if _bet_manager and _bet_manager.has_method("register_arena_start"):
		_bet_manager.register_arena_start()
	_set_gameplay_active(true)

func _on_wave_cleared(_wave: int) -> void:
	GameEvents.arena_completed.emit(run.arena_index)
	if _bet_manager and _bet_manager.has_method("resolve_bet"):
		_bet_manager.resolve_bet()
	if arena_clear_reward > 0:
		add_coins(arena_clear_reward)
	_open_bet_ui()

func _on_player_spawned(player: Node) -> void:
	_player = player
	if _waiting_for_bet:
		_set_gameplay_active(false)

func _set_gameplay_active(active: bool) -> void:
	_player = _resolve_player()
	if _player and _player.has_method("set_physics_process"):
		_player.set_physics_process(active)

func _resolve_player() -> Node:
	if _player and is_instance_valid(_player):
		return _player
	if player_path != NodePath():
		var path_player := get_node_or_null(player_path)
		if path_player:
			_player = path_player
			return _player
	_player = get_tree().get_first_node_in_group("player")
	return _player

func _on_run_failed() -> void:
	_soft_reset()

func _soft_reset() -> void:
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	if _bet_manager and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.reset_bet_state()
	run.arena_index = 0
	_player = _resolve_player()
	_open_bet_ui()

func get_arena() -> Node:
	return _arena

func get_arena_index() -> int:
	return int(run.get("arena_index", 0))
