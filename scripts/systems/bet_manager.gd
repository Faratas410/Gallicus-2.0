extends Node

const BETS_PATH := "res://data/bets.gd"

@export var fast_time_limit: float = 15.0

var active_bet: Dictionary = {}
var player_damage_taken: bool = false
var start_time: float = 0.0
var end_time: float = 0.0

var _bets: Array = []
var _arena_active: bool = false
var _run_manager: Node
var _fast_timer: SceneTreeTimer
var _fast_active: bool = false
var _fast_token: int = 0
var _fast_start_time: float = 0.0
var _fast_last_emitted: int = -1
var _arena: Node

func _ready() -> void:
	_run_manager = get_parent()
	_load_bets()
	add_to_group("bet_manager")
	GameEvents.player_damaged.connect(_on_player_damaged)
	_try_connect_player_damage()
	_try_connect_arena()

func _try_connect_player_damage() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_signal("took_damage") and not player.is_connected("took_damage", Callable(self, "_on_player_took_damage")):
		player.connect("took_damage", Callable(self, "_on_player_took_damage"))

func _try_connect_arena() -> void:
	if _arena != null and is_instance_valid(_arena):
		return
	_arena = get_tree().get_first_node_in_group("arena")
	if _arena == null:
		return
	if _arena.has_signal("wave_started") and not _arena.is_connected("wave_started", Callable(self, "_on_wave_started")):
		_arena.connect("wave_started", Callable(self, "_on_wave_started"))
	if _arena.has_signal("wave_cleared") and not _arena.is_connected("wave_cleared", Callable(self, "_on_wave_cleared")):
		_arena.connect("wave_cleared", Callable(self, "_on_wave_cleared"))
	if _arena.has_signal("player_spawned") and not _arena.is_connected("player_spawned", Callable(self, "_on_player_spawned")):
		_arena.connect("player_spawned", Callable(self, "_on_player_spawned"))

func _load_bets() -> void:
	var script := load(BETS_PATH)
	if script:
		var bets_value = script.get("BETS")
		if bets_value is Array:
			_bets = bets_value

func open_bet_ui_before_arena() -> void:
	player_damage_taken = false
	start_time = 0.0
	end_time = 0.0
	_arena_active = false
	_fast_active = false
	_fast_start_time = 0.0
	_fast_last_emitted = -1
	_invalidate_fast_timer()
	GameEvents.bet_ui_opened.emit(_bets)
	GameEvents.bet_opened.emit()

func place_bet(bet_id: String, stake: int) -> bool:
	var bet := _get_bet_by_id(bet_id)
	if bet.is_empty():
		return false
	stake = maxi(stake, 0)
	if stake > 0 and _run_manager and _run_manager.has_method("spend_coins"):
		if not _run_manager.spend_coins(stake):
			return false
	active_bet = {
		"id": bet_id,
		"stake": stake,
		"odds": float(bet["odds"]),
	}
	GameEvents.bet_placed.emit(bet_id, stake, float(bet["odds"]))
	GameEvents.bet_ui_closed.emit()
	GameEvents.bet_closed.emit()
	return true

func register_arena_start() -> void:
	_arena_active = true
	player_damage_taken = false
	start_time = Time.get_ticks_msec() / 1000.0
	_try_connect_player_damage()
	_try_connect_arena()

func resolve_bet() -> void:
	if active_bet.is_empty():
		return
	end_time = Time.get_ticks_msec() / 1000.0
	var won := false
	if not active_bet.get("failed", false):
		if active_bet.get("forced_win", false):
			won = true
		else:
			won = _evaluate_bet(active_bet["id"])
	if won:
		var payout := int(active_bet["stake"] * float(active_bet["odds"]))
		if _run_manager and _run_manager.has_method("add_coins"):
			_run_manager.add_coins(payout)
	active_bet = {}
	_arena_active = false
	_fast_active = false
	_fast_start_time = 0.0
	_fast_last_emitted = -1
	_invalidate_fast_timer()

func reset_bet_state() -> void:
	active_bet = {}
	player_damage_taken = false
	start_time = 0.0
	end_time = 0.0
	_arena_active = false
	_fast_active = false
	_fast_start_time = 0.0
	_fast_last_emitted = -1
	_invalidate_fast_timer()
	GameEvents.bet_ui_closed.emit()
	GameEvents.bet_closed.emit()

