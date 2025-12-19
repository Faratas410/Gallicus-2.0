extends CharacterBody2D

signal died

const CHASE_RANGE := 220.0
const ATTACK_RANGE := 40.0
const ATTACK_WINDUP := 0.12
const ATTACK_ACTIVE := 0.10
const ATTACK_RECOVERY := 0.25
const FLASH_DURATION := 0.08

@export var max_hp: int = 3
@export var move_speed: float = 95.0

var hp: int
var _target: Node2D
var _is_attacking: bool = false
var _base_modulate := Color.WHITE
var _flash_tween: Tween

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var sprite: Sprite2D = $Visual/Sprite2D

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")
	_set_hitbox_active(false)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_ensure_placeholder_sprite()
	_base_modulate = sprite.modulate

func _physics_process(_delta: float) -> void:
	if _is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance := global_position.distance_to(_target.global_position)
	if distance <= ATTACK_RANGE:
		_start_attack()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if distance <= CHASE_RANGE:
		var direction := (_target.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
		return

	velocity = Vector2.ZERO
	move_and_slide()

func set_target(target: Node2D) -> void:
	_target = target

func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	_flash_visual()
	if hp <= 0:
		died.emit()
		queue_free()

func _start_attack() -> void:
	if _is_attacking:
		return
	_is_attacking = true
	await get_tree().create_timer(ATTACK_WINDUP).timeout
	if not is_inside_tree():
		return
	_set_hitbox_active(true)
	await get_tree().create_timer(ATTACK_ACTIVE).timeout
	_set_hitbox_active(false)
	await get_tree().create_timer(ATTACK_RECOVERY).timeout
	_is_attacking = false

func _set_hitbox_active(active: bool) -> void:
	hitbox.monitoring = active
	hitbox_shape.disabled = not active

func _on_hitbox_body_entered(body: Node) -> void:
	if not _is_attacking:
		return
	if body == self:
		return
	if body.has_method("take_damage"):
		body.call("take_damage", 1, global_position)

func _flash_visual() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", _base_modulate, FLASH_DURATION)

func _ensure_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.85, 0.2, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(24.0, 24.0)
