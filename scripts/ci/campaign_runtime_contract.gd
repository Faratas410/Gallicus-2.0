extends SceneTree

# Real UI journey: only clocks and initial RNG seeds are controlled. No run
# histories, campaign counters, outcomes or offered pacts are injected.
const Catalog = preload("res://scripts/content/bet_catalog.gd")
const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var scene: Node
var manager: Node
var rows: Array[Dictionary] = []
var closed: bool = false
var reason: String = ""
var failed: bool = false
var resumed: Dictionary = {}
var finale_id: String = ""
var capture_dir: String = ""
var captured: Dictionary = {}
var catalog_scars_applied: int = 0
var dialogues_seen: Dictionary = {}
var seat_case_deferrals: int = 0
var seat_case_testified: bool = false
var seat_inquiry_completed: bool = false
var seat_copy_completed: bool = false
var seat_copy_paid: bool = false
var final_sheets: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _press(name: String) -> bool:
	var button: Button = scene.find_child(name, true, false) as Button
	if button == null or not button.is_visible_in_tree() or button.disabled:
		return false
	button.pressed.emit()
	return true

func _boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	await create_timer(0.5).timeout

func _ended(value: String, _summary: Dictionary) -> void:
	closed = true
	reason = value

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			capture_dir = argument.trim_prefix("--capture-dir=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
		elif argument == "--copy-paid":
			seat_copy_paid = true
	Engine.time_scale = 12.0
	root.get_node("GameEvents").run_ended.connect(_ended)
	root.get_node("GameEvents").scar_applied.connect(func(scar: Dictionary) -> void:
		if not ScarCatalog.new().get_scar(StringName(str(scar.get("id", "")))).is_empty():
			catalog_scars_applied += 1
	)
	root.get_node("GameEvents").run_finale_selected.connect(func(payload: Dictionary) -> void: finale_id = str(payload.get("ending_id", "")))
	await _boot()
	if OS.get_cmdline_user_args().has("--verify-terminal"):
		var persisted: Node = root.get_node("SaveManager")
		var snapshot: Dictionary = persisted.get_registry_evolution()
		if persisted.get_registry_era() != 4 or manager.get("_register_state") != null or persisted.has_run_save():
			_fail("fresh process did not restore terminal profile exclusively")
		manager.request_new_game()
		manager.request_load_continue()
		if persisted.get_registry_evolution() != snapshot: _fail("fresh process changed terminal state")
		scene.queue_free()
		await create_timer(3.0).timeout
		if not failed: print("CAMPAIGN_TERMINAL_REBOOT_OK")
		await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
		quit(1 if failed else 0)
		return
	await _capture("00_menu")
	var save: Node = root.get_node("SaveManager")
	for index: int in range(400):
		closed = false
		finale_id = ""
		var era_before: int = save.get_registry_era()
		var samples_before: int = int(save.get_registry_evolution().samples)
		OS.set_environment("GALLICUS_SMOKE", "1")
		OS.set_environment("GALLICUS_SMOKE_SEED", str(1782373819 + index * 7919))
		if not _press("NewGameButton"):
			_fail("new game unavailable")
			break
		OS.unset_environment("GALLICUS_SMOKE")
		OS.unset_environment("GALLICUS_SMOKE_SEED")
		Engine.time_scale = 12.0
		var deadline: int = Time.get_ticks_msec() + 15000
		while not closed and Time.get_ticks_msec() < deadline:
			await create_timer(0.6).timeout
			var run: RunState = manager.get("_run_state")
			var step: String = str(run.run_save_flow_step)
			var conversation: Node = scene.get_node("OpeningPrologue")
			if conversation.get("_active"):
				var dialogue_id: String = str(conversation.get("_payload").id)
				if not dialogues_seen.has(dialogue_id):
					dialogues_seen[dialogue_id] = index + 1
					await _capture("dialogue_" + dialogue_id)
				elif int(dialogues_seen[dialogue_id]) != index + 1:
					_fail("completed campaign dialogue repeated: " + dialogue_id)
				_press("AdvanceDialogue")
				continue
			var case_ui: Node = conversation.get_node("SeatCase")
			if bool(case_ui.get("active")) and str(case_ui.get("mode")) in ["ledger", "final_copy"]:
				# The last Era's sheets have no deferral: take the first offered choice.
				var final_mode: String = str(case_ui.get("mode"))
				if not (_press("Btn_Seat_Witness") or _press("Btn_Seat_Reserve") or _press("Btn_Seat_Defer")):
					_fail("last Era sheet without a choice: " + final_mode)
				final_sheets[final_mode] = index + 1
				continue
			if bool(case_ui.get("active")) and str(case_ui.get("mode")) == "copy":
				if seat_copy_paid and not _available("Btn_Seat_Reserve"):
					_press("Btn_Seat_Defer")
				else:
					_press("Btn_Seat_Reserve" if seat_copy_paid else "Btn_Seat_Witness")
					seat_copy_completed = save.get_seat_copy() == ("copy" if seat_copy_paid else "keep")
					if seat_copy_paid and seat_copy_completed and int(manager.call("_banco_price", "insure")) != 4 + save.get_registry_era():
						_fail("paid copy did not discount the policy")
				continue
			if bool(case_ui.get("active")) and str(case_ui.get("mode")) == "inquiry":
				var evidence_seen: int = int(case_ui.get("inquiry").get("seen", 0))
				if (evidence_seen & 1) == 0:
					_press("Btn_Seat_Reserve")
				elif (evidence_seen & 2) == 0:
					_press("Btn_Seat_Witness")
				else:
					_press("Btn_Seat_Continue")
				continue
			if bool(case_ui.get("active")) and str(case_ui.get("mode")) == "question":
				_press("Btn_Seat_Reserve")
				seat_inquiry_completed = bool(save.get_seat_inquiry().complete)
				continue
			if seat_case_deferrals > 0 and not seat_case_testified and _press("Btn_Seat_Witness"):
				seat_case_testified = true
				continue
			if _press("Btn_Seat_Defer"):
				seat_case_deferrals += 1
				continue
			if _press("Btn_Seat_Continue"):
				continue
			if index == 4 and step in ["BET_OFFER", "BET_SIGNED", "INTERMEDIATE_CHOICE", "PUSH_LUCK"] and not resumed.has(step):
				var before: Dictionary = run.to_dict()
				root.get_node("GameEvents").request_show_main_menu.emit()
				scene.queue_free()
				await create_timer(1.0).timeout
				await _boot()
				if not _press("ContinueButton"):
					_fail("resume unavailable at " + step)
					break
				Engine.time_scale = 12.0
				await create_timer(0.3).timeout
				var restored: RunState = manager.get("_run_state")
				var after: Dictionary = restored.to_dict()
				for key: String in ["run_seed", "glory", "corruption", "arena_index", "scars_history", "scar_rng_state", "scar_roll_index", "bets_history", "push_luck_doubles"]:
					if before.get(key) != after.get(key):
						_fail("resume changed " + key + " at " + step)
				resumed[step] = true
				continue
			if _press("SkipPrologue") or _press("Btn_Open_Book"):
				continue
			var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
			if _available("Btn_Sign_Left") or _available("Btn_Sign_Right"):
				await _capture("registry_%d_ramp_%d" % [save.get_registry_era(), int(save.get_registry_evolution().ramp_runs)])
				var best: int = -1
				var score: int = -999
				var seen: Array = save.get_registry_evolution().get("paths_seen", [])
				for side: int in range(2):
					var id: String = circle.call("_offer_id_at", side)
					var path: String = str(Catalog.get_path_tag_for_bet_id(StringName(id))).trim_prefix("PATH_").to_lower()
					var weight: int = 10 if path in ["hubris", "violence"] else 0
					if seen.size() < 3 and not seen.has(path): weight += 20
					if weight > score:
						score = weight
						best = side
				_press("Btn_Sign_Left" if best == 0 else "Btn_Sign_Right")
				continue
			# A held seal asks again: strike once more while the posta is thin,
			# otherwise raise the hand and keep what the wax has held.
			if _available("Btn_RESOLUTION_NEXT"):
				var held_run: RunState = manager.get("_run_state")
				if held_run.stake_glory < 6 and int(manager.get("_seal_strike_count")) < 2 and _press("Btn_RESOLUTION_STRIKE"):
					continue
				_press("Btn_RESOLUTION_NEXT")
				continue
			if _press("Btn_FIRST_REACTION_NEXT") or _press("Btn_MID_CHOICE_SELECT_0") or _press("Btn_RESOLUTION_STRIKE"):
				continue
			# Real percorsi: rilancia until the third arena, then take the
			# quietanza; the marchio is pressed only when the quietanza is blocked.
			var live: RunState = manager.get("_run_state")
			if live.arena_index < 3 and _press("Btn_PUSH_YOUR_LUCK_DOUBLE"):
				continue
			if not _press("Btn_PUSH_YOUR_LUCK_CASHOUT"):
				if not _press("Btn_PUSH_YOUR_LUCK_DOUBLE"):
					_press("Btn_PUSH_YOUR_LUCK_CONDANNA")
		if failed: break
		if not closed:
			_fail("journey stalled at " + str(manager.get("_phase")))
			break
		var state: Dictionary = save.get_registry_evolution()
		var counted: bool = int(state.samples) != samples_before
		if counted and reason not in ["REGISTRY_SILENCE", "REGISTRY_ABSENCE"] and finale_id != str(state.last_class):
			_fail("campaign classified a different ending from the dossier")
		rows.append({"run":index + 1, "reason":reason, "era":save.get_registry_era(), "evolution":state})
		print("CAMPAIGN_RUN ", JSON.stringify(rows.back()))
		if save.get_registry_era() == 4:
			break
		if save.get_registry_era() != era_before:
			await create_timer(2.2).timeout
			await _capture("silence_%d" % save.get_registry_era())
			if not _press("ReturnToMenu"): _fail("Silence has no return")
		else:
			if not _press("Btn_END_RUN_QUIT"): _fail("dossier has no menu route")
		await create_timer(0.5).timeout
	if save.get_registry_era() != 4: _fail("natural UI campaign did not reach Absence")
	if resumed.size() != 4: _fail("missing checkpoint resumes: " + str(resumed))
	if catalog_scars_applied == 0: _fail("natural losses produced no catalog scars")
	for stage: String in ["entry", "middle", "departure"]:
		if not dialogues_seen.has(stage): _fail("missing illustrated campaign stage: " + stage)
	# Racconti are the prize of closed bandi: heard in ladder order, never after the farewell.
	# The empty-seat racconti come with their Era too: all of them precede the farewell.
	var previous_run: int = int(dialogues_seen.get("entry", 0))
	var gap: bool = false
	var departure_run: int = int(dialogues_seen.get("departure", 9999))
	for tale: Dictionary in Dialogues.TALES:
		var tale_id: String = str(tale.id)
		if not dialogues_seen.has(tale_id):
			if tale.has("era"):
				_fail("the farewell came without the empty seat: " + tale_id)
			gap = true
			continue
		var heard: int = int(dialogues_seen[tale_id])
		if heard <= int(dialogues_seen.get("entry", 0)) or heard > departure_run:
			_fail("racconto outside the campaign: " + str(dialogues_seen))
		if tale.has("era"):
			continue
		if gap or heard <= previous_run:
			_fail("racconti out of ladder order: " + str(dialogues_seen))
		previous_run = heard
	check_seat_case_reached()
	check_final_era_dismantled(save)
	print("CAMPAIGN_DIALOGUES=", JSON.stringify(dialogues_seen), " BANDO_STEP=", save.get_bando_step())
	if save.get_registry_era() == 4:
		var terminal: Node = scene.get_node("UI/RegistryTerminalView")
		await create_timer(2.5).timeout
		await _capture("departure")
		await create_timer(6.5).timeout
		await _capture("absence")
		if terminal.get("_departure").visible or not terminal.get("_exit_button").visible:
			_fail("epilogue did not finish with an exit utility")
		var terminal_state: Dictionary = save.get_registry_evolution()
		manager.request_new_game()
		manager.request_load_continue()
		if save.get_registry_evolution() != terminal_state: _fail("terminal requests changed campaign")
		scene.queue_free()
		await create_timer(3.0).timeout
		await _boot()
		if manager.get("_register_state") != null: _fail("terminal reboot initialized classification")
		if scene.get_node("UI/RegistryTerminalView").get("_departure").visible: _fail("terminal reboot replayed departure")
		await _capture("terminal_reboot")
	var report: FileAccess = FileAccess.open("user://campaign_journey.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"runs":rows,"resumed":resumed,"catalog_scars_applied":catalog_scars_applied,"failed":failed}, "\t"))
	report.close()
	scene.queue_free()
	await create_timer(3.0).timeout
	if not failed: print("CAMPAIGN_RUNTIME_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(1 if failed else 0)

func _available(name: String) -> bool:
	var button: Button = scene.find_child(name, true, false) as Button
	return button != null and button.is_visible_in_tree() and not button.disabled

func check_final_era_dismantled(save: Node) -> void:
	# One piece per percorso, in order, and the farewell last, all before Absence.
	var previous: int = 0
	for scene_id: String in ["final_ledger", "final_bando", "final_copy", "departure"]:
		var heard: int = int(dialogues_seen.get(scene_id, 0))
		if heard <= previous:
			_fail("last Era out of order: " + str(dialogues_seen))
		previous = heard
	if final_sheets.get("ledger", 0) != dialogues_seen.get("final_ledger", -1) or final_sheets.get("final_copy", 0) != dialogues_seen.get("final_copy", -1):
		_fail("last Era sheets did not follow their scenes: " + str(final_sheets))
	var record: Dictionary = save.get_final_era()
	if str(record.ledger) == "" or str(record.copy) == "" or str(record.bando) not in ["closed", "missed"] or (record.strophe as Array).size() != 3:
		_fail("last Era not recorded: " + str(record))
	print("CAMPAIGN_FINAL_ERA=", JSON.stringify({"dialogues": dialogues_seen, "record": record}))

func check_seat_case_reached() -> void:
	if seat_case_deferrals == 0:
		_fail("the seat case never appeared in the campaign")
	if not seat_case_testified or not dialogues_seen.has("seat_witness_followup"):
		_fail("the testimony follow-up never appeared in the campaign")
	if not seat_inquiry_completed:
		_fail("the seat inquiry was not completed in the campaign")
	if not seat_copy_completed:
		_fail("the copy decision was not completed in the campaign")
	var expected_copy: String = "seat_copy_for_nerio" if seat_copy_paid else "seat_copy_for_dima"
	var wrong_copy: String = "seat_copy_for_dima" if seat_copy_paid else "seat_copy_for_nerio"
	if not dialogues_seen.has(expected_copy) or dialogues_seen.has(wrong_copy):
		_fail("the copy choice did not produce its own response")
	if not dialogues_seen.has("seat_voice_after_inquiry") or dialogues_seen.has("seat_receipt_after_inquiry"):
		_fail("the testimony inquiry did not produce its own response")
	print("CAMPAIGN_SEAT_CASE_DEFERRALS=", seat_case_deferrals)

func _fail(message: String) -> void:
	failed = true
	push_error("CAMPAIGN_CONTRACT: " + message)

func _capture(label: String) -> void:
	if capture_dir == "" or captured.has(label): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label + ".png"))
	captured[label] = true
