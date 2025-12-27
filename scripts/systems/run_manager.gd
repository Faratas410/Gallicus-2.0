extends Node

@export var arena_path: NodePath
@export var player_path: NodePath
@export var starting_coins: int = GameConstants.RUN_STARTING_COINS
@export var arena_clear_reward: int = GameConstants.ARENA_CLEAR_REWARD
@export var arena_scene: PackedScene = preload("res://scenes/Arena.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")

# --- XP / Leveling ---
@export var starting_level: int = 1
@export var starting_tokens: int = 0
@export var exp_per_enemy: int = 1
@export var exp_curve: Array[int] = [6, 8, 11, 15, 20, 26] # xp necessario per passare al prossimo livello; dopo l'ultimo cresce linearmente.
@export var exp_curve_tail_step: int = 8
@export var tokens_per_level: int = 1

# --- Difficulty tiers ---
@export var levels_per_tier: int = 3
@export var tier_multipliers: Array[float] = [1.00, 1.13, 1.32, 1.56, 1.84]

@export var upgrade_hp_bonus: int = 20
@export var upgrade_light_bonus: int = 1
@export var upgrade_heavy_bonus: int = 1

# Upgrade shop ora usa TOKENS, con costo che cresce dopo ogni acquisto.
@export var upgrade_hp_token_cost_start: int = 1
@export var upgrade_light_token_cost_start: int = 1
@export var upgrade_heavy_token_cost_start: int = 1
@export var token_purchase_cost_coins: int = 100

enum RunPhase { PREP, LIVE, GAME_OVER }

var run := {
	"arena_index": 0,
	"coins": 0,
	"level": 1,
	"xp": 0,
	"upgrade_tokens": 0,
	"difficulty_tier": 0,
	"upgrade_costs": {
		"hp": 1,
		"light": 1,
		"heavy": 1,
	},
	"upgrades": {
		"hp_bonus": 0,
		"light_bonus": 0,
		"heavy_bonus": 0,
	},
}

var _arena: Node
var _bet_manager: Node
var _waiting_for_bet: bool = false
var _player: Node
var _run_failed_emitted: bool = false
var _is_game_over: bool = false
var phase: RunPhase = RunPhase.PREP
var _prep_sequence_id: int = 0
var _has_started_run: bool = false
var _show_shop_next_bet: bool = false

func _ready() -> void:
	print("RunManager ready")
	add_to_group("run_manager")
	GameEvents.bet_placed.connect(_on_bet_placed)
	GameEvents.betting_opened.connect(_on_betting_opened)
	GameEvents.run_failed.connect(_on_run_failed)
	GameEvents.enemy_killed.connect(_on_enemy_killed)
	_ensure_input_map()
	call_deferred("_boot")

func _boot() -> void:
	await get_tree().process_frame
	_ensure_arena_and_player()
	_arena = get_node_or_null(arena_path)
	_player = get_tree().get_first_node_in_group("player")
	_connect_player_signals()
	_bet_manager = get_node_or_null("BetManager")
	if _arena:
		_arena.connect("wave_started", Callable(self, "_on_wave_started"))
		_arena.connect("wave_cleared", Callable(self, "_on_wave_cleared"))
		_arena.connect("player_spawned", Callable(self, "_on_player_spawned"))
	print("Boot: arena=", _arena, " player=", _player)
	print("Player in tree:", _player != null and _player.is_inside_tree())
	print("Starting new run")
	start_new_run()
	_log_runtime_state("boot_complete")

