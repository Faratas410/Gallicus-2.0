extends Control
## Live component catalogue. Uses the runtime kit; no game flow or save writes.

const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const Palette = preload("res://scripts/ui/manifesto_palette.gd")
var choices: Array[Button] = []
var routes: Array[Button] = []
var states: Array[Button] = []
var activations: int = 0
var status: Label
var language: OptionButton
var main_catalogue: VBoxContainer
var registry_catalogue: VBoxContainer
var registry_buttons: Array[Button] = []
var registry_texts: Array[RichTextLabel] = []
var section: OptionButton
var crowd_catalogue: VBoxContainer
var crowd_buttons: Array[Button] = []
var response_state: OptionButton
var judgment_catalogue: VBoxContainer
var judgment_panel: Control
var judgment_seal: Button
var judgment_advance: Button
var judgment_pips: Array[Panel] = []
var judgment_preview_source: Node
var judgment_state: OptionButton

func _ready() -> void:
	# The game loads these in MainMenu; the standalone catalogue has no menu.
	for locale: String in ["it", "en", "es"]:
		TranslationServer.add_translation(load("res://assets/i18n/%s.%s.translation" % [locale, locale]) as Translation)
	TranslationServer.set_locale("it")
	theme = preload("res://assets/ui/theme/official_theme.tres")
	var background := ColorRect.new()
	background.color = Palette.INK
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, Kit.SPACE * 4)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", Kit.SPACE * 2)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := _label("MANIFESTO / UI KIT", &"caption")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	language = OptionButton.new()
	for locale: String in ["IT", "EN", "ES"]:
		language.add_item(locale)
	language.item_selected.connect(func(index: int) -> void: TranslationServer.set_locale(["it", "en", "es"][index]))
	header.add_child(language)
	section = OptionButton.new()
	section.add_item("POSTA / FASCICOLO")
	section.add_item("REGISTRO / BANCO / FIRMA")
	section.add_item("PATTO / GRADINATA")
	section.add_item("GIUDIZIO / SIGILLO")
	section.item_selected.connect(show_section)
	header.add_child(section)
	var root_column: VBoxContainer = column
	main_catalogue = VBoxContainer.new()
	main_catalogue.add_theme_constant_override("separation", Kit.SPACE * 2)
	root_column.add_child(main_catalogue)
	column = main_catalogue
	column.add_child(_label("01 / POSTA - carta, marchio, seconda incisione", &"title"))
	var choice_row := _row(column)
	var titles: Array[String] = ["INCASSA E VAI", "CONDANNA", "RADDOPPIA"]
	var notes: Array[String] = ["La folla ti marca: incasso bloccato.", "Disponibile dopo l'arena in corso.", "Disponibile dopo l'arena in corso."]
	for index: int in range(3):
		var button := Kit.create_choice(titles[index], notes[index], [&"paper", &"ink", &"wax"][index])
		Kit.apply_action(button, [&"paper", &"ink", &"wax"][index], false, false, Kit.TITLE_SMALL)
		choice_row.add_child(button)
		button.pressed.connect(_record_activation)
		choices.append(button)
	column.add_child(_label("02 / FASCICOLO - stessa stampa, comandi compatti", &"title"))
	var page := PanelContainer.new()
	var paper := StyleBoxFlat.new()
	paper.bg_color = Palette.IVORY
	for side: String in ["left", "top", "right", "bottom"]:
		paper.set("content_margin_" + side, 16.0)
	page.add_theme_stylebox_override("panel", paper)
	column.add_child(page)
	var page_row := _row(page)
	for index: int in range(3):
		var button := _compact(["PROSSIMA SCOMMESSA", "NUOVO PERCORSO", "TORNA AL MENU"][index], &"ink" if index == 0 else &"paper")
		page_row.add_child(button)
		routes.append(button)
	column.add_child(_label("03 / STATI - Tab, mouse e Invio sui controlli nativi", &"title"))
	var state_row := _row(column)
	for index: int in range(4):
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		state_row.add_child(cell)
		cell.add_child(_label(["NORMAL / HOVER", "FOCUS / PRESSED", "DISABLED", "REGISTERED"][index]))
		var button := _compact("CONTINUA", &"wax")
		cell.add_child(button)
		button.disabled = index >= 2
		Kit.apply_action(button, &"wax", true, index == 3)
		states.append(button)
	status = _label("Campionario interattivo: le azioni incrementano soltanto un contatore locale.")
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	registry_catalogue = VBoxContainer.new()
	registry_catalogue.add_theme_constant_override("separation", 12)
	root_column.add_child(registry_catalogue)
	_build_registry_catalogue()
	registry_catalogue.hide()
	crowd_catalogue = VBoxContainer.new()
	crowd_catalogue.add_theme_constant_override("separation", Kit.SPACE * 2)
	root_column.add_child(crowd_catalogue)
	_build_crowd_catalogue()
	crowd_catalogue.hide()
	judgment_catalogue = VBoxContainer.new()
	judgment_catalogue.add_theme_constant_override("separation", Kit.SPACE * 2)
	root_column.add_child(judgment_catalogue)
	_build_judgment_catalogue()
	judgment_catalogue.hide()
	root_column.add_child(status)
	states[1].grab_focus()

