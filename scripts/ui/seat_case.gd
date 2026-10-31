extends Control

# Presentation only: RunManager validates choices and SaveManager commits them.
const Paper = preload("res://scripts/ui/banco_paper.gd")
const Writing = preload("res://scripts/ui/registry_handwriting.gd")
const FinalEra = preload("res://scripts/content/final_era.gd")
var port: RunManagerUiPort
var title: Label
var evidence: Label
var reserve: Button
var witness: Button
var defer_button: Button
var continue_button: Button
var active := false
var stage: Control
var mode := ""
var inquiry: Dictionary = {}

func _ready() -> void:
	name = "SeatCase"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	port = RunManagerUiPort.new(get_tree())
	var shade := ColorRect.new()
	shade.color = Color(0.04, 0.03, 0.02, 0.85)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage = Control.new()
	add_child(stage)
	stage.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	stage.offset_left = -520
	stage.offset_right = 520
	stage.offset_top = -300
	stage.offset_bottom = 300
	stage.pivot_offset = Vector2(520, 300)
	resized.connect(_layout_stage)
	call_deferred("_layout_stage")
	var paper := Paper.new()
	stage.add_child(paper)
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title = _label(stage, Rect2(70, 44, 900, 48), 30)
	evidence = _label(stage, Rect2(80, 105, 880, 210), 23)
	reserve = _button(stage, "Btn_Seat_Reserve", Rect2(80, 310, 880, 80), "reserve")
	witness = _button(stage, "Btn_Seat_Witness", Rect2(80, 400, 880, 80), "witness")
	defer_button = _button(stage, "Btn_Seat_Defer", Rect2(80, 490, 420, 64), "defer")
	continue_button = _button(stage, "Btn_Seat_Continue", Rect2(540, 490, 420, 64), "continue")
	reserve.focus_next = witness.get_path()
	reserve.focus_previous = defer_button.get_path()
	witness.focus_next = defer_button.get_path()
	witness.focus_previous = reserve.get_path()
	defer_button.focus_next = reserve.get_path()
	defer_button.focus_previous = witness.get_path()
	for button: Button in [reserve, witness, defer_button, continue_button]:
		button.focus_neighbor_left = button.get_path()
		button.focus_neighbor_right = button.get_path()
	continue_button.focus_next = continue_button.get_path()
	continue_button.focus_previous = continue_button.get_path()
	continue_button.focus_neighbor_top = continue_button.get_path()
	continue_button.focus_neighbor_bottom = continue_button.get_path()
	GameEvents.seat_case_resolved.connect(_on_resolved)
	GameEvents.seat_inquiry_changed.connect(_on_inquiry_changed)
	GameEvents.seat_copy_resolved.connect(_on_copy_resolved)
	GameEvents.final_ledger_resolved.connect(_on_final_resolved)
	GameEvents.final_copy_resolved.connect(_on_final_resolved)
	GameEvents.run_ended.connect(_on_run_ended)
	GameEvents.request_show_main_menu.connect(_close)
	hide()

func _layout_stage() -> void:
	if stage == null or not is_inside_tree():
		return
	var viewport := get_viewport_rect().size
	var factor := minf(viewport.x / 1280.0, viewport.y / 720.0)
	stage.scale = Vector2.ONE * factor

func _label(parent: Control, rect: Rect2, font_size: int) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", Writing.FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Writing.INK)
	parent.add_child(label)
	return label

func _button(parent: Control, node_name: String, rect: Rect2, choice: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.position = rect.position
	button.size = rect.size
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(button)
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Writing.INK
	focus.border_width_bottom = 3
	button.add_theme_stylebox_override("focus", focus)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Writing.INK)
	button.add_theme_color_override("font_disabled_color", Color("958777"))
	button.add_theme_font_override("font", Writing.FONT)
	button.add_theme_font_size_override("font_size", 19)
	var receipt := Paper.new()
	receipt.show_behind_parent = true
	button.add_child(receipt)
	receipt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_choose.bind(choice))
	return button

