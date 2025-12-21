extends Node2D

signal player_spawned(player: Node2D)
signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_count_changed(count: int)

@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemies/EnemyBasic.tscn")
@export var arena_radius: float = GameConstants.ARENA_RADIUS
@export var base_enemy_count: int = GameConstants.ARENA_BASE_ENEMY_COUNT

var _rng := RandomNumberGenerator.new()
var _current_wave: int = 0
var _enemies_remaining: int = 0
var _player: Node2D

func _ready() -> void:
	print("Arena ready")
	_rng.randomize()
	add_to_group("arena")
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.run_failed.connect(_on_run_failed)
	queue_redraw()
	_spawn_player()
	_spawn_debug_enemy()

func _draw() -> void:
	var floor_size := Vector2(1024.0, 768.0)
	var rect := Rect2(-floor_size * 0.5, floor_size)
	draw_rect(rect, Color(0.15, 0.15, 0.2, 1.0))

func start_next_wave() -> void:
	if _enemies_remaining > 0:
		return
	_current_wave += 1
	_spawn_enemies(base_enemy_count + (_current_wave - 1) * GameConstants.ARENA_ENEMY_INCREMENT)
	wave_started.emit(_current_wave)

func _spawn_player() -> void:
	if _player != null:
		return
	var existing_player := get_tree().get_first_node_in_group("player")
	if existing_player and existing_player is Node2D:
		_player = existing_player
		_player.global_position = global_position
		player_spawned.emit(_player)
		var player_callable := Callable(self, "_on_player_died")
		if _player.has_signal("died") and not _player.is_connected("died", player_callable):
			_player.connect("died", player_callable)
		return
	_player = player_scene.instantiate() as Node2D
	add_child(_player)
	_player.global_position = global_position
	player_spawned.emit(_player)
	var died_callable := Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.is_connected("died", died_callable):
		_player.connect("died", died_callable)

func _spawn_enemies(count: int) -> void:
	_enemies_remaining = count
	enemy_count_changed.emit(_enemies_remaining)
	for i in range(count):
		var enemy := enemy_scene.instantiate() as Node2D
		add_child(enemy)
		var angle := _rng.randf_range(0.0, TAU)
		var radius := _rng.randf_range(arena_radius * 0.5, arena_radius)
		enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * radius
		if enemy.has_signal("died"):
			enemy.connect("died", _on_enemy_died)

func _spawn_debug_enemy() -> void:
	if enemy_scene == null:
		return
	await get_tree().create_timer(0.2).timeout
	var enemy := enemy_scene.instantiate() as Node2D
	add_child(enemy)
	enemy.global_position = Vector2(120.0, 0.0)
	print("Spawned enemy")
	if enemy.has_signal("died"):
		enemy.connect("died", _on_enemy_died)

func _on_enemy_died() -> void:
	_enemies_remaining = max(_enemies_remaining - 1, 0)
	enemy_count_changed.emit(_enemies_remaining)
	if _enemies_remaining == 0:
		wave_cleared.emit(_current_wave)

func _on_player_died() -> void:
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)

func soft_reset() -> void:
	_clear_enemies()
	_reset_player()
	_current_wave = 0

func reset_arena() -> void:
	# elimina nemici
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()
	# se hai proiettili/effects, puliscili qui

func restart_arena() -> void:
	set_process(false)
	set_physics_process(false)
	_current_wave = 0
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()
	set_process(true)
	set_physics_process(true)
	if has_method("start_wave"):
		call("start_wave", 0)
	elif has_method("start_combat"):
		call("start_combat")
	elif has_method("begin"):
		call("begin")
	else:
		start_next_wave()

func _on_run_started() -> void:
	set_process(true)
	set_physics_process(true)

func _on_run_failed() -> void:
	set_process(false)
	set_physics_process(false)

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node and is_ancestor_of(enemy):
			enemy.queue_free()
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)

func _reset_player() -> void:
	if _player and is_instance_valid(_player):
		_player.queue_free()
	_player = null
	_spawn_player()

func get_current_wave() -> int:
	return _current_wave

func get_enemies_remaining() -> int:
	return _enemies_remaining

func get_player() -> Node2D:
	return _player