func show_registry(enabled: bool) -> void:
	show_section(1 if enabled else 0)

func show_section(index: int) -> void:
	section.select(index)
	main_catalogue.visible = index == 0
	registry_catalogue.visible = index == 1
	crowd_catalogue.visible = index == 2
	judgment_catalogue.visible = index == 3
	if index == 1:
		registry_buttons[1].grab_focus()
	elif index == 2:
		crowd_buttons[0].grab_focus()
	elif index == 3:
		judgment_seal.grab_focus()

func _build_judgment_catalogue() -> void:
	judgment_catalogue.add_child(_label("09 / GIUDIZIO - verbale e cera nativa", &"title"))
	# Never add this source to the tree: no runtime binding, bus or save flow.
	# Copy the actual panel and use its existing socket presentation helpers.
	judgment_preview_source = load("res://scenes/UI.tscn").instantiate()
	judgment_panel = judgment_preview_source.get_node("UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION").duplicate() as Control
	var center := CenterContainer.new()
	judgment_catalogue.add_child(center)
	center.add_child(judgment_panel)
	judgment_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	judgment_panel.custom_minimum_size = Vector2(820, 400)
	Kit.apply_judgment(judgment_panel)
	var box: Control = judgment_panel.get_node("Box_RESOLUTION")
	judgment_seal = box.get_node("Btn_RESOLUTION_STRIKE")
	judgment_advance = box.get_node("Btn_RESOLUTION_NEXT")
	judgment_advance.text = "ALZA LA MANO"
	judgment_seal.pressed.connect(_record_activation)
	judgment_advance.pressed.connect(_record_activation)
	judgment_pips.assign(judgment_preview_source.call("_build_judgment_seal_pips", judgment_seal))
	judgment_state = OptionButton.new()
	for label: String in ["NORMALE", "COLPO 1", "COLPO 2", "PIENO", "INCRINATO / SEGNO", "BLOCCATO"]:
		judgment_state.add_item(label)
	judgment_state.item_selected.connect(set_judgment_state)
	judgment_catalogue.add_child(judgment_state)
	set_judgment_state(0)

