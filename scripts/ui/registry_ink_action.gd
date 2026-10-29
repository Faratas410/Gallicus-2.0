extends Control
## Ink printed directly on the paper; the native Button owns input and state.
var button: Button
func _ready() -> void:
	button = get_parent() as Button
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.draw.connect(queue_redraw)
	resized.connect(queue_redraw)

func _draw() -> void:
	var ink := Color("45271c")
	var selected: bool = button.get_meta(&"registry_promise_signature_state", &"") == &"selected"
	var active: bool = not button.disabled and (button.has_focus() or button.is_hovered())
	draw_line(Vector2(16, 3), Vector2(size.x - 16, 3), ink, 4 if button.is_pressed() else 2)
	if selected or active:
		draw_line(Vector2(16, size.y - 3), Vector2(size.x - 16, size.y - 3), ink, 4 if active else 2)
	if button.disabled:
		for x: float in [size.x - 28, size.x - 20]:
			draw_line(Vector2(x, size.y * 0.42), Vector2(x, size.y * 0.62), ink, 2)
