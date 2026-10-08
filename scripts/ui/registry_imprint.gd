extends TextureRect
## Fixed Registry identifier, unrelated to the count of scars.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")

func _ready() -> void:
	texture = null
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	for index: int in range(3):
		var origin := Vector2(index * 0.13, index * 0.19) * size
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(0.66, 0.02) * size,
			origin + Vector2(0.1, 0.46) * size,
			origin + Vector2(0.02, 0.61) * size,
		]), Palette.WAX)
