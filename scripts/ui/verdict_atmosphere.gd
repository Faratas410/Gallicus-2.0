extends Control
## Shared, passive arena presence. No gameplay RNG and no input interception.
const ARENA = preload("res://assets/ui/generated/arena_unified.png")
const CROWD = preload("res://assets/ui/generated/verdict_avian_crowd.png")
const RitualEnvironment = preload("res://scripts/ui/ritual_environment.gd")
var pixel_arena := false
var staging: StringName = &"risk"
var draw_background := true
var clock := 0.0
var favor := 0
var pressure := 0
var impact := 0.0
var celebration := 0.0
var recoil := 0.0
var environment_fade := 0.0
var _backdrop: TextureRect

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	add_to_group("arena_presence")
	if draw_background:
		_backdrop = TextureRect.new()
		_backdrop.name = "SharedArenaBackdrop"
		_backdrop.texture = preload("res://assets/ui/generated/verdict_arena_v2.png") if pixel_arena else ARENA
		if pixel_arena: _backdrop.texture_filter = TEXTURE_FILTER_NEAREST
		_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_backdrop.stretch_mode = TextureRect.STRETCH_SCALE if pixel_arena else TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_backdrop.mouse_filter = MOUSE_FILTER_IGNORE
		_backdrop.show_behind_parent = true
		add_child(_backdrop)
		_backdrop.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	if pixel_arena and _backdrop:
		_backdrop.offset_top = 128
	GameEvents.settings_changed.connect(func(payload: Dictionary) -> void:
		if bool(payload.get("reduced_motion", false)): _settle_motion())
	GameEvents.seal_strike_resolved.connect(func(payload: Dictionary) -> void:
		if is_visible_in_tree(): present_outcome(bool(payload.get("held", false))))
	GameEvents.run_phase_changed.connect(func(_phase: int) -> void: _settle_motion())

func present_environment(fade: float) -> void:
	environment_fade = fade
	if is_instance_valid(_backdrop): RitualEnvironment.apply(_backdrop, fade)
	queue_redraw()

func _settle_motion() -> void:
	impact = 0.0
	celebration = 0.0
	recoil = 0.0
	queue_redraw()

func risk_impact() -> void:
	if not get_node("/root/SaveManager").get_reduced_motion(): impact = 1.0

func present_outcome(held: bool) -> void:
	_settle_motion()
	if not get_node("/root/SaveManager").get_reduced_motion():
		celebration = 1.0 if held else 0.0
		recoil = 0.0 if held else 1.0

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if not get_node("/root/SaveManager").get_reduced_motion():
		clock += delta
		impact = maxf(0, impact - delta * 5)
		celebration = maxf(0, celebration - delta * 1.7)
		recoil = maxf(0, recoil - delta * 2.5)
	queue_redraw()

func _draw() -> void:
	var s := minf(size.x / 1280, size.y / 720)
	if s <= 0: return
	var w := size.x / s
	var h := size.y / s
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * s)
	var wear := clampf(environment_fade / 0.21, 0.0, 1.0)
	if pixel_arena:
		if _backdrop: _backdrop.offset_top = 128 * s
		for i in range(12):
			var point := Vector2(fposmod(i * 137.1 + clock * 2, w), 150 + fposmod(i * 73.7 - clock, h - 150))
			draw_rect(Rect2(point, Vector2.ONE * 2), Color(1, 0.8, 0.4, 0.12 + celebration * 0.15))
		draw_set_transform(Vector2.ZERO)
		return
	# Feet stay planted. Sparse groups have individual, slow pivots and brief
	# event reactions; they no longer bob up/down as a moving decorative band.
	for i in range(5):
		var x := 60.0 + i * (w - 200) / 4
		var base_y := h * (0.28 if staging == &"crowd" else 0.17)
		var source := Rect2(((i * 2 + 1) % 3) * 600, 0, 600, 724)
		var tilt := sin(clock * 0.55 + i * 2.1) * 0.002
		tilt += sin(clock * 2.0 + i) * celebration * 0.022 + recoil * (0.008 if i % 2 else -0.008)
		draw_set_transform(Vector2(x + 38, base_y + 82) * s, tilt, Vector2.ONE * s)
		draw_texture_rect_region(CROWD, Rect2(-38, -82, 76, 82), source, Color(0.68, 0.63, 0.53, (0.65 if staging == &"crowd" else 0.42) * (1.0 - wear * 0.72)))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * s)
	if staging != &"risk":
		draw_set_transform(Vector2.ZERO)
		return
	# Same arena and exposure; reading veils are local to this composition.
	draw_rect(Rect2(0, 0, w, h), Color(0.025, 0.021, 0.019, 0.26))
	draw_rect(Rect2(0, 82, w, 328), Color(0.025, 0.021, 0.019, 0.34))
	for i in range(24):
		var y := h - 300 + i * 14
		draw_rect(Rect2(0, y, w, 14), Color(0.055, 0.047, 0.038, 0.10 + i * 0.030))
	draw_rect(Rect2(0, 0, w, 70), Color(0.035, 0.03, 0.022, 0.94))
	draw_line(Vector2(30, 65), Vector2(w - 30, 65), Color(0.65, 0.51, 0.33, 0.16), 1)
	# Light breathes on the painted lamps: no second polygon flame.
	for x: float in [w * 0.335, w * 0.66]:
		for ring in range(5, 0, -1):
			draw_circle(Vector2(x, h * 0.46), ring * 9.0, Color(0.9, 0.48, 0.13, (0.008 + sin(clock * 0.8 + ring) * 0.001 + impact * 0.004) * (1.0 - wear)))
	for i in range(12):
		var x := fposmod(i * 137.1 + clock * (2 + i % 3), w)
		var y := fposmod(i * 73.7 - clock * (1 + i % 2), h)
		draw_circle(Vector2(x, y), 0.7, Color(0.9, 0.72, 0.42, 0.10 * (1.0 - wear)))
	# Pressure belongs to the shared header; environmental wear never dims it.
	draw_set_transform(Vector2.ZERO)
