extends Node2D

signal player_spawned(player: Node2D)
signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_count_changed(count: int)

@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemies/EnemyBasic.tscn")
@export var arena_radius: float = 280.0
@export var base_enemy_count: int = 3

var _rng := RandomNumberGenerator.new()
var _current_wave: int = 0
var _enemies_remaining: int = 0
var _player: Node2D

func _ready() -> void:
	_rng.randomize()
	_spawn_player()

func start_next_wave() -> void:
	if _enemies_remaining > 0:
		return
	_current_wave += 1
	_spawn_enemies(base_enemy_count + (_current_wave - 1) * 2)
	wave_started.emit(_current_wave)

func _spawn_player() -> void:
	if _player != null:
		return
	_player = player_scene.instantiate() as Node2D
	add_child(_player)
	_player.global_position = global_position
	player_spawned.emit(_player)
	if _player.has_signal("died"):
		_player.connect("died", _on_player_died)

func _spawn_enemies(count: int) -> void:
	_enemies_remaining = count
	enemy_count_changed.emit(_enemies_remaining)
	for i in range(count):
		var enemy := enemy_scene.instantiate() as Node2D
		add_child(enemy)
		var angle := _rng.randf_range(0.0, TAU)
		var radius := _rng.randf_range(arena_radius * 0.5, arena_radius)
		enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * radius
		if enemy.has_method("set_target"):
			enemy.call("set_target", _player)
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

func get_current_wave() -> int:
	return _current_wave

func get_enemies_remaining() -> int:
	return _enemies_remaining

func get_player() -> Node2D:
	return _player
