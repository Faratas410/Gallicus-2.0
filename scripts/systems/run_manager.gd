extends Node

@export var arena_path: NodePath
@export var player_path: NodePath
@export var starting_coins: int = GameConstants.RUN_STARTING_COINS
@export var arena_clear_reward: int = GameConstants.ARENA_CLEAR_REWARD
@export var arena_scene: PackedScene = preload("res://scenes/Arena.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")

enum RunPhase { PREP, LIVE, GAME_OVER }

var run := {
	"arena_index": 0,
	"coins": 0,
}

var _arena: Node
var _bet_manager: Node
var _waiting_for_bet: bool = false
var _player: Node
var _run_failed_emitted: bool = false
var _is_game_over: bool = false
var phase: RunPhase = RunPhase.PREP
var _prep_sequence_id: int = 0
var _has_started_run: bool = false

func _ready() -> void:
	print("RunManager ready")
	add_to_group("run_manager")
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.betting_opened.connect(_on_betting_opened)
	GameEvents.run_failed.connect(_on_run_failed)
	_ensure_input_map()
	call_deferred("_boot")

func _boot() -> void:
	await get_tree().process_frame
	_ensure_arena_and_player()
	_arena = get_node_or_null(arena_path)
	_player = get_tree().get_first_node_in_group("player")
	_connect_player_signals()
	_bet_manager = get_node_or_null("BetManager")
	if _arena:
		_arena.connect("wave_started", _on_wave_started)
		_arena.connect("wave_cleared", _on_wave_cleared)
		_arena.connect("player_spawned", _on_player_spawned)
	print("Boot: arena=", _arena, " player=", _player)
	print("Player in tree:", _player != null and _player.is_inside_tree())
	print("Starting new run")
	start_new_run()
	_log_runtime_state("boot_complete")

func start_new_run() -> void:
	_prep_sequence_id += 1
	var current_id := _prep_sequence_id
	_run_failed_emitted = false
	_is_game_over = false
	_waiting_for_bet = false
	set_phase(RunPhase.PREP)

	_ensure_arena_and_player()
	if _arena != null and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_reset_or_respawn_player_full()
	_clear_enemies()
	if _bet_manager != null and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.call("reset_bet_state")

	if not _has_started_run:
		run["coins"] = starting_coins
		_has_started_run = true
	run["arena_index"] = 0

	GameEvents.run_started.emit()
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))
	GameEvents.countdown_requested.emit(3)
	_log_runtime_state("new_run_ready")
	for _i in range(3, 0, -1):
		await get_tree().create_timer(1.0).timeout
		if current_id != _prep_sequence_id or phase == RunPhase.GAME_OVER:
			return
	if current_id != _prep_sequence_id or phase == RunPhase.GAME_OVER:
		return
	set_phase(RunPhase.LIVE)
	_spawn_wave_or_enemies()
	_log_runtime_state("after_countdown")

func start_next_bet_round() -> void:
	if _is_game_over:
		return
	if _force_game_over_if_dead():
		return
	_waiting_for_bet = false
	set_phase(RunPhase.LIVE)
	_clear_enemies()
	_spawn_wave_or_enemies()

func reset_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	run["coins"] = starting_coins
	start_new_run()

func restart_run(preserve_coins: bool = true) -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if preserve_coins:
		start_new_run()
	else:
		run["coins"] = starting_coins
		start_new_run()

func _open_bet_ui() -> void:
	if _force_game_over_if_dead():
		return
	if _is_game_over:
		return
	_waiting_for_bet = true
	set_phase(RunPhase.PREP)
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
		if _arena:
			_arena.add_child(existing_player)
		else:
			main.add_child(existing_player)
		if existing_player is Node2D:
			existing_player.global_position = Vector2.ZERO
		player_path = NodePath("../Player")
	_player = existing_player
	if _player and _player is Node2D:
		(_player as Node2D).global_position = Vector2.ZERO

func _reset_or_respawn_player_full() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	_player = _resolve_player()
	if _player == null or not _player.is_inside_tree():
		var main := get_parent()
		if main != null and player_scene:
			_player = player_scene.instantiate()
			_player.name = "Player"
			if _arena:
				_arena.add_child(_player)
			else:
				main.add_child(_player)
			if _player is Node2D:
				(_player as Node2D).global_position = Vector2.ZERO
			player_path = NodePath("../Player")
	elif _arena and _player.get_parent() != _arena:
		var player_node := _player
		if player_node is Node:
			var pos := player_node is Node2D ? (player_node as Node2D).global_position : Vector2.ZERO
			player_node.reparent(_arena)
			if player_node is Node2D:
				(player_node as Node2D).global_position = pos
	if _player != null and _player.has_method("reset_full_health"):
		_player.call("reset_full_health")
	_connect_player_signals()
	_position_player_after_respawn()

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node and is_instance_valid(enemy):
			enemy.queue_free()

func _spawn_wave_or_enemies() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena == null:
		_arena = get_tree().get_first_node_in_group("arena")
	_start_next_arena()

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
	if _arena == null or _is_game_over:
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
	if _is_game_over:
		return
	_waiting_for_bet = false
	set_phase(RunPhase.LIVE)
	_start_next_arena()

func _on_betting_opened() -> void:
	_force_game_over_if_dead()

