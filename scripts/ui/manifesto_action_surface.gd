extends Control
## Passive skin of an existing native Button. Never owns input or availability.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Print = preload("res://scripts/ui/manifesto_primitives.gd")
var surface_role: StringName = &"ink"
var compact: bool = false
var registered: bool = false
var selected: bool = false
var button: Button

func _ready() -> void:
	button = get_parent() as Button
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	show_behind_parent = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	# Native draw invalidation covers disabled, focus, hover and press changes.
	button.draw.connect(queue_redraw)

func _draw() -> void:
	if button == null:
		return
	var pigment: Color = Palette.INK if surface_role == &"paper" else Palette.IVORY
	var surface: Color = Palette.IVORY if surface_role == &"paper" else Palette.WAX if surface_role == &"wax" else Palette.INK
	var mode: int = button.get_draw_mode()
	var pressed: bool = mode == BaseButton.DRAW_PRESSED or mode == BaseButton.DRAW_HOVER_PRESSED
	var blocked: bool = button.disabled and not registered
	if blocked:
		surface = surface.lerp(Palette.INK, 0.16)
	elif pressed:
		surface = surface.lerp(pigment, 0.12)
	var rect := Rect2(Vector2.ZERO, size)
	Print.slab(self, rect.grow(2), Palette.INK)
	Print.slab(self, rect, surface, 2)
	if not compact or registered or selected:
		Print.mark(self, Vector2(13, 20) if not compact else Vector2(8, 12), Palette.WAX if surface_role == &"paper" else Palette.IVORY, registered, 0.55 if compact else 1.0)
	if selected and not registered:
		draw_line(Vector2(8, 7), Vector2(size.x - 8, 7), pigment, 2)
	if blocked:
		var origin := Vector2(14, 92) if not compact else Vector2(8, size.y - 16)
		for offset: int in [0, 7]:
			draw_line(origin + Vector2(0, offset), origin + Vector2(28 if not compact else 14, offset), pigment, 3)
	elif pressed:
		draw_rect(rect.grow(-7), pigment, false, 2)
	elif mode == BaseButton.DRAW_HOVER:
		draw_line(Vector2(8, size.y - 8), size - Vector2(8, 8), pigment, 2)
