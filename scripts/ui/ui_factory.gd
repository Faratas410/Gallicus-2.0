extends RefCounted
class_name UIFactory

const MainPanelStylebox: StyleBox = preload("res://ui/official/styleboxes/sb_panel_main.tres")
const BodyFont: Font = preload("res://assets/ui/fonts/font_body.tres")

static func create_sprite_label(text: String) -> PanelContainer:
	var entry_panel := PanelContainer.new()
	entry_panel.theme_override_styles.panel = MainPanelStylebox
	var entry_label := Label.new()
	entry_label.text = text
	entry_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	entry_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	entry_label.add_theme_font_override("font", BodyFont)
	entry_panel.add_child(entry_label)
	return entry_panel
