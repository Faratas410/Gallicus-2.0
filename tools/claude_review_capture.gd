extends SceneTree

# Presentation fixtures only: wallet payloads exercise layout, never save/outcomes.
var scene: Node
var failures: Array[String] = []
var output: String = "res://artifacts/claude_review_2026-10-08/layout"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.3).timeout
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
	for language: int in range(3):
		menu.call("_on_language_selected", language)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.content_scale_size = dimensions
			root.size = dimensions
			DisplayServer.window_set_size(dimensions)
			var suffix: String = "%s_%dx%d" % [TranslationServer.get_locale(), dimensions.x, dimensions.y]
			menu.hide()
			circle.open()
			circle.call("_on_bando_changed", {"status": "open", "denari": 5, "quota": 10, "deadline": 4, "step": 0, "steps": 12})
			for balance: int in [-5, 0, 20]:
				var items: Array[Dictionary] = []
				for item_id: String in ["favor", "pressure", "insure"]:
					var item: Dictionary = scene.get_node("RunManager").BANCO_ITEMS[item_id].duplicate()
					item["id"] = item_id
					item["available"] = balance >= int(item.price)
					items.append(item)
				circle.call("_on_ledger_changed", {"banco": {"denari": balance, "open": true, "in_debt": balance < 0, "items": items}})
				await _capture("banco_%d_%s" % [balance, suffix])
				var row: HBoxContainer = circle.get("banco_row")
				for button: Button in row.get_children():
					_check(root.get_visible_rect().encloses(button.get_global_rect()), "bank button outside viewport " + suffix)
					_check(row.get_global_rect().encloses(button.get_global_rect()), "bank button outside row " + suffix)
					_check(button.disabled == (balance < 0 or balance < (5 if button.name.ends_with("insure") else 3)), "bank availability " + suffix)
				var portrait: TextureRect = circle.get_node("CenterContainer/BookFrame/ClosedIntro/VessaPortrait")
				_check(not portrait.get_global_rect().intersects(row.get_global_rect()), "portrait overlaps bank " + suffix)
				var note: Label = circle.get("banco_note")
				_check(note.get_line_count() * note.get_line_height() <= note.size.y + 1.0, "bank note clipped " + suffix)
			circle.close()
			menu.call("_show_menu")
			menu.call("_show_settings")
			await _capture("settings_" + suffix)
			menu.call("_show_menu")
	var report := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"fixture": true, "failures": failures, "captures": 24}, "\t"))
	report.close()
	scene.queue_free()
	await create_timer(1.5).timeout
	if failures.is_empty(): print("CLAUDE_REVIEW_LAYOUT_OK")
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("CLAUDE_REVIEW: " + message)

func _capture(label: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "/" + label + ".png")
