extends Node2D

signal player_spawned(player: Node2D)
signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemy_count_changed(count: int)
signal enemy_spawned(enemy: Node2D)
signal enemy_despawned(enemy: Node2D)

@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemies/EnemyBasic.tscn")
@export var arena_radius: float = GameConstants.ARENA_RADIUS
@export var base_enemy_count: int = GameConstants.ARENA_BASE_ENEMY_COUNT
@export var debug_spawn_enemy: bool = false
@export var enemy_aggro_delay: float = 0.85 # secondi prima che i nemici inizino a inseguire (bilanciamento)

const ARENA_BG_VARIANTS: Array[Texture2D] = [
	preload("res://assets/backgrounds/sfondo_arena_principale.png"),
	preload("res://assets/backgrounds/arena/variants/arena_bg_variant_01.png"),
	preload("res://assets/backgrounds/arena/variants/arena_bg_variant_02.png"),
]

var difficulty_tier: int = 0
var difficulty_multiplier: float = 1.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _current_wave: int = 0
var _enemies_remaining: int = 0
var _player: Node2D = null
var _aggro_sequence_id: int = 0
var _visual_only: bool = false
var _background_sprite: Sprite2D = null

func set_difficulty_tier(tier: int, mult: float = 1.0) -> void:
	difficulty_tier = tier
	difficulty_multiplier = mult
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy != null and is_instance_valid(enemy) and enemy.has_method("_apply_tier_scaling_from_run_manager"):
			enemy.call("_apply_tier_scaling_from_run_manager")

func _ready() -> void:
	print("Arena ready")
	_rng.randomize()
	add_to_group("arena")
	_apply_background_variant()
	if _is_visual_only():
		set_visual_only(true)
	var run_started_callable: Callable = Callable(self, "_on_run_started")
	if not GameEvents.run_started.is_connected(run_started_callable):
		GameEvents.run_started.connect(run_started_callable)
	var run_failed_callable: Callable = Callable(self, "_on_run_failed")
	if not GameEvents.run_failed.is_connected(run_failed_callable):
		GameEvents.run_failed.connect(run_failed_callable)
	if GameEvents.has_signal("difficulty_tier_changed"):
		var tier_callable: Callable = Callable(self, "_on_difficulty_tier_changed")
		if not GameEvents.difficulty_tier_changed.is_connected(tier_callable):
			GameEvents.difficulty_tier_changed.connect(tier_callable)
	queue_redraw()
	ensure_player()
	if debug_spawn_enemy and not _is_visual_only():
		_spawn_debug_enemy()

func _apply_background_variant() -> void:
	if _background_sprite == null:
		_background_sprite = get_node_or_null("Background") as Sprite2D
	if _background_sprite == null:
		return
	if ARENA_BG_VARIANTS.is_empty():
		return
	var index: int = _rng.randi_range(0, ARENA_BG_VARIANTS.size() - 1)
	var texture: Texture2D = ARENA_BG_VARIANTS[index]
	if texture == null:
		return
	_background_sprite.texture = texture

func set_visual_only(visual_only: bool) -> void:
	if _visual_only == visual_only:
		return
	_visual_only = visual_only
	set_process(not _visual_only)
	set_physics_process(not _visual_only)
	if _visual_only:
		_aggro_sequence_id += 1
		_clear_enemies()
		_set_enemy_ai_locked(true)
	else:
		_set_enemy_ai_locked(false)

func _is_visual_only() -> bool:
	if _visual_only:
		return true
	var manager: Node = get_tree().get_first_node_in_group("run_manager")
	if manager != null and manager.has_method("is_visual_only"):
		return bool(manager.call("is_visual_only"))
	return false

func _set_enemy_ai_locked(locked: bool) -> void:
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.has_method("set_ai_locked"):
			enemy.call("set_ai_locked", locked)

func _on_difficulty_tier_changed(tier: int, mult: float) -> void:
	set_difficulty_tier(tier, mult)

func _draw() -> void:
	var floor_size: Vector2 = Vector2(1024.0, 768.0)
	var rect: Rect2 = Rect2(-floor_size * 0.5, floor_size)
	draw_rect(rect, Color(0.15, 0.15, 0.2, 1.0))

func start_next_wave() -> void:
	if _is_visual_only():
		return
	if _enemies_remaining > 0:
		return
	_current_wave += 1
	_spawn_enemies(base_enemy_count + (_current_wave - 1) * GameConstants.ARENA_ENEMY_INCREMENT)
	wave_started.emit(_current_wave)
	# Non inseguono subito: dopo un delay settiamo target + (opzionale) scaling
	_schedule_enemy_aggro_after_delay()

func _spawn_player() -> void:
	if _player != null:
		return
	var existing_player: Node = get_tree().get_first_node_in_group("player")
	if existing_player and existing_player is Node2D:
		_player = existing_player
		_player.global_position = global_position
		player_spawned.emit(_player)
		var player_callable: Callable = Callable(self, "_on_player_died")
		if _player.has_signal("died") and not _player.died.is_connected(player_callable):
			_player.died.connect(player_callable)
		return
	_player = player_scene.instantiate() as Node2D
	add_child(_player)
	_player.global_position = global_position
	player_spawned.emit(_player)
	var died_callable: Callable = Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.died.is_connected(died_callable):
		_player.died.connect(died_callable)

