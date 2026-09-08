extends CanvasLayer

# Presentation only. RunManager has already entered a valid gameplay phase.
const CHAMBER: Texture2D = preload("res://assets/ui/generated/registry_chamber.png")
const REGISTRY: Texture2D = preload("res://assets/ui/generated/registry_closed.png")
const LINES: Array[String] = ["Ogni rischio accettato lascia un segno.", "Il Registro conserva le tue scelte."]
const DURATION: float = 8.0
const SKIP_DELAY: float = 0.5

var _surface: Control
var _image: TextureRect
var _caption: Label
var _skip: Button
var _elapsed: float = 0.0
var _armed: bool = false
var _shown: bool = false
var _active: bool = false
var _beat: int = -1

func _ready() -> void:
	layer = 90
	_shown = SaveManager.has_seen_opening_prologue()
	_surface = Control.new()
	_surface.name = "PrologueSurface"
	_surface.theme = preload("res://assets/ui/theme/official_theme.tres")
	add_child(_surface)
	_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.04, 0.03, 0.02)
	_surface.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_image = TextureRect.new()
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(_image)
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.015, 0.01, 0.42)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caption = Label.new()
	_caption.name = "LoreCaption"
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 28)
	_caption.add_theme_color_override("font_shadow_color", Color.BLACK)
	_caption.add_theme_constant_override("shadow_offset_y", 2)
	_surface.add_child(_caption)
	_caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_caption.anchor_top = 0.65
	_caption.anchor_bottom = 0.82
	_caption.offset_left = 64
	_caption.offset_right = -64
	_skip = Button.new()
	_skip.name = "SkipPrologue"
	_surface.add_child(_skip)
	_skip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_skip.offset_left = -240
	_skip.offset_right = -40
	_skip.offset_top = -88
	_skip.offset_bottom = -36
	_skip.pressed.connect(_finish)
	_surface.hide()
	set_process(false)
	set_process_input(false)
	GameEvents.run_started.connect(_on_run_started)
	GameEvents.request_show_main_menu.connect(_cancel)
	GameEvents.request_continue_run.connect(_cancel)
	GameEvents.run_ended.connect(_on_run_ended)

func prepare_first_entry() -> void:
	# Existing persistent campaign evidence distinguishes entry from later runs.
	_armed = not _shown and not SaveManager.has_run_save() and SaveManager.get_registry_era() == 0 and SaveManager.get_registry_pressure() == 0.0 and int(SaveManager.get_registry_evolution().get("samples", 0)) == 0

func _on_run_started() -> void:
	if not _armed:
		return
	_armed = false
	_shown = true
	SaveManager.mark_opening_prologue_seen()
	_active = true
	_elapsed = 0.0
	_beat = -1
	_surface.modulate = Color.WHITE
	_surface.show()
	_skip.disabled = true
	_skip.show()
	get_viewport().gui_release_focus()
	_update_presentation()
	set_process(true)
	set_process_input(true)

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DURATION:
		_finish()
		return
	if _skip.disabled and _elapsed >= SKIP_DELAY:
		_skip.disabled = false
		_skip.grab_focus()
	_update_presentation()

func _update_presentation() -> void:
	var beat: int = 0 if _elapsed < 3.0 else 1
	if beat != _beat:
		_beat = beat
		_image.texture = CHAMBER if beat == 0 else REGISTRY
	_caption.text = tr(LINES[beat])
	_skip.text = tr("SALTA") + "  [Esc]"
	var reduced: bool = SaveManager.get_reduced_motion()
	_image.pivot_offset = _image.size * 0.5
	_image.scale = Vector2.ONE if reduced else Vector2.ONE * (1.0 + minf(_elapsed, 6.0) * 0.002)
	_surface.modulate.a = 1.0 if reduced else 1.0 - clampf((_elapsed - 6.0) / 2.0, 0.0, 1.0)

func _input(event: InputEvent) -> void:
	if not _active:
		return
	if _elapsed >= SKIP_DELAY:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
			_finish()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _skip.get_global_rect().has_point(event.position):
			_finish()
	# Block underlying ritual input, including during the final dissolve.
	get_viewport().set_input_as_handled()

func _finish() -> void:
	if not _active:
		return
	_cancel()
	var registry: Control = get_node("../UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book") as Control
	if registry.is_visible_in_tree():
		registry.grab_focus()

func _cancel() -> void:
	_armed = false
	_active = false
	_surface.hide()
	_image.scale = Vector2.ONE
	set_process(false)
	set_process_input(false)

func _on_run_ended(_reason: String, _summary: Dictionary) -> void:
	_cancel()
