extends SceneTree

var errors: Array[String] = []
var output := "res://artifacts/seat_case_2026-10-28"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var save := root.get_node("SaveManager")
	save.mark_campaign_dialogue_seen("entry")
	save.mark_campaign_dialogue_seen("seat_kept")
	save.commit_registry_evolution(0.0, 1, {})
	save.set_ledger_denari(10)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.6).timeout
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(1.0).timeout
	var dialogue: Node = scene.get_node("OpeningPrologue")
	if bool(dialogue.get("_active")):
		dialogue.call("_finish")
	var case_ui: Control = dialogue.get_node("SeatCase")
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			case_ui.call("try_open")
			await create_timer(0.4).timeout
			await RenderingServer.frame_post_draw
			for node_name: String in ["Btn_Seat_Reserve", "Btn_Seat_Witness", "Btn_Seat_Defer"]:
				var button := case_ui.find_child(node_name, true, false) as Button
				if button == null or not button.is_visible_in_tree() or not root.get_visible_rect().encloses(button.get_global_rect()):
					errors.append("button outside viewport: %s %s" % [locale, node_name])
			var screenshot := root.get_texture().get_image()
			if screenshot.get_size() != dimensions:
				errors.append("capture dimensions differ: %s %s" % [locale, str(dimensions)])
			screenshot.save_png(output.path_join("case_%s_%dx%d.png" % [locale, dimensions.x, dimensions.y]))
	TranslationServer.set_locale("it")
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	save.set_ledger_denari(-5)
	case_ui.call("try_open")
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	if not case_ui.find_child("Btn_Seat_Reserve", true, false).disabled:
		errors.append("reservation enabled in debt")
	root.get_texture().get_image().save_png(output.path_join("case_debt_it_1280x720.png"))
	case_ui.find_child("Btn_Seat_Witness", true, false).pressed.emit()
	await create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	if not case_ui.find_child("Btn_Seat_Continue", true, false).is_visible_in_tree():
		errors.append("testimony acknowledgement missing")
	root.get_texture().get_image().save_png(output.path_join("case_witness_result_it_1280x720.png"))
	var file := FileAccess.open(output.path_join("summary.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"errors": errors, "captures": 11}, "\t"))
	file.close()
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("SEAT_CASE_CAPTURE_OK 11")
	else:
		push_error(str(errors))
	quit(0 if errors.is_empty() else 1)
