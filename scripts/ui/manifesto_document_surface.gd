extends Control
## Passive reading surface. Selection is a rule, never a registered mark.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Print = preload("res://scripts/ui/manifesto_primitives.gd")
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
	if not paper:
		# PanelContainer places this passive child in its padded content rect.
		# Extend ink into that padding; rules would run through the body copy.
		Print.slab(self, rect.grow(8), Palette.INK, 1)
		return
	Print.slab(self, rect, Palette.IVORY if paper else Palette.INK, 1)
	# Fine rules keep the reading field calm and reserve wax for signatures.
	draw_line(Vector2(8, 8), Vector2(size.x - 8, 8), pigment, 1)
	draw_line(Vector2(8, size.y - 8), size - Vector2(8, 8), pigment, 1)
	if selected:
		draw_line(Vector2(8, 16), Vector2(8, size.y - 16), pigment, 4)
