extends SceneTree

const Evolution = preload("res://scripts/systems/run/registry_evolution.gd")
const Builder = preload("res://scripts/systems/run/finale_builder.gd")
const Catalog = preload("res://scripts/content/bet_catalog.gd")
const Rules = preload("res://data/ending_rules.gd")
const SaveScript = preload("res://scripts/systems/save_manager.gd")
var _failed: bool = false

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error("AUDIT_CONTRACT: " + message)

func _run() -> void:
	_check_endings()
	_check_evolution()
	_check_migration()
	_check_scar_rng_roundtrip()
	_check_scar_consequences()
	await _check_terminal()
	if not _failed:
		print("AUDIT_RUNTIME_CONTRACT_OK")
	quit(1 if _failed else 0)

func _check_endings() -> void:
	var builder = Builder.new()
	var history: Array[StringName] = Catalog.level3_active_bet_ids()
	var trace: Dictionary = builder.build_path_trace_from_bet_history(history)
	_expect(int(trace.path_unknown_count) == 0, "active paths must preserve identity")
	_expect(int(trace.path_violence_count) == 3 and int(trace.path_penitence_count) == 2, "violence/penitence lost")
	history.append(&"UNKNOWN_TEST_BET")
	_expect(int(builder.build_path_trace_from_bet_history(history).path_unknown_count) == 1, "unknown path fallback lost")
	# Independent witness states for every declared rule, including morale fallbacks.
	var cases: Array[Dictionary] = [
		{"id":"PATH_MARTYR_01", "trace":{"double_count":4,"condanna_registry_count":2}},
		{"id":"PATH_HUBRIS_01", "corruption":7, "trace":{"double_count":3}},
		{"id":"PATH_FALL_01", "corruption":5, "trace":{"path_violence_count":3}},
		{"id":"PATH_DEBT_01", "trace":{"path_prudence_count":3}},
		{"id":"PATH_GLORY_01", "glory":8, "trace":{"path_hubris_count":2}},
		{"id":"PATH_PET_01", "trace":{"cashout_count":1}},
		{"id":"PATH_MARKED_01", "trace":{"condanna_registry_count":1}},
		{"id":"PATH_BROKEN_01", "corruption":5, "trace":{"condanna_registry_count":2}},
		{"id":"PATH_SURVIVOR_01", "trace":{}},
		{"id":"PATH_PROVOKE_01", "trace":{"double_count":2,"provoke_armed":true}},
		{"id":"MORALE_PURE_HIGH", "glory":8, "trace":{"condanna_registry_count":2}},
		{"id":"MORALE_DAMNED_ANY", "corruption":10, "trace":{}},
		{"id":"MORALE_CORRUPT_LOW", "corruption":8, "trace":{}},
		{"id":"MORALE_TAINTED_MID", "corruption":5, "glory":5, "trace":{}},
	]
	var covered: Array[String] = []
	for case: Dictionary in cases:
		var state := RunState.new()
		state.glory = int(case.get("glory", 0))
		state.corruption = int(case.get("corruption", 0))
		var selected: Dictionary = builder.select_level3_ending_key(state, case.trace)
		_expect(str(selected.get("id", "")) == str(case.id), "unreachable ending rule " + str(case.id))
		covered.append(str(case.id))
	for rule: Dictionary in Rules.dominant_rules() + Rules.morale_fallback_rules():
		_expect(covered.has(str(rule.id)), "new rule lacks behavioral witness: " + str(rule.id))
	var borderline := RunState.new()
	borderline.corruption = 4
	_expect(builder.select_level3_ending_key(borderline, {"condanna_registry_count":2}).is_empty(), "broken threshold accepted corruption below 5")

func _sample(index: int, diverse: bool = true) -> Dictionary:
	return {"choices":4, "signature":{"risk_bias":1.0,"repetition_bias":1.0,"scar_tolerance":0.6,"volatility":0.0}, "paths":[["hubris","violence","penitence"][index % 3]] if diverse else ["hubris"], "observation":str(index % 3) if diverse else "same", "classification":"THE_BROKEN"}

