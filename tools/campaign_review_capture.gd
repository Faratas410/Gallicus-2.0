extends SceneTree

# Localized layout fixtures, separate from campaign_runtime_contract's journey.
var scene: Node
var failures: Array[String] = []
var output: String = "res://artifacts/campaign_pass/layout"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var terminal: Node = scene.get_node("UI/RegistryTerminalView")
	for language: int in range(3):
		menu.call("_on_language_selected", language)
		for dimensions: Vector2i in [Vector2i(1280,720), Vector2i(1920,1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			var suffix: String = "%s_%dx%d" % [TranslationServer.get_locale(), dimensions.x, dimensions.y]
			menu.call("_show_achievements")
			menu.call("_on_museo_tab_pressed")
			await _capture("archive_" + suffix)
			if OS.get_cmdline_user_args().has("--archive-only"):
				var scroll: ScrollContainer = menu.get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/MuseoContainer/MuseoScroll")
				scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
				await _capture("archive_bottom_" + suffix)
				scroll.scroll_vertical = 0
				continue
			menu.call("_show_menu")
			terminal.set("_terminal", false)
			terminal.call("_show_surface", false)
			await create_timer(2.2).timeout
			await _capture("silence_" + suffix)
			terminal.get("_return_button").pressed.emit()
			for reduced: bool in [false, true]:
				root.get_node("SaveManager").set_reduced_motion(reduced)
				terminal.set("_terminal", false)
				terminal.call("_show_surface", true)
				await create_timer(2.5).timeout
				await _capture("departure_" + suffix + ("_reduced" if reduced else "_normal"))
				await create_timer(4.0).timeout
				var button: Button = terminal.get("_exit_button")
				if not button.is_visible_in_tree() or not root.get_visible_rect().encloses(button.get_global_rect()):
					failures.append("terminal exit geometry " + suffix)
				await _capture("absence_" + suffix + ("_reduced" if reduced else "_normal"))
			terminal.get("_credits_button").pressed.emit()
			await _capture("credits_" + suffix)
			terminal.get("_credits").hide()
			terminal.set("_terminal", false)
			terminal.call("_hide_surface")
	var manifest := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"failures":failures,"fixture":true}, "\t"))
	manifest.close()
	scene.queue_free()
	await create_timer(0.5).timeout
	quit(1 if not failures.is_empty() else 0)

func _capture(label: String) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "/" + label + ".png")
	print("CAMPAIGN_CAPTURE ", label)
