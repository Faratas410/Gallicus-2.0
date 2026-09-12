extends SceneTree

const Catalog = preload("res://scripts/content/campaign_dialogues.gd")
const Evolution = preload("res://scripts/systems/run/registry_evolution.gd")
var scene: Node
var manager: Node
var view: Node
var save: Node
var failed: bool = false
var captures: String = ""

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	if not value:
		failed = true
		push_error("ILLUSTRATED_DIALOGUE: " + message)

func _boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	view = scene.get_node("OpeningPrologue")
	await create_timer(0.15).timeout

func _input_action(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame

func _new_entry(id: String) -> void:
	root.get_node("GameEvents").request_show_main_menu.emit()
	var era: int = {"entry":0, "middle":2, "departure":3}[id]
	save.commit_registry_evolution(0.0, era, Evolution.defaults())
	manager.set("_registry_era", era)
	var settings: Dictionary = save.get("_settings")
	settings["opening_prologue_seen"] = false
	settings["campaign_dialogues_seen"] = []
	scene.get_node("MenuLayer/MainMenu").get("new_game_button").pressed.emit()
	await process_frame
	await process_frame
	_check(view.get("_active") and view.get("_payload").get("id") == id, "entry point did not open " + id)

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="):
			captures = arg.trim_prefix("--capture-dir=")
			DirAccess.make_dir_recursive_absolute(captures)
	save = root.get_node("SaveManager")
	await _boot()
	await _new_entry("entry")
	var snapshot: Dictionary = manager.get("_run_state").to_dict()
	await _input_action("ui_accept")
	_check(view.get("_beat") == 0 and manager.get("_run_state").to_dict() == snapshot, "entry click leaked through")
	await create_timer(0.55).timeout
	await _input_action("ui_accept")
	_check(view.get("_beat") == 1, "Enter did not advance one beat")
	_check(not save.has_seen_campaign_dialogue("entry"), "partial reading persisted completion")
	root.get_node("GameEvents").request_show_main_menu.emit()
	scene.queue_free()
	await create_timer(1.6).timeout
	save.set("_profile_loaded", false)
	save.load_profile()
	await _boot()
	scene.get_node("MenuLayer/MainMenu").get("continue_button").pressed.emit()
	await process_frame
	await process_frame
	_check(view.get("_active") and view.get("_beat") == 0, "interrupted conversation did not resume from its beginning")
	var resumed: Dictionary = manager.get("_run_state").to_dict()
	for key: String in ["run_seed", "scar_rng_state", "glory", "corruption", "arena_index", "bets_history"]:
		_check(snapshot[key] == resumed[key], "dialogue resume changed " + key)
	await create_timer(0.55).timeout
	await _input_action("ui_cancel")
	save.set("_profile_loaded", false)
	save.load_profile()
	_check(save.has_seen_campaign_dialogue("entry"), "skip completion did not survive disk reload")
	view.call("_try_open")
	_check(not view.get("_active"), "completed dialogue replayed")
	_check(save.call("_sanitize_campaign_dialogues", ["middle", "middle", "unknown", 12, "departure"]) == ["middle", "departure"], "invalid dialogue ids retained")
	for language: int in range(3):
		scene.get_node("MenuLayer/MainMenu").call("_on_language_selected", language)
		save.set_reduced_motion(language != 0)
		for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			root.size = dimensions
			root.content_scale_size = dimensions
			for id: String in ["entry", "middle", "departure"]:
				await _new_entry(id)
				var before: Dictionary = manager.get("_run_state").to_dict()
				for index: int in range(Catalog.SEQUENCES[id].lines.size()):
					await create_timer(0.55 if index == 0 else 0.20).timeout
					_check(view.get("_beat") == index, "unexpected beat")
					var body: Label = view.get("_caption")
					var portrait: TextureRect = view.get("_image")
					var tag: String = "%s_%s_%dx%d_%d" % [id, TranslationServer.get_locale(), dimensions.x, dimensions.y, index]
					_check(view.get("_surface").is_visible_in_tree() and not scene.get_node("MenuLayer/MainMenu").visible, "hidden conversation: " + tag)
					_check(body.get_line_count() * body.get_line_height() <= body.size.y + 1, "text clipped: " + tag)
					_check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(view.get("_stage").get_global_rect()), "stage outside viewport: " + tag)
					_check(portrait.texture != null and portrait.size.x > 0 and portrait.texture.get_width() > 0, "portrait missing: " + tag)
					_check(manager.get("_run_state").to_dict() == before, "reading changed gameplay: " + tag)
					if language > 0:
						_check(body.text != Catalog.SEQUENCES[id].lines[index].text, "untranslated beat: " + tag)
					if captures != "":
						await RenderingServer.frame_post_draw
						root.get_texture().get_image().save_png(captures.path_join(tag + ".png"))
					# Mouse and keyboard both traverse the real overlay input boundary.
					if index % 2 == 0:
						var click := InputEventMouseButton.new()
						click.button_index = MOUSE_BUTTON_LEFT
						click.pressed = true
						click.position = view.get("_next").get_global_rect().get_center()
						Input.parse_input_event(click)
						await process_frame
					else: await _input_action("ui_accept")
				_check(not view.get("_active") and save.has_seen_campaign_dialogue(id), "last beat did not close and persist: " + id)
				_check(root.gui_get_focus_owner().name == "Btn_Open_Book", "focus not restored")
	# Every scene is suppressed by Silence and by permanent Absence.
	manager.get("_run_state").registry_silence_active = true
	_check(manager.get_campaign_dialogue().is_empty(), "Silence contains a dialogue")
	manager.get("_run_state").registry_silence_active = false
	save.commit_registry_evolution(0.0, 4, Evolution.defaults())
	_check(manager.get_campaign_dialogue().is_empty(), "Absence contains a dialogue")
	var music: Node = scene.get_node("MusicDirector")
	music.call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await create_timer(1.6).timeout
	scene.queue_free()
	await create_timer(0.3).timeout
	if not failed: print("ILLUSTRATED_DIALOGUE_CONTRACT_OK")
	quit(1 if failed else 0)
