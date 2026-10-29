extends SceneTree
## Integrated utility/dialogue fixtures. Always use a disposable user profile.

var output: String = "res://artifacts/manifesto_review_2026-10-15/utility"
var failures: Array[String] = []
var captures: Array[String] = []
var scene: Node
var capture_size := Vector2i(1280, 720)

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			output = argument.trim_prefix("--capture-dir=")
	call_deferred("_run")

func _settle() -> void:
	await create_timer(0.2).timeout
	for frame: int in range(4):
		await process_frame
	await RenderingServer.frame_post_draw

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _capture(label: String) -> void:
	# Opening settings reapplies the saved window size; restore the fixture.
	DisplayServer.window_set_size(capture_size)
	root.content_scale_size = capture_size
	root.size = capture_size
	await _settle()
	var picture: Image = root.get_texture().get_image()
	_check(picture.get_size() == capture_size, label + ": image size")
	picture.save_png(output + "/" + label + ".png")
	captures.append(label)

func _visible_targets(node: Node, label: String) -> void:
	if node is Control and not node.is_visible_in_tree():
		return
	if node is BaseButton or node is Slider:
		var target := node as Control
		_check(root.get_visible_rect().encloses(target.get_global_rect()), label + ": target outside viewport " + str(target.get_path()))
		_check(target.scale == Vector2.ONE, label + ": scaled target")
	for child: Node in node.get_children():
		_visible_targets(child, label)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await _settle()
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var dialogue: Node = scene.get_node("OpeningPrologue")
	for locale: String in ["it", "en", "es"]:
		var language: OptionButton = menu.get("language_option")
		var index: int = 0
		for candidate: int in range(language.item_count):
			if str(language.get_item_metadata(candidate)) == locale:
				index = candidate
		language.select(index)
		language.item_selected.emit(index)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			capture_size = dimensions
			root.content_scale_size = dimensions
			root.size = dimensions
			var suffix := "%s_%dx%d" % [locale, dimensions.x, dimensions.y]
			menu.call("_show_menu")
			await _capture("01_menu_" + suffix)
			_visible_targets(menu, suffix)
			menu.get("settings_button").pressed.emit()
			await _capture("02_settings_" + suffix)
			_visible_targets(menu, suffix)
			menu.get("master_volume_slider").grab_focus()
			await _capture("03_slider_focus_" + suffix)
			for key: String in ["language_option", "resolution_option"]:
				var option: OptionButton = menu.get(key)
				option.show_popup()
				await _settle()
				var popup: PopupMenu = option.get_popup()
				popup.set_focused_item(0)
				await _settle()
				popup.get_texture().get_image().save_png(output + "/04_popup_" + key + "_" + suffix + ".png")
				captures.append("04_popup_" + key + "_" + suffix)
				popup.hide()
			menu.get("settings_back_button").pressed.emit()
			menu.get("credits_button").pressed.emit()
			await _capture("05_credits_" + suffix)
			_visible_targets(menu, suffix)
			menu.get("credits_back_button").pressed.emit()
			menu.get("achievements_button").pressed.emit()
			await _capture("06_archive_" + suffix)
			menu.call("_on_condanna_mouse_entered", preload("res://data/condanne.gd").defaults()[0])
			menu.call("_place_condanna_tooltip", Vector2(dimensions) - Vector2(2, 2))
			await _capture("07_tooltip_" + suffix)
			menu.call("_on_condanna_mouse_exited")
			menu.get("museo_tab_button").pressed.emit()
			await _capture("08_museum_" + suffix)
			_visible_targets(menu, suffix)
			menu.get("back_button").pressed.emit()
			await _settle()
			# Dialogue fixture: the runtime contract separately exercises real flow.
			dialogue.set("_payload", preload("res://scripts/content/campaign_dialogues.gd").SEQUENCES.entry.duplicate(true))
			dialogue.set("_active", true)
			dialogue.set("_beat", 0)
			dialogue.get("_surface").show()
			dialogue.call("_refresh_line")
			dialogue.get("_next").disabled = false
			dialogue.get("_skip").disabled = false
			dialogue.get("_next").grab_focus()
			await _capture("09_dialogue_" + suffix)
			var caption: Label = dialogue.get("_caption")
			_check(caption.get_line_count() * caption.get_line_height() <= caption.size.y, suffix + ": dialogue clipped")
			dialogue.call("_cancel")
	scene.queue_free()
	await process_frame
	var gallery: Control = load("res://tools/manifesto_kit_gallery.tscn").instantiate()
	root.add_child(gallery)
	gallery.show_section(4)
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		capture_size = dimensions
		root.content_scale_size = dimensions
		root.size = dimensions
		await _capture("10_controls_gallery_%dx%d" % [dimensions.x, dimensions.y])
		_visible_targets(gallery, "controls gallery")
	gallery.queue_free()
	await process_frame
	var report := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"fixture": true, "captures": captures, "failures": failures}, "\t"))
	print("MANIFESTO_REVIEW ", captures.size(), " captures; ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
