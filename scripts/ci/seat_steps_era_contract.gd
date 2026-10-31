extends SceneTree

# The empty-seat arc takes one step per Era: case (1), comparison (2), copy (3).
# Each step opens an entry of its own with a recall and never stacks after
# another scene of the same percorso, including after a resume.
const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
const RECALLS: Array[String] = ["seat_case_recall", "seat_inquiry_recall", "seat_copy_recall"]
var failures: Array[String] = []
var save: Node
var scene: Node
var manager: Node
var view: Node
var case_ui: Control

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error("SEAT_STEPS_ERA: " + message)

func boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	view = scene.get_node("OpeningPrologue")
	case_ui = view.get_node("SeatCase")
	await create_timer(0.5).timeout

func set_era(era: int) -> void:
	save.commit_registry_evolution(0.0, era, {})
	manager.set("_registry_era", era)

func new_percorso() -> void:
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

func _run() -> void:
	save = root.get_node("SaveManager")
	var legacy := RunState.new()
	legacy.from_dict({})
	check(legacy.campaign_scenes_heard.is_empty(), "legacy checkpoint must start with no heard scene")
	var dirty := RunState.new()
	dirty.from_dict({"campaign_scenes_heard": ["seat_kept", "unknown", 7, "seat_kept"]})
	check(dirty.campaign_scenes_heard.size() == 1 and dirty.campaign_scenes_heard[0] == "seat_kept", "heard scenes were not sanitized")
	# The bando brought the empty-seat racconto early, in the first Era.
	var unheard: Array[String] = ["middle", "departure", "final_ledger", "final_bando", "final_copy", "seat_reserved_followup", "seat_witness_followup",
		"seat_receipt_after_inquiry", "seat_voice_after_inquiry", "seat_copy_for_nerio", "seat_copy_for_dima"]
	unheard.append_array(RECALLS)
	for id: String in Dialogues.SEQUENCES:
		if id not in unheard:
			save.mark_campaign_dialogue_seen(id)
	await boot()
	# The main menu registers the translations at boot.
	for locale: String in ["en", "es"]:
		TranslationServer.set_locale(locale)
		for id: String in RECALLS:
			var texts: Array[String] = [str(Dialogues.SEQUENCES[id].title)]
			for line: Dictionary in Dialogues.SEQUENCES[id].lines:
				texts.append(str(line.text))
			for text: String in texts:
				check(TranslationServer.translate(text) != text, "untranslated recall %s: %s" % [locale, text])
	TranslationServer.set_locale("it")
	set_era(0)
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(dialogue_id() == "" and not case_ui.visible and manager.get_seat_case().is_empty(), "case opened before its Era")
	# Era 1: the recall opens a fresh entry and leads to the case.
	set_era(1)
	await new_percorso()
	check(dialogue_id() == "seat_case_recall", "case recall did not open the entry")
	await finish()
	check(case_ui.visible and str(case_ui.get("mode")) == "case", "case did not follow its recall")
	press("Btn_Seat_Witness")
	press("Btn_Seat_Continue")
	await create_timer(0.8).timeout
	check(dialogue_id() == "seat_witness_followup", "case consequence did not follow in the same entry")
	await finish()
	check(not case_ui.visible and manager.get_seat_inquiry().is_empty(), "comparison opened in the case Era")
	await new_percorso()
	check(dialogue_id() == "" and not case_ui.visible, "a later percorso of the case Era reopened the arc")
	# Era 2: the Era scene keeps its entry; the recall waits for the next one.
	set_era(2)
	await new_percorso()
	check(dialogue_id() == "middle", "Era scene did not keep priority")
	await finish()
	check(not case_ui.visible and manager.get_campaign_dialogue().is_empty(), "recall stacked after another scene")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(dialogue_id() == "" and not case_ui.visible, "resume stacked the recall after a heard scene")
	await new_percorso()
	check(dialogue_id() == "seat_inquiry_recall", "comparison recall did not open the next entry")
	await finish()
	check(case_ui.visible and str(case_ui.get("mode")) == "inquiry", "comparison did not follow its recall")
	for button_name: String in ["Btn_Seat_Reserve", "Btn_Seat_Witness", "Btn_Seat_Continue", "Btn_Seat_Reserve"]:
		press(button_name)
	check(bool(save.get_seat_inquiry().complete), "comparison did not complete")
	press("Btn_Seat_Continue")
	await create_timer(0.8).timeout
	check(dialogue_id() == "seat_voice_after_inquiry", "comparison response did not follow in the same entry")
	await finish()
	check(not case_ui.visible and manager.get_seat_copy().is_empty(), "copy opened in the comparison Era")
	# Era 3: the copy, paid in Denari, opens the first percorso, before Vessa
	# closes the account (final_era_runtime_contract.gd covers the dismantling).
	set_era(3)
	await new_percorso()
	check(dialogue_id() == "seat_copy_recall", "copy recall did not open the last Era")
	await finish()
	check(case_ui.visible and str(case_ui.get("mode")) == "copy", "copy did not follow its recall")
	press("Btn_Seat_Witness")
	press("Btn_Seat_Continue")
	await create_timer(0.8).timeout
	check(dialogue_id() == "seat_copy_for_dima", "copy consequence did not follow in the same entry")
	await finish()
	await new_percorso()
	check(dialogue_id() == "" and not case_ui.visible, "the closed arc reopened")
	save.set("_profile_loaded", false)
	save.load_profile()
	for id: String in RECALLS:
		check(save.has_seen_campaign_dialogue(id), "recall not persisted: " + id)
	check(save.get_seat_copy() == "keep" and bool(save.get_seat_inquiry().complete), "arc choices not persisted")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("SEAT_STEPS_ERA_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if failures.is_empty() else 1)