func _spawn_enemies(count: int) -> void:
	if _is_visual_only():
		return
	_enemies_remaining = count
	enemy_count_changed.emit(_enemies_remaining)
	if _player == null or not is_instance_valid(_player):
		ensure_player()
	for i in range(count):
		var enemy: Node2D = enemy_scene.instantiate() as Node2D
		add_child(enemy)
		enemy.add_to_group("enemies")
		if OS.is_debug_build() and i == 0:
			var enemy_script: Script = enemy.get_script()
			var enemy_script_path: String = ""
			if enemy_script != null:
				enemy_script_path = enemy_script.resource_path
			print("Spawned enemy script:", enemy_script_path)
		var angle: float = _rng.randf_range(0.0, TAU)
		var radius: float = _rng.randf_range(arena_radius * 0.5, arena_radius)
		enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * radius

		# Apply difficulty immediately for newly spawned enemies (senza target)
		_apply_difficulty_to_enemy(enemy)

		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died.bind(enemy))
		enemy_spawned.emit(enemy)

func _apply_difficulty_to_enemy(enemy: Node) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	# Prefer explicit API if present
	if enemy.has_method("apply_difficulty"):
		enemy.call("apply_difficulty", difficulty_multiplier)
		return
	# Fallback to existing method name used in your codebase
	if enemy.has_method("_apply_tier_scaling_from_run_manager"):
		enemy.call("_apply_tier_scaling_from_run_manager")

func _spawn_debug_enemy() -> void:
	if _is_visual_only():
		return
	if enemy_scene == null:
		return
	await get_tree().create_timer(0.2).timeout
	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	add_child(enemy)
	enemy.add_to_group("enemies")
	enemy.global_position = Vector2(120.0, 0.0)
	print("Spawned enemy")
	_apply_difficulty_to_enemy(enemy)
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy_spawned.emit(enemy)
	# stesso comportamento: non aggro immediato
	_schedule_enemy_aggro_after_delay()

func _on_enemy_died(enemy: Node2D) -> void:
	_enemies_remaining = maxi(_enemies_remaining - 1, 0)
	enemy_count_changed.emit(_enemies_remaining)
	enemy_despawned.emit(enemy)
	if _enemies_remaining == 0:
		wave_cleared.emit(_current_wave)

func _on_player_died() -> void:
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)
	# cancella eventuale aggro pending
	_aggro_sequence_id += 1

func soft_reset() -> void:
	_clear_enemies()
	_current_wave = 0
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)
	ensure_player()
	_aggro_sequence_id += 1

func reset_arena() -> void:
	# elimina nemici
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()
	# se hai proiettili/effects, puliscili qui

func restart_arena() -> void:
	set_process(false)
	set_physics_process(false)
	_current_wave = 0
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			e.queue_free()
	set_process(true)
	set_physics_process(true)
	if has_method("start_wave"):
		call("start_wave", 0)
	elif has_method("start_combat"):
		call("start_combat")
	elif has_method("begin"):
		call("begin")
	else:
		start_next_wave()

func _on_run_started() -> void:
	if _is_visual_only():
		set_visual_only(true)
		return
	set_process(true)
	set_physics_process(true)

func _on_run_failed() -> void:
	set_process(false)
	set_physics_process(false)
	_aggro_sequence_id += 1

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node and is_ancestor_of(enemy):
			if enemy is Node2D:
				enemy_despawned.emit(enemy)
			enemy.queue_free()
	_enemies_remaining = 0
	enemy_count_changed.emit(_enemies_remaining)

func _reset_player() -> void:
	if _player and is_instance_valid(_player):
		_player.queue_free()
	_player = null
	_spawn_player()

func ensure_player() -> Node2D:
	if _player != null:
		if not is_instance_valid(_player) or _player.is_queued_for_deletion() or not _player.is_inside_tree():
			_player = null
	var group_player: Node = get_tree().get_first_node_in_group("player")
	if _player == null and group_player and group_player is Node2D:
		if group_player.is_inside_tree() and not group_player.is_queued_for_deletion():
			_player = group_player
	if _player == null:
		if player_scene == null:
			return null
		_player = player_scene.instantiate() as Node2D
		add_child(_player)
	elif _player.get_parent() != self:
		var pos: Vector2 = _player.global_position
		_player.reparent(self)
		_player.global_position = pos
	_player.global_position = global_position
	player_spawned.emit(_player)
	var died_callable: Callable = Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.died.is_connected(died_callable):
		_player.died.connect(died_callable)
	return _player

func _schedule_enemy_aggro_after_delay() -> void:
	if _is_visual_only():
		return
	_aggro_sequence_id += 1
	var my_id: int = _aggro_sequence_id
	var delay: float = maxf(enemy_aggro_delay, 0.0)
	if delay <= 0.0:
		_apply_enemy_targets_if_possible(my_id)
		return
	call_deferred("_apply_enemy_targets_deferred", my_id, delay)

func _apply_enemy_targets_deferred(my_id: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_apply_enemy_targets_if_possible(my_id)

func _apply_enemy_targets_if_possible(my_id: int) -> void:
	# Se nel frattempo è cambiata wave/reset/gameover -> abort
	if my_id != _aggro_sequence_id:
		return
	if _is_visual_only():
		return
	if _player == null or not is_instance_valid(_player) or not _player.is_inside_tree():
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null or not is_instance_valid(_player):
		return
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.has_method("set_target"):
			enemy.call("set_target", _player)

func get_current_wave() -> int:
	return _current_wave

func get_enemies_remaining() -> int:
	return _enemies_remaining

func get_player() -> Node2D:
	return _player
