extends CanvasLayer

# Presentation only: listens to RunManager's terminal reasons through GameEvents.
var _port: RunManagerUiPort
var _black: ColorRect
var _return_button: Button
var _heartbeat: AudioStreamPlayer
var _terminal: bool = false
var _return_delay: Timer
var _departure: TextureRect
var _exit_button: Button
var _credits_button: Button
var _credits: AcceptDialog
var _elapsed: float = 0.0
const DEPARTURE_SECONDS: float = 6.0

func _ready() -> void:
	layer = 150
	_port = RunManagerUiPort.new(get_tree())
	_black = ColorRect.new()
	_black.name = "SilenceSurface"
	_black.color = Color.BLACK
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.focus_mode = Control.FOCUS_ALL
	add_child(_black)
	_build_departure()
	_return_button = Button.new()
	_return_button.name = "ReturnToMenu"
	_return_button.theme = preload("res://assets/ui/theme/official_theme.tres")
	_black.add_child(_return_button)
	_return_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_return_button.offset_left = -160.0
	_return_button.offset_right = 160.0
	_return_button.offset_top = -88.0
	_return_button.offset_bottom = -36.0
	_return_button.text = tr("TORNA AL MENU")
	_return_button.pressed.connect(_return_to_menu)
	_exit_button = _make_utility("ExitGame", "ESCI DAL GIOCO", 12.0, 332.0)
	_exit_button.pressed.connect(_exit_game)
	_credits_button = _make_utility("TerminalCredits", "CREDITI", -332.0, -12.0)
	_credits = AcceptDialog.new()
	_credits.title = tr("CREDITI")
	_credits.dialog_text = tr("CREDITS_BODY")
	var credits_theme: Theme = _return_button.theme.duplicate()
	credits_theme.set_stylebox("panel", "AcceptDialog", preload("res://assets/ui/official/styleboxes/sb_panel_main.tres"))
	credits_theme.set_stylebox("embedded_border", "Window", preload("res://assets/ui/official/styleboxes/sb_panel_main.tres"))
	_credits.theme = credits_theme
	_credits.ok_button_text = tr("CHIUDI")
	add_child(_credits)
	_credits_button.pressed.connect(func() -> void: _credits.popup_centered(Vector2i(720, 460)))
	_credits.confirmed.connect(func() -> void: _credits_button.grab_focus())
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
	set_process(false)
	set_process_input(false)
	GameEvents.run_ended.connect(_on_run_ended)
	GameEvents.run_started.connect(_hide_surface)
	GameEvents.request_show_main_menu.connect(_hide_surface)
	GameEvents.settings_changed.connect(func(_payload: Dictionary) -> void: _refresh_text())
	call_deferred("_restore_terminal")

func _restore_terminal() -> void:
	if not _port.can_start_run():
		_show_surface(true, false)

func _on_run_ended(reason: String, _summary: Dictionary) -> void:
	if reason == "REGISTRY_SILENCE" or reason == "REGISTRY_ABSENCE":
		_show_surface(reason == "REGISTRY_ABSENCE")

func _show_surface(terminal: bool, show_departure: bool = true) -> void:
	if _terminal:
		return
	_return_delay.stop()
	_refresh_text()
	_terminal = terminal
	_black.show()
	_return_button.hide()
	_exit_button.hide()
	_credits_button.hide()
	_departure.hide()
	set_process_input(true)
	_black.grab_focus()
	if terminal:
		if show_departure:
			_elapsed = 0.0
			_departure.modulate.a = 1.0
			_departure.show()
			set_process(true)
		else:
			_finish_departure()
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
	set_process_input(false)
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

func _make_utility(node_name: String, label: String, left: float, right: float) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = tr(label)
	button.theme = _return_button.theme
	_black.add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	button.offset_left = left
	button.offset_right = right
	button.offset_top = -88.0
	button.offset_bottom = -36.0
	button.hide()
	return button

func _refresh_text() -> void:
	_return_button.text = tr("TORNA AL MENU")
	_exit_button.text = tr("ESCI DAL GIOCO")
	_credits_button.text = tr("CREDITI")
	_credits.title = tr("CREDITI")
	_credits.dialog_text = tr("CREDITS_BODY")
	_credits.ok_button_text = tr("CHIUDI")

func _exit_game() -> void:
	_exit_button.disabled = true
	_credits_button.disabled = true
	_heartbeat.stop()
	SfxBus.call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await get_tree().create_timer(0.3, true, false, true).timeout
	get_tree().quit()

func _build_departure() -> void:
	_departure = TextureRect.new()
	_departure.name = "UnclassifiedDeparture"
	_departure.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_departure.texture = preload("res://assets/ui/generated/registry_departure.png")
	_departure.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_departure.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_black.add_child(_departure)
	_departure.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_departure.hide()

func _process(delta: float) -> void:
	_elapsed += delta
	var reduced: bool = SaveManager.get_reduced_motion()
	_departure.pivot_offset = _departure.size * 0.5
	_departure.scale = Vector2.ONE if reduced else Vector2.ONE * (1.0 + minf(_elapsed, 4.5) * 0.002)
	_departure.modulate.a = 1.0 if reduced else 1.0 - clampf((_elapsed - 4.5) / 1.5, 0.0, 1.0)
	if _elapsed >= DEPARTURE_SECONDS:
		_finish_departure()

func _finish_departure() -> void:
	set_process(false)
	_departure.hide()
	_play_heartbeat()
	_exit_button.show()
	_credits_button.show()
	_exit_button.focus_neighbor_left = _credits_button.get_path()
	_exit_button.focus_previous = _credits_button.get_path()
	_exit_button.focus_next = _credits_button.get_path()
	_credits_button.focus_neighbor_right = _exit_button.get_path()
	_credits_button.focus_next = _exit_button.get_path()
	_credits_button.focus_previous = _exit_button.get_path()
	_exit_button.grab_focus()

func _input(event: InputEvent) -> void:
	if not _black.visible or _credits.visible:
		return
	# Confine input to the terminal surface; never operate the covered dossier.
	if event is InputEventKey or event is InputEventAction:
		if event.is_action_pressed("ui_accept"):
			var focused: Control = get_viewport().gui_get_focus_owner()
			if focused in [_return_button, _exit_button, _credits_button] and focused.is_visible_in_tree():
				(focused as Button).pressed.emit()
		elif _terminal and not _departure.visible and (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev")):
			if _exit_button.has_focus(): _credits_button.grab_focus()
			else: _exit_button.grab_focus()
		get_viewport().set_input_as_handled()
