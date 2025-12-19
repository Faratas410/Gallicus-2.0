extends CharacterBody2D

signal died
signal health_changed(current: int, max: int)

@export var max_health: int = 5
@export var move_speed: float = GameConstants.ENEMY_MOVE_SPEED

const STOP_DISTANCE := 34.0
const WINDUP_TIME := 0.25
const ACTIVE_TIME := 0.10
const RECOVER_TIME := 0.25
const ATTACK_COOLDOWN := 0.65
const ATTACK_DAMAGE := 1
const PERSONAL_SPACE := 22.0
const SEPARATION_FORCE := 120.0

enum EnemyState { CHASE, WINDUP, ATTACK, RECOVER, HITSTUN, DEAD }

var _hp: int = 0
var _target: Node2D
var _base_modulate := Color.WHITE
var _flash_tween: Tween
var _knockback_velocity := Vector2.ZERO
var _knockback_timer := 0.0
var _state: EnemyState = EnemyState.CHASE
var _attack_cooldown: float = 0.0
var _hp_bar: Node2D = null

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Visual/Sprite2D

func _ready() -> void:
	_hp = max_health
	add_to_group("enemies")
	body_shape.disabled = false
	hurtbox.monitoring = true
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox_shape.disabled = true
	_ensure_placeholder_sprite()
	_base_modulate = sprite.modulate
	var bar_scene: PackedScene = preload("res://scenes/ui/EnemyHealthBar.tscn")
	_hp_bar = bar_scene.instantiate() as Node2D
	add_child(_hp_bar)
	health_changed.connect(Callable(_hp_bar, "set_health"))
	health_changed.emit(_hp, max_health)

func _physics_process(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown = max(_attack_cooldown - delta, 0.0)
	if _knockback_timer > 0.0:
		_state = EnemyState.HITSTUN
		velocity = _knockback_velocity
		_knockback_timer = max(_knockback_timer - delta, 0.0)
		move_and_slide()
		if _knockback_timer <= 0.0 and _state != EnemyState.DEAD:
			_state = EnemyState.CHASE
		return
	if _target == null:
		_target = _find_player()
	if _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance := global_position.distance_to(_target.global_position)
	match _state:
		EnemyState.CHASE:
			if distance > STOP_DISTANCE:
				var direction := (_target.global_position - global_position).normalized()
				velocity = direction * move_speed
				if distance < PERSONAL_SPACE:
					var away := (global_position - _target.global_position).normalized()
					velocity += away * SEPARATION_FORCE
				move_and_slide()
			else:
				velocity = Vector2.ZERO
				move_and_slide()
				if _attack_cooldown <= 0.0:
					print("ENEMY begin_attack dist=", distance)
					_begin_attack()
		EnemyState.WINDUP, EnemyState.ATTACK, EnemyState.RECOVER:
			velocity = Vector2.ZERO
			move_and_slide()
		EnemyState.HITSTUN:
			velocity = Vector2.ZERO
			move_and_slide()
		EnemyState.DEAD:
			velocity = Vector2.ZERO

func set_target(target: Node2D) -> void:
	_target = target

func take_damage(amount: int, from: Vector2 = Vector2.ZERO) -> void:
	_hp = max(_hp - amount, 0)
	health_changed.emit(_hp, max_health)
	if from != Vector2.ZERO:
		var dir := (global_position - from).normalized()
		_knockback_velocity = dir * 140.0
		_knockback_timer = 0.12
		_state = EnemyState.HITSTUN
	_flash_visual()
	if _hp <= 0:
		_state = EnemyState.DEAD
		died.emit()
		queue_free()

func _begin_attack() -> void:
	if _state != EnemyState.CHASE:
		return
	_state = EnemyState.WINDUP
	_attack_cooldown = ATTACK_COOLDOWN
	velocity = Vector2.ZERO
	call_deferred("_attack_sequence")

func _attack_sequence() -> void:
	print("ENEMY windup")
	await get_tree().create_timer(WINDUP_TIME).timeout
	if _state == EnemyState.DEAD:
		return
	_state = EnemyState.ATTACK
	print("ENEMY active")
	hitbox.monitoring = true
	hitbox_shape.disabled = false
	await get_tree().create_timer(ACTIVE_TIME).timeout
	hitbox.monitoring = false
	hitbox_shape.disabled = true
	_state = EnemyState.RECOVER
	print("ENEMY recover")
	await get_tree().create_timer(RECOVER_TIME).timeout
	if _state != EnemyState.DEAD:
		_state = EnemyState.CHASE

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area == null:
		return
	var target := area.get_parent()
	if target != null and target.is_in_group("player") and target.has_method("take_damage"):
		print("ENEMY HIT player")
		target.take_damage(1, global_position)

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
