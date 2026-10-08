extends SceneTree

# Render existing presentation surfaces without advancing campaign or saves.
const Characters = preload("res://scripts/content/arena_characters.gd")
const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var scene: Node
var output: String = "res://artifacts/claude_review_2026-10-08/portrait_integration"
var captures: int = 0

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
	var dialogue: Node = scene.get_node("OpeningPrologue")
	root.get_node("SaveManager").set_reduced_motion(true)
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
			var items: Array[Dictionary] = []
			for item_id: String in ["favor", "pressure", "insure"]:
				var item: Dictionary = scene.get_node("RunManager").BANCO_ITEMS[item_id].duplicate()
				item["id"] = item_id
				item["available"] = true
				items.append(item)
			circle.call("_on_ledger_changed", {"banco": {"denari": 20, "open": true, "in_debt": false, "items": items}})
			await _capture("registry_" + suffix)
			circle.close()
			menu.show()
			menu.call("_show_achievements")
			menu.call("_on_museo_tab_pressed")
			await process_frame
			await process_frame
			var archive: VBoxContainer = menu.get("museo_vbox")
			var scroll: ScrollContainer = archive.get_parent()
			for character: Dictionary in Characters.CHARACTERS:
				for entry: Node in archive.get_children():
					if str(entry.get_meta("character_id", "")) == str(character.id):
						scroll.ensure_control_visible(entry)
						await _capture("archive_%s_%s" % [character.id, suffix])
			scroll.scroll_vertical = 0
			menu.call("_show_menu")
			menu.hide()
			for speaker_id: String in ["nerio", "rugo", "dima"]:
				var sequence: Dictionary = Dialogues.SEQUENCES["middle" if speaker_id == "dima" else "entry"]
				var line_index: int = 0
				while sequence.lines[line_index].speaker != speaker_id:
					line_index += 1
				dialogue.set("_payload", {"id": "fixture", "title": sequence.title, "lines": sequence.lines})
				dialogue.set("_beat", line_index)
				dialogue.set("_active", true)
				dialogue.get("_surface").show()
				dialogue.call("_refresh_line")
				await _capture("dialogue_%s_%s" % [speaker_id, suffix])
				dialogue.call("_cancel")
	var report := FileAccess.open(output + "/summary.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"fixture": true, "captures": captures}, "\t"))
	report.close()
	scene.queue_free()
	await create_timer(1.5).timeout
	print("PORTRAIT_INTEGRATION_CAPTURE_OK ", captures)
	quit()

func _capture(label: String) -> void:
	await create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "/" + label + ".png")
	captures += 1