func start_new_run() -> void:
	_prep_sequence_id += 1
	var current_id := _prep_sequence_id
	_run_failed_emitted = false
	_is_game_over = false
	_waiting_for_bet = false
	_show_shop_next_bet = false
	set_phase(RunPhase.PREP)

	_ensure_arena_and_player()
	if _arena != null and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_reset_or_respawn_player_full()
	_clear_enemies()
	if _bet_manager != null and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.call("reset_bet_state")

	run["coins"] = starting_coins
	_reset_upgrades()
	_reset_upgrade_costs()
	_has_started_run = true
	run["arena_index"] = 0

	_reset_progression()

	GameEvents.run_started.emit()
	GameEvents.set_gameplay_enabled(true)
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))
	_emit_xp_level_ui()
	GameEvents.countdown_requested.emit(3)
	_log_runtime_state("new_run_ready")
	for _i in range(3, 0, -1):
		await get_tree().create_timer(1.0).timeout
		if current_id != _prep_sequence_id or phase == RunPhase.GAME_OVER:
			return
	if current_id != _prep_sequence_id or phase == RunPhase.GAME_OVER:
		return
	var live_player := _resolve_player()
	if live_player == null or not live_player.is_inside_tree():
		_ensure_arena_and_player()
		_reset_or_respawn_player_full()
		live_player = _resolve_player()
		if live_player == null or not live_player.is_inside_tree():
			return
	set_phase(RunPhase.LIVE)
	_spawn_wave_or_enemies()
	_log_runtime_state("after_countdown")

func start_next_bet_round() -> void:
	if _is_game_over:
		return
	if _force_game_over_if_dead():
		return
	_waiting_for_bet = false
	_show_shop_next_bet = false
	set_phase(RunPhase.LIVE)
	_clear_enemies()
	_spawn_wave_or_enemies()

func reset_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	run["coins"] = starting_coins
	start_new_run()

func restart_run(preserve_coins: bool = true) -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if preserve_coins:
		start_new_run()
	else:
		run["coins"] = starting_coins
		start_new_run()

func _open_bet_ui(from_victory: bool = false) -> void:
	if _force_game_over_if_dead():
		return
	if _is_game_over:
		return
	_waiting_for_bet = true
	_show_shop_next_bet = from_victory
	set_phase(RunPhase.PREP)
	GameEvents.betting_opened.emit()
	if _bet_manager and _bet_manager.has_method("open_bet_ui_before_arena"):
		_bet_manager.open_bet_ui_before_arena()

func _ensure_arena_and_player() -> void:
	var main := get_parent()
	if main == null:
		return
	var arena_node: Node = null
	if arena_path != NodePath():
		arena_node = get_node_or_null(arena_path)
	if arena_node == null and arena_scene:
		arena_node = arena_scene.instantiate()
		arena_node.name = "Arena"
		main.add_child(arena_node)
		if arena_node is Node2D:
			arena_node.global_position = Vector2.ZERO
		arena_path = NodePath("../Arena")
	_arena = arena_node

	var existing_player: Node = null
	if player_path != NodePath():
		existing_player = get_node_or_null(player_path)
	if existing_player == null:
		existing_player = get_tree().get_first_node_in_group("player")
	if existing_player == null and player_scene:
		existing_player = player_scene.instantiate()
		existing_player.name = "Player"
		if _arena:
			_arena.add_child(existing_player)
		else:
			main.add_child(existing_player)
		if existing_player is Node2D:
			existing_player.global_position = Vector2.ZERO
		if _arena:
			player_path = NodePath("../Arena/Player")
		else:
			player_path = NodePath("../Player")
	elif existing_player != null:
		var player_parent := existing_player.get_parent()
		if player_parent == _arena:
			player_path = NodePath("../Arena/Player")
		elif player_parent == main:
			player_path = NodePath("../Player")
	_player = existing_player
	if _player and _player is Node2D:
		(_player as Node2D).global_position = Vector2.ZERO

