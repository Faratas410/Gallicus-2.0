extends SceneTree

const Phase = preload("res://scripts/contracts/run_phase_contract.gd")

var _failed: bool = false
var _checks: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(value: bool, message: String) -> void:
	_checks += 1
	if not value:
		_failed = true
		push_error("AV_CONTRACT: " + message)

func _run() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await create_timer(0.25).timeout
	await _verify_presentation(scene)
	await _verify_music_route(scene)
	var music: Node = scene.get_node("MusicDirector")
	var players: Array = music.get("_players")
	_expect(players.size() == 2, "music must use exactly two voices")
	var active: int = int(music.get("_active"))
	var position: float = players[active].get_playback_position()
	music.call("_on_run_phase_changed", Phase.MAIN_MENU)
	await create_timer(0.12).timeout
	_expect(int(music.get("_active")) == active, "same music state restarted a track")
	_expect(players[active].get_playback_position() >= position, "same-state playback jumped backwards")
	music.set("fade_seconds", 0.12)
	music.call("_transition", "tense")
	_expect(players[0].playing and players[1].playing, "crossfade must overlap both voices")
	await create_timer(0.20).timeout
	_expect(int(players[0].playing) + int(players[1].playing) == 1, "outgoing voice not stopped")
	for player: AudioStreamPlayer in players:
		_expect(player.stream is AudioStreamWAV and player.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "score loop not configured")
	var sfx: Node = root.get_node("SfxBus")
	var sfx_players: Array = sfx.get("_players")
	_expect(sfx_players.size() == 6, "SFX pool exceeded six voices")
	sfx.call("play_cue", &"registry_pact_validate")
	sfx.call("_apply_sfx_volume_linear", 0.0)
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "SFX mute did not silence bus")
	sfx.call("_apply_sfx_volume_linear", 1.0)
	music.call("_apply_music_volume_linear", 0.0)
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "music mute did not silence bus")
	music.call("_apply_music_volume_linear", 1.0)
	var feedback: Node = scene.get_node("RitualFeedback")
	var sprites: Array = feedback.get("_sprites")
	_expect(sprites.size() == 2 and sprites[0].texture.get_width() <= 256, "VFX resource budget exceeded")
	var button: Button = Button.new()
	button.text = "AV TEST"
	button.position = Vector2(100,100)
	button.size = Vector2(180,60)
	scene.get_node("MenuLayer/MainMenu").add_child(button)
	button.grab_focus()
	var base_rect: Rect2 = button.get_global_rect()
	var base_nodes: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for index: int in range(100):
		scene.get_node("MenuLayer/MainMenu").call("_play_sfx", &"registry_promise_sign")
	_expect(sprites[0].visible or sprites[1].visible, "UI cue did not reach VFX")
	_expect(button.get_global_rect() == base_rect, "VFX changed hit geometry")
	_expect(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) == base_nodes, "repeated VFX allocated nodes")
	await create_timer(0.6).timeout
	_expect(not sprites[0].visible and not sprites[1].visible, "VFX survived its time budget")
	var ui: Node = scene.get_node("UI")
	ui.call("_play_panel_enter", button, "ritual")
	feedback.call("play_cue", &"registry_promise_sign", button)
	scene.get_node("MenuLayer/MainMenu").call("_on_reduced_motion_toggled", true)
	await process_frame
	_expect(not sprites[0].visible and not sprites[1].visible, "reduced motion did not cancel in-flight VFX")
	feedback.call("play_cue", &"registry_promise_sign", button)
	_expect(not sprites[0].visible and not sprites[1].visible, "reduced motion started a new VFX")
	_expect(not scene.get_node("MenuLayer/MainMenu/MenuAmbience").is_processing(), "ambient movement still processing")
	_expect(not button.has_meta(&"panel_enter_tween"), "reduced motion retained panel tween")
	await create_timer(0.3).timeout
	_expect(button.get_global_rect() == base_rect, "cancelled panel motion changed geometry again")
	scene.get_node("MenuLayer/MainMenu").call("_on_reduced_motion_toggled", false)
	music.call("_on_registry_run_ended", "REGISTRY_SILENCE", {})
	sfx.call("_on_run_ended", "REGISTRY_SILENCE", {})
	music.call("_on_run_phase_changed", Phase.MAIN_MENU)
	_expect(not players[0].playing and not players[1].playing, "phase callback revived music during Silence")
	for player: AudioStreamPlayer in sfx_players:
		_expect(not player.playing, "ritual audio tail survived Silence")
	music.call("_on_request_show_main_menu")
	_expect(players[int(music.get("_active"))].playing, "music did not resume after explicit return")
	button.queue_free()
	await process_frame
	var frame_ms: Array[float] = []
	for index: int in range(120):
		var started: int = Time.get_ticks_usec()
		await process_frame
		frame_ms.append(float(Time.get_ticks_usec() - started) / 1000.0)
	frame_ms.sort()
	print("AV_METRICS=", JSON.stringify({"checks":_checks, "frame_interval_p50_ms":frame_ms[60], "frame_interval_p95_ms":frame_ms[114], "nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT), "draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC), "headless":DisplayServer.get_name() == "headless"}))
	music.call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	# Let the audio server drain its playback reference before destroying the scene.
	await create_timer(0.15).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.15).timeout
	print("AV_RUNTIME_CONTRACT_OK" if not _failed else "AV_RUNTIME_CONTRACT_FAILED")
	quit(1 if _failed else 0)