func _check_scar_rng_roundtrip() -> void:
	for initial: int in [9223372036854775806, -9223372036854775807, 12345]:
		var state := RunState.new()
		state.scar_rng_state = initial
		state.scar_roll_index = 27
		var loaded := RunState.new()
		loaded.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
		_expect(loaded.scar_rng_state == initial and loaded.scar_roll_index == 27, "64-bit scar RNG lost precision in JSON")
		var uninterrupted := RandomNumberGenerator.new()
		var resumed_rng := RandomNumberGenerator.new()
		uninterrupted.state = state.scar_rng_state
		resumed_rng.state = loaded.scar_rng_state
		for draw: int in range(16):
			_expect(uninterrupted.randi() == resumed_rng.randi(), "scar sequence changed after JSON reload")
	var legacy := RunState.new()
	legacy.from_dict({"scar_rng_state":12345})
	_expect(legacy.scar_rng_state == 12345, "legacy numeric RNG save rejected")

func _check_scar_consequences() -> void:
	var outcome := RunOutcomeSystem.new()
	var scars := ScarCatalog.new()
	for behavior: StringName in [&"CASH_OUT", &"DEBT_CHAIN", &"BLOOD_TAX", &"CROW_PLEASER", &"LAST_BREATH"]:
		var consequence: Dictionary = outcome.build_level3_loss_consequence(behavior, behavior, &"", false, 0, 0)
		_expect(not scars.get_scar(consequence.scar_id).is_empty(), "promised loss scar is absent from catalog: " + str(behavior))
	var rng := RandomNumberGenerator.new()
	var no_scars: Array[StringName] = []
	var profiles: Array[Dictionary] = []
	var base: Dictionary = outcome.resolve_level3_arena(rng, 42, 0, no_scars, &"", profiles)
	for scar: Dictionary in scars.list_scars():
		var active: Array[StringName] = [scar.id]
		var affected: Dictionary = outcome.resolve_level3_arena(rng, 42, 0, active, &"", profiles)
		_expect(float(affected.failure_chance) > float(base.failure_chance), "active scar has no promised adverse effect: " + str(scar.id))

func _check_evolution() -> void:
	var malformed: Dictionary = Evolution.sanitize({"signature":{"risk_bias":{},"volatility":NAN},"samples":[],"ramp_runs":INF})
	_expect(malformed.signature.risk_bias == 0.0 and malformed.signature.volatility == 0.0 and malformed.samples == 0, "malformed evolution values must recover safely")
	var state: Dictionary = Evolution.defaults()
	var first: Dictionary = Evolution.advance(state, 0, _sample(0))
	_expect(not bool(first.state.fixed), "signature fixed after a single run")
	var second: Dictionary = Evolution.advance(first.state, 0, _sample(1))
	_expect(bool(second.state.fixed), "two coherent runs must fix signature")
	var reversal: Dictionary = _sample(2)
	reversal.signature = {"risk_bias":-1.0,"repetition_bias":0.0,"scar_tolerance":0.0,"volatility":1.0}
	var resisted: Dictionary = Evolution.advance(second.state, 0, reversal)
	_expect(bool(resisted.state.fixed) and float(resisted.state.signature.risk_bias) > 0.7, "fixed signature must resist immediate reversal")
	# A constant strategy never settles the signature; it only closes the Era by
	# exhaustion once the evidence ceiling is reached (loop review, October 2026).
	for index: int in range(Evolution.ERA_EVIDENCE_CEILING - 1):
		var constant: Dictionary = Evolution.advance(state, 0, _sample(index, false))
		_expect(not bool(constant.silence), "constant strategy alone advanced the era")
		state = constant.state
	_expect(int(state.era_runs) == Evolution.ERA_EVIDENCE_CEILING - 1, "constant strategy lost evidence")
	var exhausted: Dictionary = Evolution.advance(state, 0, _sample(Evolution.ERA_EVIDENCE_CEILING, false))
	_expect(bool(exhausted.silence) and int(exhausted.era) == 1, "evidence ceiling did not close the era")
	state = Evolution.defaults()
	var era: int = 0
	state = Evolution.defaults()
	var transitions: int = 0
	for index: int in range(80):
		var result: Dictionary = Evolution.advance(state, era, _sample(index))
		if bool(result.silence):
			_expect(int(result.era) == era + 1 and int(result.state.ramp_runs) == 0, "Silence must advance exactly one era and reset ramp")
			transitions += 1
		era = int(result.era)
		state = result.state
		# JSON round-trip models closing and reopening the application between runs.
		state = Evolution.sanitize(JSON.parse_string(JSON.stringify(state)))
		if era == 4:
			break
	_expect(era == 4 and transitions == 4, "accelerated campaign cannot reach Absence")
	var terminal: Dictionary = Evolution.advance(state, 4, _sample(99))
	_expect(not bool(terminal.silence) and terminal.state == state, "Absence must stop classification")
	var empty: Dictionary = Evolution.advance(state, 0, {"choices":0})
	_expect(empty.state == state and not bool(empty.silence), "aborted/empty runs must not progress")

