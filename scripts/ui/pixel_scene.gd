extends RefCounted
## Pixel-art presentation trial (25 October 2026): the scene is snapped to a
## 640x360 grid with a closed palette; titles use the pixel title face, while
## reading text keeps the regular serif. Presentation only, no gameplay state.
const RitualEnvironment = preload("res://scripts/ui/ritual_environment.gd")
const PALETTE = preload("res://assets/ui/official/pixel_palette.png")
const TITLE_FONT = preload("res://assets/ui/official/typography/pixelify_sans/PixelifySans-Regular.ttf")
const Caption = preload("res://scripts/ui/pixel_caption.gd")
## Art pixels per screen height: 640x360, two viewport pixels per cell at 720p.
const ROWS: float = 360.0
## Pixelify Sans draws one pixel every 100 units: 40 px puts one font pixel on
## two art pixels for titles, 30 px keeps the seal word inside its plate.
const TITLE_SIZE: int = 40
const ACTION_SIZE: int = 30

static func apply_canvas(item: CanvasItem) -> void:
	var material := item.material as ShaderMaterial
	if material == null or material.shader != RitualEnvironment.AGING:
		material = ShaderMaterial.new()
		material.shader = RitualEnvironment.AGING
		item.material = material
	material.set_shader_parameter("pixel_rows", ROWS)
	material.set_shader_parameter("palette", PALETTE)
	material.set_shader_parameter("palette_size", PALETTE.get_width())

static func apply_title(label: Label) -> void:
	label.add_theme_font_override("font", TITLE_FONT)
	label.add_theme_font_size_override("font_size", TITLE_SIZE)

static func apply_judgment(panel: Control, backdrop: TextureRect) -> void:
	if backdrop != null:
		apply_canvas(backdrop)
	var box: Control = panel.get_node("Box_RESOLUTION")
	apply_title(box.get_node("Lbl_RESOLUTION_TITLEPanel/Lbl_RESOLUTION_TITLE") as Label)
	var seal: Button = box.get_node("Btn_RESOLUTION_STRIKE")
	apply_canvas(seal)
	if seal.get_node_or_null("PixelCaption") != null:
		return
	# The shader would resample the glyphs too: draw the words on a child.
	for state: String in ["font_color", "font_disabled_color"]:
		seal.set_meta("pixel_caption_" + state, seal.get_theme_color(state))
	for state: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_disabled_color", "font_hover_pressed_color"]:
		seal.add_theme_color_override(state, Color.TRANSPARENT)
	var caption := Caption.new()
	caption.name = "PixelCaption"
	caption.add_theme_font_override("font", TITLE_FONT)
	caption.add_theme_font_size_override("font_size", ACTION_SIZE)
	seal.add_child(caption)
