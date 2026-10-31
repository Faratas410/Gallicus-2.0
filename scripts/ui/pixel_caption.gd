extends Label
## Crisp caption for a button whose skin goes through the pixel shader.
## The button keeps its text for focus, accessibility and tests; only the
## drawing moves here so glyphs are not resampled by the scene grid.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

var _color := Color.TRANSPARENT

func _notification(what: int) -> void:
	# Shown in the middle of a frame: sync before it is drawn.
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		_process(0.0)

func _process(_delta: float) -> void:
	var button := get_parent() as Button
	if button == null or not is_visible_in_tree():
		return
	if text != button.text:
		text = button.text
	var state := "font_disabled_color" if button.disabled else "font_color"
	var color: Color = button.get_meta("pixel_caption_" + state, Color(1, 0.91, 0.68, 1))
	# A theme override notifies the whole Control: set it only when it changes.
	if color != _color:
		_color = color
		add_theme_color_override("font_color", color)
