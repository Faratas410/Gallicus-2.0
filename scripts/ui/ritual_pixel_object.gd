extends Control
## Passive object skin. The parent Button retains text, focus, locks and intents.
const ATLAS = preload("res://assets/ui/generated/ritual_objects_pixel.png")
const Writing = preload("res://scripts/ui/registry_handwriting.gd")
const DISPLAY = preload("res://assets/ui/fonts/font_verdict.tres")
var tile := 0
var button: Button
var heading: Label
var consequence: Label
var last_state := ""

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	resized.connect(_layout)
	button = get_parent() as Button
	if button == null:
		set_process(false)
		return
	heading = _label()
	consequence = _label()
	sync_copy()

func _label() -> Label:
	var label := Label.new()
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_constant_override("outline_size", 0)
	add_child(label)
	return label

func sync_copy() -> void:
	if button == null: return
	for key: String in ["ManifestoSurface", "PrintedTitle", "Consequence", "WaxTrace"]:
		var old := button.get_node_or_null(key) as CanvasItem
		if old != null: old.hide()
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_hover_pressed_color", "font_outline_color"]:
		button.add_theme_color_override(state, Color.TRANSPARENT)
	button.add_theme_font_size_override("font_size", 1)
	button.custom_minimum_size = Vector2.ZERO
	var lines := button.text.split("\n", false, 1)
	heading.text = lines[0] if not lines.is_empty() else ""
	consequence.text = lines[1] if lines.size() > 1 else ""
	var engraved: bool = tile == 1 or tile == -2
	var ink: Color = Color("f4e4b5") if engraved else Writing.INK
	for label: Label in [heading, consequence]:
		label.add_theme_color_override("font_color", ink)
		label.add_theme_font_override("font", DISPLAY if engraved else Writing.FONT)
		label.material = null if engraved else Writing.material()
		if engraved:
			label.add_theme_color_override("font_shadow_color", Color("30251f"))
			label.add_theme_constant_override("shadow_offset_y", 1)
	heading.add_theme_font_size_override("font_size", 24 if tile < 2 else 23)
	consequence.add_theme_font_size_override("font_size", 19)
	_layout()

func _layout() -> void:
	if heading == null: return
	if tile == 1:
		heading.position = size * Vector2(0.16, 0.73)
		heading.size = size * Vector2(0.68, 0.17)
	elif tile >= 2:
		heading.position = size * Vector2(0.11, 0.28)
		heading.size = size * Vector2(0.78, 0.22)
		consequence.position = size * Vector2(0.12, 0.50)
		consequence.size = size * Vector2(0.76, 0.31)
	else:
		heading.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	queue_redraw()

func _process(_delta: float) -> void:
	var state := "%s|%s|%s|%s|%s|%s|%s|%s" % [button.text, button.has_focus(), button.is_hovered(), button.disabled, button.is_pressed(), button.get_meta("registry_judgment_seal_state", 0), button.get_meta("arena_gesture_choice_state", "normal"), button.get_meta("registry_pact_tablet_validated", false)]
	if state != last_state:
		last_state = state
		sync_copy()

func _draw() -> void:
	# Tile -1 is an inscription on an existing physical support.
	if tile >= 0:
		var half := ATLAS.get_size() * 0.5
		draw_texture_rect_region(ATLAS, Rect2(Vector2.ZERO, size), Rect2(Vector2(tile % 2, tile / 2) * half, half))
	if button == null: return
	var pigment: Color = Color("f4e4b5") if tile == 1 or tile == -2 else Writing.INK
	var y: float = size.y * (0.91 if tile == 1 else 0.83 if tile >= 2 else 0.91)
	if button.has_focus() or button.is_hovered():
		draw_line(Vector2(size.x * 0.15, y), Vector2(size.x * 0.85, y), pigment, 3)
	if button.disabled:
		for dy: float in [0.0, 6.0]:
			draw_line(Vector2(size.x * 0.43, y + dy), Vector2(size.x * 0.57, y + dy), pigment, 2)
	if button.is_pressed():
		draw_line(Vector2(size.x * 0.15, y - 5), Vector2(size.x * 0.85, y - 5), pigment, 2)
	if button.get_meta("arena_gesture_choice_state", "normal") == &"selected":
		draw_rect(Rect2(size.x * 0.08, size.y * 0.30, 3, size.y * 0.48), pigment)
	if bool(button.get_meta("registry_pact_tablet_validated", false)):
		draw_polyline(PackedVector2Array([Vector2(5, y - 8), Vector2(12, y), Vector2(26, y - 17)]), pigment, 3)
	if tile == 1:
		for i: int in range(3):
			var socket := size * Vector2(0.44 + i * 0.08, 0.67)
			draw_circle(socket, 8, Color("b38143"))
			draw_circle(socket, 6, Color("30251f"))
		var strikes: int = int(button.get_meta("registry_judgment_seal_state", 0))
		for i: int in range(mini(strikes, 3) if not bool(button.get_meta("pixel_wax_held", true)) else 0):
			var x: float = size.x * (0.44 + i * 0.08)
			draw_polyline(PackedVector2Array([Vector2(x, size.y * 0.36), Vector2(x - 7, size.y * 0.44), Vector2(x + 3, size.y * 0.50)]), Color("572619"), 3)
