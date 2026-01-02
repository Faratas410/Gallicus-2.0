extends Control

@onready var bar: ProgressBar = $Bar

var _target: Node2D = null
var _anchor: Node2D = null

func _ready() -> void:
	z_index = 200

func set_target(target: Node2D, anchor: Node2D) -> void:
	_target = target
	_anchor = anchor

func set_health(current: int, maxh: int) -> void:
	var safe_max: int = maxi(maxh, 1)
	var safe_current: int = clampi(current, 0, safe_max)
	if bar == null:
		return
	bar.max_value = float(safe_max)
	bar.value = float(safe_current)

func _world_to_screen(world_pos: Vector2) -> Vector2:
	var viewport: Viewport = get_viewport()
	var cam: Camera2D = viewport.get_camera_2d()
	if cam != null:
		var cam_transform: Transform2D = cam.get_canvas_transform()
		return cam_transform * world_pos
	var fallback_transform: Transform2D = viewport.get_canvas_transform()
	return fallback_transform * world_pos

func _process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return

	var anchor: Node2D = _target
	if _anchor != null and is_instance_valid(_anchor):
		anchor = _anchor

	var world_pos: Vector2 = anchor.global_position
	var screen_pos: Vector2 = _world_to_screen(world_pos)
	var bar_size: Vector2 = size
	if bar_size == Vector2.ZERO:
		if bar != null and bar.size != Vector2.ZERO:
			bar_size = bar.size
		elif custom_minimum_size != Vector2.ZERO:
			bar_size = custom_minimum_size
	var offset: Vector2 = -(bar_size * 0.5)
	var pos: Vector2 = screen_pos + offset
	if bar_size != Vector2.ZERO:
		var viewport_rect: Rect2 = get_viewport().get_visible_rect()
		var vp_size: Vector2 = viewport_rect.size
		var pad: float = 2.0
		pos.x = clampf(pos.x, pad, vp_size.x - bar_size.x - pad)
		pos.y = clampf(pos.y, pad, vp_size.y - bar_size.y - pad)
	position = pos
