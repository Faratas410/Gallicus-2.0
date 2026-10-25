extends Panel
## Reactive Incasso/Rilancio stage. Native buttons retain all existing intents.
const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const Atmosphere = preload("res://scripts/ui/verdict_atmosphere.gd")
const ObjectSkin = preload("res://scripts/ui/verdict_object.gd")
const TYPE = preload("res://assets/ui/fonts/font_verdict.tres")
const IVORY := Color("e7ddc5")
const ROOT_PATH := "Box_PUSH_YOUR_LUCK/"
const HUD_NAMES := ["BandoPanel", "CrowdFavorPanel", "ScarsPanel", "PressureRail"]
var ui: CanvasLayer
var active := false
var pressure := 0
var saved_hud: Dictionary = {}
var choices: HBoxContainer
var caption: Label
var context: Label
var bando: Label
var purse: Label
var voice: Label
var voice_name: Label
var chain: Label
var pressure_label: Label
var portrait: TextureRect
var scars: Button
var atmosphere: Control
var count_tween: Tween
var chain_tween: Tween
var last_chain := 1.0
var factor := 1.0
var target_amount := 0
var pending_outcome := -1
var registered_echo: Control
var registered_at := 0
var saved_notice: Dictionary = {}

func _ready() -> void:
	ui = get_parent().get_parent().get_parent() as CanvasLayer
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	choices = get_node(ROOT_PATH + "Box_PUSH_YOUR_LUCK_CHOICES")
	atmosphere = Atmosphere.new()
	add_child(atmosphere)
	move_child(atmosphere, 0)
	caption = _label("StakeCaption", 20)
	context = _label("ArenaContext", 15)
	bando = _label("BandoContext", 15)
	purse = _label("CoinContext", 15)
	bando.mouse_filter = Control.MOUSE_FILTER_PASS
	purse.mouse_filter = Control.MOUSE_FILTER_PASS
	chain = _label("Chain", 27)
	chain.hide()
	pressure_label = _label("Pressure", 18)
	# Persistent metrics now live at the same coordinates in every ritual.
	for item: Control in [context, bando, purse, pressure_label]: item.hide()
	voice_name = _label("VessaName", 15)
	voice = _label("VessaVoice", 21)
	portrait = TextureRect.new()
	portrait.name = "VessaPortrait"
	portrait.texture = preload("res://assets/ui/generated/dialogue_vessa_cutout.png")
	portrait.material = preload("res://assets/ui/official/portrait_grounding.tres")
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
	scars = Button.new()
	scars.name = "ScarsToken"
	scars.pressed.connect(func() -> void: ui.call("_show_scars_detail"))
	add_child(scars)
	scars.hide()
	Kit.apply_action(scars, &"ink", true)
	var token_style := StyleBoxEmpty.new()
	token_style.content_margin_left = 8
	token_style.content_margin_right = 8
	for state in ["normal", "hover", "pressed", "disabled"]:
		scars.add_theme_stylebox_override(state, token_style)
	GameEvents.seal_strike_resolved.connect(func(payload: Dictionary) -> void:
		pending_outcome = 1 if bool(payload.get("held", false)) else 0)
	GameEvents.request_show_main_menu.connect(func() -> void: pending_outcome = -1)
	GameEvents.settings_changed.connect(_on_settings_changed)
	resized.connect(_layout)
	visibility_changed.connect(func() -> void: set_manifesto_active(is_visible_in_tree()))
	for child: Control in choices.get_children():
		child.resized.connect(_layout_cards)
	for hud_name: String in HUD_NAMES:
		var hud: Control = ui.get_node("HUD/" + hud_name)
		hud.visibility_changed.connect(func() -> void:
			if active and hud.visible:
				hud.hide())
	_layout()
	set_process(false)

func _label(node_name: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Kit.apply_label(label, &"body", IVORY)
	label.add_theme_font_override("font", TYPE)
	label.set_meta("base_size", font_size)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)
	return label

