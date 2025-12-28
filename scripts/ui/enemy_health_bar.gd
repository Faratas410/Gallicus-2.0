extends Node2D

@export var y_offset: float = -24.0
@export var bar_width: float = 28.0
@export var bar_height: float = 4.0
@export var background_color: Color = Color(0.1, 0.1, 0.1, 0.9)
@export var fill_color: Color = Color(0.9, 0.2, 0.2, 0.95)
@export var border_color: Color = Color(0.0, 0.0, 0.0, 1.0)

var _current: int = 0
var _max: int = 1

func set_health(current: int, maxh: int) -> void:
	var safe_max: int = maxi(maxh, 1)
	var safe_current: int = mini(maxi(current, 0), safe_max)
	_current = safe_current
	_max = safe_max
	queue_redraw()

func _draw() -> void:
	var top_left: Vector2 = Vector2(-bar_width * 0.5, y_offset)
	var bg_rect: Rect2 = Rect2(top_left, Vector2(bar_width, bar_height))
	draw_rect(bg_rect, background_color)
	var fill_ratio: float = float(_current) / float(_max)
	var fill_width: float = bar_width * fill_ratio
	var fill_rect: Rect2 = Rect2(top_left, Vector2(fill_width, bar_height))
	draw_rect(fill_rect, fill_color)
	draw_rect(bg_rect, border_color, false, 1.0)
