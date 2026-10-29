extends Control
## The illustrated objects are passive; UI_Root remains the data consumer.
const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const SKIN = preload("res://assets/ui/generated/ritual_hud_insegne.png")
const CONTENT_TOP := 128.0
const IVORY := Color("f4e4b5")
const INK := Color("382114")
var ui: CanvasLayer
var context: Label
var pressure: Label
var chain: Label
var account: Label
var favor: Label
var bando: Label
var crowd: Label
var scars: Button
var scar_count: Label
var captions: Dictionary[String, Label] = {}
var factor := 1.0
var _pressure_level := 0

func _ready() -> void:
	ui = get_parent().get_parent() as CanvasLayer
	z_index = 120
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	context = _label()
	pressure = _label()
	chain = _label()
	account = _label()
	favor = _label()
	bando = _label(INK)
	crowd = _label()
	scar_count = _label(INK)
	for key: String in ["ARENA", "CATENA", "DENARI", "FAVORE", "SEGNI"]:
		captions[key] = _label(INK if key == "SEGNI" else IVORY)
	bando.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	crowd.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bando.mouse_filter = MOUSE_FILTER_PASS
	account.mouse_filter = MOUSE_FILTER_PASS
	favor.mouse_filter = MOUSE_FILTER_PASS
	crowd.mouse_filter = MOUSE_FILTER_PASS
	scars = Button.new()
	scars.name = "StatusScars"
	add_child(scars)
	# Native localized text remains accessible; the ink labels use two sizes.
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		scars.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_outline_color", "font_hover_pressed_color"]:
		scars.add_theme_color_override(state, Color.TRANSPARENT)
	scars.add_theme_font_size_override("font_size", 1)
	scars.pressed.connect(func() -> void: ui.call("_show_scars_detail"))
	resized.connect(_layout)
	for item: Node in [ui.get("bando_panel"), ui.get("crowd_favor_panel"), ui.get("scars_panel"), ui.get_node("HUD/PressureRail"), ui.get("hud_top_left_stats_box")]:
		if item != null:
			item.hide()
			item.visibility_changed.connect(func() -> void:
				if item.visible: item.hide())
	_layout()

func _label(pigment: Color = IVORY) -> Label:
	var item := Label.new()
	item.mouse_filter = MOUSE_FILTER_IGNORE
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item.add_theme_font_override("font", Kit.DISPLAY_FONT)
	item.add_theme_color_override("font_color", pigment)
	item.add_theme_constant_override("outline_size", 0)
	add_child(item)
	item.minimum_size_changed.connect(func() -> void: _restore_slot.call_deferred(item))
	return item

func _restore_slot(item: Control) -> void:
	# Theme/font minimums update after resize; discard the old resolution's
	# enlarged Control rectangle once the new metrics have settled.
	if not item.has_meta("hud_slot"): return
	var rect: Rect2 = item.get_meta("hud_slot")
	item.position = rect.position * factor
	item.size = rect.size * factor

func _place(item: Control, rect: Rect2, font_size: int = 18) -> void:
	item.set_meta("hud_slot", rect)
	item.add_theme_font_size_override("font_size", roundi(font_size * factor))
	item.position = rect.position * factor
	item.size = rect.size * factor

func _layout() -> void:
	factor = minf(size.x / 1280.0, size.y / 720.0)
	if context == null: return
	_place(captions["ARENA"], Rect2(46, 73, 128, 24))
	_place(context, Rect2(44, 92, 132, 39), 31)
	_place(pressure, Rect2(230, 12, 310, 24), 19)
	_place(captions["CATENA"], Rect2(681, 22, 74, 24), 16)
	_place(chain, Rect2(679, 43, 80, 38), 30)
	_place(captions["DENARI"], Rect2(857, 24, 90, 26), 15)
	_place(account, Rect2(875, 45, 68, 42), 34)
	_place(captions["FAVORE"], Rect2(1033, 24, 85, 26), 16)
	_place(favor, Rect2(1029, 45, 91, 42), 34)
	_place(bando, Rect2(237, 89, 493, 32), 17)
	_place(crowd, Rect2(806, 99, 308, 32), 15)
	_place(captions["SEGNI"], Rect2(1158, 58, 87, 25), 17)
	_place(scar_count, Rect2(1158, 80, 87, 42), 34)
	_place(scars, Rect2(1138, 12, 118, 126), 1)
	queue_redraw()

