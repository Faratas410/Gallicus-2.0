extends SceneTree

# The last Era dismantles the apparatus one percorso at a time: Vessa's last
# figure, Orvo's last bando with Lauro's last strophe, Nerio's last copy and the
# farewell. Each piece is recorded in the profile and changes the rite after it.
const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
const FinalEra = preload("res://scripts/content/final_era.gd")
const Cantastorie = preload("res://scripts/content/cantastorie.gd")
const FINALS: Array[String] = ["final_ledger", "final_bando", "final_copy", "departure"]
const SHEET_KEYS: Array[String] = [
	"L'ULTIMA CIFRA", "L'ULTIMO FOGLIO", "L'ULTIMA ERA", "L'ULTIMA STROFA",
	"Vessa chiude il banco. Da questo percorso il conto non cambia più: niente acquisti, niente quietanze in Denari. Dove va l'ultima cifra?",
	"ALLA STROFA DI LAURO · tutto il conto\nLauro mette per iscritto la gesta più alta. L'Archivio la conserva.",
	"ALLA GRADINATA · tutto il conto\nFavore +2 all'inizio di ogni percorso, fino alla fine.",
	"A VESSA · nessuna spesa\nVessa tiene il conto chiuso. Nessun effetto sul rito.",
	"PAGA CON LA VOCE\nIl debito si chiude. Il prossimo percorso parte con Pressione +2.",
	"LASCIA IL DEBITO SCRITTO\nIl Registro conserva il debito. Pressione +1 a ogni percorso, fino alla fine.",
	"Nerio può copiare una sola memoria. Quello che non copia resta a chi lo ricorda.",
	"IL POSTO\nNerio lo copia nell'ultimo foglio.", "LA GESTA PIÙ ALTA\nNerio la copia nell'ultimo foglio.",
	"I SEGNI\nNerio li copia nell'ultimo foglio.",
	"Vessa ha chiuso il banco. Il conto resta all'ultima cifra.",
	"La gradinata ricorda l'ultima cifra: Favore +2.", "Vessa ricorda la voce: Pressione +2."]
var failures: Array[String] = []
var save: Node
var scene: Node
var manager: Node
var view: Node
var case_ui: Control
var notes: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error("FINAL_ERA: " + message)

func boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	view = scene.get_node("OpeningPrologue")
	case_ui = view.get_node("SeatCase")
	await create_timer(0.5).timeout

func set_era_runs(era_runs: int, scar_tolerance: float = 0.0) -> void:
	save.commit_registry_evolution(0.0, 3, {"era_runs": era_runs, "signature": {"scar_tolerance": scar_tolerance}})
	if manager != null:
		manager.set("_registry_era", 3)

func new_percorso() -> void:
	notes.clear()
	manager.request_new_game()
	await create_timer(0.8).timeout

func dialogue_id() -> String:
	return str(view.get("_payload").get("id", "")) if bool(view.get("_active")) else ""

func finish() -> void:
	await create_timer(0.6).timeout
	view.call("_finish")
	await process_frame

func press(button_name: String) -> void:
	var button: Button = case_ui.find_child(button_name, true, false)
	check(button != null and button.is_visible_in_tree() and not button.disabled, "button unavailable: " + button_name)
	if button != null and button.is_visible_in_tree() and not button.disabled:
		button.pressed.emit()

func button(button_name: String) -> Button:
	return case_ui.find_child(button_name, true, false) as Button

func reopen_final(scenes_unheard: Array[String]) -> void:
	var meta: Dictionary = save.get("_meta")
	meta["final_era"] = save.call("_default_final_era")
	var seen: Array = save.get("_settings")["campaign_dialogues_seen"]
	for id: String in scenes_unheard:
		seen.erase(id)