func _reset_or_respawn_player_full() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	_player = _resolve_player()
	if _player == null or not _player.is_inside_tree():
		var main := get_parent()
		if main != null and player_scene:
			_player = player_scene.instantiate()
			_player.name = "Player"
			if _arena:
				_arena.add_child(_player)
			else:
				main.add_child(_player)
			if _player is Node2D:
				(_player as Node2D).global_position = Vector2.ZERO
			if _arena:
				player_path = NodePath("../Arena/Player")
			else:
				player_path = NodePath("../Player")
	elif _arena and _player.get_parent() != _arena:
		var player_node := _player
		if player_node is Node:
			var pos := Vector2.ZERO
			if player_node is Node2D:
				pos = (player_node as Node2D).global_position
			player_node.reparent(_arena)
			if player_node is Node2D:
				(player_node as Node2D).global_position = pos
			player_path = NodePath("../Arena/Player")
	if _player != null and _player.has_method("reset_full_health"):
		_player.call("reset_full_health")
	_apply_run_upgrades_to_player()
	_connect_player_signals()
	_position_player_after_respawn()

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node and is_instance_valid(enemy):
			enemy.queue_free()

func _spawn_wave_or_enemies() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena == null:
		_arena = get_tree().get_first_node_in_group("arena")
	_start_next_arena()

func _ensure_input_map() -> void:
	var actions := {
		# Movimento
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],

		# Combattimento
		"attack_light": [KEY_J],
		"attack_heavy": [KEY_K],
		"block": [KEY_L],
		"dodge": [KEY_SPACE],

		# Sistema
		"pause": [KEY_ESCAPE],
	}

	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing: Dictionary = {}
		for ev in InputMap.action_get_events(action_name):
			if ev is InputEventKey:
				existing[ev.keycode] = true

		for keycode in actions[action_name]:
			if not existing.has(keycode):
				var iev := InputEventKey.new()
				iev.keycode = keycode
				InputMap.action_add_event(action_name, iev)

	print("InputMap ensured: movement + combat bindings ready")

func _start_next_arena() -> void:
	if _arena == null or _is_game_over:
		return
	run.arena_index += 1
	_arena.call("start_next_wave")

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	run.coins += amount
	GameEvents.coins_changed.emit(run.coins)

func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	if run.coins < amount:
		return false
	run.coins -= amount
	GameEvents.coins_changed.emit(run.coins)
	return true

func get_coins() -> int:
	return int(run.get("coins", 0))

func get_tokens() -> int:
	return int(run.get("upgrade_tokens", 0))

func get_buy_token_cost() -> int:
	return token_purchase_cost_coins

func get_token_buy_cost() -> int:
	return token_purchase_cost_coins

func buy_token() -> bool:
	return purchase_token()

func spend_tokens(amount: int) -> bool:
	if amount <= 0:
		return true
	if int(run.get("upgrade_tokens", 0)) < amount:
		return false
	run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) - amount
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func purchase_token() -> bool:
	# Compra 1 token pagando coins.
	if token_purchase_cost_coins <= 0:
		return false
	if not spend_coins(token_purchase_cost_coins):
		return false
	run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) + 1
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func _on_bet_placed(_bet_id: String, _stake: int, _odds: float) -> void:
	if not _waiting_for_bet:
		return
	if _is_game_over:
		return
	_waiting_for_bet = false
	GameEvents.betting_closed.emit()
	set_phase(RunPhase.LIVE)
	_start_next_arena()

func _on_betting_opened() -> void:
	_force_game_over_if_dead()

func _on_wave_started(_wave: int) -> void:
	GameEvents.arena_started.emit(run.arena_index)
	if _bet_manager and _bet_manager.has_method("register_arena_start"):
		_bet_manager.register_arena_start()
	# la difficoltà dei nemici può dipendere dal livello
	_apply_enemy_difficulty_to_arena()
	_apply_phase()

func _on_wave_cleared(_wave: int) -> void:
	GameEvents.arena_completed.emit(run.arena_index)
	if _bet_manager and _bet_manager.has_method("resolve_bet"):
		_bet_manager.resolve_bet()
	if arena_clear_reward > 0:
		add_coins(arena_clear_reward)
	_open_bet_ui(true)

