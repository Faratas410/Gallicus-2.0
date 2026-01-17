extends Area2D

enum PickupType { SPEED, HEAL, COINS }

@export var pickup_type: PickupType = PickupType.SPEED
@export var amount: int = 0
@export var speed_multiplier: float = 1.0
@export var duration: float = 0.0
@export var despawn_time: float = 0.0

func _ready() -> void:
	var body_callable: Callable = Callable(self, "_on_body_entered")
	if not body_entered.is_connected(body_callable):
		body_entered.connect(body_callable)
	if despawn_time > 0.0:
		_despawn_after(despawn_time)

func _despawn_after(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	if is_inside_tree():
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _is_level3_mode():
		return
	if not body.is_in_group("player"):
		return
	match pickup_type:
		PickupType.SPEED:
			if body.has_method("apply_speed_boost"):
				body.call("apply_speed_boost", speed_multiplier, duration)
		PickupType.HEAL:
			if body.has_method("heal"):
				body.call("heal", amount)
		PickupType.COINS:
			var rng: RandomNumberGenerator = RandomNumberGenerator.new()
			rng.randomize()
			var value: int = rng.randi_range(1, 5)
			if GameEvents.has_signal("request_add_coins"):
				GameEvents.request_add_coins.emit(value)
	queue_free()

func _is_level3_mode() -> bool:
	var manager: Node = get_tree().get_first_node_in_group("run_manager")
	if manager != null and manager.has_method("is_level3_mode"):
		return bool(manager.call("is_level3_mode"))
	return false
