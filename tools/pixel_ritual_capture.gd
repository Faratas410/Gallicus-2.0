extends "res://tools/counter_layout_capture.gd"
## Native presentation matrix plus the inherited real-manager keyboard route.
## Run in isolated APPDATA/LOCALAPPDATA; no personal save is read or written.

func _run() -> void:
	output = "res://artifacts/pixel_ritual/final"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.3).timeout
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
	var dialogue: Node = scene.get_node("OpeningPrologue")
	var ui: Node = scene.get_node("UI")
	var manager: Node = scene.get_node("RunManager")
	var events: Node = root.get_node("GameEvents")
	for language: int in [0, 1, 2]:
		menu.call("_on_language_selected", language)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.get_node("SaveManager").set_reduced_motion(dimensions.x == 1280)
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			var suffix := "%s_%d" % [TranslationServer.get_locale(), dimensions.x]
			events.request_show_main_menu.emit()
			menu.get("new_game_button").pressed.emit()
			await create_timer(0.6).timeout
			dialogue.call("_finish")
			await process_frame
			circle.close()
			ui.call("_on_pact_sealed_opened")
			await _capture("pact_" + suffix)
			ui.call("_on_pact_sealed_closed")
			ui.call("_on_intermediate_choice_opened")
			await create_timer(0.5).timeout
			ui.get("intermediate_choice_provoca_button").grab_focus()
			await _capture("gesture_" + suffix)
			for intent_id: String in ["blood", "sand", "breath"]:
				var intent: Dictionary = manager.CROWD_INTENTS[intent_id]
				ui.set("_gesture_exchange", {"placa_text": intent.placa.text, "provoca_text": intent.provoca.text})
				ui.call("_refresh_gesture_choice_copy")
				await _capture("gesture_" + intent_id + "_" + suffix)
			ui.call("_set_intermediate_choice_modal", false)
			ui.set("_pending_resolution_context_line", "Il tuo gesto li irrita. Ora vogliono il prezzo.")
			ui.call("_on_resolve_ritual_opened", {"doom_short": "Pressione +1"})
			await _capture("judgment_" + suffix)
			var stable: Rect2 = ui.get("resolve_ritual_strike_button").get_global_rect()
			for strike: int in [1, 2]:
				ui.call("_on_seal_strike_resolved", {"strike": strike, "held": true, "held_gain": strike + 1, "can_strike_again": true, "next_odds": manager.SEAL_EXTRA_STRIKE_ODDS[strike - 1], "next_gain": 3, "bando_strike": true, "chain": 2, "chain_multiplier": 1.5})
				await _capture("judgment_held_%d_" % strike + suffix)
				_check(ui.get("resolve_ritual_strike_button").get_global_rect() == stable, "strike moved target " + suffix)
			ui.call("_reset_resolution_ritual_interaction")
			ui.call("_on_seal_strike_resolved", {"strike": 1, "held": false, "can_show_scar": true})
			ui.get("resolve_ritual_advance_button").grab_focus()
			await _capture("judgment_scar_" + suffix)
			ui.call("_on_seal_strike_resolved", {"strike": 3, "held": true, "held_gain": 4})
			await _capture("judgment_full_" + suffix)
			ui.call("_on_resolve_ritual_closed")
	await _run_pact_crowd_flow(menu, circle, dialogue, ui, manager)
	await _finish_capture()

func _capture(label: String) -> void:
	await super._capture(label)
	var ui: Node = scene.get_node("UI")
	var factor: float = root.get_visible_rect().size.x / 1280.0
	for key: String in ["pact_sealed_panel", "intermediate_choice_panel", "resolve_ritual_panel"]:
		var panel: Control = ui.get(key)
		if panel.is_visible_in_tree():
			_check(panel.scale.is_equal_approx(Vector2.ONE * factor), "ritual scale changed " + label)
			_check(is_equal_approx(panel.get_global_rect().position.y, 128 * factor), "ritual overlaps HUD " + label)
	if ui.get("resolve_ritual_panel").is_visible_in_tree():
		var body: Label = ui.get("resolve_ritual_subtitle")
		var prompt: Label = ui.get("resolve_ritual_prompt")
		var action: Button = ui.get("resolve_ritual_advance_button")
		_check(body.get_line_count() * body.get_line_height() <= 180, "rite writing exceeds paper " + label)
		_check(prompt.get_line_count() * prompt.get_line_height() <= 60, "rite prompt exceeds paper " + label)
		_check(not body.get_global_rect().intersects(prompt.get_global_rect()), "rite prompt overlaps body " + label)
		if action.is_visible_in_tree():
			_check(not body.get_global_rect().intersects(action.get_global_rect()), "rite body overlaps action " + label)
	for key: String in ["pact_sealed_advance_button", "intermediate_choice_placa_button", "intermediate_choice_provoca_button", "resolve_ritual_strike_button", "resolve_ritual_advance_button"]:
		var button: Button = ui.get(key)
		if not button.is_visible_in_tree(): continue
		var skin: Control = button.get_node("PixelRitualObject")
		for text_label: Label in [skin.get("heading"), skin.get("consequence")]:
			if text_label.text.is_empty(): continue
			_check(text_label.get_line_count() * text_label.get_line_height() <= text_label.size.y + 1, "object inscription clipped " + key + " " + label)
		_check(button.scale == Vector2.ONE, "focus moved native target " + key + " " + label)
