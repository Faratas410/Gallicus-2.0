extends SceneTree

const Characters = preload("res://scripts/content/arena_characters.gd")
var failed: bool = false
var capture_dir: String = ""

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	if not value:
		failed = true
		push_error("CHARACTER_CONTRACT: " + message)

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			capture_dir = arg.trim_prefix("--capture-dir=")
			DirAccess.make_dir_recursive_absolute(capture_dir)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.3).timeout
	var manager: Node = scene.get_node("RunManager")
	var ui: Node = scene.get_node("UI")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	root.get_node("SaveManager").set_reduced_motion(true)
	var state: RunState = manager.get("_run_state")
	_check(Characters.CHARACTERS.size() == 5, "expected three owls, a rooster and a hen")
	_check(manager.get_character_dialogue("unknown").is_empty(), "unknown context has dialogue")
	var heard: Dictionary = {}
	for context: String in ["pact", "gesture"]:
		_check(Characters.lines(context, 0, false, true).is_empty(), "terminal has dialogue")
	for language: int in range(3):
		menu.call("_on_language_selected", language)
		for character: Dictionary in Characters.CHARACTERS:
			for key: String in [character.role, character.description]:
				if language > 0: _check(TranslationServer.translate(key) != key, "untranslated character: " + key)
		for size: Vector2i in [Vector2i(1280,720), Vector2i(1920,1080)]:
			root.size = size
			root.content_scale_size = size
			for worn: bool in [false, true]:
				menu.hide()
				ui.show()
				manager.set("_registry_era", 3 if worn else 0)
				for variant: int in range(Characters.variant_count("pact")):
					state.run_seed = variant + 300
					var before: Dictionary = state.to_dict()
					for context: String in ["pact", "gesture"]:
						var lines: Array[String] = manager.get_character_dialogue(context)
						_check(lines.size() == 2, "missing exchange")
						_check(lines == manager.get_character_dialogue(context) and state.to_dict() == before, "dialogue query changed state or selection")
						for line: String in lines:
							heard[line.get_slice(":", 0)] = true
							if language > 0: _check(TranslationServer.translate(line) != line, "untranslated line: " + line)
						if context == "pact":
							ui.call("show_phase", RunPhaseContract.BET_COMMITTED)
							ui.call("_on_pact_sealed_opened")
						else: ui.call("_on_intermediate_choice_opened")
						await process_frame
						await process_frame
						await process_frame
						var label: Label = ui.get("pact_sealed_subtitle" if context == "pact" else "intermediate_choice_audience_label")
						var button: Button = ui.get("pact_sealed_advance_button" if context == "pact" else "intermediate_choice_placa_button")
						var panel: Control = ui.get("pact_sealed_panel" if context == "pact" else "intermediate_choice_panel")
						var tag: String = "%s_%s_%dx%d_%s_%d" % [context, TranslationServer.get_locale(), size.x, size.y, "worn" if worn else "early", variant]
						_check(label.get_line_count() * label.get_line_height() <= label.size.y + 1.0, "clipped dialogue: " + tag)
						_check(label.is_visible_in_tree() and not menu.visible, "dialogue hidden: " + tag)
						_check(panel.get_global_rect().encloses(button.get_global_rect()), "dialogue displaced action: " + tag)
						_check(label.text.contains(lines[0].get_slice(":", 0)), "speaker missing: " + tag)
						if capture_dir != "":
							await RenderingServer.frame_post_draw
							root.get_texture().get_image().save_png(capture_dir.path_join(tag + ".png"))
			menu.show()
			menu.call("_show_achievements")
			menu.call("_on_museo_tab_pressed")
			await process_frame
			await process_frame
			if capture_dir != "":
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(capture_dir.path_join("archive_%s_%dx%d.png" % [TranslationServer.get_locale(), size.x, size.y]))
			var archive: VBoxContainer = menu.get("museo_vbox")
			var scroll: ScrollContainer = archive.get_parent()
			for character: Dictionary in Characters.CHARACTERS:
				var found: bool = false
				for entry: Node in archive.get_children():
					if entry.get_child_count() == 0 or not entry.get_child(0) is Label:
						continue
					var biography: Label = entry.get_child(0)
					if not biography.text.begins_with(character.name + " — "):
						continue
					found = true
					scroll.ensure_control_visible(entry)
					await process_frame
					await process_frame
					_check(biography.get_line_count() * biography.get_line_height() <= biography.size.y + 1.0, "clipped biography: " + character.name)
					_check(scroll.get_global_rect().encloses(biography.get_global_rect()), "unreachable biography: " + character.name)
					if capture_dir != "" and character.id in ["rugo", "dima"]:
						await RenderingServer.frame_post_draw
						root.get_texture().get_image().save_png(capture_dir.path_join("archive_%s_%s_%dx%d.png" % [character.id, TranslationServer.get_locale(), size.x, size.y]))
				_check(found, "missing archive character: " + character.name)
			scroll.scroll_vertical = 0
			menu.call("_show_menu")
	state.registry_silence_active = true
	_check(manager.get_character_dialogue("pact").is_empty(), "Silence has dialogue")
	state.registry_silence_active = false
	for character: Dictionary in Characters.CHARACTERS:
		_check(heard.has(character.name), "unreachable speaker: " + character.name)
	var music: Node = scene.get_node("MusicDirector")
	music.call("_kill_fade")
	for player: AudioStreamPlayer in music.get("_players"): player.stop()
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	# Drain the modal reading timers before releasing their button references.
	await create_timer(1.5).timeout
	scene.queue_free()
	await create_timer(0.3).timeout
	if not failed: print("CHARACTER_RUNTIME_CONTRACT_OK")
	quit(1 if failed else 0)
