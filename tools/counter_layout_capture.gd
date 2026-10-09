extends SceneTree

# Presentation-only fixtures; run this with a disposable APPDATA profile.
const Scars = preload("res://scripts/content/scar_catalog.gd")
var scene: Node
var output: String = "res://artifacts/manifesto_material_2026-10-08/layout"
var languages: Array[int] = [0] # Temporary Italian-only review; --all-languages restores the full matrix.
var failures: Array[String] = []
var captures: int = 0
var registry_only: bool = false
var pact_crowd_only: bool = false
var pact_crowd_flow_only: bool = false
var judgment_only: bool = false
var judgment_intents: Array[String] = []
var sign_intents: int = 0
var bank_intents: int = 0
var metrics: Array[Dictionary] = []

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--all-languages":
			languages = [0, 1, 2]
		elif argument == "--registry-only":
			registry_only = true
		elif argument == "--pact-crowd-only":
			pact_crowd_only = true
		elif argument == "--pact-crowd-flow-only":
			pact_crowd_flow_only = true
		elif argument == "--judgment-only":
			judgment_only = true
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
		_check(root.get_visible_rect().encloses(book.get_global_rect()), label + " registry outside viewport")
		_check_content(book, book.get_global_rect(), label + " registry")
		for margin: Control in side:
			if margin.is_visible_in_tree():
				_check(not book.get_global_rect().intersects(margin.get_global_rect()), label + " book overlaps margin")
		for key: String in ["left_contract_label", "right_contract_label"]:
			var text: RichTextLabel = circle.get(key)
			if text.is_visible_in_tree():
				var overflow: bool = text.get_content_height() > text.size.y + 1
				_check(not overflow or text.scroll_active, label + " contract text clipped")
				metrics.append({"capture": label, "node": text.name, "height": text.size.y, "content_height": text.get_content_height(), "scroll": text.scroll_active})
		for button: Button in (circle.get("banco_row") as HBoxContainer).get_children():
			if button.is_visible_in_tree():
				_check(book.get_global_rect().encloses(button.get_global_rect()), label + " bank service outside document")
				_check(button.get_global_rect().grow(1).encloses(button.get_node("ManifestoSurface").get_global_rect()) if button.has_node("ManifestoSurface") else true, label + " service skin outside target")
				metrics.append({"capture": label, "node": button.name, "rect": str(button.get_global_rect()), "minimum": str(button.get_combined_minimum_size())})

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
	if judgment_only:
		await _run_judgment_matrix(menu, circle, dialogue, ui, manager)
		await _finish_capture()
		return
	if pact_crowd_only or pact_crowd_flow_only:
		if not pact_crowd_flow_only:
			await _run_pact_crowd_matrix(menu, circle, dialogue, ui)
		await _run_pact_crowd_flow(menu, circle, dialogue, ui, manager)
		await _finish_capture()
		return
	if registry_only:
		await _run_registry_matrix(menu, circle, dialogue, ui, manager)
		await _finish_capture()
		return
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
	await _finish_capture()

func _registry_start(menu: Node, dialogue: Node) -> void:
	root.get_node("GameEvents").request_show_main_menu.emit()
	menu.get("new_game_button").pressed.emit()
	await create_timer(0.6).timeout
	dialogue.call("_finish")
	await process_frame

func _count_sign_intent(_bet_id: String, _stake: int) -> void:
	sign_intents += 1

func _count_bank_intent(_item_id: String) -> void:
	bank_intents += 1