func _verify_presentation(scene: Node) -> void:
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var intro: Node = scene.get_node("OpeningPrologue")
	var terminal: Node = scene.get_node("UI/RegistryTerminalView")
	var ui: Node = scene.get_node("UI")
	# This goes through the actual button handler and RunManager, not a phase mock.
	menu.get("new_game_button").pressed.emit()
	await process_frame
	_expect(intro.get("_active"), "first menu entry did not start prologue")
	root.get_node("SaveManager").call("load_profile")
	_expect(root.get_node("SaveManager").call("has_seen_opening_prologue"), "prologue preference did not survive profile reload")
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	_expect(intro.get("_active"), "prologue skipped before 0.5 seconds")
	await create_timer(0.6).timeout
	event = InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	_expect(not intro.get("_active") and not intro.is_processing(), "Escape failed to stop prologue")
	var open_button: Button = scene.get_node("UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book")
	_expect(root.gui_get_focus_owner() == open_button, "skip did not restore registry focus")
	_expect(scene.get_node("MusicDirector").get("_active_key") == "safe", "real registry entry score incorrect")
	intro.call("prepare_first_entry")
	_expect(not intro.get("_armed"), "later entry rearmed prologue")
	# Full playback with reduced motion retains both captions and reading time.
	root.get_node("SaveManager").call("set_reduced_motion", true)
	intro.set("_armed", true)
	intro.call("_on_run_started")
	await create_timer(3.3).timeout
	_expect(intro.get("_active") and int(intro.get("_beat")) == 1, "reduced motion removed second caption or reading time")
	_expect(intro.get("_image").scale == Vector2.ONE, "reduced motion moved prologue image")
	menu.call("_on_language_selected", 1)
	await create_timer(0.1).timeout
	_expect(intro.get("_caption").text == "The Registry preserves your choices.", "prologue locale switch stale")
	await create_timer(4.9).timeout
	_expect(not intro.get("_active") and root.gui_get_focus_owner() == open_button, "automatic prologue completion blocked input")
	menu.call("_on_language_selected", 0)
	ui.set("_scars_detail_text", "A long scar record.\n".repeat(80))
	ui.call("_show_scars_detail")
	await process_frame
	_expect(ui.get("scars_detail_panel").is_visible_in_tree(), "scar detail binding invalid")
	_expect(ui.get("scars_detail_text").get_v_scroll_bar().size.x >= 8.0, "scar scrollbar has no usable width")
	_expect(ui.get("scars_detail_text").get_v_scroll_bar().max_value > ui.get("scars_detail_text").size.y, "long scar record cannot scroll")
	_expect(root.gui_get_focus_owner() == ui.get("scars_detail_close"), "scar detail close lacks focus")
	event = InputEventAction.new()
	event.action = "ui_down"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	_expect(root.gui_get_focus_owner() == ui.get("scars_detail_text"), "directional navigation escaped scar detail")
	ui.get("scars_detail_close").pressed.emit()
	_expect(not ui.get("scars_detail_panel").visible, "scar close button failed")
	_expect(open_button.is_visible_in_tree(), "scar detail destroyed underlying registry screen")
	ui.call("_show_scar_popup", {"name":"TEST", "effect_text":"Test scar effect"})
	_expect(ui.get("scar_popup_panel").is_visible_in_tree(), "scar notification binding invalid")
	await create_timer(3.8).timeout
	_expect(not ui.get("scar_popup_panel").visible, "reduced-motion scar notification never expires")
	for dimensions: Vector2i in [Vector2i(1280,720), Vector2i(1920,1080)]:
		root.size = dimensions
		terminal.call("_show_surface", false)
		await create_timer(2.1).timeout
		var button: Button = terminal.get("_return_button")
		_expect(button.is_visible_in_tree() and root.get_visible_rect().encloses(button.get_global_rect()), "Silence return outside viewport")
		_expect(root.gui_get_focus_owner() == button, "Silence return lacks keyboard focus")
		button.pressed.emit()
		_expect(not terminal.get("_black").visible, "Silence return button failed")
	root.size = Vector2i(1280,720)
	root.get_node("SaveManager").call("set_reduced_motion", false)
	menu.call("_show_menu")
	menu.call("_on_language_selected", 1)
	menu.call("_show_achievements")
	menu.call("_on_museo_tab_pressed")
	await process_frame
	_expect(menu.get("museo_tab_button").button_pressed and not menu.get("museo_tab_button").disabled, "archive selection is not an enabled pressed tab")
	var all_pacts_localized: bool = true
	for pact: StringName in menu.get("_run_manager_port").get_available_level3_pacts():
		var source_title: String = menu.call("_get_pact_display_name", pact)
		all_pacts_localized = all_pacts_localized and TranslationServer.translate(source_title) != source_title
	_expect(all_pacts_localized, "one or more museum pact titles have no translation")
	_expect(menu.get("condanna_entries")[&"CONDANNA_NON_MI_FERMERO"].text == "- I will not stop.", "sentence title was not localized")
	menu.call("_on_condanna_mouse_entered", preload("res://data/condanne.gd").defaults()[0])
	await process_frame
	menu.call("_place_condanna_tooltip", root.get_visible_rect().size - Vector2(2, 2))
	await process_frame
	_expect(root.get_visible_rect().encloses(menu.get("condanna_tooltip").get_global_rect()), "translated archive tooltip leaves viewport at lower edge")
	menu.call("_on_condanna_mouse_exited")
	menu.call("_on_language_selected", 0)
	menu.call("_show_menu")

