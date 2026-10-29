extends "res://scripts/ui/ritual_pixel_object.gd"
## Same native opening target; only the local inscription changes.
const Imprint = preload("res://scripts/ui/registry_lettering.gd")

func _layout() -> void:
	if not is_inside_tree():
		return
	super._layout()
	if heading:
		var factor := minf(get_viewport_rect().size.x / 1280.0, get_viewport_rect().size.y / 720.0)
		Imprint.apply(heading, roundi(25 * factor))