func _run_registry_matrix(menu: Node, circle: Node, dialogue: Node, ui: Node, manager: Node) -> void:
	root.get_node("GameEvents").request_place_bet.connect(_count_sign_intent)
	root.get_node("GameEvents").request_banco_purchase.connect(_count_bank_intent)
	for language: int in languages:
		menu.call("_on_language_selected", language)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			for reduced: bool in [true, false]:
				root.get_node("SaveManager").set_reduced_motion(reduced)
				var suffix: String = "%s_%dx%d_%s" % [TranslationServer.get_locale(), dimensions.x, dimensions.y, "reduced" if reduced else "motion"]
				await _registry_start(menu, dialogue)
				ui.call("_refresh_scars_ui", [])
				# Same catalogue data for every before/after view. Keep genuine offers
				# separately for the final request through RunManager.
				var live_offers: Array[Dictionary] = []
				for offer: Dictionary in circle.get("_betting_circle_options"):
					live_offers.append(offer.source.duplicate(true))
				circle.call("_rebuild_options_from_catalog")
				var display_offers: Array[Dictionary] = []
				for offer: Dictionary in circle.get("_betting_circle_options"):
					var source: Dictionary = offer.source.duplicate(true)
					source["seal_conditions"] = live_offers[0].get("seal_conditions", {}).duplicate(true)
					display_offers.append(source)
				circle.set_offers(display_offers)
				circle.call("_on_bando_changed", {"status": "open", "denari": 5, "quota": 10, "deadline": 4, "step": 0, "steps": 12})
				for balance: int in [-5, 0, 20]:
					var items: Array[Dictionary] = []
					for item_id: String in ["favor", "pressure", "insure"]:
						var item: Dictionary = manager.BANCO_ITEMS[item_id].duplicate()
						item["id"] = item_id
						item["available"] = balance >= int(item.price)
						items.append(item)
					circle.call("_on_ledger_changed", {"banco": {"denari": balance, "open": true, "in_debt": balance < 0, "items": items}})
					await _capture("registry_bank_%d_%s" % [balance, suffix])
					var service: Button = (circle.get("banco_row") as HBoxContainer).get_child(0)
					_mouse_button(service.get_global_rect().get_center(), true)
					_mouse_button(service.get_global_rect().get_center(), false)
					await process_frame
					_check(bank_intents == (1 if balance == 20 else 0), "bank activation count: " + suffix)
					bank_intents = 0
					# This matrix supplies presentation availability, not extra money.
					# The real manager may reject the request for insufficient funds.
				var opening: Button = circle.get("open_book_button")
				var opening_rect: Rect2 = opening.get_global_rect()
				_pointer(opening_rect.get_center())
				await _capture("registry_open_hover_" + suffix)
				_mouse_button(opening_rect.get_center(), true)
				await _capture("registry_open_pressed_" + suffix)
				_check(opening.get_global_rect() == opening_rect, "opening target moved: " + suffix)
				_mouse_button(opening_rect.get_center(), false)
				await process_frame
				if not reduced:
					_check(bool(circle.get("_opening_locked")), "opening lock missing: " + suffix)
					_check((circle.get("left_sign_button") as Button).disabled, "signature enabled during reveal: " + suffix)
				await create_timer(1.4).timeout
				_check(not bool(circle.get("_opening_locked")), "opening did not unlock: " + suffix)
				await _capture("registry_selected_left_" + suffix)
				if (circle.get("left_page") as Control).get_node("LeftPaper").has_node("ManifestoDocument"):
					var document: Control = (circle.get("left_page") as Control).get_node("LeftPaper/ManifestoDocument")
					_check(bool(document.get("selected")), "selected page lacks reading rule: " + suffix)
					metrics.append({"capture": "registry_selected_left_" + suffix, "node": "ManifestoDocument", "selected": document.get("selected"), "rect": str(document.get_global_rect())})
				var page_selector: Button = circle.get("right_select_button")
				_mouse_button(page_selector.get_global_rect().get_center(), true)
				_mouse_button(page_selector.get_global_rect().get_center(), false)
				await process_frame
				_check(circle.get("selected_bet_id") == display_offers[1].id, "page click did not select offer: " + suffix)
				await _capture("registry_selected_right_" + suffix)
				var left: Button = circle.get("left_sign_button")
				var right: Button = circle.get("right_sign_button")
				var right_rect: Rect2 = right.get_global_rect()
				_pointer(right_rect.get_center())
				await _capture("registry_signature_hover_" + suffix)
				_mouse_button(right_rect.get_center(), true)
				await _capture("registry_signature_pressed_" + suffix)
				# Move out before release: inspect pressed without committing a run.
				_pointer(Vector2(5, 5), true)
				_mouse_button(Vector2(5, 5), false)
				_check(sign_intents == 0, "cancelled press emitted intent: " + suffix)
				for button: Button in [left, right]:
					circle.call("_set_promise_signature_state", button, &"signed")
					await _capture("registry_signed_%s_%s" % ["left" if button == left else "right", suffix])
					circle.call("_set_promise_signature_state", button, &"normal")
				var offers: Array[Dictionary] = []
				for offer: Dictionary in circle.get("_betting_circle_options"):
					offers.append(offer.source.duplicate(true))
				var single_offer: Array[Dictionary] = [offers[0]]
				circle.set_offers(single_offer)
				_check(right.disabled, "missing offer still signable: " + suffix)
				await _capture("registry_missing_offer_" + suffix)
				_mouse_button(right.get_global_rect().get_center(), true)
				_mouse_button(right.get_global_rect().get_center(), false)
				_check(sign_intents == 0, "missing offer emitted intent: " + suffix)
				var long_offers: Array[Dictionary] = []
				for offer: Dictionary in offers:
					var long_offer: Dictionary = offer.duplicate(true)
					long_offer["display_subtitle"] = (str(offer.get("display_subtitle", "")) + " ").repeat(8)
					long_offers.append(long_offer)
				circle.set_offers(long_offers)
				await _capture("registry_long_start_" + suffix)
				for label: RichTextLabel in [circle.get("left_contract_label"), circle.get("right_contract_label")]:
					label.get_v_scroll_bar().value = label.get_v_scroll_bar().max_value
				await _capture("registry_long_end_" + suffix)
				circle.set_offers(live_offers)
				circle.close()
				circle.open()
				_check(left.get_meta(&"registry_promise_signature_state") != &"signed", "stale signature on reopen: " + suffix)
				await _capture("registry_reopened_" + suffix)
				circle.call("_on_open_book_pressed")
				await create_timer(1.4).timeout
				# Genuine keyboard input crosses the existing request/RunManager boundary.
				var sign_button: Button = left if reduced else right
				sign_button.grab_focus()
				var key := InputEventKey.new()
				key.keycode = KEY_ENTER
				key.pressed = true
				root.push_input(key, true)
				key = InputEventKey.new()
				key.keycode = KEY_ENTER
				root.push_input(key, true)
				await process_frame
				_check(sign_intents == 1, "keyboard signing must emit once: " + suffix)
				_check(not circle.visible, "registry remained visible after signing: " + suffix)
				_check(root.gui_get_focus_owner() != sign_button, "closed signature kept focus: " + suffix)
				await _capture("registry_to_pact_" + suffix)
				sign_intents = 0