func try_open() -> bool:
	# The last Era's sheets come first: they follow their own scene and have no deferral.
	var ledger_view := port.get_final_ledger()
	var final_copy_view := port.get_final_copy() if ledger_view.is_empty() else {}
	if not ledger_view.is_empty() or not final_copy_view.is_empty():
		active = true
		mode = "ledger" if not ledger_view.is_empty() else "final_copy"
		show()
		if mode == "ledger":
			_render_final_ledger(ledger_view)
		else:
			_render_final_copy(final_copy_view)
		call_deferred("_restore_focus_if_needed")
		return true
	_set_wide_third(false)
	for button: Button in [reserve, witness, defer_button]:
		button.disabled = false
	var view := port.get_seat_case()
	if view.is_empty():
		inquiry = port.get_seat_inquiry()
		if inquiry.is_empty():
			var copy_view := port.get_seat_copy()
			if copy_view.is_empty():
				return false
			active = true
			mode = "copy"
			show()
			_render_copy(copy_view)
			witness.grab_focus()
			call_deferred("_restore_focus_if_needed")
			return true
		active = true
		mode = "inquiry"
		show()
		_render_inquiry()
		reserve.grab_focus()
		call_deferred("_restore_focus_if_needed")
		return true
	active = true
	mode = "case"
	show()
	title.text = tr("IL POSTO MISURATO")
	evidence.text = "%s\n\n%s" % [tr("Vessa misura la fila per venderla. Dima indica il posto vuoto; Nerio mostra una copia che si ferma prima di quel posto. Come lo difendi?"), tr("Conto %d Denari") % int(view.get("denari", 0))]
	reserve.text = tr("RISERVA IL POSTO · 6 Denari\nVessa ferma la vendita. Il conto diminuisce subito.")
	witness.text = tr("PRESENTA LA TESTIMONIANZA · gratis\nNei prossimi percorsi la Pressione iniziale aumenta di 1, fino al prossimo Silenzio.")
	defer_button.text = tr("RIMANDA AL PROSSIMO PERCORSO")
	continue_button.text = tr("TORNA AL RITO")
	reserve.disabled = not bool(view.get("reserve_available", false))
	reserve.focus_neighbor_top = defer_button.get_path()
	reserve.focus_neighbor_bottom = witness.get_path()
	witness.focus_neighbor_top = defer_button.get_path() if reserve.disabled else reserve.get_path()
	witness.focus_neighbor_bottom = defer_button.get_path()
	defer_button.focus_neighbor_top = witness.get_path()
	defer_button.focus_neighbor_bottom = witness.get_path() if reserve.disabled else reserve.get_path()
	witness.focus_previous = defer_button.get_path() if reserve.disabled else reserve.get_path()
	defer_button.focus_next = witness.get_path() if reserve.disabled else reserve.get_path()
	reserve.show()
	witness.show()
	defer_button.show()
	continue_button.hide()
	witness.grab_focus()
	call_deferred("_restore_focus_if_needed")
	return true

func _restore_focus_if_needed() -> void:
	if not active or not is_visible_in_tree():
		return
	var current := get_viewport().gui_get_focus_owner()
	if current != null and is_ancestor_of(current):
		return
	if mode == "inquiry" or mode == "question":
		reserve.grab_focus()
	elif mode in ["case", "copy"]:
		witness.grab_focus()
	elif mode in ["ledger", "final_copy"]:
		_first_enabled([witness, reserve, defer_button]).grab_focus()
	elif mode in ["case_result", "inquiry_result", "copy_result", "final_result"]:
		continue_button.grab_focus()

func _choose(choice: String) -> void:
	if not active:
		return
	if mode == "ledger":
		var in_debt := not defer_button.visible
		var ledger_choice := ("voice" if in_debt else "lauro") if choice == "reserve" else ("debt" if in_debt else "crowd") if choice == "witness" else "vessa" if choice == "defer" and not in_debt else ""
		if ledger_choice != "":
			GameEvents.request_final_ledger_choice.emit(ledger_choice)
		return
	if mode == "final_copy":
		var copy_choice := "seat" if choice == "reserve" else "gesta" if choice == "witness" else "scars" if choice == "defer" else ""
		if copy_choice != "":
			GameEvents.request_final_copy_choice.emit(copy_choice)
		return
	if mode == "inquiry":
		if choice == "continue" and int(inquiry.get("seen", 0)) == 3:
			mode = "question"
			_render_question(false)
			return
		var action: String = "inspect_copy" if choice == "reserve" else "inspect_trace" if choice == "witness" else "defer" if choice == "defer" else ""
		if action != "":
			GameEvents.request_seat_inquiry_action.emit(action)
		return
	if mode == "question":
		if choice == "continue":
			mode = "inquiry"
			_render_inquiry()
			reserve.grab_focus()
			return
		var action: String = "conclude_copy" if choice == "reserve" else "infer_identity" if choice == "witness" else "defer" if choice == "defer" else ""
		if action != "":
			GameEvents.request_seat_inquiry_action.emit(action)
		return
	if mode == "copy":
		var copy_choice := "copy" if choice == "reserve" else "keep" if choice == "witness" else "defer" if choice == "defer" else ""
		if copy_choice != "":
			GameEvents.request_seat_copy_choice.emit(copy_choice)
		return
	if choice == "continue":
		_close(mode in ["case_result", "inquiry_result", "copy_result"])
		return
	GameEvents.request_seat_case_choice.emit(choice)

