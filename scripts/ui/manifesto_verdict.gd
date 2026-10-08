extends Panel
## Presentation of existing decisions. No intents, outcome logic or saved state.

const DISPLAY_FONT = preload("res://assets/ui/fonts/font_manifesto.tres")
const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const INK := Palette.INK
const IVORY := Palette.IVORY
const RED := Palette.WAX
const ROOT_PATH := "Box_PUSH_YOUR_LUCK/"
var ui: CanvasLayer
var active: bool = false
var pressure: int = 0
var saved_hud: Dictionary = {}
var caption: Label
var choices: HBoxContainer

func _ready() -> void:
	ui = get_parent().get_parent().get_parent() as CanvasLayer
	choices = get_node(ROOT_PATH + "Box_PUSH_YOUR_LUCK_CHOICES")
	caption = Label.new()
	caption.name = "StakeCaption"
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_override("font", DISPLAY_FONT)
	caption.add_theme_font_size_override("font_size", 38)
	caption.add_theme_color_override("font_color", IVORY)
	add_child(caption)
	resized.connect(_layout)
	visibility_changed.connect(_on_visibility_changed)
	for child: Control in choices.get_children():
		child.resized.connect(_layout_cards)
		var button := child.get_child(0) as Button
		for event: Signal in [button.mouse_entered, button.mouse_exited, button.button_down, button.button_up, button.focus_entered, button.focus_exited]:
			event.connect(queue_redraw)
	_layout()

func _on_visibility_changed() -> void:
	set_manifesto_active(is_visible_in_tree())

func set_manifesto_active(value: bool) -> void:
	if ui == null:
		return
	if value == active:
		if active:
			_layout()
		return
	active = value
	if active:
		for name: String in ["BandoPanel", "CrowdFavorPanel", "ScarsPanel", "PressureRail"]:
			var node: Control = ui.get_node("HUD/" + name)
			saved_hud[name] = [[node.anchor_left, node.anchor_top, node.anchor_right, node.anchor_bottom], [node.offset_left, node.offset_top, node.offset_right, node.offset_bottom], node.custom_minimum_size]
		_layout()
	else:
		for name: String in saved_hud:
			var node: Control = ui.get_node("HUD/" + name)
			var old: Array = saved_hud[name]
			for side: int in range(4):
				node.set_anchor(side, old[0][side])
			node.custom_minimum_size = old[2]
			for side: int in range(4):
				node.set_offset(side, old[1][side])
		saved_hud.clear()
	queue_redraw()

func present_payload(meta: Dictionary) -> void:
	var stake: Label = ui.get("push_luck_details")
	stake.text = str(maxi(int(meta.get("stake_glory", 0)), 0))
	# Explicit numeric payload, never extract values from localized prose.
	var number_size: int = 206
	while number_size > 48 and DISPLAY_FONT.get_string_size(stake.text, HORIZONTAL_ALIGNMENT_LEFT, -1, number_size).x > 164:
		number_size -= 2
	stake.add_theme_font_size_override("font_size", number_size)
	stake.add_theme_color_override("font_color", IVORY)
	caption.text = "GLORIA\nIN POSTA"
	ui.get("push_luck_title").add_theme_color_override("font_color", IVORY)
	ui.get("push_luck_info").add_theme_color_override("font_color", IVORY)
	pressure = int(ui.get("_escalation_level"))
	ui.get("push_luck_audience_reason").text = str(meta.get("state_line", ""))
	refresh_buttons()
	_layout()
	_settle_layout()

func _settle_layout() -> void:
	# Wrapped minimum sizes settle after the localized text and column width.
	await get_tree().process_frame
	_layout()
	await get_tree().process_frame
	_layout()

func present_pressure(level: int) -> void:
	pressure = level
	queue_redraw()

