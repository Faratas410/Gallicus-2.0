extends Node

const BETS_PATH: String = "res://data/bets.gd"

const BET_COWARD: String = "COWARD"
const BET_PURE_BLOOD: String = "PURE_BLOOD"
const BET_DOUBLE_OR_DIE: String = "DOUBLE_OR_DIE"

var active_bet: Dictionary = {}
var player_damage_taken: bool = false

var _bets: Array = []
var _arena_active: bool = false
var _run_manager: Node
var _arena: Node

func _ready() -> void:
	_run_manager = get_parent()
	_load_bets()
	add_to_group("bet_manager")
	var player_damaged_callable: Callable = Callable(self, "_on_player_damaged")
	if not GameEvents.player_damaged.is_connected(player_damaged_callable):
		GameEvents.player_damaged.connect(player_damaged_callable)
	var request_place_bet_callable: Callable = Callable(self, "_on_request_place_bet")
	if GameEvents.has_signal("request_place_bet") and not GameEvents.request_place_bet.is_connected(request_place_bet_callable):
		GameEvents.request_place_bet.connect(request_place_bet_callable)
	var request_open_bet_callable: Callable = Callable(self, "_on_request_open_bet_ui")
	if GameEvents.has_signal("request_open_bet_ui") and not GameEvents.request_open_bet_ui.is_connected(request_open_bet_callable):
		GameEvents.request_open_bet_ui.connect(request_open_bet_callable)
	_try_connect_player_damage()
	_try_connect_arena()

func _try_connect_player_damage() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("took_damage"):
		var took_damage_callable: Callable = Callable(self, "_on_player_took_damage")
		if not player.took_damage.is_connected(took_damage_callable):
			player.took_damage.connect(took_damage_callable)

func _try_connect_arena() -> void:
	if _arena != null and is_instance_valid(_arena):
		return
	_arena = get_tree().get_first_node_in_group("arena")
	if _arena == null:
		return
	if _arena.has_signal("player_spawned"):
		var player_spawned_callable: Callable = Callable(self, "_on_player_spawned")
		if not _arena.player_spawned.is_connected(player_spawned_callable):
			_arena.player_spawned.connect(player_spawned_callable)

func _load_bets() -> void:
	var script: Script = load(BETS_PATH) as Script
	if script:
		var bets_value: Variant = script.get("BETS")
		if bets_value is Array:
			_bets = bets_value

func open_bet_ui_before_arena() -> void:
	player_damage_taken = false
	_arena_active = false
	GameEvents.bet_ui_opened.emit(_bets)
	GameEvents.bet_opened.emit()

func set_chain_bet(bet_id: String) -> bool:
	var bet: Dictionary = _get_bet_by_id(bet_id)
	if bet.is_empty():
		return false
	active_bet = {
		"id": bet_id,
	}
	player_damage_taken = false
	_arena_active = false
	return true

func place_bet(bet_id: String, _stake: int) -> bool:
	var bet: Dictionary = _get_bet_by_id(bet_id)
	if bet.is_empty():
		return false
	active_bet = {
		"id": bet_id,
	}
	GameEvents.bet_placed.emit(bet_id, 0, 1.0)
	GameEvents.bet_ui_closed.emit()
	GameEvents.bet_closed.emit()
	return true

func _on_request_place_bet(bet_id: String, stake: int) -> void:
	place_bet(bet_id, stake)

func _on_request_open_bet_ui() -> void:
	open_bet_ui_before_arena()

func register_arena_start() -> void:
	_arena_active = true
	player_damage_taken = false
	_try_connect_player_damage()
	_try_connect_arena()

func resolve_bet() -> Dictionary:
	if active_bet.is_empty():
		return {}
	var won: bool = false
	if not bool(active_bet.get("failed", false)):
		if bool(active_bet.get("forced_win", false)):
			won = true
		else:
			won = _evaluate_bet(str(active_bet["id"]))
	var result: Dictionary = {
		"id": str(active_bet.get("id", "")),
		"won": won,
	}
	active_bet = {}
	_arena_active = false
	return result

func reset_bet_state() -> void:
	active_bet = {}
	player_damage_taken = false
	_arena_active = false
	GameEvents.bet_ui_closed.emit()
	GameEvents.bet_closed.emit()

func is_bet_active() -> bool:
	return not active_bet.is_empty()

func _evaluate_bet(bet_id: String) -> bool:
	match bet_id:
		BET_COWARD, BET_DOUBLE_OR_DIE:
			return true
		BET_PURE_BLOOD:
			return not player_damage_taken
		_:
			return false

func _get_bet_by_id(bet_id: String) -> Dictionary:
	for bet_value: Dictionary in _bets:
		var bet: Dictionary = bet_value as Dictionary
		if str(bet.get("id", "")) == bet_id:
			return bet
	return {}

func get_bet_data(bet_id: String) -> Dictionary:
	return _get_bet_by_id(bet_id)

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

func fail_current_bet() -> void:
	if active_bet.is_empty() or active_bet.get("failed", false) or not _arena_active:
		return
	active_bet["failed"] = true
	var bet_id: String = str(active_bet.get("id", ""))
	if _run_manager != null and _run_manager.has_method("handle_bet_failed"):
		_run_manager.handle_bet_failed(bet_id)
	else:
		if bet_id == BET_DOUBLE_OR_DIE and GameEvents.has_signal("request_fail_run"):
			GameEvents.request_fail_run.emit("RUN_FAILED")
	_arena_active = false

func win_current_bet() -> void:
	if active_bet.is_empty():
		return
	active_bet["forced_win"] = true

func _handle_no_hit_failure() -> void:
	if active_bet.is_empty():
		return
	var bet_id: String = str(active_bet.get("id", ""))
	if bet_id == BET_PURE_BLOOD and _arena_active:
		fail_current_bet()
