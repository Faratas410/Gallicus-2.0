extends SceneTree
## Real Main entry and native Registry inputs, with a disposable user profile.
var scene: Node
var circle: Control
var failures: Array[String] = []
var checks: int = 0
var intents: int = 0
var captures: bool = false
var page_layouts: Array[Dictionary] = []
var output := "res://artifacts/registry_volume"

func _initialize() -> void:
	captures = "--capture" in OS.get_cmdline_user_args()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			output = argument.trim_prefix("--capture-dir=")
	call_deferred("_run")

func check(value: bool, note: String) -> void:
	checks += 1
	if not value:
		failures.append(note)
		push_error(note)

func settle(seconds: float = 0.1) -> void:
	await create_timer(seconds).timeout
	await process_frame

func capture(label: String) -> void:
	if not captures: return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "/" + label + ".png")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await settle(0.4)
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var manager: Node = scene.get_node("RunManager")
	var events: Node = root.get_node("GameEvents")
	var save: Node = root.get_node("SaveManager")
	events.request_place_bet.connect(func(_id: String, _stake: int) -> void: intents += 1)
	circle = scene.get_node("UI/UI_RunRoot/BettingCircle")
	for locale: int in [0, 1, 2]:
		menu.call("_on_language_selected", locale)
		menu.get("new_game_button").pressed.emit()
		await settle(2.5)
		scene.get_node("OpeningPrologue").call("_finish")
		await settle()
		check(not scene.get_node("OpeningPrologue").get("_active"), "entry dialogue must be dismissed before visual capture")
		check(circle.visible, "real entry did not open Registry")
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			if captures: DisplayServer.window_set_size(dimensions)
			save.set_reduced_motion(false)
			circle.open()
			await settle()
			var suffix := "%s_%d" % [TranslationServer.get_locale(), dimensions.x]
			for button: Control in circle.banco_row.get_children():
				check(root.get_visible_rect().encloses(button.get_global_rect()), "bank target outside viewport: " + suffix)
			await capture("closed_" + suffix)
			circle.open_book_button.pressed.emit()
			await settle(0.55)
			check(circle.get("_opening_locked"), "opening must lock signature input")
			circle.left_sign_button.pressed.emit()
			check(intents == 0, "locked opening emitted intent")
			await capture("turn_" + suffix)
			await settle(0.9)
			check(is_equal_approx(circle.get("_volume").opening, 1.0), "book did not settle open")
			check(not circle.left_sign_button.disabled and not circle.right_sign_button.disabled, "signature unavailable after opening")
			check(root.gui_get_focus_owner() == circle.left_sign_button, "opening did not focus left signature")
			for control: Control in [circle.left_contract_label, circle.right_contract_label, circle.left_sign_button, circle.right_sign_button]:
				check(root.get_visible_rect().encloses(control.get_global_rect()), "reading/input outside viewport: " + suffix)
				check(control.scale == Vector2.ONE, "native target scaled")
			for label: RichTextLabel in [circle.left_contract_label, circle.right_contract_label]:
				check(label.visible_characters == -1, "contract partially written")
				check(not label.scroll_active and not label.get_v_scroll_bar().visible, "paper has a scrollbar: " + suffix)
				check(label.get_content_height() <= label.size.y, "paper clips terms: %s %s %s" % [suffix, label.get_content_height(), label.size])
			await capture("open_" + suffix)
			await key(KEY_RIGHT)
			check(root.gui_get_focus_owner() == circle.right_sign_button, "keyboard could not reach right signature")
			await capture("right_focus_" + suffix)
			# Reading is passive; keyboard stays on the two signature actions.
			await key(KEY_PAGEDOWN)
			check(root.gui_get_focus_owner() == circle.right_sign_button, "page navigation stole signature focus")
			await _check_all_contracts(suffix)
		# Interrupt opening with settings and make sure no old tween can revive it.
		circle.open()
		circle.open_book_button.pressed.emit()
		await settle(0.15)
		save.set_reduced_motion(true)
		events.settings_changed.emit({"reduced_motion": true})
		await settle()
		check(not circle.get("_opening_locked"), "reduced motion did not unlock")
		check(is_equal_approx(circle.get("_volume").opening, 1.0), "reduced motion left half-open book")
		circle.close()
		await settle(1.3)
		check(not circle.visible, "cancelled opening resurfaced")
		# Replacing an offer while opening must cancel the obsolete reveal.
		circle.open()
		circle.open_book_button.pressed.emit()
		await settle(0.1)
		circle.set_offers([] as Array[Dictionary])
		await settle(1.3)
		check(circle.get("_awaiting_open_request") and circle.get("_volume").opening == 0.0, "new offer inherited old opening tween")
		circle.close()
	# One actual accepted signature, emitted immediately; animation owns no phase.
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	if captures: DisplayServer.window_set_size(Vector2i(1280, 720))
	menu.call("_on_language_selected", 0)
	menu.get("new_game_button").pressed.emit()
	await settle(2.5)
	scene.get_node("OpeningPrologue").call("_finish")
	await settle()
	save.set_reduced_motion(true)
	circle.open()
	circle.open_book_button.pressed.emit()
	await settle()
	save.set_reduced_motion(false)
	var selected: StringName = circle.get("selected_bet_id")
	await key(KEY_ENTER)
	check(intents == 1, "signature must emit exactly one intent synchronously")
	check(manager.get("_run_state").active_bet_id == selected, "manager did not register selected offer")
	await settle(0.2)
	check(scene.find_children("*", "CanvasLayer", false, false).size() > 0, "missing presentation layers")
	await capture("signature")
	await settle(0.6)
	check(not circle.visible, "book kept gameplay open after acceptance")
	await capture("accepted_pact")
	events.request_show_main_menu.emit()
	await settle()
	var report := FileAccess.open(output + "/report.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks": checks, "failures": failures, "intents": intents, "captures": captures, "page_layouts": page_layouts}, "\t"))
	print("REGISTRY_VOLUME ", checks, " checks; ", failures.size(), " failures")
	scene.get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await settle(1.5)
	scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _check_all_contracts(suffix: String) -> void:
	# Measure every active localized offer with neutral, helped and adverse
	# conditions. A hidden scrollbar alone must never count as fitting paper.
	var label: RichTextLabel = circle.right_contract_label
	var original: String = label.text
	var worst_text := ""
	var worst_height := 0
	for offer: Dictionary in BetCatalog.level3_active_bets():
		for conditions: Dictionary in [{"favor": 0, "pressure": 0, "scars": 0}, {"favor": 3, "pressure": 10, "scars": 2}, {"favor": -3, "pressure": 10, "scars": 2}]:
			var source: Dictionary = offer.duplicate(true)
			source["seal_conditions"] = conditions
			source["stake_gain"] = 42
			circle.call("_apply_page", {"source": source}, label)
			await process_frame
			await process_frame
			var height := label.get_content_height()
			var name := "%s %s %s" % [suffix, offer.id, conditions]
			check(not label.scroll_active and not label.get_v_scroll_bar().visible, "scrollbar in " + name)
			check(height <= label.size.y, "clipped terms: %s height=%d available=%f" % [name, height, label.size.y])
			var doom: Array = circle.call("_translated_lines", str(offer.doom))
			var effect: String = circle.call("_strip_effect_prefix", doom.back())
			check(label.get_parsed_text().contains(effect), "lost consequence: " + name)
			page_layouts.append({"case": name, "height": height, "available": label.size.y})
			if height > worst_height:
				worst_height = height
				worst_text = label.text
	label.text = worst_text
	await settle()
	await capture("longest_" + suffix)
	label.text = original
	await settle()
