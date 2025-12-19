extends CharacterBody2D

signal died

@export var max_hp: int = GameConstants.ENEMY_MAX_HP
@export var move_speed: float = GameConstants.ENEMY_MOVE_SPEED

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
		_target = _find_player()
	if _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance := global_position.distance_to(_target.global_position)
	if distance <= GameConstants.ENEMY_ATTACK_RANGE:
		_start_attack()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if distance <= GameConstants.ENEMY_CHASE_RANGE:
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
	await get_tree().create_timer(GameConstants.ENEMY_ATTACK_WINDUP).timeout
	if not is_inside_tree():
		return
	_set_hitbox_active(true)
	await get_tree().create_timer(GameConstants.ENEMY_ATTACK_ACTIVE).timeout
	_set_hitbox_active(false)
	await get_tree().create_timer(GameConstants.ENEMY_ATTACK_RECOVERY).timeout
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
		body.call("take_damage", GameConstants.ENEMY_ATTACK_DAMAGE, global_position)

func _flash_visual() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", _base_modulate, GameConstants.ENEMY_FLASH_DURATION)

func _find_player() -> Node2D:
	var player := get_tree().get_first_node_in_group("player")
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
