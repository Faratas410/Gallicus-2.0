extends CanvasLayer

# Legacy node name retained. RunManager supplies the eligible, persisted beat.
const Catalog = preload("res://scripts/content/campaign_dialogues.gd")
const CHAMBER: Texture2D = preload("res://assets/ui/generated/registry_chamber.png")
const READ_GUARD: float = 0.5
var _port: RunManagerUiPort
var _surface: Control
var _stage: Control
var _image: TextureRect
var _caption: Label
var _speaker: Label
var _role: Label
var _chapter: Label
var _counter: Label
var _skip: Button
var _next: Button
var _active: bool = false
var _elapsed: float = 0.0
var _beat: int = 0
var _payload: Dictionary = {}

func _ready() -> void:
	layer = 90
	_port = RunManagerUiPort.new(get_tree())
	_surface = Control.new()
	_surface.name = "CampaignDialogueSurface"
	_surface.theme = preload("res://assets/ui/theme/official_theme.tres")
	add_child(_surface)
	_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := TextureRect.new()
	backdrop.texture = CHAMBER
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.021, 0.016, 0.82)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stage = Control.new()
	_stage.name = "ConversationStage"
	_surface.add_child(_stage)
	_stage.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_stage.offset_left = -580
	_stage.offset_right = 580
	_stage.offset_top = -310
	_stage.offset_bottom = 310
	_image = TextureRect.new()
	_image.name = "SpeakerPortrait"
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(_image, Rect2(0, 20, 400, 600))
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", preload("res://assets/ui/official/styleboxes/sb_panel_main.tres"))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(panel, Rect2(392, 134, 768, 430))
	_chapter = _label("ConversationTitle", Rect2(432, 46, 688, 54), 22)
	_chapter.add_theme_color_override("font_color", Color(0.69, 0.61, 0.44))
	_speaker = _label("SpeakerName", Rect2(432, 163, 630, 54), 34)
	_role = _label("SpeakerRole", Rect2(432, 220, 688, 32), 18)
	_role.add_theme_color_override("font_color", Color(0.72, 0.67, 0.56))
	var rule := ColorRect.new()
	rule.color = Color(0.47, 0.36, 0.20)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(rule, Rect2(432, 269, 688, 1))
	_caption = _label("DialogueText", Rect2(432, 294, 688, 156), 24)
	_counter = _label("DialoguePosition", Rect2(432, 484, 80, 42), 18)
	_next = Button.new()
	_next.name = "AdvanceDialogue"
	_place(_next, Rect2(784, 474, 336, 64))
	_next.pressed.connect(_advance)
	_skip = Button.new()
	_skip.name = "SkipPrologue"
	_place(_skip, Rect2(432, 576, 336, 44))
	_skip.pressed.connect(_finish)
	_skip.focus_neighbor_right = _next.get_path()
	_skip.focus_next = _next.get_path()
	_skip.focus_previous = _next.get_path()
	_next.focus_neighbor_left = _skip.get_path()
	_next.focus_next = _skip.get_path()
	_next.focus_previous = _skip.get_path()
	_cancel()
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.request_continue_run.connect(_on_continue_requested)
	GameEvents.request_show_main_menu.connect(_cancel)
	GameEvents.run_ended.connect(_on_run_ended)
	GameEvents.settings_changed.connect(_on_settings_changed)

func _place(control: Control, rect: Rect2) -> void:
	_stage.add_child(control)
	control.position = rect.position
	control.size = rect.size

func _label(node_name: String, rect: Rect2, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	_place(label, rect)
	return label

func _on_run_started() -> void:
	call_deferred("_try_open")

func _on_continue_requested() -> void:
	_cancel()
	call_deferred("_try_open")

func _try_open() -> void:
	if _active:
		return
	var payload: Dictionary = _port.get_campaign_dialogue()
	if payload.is_empty():
		return
	_payload = payload
	_beat = 0
	_elapsed = 0.0
	_active = true
	_surface.show()
	_skip.disabled = true
	_next.disabled = true
	get_viewport().gui_release_focus()
	_refresh_line()
	set_process(true)
	set_process_input(true)

func _refresh_line() -> void:
	if not _active:
		return
	var line: Dictionary = _payload.lines[_beat]
	var identity: Dictionary = Catalog.SPEAKERS[line.speaker]
	_image.texture = load(str(identity.portrait)) as Texture2D
	_speaker.text = tr(str(identity.name))
	_role.text = tr(str(identity.role))
	_caption.text = tr(str(line.text))
	_chapter.text = tr(str(_payload.title))
	_counter.text = "%d / %d" % [_beat + 1, _payload.lines.size()]
	_next.text = tr("TORNA AL RITO" if _beat == _payload.lines.size() - 1 else "ASCOLTA") + "  [Enter]"
	_skip.text = tr("SALTA DIALOGO") + "  [Esc]"

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= READ_GUARD and _next.disabled:
		_next.disabled = false
		_skip.disabled = false
		_next.grab_focus()

func _advance() -> void:
	if not _active or _next.disabled:
		return
	if _beat == _payload.lines.size() - 1:
		_finish()
		return
	_beat += 1
	_elapsed = READ_GUARD - 0.18
	_next.disabled = true
	_skip.disabled = true
	_refresh_line()

func _finish() -> void:
	if not _active or _skip.disabled:
		return
	GameEvents.request_dismiss_campaign_dialogue.emit(str(_payload.id))
	_cancel()
	var registry: Control = get_node("../UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book") as Control
	if registry.is_visible_in_tree():
		registry.grab_focus()

func _cancel() -> void:
	_active = false
	_payload = {}
	_surface.hide()
	set_process(false)
	set_process_input(false)

func _on_settings_changed(_settings: Dictionary) -> void:
	_refresh_line()

func _on_run_ended(_reason: String, _summary: Dictionary) -> void:
	_cancel()

func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventKey and event.echo:
		get_viewport().set_input_as_handled()
		return
	if not _next.disabled:
		if event.is_action_pressed("ui_cancel"):
			_finish()
		elif event.is_action_pressed("ui_accept"):
			if _skip.has_focus(): _finish()
			else: _advance()
		elif event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			if _next.has_focus(): _skip.grab_focus()
			else: _next.grab_focus()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if _next.get_global_rect().has_point(event.position): _advance()
			elif _skip.get_global_rect().has_point(event.position): _finish()
	# No key, click or wheel reaches the ritual underneath the conversation.
	get_viewport().set_input_as_handled()
