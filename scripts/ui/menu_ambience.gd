extends Control

const TORCH_FRAME_SIZE: Vector2i = Vector2i(64, 64)
const TORCH_FRAME_COUNT: int = 4
const TORCH_FPS: float = 8.0

@export var clouds_path: NodePath
@export var fog_path: NodePath
@export var light_overlay_path: NodePath
@export var torch_flames_path: NodePath
@export_file("*.png") var torch_strip_path: String = "res://assets/MainMenu/menu_torch_flame_strip_4x64.png"
@export var cloud_speed: float = 8.0
@export var fog_speed: float = 3.0

var _time: float = 0.0
var _clouds: Control = null
var _fog: Control = null
var _light_overlay: Control = null
var _torch_nodes: Array[AnimatedSprite2D] = []

func _ready() -> void:
	_clouds = get_node_or_null(clouds_path) as Control
	_fog = get_node_or_null(fog_path) as Control
	_light_overlay = get_node_or_null(light_overlay_path) as Control
	_cache_torch_nodes()
	_setup_torch_animation()
	if _fog != null:
		_fog.modulate = Color(1, 1, 1, 0.15)

func _process(delta: float) -> void:
	_time += delta
	_update_clouds(delta)
	_update_fog(delta)
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

func _update_fog(delta: float) -> void:
	if _fog == null:
		return
	_fog.position.x -= fog_speed * delta
	if _fog.position.x < -1280.0:
		_fog.position.x = 0.0
	var t: float = Time.get_ticks_msec() / 1000.0
	var fog_modulate: Color = _fog.modulate
	fog_modulate.a = 0.12 + sin(t * 1.5) * 0.03
	_fog.modulate = fog_modulate

func _update_light_flicker() -> void:
	if _light_overlay == null:
		return
	var base_alpha: float = 0.24
	var flicker_wave: float = (sin(_time * 3.2) * 0.5) + (sin(_time * 8.9) * 0.35)
	var overlay_modulate: Color = _light_overlay.modulate
	overlay_modulate.a = clamp(base_alpha + (flicker_wave * 0.05), 0.16, 0.34)
	_light_overlay.modulate = overlay_modulate