func _fit_number(label: Label, available_width: float) -> void:
	var point_size := 34
	while point_size > 18 and Kit.DISPLAY_FONT.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, point_size).x > available_width:
		point_size -= 1
	label.add_theme_font_size_override("font_size", roundi(point_size * factor))
	label.size.x = available_width * factor

func _process(_delta: float) -> void:
	var menu: Control = ui.get_parent().get_node("MenuLayer/MainMenu")
	visible = not menu.is_visible_in_tree() and not bool(ui.get("_ending_mode_active")) and not ui.get("game_over_panel").is_visible_in_tree()
	if not visible: return
	for key: String in captions:
		captions[key].text = tr(key)
	var port: RefCounted = ui.get("_run_manager_port")
	if port != null and port.has_manager():
		context.text = "%d / %d" % [port.get_arena_index(), port.get_arena_limit()]
		chain.text = ui.call("_chain_multiplier_text", port.get_seal_chain_multiplier())
	_pressure_level = int(ui.get("_escalation_level"))
	pressure.text = tr("PRESSIONE %d/%d") % [_pressure_level, 10]
	account.text = str(int(ui.get("_ledger_denari")))
	var favor_value: int = roundi(float(ui.get("crowd_favor_bar").value))
	favor.text = "%+d" % favor_value
	favor.tooltip_text = ui.get("crowd_favor_body").text + "\n" + ui.get("crowd_favor_note").text
	account.tooltip_text = tr("Conto %d Denari") % int(ui.get("_ledger_denari"))
	var band: String = ui.call("_crowd_favor_band_text", favor_value)
	# A shorter localized caption for this narrow surface; same band/meaning.
	crowd.text = tr("Ben disposta: aiuta un po' il sigillo.") if band == "Ben disposta: il sigillo regge un po' di più." else tr(band)
	crowd.tooltip_text = favor.tooltip_text
	bando.text = tr("BANDO DI ORVO") + "  " + ui.get("bando_body").text
	bando.tooltip_text = ui.get("bando_note").text
	var source_title: Label = ui.get_node("HUD/ScarsPanel/ScarsVBox/ScarsTitlePanel/ScarsTitle")
	scar_count.text = str(int(source_title.get_meta("scar_count", 0)))
	scars.text = source_title.text
	scars.tooltip_text = ui.get("scars_label").text
	scars.disabled = str(ui.get("_scars_detail_text")).is_empty()
	_fit_number(account, 68)
	_fit_number(scar_count, 87)
	queue_redraw()

func _draw() -> void:
	# Only the header region is consumed, not the unused transparent canvas.
	draw_texture_rect_region(SKIN, Rect2(0, 0, 1280 * factor, 220.0 * 1280.0 / 1672.0 * factor), Rect2(0, 0, 1672, 220))
	for index: int in range(clampi(_pressure_level, 0, 10)):
		var at := Vector2(245 + index * 29.3, 43)
		var cell := Rect2(at * factor, Vector2(21, 22) * factor)
		draw_rect(cell, Color("a43e26"))
		draw_line(cell.position + Vector2(0, factor), cell.position + Vector2(cell.size.x, factor), Color("e9a859"), 2 * factor)
	if scars != null and (scars.has_focus() or scars.is_hovered() or scars.button_pressed):
		var pigment := INK if scars.button_pressed else IVORY
		draw_line(Vector2(1156, 128) * factor, Vector2(1242, 128) * factor, pigment, 3 * factor)
		if scars.has_focus():
			draw_line(Vector2(1156, 132) * factor, Vector2(1242, 132) * factor, INK, 2 * factor)