func _on_wave_started(_wave: int) -> void:
	GameEvents.arena_started.emit(run.arena_index)
	if _bet_manager and _bet_manager.has_method("register_arena_start"):
		_bet_manager.register_arena_start()
	_apply_phase()

func _on_wave_cleared(_wave: int) -> void:
	GameEvents.arena_completed.emit(run.arena_index)
	if _bet_manager and _bet_manager.has_method("resolve_bet"):
		_bet_manager.resolve_bet()
	if arena_clear_reward > 0:
		add_coins(arena_clear_reward)
	_open_bet_ui()

func _on_player_spawned(player: Node) -> void:
	_player = player
	_connect_player_signals()
	_position_player_after_respawn()
	_apply_phase()

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

func _connect_player_signals() -> void:
	_player = _resolve_player()
	if _player == null:
		return
	var died_callable := Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.is_connected("died", died_callable):
		_player.connect("died", died_callable)

func _on_run_failed() -> void:
	_run_failed_emitted = true
	_enter_game_over()

func _on_player_died() -> void:
	_enter_game_over()

func _soft_reset() -> void:
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	if _bet_manager and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.reset_bet_state()
	run.arena_index = 0
	_player = _resolve_player()
	_open_bet_ui()

func _force_game_over_if_dead() -> bool:
	var p := get_tree().get_first_node_in_group("player")
	if p == null:
		return false
	var current_health := _get_player_health_value(p)
	if current_health <= 0 and current_health != -1:
		_enter_game_over()
		return true
	return false

func _get_player_health_value(p: Node) -> int:
	if p.has_method("get_current_health"):
		return int(p.call("get_current_health"))
	if p.has_meta("current_health"):
		return int(p.get_meta("current_health"))
	if p.has_method("get_health"):
		var h: Array = p.call("get_health")
		if h.size() > 0:
			return int(h[0])
	return -1

func _enter_game_over() -> void:
	if _is_game_over:
		return
	_is_game_over = true
	_waiting_for_bet = false
	set_phase(RunPhase.GAME_OVER)
	if not _run_failed_emitted:
		_run_failed_emitted = true
		GameEvents.run_failed.emit()

func get_arena() -> Node:
	return _arena

func get_arena_index() -> int:
	return int(run.get("arena_index", 0))

func is_live() -> bool:
	return phase == RunPhase.LIVE

func set_phase(p: RunPhase) -> void:
	phase = p
	GameEvents.run_phase_changed.emit(int(phase))
	_apply_phase()

func _apply_phase() -> void:
	if GameEvents.has_method("set_gameplay_enabled"):
		GameEvents.set_gameplay_enabled(phase == RunPhase.LIVE)

func _position_player_after_respawn() -> void:
	if _player == null or not (_player is Node2D):
		return
	var spawn_pos := _get_spawn_position()
	(_player as Node2D).global_position = spawn_pos
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("make_current"):
		cam.make_current()
	if cam:
		cam.global_position = (_player as Node2D).global_position

func _get_spawn_position() -> Vector2:
	if _arena and _arena is Node:
		var spawn_node := _find_spawn_node(_arena)
		if spawn_node and spawn_node is Node2D:
			return (spawn_node as Node2D).global_position
		if _arena is Node2D:
			return (_arena as Node2D).global_position
	return Vector2.ZERO

func _find_spawn_node(root: Node) -> Node:
	var direct := root.get_node_or_null("Spawn")
	if direct:
		return direct
	var named := root.find_child("Spawn", true, false)
	if named:
		return named
	var player_spawn := root.find_child("PlayerSpawn", true, false)
	if player_spawn:
		return player_spawn
	return root.find_child("PlayerSpawnPoint", true, false)

func _log_runtime_state(tag: String) -> void:
	var player_node := _resolve_player()
	var player_exists := player_node != null
	var player_in_tree := player_exists and player_node.is_inside_tree()
	var player_physics := player_exists and player_node.is_physics_processing()
	var player_process_mode := player_exists ? player_node.process_mode : -1
	var player_pos := player_exists and player_node is Node2D ? (player_node as Node2D).global_position : Vector2.ZERO

	var enemies := get_tree().get_nodes_in_group("enemies")
	var enemies_count := enemies.size()
	var sample_enemy: Node = enemies_count > 0 ? enemies[0] : null
	var enemy_physics := sample_enemy != null and sample_enemy.is_physics_processing()
	var enemy_process_mode := sample_enemy != null ? sample_enemy.process_mode : -1

	var cam := get_viewport().get_camera_2d()
	var cam_exists := cam != null
	var cam_current := cam_exists and cam.has_method("is_current") and cam.is_current()
	var cam_pos := cam_exists ? cam.global_position : Vector2.ZERO

	print(
		"[runtime:%s] paused=%s gameplay_enabled=%s player_in_tree=%s player_physics=%s player_process_mode=%s player_pos=%s enemies=%s enemy_physics=%s enemy_process_mode=%s cam_exists=%s cam_current=%s cam_pos=%s"
		% [
			tag,
			get_tree().paused,
			GameEvents.gameplay_enabled,
			player_in_tree,
			player_physics,
			player_process_mode,
			player_pos,
			enemies_count,
			enemy_physics,
			enemy_process_mode,
			cam_exists,
			cam_current,
			cam_pos,
		]
	)