func _on_player_spawned(player: Node) -> void:
	_player = player
	_apply_run_upgrades_to_player()
	_connect_player_signals()
	_position_player_after_respawn()
	_apply_phase()

func _on_enemy_killed(exp: int) -> void:
	if _is_game_over:
		return
	if phase != RunPhase.LIVE:
		return
	var gained := exp_per_enemy
	if exp > 0:
		gained = exp
	if gained <= 0:
		return
	run["xp"] = int(run.get("xp", 0)) + gained
	var leveled := _check_level_up()
	if leveled:
		_recompute_difficulty_tier(false)
	_emit_xp_level_ui()

func _xp_needed_for_next(level: int) -> int:
	# level parte da 1. Per passare a level+1 usiamo exp_curve[level-1] se esiste.
	var idx := max(level - 1, 0)
	if idx < exp_curve.size():
		return int(exp_curve[idx])
	# tail lineare
	var last := 5
	if exp_curve.size() > 0:
		last = int(exp_curve[exp_curve.size() - 1])
	var extra := (idx - max(exp_curve.size() - 1, 0)) * max(exp_curve_tail_step, 1)
	return last + extra

func _check_level_up() -> bool:
	var lvl := int(run.get("level", 1))
	var xp := int(run.get("xp", 0))
	var needed := _xp_needed_for_next(lvl)
	var leveled := false
	while xp >= needed and needed > 0:
		xp -= needed
		lvl += 1
		run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) + max(tokens_per_level, 0)
		needed = _xp_needed_for_next(lvl)
		leveled = true
	run["level"] = lvl
	run["xp"] = xp
	return leveled

func _emit_xp_level_ui() -> void:
	var lvl := int(run.get("level", 1))
	var xp := int(run.get("xp", 0))
	var needed := _xp_needed_for_next(lvl)
	GameEvents.player_level_changed.emit(lvl)
	GameEvents.player_xp_changed.emit(xp, needed)
	GameEvents.level_changed.emit(lvl)
	GameEvents.xp_changed.emit(xp, needed)
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))

func get_level() -> int:
	return int(run.get("level", 1))

func get_difficulty_tier() -> int:
	return int(run.get("difficulty_tier", 0))

func get_difficulty_multiplier() -> float:
	var tier := get_difficulty_tier()
	if tier_multipliers.size() == 0:
		return 1.0
	if tier < tier_multipliers.size():
		return float(tier_multipliers[tier])
	return float(tier_multipliers[tier_multipliers.size() - 1])

func get_upgrade_tokens() -> int:
	return int(run.get("upgrade_tokens", 0))

func consume_upgrade_token() -> bool:
	var t := int(run.get("upgrade_tokens", 0))
	if t <= 0:
		return false
	run["upgrade_tokens"] = t - 1
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func _recompute_difficulty_tier(force_emit: bool) -> void:
	var lvl := int(run.get("level", 1))
	var new_tier := 0
	if levels_per_tier > 0:
		new_tier = int(floor(float(max(lvl - 1, 0)) / float(levels_per_tier)))
	var old_tier := int(run.get("difficulty_tier", 0))
	run["difficulty_tier"] = new_tier
	var mult := get_difficulty_multiplier()
	if force_emit or new_tier != old_tier:
		GameEvents.difficulty_tier_changed.emit(new_tier, mult)
		if _arena != null and _arena.has_method("set_difficulty_tier"):
			_arena.call("set_difficulty_tier", new_tier, mult)

func _apply_enemy_difficulty_to_arena() -> void:
	# Hook opzionale: se Arena ha un metodo, passiamo livello per scalare stats nemici
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena != null and _arena.has_method("set_difficulty_tier"):
		_arena.call("set_difficulty_tier", get_difficulty_tier(), get_difficulty_multiplier())
	elif _arena != null and _arena.has_method("set_difficulty_level"):
		_arena.call("set_difficulty_level", int(run.get("level", 1)))