func _run_pact_crowd_matrix(menu: Node, circle: Node, dialogue: Node, ui: Node) -> void:
	for language: int in languages:
		menu.call("_on_language_selected", language)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			for reduced: bool in [true, false]:
				root.get_node("SaveManager").set_reduced_motion(reduced)
				var suffix: String = "%s_%dx%d_%s" % [TranslationServer.get_locale(), dimensions.x, dimensions.y, "reduced" if reduced else "motion"]
				root.get_node("GameEvents").request_show_main_menu.emit()
				menu.get("new_game_button").pressed.emit()
				await create_timer(0.6).timeout
				dialogue.call("_finish")
				await process_frame
				circle.close()
				ui.call("_on_pact_sealed_opened")
				ui.get("pact_sealed_subtitle").text = "Voci dell’arena\nDima: Hanno venduto la terza fila.\nVessa: Il tuo posto no. Per ora."
				await create_timer(0.5).timeout
				var pact: Button = ui.get("pact_sealed_advance_button")
				await _capture("pact_focus_" + suffix)
				var stable: Rect2 = pact.get_global_rect()
				pact.release_focus()
				_pointer(stable.get_center())
				await _capture("pact_hover_" + suffix)
				_mouse_button(stable.get_center(), true)
				await _capture("pact_pressed_" + suffix)
				_pointer(Vector2(10, 10), true)
				_mouse_button(Vector2(10, 10), false)
				ui.call("_set_pact_tablet_validated_state", true)
				pact.disabled = true
				await _capture("pact_validated_" + suffix)
				ui.call("_set_pact_tablet_validated_state", false)
				await _capture("pact_disabled_" + suffix)
				ui.call("_recover_pact_tablet_request_lock")
				_check(not pact.disabled, "pact recovery kept lock: " + suffix)
				_check(pact.get_global_rect() == stable, "pact states moved target: " + suffix)
				ui.call("_on_pact_sealed_closed")
				for exchange: int in range(3):
					var payload: RunUiPayload = load("res://scripts/ui/run_ui_payload.gd").new()
					payload.phase = RunPhaseContract.INTERMEDIATE_CHOICE
					payload.show_mid_choice = true
					payload.choices = ["placa", "provoca"]
					payload.title = "ATTO DAVANTI ALLA GRADINATA"
					var intent: Dictionary = scene.get_node("RunManager").CROWD_INTENTS[["blood", "sand", "breath"][exchange]]
					payload.meta = {"audience_message": "La gradinata pesa il tuo respiro.", "exchange": {"exchange": exchange + 1, "total": 3, "line": intent.line, "placa_text": intent.placa.text, "provoca_text": intent.provoca.text}}
					ui.call("apply_run_ui_payload", payload)
					ui.get("intermediate_choice_audience_label").text = "La gradinata pesa il tuo respiro.\nDima: Sento la sabbia nelle tasche.\nRugo: Aspetta. Non chiamarli ancora."
					ui.call("_on_crowd_favor_changed", {"favor": [-4, 0, 4][exchange], "note": "Il sigillo ha retto: la gradinata approva."})
					await create_timer(1.2).timeout
					await _capture("crowd_%d_" % (exchange + 1) + suffix)
				var placa: Button = ui.get("intermediate_choice_placa_button")
				var provoca: Button = ui.get("intermediate_choice_provoca_button")
				stable = provoca.get_global_rect()
				provoca.grab_focus()
				await _capture("crowd_focus_" + suffix)
				provoca.release_focus()
				_pointer(stable.get_center())
				await _capture("crowd_hover_" + suffix)
				_mouse_button(stable.get_center(), true)
				await _capture("crowd_pressed_" + suffix)
				_pointer(Vector2(10, 10), true)
				_mouse_button(Vector2(10, 10), false)
				for selected: int in [0, 1, -1]:
					ui.call("_set_gesture_choice_selected_state", selected)
					placa.disabled = true
					provoca.disabled = true
					await _capture("crowd_selected_%d_" % selected + suffix)
				ui.call("_recover_gesture_choice_request_lock")
				_check(not placa.disabled and not provoca.disabled, "gesture recovery kept lock: " + suffix)
				_check(provoca.get_global_rect() == stable, "gesture states moved target: " + suffix)
				var long_exchange: Dictionary = ui.get("_gesture_exchange").duplicate(true)
				long_exchange["placa_text"] = "Favore -1, Pressione -1. Un Segno e posta +2 se il patto regge."
				long_exchange["provoca_text"] = "Favore +1, Pressione +1. Un Segno e posta +2 se il patto regge."
				ui.set("_gesture_exchange", long_exchange)
				ui.call("_refresh_gesture_choice_copy")
				await _capture("crowd_long_" + suffix)
				ui.call("_set_intermediate_choice_modal", false)
				ui.call("_on_resolve_ritual_opened", {})
				await create_timer(0.8).timeout
				await _capture("crowd_to_judgment_" + suffix)
				ui.call("_on_resolve_ritual_closed")

