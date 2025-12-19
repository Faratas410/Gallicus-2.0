extends CharacterBody2D

signal hit_confirmed(target: Node)
signal died

enum PlayerState {
	IDLE,
	MOVE,
	ATTACKING,
	DODGING,
	BLOCKING,
	HITSTUN,
	DEAD,
}

@export var max_health: int = GameConstants.PLAYER_MAX_HEALTH
@export var debug_input: bool = true

var is_blocking: bool = false

var _current_health: int
var _state: PlayerState = PlayerState.IDLE
var _attack_cooldown: float = 0.0
var _attack_in_progress: bool = false
var _attack_damage: int = 0
var _is_invulnerable: bool = false
var _last_move_direction := Vector2.DOWN
var _dodge_direction := Vector2.ZERO
var _hit_targets: Dictionary = {}
var _knockback_velocity := Vector2.ZERO
var _knockback_timer := 0.0
var hitbox_viz: ColorRect

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var sprite: Sprite2D = $Visual

func _ready() -> void:
	_current_health = max_health
	add_to_group("player")
	set_physics_process(true)
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		if not InputMap.has_action(action):
			push_error("Missing input action: %s" % action)
	print("Player ready. Physics:", is_physics_processing())
	_set_hitbox_active(false)
	_set_hurtbox_active(true)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	_ensure_hitbox_viz()
	_ensure_placeholder_sprite()

func _physics_process(delta: float) -> void:
	_update_attack_cooldown(delta)
	if _state == PlayerState.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if debug_input:
		if Input.is_action_just_pressed("attack_light"):
			print("ACTION attack_light")
		if Input.is_action_just_pressed("attack_heavy"):
			print("ACTION attack_heavy")
		if Input.is_action_just_pressed("block"):
			print("ACTION block")
		if Input.is_action_just_pressed("dodge"):
			print("ACTION dodge")
	if input_dir != Vector2.ZERO:
		_last_move_direction = input_dir.normalized()
	if debug_input:
		if Input.is_anything_pressed():
			print("ANYTHING pressed. input_dir=", input_dir, " state=", _state)

	if debug_input and Input.is_key_pressed(KEY_W):
		print("KEY_W pressed (raw)")
	if debug_input and input_dir != Vector2.ZERO:
		print("Player input:", input_dir, " state:", _state)

	if _state == PlayerState.DODGING:
		velocity = _dodge_direction * GameConstants.PLAYER_DODGE_SPEED
		move_and_slide()
		return

	if _state == PlayerState.HITSTUN:
		velocity = _knockback_velocity
		_knockback_timer = max(_knockback_timer - delta, 0.0)
		move_and_slide()
		if _knockback_timer <= 0.0:
			_state = PlayerState.IDLE
			velocity = Vector2.ZERO
		return

	if _state == PlayerState.ATTACKING:
		if not _attack_in_progress and _attack_cooldown <= 0.0:
			_state = PlayerState.IDLE
		move_and_slide()
		if _state != PlayerState.IDLE:
			return

	if _state != PlayerState.BLOCKING:
		if Input.is_action_just_pressed("dodge"):
			_start_dodge()
			move_and_slide()
			return
		if _attack_cooldown <= 0.0:
			if Input.is_action_just_pressed("attack_light"):
				_start_light_attack()
				move_and_slide()
				return
			if Input.is_action_just_pressed("attack_heavy"):
				_start_heavy_attack()
				move_and_slide()
				return

	_update_block_state()
	if _state == PlayerState.BLOCKING:
		if not Input.is_action_pressed("block"):
			_state = PlayerState.IDLE
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _state == PlayerState.IDLE or _state == PlayerState.MOVE:
		velocity = input_dir * GameConstants.PLAYER_MOVE_SPEED
		move_and_slide()
		_state = PlayerState.MOVE if input_dir != Vector2.ZERO else PlayerState.IDLE
		return

	if debug_input and (
		Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
		or Input.is_action_pressed("move_up")
		or Input.is_action_pressed("move_down")
	) and input_dir == Vector2.ZERO:
		print("Pressed move keys but input_dir is ZERO. Check InputMap.")