func _check_migration() -> void:
	var file := FileAccess.open("user://profile.save", FileAccess.WRITE)
	file.store_string(JSON.stringify({"version":4,"unlocked_ids":["AUDIT_UNLOCK"],"settings":{"language":"es","sfx_volume":0.42,"reduced_motion":true},"meta":{"registry_pressure":12.0,"registry_era":0}}))
	file.close()
	var migrated: Node = SaveScript.new()
	migrated.load_profile()
	_expect(migrated.get_language() == "es" and is_equal_approx(migrated.get_sfx_volume(), 0.42) and migrated.get_reduced_motion(), "v4->v5 lost settings")
	_expect(migrated.has_unlocked(&"AUDIT_UNLOCK") and migrated.get_registry_pressure() == 12.0, "v4->v5 lost history")
	_expect(migrated.get_registry_evolution() == Evolution.defaults(), "v4->v5 campaign defaults invalid")
	migrated.free()
	var persisted: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("user://profile.save"))
	_expect(int(persisted.version) == 5, "v5 migration was not written to disk")
	root.get_node("SaveManager").set("_profile_loaded", false)
	root.get_node("SaveManager").load_profile()

func _check_terminal() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.3).timeout
	var manager: Node = scene.get_node("RunManager")
	await _check_contract_readability(scene)
	await _check_offer_publication(scene)
	await _check_bet_commit_flow(scene)
	await _check_menu_continue(scene)
	_check_applied_loss_scars(scene.get_node("RunManager"))
	var save: Node = root.get_node("SaveManager")
	var events: Node = root.get_node("GameEvents")
	var ended: Array = []
	events.run_ended.connect(func(reason: String, summary: Dictionary): ended.append({"reason":reason,"summary":summary}))
	manager.request_new_game()
	await create_timer(0.1).timeout
	var phase_before: int = int(manager.get("_phase"))
	events.settings_changed.emit({"language":"en","sfx_volume":0.5})
	await create_timer(0.1).timeout
	_expect(int(manager.get("_phase")) == phase_before, "changing settings rebooted the active run")
	# A percorso closed after one response is not evidence for the Registry.
	var quick := RunState.new()
	quick.bets_history.assign([Catalog.BET_P3_CROWD_FEAST])
	quick.arena_index = 1
	quick.arenas_cleared = 1
	quick.risky_decisions = 2
	quick.run_end_reason = "CONDANNA"
	var evolution_before: Dictionary = save.get_registry_evolution()
	manager.set("_run_state", quick)
	manager.set("_registry_meta_committed_this_run", false)
	manager.call("_update_registry_meta_from_run")
	_expect(save.get_registry_evolution() == evolution_before, "a one-response percorso advanced the campaign")
	# Use real catalog histories through the authoritative sample construction.
	var silences: int = 0
	for index: int in range(100):
		var run := RunState.new()
		run.bets_history.assign([Catalog.BET_P3_CROWD_FEAST, Catalog.BET_P3_CROWD_FEAST, Catalog.BET_P3_LIE_APPLAUSE, Catalog.BET_P3_CROWD_FEAST, Catalog.BET_P3_LIE_APPLAUSE] if index < 2 else [Catalog.BET_P3_CROWD_FEAST, Catalog.BET_P3_CROWD_FEAST, Catalog.BET_P3_LIE_APPLAUSE, Catalog.BET_P3_BLOOD_LEDGER, Catalog.BET_P3_CHAIN_OATH])
		run.scars_history.assign([&"DEBT_BRAND", &"CRACKED_BONES"])
		run.condanne_this_run.assign([&"CONDANNA_FIRMATO", &"CONDANNA_RICORDATO"])
		run.arena_index = 5
		run.arenas_cleared = 5
		run.risky_decisions = 4
		run.safe_decisions = 1
		run.glory = 8 + index % 3
		run.corruption = 8
		run.run_end_reason = "CONDANNA"
		manager.set("_run_state", run)
		manager.set("_registry_meta_committed_this_run", false)
		manager.call("_update_registry_meta_from_run")
		var saved: Dictionary = save.get_registry_evolution()
		manager.call("_update_registry_meta_from_run")
		_expect(saved == save.get_registry_evolution(), "closing one run twice advanced campaign twice")
		_expect(run.glory == 8 + index % 3 and run.corruption == 8, "campaign changed rewards or corruption")
		if run.registry_silence_active:
			silences += 1
			manager.set("_run_ended_emitted", false)
			manager.call("_emit_run_ended")
			_expect(not ended.back().summary.get("classified_terminal", true), "Silence classified the player")
			_expect(ended.back().reason == ("REGISTRY_ABSENCE" if silences == 4 else "REGISTRY_SILENCE"), "Silence emitted a failure reason")
		if int(save.get_registry_era()) == 4:
			break
	_expect(silences == 4, "real catalog histories cannot reach Absence")
	ended.clear()
	var before: int = int(manager.get("_run_counter"))
	manager.request_new_game()
	_expect(int(manager.get("_run_counter")) == before, "terminal profile started a new run")
	manager.request_load_continue()
	_expect(ended.size() == 2 and ended[0].reason == "REGISTRY_ABSENCE", "terminal new/continue must emit Absence")
	_expect(not bool(ended[0].summary.get("classified_terminal", true)), "Absence emitted classification")
	await process_frame
	var surface: Control = scene.get_node("UI/RegistryTerminalView/SilenceSurface")
	_expect(surface.visible and not surface.get_node("ReturnToMenu").visible, "terminal must render black with no restart")
	save.load_profile()
	var reloaded: Node = SaveScript.new()
	reloaded.load_profile()
	_expect(int(reloaded.get_registry_era()) == 4, "terminal profile did not survive disk reload")
	reloaded.set_registry_state(0.0, 0)
	_expect(int(reloaded.get_registry_era()) == 4, "terminal profile reset to era zero")
	reloaded.free()
	scene.queue_free()
	await create_timer(0.3).timeout
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.3).timeout
	_expect(scene.get_node("RunManager").get("_register_state") == null, "terminal boot initialized classification")
	_expect(scene.get_node("UI/RegistryTerminalView/SilenceSurface").visible, "terminal boot lost black surface")
	scene.queue_free()
	# Let the audio server release playback references after freeing the scene.
	await create_timer(0.3).timeout

