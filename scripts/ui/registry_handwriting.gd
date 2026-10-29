extends RefCounted
## Only writing on Registry paper; shared UI typography keeps its own roles.
const FONT_PATH := "res://assets/ui/official/typography/fondamento/Fondamento-Regular.ttf"
const FONT = preload(FONT_PATH)
const ITALIC = preload("res://assets/ui/official/typography/fondamento/Fondamento-Italic.ttf")
const INK_SHADER = preload("res://assets/ui/official/registry_ink.gdshader")
const INK := Color("45271c")
const BODY_SIZE := 18
const TITLE_SIZE := 28
const HEADING_SIZE := 20

static func material() -> ShaderMaterial:
	var ink := ShaderMaterial.new()
	ink.shader = INK_SHADER
	return ink

static func apply(label: RichTextLabel) -> void:
	label.scroll_active = false
	label.focus_mode = Control.FOCUS_NONE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for role: String in ["normal_font", "bold_font", "mono_font"]:
		label.add_theme_font_override(role, FONT)
	for role: String in ["italics_font", "bold_italics_font"]:
		label.add_theme_font_override(role, ITALIC)
	for role: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]:
		label.add_theme_font_size_override(role, BODY_SIZE)
	label.add_theme_color_override("default_color", INK)
	label.add_theme_constant_override("outline_size", 0)
	label.add_theme_constant_override("shadow_outline_size", 0)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_constant_override("line_separation", 0)
	label.material = material()

static func heading(value: String, font_size: int, pigment: Color = INK) -> String:
	var written: String = value.left(1).to_upper() + value.substr(1).to_lower()
	return "[font=%s][font_size=%d][color=#%s]%s[/color][/font_size][/font]" % [FONT_PATH, font_size, pigment.to_html(false), written.replace("[", "[lb]")]
