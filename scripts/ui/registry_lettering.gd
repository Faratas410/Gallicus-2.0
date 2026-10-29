extends RefCounted
## Local lettering for cloth and leather, independent of body and HUD fonts.
const SOURCE = preload("res://assets/ui/official/typography/fondamento/Fondamento-Regular.ttf")
const PIGMENT = preload("res://assets/ui/official/registry_imprint.gdshader")
static var face: FontFile

static func apply(label: Label, points: int = 25) -> void:
	if face == null:
		face = SOURCE.duplicate() as FontFile
		face.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		face.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	label.add_theme_font_override("font", face)
	label.add_theme_font_size_override("font_size", points)
	label.add_theme_color_override("font_color", Color("e8bc70"))
	label.add_theme_color_override("font_shadow_color", Color("401c17"))
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_constant_override("outline_size", 0)
	var pigment := ShaderMaterial.new()
	pigment.shader = PIGMENT
	label.material = pigment
