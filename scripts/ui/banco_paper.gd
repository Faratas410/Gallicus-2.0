extends Control
## Nine-slice paper: only the blank center stretches, never an emblem.
const PAPER = preload("res://assets/ui/generated/banco_paper_v2.png")
var paper_style: StyleBoxTexture

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	paper_style = StyleBoxTexture.new()
	paper_style.texture = PAPER
	paper_style.region_rect = Rect2(48, 145, 2077, 420)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		paper_style.set_texture_margin(side, 75)
	resized.connect(queue_redraw)

func _draw() -> void:
	if paper_style == null: return
	var factor := minf(get_viewport_rect().size.x / 1280.0, get_viewport_rect().size.y / 720.0)
	var density := 3.0 / factor
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE / density)
	draw_style_box(paper_style, Rect2(Vector2.ZERO, size * density))
	draw_set_transform(Vector2.ZERO)