func set_manifesto_active(value: bool) -> void:
	if ui == null or value == active:
		return
	active = value
	set_process(active)
	atmosphere.set_process(active)
	if active:
		var notice: Control = ui.get("scar_popup_panel")
		for key in ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom", "offset_left", "offset_top", "offset_right", "offset_bottom"]:
			saved_notice[key] = notice.get(key)
		for hud_name: String in HUD_NAMES:
			var hud: Control = ui.get_node("HUD/" + hud_name)
			saved_hud[hud_name] = hud.visible
			hud.hide()
		_layout()
	else:
		_finish_registered_gesture()
		var notice: Control = ui.get("scar_popup_panel")
		for key in saved_notice:
			notice.set(key, saved_notice[key])
		saved_notice.clear()
		for hud_name: String in saved_hud:
			ui.get_node("HUD/" + hud_name).visible = saved_hud[hud_name]
		saved_hud.clear()
		if count_tween:
			count_tween.kill()
		if chain_tween:
			chain_tween.kill()
		chain.scale = Vector2.ONE

func _on_settings_changed(payload: Dictionary) -> void:
	if not bool(payload.get("reduced_motion", false)):
		return
	if count_tween: count_tween.kill()
	if chain_tween: chain_tween.kill()
	if ui.get("push_luck_details") != null:
		ui.get("push_luck_details").text = str(target_amount)
	chain.scale = Vector2.ONE
	_discard_echo()
	for echo in get_tree().get_nodes_in_group("living_verdict_echo"):
		echo.queue_free()

