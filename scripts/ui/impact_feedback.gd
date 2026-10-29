extends Node
## Passive material feedback. Neither a CanvasLayer nor a hit target moves.
const DUST = preload("res://assets/ui/generated/ritual_dust.png")
const BURST_LIFETIME_SECONDS: float = 0.38
var _layer: CanvasLayer
var _reduced_motion: Callable
var _flash: ColorRect
var _flash_tween: Tween
var _slide_tweens: Dictionary = {}
var _particles: Array[WeakRef] = []

func setup(layer: CanvasLayer, reduced_motion: Callable) -> void:
	_layer = layer
	_reduced_motion = reduced_motion
	_flash = ColorRect.new()
	_flash.name = "ImpactFlash"
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 1, 1, 0)
	_flash.z_index = 400
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_flash)
	GameEvents.settings_changed.connect(_on_settings_changed)
	GameEvents.run_phase_changed.connect(func(_phase: int) -> void: clear())
	GameEvents.run_ended.connect(func(_reason: String, _summary: Dictionary) -> void: clear())

func _is_reduced() -> bool:
	return _reduced_motion.is_valid() and bool(_reduced_motion.call())

func _process(_delta: float) -> void:
	# Also settle a preference restored directly by a profile/fixture.
	if _is_reduced() and (not _particles.is_empty() or not _slide_tweens.is_empty()):
		clear()

func shake(strength: float, duration: float) -> void:
	# Preserve the API; weight is a restrained light impulse, never displacement.
	if _layer == null or _is_reduced() or strength <= 0.0:
		return
	flash(Color(0.90, 0.79, 0.60), minf(strength * 0.002, 0.035), minf(duration, 0.16))

func flash(color: Color, peak_alpha: float, duration: float) -> void:
	if _flash == null:
		return
	if is_instance_valid(_flash_tween):
		_flash_tween.kill()
	var reduced := _is_reduced()
	_flash.color = Color(color.r, color.g, color.b, minf(peak_alpha, 0.025 if reduced else 0.09))
	_flash_tween = create_tween()
	_flash_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_flash_tween.tween_property(_flash, "color:a", 0.0, minf(duration, 0.08 if reduced else 0.22))

func burst(at: Vector2, color: Color, amount: int, speed: float, upward: bool = true) -> void:
	if _layer == null or _is_reduced() or amount <= 0:
		return
	for index in range(_particles.size() - 1, -1, -1):
		if _particles[index].get_ref() == null: _particles.remove_at(index)
	if _particles.size() >= 2:
		var oldest: WeakRef = _particles.pop_front()
		var existing: Node = oldest.get_ref()
		if existing != null: existing.queue_free()
	var particles := CPUParticles2D.new()
	particles.name = "ImpactBurst"
	particles.z_index = 390
	particles.position = at
	particles.texture = DUST
	particles.one_shot = true
	particles.explosiveness = 0.92
	particles.amount = clampi(amount / 3, 3, 14)
	particles.lifetime = BURST_LIFETIME_SECONDS
	particles.direction = Vector2(0, -1) if upward else Vector2(0, 1)
	particles.spread = 55.0 if upward else 100.0
	particles.initial_velocity_min = minf(speed * 0.12, 45.0)
	particles.initial_velocity_max = minf(speed * 0.25, 90.0)
	particles.gravity = Vector2(0, 180)
	particles.scale_amount_min = 0.018
	particles.scale_amount_max = 0.04
	particles.color = Color(color, 0.38)
	var fade := Gradient.new()
	fade.set_color(0, Color(color, 0.38))
	fade.set_color(1, Color(color, 0))
	particles.color_ramp = fade
	_layer.add_child(particles)
	var particle_ref: WeakRef = weakref(particles)
	_particles.append(particle_ref)
	particles.emitting = true
	get_tree().create_timer(BURST_LIFETIME_SECONDS + 0.1).timeout.connect(func() -> void:
		var existing: Node = particle_ref.get_ref()
		if existing != null: existing.queue_free())

func slide(target: Object, property: String, value: float, duration: float) -> void:
	if target == null:
		return
	var key := "%d:%s" % [target.get_instance_id(), property]
	if _slide_tweens.has(key):
		(_slide_tweens[key].tween as Tween).kill()
		_slide_tweens.erase(key)
	if _is_reduced() or not is_inside_tree():
		target.set(property, value)
		return
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(target, property, value, duration)
	_slide_tweens[key] = {"tween": tween, "target": weakref(target), "property": property, "value": value}
	tween.finished.connect(func() -> void:
		if _slide_tweens.has(key) and _slide_tweens[key].tween == tween: _slide_tweens.erase(key))

func clear() -> void:
	if is_instance_valid(_flash_tween): _flash_tween.kill()
	if is_instance_valid(_flash): _flash.color.a = 0.0
	for entry: Dictionary in _slide_tweens.values():
		(entry.tween as Tween).kill()
		var target: Object = (entry.target as WeakRef).get_ref()
		if is_instance_valid(target): target.set(entry.property, entry.value)
	_slide_tweens.clear()
	for particle_ref: WeakRef in _particles:
		var particles: CPUParticles2D = particle_ref.get_ref()
		if particles != null:
			particles.emitting = false
			particles.hide()
			particles.queue_free()
	_particles.clear()

func _on_settings_changed(payload: Dictionary) -> void:
	if bool(payload.get("reduced_motion", false)): clear()

func _exit_tree() -> void:
	clear()
