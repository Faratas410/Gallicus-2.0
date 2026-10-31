extends SceneTree

var failures: Array[String] = []
var capture_dir := ""

func _initialize() -> void:
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		push_error("SEAT_COPY_ECHO: " + message)

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	var manager: Node = scene.get_node("RunManager")
	var ui: Node = scene.get_node("UI")
	var menu: Control = scene.get_node("MenuLayer/MainMenu")
	var save: Node = root.get_node("SaveManager")
	var meta: Dictionary = save.get("_meta")
	meta["seat_case"] = {"choice": "witness", "era": 0}
	meta["seat_inquiry"] = {"seen": 3, "complete": true}
	var state: RunState = manager.get("_run_state")
	state.arena_index = 1
	state.seat_copy_echo = true
	menu.hide()
	ui.show()
	for choice: String in ["copy", "keep"]:
		meta["seat_copy"] = choice
		var before := state.to_dict()
		var lines: Array[String] = manager.get_character_dialogue("gesture")
		check(lines.size() == 2 and lines == manager.get_character_dialogue("gesture"), "memory is missing or nondeterministic: " + choice)
		check(state.to_dict() == before, "memory changed gameplay: " + choice)
		if choice == "copy":
			check(lines[0] == "Nerio: La nota è nella mia copia.", "wrong paid memory")
		else:
			check(lines[0] == "Nerio: La mia copia non ha la nota.", "wrong free memory")
		for locale: String in ["it", "en", "es"]:
			TranslationServer.set_locale(locale)
			if locale != "it":
				for line: String in lines:
					check(TranslationServer.translate(line) != line, "untranslated memory: " + locale)
			for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
				root.size = dimensions
				root.content_scale_size = dimensions
				DisplayServer.window_set_size(dimensions)
				ui.call("_on_intermediate_choice_opened")
				await process_frame
				await process_frame
				var label: Label = ui.get("intermediate_choice_audience_label")
				check(label.is_visible_in_tree() and label.text.contains(TranslationServer.translate(lines[0])), "memory not presented: " + locale)
				check(label.get_line_count() * label.get_line_height() <= label.size.y + 1, "clipped memory: " + locale)
				if capture_dir != "":
					await create_timer(0.8).timeout
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(capture_dir.path_join("%s_%s_%dx%d.png" % [choice, locale, dimensions.x, dimensions.y]))
	state.seat_copy_echo = false
	check(manager.get_character_dialogue("gesture")[0] != "Nerio: La mia copia non ha la nota.", "memory spoke outside its percorso")
	state.seat_copy_echo = true
	var restored := RunState.new()
	restored.from_dict(state.to_dict())
	check(restored.seat_copy_echo, "the echo percorso was not kept in the checkpoint")
	# Only the first percorso after the choice is marked, once per campaign.
	meta["seat_copy_echoed"] = false
	manager.call("_prepare_seat_copy_echo")
	check(state.seat_copy_echo and save.get_seat_copy_echoed(), "the first percorso after the choice did not take the echo")
	manager.call("_prepare_seat_copy_echo")
	check(not state.seat_copy_echo, "the echo returned in a later percorso")
	state.seat_copy_echo = true
	save.mark_campaign_dialogue_seen("departure")
	check(manager.get_character_dialogue("gesture").is_empty() or manager.get_character_dialogue("gesture")[0] != "Nerio: La mia copia non ha la nota.", "the echo spoke after the farewell")
	var settings: Dictionary = save.get("_settings")
	(settings["campaign_dialogues_seen"] as Array).erase("departure")
	state.arena_index = 2
	check(manager.get_character_dialogue("gesture")[0] != "Nerio: La mia copia non ha la nota.", "memory repeated outside first arena")
	state.arena_index = 1
	state.registry_silence_active = true
	check(manager.get_character_dialogue("gesture").is_empty(), "memory spoke during Silence")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("SEAT_COPY_ECHO_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if failures.is_empty() else 1)
