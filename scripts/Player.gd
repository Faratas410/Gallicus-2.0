# LEVEL 3 RUNTIME:
# This script must remain passive.
# Gameplay logic preserved only for legacy mode.

extends CharacterBody2D

const LEVEL3_PASSIVE_MODE := true

signal health_changed(current: int, max: int)
signal took_damage(amount: int)
signal died

var _sword_tex_idle: Texture2D = null
var _sword_tex_swing: Texture2D = null
const DAMAGE_INVULN_SECONDS: float = 0.25

@export var move_speed: float = 220.0
@export var max_health: int = 100
@export var light_damage: int = 12
@export var heavy_damage: int = 25
@export var light_range: float = 60.0
@export var heavy_range: float = 90.0
@export var light_cone_angle_deg: float = 90.0
@export var heavy_cone_angle_deg: float = 120.0
@export var light_cooldown: float = 0.30
@export var heavy_cooldown: float = 0.75
@export var dodge_speed: float = 480.0
@export var dodge_cooldown: float = 1.0
@export var block_reduction: float = 0.5

@export var arena_bounds_size: Vector2 = Vector2(1024.0, 768.0)
@export var arena_bounds_margin: float = 16.0

var _current_health: int
var _attack_timer: float = 0.0
var _dodge_timer: float = 0.0
var _is_blocking: bool = false
var _speed_multiplier: float = 1.0
var _speed_boost_token: int = 0
var _last_aim_dir: Vector2 = Vector2.UP
var _is_swinging: bool = false
var _base_max_health: int = 0
var _base_light_damage: int = 0
var _base_heavy_damage: int = 0
var _damage_invuln: float = 0.0
var _heal_multiplier: float = 1.0
var _dodge_cooldown_multiplier: float = 1.0
var _dodge_speed_multiplier: float = 1.0
var input_locked: bool = false
@onready var sword_sprite: Sprite2D = get_node_or_null("SwordSprite") as Sprite2D
@onready var body_sprite: Sprite2D = get_node_or_null("Visual") as Sprite2D

func _ready() -> void:
	if _sword_tex_idle == null:
		_sword_tex_idle = load("res://assets/sprites/weapon_sword.png") as Texture2D
	if _sword_tex_swing == null:
		_sword_tex_swing = load("res://assets/sprites/weapon_sword.png") as Texture2D
	_base_max_health = max_health
	_base_light_damage = light_damage
	_base_heavy_damage = heavy_damage
	_current_health = max_health
	_emit_health()
	_ensure_placeholder_sprite()
	if sword_sprite != null:
		sword_sprite.texture = _sword_tex_idle
	if _is_level3_mode():
		if body_sprite != null:
			body_sprite.visible = false
		if sword_sprite != null:
			sword_sprite.visible = false
		input_locked = true
	if LEVEL3_PASSIVE_MODE:
		input_locked = true
		set_process_input(false)
		set_process(false)
		set_physics_process(false)
	add_to_group("player")
	if Engine.has_singleton("GameEvents") and GameEvents != null:
		if GameEvents.has_signal("gameplay_enabled_changed"):
			var gameplay_callable: Callable = Callable(self, "_on_gameplay_enabled_changed")
			if not GameEvents.gameplay_enabled_changed.is_connected(gameplay_callable):
				GameEvents.gameplay_enabled_changed.connect(gameplay_callable)
		input_locked = not GameEvents.gameplay_enabled

func _physics_process(delta: float) -> void:
	if _is_combat_runtime_disabled():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_dodge_timer = maxf(_dodge_timer - delta, 0.0)
	_damage_invuln = maxf(_damage_invuln - delta, 0.0)

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length_squared() > 0.001:
		_last_aim_dir = input_vector.normalized()
	_update_sword_idle_pose()
	velocity = input_vector * (move_speed * _speed_multiplier * _dodge_speed_multiplier)

	_is_blocking = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("attack_light"):
		_try_attack(light_damage, light_range, light_cooldown, light_cone_angle_deg)
	elif Input.is_action_just_pressed("attack_heavy"):
		_try_attack(heavy_damage, heavy_range, heavy_cooldown, heavy_cone_angle_deg)

	move_and_slide()
	_apply_bounds()

