extends Node2D

signal died

@export var move_speed: float = 140.0

var _heal_multiplier: float = 1.0
var _dodge_cooldown_multiplier: float = 1.0
var _dodge_speed_multiplier: float = 1.0

func _ready() -> void:
	add_to_group("player")
	_ensure_placeholder_sprite()
	set_process(false)
	set_physics_process(false)

func apply_scar_modifiers(heal_multiplier: float, dodge_cooldown_multiplier: float, dodge_speed_multiplier: float) -> void:
	_heal_multiplier = maxf(heal_multiplier, 0.0)
	_dodge_cooldown_multiplier = maxf(dodge_cooldown_multiplier, 0.1)
	_dodge_speed_multiplier = maxf(dodge_speed_multiplier, 0.1)

func apply_speed_boost(_mult: float, _seconds: float) -> void:
	pass

func _ensure_placeholder_sprite() -> void:
	var sprite: Sprite2D = get_node_or_null("Visual") as Sprite2D
	if sprite == null:
		return
	if sprite.texture != null:
		return
	var image: Image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.9, 0.2, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(32.0, 32.0)