func _resolve_player() -> Node:
	if _player and is_instance_valid(_player) and _player.is_inside_tree():
		return _player
	if player_path != NodePath():
		var path_player := get_node_or_null(player_path)
		if path_player:
			_player = path_player
			return _player
	_player = get_tree().get_first_node_in_group("player")
	if _player != null:
		return _player
	if player_scene:
		var main := get_parent()
		_player = player_scene.instantiate()
		_player.name = "Player"
		if _arena:
			_arena.add_child(_player)
			player_path = NodePath("../Arena/Player")
		elif main:
			main.add_child(_player)
			player_path = NodePath("../Player")
		if _player is Node2D:
			(_player as Node2D).global_position = Vector2.ZERO
	return _player

func _connect_player_signals() -> void:
	_player = _resolve_player()
	if _player == null:
		return
	var died_callable := Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.is_connected("died", died_callable):
		_player.connect("died", died_callable)

func _on_run_failed() -> void:
	if _run_failed_emitted:
		return
	_run_failed_emitted = true
	GameEvents.set_gameplay_enabled(false)
	_enter_game_over()

func _on_player_died() -> void:
	_emit_run_failed()
	_enter_game_over()

func _soft_reset() -> void:
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	if _bet_manager and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.reset_bet_state()
	run.arena_index = 0
	_player = _resolve_player()
	_open_bet_ui(false)

func handle_bet_failed() -> void:
	if _is_game_over:
		return
	if _force_game_over_if_dead():
		return
	_show_shop_next_bet = false
	_waiting_for_bet = false
	set_phase(RunPhase.PREP)
	GameEvents.set_gameplay_enabled(false)
	if run.get("coins", 0) <= 0:
		_enter_game_over()
		return
	GameEvents.bet_failed.emit(true)

func retry_current_bet() -> void:
	if _is_game_over:
		return
	_show_shop_next_bet = false
	_waiting_for_bet = false
	set_phase(RunPhase.PREP)
	GameEvents.set_gameplay_enabled(false)
	run.arena_index = max(int(run.get("arena_index", 0)) - 1, 0)
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_clear_enemies()
	if _bet_manager and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.reset_bet_state()
	_reset_or_respawn_player_full()
	_open_bet_ui(false)

func _force_game_over_if_dead() -> bool:
	var p := get_tree().get_first_node_in_group("player")
	if p == null:
		return false
	var current_health := _get_player_health_value(p)
	if current_health <= 0 and current_health != -1:
		_enter_game_over()
		return true
	return false

func _get_player_health_value(p: Node) -> int:
	if p.has_method("get_current_health"):
		return int(p.call("get_current_health"))
	if p.has_meta("current_health"):
		return int(p.get_meta("current_health"))
	if p.has_method("get_health"):
		var h: Array = p.call("get_health")
		if h.size() > 0:
			return int(h[0])
	return -1

func _enter_game_over() -> void:
	if _is_game_over:
		return
	_is_game_over = true
	_waiting_for_bet = false
	set_phase(RunPhase.GAME_OVER)
	_emit_run_failed()

func _emit_run_failed() -> void:
	if _run_failed_emitted:
		return
	_run_failed_emitted = true
	GameEvents.run_failed.emit()
	GameEvents.set_gameplay_enabled(false)

func get_arena() -> Node:
	return _arena

func get_arena_index() -> int:
	return int(run.get("arena_index", 0))

func get_upgrade_state() -> Dictionary:
	return run.get("upgrades", {})

func get_upgrade_config() -> Dictionary:
	var costs: Dictionary = run.get("upgrade_costs", {})
	return {
		"hp_bonus": upgrade_hp_bonus,
		"hp_cost": int(costs.get("hp", upgrade_hp_token_cost_start)),
		"light_bonus": upgrade_light_bonus,
		"light_cost": int(costs.get("light", upgrade_light_token_cost_start)),
		"heavy_bonus": upgrade_heavy_bonus,
		"heavy_cost": int(costs.get("heavy", upgrade_heavy_token_cost_start)),
	}

