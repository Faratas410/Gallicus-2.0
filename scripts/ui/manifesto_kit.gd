extends RefCounted
## Manifesto UI kit: shared tokens and idempotent adapters for native controls.
## Callers keep content, geometry, input signals and authoritative state.

const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Surface = preload("res://scripts/ui/manifesto_action_surface.gd")
const Document = preload("res://scripts/ui/manifesto_document_surface.gd")
const DISPLAY_FONT_PATH: String = "res://assets/ui/fonts/font_verdict.tres"
const DISPLAY_FONT = preload(DISPLAY_FONT_PATH)
const BODY_FONT = preload("res://assets/ui/fonts/font_body.tres")
const TITLE_LARGE: int = 28
const TITLE_SMALL: int = 26
const ACTION_COMPACT: int = 22
const BODY_SIZE: int = 17
const CAPTION_SIZE: int = 38
const SPACE: int = 8
const ACTION_INSET: int = 54
const CONTRACT_TITLE_SIZE: int = 22
const CONTRACT_HEADING_SIZE: int = 15
const SERVICE_SIZE: int = 15
const CONTROL_SIZE: int = 18
const INCISION: int = 2
const FOCUS_RULE: int = 4
## Accent stroke of the stylus (sober profile): drawn left to right, no scale.
const ACCENT_SECONDS: float = 0.12
static var _icons: Dictionary = {}

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
	if button.has_node("PixelRitualObject"):
		button.get_node("PixelRitualObject").sync_copy()
		return
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
	# Size before face: never shape the display face at an inherited size.
	button.add_theme_constant_override("outline_size", 0)
	# Keep the transparent semantic text wrapped at a real reading size.
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", SERVICE_SIZE if body_text else ACTION_COMPACT)
	# Expanded actions draw PrintedTitle; leave the invisible semantic face
	# alone. Swapping that unused face during boot invalidates a Godot 4.6 RID.
	if compact or body_text:
		button.add_theme_font_override("font", BODY_FONT if body_text else DISPLAY_FONT)
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
	if button.has_node("PixelRitualObject"):
		button.get_node("PixelRitualObject").sync_copy()
		return
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

# --- Common API (Gallicus "Atto a stampa"): names shared by every game pass.

static func apply_panel(control: Control, material: StringName = &"ink") -> void:
	apply_document(control, material)

static func apply_inset(control: Control, selected: bool = false) -> void:
	apply_document(control, &"paper", selected)
	if control is PanelContainer:
		# Reading margin inside the sheet, clear of the fine rules.
		var margin := StyleBoxEmpty.new()
		margin.content_margin_left = SPACE * 2
		margin.content_margin_right = SPACE * 2
		margin.content_margin_top = SPACE * 2
		margin.content_margin_bottom = SPACE * 2
		control.add_theme_stylebox_override("panel", margin)

static func apply_primary_button(button: Button, compact: bool = true) -> void:
	apply_action(button, &"ink", compact)

static func apply_secondary_button(button: Button, compact: bool = true, selected: bool = false) -> void:
	apply_action(button, &"paper", compact, false, TITLE_LARGE, selected)

static func apply_title(label: Label, pigment: Color = Palette.IVORY) -> void:
	apply_label(label, &"title", pigment)
	label.add_theme_constant_override("outline_size", 0)

static func apply_body(label: Label, pigment: Color = Palette.IVORY) -> void:
	apply_label(label, &"body", pigment)
	label.add_theme_constant_override("outline_size", 0)

static func apply_muted(label: Label, on_paper: bool = false) -> void:
	# Secondary copy stays readable: muted on ink, ink-lerped on paper.
	apply_label(label, &"body", Palette.INK.lerp(Palette.MUTED, 0.45) if on_paper else Palette.MUTED)
	label.add_theme_font_size_override("font_size", SERVICE_SIZE)
	label.add_theme_constant_override("outline_size", 0)

