extends CharacterBody2D

signal died
signal health_changed(current: int, max: int)

@export var move_speed: float = GameConstants.ENEMY_MOVE_SPEED
@export var max_health: int = 18
@export var touch_damage: int = 1
@export var touch_range: float = 56.0
@export var touch_cooldown: float = 0.55
@export var stop_distance: float = 0.0

var _current_health: int
var _target: Node2D
var _touch_timer: float = 0.0
var _hp_bar: Node2D = null
var _run_phase: int = 0
var _run_manager: Node
var _knockback_velocity := Vector2.ZERO
var _knockback_timer := 0.0
var _base_modulate := Color.WHITE
var _flash_tween: Tween

@onready var sprite: Sprite2D = $Visual/Sprite2D

func _ready() -> void:
	_current_health = max_health
	add_to_group("enemies")
	_run_manager = get_tree().get_first_node_in_group("run_manager")
	if GameEvents.has_signal("run_phase_changed"):
		GameEvents.run_phase_changed.connect(_on_run_phase_changed)
	_ensure_placeholder_sprite()
	_base_modulate = sprite.modulate
	var bar_scene: PackedScene = preload("res://scenes/ui/EnemyHealthBar.tscn")
	_hp_bar = bar_scene.instantiate() as Node2D
	add_child(_hp_bar)
	health_changed.connect(Callable(_hp_bar, "set_health"))
	health_changed.emit(_current_health, max_health)

func _physics_process(delta: float) -> void:
	if not GameEvents.gameplay_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_touch_timer = maxf(_touch_timer - delta, 0.0)
	if not _is_run_live():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if _knockback_timer > 0.0:
		velocity = _knockback_velocity
		_knockback_timer = max(_knockback_timer - delta, 0.0)
		move_and_slide()
		return
	if _target == null:
		_target = _find_player()
	if _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_target: Vector2 = _target.global_position - global_position
	var dist: float = to_target.length()
	var effective_stop := maxf(stop_distance, touch_range - 6.0)
	if dist <= effective_stop:
		velocity = Vector2.ZERO
	else:
		var direction: Vector2 = to_target / max(dist, 0.001)
		velocity = direction * move_speed
	move_and_slide()
	_try_touch_damage(dist)

func set_target(target: Node2D) -> void:
	_target = target

func take_damage(amount: int, from: Vector2 = Vector2.ZERO) -> void:
	_current_health = max(_current_health - amount, 0)
	health_changed.emit(_current_health, max_health)
	if from != Vector2.ZERO:
		var dir := (global_position - from).normalized()
		_knockback_velocity = dir * 140.0
		_knockback_timer = 0.12
	_flash_visual()
	if _current_health <= 0:
		died.emit()
		queue_free()

func _try_touch_damage(dist_to_target: float) -> void:
	if _target == null:
		return
	if _touch_timer > 0.0:
		return
	if dist_to_target <= touch_range:
		if _target.has_method("take_damage"):
			_target.call("take_damage", touch_damage)
			_touch_timer = touch_cooldown

func _flash_visual() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", _base_modulate, GameConstants.ENEMY_FLASH_DURATION)

func _find_player() -> Node2D:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player is Node2D:
		return player
	return null

func _ensure_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.85, 0.2, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(24.0, 24.0)

func _is_run_live() -> bool:
	if _run_manager != null and _run_manager.has_method("is_live"):
		return bool(_run_manager.call("is_live"))
	return _run_phase == 1

func _on_run_phase_changed(phase: int) -> void:
	_run_phase = phase