func _press_route(scene: Node, suffix: String) -> void:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		var button: Button = scene.find_child(suffix, true, false) as Button
		if button != null and button.is_visible_in_tree() and not button.disabled:
			button.pressed.emit()
			await process_frame
			return
		await process_frame
	_expect(false, "real route button unavailable: " + suffix)

func _expect_score(scene: Node, key: String, step: String) -> void:
	var music: Node = scene.get_node("MusicDirector")
	var player: AudioStreamPlayer = music.get("_players")[int(music.get("_active"))]
	_expect(music.get("_active_key") == key and player.playing and player.stream.resource_path == music.TRACKS[key], "real score mismatch at " + step)

func _verify_music_route(scene: Node) -> void:
	# Only seed and outcome are stabilized. Every ritual uses its real UI handler.
	OS.set_environment("GALLICUS_SMOKE", "1")
	OS.set_environment("GALLICUS_SMOKE_SEED", "1782373819")
	await _press_route(scene, "NewGameButton")
	OS.unset_environment("GALLICUS_SMOKE")
	OS.unset_environment("GALLICUS_SMOKE_SEED")
	_expect_score(scene, "safe", "registry")
	await _press_route(scene, "Btn_Open_Book")
	await create_timer(1.2).timeout
	var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
	var side: String = "Right" if str(circle.call("_offer_id_at", 0)) == "BET_DOUBLE_OR_DIE" else "Left"
	await _press_route(scene, "Btn_Sign_" + side)
	await create_timer(0.3).timeout
	_expect_score(scene, "tense", "sealed pact")
	var character_before: String = str(scene.get_node("UI").get("pact_sealed_subtitle").text)
	_expect(character_before.contains("Nerio:") or character_before.contains("Vessa:") or character_before.contains("Orvo:"), "real pact route omitted character dialogue")
	# Resume from a real persisted checkpoint must bypass the opening overlay.
	root.get_node("GameEvents").request_show_main_menu.emit()
	await process_frame
	await _press_route(scene, "ContinueButton")
	await create_timer(0.3).timeout
	_expect(not scene.get_node("OpeningPrologue").get("_active"), "resume replayed prologue")
	_expect_score(scene, "tense", "resumed pact")
	_expect(str(scene.get_node("UI").get("pact_sealed_subtitle").text) == character_before, "Continue changed the character exchange")
	await _press_route(scene, "Btn_FIRST_REACTION_NEXT")
	await _press_route(scene, "Btn_MID_CHOICE_SELECT_0")
	await create_timer(0.3).timeout
	_expect_score(scene, "tense", "judgment")
	OS.set_environment("GALLICUS_SMOKE", "1")
	OS.set_environment("GALLICUS_SMOKE_SCENARIO", "FULL_RUN")
	for index: int in range(3):
		await _press_route(scene, "Btn_RESOLUTION_STRIKE")
		await create_timer(0.35).timeout
	var deadline: int = Time.get_ticks_msec() + 5000
	while not scene.get_node("UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK").visible and Time.get_ticks_msec() < deadline:
		await process_frame
	OS.unset_environment("GALLICUS_SMOKE")
	OS.unset_environment("GALLICUS_SMOKE_SCENARIO")
	_expect_score(scene, "climax", "push your luck")
	await _press_route(scene, "Btn_PUSH_YOUR_LUCK_CONDANNA")
	await create_timer(0.3).timeout
	_expect_score(scene, "ending", "dossier")
	root.get_node("GameEvents").request_show_main_menu.emit()
	await process_frame
	_expect_score(scene, "menu", "return to menu")
