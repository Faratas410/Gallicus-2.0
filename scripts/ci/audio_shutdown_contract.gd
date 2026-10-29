extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var bus := root.get_node("SfxBus")
	bus.play_cue(&"coins_gain")
	bus._play_later(&"crowd_triumph", 0.08)
	var players: Array = bus.get("_players")
	if players.is_empty() or not players.any(func(player: AudioStreamPlayer) -> bool: return player.playing):
		push_error("AUDIO_SHUTDOWN: no cue started")
		quit(1)
		return
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	if players.any(func(player: AudioStreamPlayer) -> bool: return player.playing or player.stream != null):
		push_error("AUDIO_SHUTDOWN: playback or delayed cue survived stop")
		quit(1)
		return
	# A new cue requested immediately after a stop belongs to the new generation,
	# even if both events happen in the same millisecond.
	bus.stop_all()
	bus._play_later(&"crowd_triumph", 0.02)
	await create_timer(0.04).timeout
	if not players.any(func(player: AudioStreamPlayer) -> bool: return player.playing):
		push_error("AUDIO_SHUTDOWN: new delayed cue was suppressed after stop")
		quit(1)
		return
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	print("AUDIO_SHUTDOWN_CONTRACT_OK")
	quit(0)
