extends RefCounted
class_name UIFactory

const MAIN_PANEL_STYLEBOX_PATH: String = "res://assets/ui/official/styleboxes/sb_panel_main.tres"
const BODY_FONT_PATH: String = "res://assets/ui/fonts/font_body.tres"

static func create_sprite_label(text: String) -> PanelContainer:
	var entry_panel := PanelContainer.new()
	var main_panel_stylebox: StyleBox = StyleBoxEmpty.new()
	if main_panel_stylebox != null:
		entry_panel.add_theme_stylebox_override("panel", main_panel_stylebox)
	var entry_label := Label.new()
	entry_label.text = text
	entry_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var body_font: Font = _safe_load_font(BODY_FONT_PATH)
	if body_font != null:
		entry_label.add_theme_font_override("font", body_font)
	entry_panel.add_child(entry_label)
	return entry_panel

static func _safe_load_stylebox(path: String) -> StyleBox:
	if not ResourceLoader.exists(path, "StyleBox"):
		return null
	return load(path) as StyleBox

static func _safe_load_font(path: String) -> Font:
	if not ResourceLoader.exists(path, "Font") and not ResourceLoader.exists(path, "FontFile") and not ResourceLoader.exists(path, "FontVariation"):
		return null
	return load(path) as Font
