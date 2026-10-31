extends SceneTree

const Dialogues = preload("res://scripts/content/campaign_dialogues.gd")
var failures: Array[String] = []
var save: Node
var manager: Node

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("STORY_ORDER: " + message)

func _run() -> void:
	save = root.get_node("SaveManager")
	# The farewell closes the dismantling of the last Era, from its fifth percorso.
	save.commit_registry_evolution(0.0, 3, {"era_runs": 4})
	# Only the first bando tale and the farewell remain unheard. The first step
	# is already earned, so telling the farewell first would strand that prize.
	for id: String in Dialogues.SEQUENCES:
		if id not in ["first_strophe", "departure"]:
			save.mark_campaign_dialogue_seen(id)
	save.set_bando_step(1)
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.8).timeout
	manager = scene.get_node("RunManager")
	var dialogue: Node = scene.get_node("OpeningPrologue")
	check(str(dialogue.get("_payload").get("id", "")) == "first_strophe", "entry UI did not open the earned tale")
	save.set_bando_step(0)
	check(str(manager.get_campaign_dialogue().get("id", "")) == "departure", "unearned tale delayed the farewell")
	save.set_bando_step(1)
	check(str(manager.get_campaign_dialogue().get("id", "")) == "first_strophe", "earned tale is lost behind the farewell")
	dialogue.call("_finish")
	check(save.has_seen_campaign_dialogue("first_strophe"), "entry UI did not persist the earned tale")
	check(manager.get_campaign_dialogue().is_empty(), "the farewell stacked after another scene of the same percorso")
	manager.get("_run_state").campaign_scenes_heard.clear() # The next percorso's entry.
	check(str(manager.get_campaign_dialogue().get("id", "")) == "departure", "farewell must follow the earned tale")
	root.get_node("GameEvents").request_dismiss_campaign_dialogue.emit("departure")
	check(manager.get_campaign_dialogue().is_empty(), "farewell or tale repeated")
	var settings: Dictionary = save.get("_settings")
	(settings["campaign_dialogues_seen"] as Array).erase("ledger")
	save.set_bando_step(2)
	check(manager.get_campaign_dialogue().is_empty(), "late bando replayed an earlier scene after the farewell")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("CAMPAIGN_STORY_ORDER_CONTRACT_OK")
	quit(0 if failures.is_empty() else 1)
