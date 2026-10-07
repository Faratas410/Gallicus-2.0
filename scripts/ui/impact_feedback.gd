extends Node

# Presentation-only impact for the player's gestures: screen shake, a brief
# flash and wax or dust bursts. It never touches flow or outcome; UIRoot calls
# it after RunManager has answered. Reduced motion keeps only a faint flash.

const SHAKE_STEP_SECONDS: float = 0.03
const BURST_LIFETIME_SECONDS: float = 0.7

var _layer: CanvasLayer = null
var _reduced_motion: Callable = Callable()
var _flash: ColorRect = null
var _shake_tween: Tween = null
var _flash_tween: Tween = null
var _slide_tweens: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func setup(layer: CanvasLayer, reduced_motion: Callable) -> void:
	_layer = layer
	_reduced_motion = reduced_motion
	_rng.randomize()
	_flash = ColorRect.new()
	_flash.name = "ImpactFlash"
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 1, 1, 0)
	_flash.z_index = 400
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_flash)

func _is_reduced() -> bool:
	return _reduced_motion.is_valid() and bool(_reduced_motion.call())

func shake(strength: float, duration: float) -> void:
	if _layer == null or _is_reduced() or strength <= 0.0:
		return
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	var steps: int = maxi(int(duration / SHAKE_STEP_SECONDS), 1)
	for step: int in range(steps):
		var falloff: float = 1.0 - float(step) / float(steps)
		var offset := Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * strength * falloff
		_shake_tween.tween_property(_layer, "offset", offset, SHAKE_STEP_SECONDS)
	_shake_tween.tween_property(_layer, "offset", Vector2.ZERO, SHAKE_STEP_SECONDS)

func flash(color: Color, peak_alpha: float, duration: float) -> void:
	if _flash == null:
		return
	var alpha: float = peak_alpha * (0.4 if _is_reduced() else 1.0)
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash.color = Color(color.r, color.g, color.b, alpha)
	_flash_tween = create_tween()
	_flash_tween.set_ease(Tween.EASE_OUT)
	_flash_tween.set_trans(Tween.TRANS_QUAD)
	_flash_tween.tween_property(_flash, "color:a", 0.0, duration)

func burst(at: Vector2, color: Color, amount: int, speed: float, upward: bool = true) -> void:
	if _layer == null or amount <= 0:
		return
	var particles := CPUParticles2D.new()
	particles.name = "ImpactBurst"
	particles.z_index = 390
	particles.position = at
	particles.one_shot = true
	particles.explosiveness = 0.92
	particles.amount = amount if not _is_reduced() else maxi(amount / 4, 1)
	particles.lifetime = BURST_LIFETIME_SECONDS
	particles.direction = Vector2(0, -1) if upward else Vector2(0, 1)
	particles.spread = 75.0 if upward else 180.0
	particles.initial_velocity_min = speed * 0.5
	particles.initial_velocity_max = speed
	particles.gravity = Vector2(0, 900)
	particles.scale_amount_min = 2.5
	particles.scale_amount_max = 6.0
	particles.color = color
	var fade := Gradient.new()
	fade.set_color(0, color)
	fade.set_color(1, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = fade
	_layer.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(BURST_LIFETIME_SECONDS + 0.3).timeout.connect(particles.queue_free)

# Moves a gauge to its new value; reduced motion sets it at once.
func slide(target: Object, property: String, value: float, duration: float) -> void:
	if target == null:
		return
	var key: String = "%d:%s" % [target.get_instance_id(), property]
	var running: Tween = _slide_tweens.get(key, null) as Tween
	if running != null and running.is_valid():
		running.kill()
	if _is_reduced() or not is_inside_tree():
		target.set(property, value)
		return
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(target, property, value, duration)
	_slide_tweens[key] = tween
