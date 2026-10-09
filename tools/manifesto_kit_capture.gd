extends SceneTree
## Real renderer/input verification of the reusable catalogue, isolated from runs.

const Kit = preload("res://scripts/ui/manifesto_kit.gd")
var failures: Array[String] = []
var output: String = "res://artifacts/ui_kit_2026-10-09/gallery"
var languages: Array[String] = ["it"]

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--all-languages":
			languages = ["it", "en", "es"]
		elif argument.begins_with("--capture-dir="):
			output = argument.trim_prefix("--capture-dir=")
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _settle() -> void:
	await create_timer(0.15).timeout
	for frame: int in range(4):
		await process_frame
	await RenderingServer.frame_post_draw

func _key(pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_ENTER
	event.pressed = pressed
	root.push_input(event, true)

func _pointer(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	root.push_input(motion, true)

func _click(position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	root.push_input(event, true)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var gallery: Control = load("res://tools/manifesto_kit_gallery.tscn").instantiate()
	root.add_child(gallery)
	await _settle()
	var capture_count: int = 0
	for locale: String in languages:
		TranslationServer.set_locale(locale)
		_check(locale == "it" or tr("CONTINUA") != "CONTINUA", "missing translation resources: " + locale)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			await _settle()
			for button: Button in gallery.choices + gallery.routes + gallery.states:
				_check(root.get_visible_rect().encloses(button.get_global_rect()), "button outside viewport: " + locale)
				_check(button.get_node("ManifestoSurface").mouse_filter == Control.MOUSE_FILTER_IGNORE, "skin intercepted input")
				_check(button.scale == Vector2.ONE, "scaled target")
				var title := button.get_node_or_null("PrintedTitle") as Label
				if title != null:
					_check(title.get_line_count() * title.get_line_height() <= title.size.y, "title clipped: " + locale)
			for button: Button in gallery.choices:
				var note: Label = button.get_node("Consequence")
				_check(note.get_line_count() * note.get_line_height() <= note.size.y, "note clipped: " + locale)
			root.get_texture().get_image().save_png(output + "/gallery_%s_%dx%d.png" % [locale, dimensions.x, dimensions.y])
			capture_count += 1
	# The reading/signature family uses the same adapters as the real Registry.
	gallery.show_registry(true)
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.content_scale_size = dimensions
		root.size = dimensions
		await _settle()
		for signature: Button in gallery.registry_buttons:
			_check(root.get_visible_rect().encloses(signature.get_global_rect()), "registry sample outside viewport")
			_check(signature.get_node("ManifestoSurface").mouse_filter == Control.MOUSE_FILTER_IGNORE, "registry sample intercepted input")
			_check(signature.get_node_or_null("PrintedTitle") == null, "compact signature duplicated title")
		for text: RichTextLabel in gallery.registry_texts:
			_check(text.get_content_height() <= text.size.y + 1, "registry reading sample clipped")
		root.get_texture().get_image().save_png(output + "/registry_gallery_%dx%d.png" % [dimensions.x, dimensions.y])
		capture_count += 1
	var selected_sample: Button = gallery.registry_buttons[3]
	var signed_sample: Button = gallery.registry_buttons[4]
	_check(not selected_sample.get_node("ManifestoSurface").get("registered"), "selected sample is registered")
	_check(signed_sample.get_node("ManifestoSurface").get("registered"), "signed sample lacks imprint")
	gallery.show_section(2)
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.content_scale_size = dimensions
		root.size = dimensions
		await _settle()
		for sample: Button in gallery.crowd_buttons:
			_check(root.get_visible_rect().encloses(sample.get_global_rect()), "crowd sample outside viewport")
			_check(sample.get_node("ManifestoSurface").mouse_filter == Control.MOUSE_FILTER_IGNORE, "crowd sample intercepted input")
		root.get_texture().get_image().save_png(output + "/crowd_gallery_%dx%d.png" % [dimensions.x, dimensions.y])
		capture_count += 1
	var response: Button = gallery.crowd_buttons[4]
	var response_rect: Rect2 = response.get_global_rect()
	var response_count: int = response.get_child_count()
	Kit.apply_response(response, &"wax")
	Kit.apply_response(response, &"wax")
	_check(response.get_child_count() == response_count, "response duplicated title or consequence")
	var response_point: Vector2 = response.get_node("Consequence").get_global_rect().get_center()
	_pointer(response_point)
	_click(response_point, true)
	await _settle()
	_check(response.is_pressed(), "response consequence blocked press")
	root.get_texture().get_image().save_png(output + "/crowd_pressed.png")
	capture_count += 1
	_click(response_point, false)
	await _settle()
	_check(gallery.activations == 1, "response mouse emitted wrong number of intents")
	response.grab_focus()
	_key(true)
	_key(false)
	await _settle()
	_check(gallery.activations == 2, "response keyboard emitted wrong number of intents")
	for state: int in [1, 2, 3]:
		gallery.set_response_state(state)
		await _settle()
		for offset: int in range(2):
			var sample: Button = gallery.crowd_buttons[3 + offset]
			_check(not sample.get_node("ManifestoSurface").get("registered"), "selected response became registered")
			_check(sample.get_node("ManifestoSurface").get("selected") == (state == offset + 1), "response lost selected state")
		root.get_texture().get_image().save_png(output + "/crowd_state_%d.png" % state)
		capture_count += 1
	_click(response_point, true)
	_click(response_point, false)
	await _settle()
	_check(gallery.activations == 2, "blocked response emitted intent")
	_check(response.get_global_rect() == response_rect, "response state moved native target")
	gallery.show_section(3)
	gallery.activations = 0
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.content_scale_size = dimensions
		root.size = dimensions
		for state: int in range(6):
			gallery.set_judgment_state(state)
			await _settle()
			var seal: Button = gallery.judgment_seal
			_check(root.get_visible_rect().encloses(seal.get_global_rect()), "seal sample outside viewport")
			_check(seal.get_node_or_null("ManifestoSurface") == null, "native seal replaced by generic action")
			for pip: Panel in gallery.judgment_pips:
				_check(pip.mouse_filter == Control.MOUSE_FILTER_IGNORE and pip.focus_mode == Control.FOCUS_NONE, "socket intercepted input")
			root.get_texture().get_image().save_png(output + "/judgment_gallery_%dx%d_%d.png" % [dimensions.x, dimensions.y, state])
			capture_count += 1
	gallery.set_judgment_state(1)
	await _settle()
	var seal: Button = gallery.judgment_seal
	var seal_rect: Rect2 = seal.get_global_rect()
	var normal_style: StyleBox = seal.get_theme_stylebox("normal")
	var seal_children: int = seal.get_child_count()
	Kit.apply_judgment(gallery.judgment_panel)
	Kit.apply_judgment(gallery.judgment_panel)
	_check(seal.get_theme_stylebox("normal") == normal_style and seal.get_child_count() == seal_children, "type adapter replaced seal or sockets")
	_pointer(seal_rect.get_center())
	_click(seal_rect.get_center(), true)
	_click(seal_rect.get_center(), false)
	await _settle()
	seal.grab_focus()
	_key(true)
	_key(false)
	await _settle()
	_check(gallery.activations == 2, "seal mouse/Enter did not emit one each")
	gallery.set_judgment_state(4)
	await _settle()
	gallery.judgment_advance.grab_focus()
	_key(true)
	_key(false)
	await _settle()
	_check(gallery.activations == 3, "auxiliary sample lost Enter")
	gallery.set_judgment_state(5)
	await _settle()
	_click(seal_rect.get_center(), true)
	_click(seal_rect.get_center(), false)
	await _settle()
	_check(gallery.activations == 3, "disabled seal emitted intent")
	_check(seal.get_global_rect() == seal_rect, "seal states moved target")
	gallery.activations = 0
	gallery.show_registry(false)
	await _settle()
	# Idempotence and input remain properties of the existing Button.
	var button: Button = gallery.choices[2]
	var child_count: int = button.get_child_count()
	Kit.apply_action(button, &"wax", false, false, Kit.TITLE_SMALL)
	Kit.apply_action(button, &"wax", false, false, Kit.TITLE_SMALL)
	_check(button.get_child_count() == child_count, "reapplication duplicated components")
	var original_rect: Rect2 = button.get_global_rect()
	var note: Label = button.get_node("Consequence")
	var point: Vector2 = note.get_global_rect().get_center()
	_pointer(point)
	await _settle()
	_check(button.is_hovered(), "consequence blocked hover")
	_click(point, true)
	await _settle()
	_check(button.is_pressed(), "consequence blocked press")
	root.get_texture().get_image().save_png(output + "/pressed.png")
	_click(point, false)
	await _settle()
	_check(gallery.activations == 1, "click did not emit exactly one intent")
	button.grab_focus()
	_key(true)
	_key(false)
	await _settle()
	_check(gallery.activations == 2, "keyboard did not emit exactly one intent")
	button.disabled = true
	_click(point, true)
	_click(point, false)
	await _settle()
	_check(gallery.activations == 2, "disabled control emitted intent")
	_check(button.get_global_rect() == original_rect, "interaction moved target")
	var report := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"captures": capture_count + 1, "failures": failures}, "\t"))
	report.close()
	gallery.queue_free()
	await process_frame
	print("MANIFESTO_KIT_OK" if failures.is_empty() else "MANIFESTO_KIT_FAILED")
	quit(0 if failures.is_empty() else 1)