func _set_wide_third(wide: bool) -> void:
	# The last Era's sheets offer a third full choice where the others defer.
	defer_button.size = Vector2(880, 80) if wide else Vector2(420, 64)

func _first_enabled(buttons: Array[Button]) -> Button:
	for button: Button in buttons:
		if button.visible and not button.disabled:
			return button
	return buttons[0]

func _chain_focus(buttons: Array[Button]) -> void:
	var ring: Array[Button] = []
	for button: Button in buttons:
		if button.visible and not button.disabled:
			ring.append(button)
	for index: int in range(ring.size()):
		var next_path := ring[(index + 1) % ring.size()].get_path()
		var previous_path := ring[(index - 1 + ring.size()) % ring.size()].get_path()
		ring[index].focus_next = next_path
		ring[index].focus_neighbor_bottom = next_path
		ring[index].focus_previous = previous_path
		ring[index].focus_neighbor_top = previous_path

func _render_final_ledger(view: Dictionary) -> void:
	var in_debt := bool(view.get("in_debt", false))
	var denari := int(view.get("denari", 0))
	title.text = tr("L'ULTIMA CIFRA")
	evidence.text = "%s\n\n%s" % [tr("Vessa chiude il banco. Da questo percorso il conto non cambia più: niente acquisti, niente quietanze in Denari. Dove va l'ultima cifra?"), tr("Conto %d Denari") % denari]
	_set_wide_third(true)
	if in_debt:
		reserve.text = tr("PAGA CON LA VOCE\nIl debito si chiude. Il prossimo percorso parte con Pressione +2.")
		witness.text = tr("LASCIA IL DEBITO SCRITTO\nIl Registro conserva il debito. Pressione +1 a ogni percorso, fino alla fine.")
	else:
		reserve.text = tr("ALLA STROFA DI LAURO · tutto il conto\nLauro mette per iscritto la gesta più alta. L'Archivio la conserva.")
		witness.text = tr("ALLA GRADINATA · tutto il conto\nFavore +2 all'inizio di ogni percorso, fino alla fine.")
		defer_button.text = tr("A VESSA · nessuna spesa\nVessa tiene il conto chiuso. Nessun effetto sul rito.")
	reserve.disabled = not in_debt and denari <= 0
	witness.disabled = not in_debt and denari <= 0
	defer_button.disabled = false
	reserve.show()
	witness.show()
	defer_button.visible = not in_debt
	continue_button.hide()
	_chain_focus([reserve, witness, defer_button])
	_first_enabled([witness, reserve, defer_button]).grab_focus()

func _render_final_copy(view: Dictionary) -> void:
	var options: Array = view.get("options", []) as Array
	title.text = tr("L'ULTIMO FOGLIO")
	evidence.text = tr("Nerio può copiare una sola memoria. Quello che non copia resta a chi lo ricorda.")
	_set_wide_third(true)
	reserve.text = tr("IL POSTO\nNerio lo copia nell'ultimo foglio.")
	witness.text = tr("LA GESTA PIÙ ALTA\nNerio la copia nell'ultimo foglio.")
	defer_button.text = tr("I SEGNI\nNerio li copia nell'ultimo foglio.")
	for button: Button in [reserve, witness, defer_button]:
		button.disabled = false
	reserve.visible = options.has("seat")
	witness.visible = options.has("gesta")
	defer_button.visible = options.has("scars")
	continue_button.hide()
	_chain_focus([reserve, witness, defer_button])
	witness.grab_focus()

func _on_final_resolved(payload: Dictionary) -> void:
	if not active or mode not in ["ledger", "final_copy"]:
		return
	var choice := str(payload.get("choice", ""))
	var lines: Array[String] = [tr(str(FinalEra.RESULTS.get(choice, "")))]
	if mode == "final_copy":
		for option: String in FinalEra.KEEPERS:
			if option != choice and (option == "gesta" or (option == "seat" and reserve.visible) or (option == "scars" and defer_button.visible)):
				lines.append(tr(str(FinalEra.KEEPERS[option])))
	mode = "final_result"
	reserve.hide()
	witness.hide()
	defer_button.hide()
	_set_wide_third(false)
	evidence.text = "\n\n".join(lines)
	continue_button.text = tr("TORNA AL RITO")
	continue_button.show()
	continue_button.focus_next = continue_button.get_path()
	continue_button.focus_previous = continue_button.get_path()
	continue_button.focus_neighbor_top = continue_button.get_path()
	continue_button.focus_neighbor_bottom = continue_button.get_path()
	continue_button.grab_focus()