func get_upgrade_offer() -> Dictionary:
	# Ritorna dati "UI-ready" per mostrare preview e disabilitare BUY.
	var upgrades: Dictionary = run.get("upgrades", {})
	var tokens: int = int(run.get("upgrade_tokens", 0))
	var costs: Dictionary = run.get("upgrade_costs", {})
	var hp_cost := int(costs.get("hp", upgrade_hp_token_cost_start))
	var light_cost := int(costs.get("light", upgrade_light_token_cost_start))
	var heavy_cost := int(costs.get("heavy", upgrade_heavy_token_cost_start))

	return {
		"tokens": tokens,
		"hp": {
			"current_total": int(upgrades.get("hp_bonus", 0)),
			"add": int(upgrade_hp_bonus),
			"next_total": int(upgrades.get("hp_bonus", 0)) + int(upgrade_hp_bonus),
			"cost": hp_cost,
			"affordable": tokens >= hp_cost,
		},
		"light": {
			"current_total": int(upgrades.get("light_bonus", 0)),
			"add": int(upgrade_light_bonus),
			"next_total": int(upgrades.get("light_bonus", 0)) + int(upgrade_light_bonus),
			"cost": light_cost,
			"affordable": tokens >= light_cost,
		},
		"heavy": {
			"current_total": int(upgrades.get("heavy_bonus", 0)),
			"add": int(upgrade_heavy_bonus),
			"next_total": int(upgrades.get("heavy_bonus", 0)) + int(upgrade_heavy_bonus),
			"cost": heavy_cost,
			"affordable": tokens >= heavy_cost,
		},
	}

func purchase_upgrade(upgrade_type: String) -> bool:
	var upgrades: Dictionary = run.get("upgrades", {})
	var costs: Dictionary = run.get("upgrade_costs", {})
	match upgrade_type:
		"hp":
			var cost := int(costs.get("hp", upgrade_hp_token_cost_start))
			if not spend_tokens(cost):
				return false
			upgrades["hp_bonus"] = int(upgrades.get("hp_bonus", 0)) + upgrade_hp_bonus
			costs["hp"] = cost + 1
		"light":
			var cost := int(costs.get("light", upgrade_light_token_cost_start))
			if not spend_tokens(cost):
				return false
			upgrades["light_bonus"] = int(upgrades.get("light_bonus", 0)) + upgrade_light_bonus
			costs["light"] = cost + 1
		"heavy":
			var cost := int(costs.get("heavy", upgrade_heavy_token_cost_start))
			if not spend_tokens(cost):
				return false
			upgrades["heavy_bonus"] = int(upgrades.get("heavy_bonus", 0)) + upgrade_heavy_bonus
			costs["heavy"] = cost + 1
		_:
			return false
	run["upgrade_costs"] = costs
	run["upgrades"] = upgrades
	_apply_run_upgrades_to_player()
	return true

func should_show_upgrade_shop() -> bool:
	return _show_shop_next_bet

func consume_upgrade_shop() -> void:
	_show_shop_next_bet = false

func is_live() -> bool:
	return phase == RunPhase.LIVE

func set_phase(p: RunPhase) -> void:
	phase = p
	GameEvents.run_phase_changed.emit(int(phase))
	_apply_phase()

func _apply_phase() -> void:
	if GameEvents.has_method("set_gameplay_enabled"):
		GameEvents.set_gameplay_enabled(phase == RunPhase.LIVE)