static func _flat(fill: Color, bottom: int = 0, rule: Color = Palette.IVORY, margin: int = 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = rule
	box.border_width_bottom = bottom
	box.corner_detail = 1
	for side: String in ["left", "right"]:
		box.set("content_margin_" + side, margin * 2)
	for side: String in ["top", "bottom"]:
		box.set("content_margin_" + side, margin)
	return box

static func focus_rule(pigment: Color = Palette.IVORY) -> StyleBoxFlat:
	# Keyboard focus = the canon 4 px underline, never a gold frame.
	return _flat(Color.TRANSPARENT, FOCUS_RULE, pigment)

static func _icon(key: String) -> Texture2D:
	# Runtime-only procedural icons: no file, no generated PNG.
	if _icons.has(key):
		return _icons[key]
	var image := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	match key:
		"knob", "knob_hot", "knob_off":
			var fill: Color = Palette.WAX if key == "knob_hot" else Palette.IVORY.lerp(Palette.INK, Palette.DISABLED_MIX) if key == "knob_off" else Palette.IVORY
			image.fill_rect(Rect2i(5, 1, 10, 18), Palette.INK)
			image.fill_rect(Rect2i(6, 2, 8, 16), fill)
			image.fill_rect(Rect2i(9, 5, 2, 10), Palette.INK)
		"box_on", "box_off":
			for edge: Rect2i in [Rect2i(2, 2, 16, 2), Rect2i(2, 16, 16, 2), Rect2i(2, 2, 2, 16), Rect2i(16, 2, 2, 16)]:
				image.fill_rect(edge, Palette.IVORY)
			if key == "box_on":
				image.fill_rect(Rect2i(6, 9, 8, 3), Palette.IVORY)
		"chevron":
			for step: int in range(6):
				image.fill_rect(Rect2i(3 + step, 6 + step, 2, 2), Palette.INK)
				image.fill_rect(Rect2i(15 - step, 6 + step, 2, 2), Palette.INK)
	var texture := ImageTexture.create_from_image(image)
	_icons[key] = texture
	return texture

static func apply_slider(slider: Slider) -> void:
	# Incised groove, ink-on-ivory travel, ivory tab (wax while held/focused).
	var groove := _flat(Palette.INK.lerp(Palette.IVORY, 0.18), 0)
	groove.content_margin_top = INCISION
	groove.content_margin_bottom = INCISION
	var travel := _flat(Palette.IVORY, 0)
	travel.content_margin_top = INCISION
	travel.content_margin_bottom = INCISION
	slider.add_theme_stylebox_override("slider", groove)
	slider.add_theme_stylebox_override("grabber_area", travel)
	slider.add_theme_stylebox_override("grabber_area_highlight", travel)
	slider.add_theme_stylebox_override("focus", focus_rule())
	slider.add_theme_icon_override("grabber", _icon("knob"))
	slider.add_theme_icon_override("grabber_highlight", _icon("knob_hot"))
	slider.add_theme_icon_override("grabber_disabled", _icon("knob_off"))

static func apply_toggle(toggle: Button) -> void:
	# Incised square; the bar inside is the checked state (shape, not colour).
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		toggle.add_theme_stylebox_override(state, _flat(Color.TRANSPARENT, 0, Palette.IVORY, SPACE / 2))
	toggle.add_theme_stylebox_override("hover", _flat(Color.TRANSPARENT, INCISION, Palette.IVORY, SPACE / 2))
	toggle.add_theme_stylebox_override("focus", focus_rule())
	for role: String in ["checked", "unchecked", "checked_disabled", "unchecked_disabled", "radio_checked", "radio_unchecked"]:
		toggle.add_theme_icon_override(role, _icon("box_on" if role.begins_with("checked") or role == "radio_checked" else "box_off"))
	_apply_control_text(toggle, Palette.IVORY)

static func apply_option_button(option: OptionButton) -> void:
	# Paper field with an incised chevron; the popup reuses ink and paper.
	var paper := _flat(Palette.IVORY, 0, Palette.INK, SPACE)
	var hover := _flat(Palette.IVORY, INCISION, Palette.INK, SPACE)
	var pressed := _flat(Palette.IVORY.lerp(Palette.INK, 0.12), 0, Palette.INK, SPACE)
	pressed.content_margin_top = SPACE + INCISION
	pressed.content_margin_bottom = SPACE - INCISION
	var blocked := _flat(Palette.IVORY.lerp(Palette.INK, Palette.DISABLED_MIX), 0, Palette.INK, SPACE)
	option.add_theme_stylebox_override("normal", paper)
	option.add_theme_stylebox_override("hover", hover)
	option.add_theme_stylebox_override("pressed", pressed)
	option.add_theme_stylebox_override("disabled", blocked)
	option.add_theme_stylebox_override("focus", focus_rule(Palette.INK))
	option.add_theme_icon_override("arrow", _icon("chevron"))
	option.add_theme_constant_override("modulate_arrow", 0)
	_apply_control_text(option, Palette.INK)
	var popup: PopupMenu = option.get_popup()
	popup.add_theme_stylebox_override("panel", _flat(Palette.INK, 0, Palette.IVORY, SPACE))
	popup.add_theme_stylebox_override("hover", _flat(Palette.IVORY, INCISION, Palette.INK))
	popup.add_theme_font_override("font", BODY_FONT)
	popup.add_theme_font_size_override("font_size", CONTROL_SIZE)
	popup.add_theme_color_override("font_color", Palette.IVORY)
	popup.add_theme_color_override("font_hover_color", Palette.INK)
	popup.add_theme_color_override("font_disabled_color", Palette.MUTED)
	for role: String in ["radio_checked", "checked"]:
		popup.add_theme_icon_override(role, _icon("box_on"))
	for role: String in ["radio_unchecked", "unchecked"]:
		popup.add_theme_icon_override(role, _icon("box_off"))

static func _apply_control_text(control: Control, pigment: Color) -> void:
	control.add_theme_font_override("font", BODY_FONT)
	control.add_theme_font_size_override("font_size", CONTROL_SIZE)
	control.add_theme_constant_override("outline_size", 0)
	for state: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		control.add_theme_color_override(state, pigment)
	control.add_theme_color_override("font_disabled_color", pigment.lerp(Palette.MUTED, 0.6))

static func apply_scroll(scroll: ScrollContainer) -> void:
	for bar: ScrollBar in [scroll.get_v_scroll_bar(), scroll.get_h_scroll_bar()]:
		apply_scrollbar(bar)

static func apply_meter(bar: ProgressBar) -> void:
	# HUD measure: the same incised groove as the slider, ivory travel.
	var groove := _flat(Palette.INK.lerp(Palette.IVORY, 0.18), 0)
	bar.add_theme_stylebox_override("background", groove)
	bar.add_theme_stylebox_override("fill", _flat(Palette.IVORY, 0))

static func apply_scrollbar(bar: ScrollBar) -> void:
	# Thin incised track; ivory thumb, wax only while grabbed.
	# The track margins give the bar its usable width (at least 10 px).
	var track := _flat(Palette.INK.lerp(Palette.IVORY, 0.18), 0)
	for side: String in ["left", "right", "top", "bottom"]:
		track.set("content_margin_" + side, 5)
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("scroll_focus", track)
	for state: String in ["grabber", "grabber_highlight"]:
		var thumb := _flat(Palette.IVORY, 0)
		thumb.content_margin_left = 5
		thumb.content_margin_right = 5
		bar.add_theme_stylebox_override(state, thumb)
	var held := _flat(Palette.WAX, 0)
	held.content_margin_left = 5
	held.content_margin_right = 5
	bar.add_theme_stylebox_override("grabber_pressed", held)

static func apply_tooltip(panel: Control, text: Control) -> void:
	# Consultation note: paper and ink, never the confirmation mark.
	apply_inset(panel)
	if text is RichTextLabel:
		apply_rich_text(text as RichTextLabel, Palette.INK)
	elif text is Label:
		apply_body(text as Label, Palette.INK)

static func apply_dialog(dialog: AcceptDialog) -> void:
	var page := _flat(Palette.INK, 0, Palette.IVORY, SPACE * 2)
	dialog.add_theme_stylebox_override("panel", page)
	dialog.add_theme_stylebox_override("embedded_border", page)
	dialog.add_theme_color_override("title_color", Palette.IVORY)
	dialog.add_theme_font_override("title_font", DISPLAY_FONT)
	apply_body(dialog.get_label(), Palette.IVORY)
	var ok: Button = dialog.get_ok_button()
	if ok != null:
		apply_primary_button(ok)
		# AcceptDialog sizes its native button from its minimum, unlike our rows.
		ok.autowrap_mode = TextServer.AUTOWRAP_OFF
		ok.custom_minimum_size = Vector2(180, 52)

static func animate_panel_in(panel: CanvasItem, reduced_motion: bool) -> void:
	# One opacity tween per surface; toggling reduced motion settles it too.
	if panel.has_meta("kit_enter_tween"):
		var previous: Tween = panel.get_meta("kit_enter_tween")
		if is_instance_valid(previous): previous.kill()
	if not panel.has_meta("kit_motion_wired"):
		panel.set_meta("kit_motion_wired", true)
		var panel_ref: WeakRef = weakref(panel)
		panel.get_node("/root/GameEvents").settings_changed.connect(func(payload: Dictionary) -> void:
			var target: CanvasItem = panel_ref.get_ref()
			if target != null and bool(payload.get("reduced_motion", false)):
				if target.has_meta("kit_enter_tween"):
					var running: Tween = target.get_meta("kit_enter_tween")
					if is_instance_valid(running): running.kill()
				target.modulate.a = 1.0)
	if reduced_motion:
		panel.modulate.a = 1.0
		return
	panel.modulate.a = 0.0
	var tween: Tween = panel.create_tween()
	panel.set_meta("kit_enter_tween", tween)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.16)

static func bind_button_motion(_button: Button) -> void:
	# The stylus accent is owned by the action surface (see apply_action);
	# kept for the common API so callers never add scale tweens of their own.
	pass
