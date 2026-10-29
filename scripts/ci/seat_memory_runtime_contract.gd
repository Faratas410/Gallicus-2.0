extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var errors: Array[String] = []
var save: Node
var scene: Node
var manager: Node
var view: Node

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		errors.append(message)
		push_error("SEAT_MEMORY: " + message)

func boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	view = scene.get_node("OpeningPrologue")
	await create_timer(0.5).timeout

func _run() -> void:
	save = root.get_node("SaveManager")
	save.commit_registry_evolution(0.0, 1, {})
	for id: String in Dialogues.SEQUENCES:
		if id not in ["seat_receipt_after_inquiry", "seat_voice_after_inquiry"]:
			save.mark_campaign_dialogue_seen(id)
	save.set_ledger_denari(10)
	check(save.resolve_seat_case("reserve", 1, 6), "reserve fixture failed")
	await boot()
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(str(manager.get_campaign_dialogue().get("id", "")) != "seat_receipt_after_inquiry", "response opened before inquiry")
	check(save.mark_seat_evidence(1) and save.mark_seat_evidence(2) and save.complete_seat_inquiry(), "inquiry fixture failed")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(view.get("_active") and str(view.get("_payload").get("id", "")) == "seat_receipt_after_inquiry", "receipt response missing on resume")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(str(view.get("_payload").get("id", "")) == "seat_receipt_after_inquiry", "interrupted response did not return")
	view.call("_finish")
	check(save.has_seen_campaign_dialogue("seat_receipt_after_inquiry"), "receipt response not recorded")
	save.set("_profile_loaded", false)
	save.load_profile()
	check(manager.get_campaign_dialogue().is_empty(), "receipt response repeated after reload")
	var meta: Dictionary = save.get("_meta")
	meta["seat_case"] = {"choice": "witness", "era": 1}
	meta["seat_inquiry"] = {"seen": 0, "complete": false}
	# Exercise the final Era: the response must not require another percorso.
	save.commit_registry_evolution(0.0, 3, {})
	manager.set("_registry_era", 3)
	manager.request_new_game()
	await create_timer(0.8).timeout
	var case_ui: Control = view.get_node("SeatCase")
	check(case_ui.visible and str(case_ui.get("mode")) == "inquiry", "voice inquiry did not open")
	for button_name: String in ["Btn_Seat_Reserve", "Btn_Seat_Witness", "Btn_Seat_Continue", "Btn_Seat_Reserve"]:
		(case_ui.find_child(button_name, true, false) as Button).pressed.emit()
	check(bool(save.get_seat_inquiry().complete), "voice inquiry did not complete")
	check(str(case_ui.find_child("Btn_Seat_Continue", true, false).text) == "ASCOLTA LA RISPOSTA", "response action is not explicit")
	(case_ui.find_child("Btn_Seat_Continue", true, false) as Button).pressed.emit()
	await create_timer(0.8).timeout
	check(view.get("_active") and str(view.get("_payload").get("id", "")) == "seat_voice_after_inquiry", "voice response did not open in the same percorso")
	view.call("_finish")
	check(save.has_seen_campaign_dialogue("seat_voice_after_inquiry"), "voice response not recorded")
	check(save.get_ledger_denari() == 4, "response changed account")
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("SEAT_MEMORY_RUNTIME_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if errors.is_empty() else 1)
