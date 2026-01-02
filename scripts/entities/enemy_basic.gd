extends CharacterBody2D

signal health_changed(current: int, max: int)
signal died

# --- Base stats (these are the "tier 0" reference values) ---
@export var base_move_speed: float = 150.0
@export var base_max_health: int = 35
@export var base_touch_damage: int = 8
@export var exp_on_death: int = 1

# Optional: allow fine tuning scaling without changing global difficulty multiplier
@export var hp_scale: float = 1.0
@export var damage_scale: float = 1.0
@export var speed_scale: float = 1.0

var move_speed: float
var max_health: int
var touch_damage: int

const TOUCH_COOLDOWN: float = 0.6

var _current_health: int = 0
var _target: Node2D = null
var _is_dead: bool = false
var _last_mult: float = 1.0
var _touch_cd: float = 0.0
var _health_bar: Node = null
var ai_locked: bool = false

func _ready() -> void:
	add_to_group("enemies")
	_reset_to_base()
	_emit_health()

func _physics_process(delta: float) -> void:
	if ai_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if _is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _target == null or not is_instance_valid(_target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_touch_cd = maxf(_touch_cd - delta, 0.0)
	var dir: Vector2 = (_target.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()
	_try_touch_damage()

# Called by Arena when spawning enemies
func set_target(target: Node2D) -> void:
	_target = target

func set_ai_locked(locked: bool) -> void:
	ai_locked = locked

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	if amount <= 0:
		return
	_current_health = maxi(_current_health - amount, 0)
	_emit_health()
	if _current_health <= 0:
		_die()

func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	# Emit EXP on death (if the signal exists in your current GameEvents)
	if Engine.has_singleton("GameEvents") and GameEvents != null:
		if GameEvents.has_signal("enemy_killed"):
			GameEvents.enemy_killed.emit(exp_on_death)

	died.emit()
	queue_free()

func _try_touch_damage() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	if _touch_cd > 0.0:
		return
	if global_position.distance_to(_target.global_position) <= 28.0:
		if _target.has_method("take_damage"):
			_target.call("take_damage", touch_damage)
			_touch_cd = TOUCH_COOLDOWN

# --- Difficulty scaling API ---
# Preferred: Arena calls this immediately after instantiation.
func apply_difficulty(mult: float) -> void:
	_last_mult = maxf(mult, 0.05)

	# Scale stats
	move_speed = base_move_speed * (_last_mult * speed_scale)
	max_health = int(round(float(base_max_health) * (_last_mult * hp_scale)))
	touch_damage = int(round(float(base_touch_damage) * (sqrt(_last_mult) * damage_scale)))

	# Clamp & keep current health consistent:
	if max_health < 1:
		max_health = 1
	if touch_damage < 1:
		touch_damage = 1
	if move_speed < 10.0:
		move_speed = 10.0

	# If we are fresh spawn, current health might still be 0
	if _current_health <= 0:
		_current_health = max_health
	else:
		_current_health = mini(_current_health, max_health)
	_emit_health()

# Backward-compat hook: some code may still call this name.
func _apply_tier_scaling_from_run_manager() -> void:
	# If something else sets tier/mult globally, at least keep last applied.
	apply_difficulty(_last_mult)

func _reset_to_base() -> void:
	move_speed = base_move_speed
	max_health = base_max_health
	touch_damage = base_touch_damage
	_current_health = max_health
	_last_mult = 1.0
	_emit_health()

func get_health() -> Array[int]:
	var health: Array[int] = [_current_health, max_health]
	return health

func _emit_health() -> void:
	if _health_bar == null:
		var health_bar_node: Node = get_node_or_null("HealthBar")
		if health_bar_node != null and health_bar_node.has_method("set_health"):
			_health_bar = health_bar_node
	if _health_bar != null:
		_health_bar.call("set_health", _current_health, max_health)
	health_changed.emit(_current_health, max_health)
