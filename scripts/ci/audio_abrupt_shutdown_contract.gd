extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var bus := root.get_node("SfxBus")
	bus.play_cue(&"coins_gain")
	var players: Array = bus.get("_players")
	if not players.any(func(player: AudioStreamPlayer) -> bool: return player.playing):
		push_error("AUDIO_ABRUPT_SHUTDOWN: no cue started")
		quit(1)
		return
	print("AUDIO_ABRUPT_SHUTDOWN_STARTED")
	quit(0)
