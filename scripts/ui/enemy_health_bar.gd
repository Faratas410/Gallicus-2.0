extends Control

@export var target_path: NodePath

@onready var bar: ProgressBar = $Bar

var _enemy: Node2D
var _anchor: Node2D

func _ready() -> void:
	if target_path != NodePath():
		var target: Node = get_node_or_null(target_path)
		if target is Node2D:
			set_target(target, target)

func set_target(enemy: Node2D, anchor: Node2D) -> void:
	_enemy = enemy
	_anchor = anchor

func _process(_delta: float) -> void:
	if _enemy == null or _anchor == null:
		visible = false
		return
	if not _enemy.is_inside_tree() or _enemy.is_queued_for_deletion():
		visible = false
		return
	var camera: Camera2D = get_viewport().get_camera_2d() as Camera2D
	if camera == null:
		visible = false
		return
	var screen_pos: Vector2 = camera.unproject_position(_anchor.global_position)
	global_position = screen_pos - Vector2(size.x * 0.5, size.y)
	visible = true
	_update_health()

func _update_health() -> void:
	if _enemy == null or bar == null:
		return
	var current: int = 0
	var max_health: int = 1
	if _enemy.has_method("get_health"):
		var health: Array[int] = _enemy.call("get_health") as Array[int]
		if health.size() >= 2:
			current = maxi(health[0], 0)
			max_health = maxi(health[1], 1)
	bar.max_value = float(max_health)
	bar.value = float(current)