func _check_applied_loss_scars(manager: Node) -> void:
	manager.request_new_game()
	for bet: Dictionary in Catalog.level3_active_bets():
		var id: StringName = bet.id
		var applied: Array = manager.call("_handle_level3_loss_ritual", id, null)
		for scar: StringName in applied:
			_expect(manager.call("_has_scar", scar), "loss reported a scar it did not apply: " + str(id))
	manager.request_quit_to_menu()

func _check_menu_continue(scene: Node) -> void:
	var boundary := SaveContinueBoundary.new()
	var fixture := RunState.new()
	fixture.run_seed = 42
	fixture.run_save_flow_step = &"BET_OFFER"
	var scar_wire: Array = [{"id":"ROUNDTRIP_SCAR","name":"Scar"}]
	var pact_wire: Array = [{"bet_id":"CASH_OUT","bet_name":"Pact","arena_index":1,"outcome":0}]
	var wire: Dictionary = JSON.parse_string(JSON.stringify(boundary.build_save_payload(fixture, {"scars":scar_wire,"pacts_log":pact_wire})))
	_expect(bool(boundary.validate_continue_payload(wire).get("ok", false)), "writer produced a checkpoint its reader rejects")
	var expected_wire: Dictionary = JSON.parse_string(JSON.stringify({"scars":scar_wire,"pacts_log":pact_wire}))
	_expect(wire.run_state.scars == expected_wire.scars and wire.run_state.pacts_log == expected_wire.pacts_log, "checkpoint dropped scar or pact arrays: " + JSON.stringify(wire.run_state))
	var manager: Node = scene.get_node("RunManager")
	var menu: Control = scene.get_node("MenuLayer/MainMenu") as Control
	var resume: Button = menu.get("continue_button") as Button
	manager.request_new_game()
	await create_timer(0.1).timeout
	manager.call("_autosave_run_checkpoint", &"BET_OFFER", &"")
	var saved_seed: int = int((manager.get("_run_state") as RunState).run_seed)
	var saved_glory: int = int((manager.get("_run_state") as RunState).glory)
	manager.request_quit_to_menu()
	await process_frame
	_expect(resume.visible and not resume.disabled, "valid checkpoint has no resume button")
	(manager.get("_run_state") as RunState).glory = 999
	resume.pressed.emit()
	await create_timer(0.1).timeout
	_expect(not menu.visible, "resume button did not leave the menu")
	_expect(int((manager.get("_run_state") as RunState).glory) == saved_glory, "resume button did not restore saved resources")
	_expect(int((manager.get("_run_state") as RunState).run_seed) == saved_seed, "resume button replaced the saved run")
	manager.request_quit_to_menu()
	await process_frame
	# The file can disappear between rendering the available action and pressing it.
	(manager.get("_save_system") as SaveSystem).clear_run()
	resume.pressed.emit()
	await create_timer(0.1).timeout
	var message: Label = menu.get("continue_hint_label") as Label
	_expect(menu.visible and message.is_visible_in_tree(), "failed resume hid the menu or rejection message")
	_expect(message.text == str(menu.call("_format_continue_reject_reason", "missing_run_save")), "failed resume lost the actionable save reason")
	_expect(not resume.visible, "missing save left an available resume action")
	print("AUDIT_MENU_CONTINUE_OK")

