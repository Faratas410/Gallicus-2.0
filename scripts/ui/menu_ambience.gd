extends Control

const TORCH_FRAME_SIZE: Vector2i = Vector2i(64, 64)
const TORCH_FRAME_COUNT: int = 4
const TORCH_FPS: float = 1.4

@export var clouds_path: NodePath
@export var fog_path: NodePath
@export var light_overlay_path: NodePath
@export var torch_flames_path: NodePath
@export_file("*.png") var torch_strip_path: String = "res://assets/MainMenu/menu_torch_flame_strip_4x64.png"

var _time: float = 0.0
var _clouds: Control = null
var _fog: Control = null
var _light_overlay: Control = null
var _torch_flames: AnimatedSprite2D = null

func _ready() -> void:
	_clouds = get_node_or_null(clouds_path) as Control
	_fog = get_node_or_null(fog_path) as Control
	_light_overlay = get_node_or_null(light_overlay_path) as Control
	_torch_flames = get_node_or_null(torch_flames_path) as AnimatedSprite2D
	_setup_torch_animation()

func _process(delta: float) -> void:
	_time += delta
	_update_clouds()
	_update_fog()
	_update_light_flicker()


func _setup_torch_animation() -> void:
	if _torch_flames == null:
		return
	if _torch_flames.sprite_frames != null and _torch_flames.sprite_frames.has_animation(&"default"):
		_torch_flames.play(&"default")
		return
	var strip_texture: Texture2D = load(torch_strip_path) as Texture2D
	if strip_texture == null:
		return
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	if not sprite_frames.has_animation(&"default"):
		sprite_frames.add_animation(&"default")
	sprite_frames.set_animation_loop(&"default", true)
	sprite_frames.set_animation_speed(&"default", TORCH_FPS)
	for frame_index: int in range(TORCH_FRAME_COUNT):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = strip_texture
		atlas.region = Rect2(float(frame_index * TORCH_FRAME_SIZE.x), 0.0, float(TORCH_FRAME_SIZE.x), float(TORCH_FRAME_SIZE.y))
		sprite_frames.add_frame(&"default", atlas)
	_torch_flames.sprite_frames = sprite_frames
	_torch_flames.play(&"default")

func _update_clouds() -> void:
	if _clouds == null:
		return
	_clouds.position.x = sin(_time * 0.08) * 22.0

func _update_fog() -> void:
	if _fog == null:
		return
	_fog.position.x = sin((_time * 0.05) + 0.8) * 18.0

func _update_light_flicker() -> void:
	if _light_overlay == null:
		return
	var base_alpha: float = 0.24
	var flicker_wave: float = (sin(_time * 3.2) * 0.5) + (sin(_time * 8.9) * 0.35)
	var overlay_modulate: Color = _light_overlay.modulate
	overlay_modulate.a = clamp(base_alpha + (flicker_wave * 0.05), 0.16, 0.34)
	_light_overlay.modulate = overlay_modulate
