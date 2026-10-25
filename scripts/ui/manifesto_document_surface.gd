extends Control
## Passive reading surface. Selection is a rule, never a registered mark.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Print = preload("res://scripts/ui/manifesto_primitives.gd")
const PAPER = preload("res://assets/ui/generated/registry_paper.png")
var surface_role: StringName = &"paper"
var selected: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	show_behind_parent = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)

func _draw() -> void:
	var paper: bool = surface_role == &"paper"
	var pigment: Color = Palette.INK if paper else Palette.IVORY
	var rect := Rect2(Vector2.ZERO, size)
	# PanelContainer fits passive children inside its content margins too.
	# Restore the sheet's outer extent so its rules stay outside the text.
	if get_parent() is PanelContainer:
		var style: StyleBox = get_parent().get_theme_stylebox("panel")
		var inset := Vector2(style.get_content_margin(SIDE_LEFT), style.get_content_margin(SIDE_TOP))
		var end_inset := Vector2(style.get_content_margin(SIDE_RIGHT), style.get_content_margin(SIDE_BOTTOM))
		rect = Rect2(-inset, size + inset + end_inset)
	if not paper:
		# PanelContainer places this passive child in its padded content rect.
		# Extend ink into that padding; rules would run through the body copy.
		Print.slab(self, rect.grow(8), Palette.INK, 1)
		return
	Print.slab(self, rect, Palette.IVORY if paper else Palette.INK, 1)
	draw_texture_rect(PAPER, rect.grow(-2), false, Color(1, 1, 1, 0.15))
	# Fine rules keep the reading field calm and reserve wax for signatures.
	var ruled: Rect2 = rect.grow(-8)
	draw_line(ruled.position, Vector2(ruled.end.x, ruled.position.y), pigment, 1)
	draw_line(Vector2(ruled.position.x, ruled.end.y), ruled.end, pigment, 1)
	if selected:
		draw_line(ruled.position + Vector2(0, 8), Vector2(ruled.position.x, ruled.end.y - 8), pigment, 4)
