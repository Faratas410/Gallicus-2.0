extends "res://tools/visual_qa_capture.gd"

const AV_OUTPUT: String = "res://artifacts/av_pass/screenshots"

func _capture(name: String, expected_size: Vector2i = Vector2i.ZERO) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(AV_OUTPUT))
	await _settle(6)
	await _save_av_frame(name, expected_size)
	if name.begins_with("06_judgment_") and name.ends_with("_focus"):
		var ui: Node = get_tree().root.get_node(UI_ROOT_PATH)
		var menu: Node = get_tree().root.get_node("Main/MenuLayer/MainMenu")
		# Base matrices change TranslationServer directly; keep the isolated profile in sync.
		SaveManager.set_language(TranslationServer.get_locale())
		menu.call("_on_reduced_motion_toggled", false)
		# Settings trigger a deferred UI refresh, which clears prior phase feedback.
		await _settle(3)
		var seal: Control = get_tree().root.get_node(JUDGMENT_SEAL_BUTTON_PATH) as Control
		seal.grab_focus()
		ui.call("_play_sfx", &"registry_judgment_seal_strike")
		await get_tree().create_timer(0.08).timeout
		var feedback: Node = get_tree().get_first_node_in_group("ritual_feedback")
		var visible_dust: bool = false
		for sprite: Node in feedback.get_children():
			if sprite is TextureRect and sprite.visible and sprite.modulate.a > 0.0:
				visible_dust = true
		if not visible_dust:
			_failures.append("No visible dust: " + name)
		await _save_av_frame(name + "_dust", expected_size)
		menu.call("_on_reduced_motion_toggled", true)
		ui.call("_play_sfx", &"registry_judgment_seal_strike")
		await _settle(2)
		for sprite: Node in feedback.get_children():
			if sprite is TextureRect and sprite.visible:
				_failures.append("Dust survived reduced motion: " + name)
		await _save_av_frame(name + "_reduced", expected_size)
		menu.call("_on_reduced_motion_toggled", false)

func _save_av_frame(name: String, expected_size: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	var captured: Image = get_tree().root.get_texture().get_image()
	if captured == null or captured.is_empty() or (expected_size != Vector2i.ZERO and captured.get_size() != expected_size):
		_failures.append("Invalid screenshot: " + name)
		return
	if captured.save_png("%s/%s.png" % [AV_OUTPUT, name]) != OK:
		_failures.append("Could not save: " + name)
	print("AV_CAPTURE ", name)

func _cleanup_capture_scene() -> void:
	if is_instance_valid(_main):
		var director: Node = _main.get_node_or_null("MusicDirector")
		if director != null:
			director.call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
		get_node("/root/SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
		await get_tree().create_timer(0.2).timeout
	await super._cleanup_capture_scene()