func is_bet_active() -> bool:
	return not active_bet.is_empty()

func _evaluate_bet(bet_id: String) -> bool:
	match bet_id:
		"WIN":
			return true
		"NO_HIT":
			return not player_damage_taken
		"FAST":
			if start_time <= 0.0:
				return false
			return (end_time - start_time) <= fast_time_limit
		_:
			return false

func _get_bet_by_id(bet_id: String) -> Dictionary:
	for bet in _bets:
		if bet.get("id", "") == bet_id:
			return bet
	return {}

func _on_player_damaged() -> void:
	if _arena_active:
		player_damage_taken = true
		_handle_no_hit_failure()

func _on_player_took_damage(_amount: int) -> void:
	if _arena_active:
		player_damage_taken = true
	_handle_no_hit_failure()

func _on_player_spawned(_player: Node) -> void:
	_try_connect_player_damage()

func _on_wave_started(_wave: int) -> void:
	if active_bet.get("id", "") != "FAST" or not is_bet_active():
		return
	if not _arena_active:
		return
	_fast_active = true
	_fast_token += 1
	var token := _fast_token
	_fast_start_time = Time.get_ticks_msec() / 1000.0
	_fast_last_emitted = -1
	_start_fast_countdown(token)
	_fast_timer = get_tree().create_timer(fast_time_limit)
	_fast_timer.timeout.connect(func() -> void:
		_on_fast_timeout(token)
	)

func _on_wave_cleared(_wave: int) -> void:
	if active_bet.get("id", "") != "FAST" or not is_bet_active():
		return
	_fast_active = false
	end_time = Time.get_ticks_msec() / 1000.0
	win_current_bet()
	_invalidate_fast_timer()

func _on_fast_timeout(token: int) -> void:
	if token != _fast_token:
		return
	if active_bet.get("id", "") == "FAST" and is_bet_active() and _fast_active:
		fail_current_bet()

func fail_current_bet() -> void:
	if active_bet.is_empty() or active_bet.get("failed", false) or not _arena_active:
		return
	active_bet["failed"] = true
	_fast_active = false
	_fast_start_time = 0.0
	_fast_last_emitted = -1
	_invalidate_fast_timer()
	if _run_manager != null and _run_manager.has_method("handle_bet_failed"):
		_run_manager.handle_bet_failed()
	else:
		GameEvents.run_failed.emit()
		GameEvents.set_gameplay_enabled(false)
	_arena_active = false

func win_current_bet() -> void:
	if active_bet.is_empty():
		return
	active_bet["forced_win"] = true

func _invalidate_fast_timer() -> void:
	_fast_token += 1
	_fast_timer = null
	_fast_active = false
	_fast_start_time = 0.0
	_fast_last_emitted = -1
	GameEvents.countdown_requested.emit(0)

func _start_fast_countdown(token: int) -> void:
	if token != _fast_token:
		return
	_emit_fast_countdown()
	_schedule_fast_tick(token)

func _schedule_fast_tick(token: int) -> void:
	if token != _fast_token or not _fast_active:
		return
	var timer := get_tree().create_timer(1.0)
	timer.timeout.connect(func() -> void:
		_on_fast_tick(token)
	)

func _on_fast_tick(token: int) -> void:
	if token != _fast_token or not _fast_active:
		return
	_emit_fast_countdown()
	_schedule_fast_tick(token)

func _emit_fast_countdown() -> void:
	if not _fast_active or _fast_start_time <= 0.0:
		return
	var elapsed := (Time.get_ticks_msec() / 1000.0) - _fast_start_time
	var remaining := int(ceil(fast_time_limit - elapsed))
	remaining = maxi(remaining, 0)
	if remaining == _fast_last_emitted:
		return
	_fast_last_emitted = remaining
	GameEvents.countdown_requested.emit(remaining)

func _handle_no_hit_failure() -> void:
	if active_bet.is_empty():
		return
	if active_bet.get("id", "") == "NO_HIT" and _arena_active:
		fail_current_bet()