func _check_contract_readability(scene: Node) -> void:
	_expect(scene.get_node("RunManager").get_available_level3_pacts() == Catalog.level3_active_bet_ids(), "archive differs from the actual offer catalogue")
	for pact: StringName in scene.get_node("RunManager").get_available_level3_pacts():
		_expect(Catalog.level3_active_bet_ids().has(pact), "archive lists a retired pact")
		_expect(Catalog.get_level3_display_subtitle(pact) != "", "archive pact has no readable meaning")
	var registry: Control = scene.get_node("UI/UI_RunRoot/BettingCircle")
	var label: RichTextLabel = registry.get_node("CenterContainer/BookFrame/LeftPage/Content/Rtl_Left_Contract")
	var old_locale: String = TranslationServer.get_locale()
	var old_text: String = label.text
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		for bet: Dictionary in Catalog.level3_active_bets():
			if locale != "it":
				for field: String in ["display_title", "display_subtitle", "doom", "condition", "pact"]:
					var source: String = str(bet.get(field, ""))
					_expect(source == "" or String(TranslationServer.translate(source)) != source, "untranslated catalog field: %s / %s / %s" % [str(bet.id), field, locale])
			var display: Dictionary = registry.call("_map_offer_for_display", bet)
			label.text = str(display.contract)
			label.visible_ratio = 1.0
			await process_frame
			await process_frame
			_expect(label.get_content_height() <= label.size.y + 1.0, "contract clipped: %s / %s (%d > %.1f)" % [str(bet.id), locale, label.get_content_height(), label.size.y])
			if locale != "it":
				_expect(not label.text.contains("CONDANNA") and not label.text.contains("CONDIZIONE"), "contract sections were not translated")
	TranslationServer.set_locale(old_locale)
	label.text = old_text