func refresh_buttons() -> void:
	if ui == null:
		return
	for key: String in ["cashout", "condanna", "double"]:
		var button: Button = ui.get("push_luck_" + key + "_button")
		var note: Label = ui.get("push_luck_" + key + "_note")
		var empty := StyleBoxEmpty.new()
		for state: String in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, empty)
		var focus := StyleBoxFlat.new()
		focus.bg_color = Color.TRANSPARENT
		focus.border_color = INK if key == "cashout" else IVORY
		focus.border_width_bottom = 4
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_font_override("font", DISPLAY_FONT)
		# Keep the semantic Button text; a native child title owns its layout.
		button.add_theme_font_size_override("font_size", 1)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var color: Color = INK if key == "cashout" else IVORY
		for role: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_disabled_color"]:
			button.add_theme_color_override(role, Color.TRANSPARENT)
		var title: Label = button.get_node_or_null("PrintedTitle")
		if title == null:
			title = Label.new()
			title.name = "PrintedTitle"
			title.mouse_filter = Control.MOUSE_FILTER_IGNORE
			title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.add_child(title)
		# Keep the localization key so a live language change re-translates it.
		title.text = button.text
		title.add_theme_font_override("font", DISPLAY_FONT)
		title.add_theme_font_size_override("font_size", 40 if not ui.get("push_luck_condanna_button").visible else 26)
		title.add_theme_color_override("font_color", color)
		note.add_theme_color_override("font_color", color)
		note.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		note.size_flags_vertical = Control.SIZE_FILL
		button.modulate = Color.WHITE
		var wax: CanvasItem = button.get_node_or_null("WaxTrace")
		if wax != null:
			wax.hide()
	queue_redraw()

func _layout_cards() -> void:
	if ui == null:
		return
	for key: String in ["cashout", "condanna", "double"]:
		var button: Button = ui.get("push_luck_" + key + "_button")
		var note: Label = ui.get("push_luck_" + key + "_note")
		if button == null or note == null:
			continue
		var column: Control = button.get_parent()
		_place(button, Rect2(Vector2.ZERO, column.size))
		var title: Control = button.get_node_or_null("PrintedTitle")
		if title != null:
			_place(title, Rect2(54, 10, column.size.x - 70, 54))
		_place(note.get_parent(), Rect2(0, 60, column.size.x, 90))
	queue_redraw()

func _place(node: Control, rect: Rect2) -> void:
	node.set_anchors_preset(Control.PRESET_TOP_LEFT)
	node.custom_minimum_size = Vector2.ZERO
	node.position = rect.position
	node.size = rect.size

func _layout() -> void:
	if ui == null or caption == null:
		return
	var field: Control = get_node(ROOT_PATH)
	_place(field, Rect2(Vector2.ZERO, size))
	var rail_width: float = 184.0
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_TITLEPanel"), Rect2(38, 28, 150, 94))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_SUBTITLEPanel"), Rect2(30, 112, 170, 260))
	_place(caption, Rect2(38, 365, 155, 132))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_BODYPanel"), Rect2(38, size.y - 160, 160, 64))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_HINTPanel"), Rect2(size.x - 286, 325, 246, 60))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_FOOTERPanel"), Rect2(rail_width + 54, size.y - 290, size.x - rail_width - 340, 46))
	_place(choices, Rect2(rail_width + 48, size.y - 244, size.x - rail_width - 80, 158))
	if active:
		_place(ui.get_node("HUD/BandoPanel"), Rect2(size.x - 286, 24, 254, 162))
		_place(ui.get_node("HUD/CrowdFavorPanel"), Rect2(size.x - 286, 196, 254, 122))
		_place(ui.get_node("HUD/ScarsPanel"), Rect2(size.x - 286, 334, 254, 112))
		_place(ui.get_node("HUD/PressureRail"), Rect2(32, size.y - 64, size.x - 64, 60))
	# Audience already has its complete reactive section in the right column.
	get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_HINTPanel").hide()
	_layout_cards()
	queue_redraw()

