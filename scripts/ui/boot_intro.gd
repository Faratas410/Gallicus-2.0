extends CanvasLayer

# -----------------------------------------------------------------------------
# ROLE / OWNERSHIP
# - This script is responsible for: the short boot plate shown at every launch
#   before the main menu (ink slab, wordmark, stylus incision, tagline).
# - This script must NOT: emit gameplay intents, touch RunManager or saves.
#
# FLOW CONTRACT (high level)
# - Inputs: any key, mouse button, touch or joypad button skips the plate.
# - Outputs: none; the node frees itself and leaves the menu underneath.
# - Critical invariants: no scale or offset motion; reduced motion shows a
#   still plate and cuts; headless runs, tools that instance Main.tscn and
#   `--skip-intro` never show it.
# -----------------------------------------------------------------------------

const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const WORDMARK: Texture2D = preload("res://assets/ui/generated/gallicus_wordmark.png")
const MAIN_SCENE_PATH: String = "res://scenes/Main.tscn"
const SKIP_ARGUMENT: String = "--skip-intro"
const TAGLINE: String = "L'arena dimentica. Il Registro no."

# Beats in seconds: ink, wordmark + incision, tagline, dissolve to the menu.
const INK_END: float = 0.40
const WORDMARK_FADE: float = 0.30
const INCISION_END: float = 1.20
const TAGLINE_FADE: float = 0.20
const DISSOLVE_START: float = 2.00
const DISSOLVE_SECONDS: float = 0.40
const REDUCED_HOLD: float = 0.80
const WORDMARK_MAX: Vector2 = Vector2(740.0, 247.0)
const INCISION_WIDTH: float = 420.0

var _surface: Control = null
var _tagline: Label = null
var _time: float = 0.0
var _reduced_motion: bool = false
var _dissolve_from: float = -1.0

func _ready() -> void:
	if _should_skip():
		queue_free()
		return
	_reduced_motion = SaveManager != null and SaveManager.get_reduced_motion()
	_surface = Control.new()
	_surface.name = "BootIntroSurface"
	_surface.set_anchors_preset(Control.PRESET_FULL_RECT)
	_surface.mouse_filter = Control.MOUSE_FILTER_STOP
	_surface.draw.connect(_draw_surface)
	add_child(_surface)
	_tagline = Label.new()
	_tagline.name = "BootIntroTagline"
	_tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tagline.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tagline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Kit.apply_body(_tagline)
	_tagline.text = tr(TAGLINE)
	_surface.add_child(_tagline)
	_refresh()

func _should_skip() -> bool:
	if DisplayServer.get_name() == "headless":
		return true
	if SKIP_ARGUMENT in OS.get_cmdline_user_args():
		return true
	# Visual QA and runtime contracts instance Main.tscn under their own root.
	var current: Node = get_tree().current_scene
	return current == null or current.scene_file_path != MAIN_SCENE_PATH

func _process(delta: float) -> void:
	_time += delta
	if _time >= _end_time():
		queue_free()
		return
	_refresh()

func _input(event: InputEvent) -> void:
	var skips: bool = (
		event is InputEventKey
		or event is InputEventMouseButton
		or event is InputEventScreenTouch
		or event is InputEventJoypadButton
	)
	if not skips or not event.is_pressed() or event.is_echo():
		return
	get_viewport().set_input_as_handled()
	_skip()

func _skip() -> void:
	if _reduced_motion or _dissolve_from >= 0.0:
		queue_free()
		return
	_dissolve_from = _time

func _end_time() -> float:
	if _reduced_motion:
		return REDUCED_HOLD
	if _dissolve_from >= 0.0:
		return _dissolve_from + DISSOLVE_SECONDS
	return DISSOLVE_START + DISSOLVE_SECONDS

func _plate_alpha() -> float:
	if _reduced_motion:
		return 1.0
	var start: float = _dissolve_from if _dissolve_from >= 0.0 else DISSOLVE_START
	return 1.0 - clampf((_time - start) / DISSOLVE_SECONDS, 0.0, 1.0)

func _wordmark_alpha() -> float:
	if _reduced_motion:
		return 1.0
	return clampf((_time - INK_END) / WORDMARK_FADE, 0.0, 1.0)

func _incision_progress() -> float:
	if _reduced_motion:
		return 1.0
	return clampf((_time - INK_END) / (INCISION_END - INK_END), 0.0, 1.0)

func _tagline_alpha() -> float:
	if _reduced_motion:
		return 1.0
	return clampf((_time - INCISION_END) / TAGLINE_FADE, 0.0, 1.0)

func _refresh() -> void:
	if _surface == null:
		return
	_layout()
	_surface.modulate.a = _plate_alpha()
	_tagline.modulate.a = _tagline_alpha()
	_surface.queue_redraw()

func _wordmark_rect() -> Rect2:
	var view: Vector2 = _surface.size
	var texture_size: Vector2 = WORDMARK.get_size()
	var fit: float = minf(WORDMARK_MAX.x / texture_size.x, WORDMARK_MAX.y / texture_size.y)
	var draw_size: Vector2 = texture_size * fit
	return Rect2((view - draw_size) * 0.5 - Vector2(0.0, 40.0), draw_size)

func _layout() -> void:
	if _surface == null:
		return
	var rect: Rect2 = _wordmark_rect()
	_tagline.offset_top = rect.end.y + Kit.SPACE * 5
	_tagline.offset_bottom = 0.0

func _draw_surface() -> void:
	_surface.draw_rect(Rect2(Vector2.ZERO, _surface.size), Palette.INK)
	var rect: Rect2 = _wordmark_rect()
	_surface.draw_texture_rect(WORDMARK, rect, false, Color(1.0, 1.0, 1.0, _wordmark_alpha()))
	var progress: float = _incision_progress()
	if progress <= 0.0:
		return
	# The stylus incises left to right under the wordmark: width grows, nothing moves.
	var left: float = (_surface.size.x - INCISION_WIDTH) * 0.5
	var y: float = rect.end.y + Kit.SPACE * 2
	_surface.draw_rect(Rect2(left, y, INCISION_WIDTH * progress, Kit.FOCUS_RULE), Palette.IVORY)
