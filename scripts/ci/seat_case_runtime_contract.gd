extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error("SEAT_CASE: " + message)

func _run() -> void:
	var save := root.get_node("SaveManager")
	var legacy := RunState.new()
	legacy.from_dict({})
	check(not legacy.seat_case_deferred and str(save.get_seat_case().choice) == "", "legacy defaults must leave the case open")
	var isolated_save: Node = load("res://scripts/systems/save_manager.gd").new()
	isolated_save.set("_profile_loaded", true)
	isolated_save.call("_load_meta_from_profile", {"meta": {"seat_case": {"choice": "witness", "era": []}}})
	check(str(isolated_save.get_seat_case().choice) == "", "malformed case data must fall back safely")
	isolated_save.free()
	save.mark_campaign_dialogue_seen("entry")
	save.mark_campaign_dialogue_seen("seat_kept")
	save.commit_registry_evolution(0.0, 1, {})
	save.set_ledger_denari(-5)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	var manager: Node = scene.get_node("RunManager")
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(1.0).timeout
	var dialogue: Node = scene.get_node("OpeningPrologue")
	if bool(dialogue.get("_active")):
		dialogue.call("_finish")
	await process_frame
	var case_ui: Control = dialogue.get_node("SeatCase")
	check(case_ui.visible, "case did not open after the dialogue")
	var reserve: Button = case_ui.find_child("Btn_Seat_Reserve", true, false)
	var witness: Button = case_ui.find_child("Btn_Seat_Witness", true, false)
	check(reserve.disabled and not witness.disabled, "debt must leave testimony available")
	check(witness.has_focus(), "testimony must receive initial keyboard focus")
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	root.push_input(tab, true)
	tab = InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = false
	root.push_input(tab, true)
	await process_frame
	check(case_ui.find_child("Btn_Seat_Defer", true, false).has_focus(), "focus escaped the case in debt")
	var defer_key := InputEventKey.new()
	defer_key.keycode = KEY_ENTER
	defer_key.pressed = true
	root.push_input(defer_key, true)
	defer_key = InputEventKey.new()
	defer_key.keycode = KEY_ENTER
	defer_key.pressed = false
	root.push_input(defer_key, true)
	await process_frame
	check(not case_ui.visible and str(save.get_seat_case().choice) == "", "deferral must keep case unresolved")
	var deferred: RunState = manager.get("_run_state")
	var restored := RunState.new()
	restored.from_dict(deferred.to_dict())
	var disk_save: Dictionary = manager.get("_save_system").load_run()
	check(restored.seat_case_deferred and not disk_save.is_empty() and bool(disk_save.state.seat_case_deferred) and manager.get_seat_case().is_empty(), "deferral was not retained in the run checkpoint")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	await create_timer(0.5).timeout
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	dialogue = scene.get_node("OpeningPrologue")
	case_ui = dialogue.get_node("SeatCase")
	reserve = case_ui.find_child("Btn_Seat_Reserve", true, false)
	witness = case_ui.find_child("Btn_Seat_Witness", true, false)
	deferred = manager.get("_run_state")
	check(deferred.seat_case_deferred and not case_ui.visible, "same-run continue reopened deferred case")
	deferred.seat_case_deferred = false # Simulate the next percorso in this isolated fixture.
	case_ui.call("try_open")
	var key := InputEventKey.new()
	key.keycode = KEY_ENTER
	key.pressed = true
	root.push_input(key, true)
	key = InputEventKey.new()
	key.keycode = KEY_ENTER
	key.pressed = false
	root.push_input(key, true)
	await process_frame
	check(str(save.get_seat_case().choice) == "witness" and save.get_ledger_denari() == -5, "testimony did not persist without a charge")
	case_ui.find_child("Btn_Seat_Continue", true, false).pressed.emit()
	check(not case_ui.visible, "acknowledgement did not return to the rite")
	await create_timer(0.7).timeout
	check(bool(dialogue.get("_active")) and str(dialogue.get("_payload").get("id", "")) == "seat_witness_followup", "testimony follow-up did not open")
	dialogue.call("_finish")
	await process_frame
	check(save.has_seen_campaign_dialogue("seat_witness_followup"), "testimony follow-up was not recorded")
	check(str(manager.get_campaign_dialogue().get("id", "")) != "seat_witness_followup", "completed testimony follow-up repeated")
	var run: RunState = manager.get("_run_state")
	run.escalation_level = 0
	manager.call("_open_ledger_for_run")
	check(run.escalation_level == 2, "testimony and debt must each add one pressure on a later run")
	manager.set("_registry_era", 2)
	run.escalation_level = 0
	manager.call("_open_ledger_for_run")
	check(run.escalation_level == 1, "testimony pressure must end after the next Silence")
	# Reset only the isolated fixture profile to exercise the paid branch.
	var meta: Dictionary = save.get("_meta")
	meta["seat_case"] = {"choice": "", "era": -1}
	save.set_ledger_denari(10)
	manager.set("_registry_era", 1)
	case_ui.call("try_open")
	check(not reserve.disabled, "affordable reservation was disabled")
	reserve.pressed.emit()
	check(save.get_ledger_denari() == 4 and str(save.get_seat_case().choice) == "reserve", "reservation did not commit choice and price")
	root.get_node("GameEvents").request_seat_case_choice.emit("reserve")
	check(save.get_ledger_denari() == 4, "repeated request charged twice")
	# Restart before acknowledging the paid choice: the saved follow-up must
	# still open and the account must not be charged again.
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(0.5).timeout
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	await create_timer(0.5).timeout
	scene.find_child("ContinueButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	dialogue = scene.get_node("OpeningPrologue")
	check(bool(dialogue.get("_active")) and str(dialogue.get("_payload").get("id", "")) == "seat_reserved_followup", "reservation follow-up did not open")
	check(save.get_ledger_denari() == 4, "resume charged the reservation again")
	dialogue.call("_finish")
	await process_frame
	check(save.has_seen_campaign_dialogue("seat_reserved_followup"), "reservation follow-up was not recorded")
	check(str(manager.get_campaign_dialogue().get("id", "")) != "seat_reserved_followup", "completed reservation follow-up repeated")
	save.set("_profile_loaded", false)
	save.load_profile()
	check(save.get_ledger_denari() == 4 and str(save.get_seat_case().choice) == "reserve", "profile reload lost transaction")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	menu.call("_build_museo_list")
	var remembered := false
	for label: Label in menu.get("museo_vbox").find_children("*", "Label", true, false):
		if label.text == tr("Il posto e' stato riservato con il conto di Vessa."):
			remembered = true
	check(remembered, "Archive did not show the saved reservation")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("SEAT_CASE_RUNTIME_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if failures.is_empty() else 1)
