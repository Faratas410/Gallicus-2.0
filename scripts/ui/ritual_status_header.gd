extends Control
## Stable reading positions throughout the active ritual; existing HUD owns data.
const Kit = preload("res://scripts/ui/manifesto_kit.gd")
var ui: CanvasLayer
var context: Label
var pressure: Label
var chain: Label
var account: Label
var bando: Label
var crowd: Label
var scars: Button
var factor := 1.0
var _pressure_level := 0

func _ready() -> void:
	ui = get_parent().get_parent() as CanvasLayer
	z_index = 120
	mouse_filter = MOUSE_FILTER_IGNORE
	context = _label()
	pressure = _label()
	chain = _label()
	account = _label()
	bando = _label()
	crowd = _label()
	bando.mouse_filter = MOUSE_FILTER_PASS
	account.mouse_filter = MOUSE_FILTER_PASS
	scars = Button.new()
	scars.name = "StatusScars"
	add_child(scars)
	Kit.apply_secondary_button(scars)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var box := StyleBoxEmpty.new()
		box.content_margin_left = 6
		box.content_margin_right = 6
		scars.add_theme_stylebox_override(state, box)
	scars.pressed.connect(func() -> void: ui.call("_show_scars_detail"))
	resized.connect(_layout)
	for item: Node in [ui.get("bando_panel"), ui.get("crowd_favor_panel"), ui.get("scars_panel"), ui.get_node("HUD/PressureRail"), ui.get("hud_top_left_stats_box")]:
		if item != null:
			item.hide()
			item.visibility_changed.connect(func() -> void:
				if item.visible: item.hide())
	_layout()

func _label() -> Label:
	var item := Label.new()
	item.mouse_filter = MOUSE_FILTER_IGNORE
	Kit.apply_body(item)
	add_child(item)
	return item

func _place(item: Control, at: Vector2, extent: Vector2) -> void:
	item.position = at * factor
	item.size = extent * factor
	item.add_theme_font_size_override("font_size", roundi(15 * factor))

func _layout() -> void:
	factor = minf(size.x / 1280.0, size.y / 720.0)
	if context == null: return
	_place(context, Vector2(36, 12), Vector2(160, 26))
	_place(pressure, Vector2(210, 12), Vector2(160, 26))
	_place(chain, Vector2(535, 12), Vector2(165, 26))
	_place(account, Vector2(730, 12), Vector2(380, 26))
	_place(bando, Vector2(36, 46), Vector2(650, 26))
	_place(crowd, Vector2(730, 46), Vector2(510, 26))
	_place(scars, Vector2(1145, 10), Vector2(110, 38))
	queue_redraw()

func _process(_delta: float) -> void:
	var menu: Control = ui.get_parent().get_node("MenuLayer/MainMenu")
	visible = not menu.is_visible_in_tree() and not bool(ui.get("_ending_mode_active")) and not ui.get("game_over_panel").is_visible_in_tree()
	if not visible: return
	var port: RefCounted = ui.get("_run_manager_port")
	if port != null and port.has_manager():
		context.text = tr("Arena %d di %d") % [port.get_arena_index(), port.get_arena_limit()]
		chain.text = tr("Catena %s") % ui.call("_chain_multiplier_text", port.get_seal_chain_multiplier())
	_pressure_level = int(ui.get("_escalation_level"))
	pressure.text = tr("PRESSIONE %d/%d") % [_pressure_level, 10]
	account.text = tr("Favore %+d.") % roundi(float(ui.get("crowd_favor_bar").value)) + "   " + tr("Conto %d Denari") % int(ui.get("_ledger_denari"))
	account.tooltip_text = ui.get("crowd_favor_body").text + "\n" + ui.get("crowd_favor_note").text
	crowd.text = tr(str(ui.call("_crowd_favor_band_text", roundi(float(ui.get("crowd_favor_bar").value)))))
	bando.text = tr("BANDO DI ORVO") + "  " + ui.get("bando_body").text
	bando.tooltip_text = ui.get("bando_note").text
	scars.text = ui.get_node("HUD/ScarsPanel/ScarsVBox/ScarsTitlePanel/ScarsTitle").text
	scars.tooltip_text = ui.get("scars_label").text
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, size.x, 82 * factor), Color(0.098, 0.098, 0.09, 0.96))
	draw_line(Vector2(30, 81) * factor, Vector2(size.x - 30 * factor, 81 * factor), Color(0.64, 0.62, 0.56, 0.45), 1)
	for i in range(10):
		var at := Vector2(380 + i * 12, 14)
		var points := PackedVector2Array([at, at + Vector2(7, 0), at + Vector2(3, 20), at + Vector2(-4, 20)])
		for p in range(points.size()): points[p] *= factor
		draw_colored_polygon(points, Kit.Palette.WAX.lightened(0.15) if i < _pressure_level else Kit.Palette.MUTED.darkened(0.5))
