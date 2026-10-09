extends RefCounted
## Manifesto UI kit: shared tokens and idempotent adapters for native controls.
## Callers keep content, geometry, input signals and authoritative state.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Surface = preload("res://scripts/ui/manifesto_action_surface.gd")
const Document = preload("res://scripts/ui/manifesto_document_surface.gd")
const DISPLAY_FONT_PATH: String = "res://assets/ui/fonts/font_manifesto.tres"
const DISPLAY_FONT = preload(DISPLAY_FONT_PATH)
const BODY_FONT = preload("res://assets/ui/fonts/font_body.tres")
const TITLE_LARGE: int = 40
const TITLE_SMALL: int = 26
const ACTION_COMPACT: int = 22
const BODY_SIZE: int = 17
const CAPTION_SIZE: int = 38
const SPACE: int = 8
const ACTION_INSET: int = 54
const CONTRACT_TITLE_SIZE: int = 22
const CONTRACT_HEADING_SIZE: int = 15
const SERVICE_SIZE: int = 15

static func format_heading(value: String, text_size: int, pigment: Color = Palette.INK) -> String:
	return "[font=%s][font_size=%d][color=#%s]%s[/color][/font_size][/font]" % [DISPLAY_FONT_PATH, text_size, pigment.to_html(false), value.replace("[", "[lb]")]

static func apply_rich_text(label: RichTextLabel, pigment: Color = Palette.INK) -> void:
	for font_role: String in ["normal_font", "bold_font", "italics_font", "bold_italics_font", "mono_font"]:
		label.add_theme_font_override(font_role, BODY_FONT)
	for size_role: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]:
		label.add_theme_font_size_override(size_role, BODY_SIZE)
	label.add_theme_color_override("default_color", pigment)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("line_separation", 1)

static func apply_document(control: Control, material: StringName = &"paper", selected: bool = false) -> void:
	var surface := control.get_node_or_null("ManifestoDocument") as Control
	if surface == null:
		surface = Document.new()
		surface.name = "ManifestoDocument"
		control.add_child(surface)
		control.move_child(surface, 0)
	if control is PanelContainer or control is Panel:
		control.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	surface.set("surface_role", material)
	surface.set("selected", selected)
	surface.queue_redraw()

static func apply_page_selection(button: Button) -> void:
	button.modulate = Color.WHITE
	button.flat = false
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Palette.INK
	focus.border_width_bottom = 4
	button.add_theme_stylebox_override("focus", focus)

static func apply_label(label: Label, role: StringName = &"body", pigment: Color = Palette.IVORY) -> void:
	label.add_theme_font_override("font", BODY_FONT if role == &"body" else DISPLAY_FONT)
	label.add_theme_font_size_override("font_size", BODY_SIZE if role == &"body" else CAPTION_SIZE if role == &"caption" else TITLE_SMALL)
	label.add_theme_color_override("font_color", pigment)

static func apply_judgment(panel: Control) -> void:
	# The seal keeps every native texture, socket, state and hit target. Only
	# its type and the surrounding reading/auxiliary controls consume the kit.
	var box: Control = panel.get_node("Box_RESOLUTION")
	for key: String in ["TITLE", "BODY", "RITUAL_PROMPT"]:
		var support: PanelContainer = box.get_node("Lbl_RESOLUTION_%sPanel" % key)
		var label: Label = support.get_node("Lbl_RESOLUTION_%s" % key)
		support.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		apply_label(label, &"title" if key == "TITLE" else &"body")
		label.add_theme_constant_override("outline_size", 0)
		if key == "RITUAL_PROMPT":
			label.add_theme_font_size_override("font_size", SERVICE_SIZE)
		else:
			apply_document(support, &"ink")
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	var seal: Button = box.get_node("Btn_RESOLUTION_STRIKE")
	seal.add_theme_font_override("font", DISPLAY_FONT)
	seal.add_theme_font_size_override("font_size", ACTION_COMPACT)
	seal.add_theme_constant_override("outline_size", 0)
	apply_action(box.get_node("Btn_RESOLUTION_NEXT"), &"ink", true)