func _check_offer_publication(scene: Node) -> void:
	var manager: Node = scene.get_node("RunManager")
	var events: Node = root.get_node("GameEvents")
	var offers: Array[Array] = []
	var lifecycle: Array[String] = []
	var begin_observer := func() -> void:
		lifecycle.append("begin")
		_expect(not manager.get("_run_state").level3_current_offer.is_empty() and bool(manager.get("_waiting_for_bet")), "lifecycle began before complete offer/gate")
	var end_observer := func() -> void: lifecycle.append("end")
	events.betting_opened.connect(begin_observer)
	events.bet_opened.connect(end_observer)
	var modal_opens: Array[String] = []
	var modal_observer := func(kind: String) -> void:
		if kind == "betting_circle": modal_opens.append(kind)
	events.modal_opened.connect(modal_observer)
	var observer := func(value: Array[Dictionary]) -> void:
		lifecycle.append("offer")
		offers.append(value.duplicate(true))
		_expect(not value.is_empty(), "published intermediate empty offer")
		_expect(value == manager.get("_run_state").level3_current_offer, "published offer differs from manager state")
		_expect(bool(manager.get("_waiting_for_bet")), "offer published before request gate was ready")
		for entry: Dictionary in value:
			_expect(entry.has("stake_gain") and entry.has("seal_conditions"), "published incomplete Registry terms")
	events.bet_ui_opened.connect(observer)
	scene.get_node("MenuLayer/MainMenu").get("new_game_button").pressed.emit()
	_expect(offers.size() == 1, "new run must publish one offer, got %d" % offers.size())
	_expect(modal_opens.size() == 1, "new run reset the Registry more than once")
	_expect(lifecycle == ["begin", "offer", "end"], "offer lifecycle duplicated or reordered")
	var first: Array = manager.get("_run_state").level3_current_offer.duplicate(true)
	offers.clear()
	manager.call("_open_level3_bet_ui")
	_expect(offers.size() == 1 and offers[0] == first, "same-phase reopen changed or duplicated the offer")
	manager.request_quit_to_menu()
	await process_frame
	offers.clear()
	scene.get_node("MenuLayer/MainMenu").get("continue_button").pressed.emit()
	_expect(offers.size() == 1 and offers[0] == first, "BET_OFFER Continue changed or duplicated the offer")
	events.bet_ui_opened.disconnect(observer)
	events.modal_opened.disconnect(modal_observer)
	events.betting_opened.disconnect(begin_observer)
	events.bet_opened.disconnect(end_observer)
	manager.request_quit_to_menu()
	await process_frame
	print("AUDIT_OFFER_PUBLICATION_OK")

