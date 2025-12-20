extends Node

@export var arena_path: NodePath
@export var player_path: NodePath
@export var starting_coins: int = GameConstants.RUN_STARTING_COINS
@export var arena_clear_reward: int = GameConstants.ARENA_CLEAR_REWARD
@export var arena_scene: PackedScene = preload("res://scenes/Arena.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")

var run := {
	"arena_index": 0,
	"coins": 0,
}

var _arena: Node
var _bet_manager: Node
var _waiting_for_bet: bool = false
var _player: Node

func _ready() -> void:
	print("RunManager ready")
	add_to_group("run_manager")
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.run_failed.connect(_on_run_failed)
	_ensure_input_map()
	call_deferred("_boot")

func _boot() -> void:
	await get_tree().process_frame
	_ensure_arena_and_player()
	_arena = get_node_or_null(arena_path)
	_player = get_tree().get_first_node_in_group("player")
	_bet_manager = get_node_or_null("BetManager")
	if _arena:
		_arena.connect("wave_started", _on_wave_started)
		_arena.connect("wave_cleared", _on_wave_cleared)
		_arena.connect("player_spawned", _on_player_spawned)
	print("Boot: arena=", _arena, " player=", _player)
	print("Player in tree:", _player != null and _player.is_inside_tree())
	print("Starting new run")
	start_new_run()

func start_new_run() -> void:
	run = {
		"arena_index": 0,
		"coins": starting_coins,
	}
	GameEvents.run_started.emit()
	GameEvents.coins_changed.emit(run.coins)
	_open_bet_ui()

func restart_run(open_bet: bool = true) -> void:
	run = {
		"arena_index": 0,
		"coins": starting_coins,
	}
	GameEvents.coins_changed.emit(run.coins)

	_waiting_for_bet = open_bet
	if _bet_manager != null and _bet_manager.has_method("reset"):
		_bet_manager.call("reset")

	if _arena != null:
		if _arena.has_method("reset_arena"):
			_arena.call("reset_arena")
		elif _arena.has_method("clear_enemies"):
			_arena.call("clear_enemies")

	_ensure_arena_and_player()

	_arena = get_node_or_null(arena_path)
	if _arena == null:
		_arena = get_tree().get_first_node_in_group("arena")

	GameEvents.run_started.emit()
	if _arena != null and _arena.has_method("restart_arena"):
		_arena.call("restart_arena")

	if open_bet:
		GameEvents.betting_opened.emit()

func _open_bet_ui() -> void:
	_waiting_for_bet = true
	_set_gameplay_active(false)
	if _bet_manager and _bet_manager.has_method("open_bet_ui_before_arena"):
		_bet_manager.open_bet_ui_before_arena()

func _ensure_arena_and_player() -> void:
	var main := get_parent()
	if main == null:
		return
	var arena_node: Node = null
	if arena_path != NodePath():
		arena_node = get_node_or_null(arena_path)
	if arena_node == null and arena_scene:
		arena_node = arena_scene.instantiate()
		arena_node.name = "Arena"
		main.add_child(arena_node)
		if arena_node is Node2D:
			arena_node.global_position = Vector2.ZERO
		arena_path = NodePath("../Arena")
	_arena = arena_node

	var existing_player: Node = null
	if player_path != NodePath():
		existing_player = get_node_or_null(player_path)
	if existing_player == null:
		existing_player = get_tree().get_first_node_in_group("player")
	if existing_player == null and player_scene:
		existing_player = player_scene.instantiate()
		existing_player.name = "Player"
		main.add_child(existing_player)
		if existing_player is Node2D:
			existing_player.global_position = Vector2.ZERO
		player_path = NodePath("../Player")
	_player = existing_player
	if _player and _player is Node2D:
		(_player as Node2D).global_position = Vector2.ZERO

func _ensure_input_map() -> void:
	var actions := {
		# Movimento
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],

		# Combattimento
		"attack_light": [KEY_J],
		"attack_heavy": [KEY_K],
		"block": [KEY_L],
		"dodge": [KEY_SPACE],

		# Sistema
		"pause": [KEY_ESCAPE],
	}

	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing: Dictionary = {}
		for ev in InputMap.action_get_events(action_name):
			if ev is InputEventKey:
				existing[ev.keycode] = true

		for keycode in actions[action_name]:
			if not existing.has(keycode):
				var iev := InputEventKey.new()
				iev.keycode = keycode
				InputMap.action_add_event(action_name, iev)

	print("InputMap ensured: movement + combat bindings ready")

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
