extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var failures: Array[String] = []
var scene: Node
var manager: Node
var save: Node
var case_ui: Control

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error("SEAT_INQUIRY: " + message)

func boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	await create_timer(0.5).timeout
	case_ui = scene.get_node("OpeningPrologue/SeatCase")

func press(button_name: String) -> void:
	var button: Button = case_ui.find_child(button_name, true, false)
	check(button != null and button.is_visible_in_tree() and not button.disabled, "button unavailable: " + button_name)
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
	save.commit_registry_evolution(0.0, 1, {})
	for id: String in Dialogues.SEQUENCES.keys():
		save.mark_campaign_dialogue_seen(id)
	save.set_ledger_denari(10)
	check(save.resolve_seat_case("reserve", 1, 6), "fixture could not reserve")
	await boot()
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(case_ui.visible and str(case_ui.get("mode")) == "inquiry", "inquiry did not open after the follow-up")
	root.get_node("GameEvents").request_seat_inquiry_action.emit("conclude_copy")
	check(not bool(save.get_seat_inquiry().complete), "conclusion accepted before evidence")
	check(case_ui.find_child("Btn_Seat_Reserve", true, false).has_focus(), "first trace lacks keyboard focus")
	await send_key(KEY_ENTER)
	check(int(save.get_seat_inquiry().seen) == 1, "copy inspection was not saved")
	press("Btn_Seat_Defer")
	check(not case_ui.visible and bool(manager.get("_run_state").seat_inquiry_deferred), "deferral failed")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	await boot()
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	check(not case_ui.visible and int(save.get_seat_inquiry().seen) == 1, "resume reopened deferral or lost evidence")
	# A fresh percorso resets the run-scoped deferral, retaining profile evidence.
	manager.request_new_game()
	await create_timer(0.8).timeout
	check(case_ui.visible and int(save.get_seat_inquiry().seen) == 1, "next percorso did not restore the inquiry")
	await send_key(KEY_TAB)
	check(case_ui.find_child("Btn_Seat_Witness", true, false).has_focus(), "evidence focus escaped its choices")
	await send_key(KEY_ENTER)
	check(int(save.get_seat_inquiry().seen) == 3, "second evidence did not persist")
	check(case_ui.find_child("Btn_Seat_Continue", true, false).has_focus(), "comparison is not focused after both traces")
	await send_key(KEY_DOWN)
	check(case_ui.find_child("Btn_Seat_Defer", true, false).has_focus(), "down navigation left the inquiry")
	await send_key(KEY_UP)
	check(case_ui.find_child("Btn_Seat_Continue", true, false).has_focus(), "up navigation cannot return to comparison")
	press("Btn_Seat_Continue")
	check(str(case_ui.get("mode")) == "question", "comparison question did not open")
	await send_key(KEY_TAB)
	check(case_ui.find_child("Btn_Seat_Witness", true, false).has_focus(), "question focus escaped its choices")
	await send_key(KEY_ENTER)
	check(not bool(save.get_seat_inquiry().complete), "unsupported identity inference was accepted")
	check(str(case_ui.get("evidence").text).contains("Nessuna"), "unsupported inference lacks feedback")
	press("Btn_Seat_Continue")
	check(str(case_ui.get("mode")) == "inquiry" and int(save.get_seat_inquiry().seen) == 3, "reread did not restore both traces")
	press("Btn_Seat_Continue")
	press("Btn_Seat_Reserve")
	check(bool(save.get_seat_inquiry().complete), "supported conclusion was not recorded")
	press("Btn_Seat_Continue")
	check(not case_ui.visible and save.get_ledger_denari() == 4, "conclusion changed the account or failed to close")
	save.set("_profile_loaded", false)
	save.load_profile()
	check(bool(save.get_seat_inquiry().complete) and manager.get_seat_inquiry().is_empty(), "completed inquiry repeated after reload")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	menu.call("_build_museo_list")
	var remembered := false
	for label: Label in menu.get("museo_vbox").find_children("*", "Label", true, false):
		if label.text == "La copia è incompleta; il nome di chi sedeva non è provato.":
			remembered = true
	check(remembered, "Archive lacks the conclusion")
	# Independent fixture for the testimony route and its distinct second trace.
	var meta: Dictionary = save.get("_meta")
	meta["seat_case"] = {"choice": "witness", "era": 1}
	meta["seat_inquiry"] = {"seen": 0, "complete": false}
	case_ui.call("try_open")
	check(case_ui.visible and str(case_ui.find_child("Btn_Seat_Witness", true, false).text).contains("VOCE"), "testimony route lost its voice trace")
	press("Btn_Seat_Witness")
	press("Btn_Seat_Reserve")
	check(int(save.get_seat_inquiry().seen) == 3, "reverse inspection order failed")
	press("Btn_Seat_Continue")
	press("Btn_Seat_Reserve")
	check(bool(save.get_seat_inquiry().complete), "testimony conclusion failed")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("SEAT_INQUIRY_RUNTIME_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if failures.is_empty() else 1)
