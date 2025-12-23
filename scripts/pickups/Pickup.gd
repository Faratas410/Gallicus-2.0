extends Area2D

enum PickupType { SPEED, HEAL, COINS }

@export var pickup_type: PickupType = PickupType.SPEED
@export var amount: int = 0
@export var speed_multiplier: float = 1.0
@export var duration: float = 0.0
@export var despawn_time: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if despawn_time > 0.0:
		_despawn_after(despawn_time)

func _despawn_after(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	if is_inside_tree():
		queue_free()

func _on_body_entered(body: Node) -> void:
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
			var rng := RandomNumberGenerator.new()
			rng.randomize()
			var value := rng.randi_range(1, 5)
			var run_manager := get_tree().get_first_node_in_group("run_manager")
			if run_manager != null and run_manager.has_method("add_coins"):
				run_manager.call("add_coins", value)
			elif body.has_method("add_coins"):
				body.call("add_coins", value)
	queue_free()