func _check_bet_commit_flow(scene: Node) -> void:
	var manager: Node = scene.get_node("RunManager")
	var events: Node = root.get_node("GameEvents")
	var save: Node = root.get_node("SaveManager")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
	var accepted: Array[String] = []
	var rituals: Array[int] = []
	var accepted_observer := func(id: String, _stake: int, _odds: float) -> void: accepted.append(id)
	var ritual_observer := func() -> void: rituals.append(1)
	events.bet_placed.connect(accepted_observer)
	events.pact_sealed_opened.connect(ritual_observer)
	var previous_motion: bool = save.get_reduced_motion()
	save.set_reduced_motion(true)
	for input: String in ["mouse", "keyboard", "intro_alias"]:
		menu.get("new_game_button").pressed.emit()
		await create_timer(0.7).timeout
		scene.get_node("OpeningPrologue").call("_finish")
		await process_frame
		var state: RunState = manager.get("_run_state")
		var snapshot: Dictionary = state.to_dict().duplicate(true)
		# Expected rejected requests: suppress only their diagnostics, then
		# restore logging before assertions so actual test failures remain visible.
		var print_errors: bool = Engine.print_error_messages
		Engine.print_error_messages = false
		events.request_place_bet.emit("NOT_AN_OFFER", 0)
		events.request_intro_select_bet.emit("")
		state.run_is_over = true
		events.request_place_bet.emit(str(state.level3_current_offer[0].id), 0)
		state.run_is_over = false
		Engine.print_error_messages = print_errors
		_expect(state.to_dict() == snapshot, "rejected selection mutated run state")
		_expect(str(manager.get("_last_request")) == "select_bet", "selection lost phase diagnostic context")
		var offer: Array[Dictionary] = state.level3_current_offer.duplicate(true)
		Engine.print_error_messages = false
		circle.set_offers([] as Array[Dictionary])
		circle.open()
		circle.open_book_button.pressed.emit()
		Engine.print_error_messages = print_errors
		await process_frame
		_expect(circle.selected_bet_id == &"" and circle.left_sign_button.disabled and circle.right_sign_button.disabled, "empty authoritative offer became signable")
		circle.left_sign_button.pressed.emit()
		_expect(accepted.is_empty(), "invalid offer emitted a commit")
		var malformed: Array[Dictionary] = [{"id": "NOT_AN_OFFER", "name": "Not a pact"}, {"name": "Missing id"}]
		Engine.print_error_messages = false
		circle.set_offers(malformed)
		circle.reset()
		Engine.print_error_messages = print_errors
		_expect(circle.selected_bet_id == &"" and circle.left_sign_button.disabled and circle.right_sign_button.disabled, "malformed offer or reset invented a signable page")
		circle.set_offers(offer)
		circle.open()
		circle.open_book_button.pressed.emit()
		await create_timer(0.4).timeout
		var id: String = str(circle.selected_bet_id)
		var history_before: int = state.bets_history.size()
		var pacts_before: int = state.pacts_log.size()
		if input == "intro_alias":
			events.request_intro_select_bet.emit(id)
		else:
			var button: Button = circle.left_sign_button
			button.grab_focus()
			_expect(button.is_visible_in_tree() and not button.disabled, "native signature target unavailable: " + input)
			if input == "mouse":
				for down: bool in [true, false]:
					var click := InputEventMouseButton.new()
					click.position = button.get_global_rect().get_center()
					click.global_position = click.position
					click.button_index = MOUSE_BUTTON_LEFT
					click.pressed = down
					root.push_input(click, true)
			else:
				for down: bool in [true, false]:
					var key := InputEventKey.new()
					key.keycode = KEY_ENTER
					key.pressed = down
					root.push_input(key, true)
		_expect(accepted == [id] and rituals.size() == 1, "signature did not commit once: " + input)
		_expect(state.active_bet_id == StringName(id) and state.bets_history.size() == history_before + 1 and state.pacts_log.size() == pacts_before + 1, "signature history changed more than once: " + input)
		var disk: Dictionary = manager.get("_save_system").load_run_payload()
		_expect(str(disk.get("run_state", {}).get("run_save_flow_step", "")) == "BET_SIGNED", "signature did not persist BET_SIGNED")
		snapshot = state.to_dict().duplicate(true)
		Engine.print_error_messages = false
		events.request_place_bet.emit(id, 0)
		events.request_intro_select_bet.emit(id)
		Engine.print_error_messages = print_errors
		_expect(state.to_dict() == snapshot and accepted.size() == 1 and rituals.size() == 1, "duplicate signature changed run or replayed ritual")
		manager.request_quit_to_menu()
		await process_frame
		Engine.print_error_messages = false
		events.request_place_bet.emit(id, 0)
		Engine.print_error_messages = print_errors
		_expect(accepted.size() == 1, "menu accepted an out-of-phase signature")
		menu.get("continue_button").pressed.emit()
		_expect(accepted.size() == 1 and rituals.size() == 2, "BET_SIGNED Continue signed again or failed to resume pact")
		var resumed: RunState = manager.get("_run_state")
		_expect(resumed.active_bet_id == StringName(id) and resumed.bets_history.size() == history_before + 1 and resumed.pacts_log.size() == pacts_before + 1, "signed Continue changed identity or history")
		manager.request_quit_to_menu()
		await process_frame
		accepted.clear()
		rituals.clear()
	save.set_reduced_motion(previous_motion)
	events.bet_placed.disconnect(accepted_observer)
	events.pact_sealed_opened.disconnect(ritual_observer)
	print("AUDIT_BET_COMMIT_FLOW_OK")
