extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var errors: Array[String] = []
var output := "res://artifacts/seat_inquiry_2026-10-28"

func _initialize() -> void:
	call_deferred("_run")

func _capture(case_ui: Control, name: String, dimensions: Vector2i) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	var text: Label = case_ui.get("evidence")
	if text.get_line_count() > text.get_visible_line_count():
		errors.append("clipped evidence: " + name)
	var screenshot := root.get_texture().get_image()
	if screenshot.get_size() != dimensions:
		errors.append("wrong dimensions: " + name)
	screenshot.save_png(output.path_join(name + ".png"))

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var save := root.get_node("SaveManager")
	save.commit_registry_evolution(0.0, 1, {})
	for id: String in Dialogues.SEQUENCES.keys():
		save.mark_campaign_dialogue_seen(id)
	var meta: Dictionary = save.get("_meta")
	meta["seat_case"] = {"choice": "reserve", "era": 1}
	meta["seat_inquiry"] = {"seen": 3, "complete": false}
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
			for branch: String in ["reserve", "witness"]:
				meta["seat_case"] = {"choice": branch, "era": 1}
				meta["seat_inquiry"] = {"seen": 3, "complete": false}
				case_ui.call("try_open")
				await _capture(case_ui, "traces_%s_%s_%dx%d" % [branch, locale, dimensions.x, dimensions.y], dimensions)
			case_ui.find_child("Btn_Seat_Continue", true, false).pressed.emit()
			case_ui.find_child("Btn_Seat_Witness", true, false).pressed.emit()
			await _capture(case_ui, "unsupported_%s_%dx%d" % [locale, dimensions.x, dimensions.y], dimensions)
	TranslationServer.set_locale("it")
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	meta["seat_case"] = {"choice": "reserve", "era": 1}
	meta["seat_inquiry"] = {"seen": 1, "complete": false}
	case_ui.call("try_open")
	await _capture(case_ui, "partial_it_1280x720", Vector2i(1280, 720))
	case_ui.find_child("Btn_Seat_Witness", true, false).pressed.emit()
	case_ui.find_child("Btn_Seat_Continue", true, false).pressed.emit()
	case_ui.find_child("Btn_Seat_Reserve", true, false).pressed.emit()
	await _capture(case_ui, "result_it_1280x720", Vector2i(1280, 720))
	var file := FileAccess.open(output.path_join("summary.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"errors": errors, "captures": 20}, "\t"))
	file.close()
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("SEAT_INQUIRY_CAPTURE_OK 20")
	else:
		push_error(str(errors))
	quit(0 if errors.is_empty() else 1)