func present_payload(meta: Dictionary) -> void:
	_discard_echo()
	var stake: Label = ui.get("push_luck_details")
	var amount := maxi(int(meta.get("stake_glory", 0)), 0)
	target_amount = amount
	if count_tween:
		count_tween.kill()
	stake.text = str(amount)
	stake.add_theme_color_override("font_color", IVORY)
	if not ui.call("_is_reduced_motion"):
		count_tween = create_tween()
		count_tween.tween_method(func(value: float) -> void: stake.text = str(roundi(value)), 0.0, float(amount), 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	caption.text = tr("Gloria in posta")
	ui.get("push_luck_title").text = tr("Quanto vale fermarsi?")
	ui.get("push_luck_audience_reason").text = str(meta.get("state_line", ""))
	voice_name.text = tr("VESSA, AL BANCO")
	voice.text = tr("Posso scriverle adesso. Dopo, chissà. Anche lo zero si scrive.") if not bool(meta.get("cashout_locked", false)) else tr("Il banco è qui. Il permesso, oggi, lo tiene la gradinata.")
	pressure = int(ui.get("_escalation_level"))
	if pending_outcome >= 0:
		atmosphere.call("present_outcome", pending_outcome == 1)
		pending_outcome = -1
	_sync_context()
	refresh_buttons()
	_layout()
	_settle_layout()

func _settle_layout() -> void:
	await get_tree().process_frame
	_layout()
	await get_tree().process_frame
	_layout()

func _sync_context() -> void:
	var port: RefCounted = ui.get("_run_manager_port")
	if port != null and port.has_manager():
		context.text = tr("Arena %d di %d") % [port.get_arena_index(), port.get_arena_limit()]
		var multiplier: float = port.get_seal_chain_multiplier()
		chain.text = tr("Catena %s") % ui.call("_chain_multiplier_text", multiplier)
		if not is_equal_approx(multiplier, last_chain) and not ui.call("_is_reduced_motion"):
			if chain_tween:
				chain_tween.kill()
			chain.pivot_offset = chain.size * 0.5
			chain_tween = create_tween()
			chain_tween.tween_property(chain, "scale", Vector2(1.08, 1.08), 0.13)
			chain_tween.tween_property(chain, "scale", Vector2.ONE, 0.22)
		last_chain = multiplier
	var view: Dictionary = ui.get("_bando_view")
	bando.text = tr("BANDO DI ORVO") + " · " + ui.get("bando_body").text if not view.is_empty() else ""
	bando.tooltip_text = ui.get("bando_note").text
	var favor := roundi(float(ui.get("crowd_favor_bar").value))
	purse.text = tr("Favore %+d.") % favor + "   ·   " + tr("Conto %d Denari") % int(ui.get("_ledger_denari"))
	purse.tooltip_text = ui.get("crowd_favor_body").text
	scars.text = ui.get_node("HUD/ScarsPanel/ScarsVBox/ScarsTitlePanel/ScarsTitle").text
	scars.tooltip_text = ui.get("scars_label").text
	atmosphere.set("favor", favor)
	atmosphere.set("pressure", pressure)
	pressure_label.text = tr("PRESSIONE %d/%d") % [pressure, 10]

func _process(_delta: float) -> void:
	if count_tween and count_tween.is_running() and ui.call("_is_reduced_motion"):
		_on_settings_changed({"reduced_motion": true})
	_sync_context()

func present_pressure(level: int) -> void:
	pressure = level
	if atmosphere:
		atmosphere.set("pressure", level)

func refresh_buttons() -> void:
	if ui == null:
		return
	for key: String in ["cashout", "condanna", "double"]:
		var button: Button = ui.get("push_luck_" + key + "_button")
		var note: Label = ui.get("push_luck_" + key + "_note")
		var metadata: StringName = &"registry_receipt_taken" if key == "cashout" else &"registry_second_incision_sealed" if key == "double" else &"registry_condemnation_mark_registered"
		var registered := bool(button.get_meta(metadata, false))
		Kit.apply_action(button, &"paper" if key == "cashout" else &"wax", false, registered)
		button.get_node("ManifestoSurface").hide()
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var skin: Control = button.get_node_or_null("VerdictObject")
		if skin == null:
			skin = ObjectSkin.new()
			skin.name = "VerdictObject"
			button.add_child(skin)
			button.move_child(skin, 0)
			skin.set("kind", key)
		if registered and not skin.get("registered") and key == "double":
			atmosphere.call("risk_impact")
		if registered and not skin.get("registered") and active:
			_remember_registered_gesture(button, note, key)
		skin.set("registered", registered)
		Kit.apply_label(note, &"body", Color("29231a") if key == "cashout" else IVORY)
		note.add_theme_font_override("font", TYPE)
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		note.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		note.size_flags_vertical = Control.SIZE_FILL
	_layout_cards()

func _discard_echo() -> void:
	if is_instance_valid(registered_echo):
		registered_echo.free()
	registered_echo = null

func _exit_tree() -> void:
	_discard_echo()

func _remember_registered_gesture(button: Button, note: Label, key: String) -> void:
	# A phase may close synchronously in response to the intent. Preserve a short
	# passive imprint across that transition; never delay or replay the intent.
	_discard_echo()
	registered_at = Time.get_ticks_msec()
	var echo := Button.new()
	echo.disabled = true
	echo.focus_mode = Control.FOCUS_NONE
	echo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	echo.position = button.get_global_rect().position
	echo.size = button.size
	echo.z_index = 100
	echo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		echo.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var skin := ObjectSkin.new()
	skin.kind = key
	skin.registered = true
	skin.dense = ui.get("push_luck_condanna_button").visible
	skin.factor = factor
	echo.add_child(skin)
	echo.add_child(button.get_node("PrintedTitle").duplicate(0))
	echo.add_child(note.get_parent().duplicate(0))
	registered_echo = echo

func _finish_registered_gesture() -> void:
	if not is_instance_valid(registered_echo):
		return
	if Time.get_ticks_msec() - registered_at > 500 or ui.call("_is_reduced_motion"):
		_discard_echo()
		return
	var echo := registered_echo
	registered_echo = null
	ui.add_child(echo)
	echo.add_to_group("living_verdict_echo")
	var fade := echo.create_tween()
	fade.tween_interval(0.10)
	fade.tween_property(echo, "modulate:a", 0.0, 0.18)
	fade.tween_callback(echo.queue_free)

func _place(node: Control, rect: Rect2) -> void:
	node.set_anchors_preset(Control.PRESET_TOP_LEFT)
	node.custom_minimum_size = Vector2.ZERO
	node.position = rect.position * factor
	node.size = rect.size * factor

func _layout() -> void:
	if ui == null or caption == null or ui.get("push_luck_title") == null:
		return
	factor = minf(size.x / 1280.0, size.y / 720.0)
	var w := size.x / factor
	var h := size.y / factor
	_place(get_node(ROOT_PATH), Rect2(0, 0, w, h))
	_place(atmosphere, Rect2(0, 0, w, h))
	for label in [caption, context, bando, purse, voice, voice_name, chain, pressure_label]:
		label.add_theme_font_size_override("font_size", roundi(float(label.get_meta("base_size")) * factor))
	_place(context, Rect2(36, 18, 175, 30))
	_place(bando, Rect2(230, 18, w - 700, 52))
	_place(purse, Rect2(w - 440, 18, 292, 36))
	_place(scars, Rect2(w - 130, 12, 110, 42))
	scars.add_theme_font_size_override("font_size", roundi(16 * factor))
	scars.add_theme_font_override("font", TYPE)
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_TITLEPanel"), Rect2(72, 92, 590, 50))
	Kit.apply_label(ui.get("push_luck_title"), &"title")
	ui.get("push_luck_title").add_theme_font_override("font", TYPE)
	ui.get("push_luck_title").add_theme_font_size_override("font_size", roundi(32 * factor))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_SUBTITLEPanel"), Rect2(70, 143, 255, 145))
	var stake: Label = ui.get("push_luck_details")
	var font_size := 142
	while font_size > 48 and TYPE.get_string_size(str(target_amount), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > 250:
		font_size -= 2
	stake.add_theme_font_override("font", TYPE)
	stake.add_theme_font_size_override("font_size", roundi(font_size * factor))
	_place(caption, Rect2(78, 284, 220, 32))
	_place(chain, Rect2(340, 225, 230, 46))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_BODYPanel"), Rect2(78, 322, 300, 30))
	Kit.apply_label(ui.get("push_luck_info"), &"body")
	ui.get("push_luck_info").add_theme_font_override("font", TYPE)
	ui.get("push_luck_info").add_theme_font_size_override("font_size", roundi(16 * factor))
	_place(pressure_label, Rect2(78, 365, 160, 36))
	_place(portrait, Rect2(w - 530, 108, 140, 210))
	_place(voice_name, Rect2(w - 365, 112, 290, 28))
	_place(voice, Rect2(w - 365, 154, 290, 142))
	if active:
		_place(ui.get("scar_popup_panel"), Rect2(520, 310, w - 600, 100))
	_place(get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_FOOTERPanel"), Rect2(78, h - 36, w - 156, 30))
	ui.get("push_luck_audience_reason").add_theme_font_size_override("font_size", roundi(15 * factor))
	ui.get("push_luck_audience_reason").add_theme_font_override("font", TYPE)
	get_node(ROOT_PATH + "Lbl_PUSH_YOUR_LUCK_HINTPanel").hide()
	_place(choices, Rect2(65, h - 286, w - 130, 238))
	choices.add_theme_constant_override("separation", roundi(24 * factor))
	_layout_cards()

func _layout_cards() -> void:
	if ui == null or ui.get("push_luck_condanna_button") == null:
		return
	var dense: bool = ui.get("push_luck_condanna_button").visible
	for key: String in ["cashout", "condanna", "double"]:
		var button: Button = ui.get("push_luck_" + key + "_button")
		var note: Label = ui.get("push_luck_" + key + "_note")
		if button == null or note == null:
			continue
		var column: Control = button.get_parent()
		_place(button, Rect2(Vector2.ZERO, column.size / factor))
		var title: Label = button.get_node_or_null("PrintedTitle")
		if title == null:
			continue
		var width := column.size.x / factor
		var seal := key == "double"
		var left := 102.0 if key == "cashout" else 28.0
		var title_rect := Rect2(left, 52, width - left - 32, 73)
		var note_rect := Rect2(left, 126, width - left - 30, 91)
		if seal and not dense:
			title_rect = Rect2(25, 85, 220, 65)
			note_rect = Rect2(266, 91, width - 282, 120)
		elif seal:
			title_rect = Rect2(45, 50, width - 90, 55)
			note_rect = Rect2(32, 145, width - 64, 86)
		_place(title, title_rect)
		title.text = tr("Prendi la quietanza") if key == "cashout" else tr("Raddoppia") if seal else tr("Ricevi il marchio")
		title.add_theme_font_override("font", TYPE)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if seal else HORIZONTAL_ALIGNMENT_LEFT
		title.add_theme_font_size_override("font_size", roundi((24 if dense else 30) * factor))
		_place(note.get_parent(), note_rect)
		for side in ["left", "right", "top", "bottom"]:
			note.get_parent().add_theme_constant_override("margin_" + side, 0)
		note.add_theme_font_size_override("font_size", roundi((15 if dense else 17) * factor))
		var skin: Control = button.get_node_or_null("VerdictObject")
		if skin:
			skin.set("dense", dense)
			skin.set("factor", factor)
			skin.queue_redraw()
