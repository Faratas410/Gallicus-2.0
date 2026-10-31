extends SceneTree

# Fixture captures of the last Era's sheets: the last figure (positive and in
# debt) and the last copy with all three memories, IT/EN/ES at 720p and 1080p.
const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var errors: Array[String] = []
var output := "res://artifacts/final_era_2026-10-30/captures"
var case_ui: Control
var captures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _shoot(tag: String) -> void:
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			case_ui.set("active", false)
			case_ui.call("try_open")
			await create_timer(0.3).timeout
			await RenderingServer.frame_post_draw
			var evidence: Label = case_ui.get("evidence")
			if evidence.get_line_count() > evidence.get_visible_line_count():
				errors.append("evidence clipped: %s %s" % [tag, locale])
			for node_name: String in ["Btn_Seat_Reserve", "Btn_Seat_Witness", "Btn_Seat_Defer"]:
				var button := case_ui.find_child(node_name, true, false) as Button
				if button.visible and not root.get_visible_rect().encloses(button.get_global_rect()):
					errors.append("button outside viewport: %s %s %s" % [tag, locale, node_name])
			root.get_texture().get_image().save_png(output.path_join("%s_%s_%dx%d.png" % [tag, locale, dimensions.x, dimensions.y]))
			captures += 1
	TranslationServer.set_locale("it")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var save := root.get_node("SaveManager")
	save.commit_registry_evolution(0.0, 3, {"era_runs": 1, "signature": {"scar_tolerance": 0.5}})
	for id: String in Dialogues.SEQUENCES:
		save.mark_campaign_dialogue_seen(id)
	save.resolve_seat_case("witness", 1, 0)
	save.set_ledger_denari(30)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	case_ui = scene.get_node("OpeningPrologue/SeatCase")
	await _shoot("ledger")
	save.set_ledger_denari(-8)
	await _shoot("ledger_debt")
	save.set_ledger_denari(30)
	save.resolve_final_ledger("vessa")
	await _shoot("final_copy")
	root.content_scale_size = Vector2i(1280, 720)
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	case_ui.find_child("Btn_Seat_Witness", true, false).pressed.emit()
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output.path_join("final_copy_result_it_1280x720.png"))
	var file := FileAccess.open(output.path_join("summary.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"errors": errors, "captures": captures + 1}, "\t"))
	file.close()
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("FINAL_ERA_CAPTURE_OK %d" % (captures + 1))
	else:
		push_error(str(errors))
	quit(0 if errors.is_empty() else 1)