func _render_copy(view: Dictionary) -> void:
	title.text = tr("DOVE RESTA IL MARGINE?")
	evidence.text = "%s\n\n%s\n\n%s" % [tr("Dima tiene l'annotazione. Vessa riconosce la copia di Nerio come prova per la polizza."), tr("Il prossimo Silenzio non ha una data fissata."), tr("Conto %d Denari") % int(view.get("denari", 0))]
	reserve.text = tr("TRASCRIVI PER NERIO · 5 Denari\nNerio riceve la copia. Polizza -1 Denaro fino al prossimo Silenzio.")
	witness.text = tr("LASCIA A DIMA · gratis\nDima conserva l'annotazione; Nerio non ne riceve una copia.")
	defer_button.text = tr("RIMANDA AL PROSSIMO PERCORSO")
	reserve.disabled = not bool(view.get("copy_available", false))
	reserve.show()
	witness.show()
	defer_button.show()
	continue_button.hide()
	reserve.focus_next = witness.get_path()
	reserve.focus_previous = defer_button.get_path()
	reserve.focus_neighbor_top = defer_button.get_path()
	reserve.focus_neighbor_bottom = witness.get_path()
	witness.focus_next = defer_button.get_path()
	witness.focus_previous = defer_button.get_path() if reserve.disabled else reserve.get_path()
	witness.focus_neighbor_top = defer_button.get_path() if reserve.disabled else reserve.get_path()
	witness.focus_neighbor_bottom = defer_button.get_path()
	defer_button.focus_next = witness.get_path() if reserve.disabled else reserve.get_path()
	defer_button.focus_previous = witness.get_path()
	defer_button.focus_neighbor_top = witness.get_path()
	defer_button.focus_neighbor_bottom = witness.get_path() if reserve.disabled else reserve.get_path()

func _on_copy_resolved(payload: Dictionary) -> void:
	if not active or mode != "copy":
		return
	var choice := str(payload.get("choice", ""))
	if choice == "defer":
		_close()
		return
	mode = "copy_result"
	reserve.hide()
	witness.hide()
	defer_button.hide()
	continue_button.show()
	continue_button.text = tr("ASCOLTA LA RISPOSTA")
	continue_button.focus_next = continue_button.get_path()
	continue_button.focus_previous = continue_button.get_path()
	continue_button.focus_neighbor_top = continue_button.get_path()
	continue_button.focus_neighbor_bottom = continue_button.get_path()
	evidence.text = tr("Dima tiene l'annotazione. Nerio ne riceve una copia nel suo fascicolo.") if choice == "copy" else tr("Dima tiene l'annotazione. Il fascicolo di Nerio resta senza quella copia.")
	if choice == "copy":
		evidence.text += "\n\n" + tr("Vessa sconta la polizza di 1 Denaro fino al prossimo Silenzio.")
	continue_button.grab_focus()

func _on_resolved(payload: Dictionary) -> void:
	if not active or mode != "case":
		return
	var choice := str(payload.get("choice", ""))
	if choice == "defer":
		_close()
		return
	reserve.hide()
	witness.hide()
	defer_button.hide()
	continue_button.show()
	mode = "case_result"
	evidence.text = tr("Vessa ritira il righello. Dima tiene il posto; Nerio lascia bianco il margine della copia.") if choice == "reserve" else tr("Dima indica il posto davanti alla gradinata. Nerio lascia bianco il margine; la folla ricorda chi ha parlato.")
	continue_button.grab_focus()

