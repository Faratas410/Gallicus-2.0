extends Node
## Layout adapter for the three native ritual panels. No flow or game state.
const ObjectArt = preload("res://scripts/ui/ritual_pixel_object.gd")
const Writing = preload("res://scripts/ui/registry_handwriting.gd")
const DISPLAY = preload("res://assets/ui/fonts/font_verdict.tres")
const ARENA = preload("res://assets/ui/generated/registry_volume_arena.png")
var panel: Control
var ui: CanvasLayer
var kind: String
var box: Control
var backdrop: TextureRect

static func install(owner_ui: CanvasLayer, target: Control, stage_kind: String) -> void:
	var stage := new()
	stage.name = "PixelRitualStage"
	stage.ui = owner_ui
	stage.panel = target
	stage.kind = stage_kind
	target.add_child(stage)
	stage.setup()

func setup() -> void:
	box = panel.get_node("Box_" + kind)
	panel.custom_minimum_size = Vector2.ZERO
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	for old: Node in panel.find_children("ManifestoDocument", "", true, false):
		(old as CanvasItem).hide()
	var phase := panel.get_parent()
	for item: Node in phase.get_children():
		if "BackdropShade" in item.name: (item as CanvasItem).hide()
		elif "Backdrop" in item.name and item is TextureRect:
			backdrop = item
			backdrop.texture = ARENA
			backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	if kind == "FIRST_REACTION":
		_object(panel, "PactTablet", 0, Rect2(340, 76, 600, 500))
		_action(ui.get("pact_sealed_advance_button"), -1)
	elif kind == "MID_CHOICE":
		_action(ui.get("intermediate_choice_placa_button"), 2)
		_action(ui.get("intermediate_choice_provoca_button"), 3)
		# A parchment voice strip beneath the banner; never a black modal.
		var voice_support := TextureRect.new()
		voice_support.name = "AudienceParchment"
		var region := AtlasTexture.new()
		region.atlas = ObjectArt.ATLAS
		region.region = Rect2(95, 176, 460, 235)
		voice_support.texture = region
		voice_support.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		voice_support.mouse_filter = Control.MOUSE_FILTER_IGNORE
		voice_support.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		panel.add_child(voice_support)
		panel.move_child(voice_support, 0)
		_place(voice_support, Rect2(325, 92, 630, 118))
	else:
		_object(panel, "JudgmentRecord", 2, Rect2(550, 66, 714, 510))
		_action(ui.get("resolve_ritual_strike_button"), 1)
		_action(ui.get("resolve_ritual_advance_button"), -2)
		var pips: Array = ui.get("resolve_ritual_seal_pips")
		for i: int in range(pips.size()):
			var pip: Control = pips[i]
			pip.anchor_left = 0.44 + i * 0.08
			pip.anchor_right = pip.anchor_left
			pip.anchor_top = 0.67
			pip.anchor_bottom = pip.anchor_top
	panel.get_viewport().size_changed.connect(layout)
	panel.visibility_changed.connect(layout)
	layout()

func _object(parent: Control, object_name: String, tile: int, rect: Rect2) -> void:
	var skin := ObjectArt.new()
	skin.name = object_name
	skin.tile = tile
	parent.add_child(skin)
	parent.move_child(skin, 0)
	_place(skin, rect)

func _action(button: Button, tile: int) -> void:
	var skin := ObjectArt.new()
	skin.name = "PixelRitualObject"
	skin.tile = tile
	button.add_child(skin)
	button.move_child(skin, 0)
	button.set_meta("pixel_ritual", true)

func _place(control: Control, rect: Rect2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.custom_minimum_size = Vector2.ZERO
	control.position = rect.position
	control.size = rect.size

func _text(label: Label, rect: Rect2, heading: bool = false, font_size: int = 20) -> void:
	var support := label.get_parent() as Control
	support.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_place(support, rect)
	label.add_theme_font_override("font", DISPLAY if heading else Writing.FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("f4e4b5") if heading else Writing.INK)
	label.add_theme_constant_override("outline_size", 0)
	label.material = null if heading else Writing.material()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if heading else HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.custom_minimum_size = Vector2.ZERO
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	(support as Container).queue_sort()

func layout() -> void:
	var viewport := panel.get_viewport_rect().size
	var factor: float = minf(viewport.x / 1280.0, viewport.y / 720.0)
	_place(panel, Rect2(Vector2((viewport.x - 1280 * factor) * 0.5, 128 * factor), Vector2(1280, 592)))
	panel.scale = Vector2.ONE * factor
	_place(box, Rect2(0, 0, 1280, 592))
	if backdrop != null:
		_place(backdrop, Rect2(0, 128 * factor, viewport.x, viewport.y - 128 * factor))
	if kind == "FIRST_REACTION":
		_text(ui.get("pact_sealed_title"), Rect2(365, 6, 550, 52), true, 26)
		_text(ui.get("pact_sealed_subtitle"), Rect2(445, 218, 390, 130))
		_place(ui.get("pact_sealed_advance_button"), Rect2(446, 352, 330, 68))
	elif kind == "MID_CHOICE":
		_text(ui.get("intermediate_choice_label"), Rect2(365, 6, 550, 52), true, 23)
		_text(ui.get("intermediate_choice_audience_label"), Rect2(350, 100, 580, 98), false, 18)
		_place(box.get_node("Box_MID_CHOICE_CHOICES"), Rect2(0, 0, 1280, 592))
		_place(ui.get("intermediate_choice_placa_button"), Rect2(192, 230, 430, 346))
		_place(ui.get("intermediate_choice_provoca_button"), Rect2(658, 230, 430, 346))
	else:
		_text(ui.get("resolve_ritual_title"), Rect2(365, 6, 550, 52), true, 26)
		_text(ui.get("resolve_ritual_prompt"), Rect2(650, 200, 510, 60), false, 18)
		_text(ui.get("resolve_ritual_subtitle"), Rect2(650, 264, 510, 180), false, 18)
		_place(ui.get("resolve_ritual_strike_button"), Rect2(60, 144, 490, 432))
		_place(ui.get("resolve_ritual_advance_button"), Rect2(730, 484, 350, 44))
