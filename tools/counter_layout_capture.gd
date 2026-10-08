extends SceneTree

# Presentation-only fixtures; run this with a disposable APPDATA profile.
const Scars = preload("res://scripts/content/scar_catalog.gd")
var scene: Node
var output: String = "res://artifacts/manifesto_material_2026-10-08/layout"
var languages: Array[int] = [0] # Temporary Italian-only review; --all-languages restores the full matrix.
var failures: Array[String] = []
var captures: int = 0

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--all-languages":
			languages = [0, 1, 2]
		elif argument.begins_with("--capture-dir="):
			output = argument.trim_prefix("--capture-dir=")
	call_deferred("_run")

func _pointer(position: Vector2, held: bool = false) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	root.push_input(event, true)

func _mouse_button(position: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	root.push_input(event, true)

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _capture(label: String) -> void:
	await create_timer(0.15).timeout
	# A wall-time delay may elapse in one slow render frame. Let native
	# translated text and container minimum sizes settle before capture.
	for frame: int in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	_validate_layout(label)
	var picture := root.get_texture().get_image()
	_check(picture.get_size() == root.size, "unexpected image dimensions: " + label)
	picture.save_png(output + "/" + label + ".png")
	captures += 1

func _validate_layout(label: String) -> void:
	var ui: Node = scene.get_node("UI")
	var rail: Control = ui.get_node("HUD/PressureRail")
	var side: Array[Control] = [ui.get("bando_panel"), ui.get("crowd_favor_panel"), ui.get("scars_panel")]
	for index: int in range(side.size()):
		var panel: Control = side[index]
		if not panel.is_visible_in_tree():
			continue
		_check(root.get_visible_rect().encloses(panel.get_global_rect()), label + " margin outside viewport " + panel.name)
		for other: Control in side.slice(index + 1):
			if other.is_visible_in_tree():
				_check(not panel.get_global_rect().intersects(other.get_global_rect()), label + " overlapping margin " + panel.name + "/" + other.name)
		if rail.is_visible_in_tree():
			_check(not panel.get_global_rect().intersects(rail.get_global_rect()), label + " margin hits rail " + panel.name)
	for key: String in ["push_luck_panel", "intermediate_choice_panel", "game_over_panel", "pact_sealed_panel", "resolve_ritual_panel"]:
		var panel: Control = ui.get(key)
		if panel == null or not panel.is_visible_in_tree():
			continue
		_check(root.get_visible_rect().encloses(panel.get_global_rect()), label + " panel outside viewport " + key)
		for margin: Control in side:
			if margin.is_visible_in_tree() and key != "push_luck_panel":
				_check(not panel.get_global_rect().intersects(margin.get_global_rect()), label + " panel overlaps context " + key)
		_check_content(panel, panel.get_global_rect(), label)
		if key == "push_luck_panel":
			for button: Button in [ui.get("push_luck_cashout_button"), ui.get("push_luck_condanna_button"), ui.get("push_luck_double_button")]:
				if not button.is_visible_in_tree():
					continue
				var card: Control = button.get_parent()
				_check(card.get_global_rect().grow(1).encloses(button.get_global_rect()), label + " action outside printed surface " + button.name)
				_check_content(card, card.get_global_rect(), label + " action")
				var action_note := card.get_child(1).get_child(0) as Label
				_check(action_note.get_global_rect().position.y + action_note.get_line_count() * action_note.get_line_height() <= card.get_global_rect().end.y - 8, label + " note lacks bottom padding")
				for margin: Control in side:
					_check(not card.get_global_rect().intersects(margin.get_global_rect()), label + " action hits margin")
				_check(not card.get_global_rect().intersects(rail.get_global_rect()), label + " action hits footer")
	var circle: Control = scene.get_node("UI/UI_RunRoot/BettingCircle")
	if circle.visible:
		var book: Control = circle.get("book_frame")
		for margin: Control in side:
			if margin.is_visible_in_tree():
				_check(not book.get_global_rect().intersects(margin.get_global_rect()), label + " book overlaps margin")
		for key: String in ["left_contract_label", "right_contract_label"]:
			var text: RichTextLabel = circle.get(key)
			if text.is_visible_in_tree():
				_check(text.get_content_height() <= text.size.y + 1, label + " contract text clipped")

func _check_content(node: Node, bounds: Rect2, context: String) -> void:
	for child: Node in node.get_children():
		if child is Control and child.is_visible_in_tree():
			if child is Label:
				_check(child.get_line_count() * child.get_line_height() <= child.size.y + 1, context + " text clipped " + child.name)
			if child is Label or child is Button:
				_check(bounds.grow(1).encloses(child.get_global_rect()), context + " content outside panel " + child.name)
			if not child is ScrollContainer:
				_check_content(child, bounds, context)

func _run() -> void:
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
	root.get_node("SaveManager").set_reduced_motion(true)
	for language: int in languages:
		menu.call("_on_language_selected", language)
		menu.hide()
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			var suffix: String = "%s_%dx%d" % [TranslationServer.get_locale(), dimensions.x, dimensions.y]
			root.get_node("GameEvents").request_show_main_menu.emit()
			menu.get("new_game_button").pressed.emit()
			await create_timer(0.6).timeout
			dialogue.call("_finish")
			await process_frame
			ui.call("_refresh_scars_ui", [])
			circle.call("_on_bando_changed", {"status": "open", "denari": 5, "quota": 10, "deadline": 4, "step": 0, "steps": 12})
			for balance: int in [-5, 20]:
				var items: Array[Dictionary] = []
				for item_id: String in ["favor", "pressure", "insure"]:
					var item: Dictionary = manager.BANCO_ITEMS[item_id].duplicate()
					item["id"] = item_id
					item["available"] = balance >= int(item.price)
					items.append(item)
				circle.call("_on_ledger_changed", {"banco": {"denari": balance, "open": true, "in_debt": balance < 0, "items": items}})
				await _capture("banco_%d_%s" % [balance, suffix])
				var note: Label = circle.get("banco_note")
				_check(note.get_line_count() * note.get_line_height() <= note.size.y + 1, "bank note clipped " + suffix)
			circle.call("_on_open_book_pressed")
			await create_timer(0.8).timeout
			await _capture("signature_" + suffix)
			var fixture_bet: StringName = circle.get("selected_bet_id")
			circle.call("_set_promise_signature_state", circle.get("left_sign_button"), &"signed")
			await _capture("signature_signed_" + suffix)
			circle.close()
			ui.call("_on_pact_sealed_opened")
			await _capture("pact_" + suffix)
			ui.call("_on_pact_sealed_closed")
			ui.call("_on_resolve_ritual_opened", {})
			await create_timer(0.8).timeout
			await _capture("judgment_" + suffix)
			ui.call("_on_resolve_ritual_closed")
			ui.call("_on_intermediate_choice_opened")
			await create_timer(1.2).timeout
			await _capture("gesture_" + suffix)
			ui.get("intermediate_choice_provoca_button").grab_focus()
			await _capture("gesture_focus_" + suffix)
			ui.call("_set_intermediate_choice_modal", false)
			await process_frame
			# Dense state includes live metadata, the actual payload factory and two scars.
			var state: RefCounted = manager.get("_run_state")
			state.set("stake_glory", 4)
			state.set("corruption", 1)
			var scars: Array = []
			for id: StringName in [&"CRACKED_BONES", &"ONE_EYE"]:
				var scar: Dictionary = Scars.new().get_scar(id).duplicate(true)
				scars.append(scar)
			ui.call("_refresh_scars_ui", scars)
			ui.call("_on_crowd_favor_changed", {"favor": 4, "note": "Il sigillo ha retto: la gradinata approva."})
			ui.call("_on_bando_changed", {"status": "open", "posta": 4, "quota": 10, "deadline": 4, "next_quota": 10, "next_deadline": 4, "step": 0, "steps": 12, "prize_tale": "Il conto di Vessa"})
			var hud_before: Dictionary = {}
			for hud_name: String in ["BandoPanel", "CrowdFavorPanel", "ScarsPanel", "PressureRail"]:
				var hud: Control = ui.get_node("HUD/" + hud_name)
				hud_before[hud_name] = [hud.anchor_left, hud.anchor_top, hud.anchor_right, hud.anchor_bottom, hud.offset_left, hud.offset_top, hud.offset_right, hud.offset_bottom]
			ui.call("show_phase", RunPhaseContract.PUSH_YOUR_LUCK)
			var payload: Dictionary = manager.call("_build_push_luck_payload", fixture_bet)
			payload.merge({"cashout_locked": false, "cashout_lock_reason": "", "double_locked": false, "double_lock_reason": "", "audience_label": tr("FOLLA IN DELIRIO"), "cashout_glory_delta": 4, "cashout_corruption_delta": 1}, true)
			ui.call("_on_push_luck_opened", payload)
			# The fixture skips the arena transition; suppress its intro overlay.
			ui.get("arena_theme_title_panel").hide()
			ui.get("arena_theme_subtitle_panel").hide()
			await _capture("receipt_" + suffix)
			ui.call("_show_scar_popup", scars[0])
			await _capture("receipt_notice_" + suffix)
			ui.call("_hide_scar_popup")
			ui.get("push_luck_double_button").grab_focus()
			await _capture("double_focus_" + suffix)
			var double_button: Button = ui.get("push_luck_double_button")
			double_button.release_focus()
			var note: Label = ui.get("push_luck_double_note")
			var target: Vector2 = note.get_global_rect().get_center()
			_pointer(target)
			await _capture("double_hover_" + suffix)
			_check(double_button.is_hovered(), "note area does not reach button")
			_mouse_button(target, true)
			await _capture("double_pressed_" + suffix)
			_check(double_button.is_pressed(), "note area does not press button")
			_pointer(Vector2(640, 60), true)
			_mouse_button(Vector2(640, 60), false)
			await process_frame
			var stable: Rect2 = ui.get("push_luck_double_button").get_global_rect()
			root.get_node("SaveManager").set_reduced_motion(false)
			ui.call("_on_sign_preview_entered", ui.get("push_luck_double_button"))
			_check(ui.get("push_luck_double_button").scale == Vector2.ONE, "manifesto hover moved target")
			root.get_node("SaveManager").set_reduced_motion(true)
			ui.call("_on_escalation_changed", 9, 10)
			state.set("stake_glory", 1234)
			state.set("escalation_level", 9)
			ui.call("_on_escalation_changed", 9, 10)
			payload = manager.call("_build_push_luck_payload", fixture_bet)
			payload.merge({"cashout_locked": false, "double_locked": false}, true)
			ui.call("_on_push_luck_opened", payload)
			await _capture("pressure_large_stake_" + suffix)
			_check(ui.get("push_luck_double_button").get_global_rect() == stable, "pressure moved action target")
			state.set("stake_glory", 4)
			state.set("escalation_level", 0)
			ui.call("_on_escalation_changed", 0, 10)
			payload = manager.call("_build_push_luck_payload", fixture_bet)
			payload.merge({"cashout_locked": false, "cashout_lock_reason": "", "double_locked": false, "double_lock_reason": "", "cashout_glory_delta": 4, "cashout_corruption_delta": 1}, true)
			ui.call("_on_push_luck_opened", payload)
			ui.call("_set_second_incision_sealed_state", true)
			ui.get("push_luck_double_button").disabled = true
			await _capture("incision_registered_" + suffix)
			ui.call("_on_escalation_changed", 0, 10)
			ui.call("_on_push_luck_opened", payload)
			ui.call("_set_receipt_taken_state", true)
			ui.get("push_luck_cashout_button").disabled = true
			await _capture("receipt_registered_" + suffix)
			payload.merge({"cashout_locked": true, "cashout_lock_reason": tr("La folla ti marca: incasso bloccato."), "double_locked": true, "double_lock_reason": tr("Disponibile dopo l'arena in corso.")}, true)
			ui.call("_on_push_luck_opened", payload)
			await _capture("blocked_" + suffix)
			ui.call("_show_scars_detail")
			await _capture("scars_detail_" + suffix)
			ui.call("_hide_scars_detail")
			ui.call("show_phase", RunPhaseContract.GAME_OVER)
			for hud_name: String in hud_before:
				var hud: Control = ui.get_node("HUD/" + hud_name)
				_check(hud_before[hud_name] == [hud.anchor_left, hud.anchor_top, hud.anchor_right, hud.anchor_bottom, hud.offset_left, hud.offset_top, hud.offset_right, hud.offset_bottom], "HUD not restored: " + hud_name)
			for outcome: StringName in [&"CASHOUT", &"LOSS", &"WIN"]:
				ui.call("_on_run_finale_selected", {"outcome": outcome, "glory": 4, "scars": scars, "pacts_signed": [fixture_bet], "last_crowd_line": "Hai spento la corsa. La folla voleva il salto.", "meta": {"register_final": false, "next_bet_enabled": outcome == &"WIN"}})
				await ui.call("_on_run_failed")
				await _capture("dossier_%s_%s" % [outcome, suffix])
				if outcome == &"CASHOUT":
					ui.get("quit_button").grab_focus()
					await _capture("dossier_utility_focus_" + suffix)
				for key: String in ["verdict_sentence_label", "verdict_charge_label"]:
					var label: Label = ui.get(key)
					_check(label.is_visible_in_tree() and label.modulate.a > 0.9, "dossier not visible " + suffix + key)
					_check(label.get_line_count() * label.get_line_height() <= label.size.y + 1, "dossier clipped " + suffix + key)
			ui.call("_on_run_finale_selected", {"outcome": &"LOSS", "glory": 4, "scars": scars, "meta": {"register_final": true, "register_ending_key": "ending_scars", "next_bet_enabled": false}})
			await ui.call("_on_run_failed")
			await _capture("dossier_closed_" + suffix)
	var report := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"fixture": true, "captures": captures, "failures": failures}, "\t"))
	report.close()
	scene.get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await create_timer(1.6).timeout
	scene.queue_free()
	await create_timer(0.3).timeout
	if failures.is_empty(): print("COUNTER_LAYOUT_OK ", captures)
	quit(0 if failures.is_empty() else 1)

