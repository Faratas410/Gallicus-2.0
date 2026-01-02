extends Control

@onready var bar: ProgressBar = $Bar

var _target: Node2D = null
var _anchor: Node2D = null

func _ready() -> void:
	top_level = true
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
	var canvas_transform: Transform2D = get_viewport().get_canvas_transform()
	return canvas_transform.xform(world_pos)

func _process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return

	var anchor: Node2D = _target
	if _anchor != null and is_instance_valid(_anchor):
		anchor = _anchor

	var world_pos: Vector2 = anchor.global_position
	var screen_pos: Vector2 = _world_to_screen(world_pos)
	var half: Vector2 = size * 0.5
	var pos: Vector2 = screen_pos - half
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var vp_size: Vector2 = viewport_rect.size
	var pad: float = 2.0
	pos.x = clampf(pos.x, viewport_rect.position.x + pad, viewport_rect.position.x + vp_size.x - size.x - pad)
	pos.y = clampf(pos.y, viewport_rect.position.y + pad, viewport_rect.position.y + vp_size.y - size.y - pad)
	position = pos
