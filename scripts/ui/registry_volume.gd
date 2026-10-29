extends Control
## Passive projected book. Only geometry and ink; no run state or intents.
const BOOK = preload("res://assets/ui/generated/registry_volume_book.png")
const SPRITES = preload("res://assets/ui/generated/registry_volume_sprites.png")
const COVER = preload("res://assets/ui/generated/registry_volume_sprites_v2.png")
const INK := Color("45271c")
const DESIGN := Vector2(1620, 972)
const PEN_REGION := Rect2(875, 350, 620, 390)
var opening: float = 1.0:
	set(value):
		opening = clampf(value, 0.0, 1.0)
		queue_redraw()
var signature_side: int = -1
var signature_progress: float = 0.0:
	set(value):
		signature_progress = clampf(value, 0.0, 1.0)
		queue_redraw()
var show_pen: bool = false
const STROKES = [
	[Vector2(0, 45), Vector2(33, 2), Vector2(24, 38), Vector2(9, 49), Vector2(14, 29), Vector2(48, 26), Vector2(59, 35), Vector2(42, 45), Vector2(30, 43)],
	[Vector2(49, 43), Vector2(66, 24), Vector2(58, 45), Vector2(77, 28), Vector2(70, 44), Vector2(87, 31), Vector2(83, 43), Vector2(99, 34), Vector2(110, 39), Vector2(122, 34), Vector2(136, 39)],
	[Vector2(11, 54), Vector2(68, 51), Vector2(158, 40)]
]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)

func _project(p: Vector3) -> Vector2:
	var perspective: float = 6800.0 / (6800.0 - p.z)
	return Vector2(810, 520) + (Vector2(p.x, p.y) - Vector2(810, 520)) * perspective

func _pose(u: float, v: float, depth: float = 0.0) -> Vector2:
	var angle: float = opening * PI
	return _project(Vector3(810 + cos(angle) * u * 768 - sin(angle) * depth,
		145 + v * 778, sin(angle) * u * 768 + cos(angle) * depth))

func _surface(texture: Texture2D, source: Rect2, point: Callable, tint: Color = Color.WHITE) -> void:
	var dimensions := texture.get_size()
	for strip: int in range(80):
		var a: float = strip / 80.0
		var b: float = (strip + 1) / 80.0
		var vertices := PackedVector2Array([point.call(a, 0.0), point.call(b, 0.0), point.call(b, 1.0), point.call(a, 1.0)])
		var area: float = absf((vertices[1] - vertices[0]).cross(vertices[3] - vertices[0]))
		if area < 0.1:
			continue
		var uv := PackedVector2Array([
			(source.position + Vector2(a * source.size.x, 0)) / dimensions,
			(source.position + Vector2(b * source.size.x, 0)) / dimensions,
			(source.position + Vector2(b * source.size.x, source.size.y)) / dimensions,
			(source.position + Vector2(a * source.size.x, source.size.y)) / dimensions])
		draw_polygon(vertices, PackedColorArray([tint]), uv, texture)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, size / DESIGN)
	var half: Vector2 = BOOK.get_size() * Vector2(0.5, 1.0)
	if opening >= 0.999:
		draw_texture_rect(BOOK, Rect2(42, 145, 1536, 778), false)
	else:
		draw_texture_rect_region(BOOK, Rect2(810, 145, 768, 778), Rect2(Vector2(half.x, 0), half))
		var shade: float = sin(opening * PI)
		draw_rect(Rect2(810, 182, 95 * shade, 640), Color(0.12, 0.05, 0.02, shade * 0.17))
		if opening <= 0.5:
			# Leather board only: never stretch a pale page face along this rim.
			_surface(SPRITES, Rect2(705, 440, 15, 320), func(u: float, v: float) -> Vector2: return _pose(0.982, 0.025 + v * 0.95, u * 16))
			_surface(SPRITES, Rect2(285, 883, 310, 14), func(u: float, v: float) -> Vector2: return _pose(0.025 + u * 0.95, 0.982, v * 16))
			_surface(COVER, Rect2(110, 80, 665, 850), func(u: float, v: float) -> Vector2: return _pose(u, v, 16))
		else:
			_surface(BOOK, Rect2(Vector2.ZERO, half), func(u: float, v: float) -> Vector2: return _pose(1.0 - u, v))
	if signature_side >= 0:
		_draw_signature()

func _draw_signature() -> void:
	var origin := Vector2(380 if signature_side == 0 else 1010, 650)
	for start: float in [300.0, 932.0]:
		draw_line(Vector2(start, 706), Vector2(start + 390, 706), INK, 2)
	var remaining: float = signature_progress * 22.0
	var tip: Vector2 = origin
	for stroke: Array in STROKES:
		for index: int in range(1, stroke.size()):
			if remaining <= 0:
				break
			var a: Vector2 = origin + stroke[index - 1]
			var b: Vector2 = origin + stroke[index - 1].lerp(stroke[index], minf(remaining, 1.0))
			draw_line(a, b, INK, 2.8, false)
			tip = b
			remaining -= 1.0
	if show_pen and signature_progress < 0.98:
		var pen_size := Vector2(260, 164)
		draw_texture_rect_region(SPRITES, Rect2(tip - Vector2(5, 157), pen_size), PEN_REGION)