func _run_judgment_matrix(menu: Node, circle: Node, dialogue: Node, ui: Node, manager: Node) -> void:
	# Presentation fixture: detach only the manager's request receiver. Native
	# Buttons still send the public intent; synthetic answers never change a run.
	var events: Node = root.get_node("GameEvents")
	var receiver := Callable(manager, "_on_request_ritual_advance")
	events.request_ritual_advance.disconnect(receiver)
	var observer := func(kind: String) -> void: judgment_intents.append(kind)
	events.request_ritual_advance.connect(observer)
	menu.call("_on_language_selected", 0)
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.content_scale_size = dimensions
		root.size = dimensions
		DisplayServer.window_set_size(dimensions)
		for reduced: bool in [true, false]:
			root.get_node("SaveManager").set_reduced_motion(reduced)
			var suffix: String = "%dx%d_%s" % [dimensions.x, dimensions.y, "reduced" if reduced else "motion"]
			events.request_show_main_menu.emit()
			menu.get("new_game_button").pressed.emit()
			await create_timer(0.6).timeout
			dialogue.call("_finish")
			await process_frame
			circle.close()
			ui.set("_pending_resolution_context_line", "Il tuo gesto li irrita. Ora vogliono il prezzo.")
			ui.call("_on_resolve_ritual_opened", {"doom_short": "Pressione +1"})
			await create_timer(0.8).timeout
			var seal: Button = ui.get("resolve_ritual_strike_button")
			var advance: Button = ui.get("resolve_ritual_advance_button")
			await _capture("judgment_focus_" + suffix)
			var stable: Rect2 = seal.get_global_rect()
			seal.release_focus()
			_pointer(Vector2(10, 10))
			await _capture("judgment_normal_" + suffix)
			_pointer(stable.get_center())
			await _capture("judgment_hover_" + suffix)
			_mouse_button(stable.get_center(), true)
			await _capture("judgment_pressed_" + suffix)
			_pointer(Vector2(10, 10), true)
			_mouse_button(Vector2(10, 10), false)
			judgment_intents.clear()
			_enter(seal)
			ui.call("_on_resolve_ritual_strike_pressed")
			_check(judgment_intents == ["strike"], "repeated strike bypassed lock: " + suffix)
			await _capture("judgment_locked_" + suffix)
			ui.call("_recover_judgment_seal_request_lock")
			_check(not seal.disabled, "first strike recovery kept lock: " + suffix)
			for strike: int in [1, 2]:
				ui.call("_on_seal_strike_resolved", {"strike": strike, "held": true, "held_gain": strike + 1, "can_strike_again": true, "next_odds": "RISCHIOSO", "next_gain": 3, "bando_strike": true, "chain": 2, "chain_multiplier": 1.5})
				await create_timer(0.3).timeout
				await _capture("judgment_held_%d_" % strike + suffix)
				_check(seal.get_global_rect() == stable, "seal target moved after strike: " + suffix)
			advance.grab_focus()
			await _capture("judgment_stop_focus_" + suffix)
			judgment_intents.clear()
			_enter(advance)
			ui.call("_on_resolve_ritual_next_pressed")
			_check(judgment_intents == ["resolve"], "stop did not emit one resolve: %s %s" % [suffix, judgment_intents])
			await _capture("judgment_stopped_" + suffix)
			ui.call("_recover_judgment_seal_request_lock")
			_check(not seal.disabled and not advance.disabled, "held recovery kept lock: " + suffix)
			_check(int(seal.get_meta("registry_judgment_seal_state", -1)) == 2, "recovery cleared wax: " + suffix)
			ui.call("_on_seal_strike_resolved", {"strike": 3, "held": true, "held_gain": 4})
			await create_timer(0.3).timeout
			await _capture("judgment_full_" + suffix)
			ui.call("_reset_resolution_ritual_interaction")
			ui.call("_on_seal_strike_resolved", {"strike": 1, "held": false, "can_show_scar": true})
			await create_timer(0.3).timeout
			await _capture("judgment_scar_offer_" + suffix)
			judgment_intents.clear()
			_enter(advance)
			ui.call("_on_resolve_ritual_next_pressed")
			_check(judgment_intents == ["show_scar"], "Segno did not emit one show_scar: %s %s" % [suffix, judgment_intents])
			ui.call("_on_seal_strike_resolved", {"strike": 1, "held": true, "held_gain": 2, "scar_shown": true})
			await create_timer(0.3).timeout
			await _capture("judgment_scar_shown_" + suffix)
			ui.call("_reset_resolution_ritual_interaction")
			ui.call("_on_seal_strike_resolved", {"strike": 1, "held": false})
			await create_timer(0.3).timeout
			await _capture("judgment_cracked_" + suffix)
			ui.call("_on_resolve_ritual_closed")
	events.request_ritual_advance.disconnect(observer)
	events.request_ritual_advance.connect(receiver)