func _slab(rect: Rect2, color: Color, salt: int = 0) -> void:
	if rect.size.x < 24 or rect.size.y < 24:
		return
	# Sparse, fixed edge cuts; quiet reading surfaces and no gameplay RNG.
	var notch: float = 0.24 + float(salt % 3) * 0.12
	var points := PackedVector2Array([
		rect.position + Vector2(2, 2),
		rect.position + Vector2(rect.size.x * notch, 0),
		rect.position + Vector2(rect.size.x * notch + 12, 2),
		Vector2(rect.end.x - 2, rect.position.y + 1),
		Vector2(rect.end.x, rect.position.y + rect.size.y * 0.63),
		rect.end - Vector2(2, 2),
		Vector2(rect.position.x + rect.size.x * 0.72, rect.end.y),
		Vector2(rect.position.x + rect.size.x * 0.72 - 16, rect.end.y - 2),
		Vector2(rect.position.x + 1, rect.end.y - 1),
		rect.position + Vector2(0, rect.size.y * 0.31),
	])
	draw_colored_polygon(points, color)

func _mark(at: Vector2, color: Color, impressed: bool) -> void:
	for i: int in range(3):
		var start := at + Vector2(i * 6, i * 11)
		var polygon := PackedVector2Array([start + Vector2(26, 0), start + Vector2(12, 25), start + Vector2(0, 34)])
		if impressed:
			draw_colored_polygon(polygon, color)
		else:
			polygon.append(polygon[0])
			draw_polyline(polygon, color, 1.25, true)

func _draw() -> void:
	if ui == null or choices == null:
		return
	_slab(Rect2(20, -6, 188, size.y - 66), INK, 2)
	_slab(Rect2(28, -6, 172, size.y - 78), RED, 6)
	_slab(Rect2(size.x - 302, -6, 306, 470), INK, 9)
	var feedback: Label = ui.get("push_luck_audience_reason")
	if feedback != null and not feedback.text.is_empty():
		_slab(Rect2(232, size.y - 290, size.x - 524, 46), INK, 5)
	_mark(Vector2(104, maxf(505, caption.position.y + caption.get_line_count() * caption.get_line_height() + 12)), IVORY, false)
	for index: int in range(choices.get_child_count()):
		var column: Control = choices.get_child(index)
		if not column.visible:
			continue
		var rect := Rect2(choices.position + column.position, column.size)
		var key: String = ["cashout", "condanna", "double"][index]
		var button: Button = ui.get("push_luck_" + key + "_button")
		var meta: String = ["registry_receipt_taken", "registry_condemnation_mark_registered", "registry_second_incision_sealed"][index]
		var impressed: bool = bool(button.get_meta(meta, false))
		var pigment: Color = INK if index == 0 else IVORY
		var surface: Color = IVORY if index == 0 else RED if index == 2 else INK
		var mode: int = button.get_draw_mode()
		if button.disabled and not impressed:
			surface = surface.lerp(INK, 0.16)
		elif mode == BaseButton.DRAW_PRESSED or mode == BaseButton.DRAW_HOVER_PRESSED:
			surface = surface.lerp(pigment, 0.12)
		_slab(rect.grow(2), INK, index * 3)
		_slab(rect, surface, index + 2)
		_mark(rect.position + Vector2(13, 20), RED if index == 0 else IVORY, impressed)
		if button.disabled and not impressed:
			# A double bar identifies the blocked object independently of color.
			for y: int in [92, 99]:
				draw_line(rect.position + Vector2(14, y), rect.position + Vector2(42, y), pigment, 3)
		elif mode == BaseButton.DRAW_PRESSED or mode == BaseButton.DRAW_HOVER_PRESSED:
			draw_rect(rect.grow(-7), pigment, false, 2)
		elif mode == BaseButton.DRAW_HOVER:
			draw_line(Vector2(rect.position.x + 8, rect.end.y - 8), rect.end - Vector2(8, 8), pigment, 2)
	# Additional fixed edge traces express existing pressure without moving UI.
	if pressure > 2:
		for i: int in range(mini(pressure / 3, 3)):
			draw_line(Vector2(201, 80 + i * 135), Vector2(216, 116 + i * 135), RED, 3)
