extends CanvasLayer

# Presentation only: listens to RunManager's terminal reasons through GameEvents.
var _port: RunManagerUiPort
var _black: ColorRect
var _return_button: Button
var _heartbeat: AudioStreamPlayer
var _terminal: bool = false
var _return_delay: Timer

func _ready() -> void:
	layer = 150
	_port = RunManagerUiPort.new(get_tree())
	_black = ColorRect.new()
	_black.name = "SilenceSurface"
	_black.color = Color.BLACK
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.focus_mode = Control.FOCUS_ALL
	add_child(_black)
	_return_button = Button.new()
	_return_button.name = "ReturnToMenu"
	_return_button.theme = preload("res://assets/ui/theme/official_theme.tres")
	_black.add_child(_return_button)
	_return_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_return_button.position = Vector2(-160, -88)
	_return_button.size = Vector2(320, 52)
	_return_button.text = tr("TORNA AL MENU")
	_return_button.pressed.connect(_return_to_menu)
	_heartbeat = AudioStreamPlayer.new()
	_heartbeat.name = "TerminalHeartbeat"
	_heartbeat.bus = "SFX"
	_heartbeat.volume_db = -20.0
	add_child(_heartbeat)
	_return_delay = Timer.new()
	_return_delay.one_shot = true
	_return_delay.wait_time = 2.0
	_return_delay.timeout.connect(_offer_return)
	add_child(_return_delay)
	_black.hide()
	GameEvents.run_ended.connect(_on_run_ended)
	GameEvents.run_started.connect(_hide_surface)
	GameEvents.request_show_main_menu.connect(_hide_surface)
	call_deferred("_restore_terminal")

func _restore_terminal() -> void:
	if not _port.can_start_run():
		_show_surface(true)

func _on_run_ended(reason: String, _summary: Dictionary) -> void:
	if reason == "REGISTRY_SILENCE" or reason == "REGISTRY_ABSENCE":
		_show_surface(reason == "REGISTRY_ABSENCE")

func _show_surface(terminal: bool) -> void:
	_return_delay.stop()
	_terminal = terminal
	_black.show()
	_return_button.hide()
	_black.grab_focus()
	if terminal:
		_play_heartbeat()
		return
	_return_delay.start()

func _offer_return() -> void:
	if _terminal or not _black.visible:
		return
	_return_button.text = tr("TORNA AL MENU")
	_return_button.show()
	_return_button.grab_focus()

func _hide_surface() -> void:
	if _terminal:
		return
	_return_delay.stop()
	_black.hide()
	_heartbeat.stop()

func _return_to_menu() -> void:
	if not _terminal:
		_hide_surface()
		GameEvents.request_show_main_menu.emit()

func _play_heartbeat() -> void:
	if _heartbeat.playing:
		return
	var stream: AudioStreamWAV = preload("res://assets/audio/original/terminal_heartbeat.wav")
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_heartbeat.stream = stream
	_heartbeat.play()
