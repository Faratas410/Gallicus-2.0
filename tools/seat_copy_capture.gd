extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var errors: Array[String] = []
var output := "res://artifacts/seat_copy_2026-10-29"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var save := root.get_node("SaveManager")
	save.commit_registry_evolution(0.0, 1, {})
	for id: String in Dialogues.SEQUENCES:
		save.mark_campaign_dialogue_seen(id)
	save.resolve_seat_case("witness", 1, 0)
	save.mark_seat_evidence(1)
	save.mark_seat_evidence(2)
	save.complete_seat_inquiry()
	save.set_ledger_denari(10)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	var case_ui: Control = scene.get_node("OpeningPrologue/SeatCase")
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			case_ui.call("try_open")
			await create_timer(0.3).timeout
			await RenderingServer.frame_post_draw
			var evidence: Label = case_ui.get("evidence")
			if evidence.get_line_count() > evidence.get_visible_line_count():
				errors.append("evidence clipped: " + locale)
			for node_name: String in ["Btn_Seat_Reserve", "Btn_Seat_Witness", "Btn_Seat_Defer"]:
				var button := case_ui.find_child(node_name, true, false) as Button
				if not button.is_visible_in_tree() or not root.get_visible_rect().encloses(button.get_global_rect()):
					errors.append("button outside viewport: " + locale + " " + node_name)
			var screenshot := root.get_texture().get_image()
			if screenshot.get_size() != dimensions:
				errors.append("wrong size: " + locale)
			screenshot.save_png(output.path_join("copy_%s_%dx%d.png" % [locale, dimensions.x, dimensions.y]))
	TranslationServer.set_locale("it")
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	save.set_ledger_denari(-5)
	case_ui.call("try_open")
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	if not case_ui.find_child("Btn_Seat_Reserve", true, false).disabled:
		errors.append("paid copy enabled in debt")
	root.get_texture().get_image().save_png(output.path_join("copy_debt_it_1280x720.png"))
	case_ui.find_child("Btn_Seat_Witness", true, false).pressed.emit()
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join("copy_keep_result_it_1280x720.png"))
	var meta: Dictionary = save.get("_meta")
	meta["seat_copy"] = ""
	save.set_ledger_denari(10)
	case_ui.call("try_open")
	case_ui.find_child("Btn_Seat_Reserve", true, false).pressed.emit()
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join("copy_paid_result_it_1280x720.png"))
	var file := FileAccess.open(output.path_join("summary.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"errors": errors, "captures": 9}, "\t"))
	file.close()
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("SEAT_COPY_CAPTURE_OK 9")
	else:
		push_error(str(errors))
	quit(0 if errors.is_empty() else 1)
