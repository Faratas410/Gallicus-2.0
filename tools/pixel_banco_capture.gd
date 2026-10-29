extends "res://tools/counter_layout_capture.gd"
## Current closed-book matrix. Open-book contracts live in registry_volume_capture.
func _run() -> void:
	output = "res://artifacts/banco_review/final"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.4).timeout
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
	var manager: Node = scene.get_node("RunManager")
	var events: Node = root.get_node("GameEvents")
	events.request_banco_purchase.connect(_count_bank_intent)
	for language: int in [0, 1, 2]:
		menu.call("_on_language_selected", language)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			root.get_node("SaveManager").set_reduced_motion(dimensions.x == 1280)
			events.request_show_main_menu.emit()
			menu.get("new_game_button").pressed.emit()
			await create_timer(0.6).timeout
			scene.get_node("OpeningPrologue").call("_finish")
			await process_frame
			for balance: int in [-5, 0, 20]:
				scene.get_node("UI").call("_on_ledger_changed", {"denari": balance})
				var items: Array[Dictionary] = []
				for item_id: String in ["favor", "pressure", "insure"]:
					var item: Dictionary = manager.BANCO_ITEMS[item_id].duplicate()
					item["id"] = item_id
					item["available"] = balance >= int(item.price)
					items.append(item)
				circle.call("_on_ledger_changed", {"banco": {"denari": balance, "open": true, "in_debt": balance < 0, "items": items}})
				var suffix := "%d_%s_%d" % [balance, TranslationServer.get_locale(), dimensions.x]
				await _capture("banco_" + suffix)
				for button: Button in circle.banco_row.get_children():
					var ink: Label = button.get_node("PixelRitualObject").get("copy")
					_check(button.get_global_rect().encloses(ink.get_global_rect()), "ink outside receipt " + suffix)
					_check(ink.get_line_count() * ink.get_line_height() <= button.size.y * 0.70, "ink leaves blank paper " + suffix)
				var service: Button = circle.banco_row.get_child(0)
				var target := service.get_global_rect()
				_pointer(target.get_center())
				await process_frame
				_mouse_button(target.get_center(), true)
				_mouse_button(target.get_center(), false)
				await process_frame
				_check(bank_intents == (1 if balance == 20 else 0), "native purchase intent count " + suffix)
				_check(service.get_global_rect() == target, "receipt target moved " + suffix)
				bank_intents = 0
	await _finish_capture()
