extends RefCounted
## Shared, deterministic print geometry. No textures, input or gameplay RNG.

static func slab(canvas: CanvasItem, rect: Rect2, color: Color, salt: int = 0) -> void:
	if rect.size.x < 24 or rect.size.y < 24:
		return
	var notch: float = 0.24 + float(salt % 3) * 0.12
	canvas.draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(2, 2),
		rect.position + Vector2(rect.size.x * notch, 0),
		rect.position + Vector2(rect.size.x * notch + 12, 2),
		Vector2(rect.end.x - 2, rect.position.y + 1),
		Vector2(rect.end.x, rect.position.y + rect.size.y * 0.63),
		rect.end - Vector2(2, 2),
		Vector2(rect.position.x + rect.size.x * 0.72, rect.end.y),
		Vector2(rect.position.x + rect.size.x * 0.72 - 16, rect.end.y - 2),
		Vector2(rect.position.x + 1, rect.end.y - 1),
		rect.position + Vector2(0, rect.size.y * 0.31),
	]), color)

static func mark(canvas: CanvasItem, at: Vector2, color: Color, impressed: bool, scale_factor: float = 1.0) -> void:
	for index: int in range(3):
		var start := at + Vector2(index * 6, index * 11) * scale_factor
		var polygon := PackedVector2Array([
			start + Vector2(26, 0) * scale_factor,
			start + Vector2(12, 25) * scale_factor,
			start + Vector2(0, 34) * scale_factor,
		])
		if impressed:
			canvas.draw_colored_polygon(polygon, color)
		else:
			polygon.append(polygon[0])
			canvas.draw_polyline(polygon, color, 1.25, true)
