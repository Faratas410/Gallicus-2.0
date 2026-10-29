extends Control
## Ink and paper only. Purchase authority stays on the original native Button.
const Paper = preload("res://scripts/ui/banco_paper.gd")
const Writing = preload("res://scripts/ui/registry_handwriting.gd")
var button: Button
var copy: Label
var previous := ""

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	button = get_parent() as Button
	var support := Paper.new()
	support.name = "PaperSupport"
	support.show_behind_parent = true
	add_child(support)
	support.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	copy = Label.new()
	copy.mouse_filter = MOUSE_FILTER_IGNORE
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	copy.add_theme_font_override("font", Writing.FONT)
	copy.add_theme_color_override("font_color", Writing.INK)
	copy.material = Writing.material()
	add_child(copy)
	resized.connect(sync_copy)
	sync_copy()

func sync_copy() -> void:
	if button == null: return
	for key in ["ManifestoSurface", "PrintedTitle", "Consequence", "WaxTrace"]:
		var old := button.get_node_or_null(key) as CanvasItem
		if old: old.hide()
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_hover_pressed_color", "font_outline_color"]:
		button.add_theme_color_override(state, Color.TRANSPARENT)
	button.add_theme_font_size_override("font_size", 1)
	var scale_factor := size.x / 560.0
	button.custom_minimum_size.y = (122 if button.name == "Btn_Banco_insure" else 82) * scale_factor
	var parts := button.text.split("\n")
	copy.text = ((parts[0].left(1).to_upper() + parts[0].substr(1).to_lower()) + "  ·  " + parts[2] + "\n" + parts[1]) if parts.size() == 3 else button.text
	copy.add_theme_font_size_override("font_size", roundi(18 * scale_factor))
	copy.position = Vector2(size.x * 0.10, size.y * 0.17)
	copy.size = Vector2(size.x * 0.80, size.y * 0.66)
	queue_redraw()

func _process(_delta: float) -> void:
	var state := "%s|%s|%s|%s" % [button.text, button.disabled, button.has_focus(), button.is_hovered()]
	if state != previous:
		previous = state
		sync_copy()

func _draw() -> void:
	if button == null: return
	if button.has_focus() or button.is_hovered():
		draw_line(size * Vector2(0.12, 0.88), size * Vector2(0.88, 0.88), Writing.INK, 2)
	if button.disabled:
		for y in [0.44, 0.53]:
			draw_line(size * Vector2(0.04, y), size * Vector2(0.075, y), Writing.INK, 3)
