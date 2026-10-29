extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var failures: Array[String] = []
var output := "res://artifacts/seat_policy_2026-10-29"

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
	save.set_ledger_denari(20)
	save.resolve_seat_copy("copy")
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	var bank_button := scene.find_child("Btn_Banco_insure", true, false) as Button
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.size = dimensions
			root.content_scale_size = dimensions
			DisplayServer.window_set_size(dimensions)
			scene.get_node("UI/UI_RunRoot/BettingCircle").call("_render_banco")
			await create_timer(0.5).timeout
			await RenderingServer.frame_post_draw
			if bank_button == null or not bank_button.is_visible_in_tree() or not bank_button.text.contains("5"):
				failures.append("discounted policy not visible: " + locale)
			var picture := root.get_texture().get_image()
			if picture.get_size() != dimensions:
				failures.append("wrong dimensions: " + locale)
			picture.save_png(output.path_join("bank_%s_%dx%d.png" % [locale, dimensions.x, dimensions.y]))
	var file := FileAccess.open(output.path_join("summary.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"failures": failures, "captures": 6}, "\t"))
	file.close()
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("SEAT_POLICY_BANK_CAPTURE_OK 6")
	else:
		push_error(str(failures))
	quit(0 if failures.is_empty() else 1)