func _position_player_after_respawn() -> void:
	if _player == null or not (_player is Node2D):
		return
	var spawn_pos := _get_spawn_position()
	(_player as Node2D).global_position = spawn_pos
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		var player_cam := _player.find_child("Camera2D", true, false)
		if player_cam and player_cam is Camera2D:
			cam = player_cam
			cam.make_current()
	if cam and cam.has_method("make_current"):
		cam.make_current()
	if cam:
		cam.global_position = (_player as Node2D).global_position

func _reset_upgrades() -> void:
	run["upgrades"] = {
		"hp_bonus": 0,
		"light_bonus": 0,
		"heavy_bonus": 0,
	}

func _reset_upgrade_costs() -> void:
	run["upgrade_costs"] = {
		"hp": upgrade_hp_token_cost_start,
		"light": upgrade_light_token_cost_start,
		"heavy": upgrade_heavy_token_cost_start,
	}

func _reset_progression() -> void:
	# reset XP/level per run (puoi cambiare in "persistente" più avanti)
	run["level"] = starting_level
	run["xp"] = 0
	run["upgrade_tokens"] = starting_tokens
	_recompute_difficulty_tier(true)

func _apply_run_upgrades_to_player() -> void:
	if _player == null:
		_player = _resolve_player()
	if _player == null:
		return
	var upgrades: Dictionary = run.get("upgrades", {})
	if _player.has_method("apply_run_upgrades"):
		_player.call(
			"apply_run_upgrades",
			int(upgrades.get("hp_bonus", 0)),
			int(upgrades.get("light_bonus", 0)),
			int(upgrades.get("heavy_bonus", 0))
		)

func _get_spawn_position() -> Vector2:
	if _arena and _arena is Node:
		var spawn_node := _find_spawn_node(_arena)
		if spawn_node and spawn_node is Node2D:
			return (spawn_node as Node2D).global_position
		if _arena is Node2D:
			return (_arena as Node2D).global_position
	return Vector2.ZERO

func _find_spawn_node(root: Node) -> Node:
	var direct := root.get_node_or_null("Spawn")
	if direct:
		return direct
	var named := root.find_child("Spawn", true, false)
	if named:
		return named
	var player_spawn := root.find_child("PlayerSpawn", true, false)
	if player_spawn:
		return player_spawn
	return root.find_child("PlayerSpawnPoint", true, false)

func _log_runtime_state(tag: String) -> void:
	var player_node := _resolve_player()
	var player_exists := player_node != null
	var player_in_tree := player_exists and player_node.is_inside_tree()
	var player_physics := player_exists and player_node.is_physics_processing()
	var player_process_mode := -1
	if player_exists:
		player_process_mode = player_node.process_mode
	var player_pos := Vector2.ZERO
	if player_exists and player_node is Node2D:
		player_pos = (player_node as Node2D).global_position

	var enemies := get_tree().get_nodes_in_group("enemies")
	var enemies_count := enemies.size()
	var sample_enemy: Node = null
	if enemies_count > 0:
		sample_enemy = enemies[0]
	var enemy_physics := sample_enemy != null and sample_enemy.is_physics_processing()
	var enemy_process_mode := -1
	if sample_enemy != null:
		enemy_process_mode = sample_enemy.process_mode

	var cam := get_viewport().get_camera_2d()
	var cam_exists := cam != null
	var cam_current := cam_exists and cam.has_method("is_current") and cam.is_current()
	var cam_pos := Vector2.ZERO
	if cam_exists:
		cam_pos = cam.global_position

	print(
		"[runtime:%s] paused=%s gameplay_enabled=%s player_in_tree=%s player_physics=%s player_process_mode=%s player_pos=%s enemies=%s enemy_physics=%s enemy_process_mode=%s cam_exists=%s cam_current=%s cam_pos=%s"
		% [
			tag,
			get_tree().paused,
			GameEvents.gameplay_enabled,
			player_in_tree,
			player_physics,
			player_process_mode,
			player_pos,
			enemies_count,
			enemy_physics,
			enemy_process_mode,
			cam_exists,
			cam_current,
			cam_pos,
		]
	)
