extends SceneTree

# Real UI journey: only clocks and initial RNG seeds are controlled. No run
# histories, campaign counters, outcomes or offered pacts are injected.
const Catalog = preload("res://scripts/content/bet_catalog.gd")
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
		quit(1 if failed else 0)
		return
	await _capture("00_menu")
	var save: Node = root.get_node("SaveManager")
	for index: int in range(400):
		closed = false
		finale_id = ""
		var era_before: int = save.get_registry_era()
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
			if _press("Btn_FIRST_REACTION_NEXT") or _press("Btn_MID_CHOICE_SELECT_0") or _press("Btn_RESOLUTION_STRIKE"):
				continue
			if not _press("Btn_PUSH_YOUR_LUCK_CONDANNA"):
				if not _press("Btn_PUSH_YOUR_LUCK_CASHOUT"):
					_press("Btn_PUSH_YOUR_LUCK_DOUBLE")
		if failed: break
		if not closed:
			_fail("journey stalled at " + str(manager.get("_phase")))
			break
		var state: Dictionary = save.get_registry_evolution()
		if reason not in ["REGISTRY_SILENCE", "REGISTRY_ABSENCE"] and finale_id != str(state.last_class):
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
	quit(1 if failed else 0)

func _available(name: String) -> bool:
	var button: Button = scene.find_child(name, true, false) as Button
	return button != null and button.is_visible_in_tree() and not button.disabled

func _fail(message: String) -> void:
	failed = true
	push_error("CAMPAIGN_CONTRACT: " + message)

func _capture(label: String) -> void:
	if capture_dir == "" or captured.has(label): return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_dir.path_join(label + ".png"))
	captured[label] = true