func set_input_locked(locked: bool) -> void:
	if _is_combat_runtime_disabled():
		input_locked = true
		return
	input_locked = locked

func _is_combat_runtime_disabled() -> bool:
	if LEVEL3_PASSIVE_MODE:
		return true
	return _is_level3_mode()

func _is_level3_mode() -> bool:
	var manager: Node = get_tree().get_first_node_in_group("run_manager")
	if manager != null and manager.has_method("is_level3_mode"):
		return bool(manager.call("is_level3_mode"))
	return false

func _on_gameplay_enabled_changed(enabled: bool) -> void:
	set_input_locked(not enabled)

func _apply_bounds() -> void:
	var half: Vector2 = arena_bounds_size * 0.5
	var margin: float = maxf(arena_bounds_margin, 0.0)
	global_position.x = clampf(global_position.x, -half.x + margin, half.x - margin)
	global_position.y = clampf(global_position.y, -half.y + margin, half.y - margin)

func _try_attack(damage: int, attack_range: float, cooldown: float, cone_angle_deg: float) -> void:
	if _is_combat_runtime_disabled():
		return
	if _attack_timer > 0.0:
		return
	_attack_timer = cooldown
	_play_sword_swing()
	_perform_attack(damage, attack_range, cone_angle_deg)

func _dir_to_cardinal(dir: Vector2) -> Vector2:
	if absf(dir.x) > absf(dir.y):
		if dir.x > 0.0:
			return Vector2.RIGHT
		return Vector2.LEFT
	if dir.y > 0.0:
		return Vector2.DOWN
	return Vector2.UP

func _update_sword_idle_pose() -> void:
	if sword_sprite == null:
		return
	if _is_swinging:
		return
	if sword_sprite.texture != _sword_tex_idle:
		sword_sprite.texture = _sword_tex_idle

	var card: Vector2 = _dir_to_cardinal(_last_aim_dir)
	sword_sprite.z_index = 10
	if card == Vector2.UP:
		sword_sprite.z_index = -1

	var base_rot: float = 0.0
	if card == Vector2.UP:
		base_rot = 0.0
	elif card == Vector2.RIGHT:
		base_rot = deg_to_rad(90)
	elif card == Vector2.DOWN:
		base_rot = deg_to_rad(180)
	else:
		base_rot = deg_to_rad(-90)

	sword_sprite.rotation = base_rot

	var offset: Vector2 = Vector2(10, -10)
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

	var card: Vector2 = _dir_to_cardinal(_last_aim_dir)

	var base_rot: float = 0.0
	if card == Vector2.UP:
		base_rot = 0.0
	elif card == Vector2.RIGHT:
		base_rot = deg_to_rad(90)
	elif card == Vector2.DOWN:
		base_rot = deg_to_rad(180)
	else:
		base_rot = deg_to_rad(-90)

	_is_swinging = true
	sword_sprite.texture = _sword_tex_swing
	sword_sprite.rotation = base_rot
	sword_sprite.z_index = 10
	if card == Vector2.UP:
		sword_sprite.z_index = -1

	var swing_a: float = deg_to_rad(-35)
	var swing_b: float = deg_to_rad(35)

	var tween: Tween = create_tween()
	tween.tween_property(sword_sprite, "rotation", base_rot + swing_b, 0.10).from(base_rot + swing_a)
	tween.tween_interval(0.02)
	tween.tween_callback(func() -> void:
		_is_swinging = false
		_update_sword_idle_pose()
	)

func _perform_attack(damage: int, attack_range: float, cone_angle_deg: float) -> void:
	if _is_combat_runtime_disabled():
		return
	var aim: Vector2 = _last_aim_dir
	if aim.length_squared() < 0.0001:
		aim = Vector2.UP
	aim = aim.normalized()

	var cos_limit: float = cos(deg_to_rad(cone_angle_deg * 0.5))

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue
		var enemy_node: Node2D = enemy as Node2D
		var to_enemy: Vector2 = enemy_node.global_position - global_position
		var dist: float = to_enemy.length()
		if dist > attack_range or dist <= 0.001:
			continue

		var dir: Vector2 = to_enemy / dist
		if dir.dot(aim) < cos_limit:
			continue

		if enemy_node.has_method("take_damage"):
			enemy_node.call("take_damage", damage)