static func apply_action(button: Button, material: StringName, compact: bool = false, registered: bool = false, title_size: int = TITLE_LARGE, selected: bool = false, body_text: bool = false) -> void:
	var surface := button.get_node_or_null("ManifestoSurface") as Control
	if surface == null:
		surface = Surface.new()
		surface.name = "ManifestoSurface"
		button.add_child(surface)
	surface.set("surface_role", material)
	surface.set("compact", compact)
	surface.set("registered", registered)
	surface.set("selected", selected)
	surface.queue_redraw()
	var pigment: Color = Palette.INK if material == &"paper" else Palette.IVORY
	var empty := StyleBoxEmpty.new()
	# Constant margins preserve target size across every interaction state.
	if compact:
		empty.content_margin_left = 34
		empty.content_margin_right = 18
		empty.content_margin_top = 8
		empty.content_margin_bottom = 8
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, empty)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = pigment
	focus.border_width_bottom = 4
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_font_override("font", BODY_FONT if body_text else DISPLAY_FONT)
	button.add_theme_constant_override("outline_size", 0)
	button.add_theme_font_size_override("font_size", SERVICE_SIZE if body_text else ACTION_COMPACT if compact else 1)
	button.modulate = Color.WHITE
	for state: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_disabled_color"]:
		button.add_theme_color_override(state, pigment if compact else Color.TRANSPARENT)
	if compact:
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		return
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var title := button.get_node_or_null("PrintedTitle") as Label
	if title == null:
		title = Label.new()
		title.name = "PrintedTitle"
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_child(title)
	# Keep translation keys and native semantic Button text intact.
	title.text = button.text
	apply_label(title, &"title", pigment)
	title.add_theme_font_size_override("font_size", title_size)
	var wax: CanvasItem = button.get_node_or_null("WaxTrace")
	if wax != null:
		wax.hide()

static func layout_action(button: Button) -> void:
	var title := button.get_node_or_null("PrintedTitle") as Label
	if title != null:
		title.position = Vector2(ACTION_INSET, 10)
		title.size = Vector2(button.size.x - ACTION_INSET - SPACE * 2, 54)

static func create_choice(text_key: String, note_key: String, material: StringName) -> Button:
	var button := Button.new()
	button.text = text_key
	button.custom_minimum_size = Vector2(300, 158)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	apply_action(button, material)
	var note := Label.new()
	note.name = "Consequence"
	note.text = note_key
	note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	apply_label(note, &"body", Palette.INK if material == &"paper" else Palette.IVORY)
	button.add_child(note)
	button.resized.connect(func() -> void:
		layout_action(button)
		note.position = Vector2(ACTION_INSET, 64)
		note.size = Vector2(button.size.x - ACTION_INSET - SPACE * 2, 86)
	)
	return button

static func apply_response(button: Button, material: StringName, selected: bool = false) -> void:
	# Native text retains the full accessible/localized act and its price.
	apply_action(button, material, false, false, ACTION_COMPACT, selected)
	var lines: PackedStringArray = button.text.split("\n", false, 1)
	(button.get_node("PrintedTitle") as Label).text = lines[0] if not lines.is_empty() else ""
	var note := button.get_node_or_null("Consequence") as Label
	if note == null:
		note = Label.new()
		note.name = "Consequence"
		note.mouse_filter = Control.MOUSE_FILTER_IGNORE
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_child(note)
	note.text = lines[1] if lines.size() > 1 else ""
	apply_label(note, &"body", Palette.INK if material == &"paper" else Palette.IVORY)
	var layout: Callable = layout_response.bind(button)
	if not button.resized.is_connected(layout):
		button.resized.connect(layout)
	layout_response(button)

static func layout_response(button: Button) -> void:
	layout_action(button)
	var note := button.get_node_or_null("Consequence") as Label
	if note != null:
		note.position = Vector2(ACTION_INSET, 68)
		note.size = Vector2(button.size.x - ACTION_INSET - SPACE * 2, button.size.y - 84)
