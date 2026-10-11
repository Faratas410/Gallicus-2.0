extends Control
## Passive skin of an existing native Button. Never owns input or availability.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Print = preload("res://scripts/ui/manifesto_primitives.gd")
var surface_role: StringName = &"ink"
var compact: bool = false
var registered: bool = false
var selected: bool = false
var button: Button
## 0..1 progress of the stylus line along the lower edge (hover or focus).
var accent: float = 0.0:
	set(value):
		accent = value
		queue_redraw()
var _accent_tween: Tween

func _ready() -> void:
	button = get_parent() as Button
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	show_behind_parent = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	# Native draw invalidation covers disabled, focus, hover and press changes.
	button.draw.connect(queue_redraw)
	button.mouse_entered.connect(_trace_accent)
	button.mouse_exited.connect(_trace_accent)
	button.focus_entered.connect(_trace_accent)
	button.focus_exited.connect(_trace_accent)

func _trace_accent() -> void:
	# Sober profile: no scale or offset; the line is drawn left to right.
	var target: float = 1.0 if not button.disabled and (button.is_hovered() or button.has_focus()) else 0.0
	if _accent_tween != null and _accent_tween.is_valid():
		_accent_tween.kill()
	if not is_inside_tree():
		accent = target
		return
	var save_manager: Node = get_node_or_null("/root/SaveManager")
	if target == 0.0 or (save_manager != null and bool(save_manager.call("get_reduced_motion"))):
		accent = target
		return
	accent = 0.0
	_accent_tween = create_tween()
	_accent_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_accent_tween.tween_property(self, "accent", 1.0, 0.12)

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
	var active: bool = accent > 0.0 and not blocked
	if not compact or registered or selected or active:
		Print.mark(self, Vector2(13, 20) if not compact else Vector2(8, 12), Palette.WAX if surface_role == &"paper" else Palette.IVORY, registered, 0.55 if compact else 1.0)
	if selected and not registered:
		draw_line(Vector2(8, 7), Vector2(size.x - 8, 7), pigment, 2)
	if blocked:
		var origin := Vector2(14, 92) if not compact else Vector2(8, size.y - 16)
		for offset: int in [0, 7]:
			draw_line(origin + Vector2(0, offset), origin + Vector2(28 if not compact else 14, offset), pigment, 3)
	elif pressed:
		draw_rect(rect.grow(-7), pigment, false, 2)
	elif active:
		# Incised stylus line: hover and focus share the same sign.
		var reach: float = 8.0 + (size.x - 16.0) * accent
		draw_line(Vector2(8, size.y - 8), Vector2(reach, size.y - 8), pigment, 2)
