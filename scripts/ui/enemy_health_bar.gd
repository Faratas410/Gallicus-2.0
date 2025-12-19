extends Node2D

@onready var fill: ColorRect = $Fill

var _max: int = 1

func set_health(current: int, max: int) -> void:
	_max = max
	var ratio := 0.0
	if max > 0:
		ratio = float(current) / float(max)
	fill.size.x = 26.0 * clamp(ratio, 0.0, 1.0)
