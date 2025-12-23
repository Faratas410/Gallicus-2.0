extends Node2D

@export var spawn_interval: float = 4.0
@export var spawn_area: Rect2 = Rect2(-480, -352, 960, 704)
@export var max_alive: int = 3
@export var weight_speed: float = 1.0
@export var weight_heal: float = 1.0
@export var weight_coins: float = 1.0

@export var speed_scene: PackedScene = preload("res://scenes/pickups/Pickup_SpeedBoost.tscn")
@export var heal_scene: PackedScene = preload("res://scenes/pickups/Pickup_Heal.tscn")
@export var coins_scene: PackedScene = preload("res://scenes/pickups/Pickup_Coins.tscn")

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_spawn_loop()

func _spawn_loop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(spawn_interval).timeout
		_try_spawn()

func _try_spawn() -> void:
	if max_alive > 0 and get_tree().get_nodes_in_group("pickups").size() >= max_alive:
		return
	var scene := _pick_scene()
	if scene == null:
		return
	var pickup := scene.instantiate()
	add_child(pickup)
	if pickup is Node2D:
		var offset := Vector2(
			_rng.randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
			_rng.randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		)
		(pickup as Node2D).global_position = global_position + offset

func _pick_scene() -> PackedScene:
	var total: float = maxf(weight_speed, 0.0) + maxf(weight_heal, 0.0) + maxf(weight_coins, 0.0)
	if total <= 0.0:
		return speed_scene
	var roll: float = _rng.randf() * total
	if roll < weight_speed:
		return speed_scene
	roll -= weight_speed
	if roll < weight_heal:
		return heal_scene
	return coins_scene
