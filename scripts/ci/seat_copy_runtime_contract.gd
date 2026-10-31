extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var errors: Array[String] = []
var save: Node
var scene: Node
var manager: Node
var case_ui: Control

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	if not value:
		errors.append(message)
		push_error("SEAT_COPY: " + message)

func boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	case_ui = scene.get_node("OpeningPrologue/SeatCase")
	await create_timer(0.5).timeout

func press(name: String) -> void:
	var button: Button = case_ui.find_child(name, true, false)
	check(button != null and button.is_visible_in_tree() and not button.disabled, "unavailable: " + name)
	if button != null and button.is_visible_in_tree() and not button.disabled:
		button.pressed.emit()

func send_key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	root.push_input(event, true)
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	root.push_input(event, true)
	await process_frame

func _run() -> void:
	save = root.get_node("SaveManager")
	# The copy belongs to the last Era of the arc (SEAT_STEP_ERAS): insure costs 5 + 3.
	save.commit_registry_evolution(0.0, 3, {})
	for id: String in Dialogues.SEQUENCES:
		# The last Era's dismantling has its own contract (final_era_runtime_contract.gd).
		if id not in ["final_ledger", "final_bando", "final_copy"]:
			save.mark_campaign_dialogue_seen(id)
	check(save.resolve_seat_case("witness", 1, 0), "fixture case failed")
	check(save.mark_seat_evidence(1) and save.mark_seat_evidence(2) and save.complete_seat_inquiry(), "fixture inquiry failed")
	save.set_ledger_denari(-5)
	await boot()
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(case_ui.visible and str(case_ui.get("mode")) == "copy", "copy decision missing")
	var seen: Array = save.get("_settings")["campaign_dialogues_seen"]
	seen.erase("seat_voice_after_inquiry")
	check(manager.get_seat_copy().is_empty(), "copy offered before the response")
	seen.append("seat_voice_after_inquiry")
	check(case_ui.find_child("Btn_Seat_Reserve", true, false).disabled, "copy payable in debt")
	check(case_ui.find_child("Btn_Seat_Witness", true, false).has_focus(), "free option lacks focus")
	await send_key(KEY_TAB)
	check(case_ui.find_child("Btn_Seat_Defer", true, false).has_focus(), "defer lacks keyboard focus")
	await send_key(KEY_TAB)
	check(case_ui.find_child("Btn_Seat_Witness", true, false).has_focus(), "disabled paid option captured focus")
	root.get_node("GameEvents").request_seat_copy_choice.emit("copy")
	check(save.get_seat_copy() == "" and save.get_ledger_denari() == -5, "unaffordable copy accepted")
	press("Btn_Seat_Defer")
	check(bool(manager.get("_run_state").seat_copy_deferred), "defer not stored")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(not case_ui.visible and bool(manager.get("_run_state").seat_copy_deferred), "defer did not survive resume")
	manager.request_new_game()
	await create_timer(0.8).timeout
	check(case_ui.visible and str(case_ui.get("mode")) == "copy", "deferred decision did not return")
	press("Btn_Seat_Witness")
	check(save.get_seat_copy() == "keep" and save.get_ledger_denari() == -5, "free choice in debt failed")
	await send_key(KEY_TAB)
	check(case_ui.find_child("Btn_Seat_Continue", true, false).has_focus(), "result focus escaped")
	seen.erase("seat_copy_for_dima")
	press("Btn_Seat_Continue")
	await create_timer(0.8).timeout
	var dialogue: Node = scene.get_node("OpeningPrologue")
	check(dialogue.get("_active") and str(dialogue.get("_payload").get("id", "")) == "seat_copy_for_dima", "free choice response missing")
	dialogue.call("_finish")
	save.set("_profile_loaded", false)
	save.load_profile()
	check(save.get_seat_copy() == "keep" and manager.get_seat_copy().is_empty(), "free choice did not persist")
	check(int(manager.call("_banco_price", "insure")) == 8, "free choice received paid discount")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	menu.call("_build_museo_list")
	var found := false
	for label: Label in menu.get("museo_vbox").find_children("*", "Label", true, false):
		if label.text == "Dima tiene l'annotazione. Il fascicolo di Nerio resta senza quella copia.":
			found = true
	check(found, "Archive lacks free choice")
	var meta: Dictionary = save.get("_meta")
	meta["seat_copy"] = ""
	seen = save.get("_settings")["campaign_dialogues_seen"]
	seen.erase("seat_copy_for_nerio")
	save.set_ledger_denari(12)
	manager.request_new_game()
	await create_timer(0.8).timeout
	press("Btn_Seat_Reserve")
	check(save.get_seat_copy() == "copy" and save.get_ledger_denari() == 7, "paid copy not resolved")
	root.get_node("GameEvents").request_seat_copy_choice.emit("copy")
	check(save.get_ledger_denari() == 7, "copy charged twice")
	press("Btn_Seat_Continue")
	await create_timer(0.8).timeout
	check(dialogue.get("_active") and str(dialogue.get("_payload").get("id", "")) == "seat_copy_for_nerio", "paid choice response missing")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	save.set("_profile_loaded", false)
	save.load_profile()
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	dialogue = scene.get_node("OpeningPrologue")
	check(dialogue.get("_active") and str(dialogue.get("_payload").get("id", "")) == "seat_copy_for_nerio", "paid response did not survive resume")
	check(save.get_ledger_denari() == 7 and int(manager.call("_banco_price", "insure")) == 7, "paid discount or balance changed on resume")
	dialogue.call("_finish")
	menu = scene.get_node("MenuLayer/MainMenu")
	save.set("_profile_loaded", false)
	save.load_profile()
	check(save.get_seat_copy() == "copy" and save.get_ledger_denari() == 7, "paid copy not persisted")
	check(save.get_seat_copy_era() == 3 and int(manager.call("_banco_price", "insure")) == 7, "paid copy discount missing")
	var insurance: Dictionary = {}
	for item: Dictionary in manager.get_banco_view().items:
		if str(item.id) == "insure":
			insurance = item
	check(int(insurance.get("price", -1)) == 7 and bool(insurance.get("available", false)) and str(insurance.get("title", "")).contains("SCONTO"), "discount not disclosed at banco")
	root.get_node("GameEvents").request_banco_purchase.emit("insure")
	check(save.get_ledger_denari() == 0 and bool(manager.get("_run_state").banco_insured), "discounted policy did not charge correctly")
	menu.call("_build_museo_list")
	found = false
	var discount_found := false
	for label: Label in menu.get("museo_vbox").find_children("*", "Label", true, false):
		if label.text == "Dima tiene l'annotazione. Nerio ne riceve una copia nel suo fascicolo.":
			found = true
		if label.text == "La polizza costa 1 Denaro in meno fino al prossimo Silenzio.":
			discount_found = true
	check(found, "Archive lacks paid choice")
	check(discount_found, "Archive lacks active discount")
	# A copy recorded in an earlier Era (older profiles) no longer discounts the policy.
	save.get("_meta")["seat_copy_era"] = 2
	check(int(manager.call("_banco_price", "insure")) == 8, "discount survived the next Silence")
	menu.call("_build_museo_list")
	await process_frame
	for label: Label in menu.get("museo_vbox").find_children("*", "Label", true, false):
		check(label.text != "La polizza costa 1 Denaro in meno fino al prossimo Silenzio.", "Archive shows expired discount")
	var prior_meta: Dictionary = save.get("_meta").duplicate(true)
	var malformed: Dictionary = prior_meta.duplicate(true)
	malformed.erase("seat_copy_era")
	save.call("_load_meta_from_profile", {"meta": malformed})
	check(save.get_seat_copy() == "copy" and save.get_seat_copy_era() == 3, "previous paid profile did not migrate")
	malformed["registry_era"] = 4
	save.call("_load_meta_from_profile", {"meta": malformed})
	check(save.get_seat_copy_era() == -1 and not bool(manager.call("_seat_copy_insurance_discount")), "terminal profile gained a discount")
	malformed = prior_meta.duplicate(true)
	malformed["seat_copy_era"] = 0.5
	save.call("_load_meta_from_profile", {"meta": malformed})
	check(save.get_seat_copy_era() == -1, "malformed discount era accepted")
	malformed = prior_meta.duplicate(true)
	malformed["seat_inquiry"] = {"seen": 0, "complete": false}
	malformed["seat_copy"] = "copy"
	save.call("_load_meta_from_profile", {"meta": malformed})
	check(save.get_seat_copy() == "", "copy survived without completed inquiry")
	malformed = prior_meta.duplicate(true)
	malformed.erase("seat_copy")
	save.call("_load_meta_from_profile", {"meta": malformed})
	check(save.get_seat_copy() == "", "old profile did not receive empty default")
	save.call("_load_meta_from_profile", {"meta": prior_meta})
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("SEAT_COPY_RUNTIME_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if errors.is_empty() else 1)