func take_damage(amount: int, from: Vector2 = Vector2.ZERO) -> void:
	if _state == PlayerState.DEAD:
		return
	if _is_invulnerable or _state == PlayerState.DODGING:
		return
	var final_damage := amount
	var knockback_scale := 1.0
	if is_blocking:
		final_damage = max(1, int(ceil(amount * 0.4)))
		knockback_scale = 0.4
	_current_health = max(_current_health - final_damage, 0)
	if final_damage > 0:
		GameEvents.player_damaged.emit()
	if from != Vector2.ZERO:
		var knockback_direction := (global_position - from).normalized()
		_knockback_velocity = knockback_direction * GameConstants.PLAYER_KNOCKBACK_FORCE * knockback_scale
		_knockback_timer = GameConstants.PLAYER_HITSTUN_DURATION
		_state = PlayerState.HITSTUN
	if _current_health <= 0:
		_state = PlayerState.DEAD
		velocity = Vector2.ZERO
		died.emit()
		GameEvents.run_failed.emit()
		queue_free()

func _start_light_attack() -> void:
	_start_attack(
		1,
		GameConstants.PLAYER_LIGHT_ATTACK_DURATION,
		0.0,
		GameConstants.PLAYER_LIGHT_ATTACK_COOLDOWN
	)

func _start_heavy_attack() -> void:
	_start_attack(
		2,
		GameConstants.PLAYER_HEAVY_ATTACK_DURATION,
		GameConstants.PLAYER_HEAVY_ATTACK_WINDUP,
		GameConstants.PLAYER_HEAVY_ATTACK_COOLDOWN
	)

func _start_attack(damage: int, duration: float, windup: float, cooldown: float) -> void:
	if _attack_in_progress:
		return
	_attack_in_progress = true
	is_blocking = false
	_state = PlayerState.ATTACKING
	_attack_damage = damage
	var direction := _last_move_direction
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	hitbox.position = direction.normalized() * 16.0
	_set_hitbox_active(false)
	var active_time: float = maxf(duration - windup, 0.0)
	if windup > 0.0:
		await get_tree().create_timer(windup).timeout
		if _state != PlayerState.ATTACKING:
			_attack_in_progress = false
			return
	_set_hitbox_active(true)
	if active_time > 0.0:
		await get_tree().create_timer(active_time).timeout
	_set_hitbox_active(false)
	_attack_in_progress = false
	_attack_cooldown = cooldown
	if _state == PlayerState.ATTACKING:
		_state = PlayerState.IDLE

func _start_dodge() -> void:
	_state = PlayerState.DODGING
	is_blocking = false
	_is_invulnerable = true
	_set_hurtbox_active(false)
	_dodge_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _dodge_direction == Vector2.ZERO:
		_dodge_direction = _last_move_direction
	if _dodge_direction == Vector2.ZERO:
		_dodge_direction = Vector2.RIGHT
	_dodge_direction = _dodge_direction.normalized()
	await get_tree().create_timer(GameConstants.PLAYER_DODGE_DURATION).timeout
	_is_invulnerable = false
	_set_hurtbox_active(true)
	if _state == PlayerState.DODGING:
		_state = PlayerState.IDLE

func _update_block_state() -> void:
	if Input.is_action_pressed("block"):
		if _state != PlayerState.BLOCKING:
			_state = PlayerState.BLOCKING
			is_blocking = true
	else:
		if _state == PlayerState.BLOCKING:
			_state = PlayerState.IDLE
		is_blocking = false

func _update_attack_cooldown(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown = max(_attack_cooldown - delta, 0.0)

func _set_hitbox_active(active: bool) -> void:
	hitbox.monitoring = active
	hitbox_shape.disabled = not active
	if hitbox_viz:
		hitbox_viz.visible = active
	if active:
		_hit_targets.clear()

func _set_hurtbox_active(active: bool) -> void:
	hurtbox.monitoring = active
	hurtbox_shape.disabled = not active

func _on_hitbox_area_entered(area: Area2D) -> void:
	var target := area.get_parent()
	if target == null:
		return
	if target.has_method("take_damage"):
		target.take_damage(_attack_damage, global_position)
		hit_confirmed.emit(target)

func _ensure_hitbox_viz() -> void:
	var existing := hitbox.get_node_or_null("HitboxViz")
	if existing:
		hitbox_viz = existing
		return
	var rect := ColorRect.new()
	rect.name = "HitboxViz"
	rect.size = Vector2(26.0, 18.0)
	rect.color = Color(1.0, 0.0, 0.0, 0.35)
	rect.visible = false
	rect.position = Vector2(-13.0, -9.0)
	hitbox.add_child(rect)
	hitbox_viz = rect

func _ensure_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.6, 0.9, 1.0))
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.scale = Vector2(24.0, 24.0)
