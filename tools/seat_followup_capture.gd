extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var errors: Array[String] = []
var output := "res://artifacts/seat_followup_2026-10-28"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	var dialogue: Node = scene.get_node("OpeningPrologue")
	dialogue.set("_active", true)
	dialogue.get("_surface").show()
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			for id: String in ["seat_reserved_followup", "seat_witness_followup"]:
				var payload: Dictionary = Dialogues.SEQUENCES[id].duplicate(true)
				payload["id"] = id
				dialogue.set("_payload", payload)
				var longest := 0
				var longest_index := 0
				for index: int in range(payload.lines.size()):
					dialogue.set("_beat", index)
					dialogue.call("_refresh_line")
					await process_frame
					var caption: Label = dialogue.get("_caption")
					if caption.get_line_count() > caption.get_visible_line_count():
						errors.append("clipped line: %s %s %d %s" % [locale, id, index, str(dimensions)])
					if caption.text.length() > longest:
						longest = caption.text.length()
						longest_index = index
				dialogue.set("_beat", longest_index)
				dialogue.call("_refresh_line")
				await create_timer(0.2).timeout
				await RenderingServer.frame_post_draw
				var image := root.get_texture().get_image()
				if image.get_size() != dimensions:
					errors.append("wrong capture size: %s %s" % [locale, str(dimensions)])
				image.save_png(output.path_join("%s_%s_%dx%d.png" % [id, locale, dimensions.x, dimensions.y]))
	var file := FileAccess.open(output.path_join("summary.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"errors": errors, "captures": 12, "lines_checked": 72}, "\t"))
	file.close()
	dialogue.call("_cancel")
	scene.queue_free()
	await create_timer(0.5).timeout
	if errors.is_empty():
		print("SEAT_FOLLOWUP_CAPTURE_OK 12")
	else:
		push_error(str(errors))
	quit(0 if errors.is_empty() else 1)
