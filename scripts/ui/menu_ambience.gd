extends Control

const TORCH_FRAME_SIZE: Vector2i = Vector2i(64, 64)
const TORCH_FRAME_COUNT: int = 4
const TORCH_FPS: float = 8.0
const MENU_CENTER: Vector2 = Vector2(640.0, 360.0)

@export var base_path: NodePath
@export var clouds_path: NodePath
@export var fog_back_path: NodePath
@export var fog_mid_path: NodePath
@export var fog_front_path: NodePath
@export var light_overlay_path: NodePath
@export var statue_path: NodePath
@export var flag_root_path: NodePath
@export var torch_flames_path: NodePath
@export_file("*.png") var torch_strip_path: String = "res://assets/MainMenu/menu_torch_flame_strip_4x64.png"
@export var cloud_speed: float = 4.6
@export var cloud_alpha_base: float = 0.075
@export var cloud_alpha_amplitude: float = 0.018
@export var cloud_alpha_max: float = 0.12
@export var cloud_tint: float = 0.86

var _time: float = 0.0
var _base: Control = null
var _clouds: Control = null
var _fog_back: Control = null
var _fog_mid: Control = null
var _fog_front: Control = null
var _light_overlay: Control = null
var _statue: Control = null
var _flag_root: Node2D = null
var _torch_nodes: Array[AnimatedSprite2D] = []
var _base_position: Vector2 = Vector2.ZERO
var _base_scale: Vector2 = Vector2.ONE
var _cloud_position: Vector2 = Vector2.ZERO
var _cloud_scale: Vector2 = Vector2.ONE
var _fog_positions: Dictionary = {}
var _statue_position: Vector2 = Vector2.ZERO
var _flag_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_base = _resolve_control(base_path, "Base")
	_clouds = _resolve_control(clouds_path, "CloudsLayer")
	_fog_back = _resolve_control(fog_back_path, "FogLayer_Back")
	_fog_mid = _resolve_control(fog_mid_path, "FogLayer_Mid")
	_fog_front = _resolve_control(fog_front_path, "FogLayer_Front")
	_light_overlay = _resolve_control(light_overlay_path, "LightOverlay")
	_statue = _resolve_control(statue_path, "FelixStatue")
	_flag_root = _resolve_node(flag_root_path, "FlagRoot") as Node2D
	_cache_depth_layer_bases()
	_cache_torch_nodes()
	_setup_torch_animation()

func _process(delta: float) -> void:
	_time += delta
	_update_depth_layers()
	_update_clouds(delta)
	_update_fog_layers()
	_update_light_flicker()
	_update_torch_flicker()

func _resolve_node(path: NodePath, fallback_name: String) -> Node:
	if not path.is_empty():
		var explicit_node: Node = get_node_or_null(path)
		if explicit_node != null:
			return explicit_node
	return get_node_or_null(fallback_name)

func _resolve_control(path: NodePath, fallback_name: String) -> Control:
	return _resolve_node(path, fallback_name) as Control

func _cache_depth_layer_bases() -> void:
	if _base != null:
		_base_position = _base.position
		_base_scale = _base.scale
		_base.pivot_offset = MENU_CENTER
	if _clouds != null:
		_cloud_position = _clouds.position
		_cloud_scale = _clouds.scale
		_clouds.pivot_offset = MENU_CENTER
	for fog_layer: Control in [_fog_back, _fog_mid, _fog_front]:
		if fog_layer != null:
			_fog_positions[fog_layer] = fog_layer.position
	if _statue != null:
		_statue_position = _statue.position
		_statue.pivot_offset = MENU_CENTER
	if _flag_root != null:
		_flag_position = _flag_root.position

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
		torch.speed_scale = 1.8 + (_torch_nodes.find(torch) * 0.17)
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

func _update_clouds(_delta: float) -> void:
	if _clouds == null:
		return
	var drift_x: float = sin(_time * 0.035 * cloud_speed) * 8.0
	var drift_y: float = sin(_time * 0.022 * cloud_speed + 1.4) * 2.5
	_clouds.position = _cloud_position + Vector2(drift_x, drift_y)
	_clouds.scale = _cloud_scale + Vector2(0.012, 0.012)
	var cloud_alpha_pulse: float = sin(_time * (cloud_speed * 0.02))
	var clouds_modulate: Color = _clouds.modulate
	clouds_modulate.r = cloud_tint
	clouds_modulate.g = cloud_tint
	clouds_modulate.b = cloud_tint
	clouds_modulate.a = clamp(cloud_alpha_base + (cloud_alpha_pulse * cloud_alpha_amplitude), 0.0, cloud_alpha_max)
	_clouds.modulate = clouds_modulate

func _update_fog_layers() -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	_apply_fog_layer(_fog_back, 0.085 + (sin(t * 0.38) * 0.012), Vector2(sin(t * 0.16) * 5.0, 0.0))
	_apply_fog_layer(_fog_mid, 0.12 + (sin(t * 0.52 + 0.6) * 0.018), Vector2(sin(t * 0.22 + 0.7) * 8.0, 0.0))
	_apply_fog_layer(_fog_front, 0.15 + (sin(t * 0.68 + 1.1) * 0.014), Vector2(sin(t * 0.28 + 1.2) * 11.0, 0.0))

func _apply_fog_layer(fog_layer: Control, alpha: float, offset: Vector2) -> void:
	if fog_layer == null:
		return
	var base_position: Vector2 = _fog_positions.get(fog_layer, fog_layer.position) as Vector2
	fog_layer.position = base_position + offset
	var fog_modulate: Color = fog_layer.modulate
	fog_modulate.a = clamp(alpha, 0.0, 1.0)
	fog_layer.modulate = fog_modulate

func _update_depth_layers() -> void:
	var breath: float = sin(_time * 0.18)
	if _base != null:
		_base.position = _base_position + Vector2(breath * -1.2, 0.0)
		_base.scale = _base_scale + Vector2(0.004, 0.004)
	if _statue != null:
		_statue.position = _statue_position + Vector2(sin(_time * 0.16 + 0.8) * 2.0, cos(_time * 0.12) * 1.0)
		_statue.scale = Vector2.ONE + Vector2(0.003, 0.003)
	if _flag_root != null:
		_flag_root.position = _flag_position + Vector2(sin(_time * 0.42) * 1.0, sin(_time * 0.27) * 0.8)

func _update_light_flicker() -> void:
	if _light_overlay == null:
		return
	var base_alpha: float = 0.22
	var flicker_wave: float = (sin(_time * 2.8) * 0.44) + (sin(_time * 7.1) * 0.28) + (sin(_time * 13.0) * 0.12)
	var overlay_modulate: Color = _light_overlay.modulate
	overlay_modulate.a = clamp(base_alpha + (flicker_wave * 0.045), 0.15, 0.31)
	_light_overlay.modulate = overlay_modulate

func _update_torch_flicker() -> void:
	for index: int in range(_torch_nodes.size()):
		var torch: AnimatedSprite2D = _torch_nodes[index]
		if torch == null:
			continue
		var wave: float = sin(_time * (5.2 + index) + float(index) * 0.9)
		var micro: float = sin(_time * (17.0 + index * 1.7))
		var alpha: float = clamp(0.86 + (wave * 0.08) + (micro * 0.035), 0.68, 1.0)
		var warm: float = clamp(0.9 + (wave * 0.05), 0.78, 1.0)
		torch.modulate = Color(1.0, warm, 0.72, alpha)
		torch.scale = Vector2.ONE * (1.0 + (wave * 0.035))
