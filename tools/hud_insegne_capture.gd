extends SceneTree
## Isolated real entry, then explicit UI presentation fixtures (no economy).
var scene: Node
var ui: Node
var header: Control
var checks := 0
var failures: Array[String] = []
var sign_intents := 0
const OUTPUT := "res://artifacts/hud_insegne"

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures.append(note)
		push_error(note)

func settle(seconds: float = 0.15) -> void:
	await create_timer(seconds).timeout
	await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT + "/" + name + ".png")

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

func measure(suffix: String) -> void:
	for node: Node in header.get_children():
		if not node is Label: continue
		var label := node as Label
		var slot: Rect2 = label.get_meta("hud_slot")
		var available: Vector2 = slot.size * header.factor
		check(label.size.x <= available.x + 1 and label.size.y <= available.y + 1, "label grew outside skin: %s '%s' %s / %s" % [suffix, label.text, label.size, available])
		check(root.get_visible_rect().encloses(label.get_global_rect()), "label outside viewport " + suffix)
		var font := label.get_theme_font("font")
		var points := label.get_theme_font_size("font_size")
		if label.autowrap_mode == TextServer.AUTOWRAP_OFF:
			check(font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, points).x <= available.x + 1, "text wider than skin: " + suffix + " " + label.text)
		else:
			check(label.get_line_count() * label.get_line_height() <= available.y + 1, "wrapped text taller than skin: " + suffix + " " + label.text)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await settle(0.5)
	ui = scene.get_node("UI")
	header = ui.get_node("HUD/RitualStatusHeader")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var circle: Control = ui.get("betting_circle")
	var manager: Node = scene.get_node("RunManager")
	root.get_node("GameEvents").request_place_bet.connect(func(_id: String, _stake: int) -> void: sign_intents += 1)
	root.get_node("SaveManager").set_reduced_motion(true)
	check(not header.is_visible_in_tree(), "HUD visible over menu")
	for language: int in [0, 1, 2]:
		menu.call("_on_language_selected", language)
		menu.get("new_game_button").pressed.emit()
		await settle(2.5)
		scene.get_node("OpeningPrologue").call("_finish")
		await settle()
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			var suffix := "%s_%d" % [TranslationServer.get_locale(), dimensions.x]
			circle.open()
			circle.open_book_button.pressed.emit()
			await settle()
			check(header.is_visible_in_tree(), "HUD missing in Registry")
			measure(suffix)
			await capture("registry_" + suffix)
			for values: Vector3i in [Vector3i(5, 1, 99999), Vector3i(10, -4, -9999), Vector3i(0, 4, 12)]:
				ui.call("_on_escalation_changed", values.x, 10)
				ui.call("_on_crowd_favor_changed", {"favor": values.y})
				ui.call("_on_ledger_changed", {"denari": values.z})
				ui.call("_on_scars_updated", [ScarCatalog.SCARS[1]])
				await settle()
				check(header.account.text == str(values.z), "account sign/value lost")
				check(header.favor.text == "%+d" % values.y, "favor sign/value lost")
				check(header.get("_pressure_level") == values.x, "pressure value lost")
				check(header.scar_count.text == "1" and not header.scars.disabled, "mark count/availability wrong")
				measure(suffix)
				await capture("pressure_%d_" % values.x + suffix)
			header.scars.grab_focus()
			await capture("marks_focus_" + suffix)
			await key(KEY_ENTER)
			await settle()
			check(ui.get("scars_detail_panel").visible, "Enter did not open marks")
			check(sign_intents == 0, "opening marks signed a contract")
			await capture("marks_detail_" + suffix)
			ui.get("scars_detail_close").pressed.emit()
			await settle()
			check(root.gui_get_focus_owner() == header.scars, "marks close lost focus")
			for status: String in ["closed", "lapsed", "missed", "open"]:
				ui.call("_on_bando_changed", {"status": status, "posta": 999, "quota": 1000, "deadline": 7, "denari": 12})
				await settle()
				measure(suffix + status)
			circle.close()
			ui.call("show_phase", RunPhaseContract.PUSH_YOUR_LUCK)
			var payload: Dictionary = manager.call("_build_push_luck_payload", circle.get("selected_bet_id"))
			ui.call("_on_push_luck_opened", payload)
			await settle()
			await capture("verdict_" + suffix)
			check(header.is_visible_in_tree(), "HUD missing in verdict")
			ui.call("_on_push_luck_closed")
			ui.call("_on_intermediate_choice_opened")
			await settle()
			await capture("pact_" + suffix)
			check(header.is_visible_in_tree(), "HUD missing in pact")
			ui.call("_set_intermediate_choice_modal", false)
		root.get_node("GameEvents").request_show_main_menu.emit()
		await settle()
		check(not header.is_visible_in_tree(), "HUD resurfaced over menu")
	var report := FileAccess.open(OUTPUT + "/report.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks": checks, "failures": failures, "sign_intents": sign_intents}, "\t"))
	print("HUD_INSEGNE ", checks, " checks; ", failures.size(), " failures")
	scene.get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await settle(1.5)
	scene.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
