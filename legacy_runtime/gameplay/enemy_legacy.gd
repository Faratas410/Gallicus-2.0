# DEPRECATED: legacy enemy runtime artifact. Do not edit.
extends CharacterBody2D

signal died

@export var move_speed: float = 150.0
@export var max_health: int = 40
@export var touch_damage: int = 8
@export var exp_on_death: int = 1

var _current_health: int
var _target: Node2D
var _is_dead: bool = false

func _ready() -> void:
	_apply_tier_scaling_from_run_manager()
	_current_health = max_health
	add_to_group("enemies")
	_ensure_placeholder_sprite()

func _physics_process(delta: float) -> void:
	if _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var direction := (_target.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	_try_touch_damage()

func set_target(target: Node2D) -> void:
	_target = target

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	_current_health = maxi(_current_health - amount, 0)
	if _current_health <= 0:
		_is_dead = true
		_emit_exp_on_death()
		died.emit()
		queue_free()

func _try_touch_damage() -> void:
	if _target == null:
		return
	if global_position.distance_to(_target.global_position) <= 28.0:
		if _target.has_method("take_damage"):
			_target.call("take_damage", touch_damage)

func _ensure_placeholder_sprite() -> void:
	var sprite := $Sprite2D as Sprite2D
	if sprite.texture:
		return
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.85, 0.2, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(28.0, 28.0)

func _emit_exp_on_death() -> void:
	if Engine.has_singleton("GameEvents") and GameEvents != null:
		GameEvents.enemy_killed.emit(exp_on_death)

func _apply_tier_scaling_from_run_manager() -> void:
	# Tier scaling "a scatti": the RunManager exposes get_difficulty_multiplier().
	# This makes scaling effective without needing Arena spawn changes.
	var rm := get_tree().get_first_node_in_group("run_manager")
	if rm == null:
		return

	var mult := 1.0
	if rm.has_method("get_difficulty_multiplier"):
		mult = float(rm.call("get_difficulty_multiplier"))
	elif rm.has_method("get_difficulty_tier"):
		var tier := int(rm.call("get_difficulty_tier"))
		mult = 1.0 + (0.15 * float(tier))

	if mult <= 1.0:
		return

	# Apply to exported stats (safe, deterministic).
	max_health = int(round(float(max_health) * mult))
	move_speed = move_speed * mult
	touch_damage = int(round(float(touch_damage) * mult))