func _render_inquiry() -> void:
	title.text = tr("LE TRACCE DEL POSTO")
	var seen: int = int(inquiry.get("seen", 0))
	var copy: String = tr("Copia: Nerio ha ricevuto solo la parte che termina prima del posto.") if (seen & 1) != 0 else tr("La copia di Nerio aspetta di essere letta.")
	var trace: String = tr("Ricevuta: c'è un foro sul margine, ma il foglio sotto manca.") if str(inquiry.get("choice", "")) == "reserve" else tr("Voce: dalla prima fila qualcuno ricorda un foglio più lungo.")
	if (seen & 2) == 0:
		trace = tr("La seconda traccia aspetta di essere esaminata.")
	evidence.text = "%s\n\n%s" % [copy, trace]
	reserve.text = tr("LEGGI LA COPIA DI NERIO")
	witness.text = tr("ESAMINA LA RICEVUTA") if str(inquiry.get("choice", "")) == "reserve" else tr("ASCOLTA LA VOCE DELLA FILA")
	defer_button.text = tr("RIMANDA AL PROSSIMO PERCORSO")
	continue_button.text = tr("CONFRONTA LE TRACCE")
	reserve.disabled = false
	witness.disabled = false
	reserve.show()
	witness.show()
	defer_button.show()
	continue_button.visible = seen == 3
	reserve.focus_next = witness.get_path()
	reserve.focus_previous = defer_button.get_path()
	reserve.focus_neighbor_top = defer_button.get_path()
	reserve.focus_neighbor_bottom = witness.get_path()
	witness.focus_next = continue_button.get_path() if seen == 3 else defer_button.get_path()
	witness.focus_previous = reserve.get_path()
	witness.focus_neighbor_top = reserve.get_path()
	witness.focus_neighbor_bottom = continue_button.get_path() if seen == 3 else defer_button.get_path()
	continue_button.focus_next = defer_button.get_path()
	continue_button.focus_previous = witness.get_path()
	continue_button.focus_neighbor_top = witness.get_path()
	continue_button.focus_neighbor_bottom = defer_button.get_path()
	defer_button.focus_previous = continue_button.get_path() if seen == 3 else witness.get_path()
	defer_button.focus_next = reserve.get_path()
	defer_button.focus_neighbor_top = continue_button.get_path() if seen == 3 else witness.get_path()
	defer_button.focus_neighbor_bottom = reserve.get_path()

func _render_question(unsupported: bool) -> void:
	title.text = tr("CHE COSA PUOI SCRIVERE?")
	evidence.text = tr("Hai esaminato la copia e la seconda traccia. Quale conclusione puoi sostenere?")
	if unsupported:
		evidence.text += "\n\n" + tr("Nessuna delle due tracce nomina chi sedeva lì. Rileggi ciò che è rimasto.")
	reserve.text = tr("MANCA UNA PARTE DELLA COPIA")
	witness.text = tr("LA COPIA IDENTIFICA CHI SEDEVA")
	continue_button.text = tr("RILEGGI LE TRACCE")
	continue_button.show()
	reserve.focus_previous = defer_button.get_path()
	witness.focus_next = continue_button.get_path()
	witness.focus_neighbor_bottom = continue_button.get_path()
	continue_button.focus_previous = witness.get_path()
	continue_button.focus_next = defer_button.get_path()
	continue_button.focus_neighbor_top = witness.get_path()
	continue_button.focus_neighbor_bottom = defer_button.get_path()
	defer_button.focus_previous = continue_button.get_path()
	defer_button.focus_next = reserve.get_path()
	defer_button.focus_neighbor_top = continue_button.get_path()
	reserve.grab_focus()

func _on_inquiry_changed(payload: Dictionary) -> void:
	if not active or mode not in ["inquiry", "question"]:
		return
	var result := str(payload.get("result", ""))
	if result == "deferred":
		_close()
	elif result in ["inspect_copy", "inspect_trace"]:
		inquiry = payload.duplicate()
		_render_inquiry()
		if int(inquiry.seen) == 3:
			continue_button.grab_focus()
		elif result == "inspect_copy":
			witness.grab_focus()
		else:
			reserve.grab_focus()
	elif result == "unsupported":
		_render_question(true)
	elif result == "complete":
		mode = "inquiry_result"
		title.text = tr("LE TRACCE DEL POSTO")
		evidence.text = tr("Annotato: manca una parte della copia. Il nome di chi sedeva resta senza prova.")
		reserve.hide()
		witness.hide()
		defer_button.hide()
		continue_button.text = tr("ASCOLTA LA RISPOSTA")
		continue_button.show()
		continue_button.focus_next = continue_button.get_path()
		continue_button.focus_previous = continue_button.get_path()
		continue_button.focus_neighbor_top = continue_button.get_path()
		continue_button.focus_neighbor_bottom = continue_button.get_path()
		continue_button.grab_focus()

func _close(open_followup: bool = false) -> void:
	active = false
	hide()
	if open_followup:
		get_parent().call_deferred("_try_open")
		return
	var registry := get_node_or_null("../../UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book") as Control
	if registry != null and registry.is_visible_in_tree():
		registry.grab_focus()

func _on_run_ended(_reason: String, _summary: Dictionary) -> void:
	_close()

func _unhandled_input(event: InputEvent) -> void:
	if active and event.is_action_pressed("ui_cancel"):
		# The last Era's sheets cannot be deferred; Cancel only leaves their result.
		if mode not in ["ledger", "final_copy"]:
			_choose("continue" if mode in ["case_result", "inquiry_result", "copy_result", "final_result"] else "defer")
		get_viewport().set_input_as_handled()
