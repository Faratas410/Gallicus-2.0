extends Node

@export var arena_path: NodePath
@export var player_path: NodePath
@export var starting_coins: int = GameConstants.RUN_STARTING_COINS
@export var arena_clear_reward: int = GameConstants.ARENA_CLEAR_REWARD
@export var arena_scene: PackedScene = preload("res://scenes/Arena.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")

const DEBUG_RUNTIME_LOGS: bool = false

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

@export var bet_coward_coin_reward: int = 20
@export var bet_pure_hp_bonus: int = 30
@export var bet_pure_light_bonus: int = 2
@export var bet_pure_heavy_bonus: int = 2

const BET_COWARD: String = "COWARD"
const BET_PURE_BLOOD: String = "PURE_BLOOD"
const BET_DOUBLE_OR_DIE: String = "DOUBLE_OR_DIE"

enum RunPhase { PREP, LIVE, GAME_OVER }

var run: Dictionary = {
	"arena_index": 0,
	"coins": 0,
	"level": 1,
	"xp": 0,
	"upgrade_tokens": 0,
	"difficulty_tier": 0,
	"bet_hp_penalty": 0,
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
var _waiting_for_push_luck: bool = false
var _player: Node
var _run_failed_emitted: bool = false
var _is_game_over: bool = false
var phase: RunPhase = RunPhase.PREP
var _prep_sequence_id: int = 0
var _has_started_run: bool = false
var _show_shop_next_bet: bool = false
var _modal_lock_count: int = 0
var _bet_chain_level: int = 1
var _current_bet_id: String = ""

func _ready() -> void:
	print("RunManager ready")
	add_to_group("run_manager")
	var bet_placed_callable: Callable = Callable(self, "_on_bet_placed")
	if not GameEvents.bet_placed.is_connected(bet_placed_callable):
		GameEvents.bet_placed.connect(bet_placed_callable)
	var betting_opened_callable: Callable = Callable(self, "_on_betting_opened")
	if not GameEvents.betting_opened.is_connected(betting_opened_callable):
		GameEvents.betting_opened.connect(betting_opened_callable)
	var run_failed_callable: Callable = Callable(self, "_on_run_failed")
	if not GameEvents.run_failed.is_connected(run_failed_callable):
		GameEvents.run_failed.connect(run_failed_callable)
	var enemy_killed_callable: Callable = Callable(self, "_on_enemy_killed")
	if not GameEvents.enemy_killed.is_connected(enemy_killed_callable):
		GameEvents.enemy_killed.connect(enemy_killed_callable)
	var request_purchase_callable: Callable = Callable(self, "_on_request_purchase_upgrade")
	if GameEvents.has_signal("request_purchase_upgrade") and not GameEvents.request_purchase_upgrade.is_connected(request_purchase_callable):
		GameEvents.request_purchase_upgrade.connect(request_purchase_callable)
	var request_purchase_token_callable: Callable = Callable(self, "_on_request_purchase_token")
	if GameEvents.has_signal("request_purchase_token") and not GameEvents.request_purchase_token.is_connected(request_purchase_token_callable):
		GameEvents.request_purchase_token.connect(request_purchase_token_callable)
	var request_consume_shop_callable: Callable = Callable(self, "_on_request_consume_upgrade_shop")
	if GameEvents.has_signal("request_consume_upgrade_shop") and not GameEvents.request_consume_upgrade_shop.is_connected(request_consume_shop_callable):
		GameEvents.request_consume_upgrade_shop.connect(request_consume_shop_callable)
	var request_reset_callable: Callable = Callable(self, "_on_request_reset_run")
	if GameEvents.has_signal("request_reset_run") and not GameEvents.request_reset_run.is_connected(request_reset_callable):
		GameEvents.request_reset_run.connect(request_reset_callable)
	var request_retry_callable: Callable = Callable(self, "_on_request_retry_run")
	if GameEvents.has_signal("request_retry_run") and not GameEvents.request_retry_run.is_connected(request_retry_callable):
		GameEvents.request_retry_run.connect(request_retry_callable)
	var request_next_bet_callable: Callable = Callable(self, "_on_request_next_bet")
	if GameEvents.has_signal("request_next_bet") and not GameEvents.request_next_bet.is_connected(request_next_bet_callable):
		GameEvents.request_next_bet.connect(request_next_bet_callable)
	var request_add_coins_callable: Callable = Callable(self, "_on_request_add_coins")
	if GameEvents.has_signal("request_add_coins") and not GameEvents.request_add_coins.is_connected(request_add_coins_callable):
		GameEvents.request_add_coins.connect(request_add_coins_callable)
	var request_cashout_callable: Callable = Callable(self, "_on_request_push_luck_cashout")
	if GameEvents.has_signal("request_push_luck_cashout") and not GameEvents.request_push_luck_cashout.is_connected(request_cashout_callable):
		GameEvents.request_push_luck_cashout.connect(request_cashout_callable)
	var request_double_callable: Callable = Callable(self, "_on_request_push_luck_double")
	if GameEvents.has_signal("request_push_luck_double") and not GameEvents.request_push_luck_double.is_connected(request_double_callable):
		GameEvents.request_push_luck_double.connect(request_double_callable)
	var modal_opened_callable: Callable = Callable(self, "_on_modal_opened")
	if GameEvents.has_signal("modal_opened") and not GameEvents.modal_opened.is_connected(modal_opened_callable):
		GameEvents.modal_opened.connect(modal_opened_callable)
	var modal_closed_callable: Callable = Callable(self, "_on_modal_closed")
	if GameEvents.has_signal("modal_closed") and not GameEvents.modal_closed.is_connected(modal_closed_callable):
		GameEvents.modal_closed.connect(modal_closed_callable)
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
		var wave_started_callable: Callable = Callable(self, "_on_wave_started")
		if _arena.has_signal("wave_started") and not _arena.wave_started.is_connected(wave_started_callable):
			_arena.wave_started.connect(wave_started_callable)
		var wave_cleared_callable: Callable = Callable(self, "_on_wave_cleared")
		if _arena.has_signal("wave_cleared") and not _arena.wave_cleared.is_connected(wave_cleared_callable):
			_arena.wave_cleared.connect(wave_cleared_callable)
		var player_spawned_callable: Callable = Callable(self, "_on_player_spawned")
		if _arena.has_signal("player_spawned") and not _arena.player_spawned.is_connected(player_spawned_callable):
			_arena.player_spawned.connect(player_spawned_callable)
	print("Boot: arena=", _arena, " player=", _player)
	print("Player in tree:", _player != null and _player.is_inside_tree())
	print("Starting new run")
	start_new_run()
	_log_runtime_state("boot_complete")

func start_new_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if GameEvents != null and GameEvents.has_method("set_gameplay_enabled"):
		GameEvents.set_gameplay_enabled(true)
	_prep_sequence_id += 1
	var current_id: int = _prep_sequence_id
	_run_failed_emitted = false
	_is_game_over = false
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_show_shop_next_bet = false
	_reset_bet_chain()
	set_phase(RunPhase.PREP)

	_ensure_arena_and_player()
	if _arena != null and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_reset_or_respawn_player_full()
	_clear_enemies()
	if _bet_manager != null and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.call("reset_bet_state")

	run["coins"] = starting_coins
	run["bet_hp_penalty"] = 0
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
	var live_player: Node = _resolve_player()
	if live_player == null or not live_player.is_inside_tree():
		_ensure_arena_and_player()
		_reset_or_respawn_player_full()
		live_player = _resolve_player()
		if live_player == null or not live_player.is_inside_tree():
			return
	set_phase(RunPhase.PREP)
	_open_bet_ui(false)
	_log_runtime_state("waiting_for_bet")

func start_next_bet_round() -> void:
	if _is_game_over:
		return
	if _force_game_over_if_dead():
		return
	if _waiting_for_push_luck:
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
	_waiting_for_push_luck = false
	_show_shop_next_bet = from_victory
	set_phase(RunPhase.PREP)
	GameEvents.betting_opened.emit()
	if _bet_manager and _bet_manager.has_method("open_bet_ui_before_arena"):
		_bet_manager.open_bet_ui_before_arena()

func _ensure_arena_and_player() -> void:
	var main: Node = get_parent()
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
		var player_parent: Node = existing_player.get_parent()
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
		var main: Node = get_parent()
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
		var player_node: Node = _player
		if player_node is Node:
			var pos: Vector2 = Vector2.ZERO
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
	var actions: Dictionary = {
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

	for action_name: String in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing: Dictionary = {}
		for ev: InputEvent in InputMap.action_get_events(action_name):
			if ev is InputEventKey:
				existing[ev.keycode] = true

		var keycodes: Array = actions[action_name] as Array
		for keycode: int in keycodes:
			if not existing.has(keycode):
				var iev: InputEventKey = InputEventKey.new()
				iev.keycode = keycode
				InputMap.action_add_event(action_name, iev)

	print("InputMap ensured: movement + combat bindings ready")

func _start_next_arena() -> void:
	if _arena == null or _is_game_over:
		return
	run["arena_index"] = int(run.get("arena_index", 0)) + 1
	_arena.call("start_next_wave")

func _on_request_purchase_upgrade(upgrade_key: String) -> void:
	purchase_upgrade(upgrade_key)

func _on_request_purchase_token() -> void:
	purchase_token()

func _on_request_consume_upgrade_shop() -> void:
	consume_upgrade_shop()

func _on_request_reset_run() -> void:
	start_new_run()

func _on_request_retry_run() -> void:
	retry_current_bet()

func _on_request_next_bet() -> void:
	start_next_bet_round()

func _on_request_add_coins(amount: int) -> void:
	add_coins(amount)

func _on_request_push_luck_cashout() -> void:
	if not _waiting_for_push_luck:
		return
	var bet_id: String = _current_bet_id
	_waiting_for_push_luck = false
	GameEvents.push_luck_closed.emit()
	if bet_id != "":
		_apply_bet_reward_scaled(bet_id, _bet_chain_level)
	_reset_bet_chain()
	_open_bet_ui(true)

func _on_request_push_luck_double() -> void:
	if not _waiting_for_push_luck:
		return
	var bet_id: String = _current_bet_id
	_waiting_for_push_luck = false
	GameEvents.push_luck_closed.emit()
	if bet_id == "":
		_open_bet_ui(true)
		return
	_bet_chain_level = maxi(_bet_chain_level + 1, 1)
	if _bet_manager and _bet_manager.has_method("set_chain_bet"):
		_bet_manager.call("set_chain_bet", bet_id)
	set_phase(RunPhase.LIVE)
	_clear_enemies()
	_spawn_wave_or_enemies()

func _on_modal_opened(_kind: String) -> void:
	_modal_lock_count += 1
	_apply_modal_lock()

func _on_modal_closed(_kind: String) -> void:
	_modal_lock_count = maxi(_modal_lock_count - 1, 0)
	_apply_modal_lock()

func _apply_modal_lock() -> void:
	var locked: bool = _modal_lock_count > 0
	var player: Node = get_tree().get_first_node_in_group("player") as Node
	if player != null:
		if player.has_method("set_input_locked"):
			player.call("set_input_locked", locked)
		elif "input_locked" in player:
			player.set("input_locked", locked)

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	for enemy: Node in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.has_method("set_ai_locked"):
			enemy.call("set_ai_locked", locked)
		elif "ai_locked" in enemy:
			enemy.set("ai_locked", locked)

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	run["coins"] = int(run.get("coins", 0)) + amount
	GameEvents.coins_changed.emit(int(run.get("coins", 0)))

func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	if int(run.get("coins", 0)) < amount:
		return false
	run["coins"] = int(run.get("coins", 0)) - amount
	GameEvents.coins_changed.emit(int(run.get("coins", 0)))
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
	_waiting_for_push_luck = false
	_current_bet_id = _bet_id
	_bet_chain_level = 1
	GameEvents.betting_closed.emit()
	set_phase(RunPhase.LIVE)
	_start_next_arena()

func _on_betting_opened() -> void:
	_force_game_over_if_dead()

func _on_wave_started(_wave: int) -> void:
	GameEvents.arena_started.emit(int(run.get("arena_index", 0)))
	if _bet_manager and _bet_manager.has_method("register_arena_start"):
		_bet_manager.register_arena_start()
	# la difficoltà dei nemici può dipendere dal livello
	_apply_enemy_difficulty_to_arena()
	_apply_phase()

func _on_wave_cleared(_wave: int) -> void:
	GameEvents.arena_completed.emit(int(run.get("arena_index", 0)))
	var bet_result: Dictionary = {}
	if _bet_manager and _bet_manager.has_method("resolve_bet"):
		bet_result = _bet_manager.resolve_bet() as Dictionary
	if arena_clear_reward > 0:
		add_coins(arena_clear_reward)
	if not bet_result.is_empty():
		var bet_id: String = str(bet_result.get("id", ""))
		var won: bool = bool(bet_result.get("won", false))
		if won and bet_id != "":
			_current_bet_id = bet_id
			_open_push_luck_choice(bet_id)
			return
	_reset_bet_chain()
	_open_bet_ui(true)

func _on_player_spawned(player: Node) -> void:
	_player = player
	_apply_run_upgrades_to_player()
	_connect_player_signals()
	_position_player_after_respawn()
	_apply_phase()

func _on_enemy_killed(exp_value: int) -> void:
	if _is_game_over:
		return
	if phase != RunPhase.LIVE:
		return
	var gained: int = exp_per_enemy
	if exp_value > 0:
		gained = exp_value
	if gained <= 0:
		return
	run["xp"] = int(run.get("xp", 0)) + gained
	var leveled: bool = _check_level_up()
	if leveled:
		_recompute_difficulty_tier(false)
	_emit_xp_level_ui()

func _xp_needed_for_next(level: int) -> int:
	# level parte da 1. Per passare a level+1 usiamo exp_curve[level-1] se esiste.
	var idx: int = maxi(level - 1, 0)
	if idx < exp_curve.size():
		return int(exp_curve[idx])
	# tail lineare
	var last: int = 5
	if exp_curve.size() > 0:
		last = int(exp_curve[exp_curve.size() - 1])
	var extra: int = (idx - maxi(exp_curve.size() - 1, 0)) * maxi(exp_curve_tail_step, 1)
	return last + extra

func _check_level_up() -> bool:
	var lvl: int = int(run.get("level", 1))
	var xp: int = int(run.get("xp", 0))
	var needed: int = _xp_needed_for_next(lvl)
	var leveled: bool = false
	while xp >= needed and needed > 0:
		xp -= needed
		lvl += 1
		run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) + maxi(tokens_per_level, 0)
		needed = _xp_needed_for_next(lvl)
		leveled = true
	run["level"] = lvl
	run["xp"] = xp
	return leveled

func _emit_xp_level_ui() -> void:
	var lvl: int = int(run.get("level", 1))
	var xp: int = int(run.get("xp", 0))
	var needed: int = _xp_needed_for_next(lvl)
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
	var tier: int = get_difficulty_tier()
	if tier_multipliers.size() == 0:
		return 1.0
	if tier < tier_multipliers.size():
		return float(tier_multipliers[tier])
	return float(tier_multipliers[tier_multipliers.size() - 1])

func get_upgrade_tokens() -> int:
	return int(run.get("upgrade_tokens", 0))

func consume_upgrade_token() -> bool:
	var t: int = int(run.get("upgrade_tokens", 0))
	if t <= 0:
		return false
	run["upgrade_tokens"] = t - 1
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func _recompute_difficulty_tier(force_emit: bool) -> void:
	var lvl: int = int(run.get("level", 1))
	var new_tier: int = 0
	if levels_per_tier > 0:
		new_tier = int(floor(float(maxi(lvl - 1, 0)) / float(levels_per_tier)))
	var old_tier: int = int(run.get("difficulty_tier", 0))
	run["difficulty_tier"] = new_tier
	var mult: float = get_difficulty_multiplier()
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
		var path_player: Node = get_node_or_null(player_path)
		if path_player:
			_player = path_player
			return _player
	_player = get_tree().get_first_node_in_group("player")
	if _player != null:
		return _player
	if player_scene:
		var main: Node = get_parent()
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
	if OS.is_debug_build() and _player != null:
		var player_script: Script = _player.get_script()
		var player_script_path: String = ""
		if player_script != null:
			player_script_path = player_script.resource_path
		print("Runtime Player script:", player_script_path)
	if _player == null:
		return
	var died_callable: Callable = Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.died.is_connected(died_callable):
		_player.died.connect(died_callable)

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
	run["arena_index"] = 0
	_player = _resolve_player()
	_reset_bet_chain()
	_open_bet_ui(false)

func handle_bet_failed(bet_id: String) -> void:
	if _is_game_over:
		return
	if bet_id == BET_DOUBLE_OR_DIE:
		_reset_bet_chain()
		_enter_game_over()
		return
	if bet_id == BET_PURE_BLOOD:
		var chain_level: int = _bet_chain_level
		_apply_pure_bet_penalty(chain_level)
	_reset_bet_chain()

func _apply_pure_bet_penalty(chain_level: int) -> void:
	var scale: int = _get_bet_chain_doom_scale(chain_level)
	var penalty: int = 10 * scale
	var current_penalty: int = int(run.get("bet_hp_penalty", 0))
	var max_health: int = _get_player_max_health_value(_resolve_player())
	if max_health > 0:
		penalty = mini(penalty, maxi(max_health - 1, 0))
	run["bet_hp_penalty"] = current_penalty - penalty
	_apply_run_upgrades_to_player()

func _apply_bet_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	var bet_id: String = str(result.get("id", ""))
	var won: bool = bool(result.get("won", false))
	if not won:
		return
	_apply_bet_reward_scaled(bet_id, 1)

func _reset_bet_chain() -> void:
	_bet_chain_level = 1
	_current_bet_id = ""
	_waiting_for_push_luck = false

func _open_push_luck_choice(bet_id: String) -> void:
	_waiting_for_push_luck = true
	_show_shop_next_bet = false
	set_phase(RunPhase.PREP)
	var bet_data: Dictionary = _get_bet_data(bet_id)
	var bet_name: String = bet_id
	var condition_text: String = ""
	if not bet_data.is_empty():
		bet_name = str(bet_data.get("name", bet_id))
		condition_text = str(bet_data.get("condition", ""))
	var next_level: int = _bet_chain_level + 1
	var payload: Dictionary = {
		"bet_id": bet_id,
		"bet_name": bet_name,
		"current_level": _bet_chain_level,
		"next_level": next_level,
		"condition": condition_text,
		"next_pact": _build_bet_pact_text(bet_id, next_level),
		"next_doom": _build_bet_doom_text(bet_id, next_level),
	}
	GameEvents.push_luck_opened.emit(payload)

func _apply_bet_reward_scaled(bet_id: String, chain_level: int) -> void:
	var reward_scale: int = _get_bet_chain_reward_scale(chain_level)
	match bet_id:
		BET_COWARD:
			if bet_coward_coin_reward > 0:
				add_coins(bet_coward_coin_reward * reward_scale)
		BET_PURE_BLOOD:
			_apply_pure_bet_reward_scaled(reward_scale)
		BET_DOUBLE_OR_DIE:
			_apply_double_or_die_reward_scaled(reward_scale)
		_:
			pass

func _apply_pure_bet_reward_scaled(scale: int) -> void:
	var upgrades: Dictionary = run.get("upgrades", {}) as Dictionary
	var reward_scale: int = maxi(scale, 1)
	upgrades["hp_bonus"] = int(upgrades.get("hp_bonus", 0)) + bet_pure_hp_bonus * reward_scale
	upgrades["light_bonus"] = int(upgrades.get("light_bonus", 0)) + bet_pure_light_bonus * reward_scale
	upgrades["heavy_bonus"] = int(upgrades.get("heavy_bonus", 0)) + bet_pure_heavy_bonus * reward_scale
	run["upgrades"] = upgrades
	_apply_run_upgrades_to_player()

func _get_bet_chain_reward_scale(chain_level: int) -> int:
	return maxi(chain_level, 1)

func _get_bet_chain_doom_scale(chain_level: int) -> int:
	return 1 + maxi(chain_level - 1, 0) * 2

func _build_bet_pact_text(bet_id: String, chain_level: int) -> String:
	var reward_scale: int = _get_bet_chain_reward_scale(chain_level)
	match bet_id:
		BET_COWARD:
			return "Ricompensa minore: +%d monete" % (bet_coward_coin_reward * reward_scale)
		BET_PURE_BLOOD:
			return "Upgrade forte: +%d HP max, +%d danni leggeri, +%d danni pesanti" % [
				bet_pure_hp_bonus * reward_scale,
				bet_pure_light_bonus * reward_scale,
				bet_pure_heavy_bonus * reward_scale,
			]
		BET_DOUBLE_OR_DIE:
			return "Raddoppio danni per la run x%d" % reward_scale
		_:
			return bet_id

func _build_bet_doom_text(bet_id: String, chain_level: int) -> String:
	match bet_id:
		BET_COWARD:
			return "Nessuna penalità extra"
		BET_PURE_BLOOD:
			var doom_scale: int = _get_bet_chain_doom_scale(chain_level)
			return "HP massimo -%d permanente per la run" % (10 * doom_scale)
		BET_DOUBLE_OR_DIE:
			return "MORTE IMMEDIATA: run terminata"
		_:
			return ""

func _get_bet_data(bet_id: String) -> Dictionary:
	if _bet_manager == null or not is_instance_valid(_bet_manager):
		_bet_manager = get_node_or_null("BetManager")
	if _bet_manager and _bet_manager.has_method("get_bet_data"):
		return _bet_manager.call("get_bet_data", bet_id) as Dictionary
	return {}

func _apply_double_or_die_reward_scaled(scale: int) -> void:
	var p: Node = _resolve_player()
	if p == null:
		return
	if not p.has_method("get_damage_values"):
		return
	var damage_values: Array = p.call("get_damage_values") as Array
	if damage_values.size() < 2:
		return
	var light_bonus: int = int(damage_values[0])
	var heavy_bonus: int = int(damage_values[1])
	if light_bonus <= 0 and heavy_bonus <= 0:
		return
	var reward_scale: int = maxi(scale, 1)
	var upgrades: Dictionary = run.get("upgrades", {}) as Dictionary
	for _i in range(reward_scale):
		upgrades["light_bonus"] = int(upgrades.get("light_bonus", 0)) + light_bonus
		upgrades["heavy_bonus"] = int(upgrades.get("heavy_bonus", 0)) + heavy_bonus
	run["upgrades"] = upgrades
	_apply_run_upgrades_to_player()

func retry_current_bet() -> void:
	if _is_game_over:
		return
	_show_shop_next_bet = false
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_reset_bet_chain()
	set_phase(RunPhase.PREP)
	GameEvents.set_gameplay_enabled(false)
	run["arena_index"] = maxi(int(run.get("arena_index", 0)) - 1, 0)
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_clear_enemies()
	if _bet_manager and _bet_manager.has_method("reset_bet_state"):
		_bet_manager.reset_bet_state()
	_reset_or_respawn_player_full()
	_open_bet_ui(false)

func _force_game_over_if_dead() -> bool:
	var p: Node = get_tree().get_first_node_in_group("player")
	if p == null:
		return false
	var current_health: int = _get_player_health_value(p)
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

func _get_player_max_health_value(p: Node) -> int:
	if p == null:
		return -1
	if p.has_method("get_health"):
		var h: Array = p.call("get_health")
		if h.size() > 1:
			return int(h[1])
	if p.has_meta("max_health"):
		return int(p.get_meta("max_health"))
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
	return run.get("upgrades", {}) as Dictionary

func get_upgrade_config() -> Dictionary:
	var costs: Dictionary = run.get("upgrade_costs", {}) as Dictionary
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
	var upgrades: Dictionary = run.get("upgrades", {}) as Dictionary
	var tokens: int = int(run.get("upgrade_tokens", 0))
	var costs: Dictionary = run.get("upgrade_costs", {}) as Dictionary
	var hp_cost: int = int(costs.get("hp", upgrade_hp_token_cost_start))
	var light_cost: int = int(costs.get("light", upgrade_light_token_cost_start))
	var heavy_cost: int = int(costs.get("heavy", upgrade_heavy_token_cost_start))

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
	var upgrades: Dictionary = run.get("upgrades", {}) as Dictionary
	var costs: Dictionary = run.get("upgrade_costs", {}) as Dictionary
	match upgrade_type:
		"hp":
			var cost: int = int(costs.get("hp", upgrade_hp_token_cost_start))
			if not spend_tokens(cost):
				return false
			upgrades["hp_bonus"] = int(upgrades.get("hp_bonus", 0)) + upgrade_hp_bonus
			costs["hp"] = cost + 1
		"light":
			var cost: int = int(costs.get("light", upgrade_light_token_cost_start))
			if not spend_tokens(cost):
				return false
			upgrades["light_bonus"] = int(upgrades.get("light_bonus", 0)) + upgrade_light_bonus
			costs["light"] = cost + 1
		"heavy":
			var cost: int = int(costs.get("heavy", upgrade_heavy_token_cost_start))
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

func set_phase(p: Variant) -> void:
	# Supporta sia RunPhase che int (es. valori serializzati / segnali legacy).
	if typeof(p) == TYPE_INT:
		phase = (p as int) as RunPhase
	else:
		phase = p as RunPhase
	GameEvents.run_phase_changed.emit(int(phase))
	_apply_phase()

func _apply_phase() -> void:
	if GameEvents.has_method("set_gameplay_enabled"):
		GameEvents.set_gameplay_enabled(phase == RunPhase.LIVE)

func _position_player_after_respawn() -> void:
	if _player == null or not (_player is Node2D):
		return
	var spawn_pos: Vector2 = _get_spawn_position()
	(_player as Node2D).global_position = spawn_pos
	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam == null:
		var player_cam: Node = _player.find_child("Camera2D", true, false)
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
	var upgrades: Dictionary = run.get("upgrades", {}) as Dictionary
	var bet_hp_penalty: int = int(run.get("bet_hp_penalty", 0))
	if _player.has_method("apply_run_upgrades"):
		_player.call(
			"apply_run_upgrades",
			int(upgrades.get("hp_bonus", 0)) + bet_hp_penalty,
			int(upgrades.get("light_bonus", 0)),
			int(upgrades.get("heavy_bonus", 0))
		)

func _get_spawn_position() -> Vector2:
	if _arena and _arena is Node:
		var spawn_node: Node = _find_spawn_node(_arena)
		if spawn_node and spawn_node is Node2D:
			return (spawn_node as Node2D).global_position
		if _arena is Node2D:
			return (_arena as Node2D).global_position
	return Vector2.ZERO

func _find_spawn_node(root: Node) -> Node:
	var direct: Node = root.get_node_or_null("Spawn")
	if direct:
		return direct
	var named: Node = root.find_child("Spawn", true, false)
	if named:
		return named
	var player_spawn: Node = root.find_child("PlayerSpawn", true, false)
	if player_spawn:
		return player_spawn
	return root.find_child("PlayerSpawnPoint", true, false)

func _log_runtime_state(tag: String) -> void:
	if not DEBUG_RUNTIME_LOGS:
		return
	var player_node: Node = _resolve_player()
	var player_exists: bool = player_node != null
	var player_in_tree: bool = player_exists and player_node.is_inside_tree()
	var player_physics: bool = player_exists and player_node.is_physics_processing()
	var player_process_mode: int = -1
	if player_exists:
		player_process_mode = player_node.process_mode
	var player_pos: Vector2 = Vector2.ZERO
	if player_exists and player_node is Node2D:
		player_pos = (player_node as Node2D).global_position

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var enemies_count: int = enemies.size()
	var sample_enemy: Node = null
	if enemies_count > 0:
		sample_enemy = enemies[0] as Node
	var enemy_physics: bool = sample_enemy != null and sample_enemy.is_physics_processing()
	var enemy_process_mode: int = -1
	if sample_enemy != null:
		enemy_process_mode = sample_enemy.process_mode

	var cam: Camera2D = get_viewport().get_camera_2d()
	var cam_exists: bool = cam != null
	var cam_current: bool = cam_exists and cam.has_method("is_current") and cam.is_current()
	var cam_pos: Vector2 = Vector2.ZERO
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
