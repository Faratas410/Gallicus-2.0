extends SceneTree

# The local session log measures human playtime: it counts only time inside a
# percorso, keeps it across a resume and writes one line per closed percorso.
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error("SESSION_LOG: " + message)

func _run() -> void:
	var save := root.get_node("SaveManager")
	save.mark_campaign_dialogue_seen("entry")
	var legacy := RunState.new()
	legacy.from_dict({"active_msec": -40})
	check(legacy.active_msec == 0, "legacy or negative playtime accepted")
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(0.5).timeout
	var manager: Node = scene.get_node("RunManager")
	var menu_state: RunState = manager.get("_run_state")
	var idle: int = menu_state.active_msec
	await create_timer(0.3).timeout
	check(menu_state.active_msec == idle, "the main menu counted as playtime")
	scene.find_child("NewGameButton", true, false).pressed.emit()
	await create_timer(0.6).timeout
	var run: RunState = manager.get("_run_state")
	check(run.active_msec > 0, "a percorso did not count its playtime")
	var restored := RunState.new()
	restored.from_dict(run.to_dict())
	check(restored.active_msec == run.active_msec, "playtime was not kept in the checkpoint")
	manager.request_quit_to_menu()
	var paused: int = run.active_msec
	await create_timer(0.3).timeout
	check(run.active_msec == paused, "the menu during a percorso counted as playtime")
	var path: String = "user://session_log.jsonl"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	run.active_msec = 125000
	run.run_end_reason = "CASH_OUT"
	manager.call("_append_session_log", 2)
	manager.call("_append_session_log", 3)
	var lines: PackedStringArray = FileAccess.get_file_as_string(path).strip_edges().split("\n")
	check(lines.size() == 2, "the log did not append one line per percorso")
	var entry: Variant = JSON.parse_string(lines[0])
	check(entry is Dictionary and int(entry.active_seconds) == 125 and int(entry.era) == 2 and str(entry.reason) == "CASH_OUT", "the log line lost its measures")
	for key: String in ["ended_unix", "silence", "arenas", "scenes", "bando", "denari", "earned", "lost"]:
		check(entry is Dictionary and entry.has(key), "the log line lacks " + key)
	# A percorso closed by a Silence belongs to the Era it was played in.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	run.run_finale_emitted = false
	manager.set("_registry_meta_committed_this_run", true)
	manager.set("_registry_era", 2)
	run.registry_silence_evaluated = true
	run.registry_silence_active = true
	manager.call("_emit_run_finale")
	var silence_line: Variant = JSON.parse_string(FileAccess.get_file_as_string(path).strip_edges())
	check(silence_line is Dictionary and int(silence_line.era) == 1 and bool(silence_line.silence), "the Silence percorso was logged in the next Era")
	scene.queue_free()
	await create_timer(0.5).timeout
	if failures.is_empty():
		print("SESSION_LOG_CONTRACT_OK")
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0 if failures.is_empty() else 1)