func _enter(button: Button) -> void:
	if not button.is_visible_in_tree() or button.disabled:
		_check(false, "keyboard fixture targeted unavailable action: " + button.name)
		return
	button.grab_focus()
	if root.gui_get_focus_owner() != button:
		_check(false, "keyboard fixture failed to focus: " + button.name)
		return
	var event := InputEventKey.new()
	event.keycode = KEY_ENTER
	event.pressed = true
	root.push_input(event, true)
	event = InputEventKey.new()
	event.keycode = KEY_ENTER
	root.push_input(event, true)

func _wait_visible(control: Control, seconds: float = 8.0) -> bool:
	var end: int = Time.get_ticks_msec() + int(seconds * 1000)
	while not control.is_visible_in_tree() and Time.get_ticks_msec() < end:
		await process_frame
	return control.is_visible_in_tree()

func _run_pact_crowd_flow(menu: Node, circle: Node, dialogue: Node, ui: Node, manager: Node) -> void:
	# Isolated scenario: the special arena falls on the first arena. All phase
	# transitions and three exchange resolutions still belong to RunManager.
	root.get_node("GameEvents").request_show_main_menu.emit()
	menu.get("new_game_button").pressed.emit()
	await create_timer(0.6).timeout
	dialogue.call("_finish")
	await process_frame
	manager.get("_run_state").set("special_arena_index", 1)
	circle.call("_on_open_book_pressed")
	await create_timer(1.4).timeout
	_enter(circle.get("left_sign_button"))
	_check(await _wait_visible(ui.get("pact_sealed_panel")), "live signing did not reach pact")
	await _capture("live_signature_to_pact")
	var pact: Button = ui.get("pact_sealed_advance_button")
	if pact.is_visible_in_tree():
		await create_timer(0.6).timeout
		_enter(pact)
	_check(await _wait_visible(ui.get("intermediate_choice_panel")), "live pact did not reach crowd")
	for exchange: int in range(3):
		await create_timer(0.7).timeout
		_check(int(ui.get("_gesture_exchange").get("exchange", 0)) == exchange + 1, "live exchange did not advance")
		_check(int(ui.get("_gesture_exchange").get("total", 0)) == 3, "live special arena did not request three exchanges")
		await _capture("live_exchange_%d" % (exchange + 1))
		var button: Button = ui.get("intermediate_choice_placa_button" if exchange != 1 else "intermediate_choice_provoca_button")
		_check(not button.disabled, "live exchange kept previous lock")
		_enter(button)
		await process_frame
	_check(await _wait_visible(ui.get("resolve_ritual_panel")), "live exchanges did not reach judgment")
	await create_timer(0.7).timeout
	await _capture("live_crowd_to_judgment")
	_enter(ui.get("resolve_ritual_strike_button"))
	# A crack may close itself, or offer a Segno before raising the hand.
	# Never send Enter to an invisible action and accidentally activate its
	# successor: the authoritative seal result decides which choice exists.
	var deadline: int = Time.get_ticks_msec() + 8000
	while not ui.get("push_luck_panel").is_visible_in_tree() and Time.get_ticks_msec() < deadline:
		var advance: Button = ui.get("resolve_ritual_advance_button")
		if advance.is_visible_in_tree() and not advance.disabled:
			_enter(advance)
		await create_timer(0.3).timeout
	_check(await _wait_visible(ui.get("push_luck_panel")), "live judgment did not reach posta")
	await create_timer(0.8).timeout
	await _capture("live_judgment_to_posta")

func _finish_capture() -> void:
	var report := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"fixture": true, "captures": captures, "failures": failures, "metrics": metrics}, "\t"))
	report.close()
	scene.get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await create_timer(1.6).timeout
	scene.queue_free()
	await create_timer(0.3).timeout
	if failures.is_empty(): print("COUNTER_LAYOUT_OK ", captures)
	quit(0 if failures.is_empty() else 1)