func set_judgment_state(index: int) -> void:
	judgment_state.select(index)
	var native_state: String = ["normal", "strike_1", "strike_2", "resolved", "strike_1", "disabled"][index]
	var path: String = "res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_%s.tres"
	for role: String in ["normal", "hover", "focus", "pressed", "disabled"]:
		var texture_state: String = native_state
		if index == 0:
			texture_state = "focus" if role == "hover" else role
		judgment_seal.add_theme_stylebox_override(role, load(path % texture_state))
	judgment_seal.disabled = index == 3 or index == 5
	judgment_seal.text = "LASCIA CEDERE" if index == 4 else "SIGILLATO" if index == 3 else "COLPISCI ANCORA" if index in [1, 2] else "COLPISCI"
	judgment_advance.visible = index in [1, 2, 4, 5]
	judgment_advance.disabled = index == 5
	judgment_advance.text = "MOSTRA UN SEGNO" if index == 4 else "ALZA LA MANO"
	for offset: int in range(3):
		judgment_pips[offset].hide()
		if offset < (1 if index == 4 else mini(index, 3)) and index != 5:
			judgment_preview_source.call("_fill_judgment_seal_pip", judgment_pips[offset], false, index != 4)
	var body: Label = judgment_panel.get_node("Box_RESOLUTION/Lbl_RESOLUTION_BODYPanel/Lbl_RESOLUTION_BODY")
	body.text = "Il Registro pesa il patto.\nOgni colpo mette alla prova la cera." if index != 4 else "La cera si incrina.\nMostra un Segno alla gradinata: il sigillo regge, ma il corpo paga con Ossa incrinate (se ci sono già: Pressione +1). Una volta per percorso."
	var prompt: Label = judgment_panel.get_node("Box_RESOLUTION/Lbl_RESOLUTION_RITUAL_PROMPTPanel/Lbl_RESOLUTION_RITUAL_PROMPT")
	prompt.text = "LA CERA SI INCRINA - MOSTRA UN SEGNO O LASCIA CEDERE" if index == 4 else "SIGILLO PIENO - IL REGISTRO PUÒ AVANZARE" if index == 3 else "IL SIGILLO REGGE - COLPISCI ANCORA O ALZA LA MANO" if index in [1, 2] else "IMPRIMI IL SIGILLO"
	status.text = "Input ricevuti: %d" % activations

func _exit_tree() -> void:
	if is_instance_valid(judgment_preview_source):
		judgment_preview_source.free()

func _build_crowd_catalogue() -> void:
	crowd_catalogue.add_child(_label("07 / PATTO - tavoletta, impronta e blocco", &"title"))
	var pact_row := _row(crowd_catalogue)
	for index: int in range(3):
		var page := PanelContainer.new()
		page.custom_minimum_size = Vector2(300, 132)
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pact_row.add_child(page)
		Kit.apply_document(page)
		var inset := MarginContainer.new()
		for side: String in ["left", "top", "right", "bottom"]:
			inset.add_theme_constant_override("margin_" + side, 16)
		page.add_child(inset)
		var column := VBoxContainer.new()
		inset.add_child(column)
		var title := _label(["PATTO SIGILLATO", "VALIDATED", "DISABLED"][index], &"title")
		Kit.apply_label(title, &"title", Palette.INK)
		column.add_child(title)
		var button := _compact("MOSTRA IL PATTO", &"ink")
		Kit.apply_action(button, &"ink", true, index == 1)
		button.disabled = index > 0
		column.add_child(button)
		crowd_buttons.append(button)
	crowd_catalogue.add_child(_label("08 / GRADINATA - risposta e prezzo allineati", &"title"))
	var response_row := _row(crowd_catalogue)
	for index: int in range(2):
		var button := Button.new()
		button.custom_minimum_size = Vector2(350, 180)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = "%s\n%s\n%s" % [tr("ABBASSA LO SGUARDO" if index == 0 else "SFIDA LA GRADINATA"), tr("Favore -1." if index == 0 else "Favore +1, Pressione +1."), tr("Il Registro annota misura." if index == 0 else "Il Registro annota esposizione.")]
		Kit.apply_response(button, &"paper" if index == 0 else &"wax")
		response_row.add_child(button)
		button.pressed.connect(_record_activation)
		crowd_buttons.append(button)
	var state := OptionButton.new()
	response_state = state
	for value: String in ["NORMAL / HOVER / FOCUS / PRESSED", "SELECTED: MISURA", "SELECTED: SFIDA", "DISABLED"]:
		state.add_item(value)
	state.item_selected.connect(set_response_state)
	crowd_catalogue.add_child(state)

func set_response_state(index: int) -> void:
	response_state.select(index)
	for offset: int in range(2):
		var button: Button = crowd_buttons[3 + offset]
		Kit.apply_response(button, &"paper" if offset == 0 else &"wax", index == offset + 1)
		button.disabled = index > 0

