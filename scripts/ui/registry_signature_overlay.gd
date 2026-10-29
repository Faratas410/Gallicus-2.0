extends CanvasLayer
## Short visual echo of an accepted bet. Never delays or emits a run intent.
const Volume = preload("res://scripts/ui/registry_volume.gd")
const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const Handwriting = preload("res://scripts/ui/registry_handwriting.gd")
var ink: Control
var elapsed: float = 0.0
var reduced: bool = false

func present(source: Control, side: int) -> void:
	layer = 70
	var surface := Control.new()
	add_child(surface)
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	var background := TextureRect.new()
	background.texture = source.arena_background.texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.offset_top = source.book_frame.get_global_rect().position.y
	var stage := Control.new()
	surface.add_child(stage)
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.offset_top = background.offset_top
	surface.resized.connect(func() -> void:
		var inset: float = preload("res://scripts/ui/ritual_status_header.gd").CONTENT_TOP * minf(surface.size.x / 1280.0, surface.size.y / 720.0)
		background.offset_top = inset
		stage.offset_top = inset)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ink = Volume.new()
	stage.add_child(ink)
	ink.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ink.signature_side = side
	ink.show_pen = true
	for original: Control in [source.header_label, source.left_contract_label, source.right_contract_label]:
		var copy: Control
		if original is RichTextLabel:
			var rich := RichTextLabel.new()
			rich.bbcode_enabled = true
			rich.text = original.text
			Handwriting.apply(rich)
			rich.scroll_active = false
			copy = rich
		else:
			var label := Label.new()
			label.text = original.text
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			Kit.apply_label(label, &"title", Kit.Palette.IVORY)
			copy = label
		copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage.add_child(copy)
		# Normalize against the same stage so resizing cannot separate ink/paper.
		var rect: Rect2 = original.get_global_rect()
		var base: Rect2 = source.book_frame.get_global_rect()
		copy.set_anchor(SIDE_LEFT, (rect.position.x - base.position.x) / base.size.x)
		copy.set_anchor(SIDE_TOP, (rect.position.y - base.position.y) / base.size.y)
		copy.set_anchor(SIDE_RIGHT, (rect.end.x - base.position.x) / base.size.x)
		copy.set_anchor(SIDE_BOTTOM, (rect.end.y - base.position.y) / base.size.y)
		for edge: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			copy.set_offset(edge, 0)
	GameEvents.request_show_main_menu.connect(_cancel)
	GameEvents.run_started.connect(_cancel)
	GameEvents.run_ended.connect(_cancel.unbind(2))
	GameEvents.pact_sealed_closed.connect(_cancel)
	GameEvents.settings_changed.connect(_settings)
	reduced = SaveManager.get_reduced_motion()
	if reduced:
		ink.signature_progress = 1.0
		elapsed = 0.50

func _settings(payload: Dictionary) -> void:
	if bool(payload.get("reduced_motion", false)):
		reduced = true
		ink.signature_progress = 1.0
		elapsed = maxf(elapsed, 0.50)

func _process(delta: float) -> void:
	if ink == null:
		return
	elapsed += delta
	ink.signature_progress = 1.0 if reduced else clampf(elapsed / 0.48, 0.0, 1.0)
	if elapsed >= 0.65:
		_cancel()

func _input(event: InputEvent) -> void:
	# A deliberate confirm skips the visual echo and reaches the existing pact
	# input in the same frame. Presentation must never stall keyboard progression.
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_cancel()
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()

func _cancel() -> void:
	set_process(false)
	set_process_input(false)
	hide()
	queue_free()
