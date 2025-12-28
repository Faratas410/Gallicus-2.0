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

func _process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return

	var anchor: Node2D = _target
	if _anchor != null and is_instance_valid(_anchor):
		anchor = _anchor

	var cam: Camera2D = get_viewport().get_camera_2d() as Camera2D
	if cam == null:
		var cams: Array = get_tree().get_nodes_in_group("cameras")
		for c: Node in cams:
			if c is Camera2D and (c as Camera2D).is_current():
				cam = c as Camera2D
				break
	if cam == null:
		var any_cam: Node = get_tree().get_first_node_in_group("camera_2d")
		if any_cam is Camera2D:
			cam = any_cam as Camera2D
	if cam == null:
		return

	var world_pos: Vector2 = anchor.global_position
	var screen_pos: Vector2 = cam.unproject_position(world_pos)
	var half: Vector2 = size * 0.5
	var pos: Vector2 = screen_pos - half
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var vp_size: Vector2 = viewport_rect.size
	var pad: float = 2.0
	pos.x = clampf(pos.x, viewport_rect.position.x + pad, viewport_rect.position.x + vp_size.x - size.x - pad)
	pos.y = clampf(pos.y, viewport_rect.position.y + pad, viewport_rect.position.y + vp_size.y - size.y - pad)
	position = pos