func _build_registry_catalogue() -> void:
	registry_catalogue.add_child(_label("04 / REGISTRO - leggere non significa firmare", &"title"))
	var pages := _row(registry_catalogue)
	for selected: bool in [true, false]:
		var page := PanelContainer.new()
		page.custom_minimum_size = Vector2(300, 216)
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pages.add_child(page)
		Kit.apply_document(page, &"paper", selected)
		var inset := MarginContainer.new()
		for side: String in ["left", "top", "right", "bottom"]:
			inset.add_theme_constant_override("margin_" + side, 16)
		page.add_child(inset)
		var column := VBoxContainer.new()
		inset.add_child(column)
		var text := RichTextLabel.new()
		text.bbcode_enabled = true
		text.scroll_active = false
		text.custom_minimum_size.y = 112
		text.text = "[center]%s[/center]\n%s\n%s\n%s" % [Kit.format_heading(tr("SCEGLI LA VIA"), Kit.CONTRACT_TITLE_SIZE), tr("Leggi la promessa e il costo. Poi firma."), Kit.format_heading(tr("SE IL PATTO REGGE"), Kit.CONTRACT_HEADING_SIZE), tr("Ogni patto lascia un segno.")]
		Kit.apply_rich_text(text)
		column.add_child(text)
		registry_texts.append(text)
		var signature := _compact("FIRMA", &"wax")
		Kit.apply_action(signature, &"wax", true, false, Kit.ACTION_COMPACT, selected)
		column.add_child(signature)
		registry_buttons.append(signature)
	registry_catalogue.add_child(_label("05 / FIRMA - selezionata, impressa e bloccata", &"title"))
	var states_row := _row(registry_catalogue)
	for index: int in range(4):
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		states_row.add_child(cell)
		cell.add_child(_label(["NORMAL / HOVER", "SELECTED / FOCUS", "SIGNED", "DISABLED"][index]))
		var signature := _compact("FIRMA", &"wax")
		Kit.apply_action(signature, &"wax", true, index == 2, Kit.ACTION_COMPACT, index == 1)
		signature.disabled = index >= 2
		cell.add_child(signature)
		registry_buttons.append(signature)
	registry_catalogue.add_child(_label("06 / BANCO - servizio, effetto, prezzo", &"title"))
	var services := _row(registry_catalogue)
	for available: bool in [true, false]:
		var service := _compact("COMPRA IL FAVORE", &"paper")
		service.text = "%s\n%s\n%s" % [tr("COMPRA IL FAVORE"), tr("Favore +2."), tr("%d Denari") % 3]
		service.custom_minimum_size.y = 88
		service.disabled = not available
		Kit.apply_action(service, &"paper", true, false, Kit.ACTION_COMPACT, false, true)
		services.add_child(service)
		registry_buttons.append(service)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and language != null:
		language.select(maxi(["it", "en", "es"].find(TranslationServer.get_locale()), 0))
		for offset: int in range(maxi(crowd_buttons.size() - 3, 0)):
			var button: Button = crowd_buttons[3 + offset]
			button.text = "%s\n%s\n%s" % [tr("ABBASSA LO SGUARDO" if offset == 0 else "SFIDA LA GRADINATA"), tr("Favore -1." if offset == 0 else "Favore +1, Pressione +1."), tr("Il Registro annota misura." if offset == 0 else "Il Registro annota esposizione.")]
			Kit.apply_response(button, &"paper" if offset == 0 else &"wax", button.get_node("ManifestoSurface").get("selected"))

func _label(value: String, role: StringName = &"body") -> Label:
	var label := Label.new()
	label.text = value
	Kit.apply_label(label, role)
	return label

func _row(parent: Node) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", Kit.SPACE * 2)
	parent.add_child(row)
	return row

func _compact(value: String, material: StringName) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(200, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Kit.apply_action(button, material, true)
	button.pressed.connect(_record_activation)
	return button

func _record_activation() -> void:
	activations += 1
	status.text = "Input ricevuti: %d" % activations
