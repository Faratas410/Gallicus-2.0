extends CharacterBody2D

signal health_changed(current: int, max: int)
signal died

@export var move_speed: float = 220.0
@export var max_health: int = 100
@export var light_damage: int = 12
@export var heavy_damage: int = 25
@export var light_range: float = 60.0
@export var heavy_range: float = 90.0
@export var light_cooldown: float = 0.35
@export var heavy_cooldown: float = 0.75
@export var dodge_speed: float = 480.0
@export var dodge_cooldown: float = 1.0
@export var block_reduction: float = 0.6

@export var arena_bounds_size: Vector2 = Vector2(1024.0, 768.0)
@export var arena_bounds_margin: float = 16.0

var _current_health: int
var _attack_timer: float = 0.0
var _dodge_timer: float = 0.0
var _is_blocking: bool = false

func _ready() -> void:
	_current_health = max_health
	_emit_health()
	_ensure_placeholder_sprite()

func _physics_process(delta: float) -> void:
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_dodge_timer = maxf(_dodge_timer - delta, 0.0)

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed

	_is_blocking = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("dodge") and _dodge_timer <= 0.0:
		velocity += input_vector.normalized() * dodge_speed
		_dodge_timer = dodge_cooldown

	if Input.is_action_just_pressed("attack_light"):
		_try_attack(light_damage, light_range, light_cooldown)
	elif Input.is_action_just_pressed("attack_heavy"):
		_try_attack(heavy_damage, heavy_range, heavy_cooldown)

	move_and_slide()
	_apply_bounds()

func _apply_bounds() -> void:
	var half := arena_bounds_size * 0.5
	var margin := maxf(arena_bounds_margin, 0.0)
	global_position.x = clampf(global_position.x, -half.x + margin, half.x - margin)
	global_position.y = clampf(global_position.y, -half.y + margin, half.y - margin)

func _try_attack(damage: int, range: float, cooldown: float) -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = cooldown
	_perform_attack(damage, range)

func _perform_attack(damage: int, range: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		var enemy_node := enemy as Node2D
		if global_position.distance_to(enemy_node.global_position) <= range:
			if enemy_node.has_method("take_damage"):
				enemy_node.call("take_damage", damage)

func take_damage(amount: int) -> void:
	var final_damage := amount
	if _is_blocking:
		final_damage = int(round(amount * (1.0 - block_reduction)))
	_current_health = max(_current_health - final_damage, 0)
	_emit_health()
	if _current_health <= 0:
		died.emit()
		queue_free()

func _emit_health() -> void:
	health_changed.emit(_current_health, max_health)

func _ensure_placeholder_sprite() -> void:
	var sprite := $Sprite2D as Sprite2D
	if sprite.texture:
		return
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.9, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(32.0, 32.0)
