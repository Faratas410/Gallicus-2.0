extends SceneTree

const Phase = preload("res://scripts/contracts/run_phase_contract.gd")

var _failed: bool = false
var _checks: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(value: bool, message: String) -> void:
	_checks += 1
	if not value:
		_failed = true
		push_error("AV_CONTRACT: " + message)

func _run() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await create_timer(0.25).timeout
	var music: Node = scene.get_node("MusicDirector")
	var players: Array = music.get("_players")
	_expect(players.size() == 2, "music must use exactly two voices")
	var active: int = int(music.get("_active"))
	var position: float = players[active].get_playback_position()
	music.call("_on_run_phase_changed", Phase.MAIN_MENU)
	await create_timer(0.12).timeout
	_expect(int(music.get("_active")) == active, "same music state restarted a track")
	_expect(players[active].get_playback_position() >= position, "same-state playback jumped backwards")
	music.set("fade_seconds", 0.12)
	music.call("_transition", "tense")
	_expect(players[0].playing and players[1].playing, "crossfade must overlap both voices")
	await create_timer(0.20).timeout
	_expect(int(players[0].playing) + int(players[1].playing) == 1, "outgoing voice not stopped")
	for player: AudioStreamPlayer in players:
		_expect(player.stream is AudioStreamWAV and player.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "score loop not configured")
	var sfx: Node = root.get_node("SfxBus")
	var sfx_players: Array = sfx.get("_players")
	_expect(sfx_players.size() == 6, "SFX pool exceeded six voices")
	sfx.call("play_cue", &"registry_pact_validate")
	sfx.call("_apply_sfx_volume_linear", 0.0)
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")), "SFX mute did not silence bus")
	sfx.call("_apply_sfx_volume_linear", 1.0)
	music.call("_apply_music_volume_linear", 0.0)
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "music mute did not silence bus")
	music.call("_apply_music_volume_linear", 1.0)
	var feedback: Node = scene.get_node("RitualFeedback")
	var sprites: Array = feedback.get("_sprites")
	_expect(sprites.size() == 2 and sprites[0].texture.get_width() <= 256, "VFX resource budget exceeded")
	var button: Button = Button.new()
	button.text = "AV TEST"
	button.position = Vector2(100,100)
	button.size = Vector2(180,60)
	scene.get_node("MenuLayer/MainMenu").add_child(button)
	button.grab_focus()
	var base_rect: Rect2 = button.get_global_rect()
	var base_nodes: int = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for index: int in range(100):
		scene.get_node("MenuLayer/MainMenu").call("_play_sfx", &"registry_promise_sign")
	_expect(sprites[0].visible or sprites[1].visible, "UI cue did not reach VFX")
	_expect(button.get_global_rect() == base_rect, "VFX changed hit geometry")
	_expect(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) == base_nodes, "repeated VFX allocated nodes")
	await create_timer(0.6).timeout
	_expect(not sprites[0].visible and not sprites[1].visible, "VFX survived its time budget")
	var ui: Node = scene.get_node("UI")
	ui.call("_play_panel_enter", button, "ritual")
	feedback.call("play_cue", &"registry_promise_sign", button)
	scene.get_node("MenuLayer/MainMenu").call("_on_reduced_motion_toggled", true)
	await process_frame
	_expect(not sprites[0].visible and not sprites[1].visible, "reduced motion did not cancel in-flight VFX")
	feedback.call("play_cue", &"registry_promise_sign", button)
	_expect(not sprites[0].visible and not sprites[1].visible, "reduced motion started a new VFX")
	_expect(not scene.get_node("MenuLayer/MainMenu/MenuAmbience").is_processing(), "ambient movement still processing")
	_expect(not button.has_meta(&"panel_enter_tween"), "reduced motion retained panel tween")
	await create_timer(0.3).timeout
	_expect(button.get_global_rect() == base_rect, "cancelled panel motion changed geometry again")
	scene.get_node("MenuLayer/MainMenu").call("_on_reduced_motion_toggled", false)
	music.call("_on_registry_run_ended", "REGISTRY_SILENCE", {})
	sfx.call("_on_run_ended", "REGISTRY_SILENCE", {})
	music.call("_on_run_phase_changed", Phase.MAIN_MENU)
	_expect(not players[0].playing and not players[1].playing, "phase callback revived music during Silence")
	for player: AudioStreamPlayer in sfx_players:
		_expect(not player.playing, "ritual audio tail survived Silence")
	music.call("_on_request_show_main_menu")
	_expect(players[int(music.get("_active"))].playing, "music did not resume after explicit return")
	button.queue_free()
	await process_frame
	var frame_ms: Array[float] = []
	for index: int in range(120):
		var started: int = Time.get_ticks_usec()
		await process_frame
		frame_ms.append(float(Time.get_ticks_usec() - started) / 1000.0)
	frame_ms.sort()
	print("AV_METRICS=", JSON.stringify({"checks":_checks, "frame_interval_p50_ms":frame_ms[60], "frame_interval_p95_ms":frame_ms[114], "nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT), "draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC), "headless":DisplayServer.get_name() == "headless"}))
	music.call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	# Let the audio server drain its playback reference before destroying the scene.
	await create_timer(0.15).timeout
	scene.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.15).timeout
	print("AV_RUNTIME_CONTRACT_OK" if not _failed else "AV_RUNTIME_CONTRACT_FAILED")
	quit(1 if _failed else 0)
