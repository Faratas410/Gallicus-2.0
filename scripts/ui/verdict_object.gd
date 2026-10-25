extends Control
## Passive physical skin; the parent's rectangular native target never moves.
const TYPE = preload("res://assets/ui/fonts/font_verdict.tres")
const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const RECEIPT = preload("res://assets/ui/generated/receipt.png")
const SEAL = preload("res://assets/ui/generated/verdict_owl_seal.png")
const CONDEMNATION = preload("res://assets/ui/generated/condemnation_mark.png")
var kind := "cashout"
var registered := false
var dense := false
var factor := 1.0
var lift := 0.0
var button: Button

func _ready() -> void:
	button = get_parent() as Button
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for event: Signal in [button.mouse_entered, button.mouse_exited, button.focus_entered, button.focus_exited, button.button_down, button.button_up]:
		event.connect(queue_redraw)

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var reduced: bool = get_node("/root/SaveManager").get_reduced_motion()
	var target := -4.0 if (button.is_hovered() or button.has_focus()) and not button.disabled else 0.0
	if button.is_pressed():
		target = 2.0
	lift = 0.0 if reduced else move_toward(lift, target, delta * 45.0)
	queue_redraw()

func _draw() -> void:
	if button == null:
		return
	var w := size.x / factor
	var h := size.y / factor
	var seal := kind == "double"
	var rect := Rect2(5, 20, w - 10, h - 34)
	if seal:
		rect = Rect2((w - 190) * 0.5, -6, 190, 155) if dense else Rect2(12, 6, 248, 226)
	var tilt := -0.025 if kind == "cashout" else 0.018
	draw_set_transform(Vector2(0, lift) * factor, tilt, Vector2.ONE * factor)
	var tint := Color.WHITE if not button.disabled or registered else Color(0.76, 0.73, 0.68)
	var texture: Texture2D = SEAL if seal else CONDEMNATION if kind == "condanna" else RECEIPT
	draw_texture_rect(texture, Rect2(rect.position + Vector2(5, 11), rect.size), false, Color(0, 0, 0, 0.65))
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
	draw_set_transform(Vector2(0, lift) * factor, tilt, Vector2.ONE * factor)
	if registered:
		if seal:
			# Reopened wax receives a deliberate second parallel incision, not a fracture.
			for i in range(2):
				var at := rect.position + Vector2(rect.size.x * 0.38 + i * 16, rect.size.y * 0.70)
				draw_line(at, at + Vector2(19, -26), Color("260f0d"), 5, true)
				draw_line(at + Vector2(2, 1), at + Vector2(21, -25), Color("d99d6b"), 1.5, true)
		else:
			var stamp := tr("INCASSATA") if kind == "cashout" else tr("REGISTRATA")
			var at := Vector2(w - 160, h - 35)
			draw_rect(Rect2(at - Vector2(6, 24), Vector2(150, 33)), Color("792d26"), false, 2)
			draw_string(TYPE, at, stamp, HORIZONTAL_ALIGNMENT_LEFT, 142, 18, Color("792d26"))
	draw_set_transform(Vector2.ZERO)