func _run() -> void:
	save = root.get_node("SaveManager")
	_check_profile_data()
	for id: String in Dialogues.SEQUENCES:
		if id not in FINALS:
			save.mark_campaign_dialogue_seen(id)
	check(save.resolve_seat_case("witness", 1, 0) and save.mark_seat_evidence(1) and save.mark_seat_evidence(2) and save.complete_seat_inquiry() and save.resolve_seat_copy("keep"), "seat arc fixture failed")
	save.set_ledger_denari(30)
	set_era_runs(0)
	await boot()
	root.get_node("GameEvents").crowd_favor_changed.connect(func(payload: Dictionary) -> void: notes.append(str(payload.get("note", ""))))
	root.get_node("GameEvents").ledger_changed.connect(func(payload: Dictionary) -> void: notes.append(str(payload.get("note", ""))))
	await _check_translations_and_layout()
	set_era_runs(0)
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(dialogue_id() == "" and bool(manager.get_banco_view().open), "the first percorso of the last Era must leave the counter open")
	# Percorso 2: Vessa closes the account.
	set_era_runs(1)
	await new_percorso()
	check(dialogue_id() == "final_ledger", "Vessa's scene did not open its percorso")
	await finish()
	check(case_ui.visible and str(case_ui.get("mode")) == "ledger", "the last figure sheet did not follow its scene")
	check(not button("Btn_Seat_Reserve").disabled and not button("Btn_Seat_Witness").disabled and button("Btn_Seat_Defer").visible, "positive account lacks its three destinations")
	press("Btn_Seat_Witness")
	var record: Dictionary = save.get_final_era()
	check(str(record.ledger) == "crowd" and int(record.amount) == 30 and save.get_ledger_denari() == 0, "the stands did not receive the whole account")
	var counter: Dictionary = manager.get_banco_view()
	check(bool(counter.closed) and not bool(counter.open) and (counter.items as Array).is_empty(), "the counter stayed open after the last figure")
	manager.call("_ledger_change", 5, "")
	check(save.get_ledger_denari() == 0, "the closed account still moved")
	check(str(case_ui.get("evidence").text).contains(tr(str(FinalEra.RESULTS.crowd))), "the sheet did not show its result")
	press("Btn_Seat_Continue")
	check(not case_ui.visible and manager.get_campaign_dialogue().is_empty(), "another scene stacked after the last figure")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(dialogue_id() == "" and not case_ui.visible, "resume reopened the last figure")
	# Percorso 3: the stands remember the figure; Orvo's last bando, in a low
	# voice: one rung below the completed ladder and the whole percorso.
	save.set_bando_step(12)
	set_era_runs(2)
	await new_percorso()
	check(notes.has("La gradinata ricorda l'ultima cifra: Favore +2."), "the stands did not remember the last figure")
	var run: RunState = manager.get("_run_state")
	check(run.bando_status == "open" and run.bando_quota == 42 and int(manager.get_bando_view().denari) == 0, "the bando before the announcement is wrong")
	check(dialogue_id() == "final_bando", "Orvo's scene did not open its percorso")
	await finish()
	check(str(save.get_final_era().bando) == "open", "Orvo's announcement was not recorded")
	var bando: Dictionary = manager.get_bando_view()
	check(run.bando_quota == 38 and run.bando_deadline == 7 and bool(bando.last), "the last bando did not ask one rung lower over every arena")
	var hud: Node = scene.get_node("UI")
	hud.call("_render_bando_panel")
	check(str(hud.get("bando_note").text) == tr("Ultimo bando: un gradino in meno, tutte le arene."), "the panel did not announce the last bando")
	var restored := RunState.new()
	restored.from_dict(run.to_dict())
	check(restored.bando_quota == 38 and restored.bando_deadline == 7, "the eased bando was not kept in the checkpoint")
	run.bando_status = "closed"
	hud.call("_on_bando_changed", manager.get_bando_view())
	check(str(hud.get("bando_body").text) == tr("Ultimo bando chiuso: Lauro ne fa l'ultima strofa.") and str(hud.call("_dossier_bando_line")) == tr("Ultimo bando chiuso: Lauro ne fa l'ultima strofa."), "the closed last bando promised Denari or another bando")
	run.bando_status = "closed"
	var gesta: Dictionary = manager.call("_sing_gesta", false)
	record = save.get_final_era()
	check(bool(gesta.last) and str(record.bando) == "closed" and (record.strophe as Array).size() == 3, "Lauro's last strophe was not kept")
	check(not bool(manager.call("_sing_gesta", false).last), "the last strophe was sung twice")
	# Percorso 4: no bando; Nerio's last copy.
	set_era_runs(3)
	await new_percorso()
	run = manager.get("_run_state")
	check(run.bando_status == "" and str(manager.get_bando_view().status) == "", "a bando opened after the last one")
	check(dialogue_id() == "final_copy", "Nerio's scene did not open its percorso")
	await finish()
	check(case_ui.visible and str(case_ui.get("mode")) == "final_copy", "the last sheet did not follow its scene")
	check(button("Btn_Seat_Reserve").visible and button("Btn_Seat_Witness").visible and not button("Btn_Seat_Defer").visible, "the last sheet offered memories that do not exist")
	root.get_node("GameEvents").request_final_copy_choice.emit("scars")
	check(str(save.get_final_era().copy) == "", "an absent memory was copied")
	press("Btn_Seat_Witness")
	check(str(save.get_final_era().copy) == "gesta", "the highest deed was not copied")
	check(str(case_ui.get("evidence").text).contains(tr(str(FinalEra.KEEPERS.seat))), "the sheet did not say who keeps the seat")
	press("Btn_Seat_Continue")
	# Percorso 5: the farewell closes the dismantling.
	set_era_runs(4)
	await new_percorso()
	check(dialogue_id() == "departure", "the farewell did not close the last Era")
	await finish()
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	menu.call("_build_museo_list")
	var archive: Array[String] = []
	for label: Label in menu.get("museo_vbox").find_children("*", "Label", true, false):
		archive.append(label.text)
	var archived := "\n".join(archive)
	for line: String in [FinalEra.RESULTS.crowd, FinalEra.RESULTS.gesta, FinalEra.KEEPERS.seat, FinalEra.BANDO.closed]:
		check(archived.contains(tr(line)), "Archive lacks: " + line)
	await _check_debt_and_scars()
	await _check_zero_balance_and_copy()
	save.reset_campaign()
	check(save.get_final_era() == save.call("_default_final_era"), "reset kept the last Era")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("FINAL_ERA_RUNTIME_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if failures.is_empty() else 1)

func _check_profile_data() -> void:
	var isolated: Node = load("res://scripts/systems/save_manager.gd").new()
	isolated.set("_profile_loaded", true)
	var verse: String = Cantastorie.all_keys()[0]
	isolated.call("_load_meta_from_profile", {"meta": {"final_era": {"ledger": "lauro", "amount": "x", "voice_pending": true,
		"bando": "closed", "strophe": [{"key": "unknown"}, {"key": verse, "value": 3.0}], "copy": "elsewhere"}}})
	var record: Dictionary = isolated.get_final_era()
	check(str(record.ledger) == "lauro" and int(record.amount) == 0 and not bool(record.voice_pending), "malformed last figure accepted")
	check(str(record.bando) == "closed" and (record.strophe as Array).size() == 1 and str(record.copy) == "", "malformed strophe or copy accepted")
	isolated.call("_load_meta_from_profile", {"meta": {}})
	check(isolated.get_final_era() == isolated.call("_default_final_era"), "older profiles must start with nothing closed")
	isolated.free()

func _check_debt_and_scars() -> void:
	# In debt the figure is paid with the voice or left written; a scarred reading adds the Marks.
	reopen_final(["final_ledger", "final_bando", "final_copy", "departure"])
	save.set_ledger_denari(-8)
	set_era_runs(1, 0.5)
	await new_percorso()
	check(dialogue_id() == "final_ledger", "Vessa's scene did not open in debt")
	await finish()
	check(case_ui.visible and not button("Btn_Seat_Defer").visible and not button("Btn_Seat_Reserve").disabled, "debt sheet lacks its two destinations")
	root.get_node("GameEvents").request_final_ledger_choice.emit("crowd")
	check(str(save.get_final_era().ledger) == "", "a debt was given to the stands")
	press("Btn_Seat_Reserve")
	var record: Dictionary = save.get_final_era()
	check(str(record.ledger) == "voice" and bool(record.voice_pending) and save.get_ledger_denari() == 0 and int(record.amount) == -8, "the voice did not close the debt")
	press("Btn_Seat_Continue")
	save.mark_campaign_dialogue_seen("final_bando")
	set_era_runs(3, 0.5)
	await new_percorso()
	check(notes.has("Vessa ricorda la voce: Pressione +2.") and not bool(save.get_final_era().voice_pending), "the voice was not paid on the next percorso")
	check(dialogue_id() == "final_copy", "Nerio's scene did not open after the voice")
	await finish()
	check(button("Btn_Seat_Defer").visible, "a scarred reading did not offer the Marks")
	press("Btn_Seat_Defer")
	check(str(save.get_final_era().copy) == "scars", "the Marks were not copied")
	press("Btn_Seat_Continue")

func _check_zero_balance_and_copy() -> void:
	reopen_final(["final_ledger"])
	save.set_ledger_denari(0)
	set_era_runs(1)
	await new_percorso()
	await finish()
	check(button("Btn_Seat_Reserve").disabled and button("Btn_Seat_Witness").disabled and not button("Btn_Seat_Defer").disabled, "an empty account could still pay")
	root.get_node("GameEvents").request_final_ledger_choice.emit("lauro")
	check(str(save.get_final_era().ledger) == "", "an empty account paid Lauro")
	press("Btn_Seat_Defer")
	check(str(save.get_final_era().ledger) == "vessa", "Vessa did not keep the closed account")
	press("Btn_Seat_Continue")
	# A seat copy still pending after the closure can no longer be paid.
	var meta: Dictionary = save.get("_meta")
	meta["seat_copy"] = ""
	meta["ledger_denari"] = 12
	var copy_view: Dictionary = manager.get_seat_copy()
	check(not copy_view.is_empty() and not bool(copy_view.copy_available), "the paid copy stayed available after the closure")
	root.get_node("GameEvents").request_seat_copy_choice.emit("copy")
	check(save.get_seat_copy() == "" and save.get_ledger_denari() == 12, "the closed account paid for a copy")

func _check_translations_and_layout() -> void:
	var keys: Array[String] = SHEET_KEYS.duplicate()
	keys.append_array(FinalEra.all_keys())
	for id: String in ["final_ledger", "final_bando", "final_copy"]:
		keys.append(str(Dialogues.SEQUENCES[id].title))
		for line: Dictionary in Dialogues.SEQUENCES[id].lines:
			keys.append(str(line.text))
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		if locale != "it":
			for key: String in keys:
				check(TranslationServer.translate(key) != key, "untranslated %s: %s" % [locale, key])
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.size = dimensions
			root.content_scale_size = dimensions
			for id: String in ["final_ledger", "final_bando", "final_copy"]:
				var payload: Dictionary = Dialogues.SEQUENCES[id].duplicate(true)
				payload["id"] = id
				for index: int in range(payload.lines.size()):
					view.set("_payload", payload)
					view.set("_beat", index)
					view.set("_active", true)
					view.call("_refresh_line")
					await process_frame
					var body: Label = view.get("_caption")
					check(body.get_line_count() * body.get_line_height() <= body.size.y + 1, "clipped %s %s %d" % [id, locale, index])
	view.set("_active", false)
	view.set("_payload", {})
	TranslationServer.set_locale("it")
