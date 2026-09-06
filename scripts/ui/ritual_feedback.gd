extends CanvasLayer

# Cosmetic only. No input interception, timers in flow, or gameplay RNG.
const DUST: Texture2D = preload("res://assets/ui/generated/ritual_dust.png")
const MAX_EFFECTS: int = 2
const CUES: Array[StringName] = [
	&"arena_threshold_cross", &"registry_table_open", &"registry_promise_sign",
	&"registry_pact_validate", &"arena_gesture_placa", &"arena_gesture_provoca",
	&"registry_judgment_seal_strike", &"registry_judgment_seal_resolve",
	&"registry_receipt_take", &"registry_condemnation_mark", &"registry_second_incision",
	&"registry_dossier_update", &"registry_dossier_close", &"registry_dossier_route",
]
var _sprites: Array[TextureRect] = []
var _tweens: Array[Tween] = []
var _next: int = 0

func _ready() -> void:
	layer = 20
	add_to_group("ritual_feedback")
	for index: int in range(MAX_EFFECTS):
		var sprite: TextureRect = TextureRect.new()
		sprite.texture = DUST
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sprite.focus_mode = Control.FOCUS_NONE
		sprite.hide()
		add_child(sprite)
		_sprites.append(sprite)
		_tweens.append(null)
	GameEvents.settings_changed.connect(_on_settings_changed)
	GameEvents.run_phase_changed.connect(_on_phase_changed)
	GameEvents.run_ended.connect(_on_run_ended)

func play_cue(cue: StringName, target: Control) -> void:
	if not CUES.has(cue) or SaveManager.get_reduced_motion():
		return
	if not is_instance_valid(target) or not target.is_visible_in_tree():
		return
	var slot: int = _next
	_next = (_next + 1) % MAX_EFFECTS
	if _tweens[slot] != null and _tweens[slot].is_valid():
		_tweens[slot].kill()
	var sprite: TextureRect = _sprites[slot]
	var rect: Rect2 = target.get_global_rect()
	var extent: float = clampf(rect.size.x * 0.35, 90.0, 160.0)
	sprite.size = Vector2.ONE * extent
	# Lower edge keeps glyphs and focus clear. Controls themselves never move.
	sprite.position = Vector2(rect.position.x + rect.size.x * 0.22 - extent * 0.5, rect.end.y - extent * 0.50)
	sprite.pivot_offset = sprite.size * 0.5
	sprite.scale = Vector2.ONE * 0.92
	sprite.modulate = Color(1.0, 0.94, 0.80, 0.0)
	sprite.show()
	var tween: Tween = create_tween()
	_tweens[slot] = tween
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.42, 0.07)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.34)
	tween.parallel().tween_property(sprite, "scale", Vector2.ONE * 1.06, 0.34)
	tween.parallel().tween_property(sprite, "position:y", sprite.position.y - 5.0, 0.34)
	tween.tween_callback(sprite.hide)

func clear() -> void:
	for index: int in range(_sprites.size()):
		if _tweens[index] != null and _tweens[index].is_valid():
			_tweens[index].kill()
		_tweens[index] = null
		_sprites[index].hide()

func _on_settings_changed(payload: Dictionary) -> void:
	if bool(payload.get("reduced_motion", false)):
		clear()

func _on_phase_changed(_phase: int) -> void:
	clear()

func _on_run_ended(_reason: String, _summary: Dictionary) -> void:
	clear()

func _exit_tree() -> void:
	clear()