func take_damage(amount: int) -> void:
	if _is_combat_runtime_disabled():
		return
	if _damage_invuln > 0.0:
		return
	var final_damage: int = amount
	if _is_blocking:
		var effective_reduction: float = block_reduction / maxf(_dodge_cooldown_multiplier, 0.1)
		effective_reduction = clampf(effective_reduction, 0.0, 1.0)
		final_damage = int(round(amount * (1.0 - effective_reduction)))
	if final_damage > 0:
		_damage_invuln = DAMAGE_INVULN_SECONDS
		took_damage.emit(final_damage)
		if Engine.has_singleton("GameEvents") and GameEvents != null and GameEvents.has_signal("player_damaged"):
			GameEvents.player_damaged.emit()
	_current_health = maxi(_current_health - final_damage, 0)
	_emit_health()
	if _current_health <= 0:
		died.emit()
		queue_free()

func _emit_health() -> void:
	if _is_combat_runtime_disabled():
		return
	health_changed.emit(_current_health, max_health)

func reset_full_health() -> void:
	if _is_combat_runtime_disabled():
		return
	_current_health = max_health
	_emit_health()

func apply_run_upgrades(max_hp_bonus: int, light_bonus: int, heavy_bonus: int) -> void:
	var manager: Node = get_tree().get_first_node_in_group("run_manager")
	if manager != null and manager.has_method("is_level3_mode") and bool(manager.call("is_level3_mode")):
		return
	if _base_max_health <= 0:
		_base_max_health = max_health
	if _base_light_damage <= 0:
		_base_light_damage = light_damage
	if _base_heavy_damage <= 0:
		_base_heavy_damage = heavy_damage
	var previous_max: int = max_health
	var previous_current: int = _current_health
	print("Apply run upgrades: hp_bonus=%d light_bonus=%d heavy_bonus=%d prev_hp=%d/%d" % [
		max_hp_bonus,
		light_bonus,
		heavy_bonus,
		previous_current,
		previous_max
	])
	max_health = maxi(_base_max_health + max_hp_bonus, 1)
	light_damage = _base_light_damage + light_bonus
	heavy_damage = _base_heavy_damage + heavy_bonus
	if max_health != previous_max:
		var delta: int = max_health - previous_max
		_current_health = clampi(previous_current + delta, 0, max_health)
	else:
		_current_health = clampi(previous_current, 0, max_health)
	_emit_health()

func apply_scar_modifiers(heal_multiplier: float, dodge_cooldown_multiplier: float, dodge_speed_multiplier: float) -> void:
	_heal_multiplier = maxf(heal_multiplier, 0.0)
	_dodge_cooldown_multiplier = maxf(dodge_cooldown_multiplier, 0.1)
	_dodge_speed_multiplier = maxf(dodge_speed_multiplier, 0.1)

func get_damage_values() -> Array[int]:
	return [light_damage, heavy_damage]

func heal(amount: int) -> void:
	if _is_combat_runtime_disabled():
		return
	if amount <= 0:
		return
	var scaled: int = int(round(float(amount) * _heal_multiplier))
	if scaled <= 0:
		return
	_current_health = clampi(_current_health + scaled, 0, max_health)
	_emit_health()

func apply_speed_boost(mult: float, seconds: float) -> void:
	if mult <= 0.0 or seconds <= 0.0:
		return
	_speed_multiplier = maxf(_speed_multiplier, mult)
	_speed_boost_token += 1
	var token: int = _speed_boost_token
	await get_tree().create_timer(seconds).timeout
	if token == _speed_boost_token:
		_speed_multiplier = 1.0

func _ensure_placeholder_sprite() -> void:
	var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		sprite = find_child("Sprite2D", true, false) as Sprite2D
	if sprite == null:
		return
	if sprite.texture:
		return
	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.9, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(32.0, 32.0)
