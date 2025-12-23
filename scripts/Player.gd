extends CharacterBody2D

signal health_changed(current: int, max: int)
signal took_damage(amount: int)
signal died

const SWORD_TEX_IDLE := preload("res://assets/sprites/player/sword_idle_up_32.png")
const SWORD_TEX_SWING := preload("res://assets/sprites/player/sword_swing_horizontal_32.png")

@export var move_speed: float = 220.0
@export var max_health: int = 100
@export var light_damage: int = 6
@export var heavy_damage: int = 10
@export var light_range: float = 60.0
@export var heavy_range: float = 90.0
@export var light_cone_angle_deg: float = 90.0
@export var heavy_cone_angle_deg: float = 120.0
@export var light_cooldown: float = 0.30
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
var coins: int = 0
var _speed_multiplier: float = 1.0
var _speed_boost_token: int = 0
var _last_aim_dir: Vector2 = Vector2.UP
var _is_swinging: bool = false
@onready var sword_sprite: Sprite2D = get_node_or_null("SwordSprite") as Sprite2D

func _ready() -> void:
	_current_health = max_health
	_emit_health()
	_ensure_placeholder_sprite()
	if sword_sprite != null:
		sword_sprite.texture = SWORD_TEX_IDLE
	add_to_group("player")

func _physics_process(delta: float) -> void:
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_dodge_timer = maxf(_dodge_timer - delta, 0.0)

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length_squared() > 0.001:
		_last_aim_dir = input_vector.normalized()
	_update_sword_idle_pose()
	velocity = input_vector * (move_speed * _speed_multiplier)

	_is_blocking = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("dodge") and _dodge_timer <= 0.0:
		velocity += input_vector.normalized() * dodge_speed
		_dodge_timer = dodge_cooldown

	if Input.is_action_just_pressed("attack_light"):
		_try_attack(light_damage, light_range, light_cooldown, light_cone_angle_deg)
	elif Input.is_action_just_pressed("attack_heavy"):
		_try_attack(heavy_damage, heavy_range, heavy_cooldown, heavy_cone_angle_deg)

	move_and_slide()
	_apply_bounds()

func _apply_bounds() -> void:
	var half := arena_bounds_size * 0.5
	var margin := maxf(arena_bounds_margin, 0.0)
	global_position.x = clampf(global_position.x, -half.x + margin, half.x - margin)
	global_position.y = clampf(global_position.y, -half.y + margin, half.y - margin)

func _try_attack(damage: int, range: float, cooldown: float, cone_angle_deg: float) -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = cooldown
	_play_sword_swing()
	_perform_attack(damage, range, cone_angle_deg)

func _dir_to_cardinal(dir: Vector2) -> Vector2:
	if absf(dir.x) > absf(dir.y):
		return Vector2.RIGHT if dir.x > 0.0 else Vector2.LEFT
	return Vector2.DOWN if dir.y > 0.0 else Vector2.UP

func _update_sword_idle_pose() -> void:
	if sword_sprite == null:
		return
	if _is_swinging:
		return
	if sword_sprite.texture != SWORD_TEX_IDLE:
		sword_sprite.texture = SWORD_TEX_IDLE

	var card := _dir_to_cardinal(_last_aim_dir)
	sword_sprite.z_index = -1 if card == Vector2.UP else 10

	var base_rot := 0.0
	if card == Vector2.UP:
		base_rot = 0.0
	elif card == Vector2.RIGHT:
		base_rot = deg_to_rad(90)
	elif card == Vector2.DOWN:
		base_rot = deg_to_rad(180)
	else:
		base_rot = deg_to_rad(-90)

	sword_sprite.rotation = base_rot

	var offset := Vector2(10, -10)
	if card == Vector2.UP:
		offset = Vector2(6, -18)
	elif card == Vector2.RIGHT:
		offset = Vector2(14, 0)
	elif card == Vector2.DOWN:
		offset = Vector2(-8, 10)
	else:
		offset = Vector2(-14, 0)

	sword_sprite.position = offset

func _play_sword_swing() -> void:
	if sword_sprite == null:
		return

	var card := _dir_to_cardinal(_last_aim_dir)

	var base_rot := 0.0
	if card == Vector2.UP:
		base_rot = 0.0
	elif card == Vector2.RIGHT:
		base_rot = deg_to_rad(90)
	elif card == Vector2.DOWN:
		base_rot = deg_to_rad(180)
	else:
		base_rot = deg_to_rad(-90)

	_is_swinging = true
	sword_sprite.texture = SWORD_TEX_SWING
	sword_sprite.rotation = base_rot
	sword_sprite.z_index = -1 if card == Vector2.UP else 10

	var swing_a := deg_to_rad(-35)
	var swing_b := deg_to_rad(35)

	var tween := create_tween()
	tween.tween_property(sword_sprite, "rotation", base_rot + swing_b, 0.10).from(base_rot + swing_a)
	tween.tween_interval(0.02)
	tween.tween_callback(func() -> void:
		_is_swinging = false
		_update_sword_idle_pose()
	)

func _perform_attack(damage: int, range: float, cone_angle_deg: float) -> void:
	var aim := _last_aim_dir
	if aim.length_squared() < 0.0001:
		aim = Vector2.UP
	aim = aim.normalized()

	var cos_limit := cos(deg_to_rad(cone_angle_deg * 0.5))

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		var enemy_node := enemy as Node2D
		var to_enemy: Vector2 = enemy_node.global_position - global_position
		var dist: float = to_enemy.length()
		if dist > range or dist <= 0.001:
			continue

		var dir := to_enemy / dist
		if dir.dot(aim) < cos_limit:
			continue

		if enemy_node.has_method("take_damage"):
			enemy_node.call("take_damage", damage)

func take_damage(amount: int) -> void:
	var final_damage := amount
	if _is_blocking:
		final_damage = int(round(amount * (1.0 - block_reduction)))
	if final_damage > 0:
		took_damage.emit(final_damage)
		if Engine.has_singleton("GameEvents") and GameEvents != null and GameEvents.has_signal("player_damaged"):
			GameEvents.player_damaged.emit()
	_current_health = max(_current_health - final_damage, 0)
	_emit_health()
	if _current_health <= 0:
		died.emit()
		queue_free()

func _emit_health() -> void:
	health_changed.emit(_current_health, max_health)

func heal(amount: int) -> void:
	if amount <= 0:
		return
	_current_health = clampi(_current_health + amount, 0, max_health)
	_emit_health()

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount

func apply_speed_boost(mult: float, seconds: float) -> void:
	if mult <= 0.0 or seconds <= 0.0:
		return
	_speed_multiplier = max(_speed_multiplier, mult)
	_speed_boost_token += 1
	var token := _speed_boost_token
	await get_tree().create_timer(seconds).timeout
	if token == _speed_boost_token:
		_speed_multiplier = 1.0

func _ensure_placeholder_sprite() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		sprite = find_child("Sprite2D", true, false) as Sprite2D
	if sprite == null:
		return
	if sprite.texture:
		return
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.9, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(32.0, 32.0)
