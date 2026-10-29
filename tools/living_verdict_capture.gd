extends SceneTree
## Disposable presentation fixtures. No profile or gameplay changes are retained.
var output := "res://artifacts/living_verdict/after"
var languages: Array[int] = [0]
var failures: Array[String] = []
var scene: Node
var metrics: Array[Dictionary] = []
var double_intents := 0

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-dir="):
			output = argument.trim_prefix("--capture-dir=")
		if argument == "--all-languages":
			languages = [0, 1, 2]
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.4).timeout
	var ui: Node = scene.get_node("UI")
	var manager: Node = scene.get_node("RunManager")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	root.get_node("SaveManager").set_reduced_motion(true)
	# These are presentation fixtures, not a running PYL phase. Observe the native
	# UI intent without sending it to a manager still in BET_PRESENT. Real routes
	# are verified separately by the unchanged smoke driver.
	root.get_node("GameEvents").request_pyl_double.disconnect(Callable(manager, "_on_request_pyl_double"))
	root.get_node("GameEvents").request_pyl_double.connect(func() -> void: double_intents += 1)
	for language in languages:
		menu.call("_on_language_selected", language)
		root.get_node("GameEvents").request_show_main_menu.emit()
		menu.get("new_game_button").pressed.emit()
		await create_timer(0.5).timeout
		scene.get_node("OpeningPrologue").call("_finish")
		await process_frame
		var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
		var bet: StringName = circle.get("selected_bet_id")
		circle.close()
		var state: RefCounted = manager.get("_run_state")
		state.set("stake_glory", 24)
		state.set("seal_chain", 3)
		ui.call("_on_crowd_favor_changed", {"favor": 3})
		ui.call("_on_ledger_changed", {"denari": 12})
		ui.call("_on_bando_changed", {"status": "open", "posta": 24, "quota": 30, "deadline": 4, "step": 0, "steps": 12})
		for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			var suffix := "%s_%dx%d" % [TranslationServer.get_locale(), dimensions.x, dimensions.y]
			ui.call("show_phase", RunPhaseContract.PUSH_YOUR_LUCK)
			ui.call("_on_escalation_changed", 4, 10)
			var payload: Dictionary = manager.call("_build_push_luck_payload", bet)
			payload.merge({"cashout_locked": false, "cashout_lock_reason": "", "double_locked": false, "double_lock_reason": ""}, true)
			ui.call("_on_push_luck_opened", payload)
			ui.get("arena_theme_title_panel").hide()
			ui.get("arena_theme_subtitle_panel").hide()
			await _capture("choice_" + suffix, ui)
			ui.get("push_luck_double_button").grab_focus()
			await _capture("focus_" + suffix, ui)
			if language == 0:
				root.get_node("SaveManager").set_reduced_motion(false)
				var target: Button = ui.get("push_luck_double_button")
				var native_rect := target.get_global_rect()
				var before_intents := double_intents
				var point: Vector2 = ui.get("push_luck_double_note").get_global_rect().get_center()
				var motion := InputEventMouseMotion.new()
				motion.position = point
				root.push_input(motion)
				await process_frame
				if not target.is_hovered():
					failures.append(suffix + " consequence text intercepts pointer")
				for down: bool in [true, false, true, false]:
					var event := InputEventMouseButton.new()
					event.position = point
					event.button_index = MOUSE_BUTTON_LEFT
					event.pressed = down
					root.push_input(event)
					await process_frame
				if double_intents != before_intents + 1:
					failures.append(suffix + " native double-click emitted wrong intent count")
				if target.get_global_rect() != native_rect:
					failures.append(suffix + " click displaced native target")
				ui.call("_on_push_luck_closed")
				await process_frame
				if get_nodes_in_group("living_verdict_echo").size() != 1:
					failures.append(suffix + " registered gesture lost on synchronous close")
				await _capture("native_click_" + suffix, ui)
				await create_timer(0.15).timeout
				if not get_nodes_in_group("living_verdict_echo").is_empty():
					failures.append(suffix + " transition echo did not expire")
				root.get_node("SaveManager").set_reduced_motion(true)
				ui.call("_on_push_luck_opened", payload)
			ui.call("_set_second_incision_sealed_state", true)
			await _capture("incision_" + suffix, ui)
			ui.call("_on_push_luck_opened", payload)
			ui.call("_set_receipt_taken_state", true)
			await _capture("receipt_" + suffix, ui)
			payload.merge({"cashout_locked": true, "cashout_lock_reason": tr("La folla ti marca: incasso bloccato."), "double_locked": true, "double_lock_reason": tr("Disponibile dopo l'arena in corso.")}, true)
			ui.call("_on_push_luck_opened", payload)
			ui.call("_on_escalation_changed", 9, 10)
			await _capture("blocked_" + suffix, ui)
			if root.gui_get_focus_owner() != ui.get("push_luck_condanna_button"):
				failures.append(suffix + " focus did not skip blocked actions")
			payload.merge({"cashout_locked": false, "cashout_lock_reason": "", "double_locked": false, "double_lock_reason": "", "stake_glory": 123456}, true)
			ui.call("_on_push_luck_opened", payload)
			await _capture("large_stake_" + suffix, ui)
			if language == 0:
				var button: Button = ui.get("push_luck_double_button")
				var target := button.get_global_rect()
				root.get_node("SaveManager").set_reduced_motion(false)
				payload["stake_glory"] = 24
				ui.call("_on_push_luck_opened", payload)
				await _capture("motion_start_" + suffix, ui)
				await create_timer(0.5).timeout
				await _capture("motion_end_" + suffix, ui)
				if ui.get("push_luck_details").text != "24":
					failures.append(suffix + " count did not settle on payload")
				ui.call("_set_second_incision_sealed_state", true)
				await _capture("risk_motion_" + suffix, ui)
				if target != button.get_global_rect():
					failures.append(suffix + " motion displaced native target")
				var atmosphere: Control = ui.get("push_luck_panel").get("atmosphere")
				if float(atmosphere.get("celebration")) > 0:
					failures.append(suffix + " risk falsely celebrated")
				atmosphere.call("present_outcome", true)
				await _capture("held_motion_" + suffix, ui)
				atmosphere.call("present_outcome", false)
				await _capture("broken_motion_" + suffix, ui)
				root.get_node("SaveManager").set_reduced_motion(true)
				var clock_before: float = atmosphere.get("clock")
				await create_timer(0.2).timeout
				if float(atmosphere.get("clock")) != clock_before:
					failures.append(suffix + " reduced motion clock kept moving")
				ui.call("_show_scars_detail")
				await _capture("scars_" + suffix, ui)
				ui.call("_hide_scars_detail")
			ui.call("_on_push_luck_closed")
	var file := FileAccess.open(output + "/result.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"failures": failures, "languages": languages, "metrics": metrics}, "\t"))
	print("LIVING_VERDICT_CAPTURE ", "PASS" if failures.is_empty() else "FAIL", " ", failures)
	scene.get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await create_timer(1.5).timeout
	scene.queue_free()
	await create_timer(0.3).timeout
	quit(0 if failures.is_empty() else 1)

func _capture(label: String, ui: Node) -> void:
	await create_timer(0.22).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image.get_size() != root.size:
		failures.append(label + " image resolution mismatch")
	image.save_png(output + "/" + label + ".png")
	var panel: Control = ui.get("push_luck_panel")
	_check_content(panel, panel.get_global_rect(), label)
	for key in ["cashout", "condanna", "double"]:
		var button: Button = ui.get("push_luck_" + key + "_button")
		if button.is_visible_in_tree() and not root.get_visible_rect().encloses(button.get_global_rect()):
			failures.append(label + " target outside viewport: " + key)
		if button.is_visible_in_tree():
			_check_content(button.get_parent(), button.get_parent().get_global_rect(), label + " " + key)
			metrics.append({"capture": label, "action": key, "target": str(button.get_global_rect()), "note": str(ui.get("push_luck_" + key + "_note").get_global_rect())})

func _check_content(node: Node, bounds: Rect2, label: String) -> void:
	for child in node.get_children():
		if child is Control and child.is_visible_in_tree():
			if child is Label:
				if child.get_line_count() * child.get_line_height() > child.size.y + 1:
					failures.append(label + " clipped text: " + str(child.get_path()))
				if not bounds.grow(2).encloses(child.get_global_rect()):
					failures.append(label + " text outside panel: " + str(child.get_path()))
			_check_content(child, bounds, label)
