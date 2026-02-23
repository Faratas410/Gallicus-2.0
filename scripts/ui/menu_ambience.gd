extends Control

const TORCH_FRAME_SIZE: Vector2i = Vector2i(64, 64)
const TORCH_FRAME_COUNT: int = 4
const TORCH_FPS: float = 8.0

@export var clouds_path: NodePath
@export var fog_back_path: NodePath
@export var fog_mid_path: NodePath
@export var fog_front_path: NodePath
@export var light_overlay_path: NodePath
@export var torch_flames_path: NodePath
@export_file("*.png") var torch_strip_path: String = "res://assets/MainMenu/menu_torch_flame_strip_4x64.png"
@export var cloud_speed: float = 8.0

var _time: float = 0.0
var _clouds: Control = null
var _fog_back: Control = null
var _fog_mid: Control = null
var _fog_front: Control = null
var _light_overlay: Control = null
var _torch_nodes: Array[AnimatedSprite2D] = []

func _ready() -> void:
	_clouds = get_node_or_null(clouds_path) as Control
	_fog_back = get_node_or_null(fog_back_path) as Control
	_fog_mid = get_node_or_null(fog_mid_path) as Control
	_fog_front = get_node_or_null(fog_front_path) as Control
	_light_overlay = get_node_or_null(light_overlay_path) as Control
	_cache_torch_nodes()
	_setup_torch_animation()

func _process(delta: float) -> void:
	_time += delta
	_update_clouds(delta)
	_update_fog_layers()
	_update_light_flicker()

func _cache_torch_nodes() -> void:
	_torch_nodes.clear()
	var torch_root: Node = get_node_or_null(torch_flames_path)
	if torch_root == null:
		return
	if torch_root is AnimatedSprite2D:
		_torch_nodes.append(torch_root as AnimatedSprite2D)
		return
	for child: Node in torch_root.get_children():
		var torch: AnimatedSprite2D = child as AnimatedSprite2D
		if torch != null:
			_torch_nodes.append(torch)

func _setup_torch_animation() -> void:
	if _torch_nodes.is_empty():
		return
	var strip_texture: Texture2D = load(torch_strip_path) as Texture2D
	if strip_texture == null:
		return
	for torch: AnimatedSprite2D in _torch_nodes:
		if torch.sprite_frames == null or not torch.sprite_frames.has_animation(&"default"):
			torch.sprite_frames = _build_torch_frames(strip_texture)
		torch.speed_scale = 2.0
		torch.play(&"default")

func _build_torch_frames(strip_texture: Texture2D) -> SpriteFrames:
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
	return sprite_frames

func _update_clouds(delta: float) -> void:
	if _clouds == null:
		return
	_clouds.position.x -= cloud_speed * delta
	if _clouds.position.x < -1280.0:
		_clouds.position.x = 0.0

func _update_fog_layers() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	_apply_fog_alpha(_fog_back, 0.17 + (sin(t * 0.45) * 0.015))
	_apply_fog_alpha(_fog_mid, 0.25 + (sin(t * 0.6 + 0.6) * 0.02))
	_apply_fog_alpha(_fog_front, 0.33 + (sin(t * 0.75 + 1.1) * 0.025))

func _apply_fog_alpha(fog_layer: Control, alpha: float) -> void:
	if fog_layer == null:
		return
	var fog_modulate: Color = fog_layer.modulate
	fog_modulate.a = clamp(alpha, 0.0, 1.0)
	fog_layer.modulate = fog_modulate

func _update_light_flicker() -> void:
	if _light_overlay == null:
		return
	var base_alpha: float = 0.24
	var flicker_wave: float = (sin(_time * 3.2) * 0.5) + (sin(_time * 8.9) * 0.35)
	var overlay_modulate: Color = _light_overlay.modulate
	overlay_modulate.a = clamp(base_alpha + (flicker_wave * 0.05), 0.16, 0.34)
	_light_overlay.modulate = overlay_modulate
