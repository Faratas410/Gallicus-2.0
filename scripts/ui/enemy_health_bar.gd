extends Node2D

@onready var fill: ColorRect = $Fill

const BAR_W: float = 26.0

func set_health(current: int, max: int) -> void:
	var ratio: float = 0.0
	if max > 0:
		ratio = float(current) / float(max)
	ratio = clamp(ratio, 0.0, 1.0)
	var s := fill.size
	s.x = BAR_W * ratio
	fill.size = s
