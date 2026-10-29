extends Control
## Passive physical skin; the parent's rectangular native target never moves.
const TYPE = preload("res://assets/ui/fonts/font_verdict.tres")
const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const Art = preload("res://scripts/ui/banco_pixel_art.gd")
const Paper = preload("res://scripts/ui/banco_paper.gd")
var paper: Control
var SEAL := Art.texture(Art.SEAL)
var CONDEMNATION := Art.texture(Art.CONDEMNATION)
var kind := "cashout"
var registered := false
var dense := false
var factor := 1.0
var button: Button

func _ready() -> void:
	button = get_parent() as Button
	texture_filter = TEXTURE_FILTER_NEAREST
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	paper = Paper.new()
	paper.name = "ObjectPaper"
	paper.show_behind_parent = true
	add_child(paper)
	for event: Signal in [button.mouse_entered, button.mouse_exited, button.focus_entered, button.focus_exited, button.button_down, button.button_up]:
		event.connect(queue_redraw)

static func support_rect(action: String, width: float) -> Rect2:
	if action == "double": return Rect2(146, 24, width - 158, 180)
	var paper_width := minf(360, width - 10)
	return Rect2((width - paper_width) * 0.5, 24, paper_width, 180)

func _process(_delta: float) -> void:
	if not is_visible_in_tree(): return
	paper.visible = kind != "condanna"
	var support := support_rect(kind, size.x / factor)
	paper.position = support.position * factor
	paper.size = support.size * factor
	paper.modulate = Color.WHITE if not button.disabled or registered else Color(0.82, 0.79, 0.74)
	queue_redraw()

func _draw() -> void:
	if button == null:
		return
	var w := size.x / factor
	var h := size.y / factor
	var seal := kind == "double"
	var rect := support_rect(kind, w)
	if seal:
		rect = Rect2(8, 40, 126, 140)
	var tilt := 0.0
	draw_set_transform(Vector2.ZERO, tilt, Vector2.ONE * factor)
	var tint := Color.WHITE if not button.disabled or registered else Color(0.76, 0.73, 0.68)
	if seal or kind == "condanna":
		var texture: Texture2D = SEAL if seal else CONDEMNATION
		draw_texture_rect(texture, Rect2(rect.position + Vector2(3, 6), rect.size), false, Color(0, 0, 0, 0.5))
		draw_texture_rect(texture, rect, false, tint)
	# Same lower stylus rule as the kit, on the fixed target rather than wax.
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * factor)
	var pigment := Palette.INK if kind == "cashout" else Palette.IVORY
	if (button.has_focus() or button.is_hovered()) and not button.disabled:
		draw_line(Vector2(12, h - 5), Vector2(w - 12, h - 5), Palette.INK, 7, true)
		draw_line(Vector2(12, h - 5), Vector2(w - 12, h - 5), Palette.IVORY, 4, true)
	if button.disabled and not registered:
		for y: float in [h - 18, h - 11]:
			draw_line(Vector2(18, y), Vector2(44, y), pigment, 3, true)
	draw_set_transform(Vector2.ZERO, tilt, Vector2.ONE * factor)
	if registered:
		if seal:
			# Reopened wax receives a deliberate second parallel incision, not a fracture.
			for i in range(2):
				var at := rect.position + Vector2(rect.size.x * 0.38 + i * 16, rect.size.y * 0.70)
				draw_line(at, at + Vector2(19, -26), Color("260f0d"), 5, true)
				draw_line(at + Vector2(2, 1), at + Vector2(21, -25), Color("d99d6b"), 1.5, true)
		else:
			var stamp := tr("INCASSATA") if kind == "cashout" else tr("REGISTRATA")
			var at := support_rect(kind, w).end - Vector2(172, 14)
			draw_rect(Rect2(at - Vector2(6, 24), Vector2(150, 33)), Color("792d26"), false, 2)
			draw_string(TYPE, at, stamp, HORIZONTAL_ALIGNMENT_LEFT, 142, 18, Color("792d26"))
	draw_set_transform(Vector2.ZERO)
