extends Node

const BETS_PATH := "res://data/bets.gd"

var active_bet: Dictionary = {}
var player_damage_taken: bool = false
var start_time: float = 0.0
var end_time: float = 0.0

var _bets: Array = []
var _arena_active: bool = false
var _run_manager: Node

func _ready() -> void:
	_run_manager = get_parent()
	_load_bets()
	add_to_group("bet_manager")
	GameEvents.player_damaged.connect(_on_player_damaged)

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
	GameEvents.bet_ui_opened.emit(_bets)
	GameEvents.betting_opened.emit()

func place_bet(bet_id: String, stake: int) -> bool:
	var bet := _get_bet_by_id(bet_id)
	if bet.is_empty():
		return false
	stake = max(stake, 0)
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
	GameEvents.betting_closed.emit()
	return true

func register_arena_start() -> void:
	_arena_active = true
	player_damage_taken = false
	start_time = Time.get_ticks_msec() / 1000.0

func resolve_bet() -> void:
	if active_bet.is_empty():
		return
	end_time = Time.get_ticks_msec() / 1000.0
	var won := _evaluate_bet(active_bet["id"])
	if won:
		var payout := int(active_bet["stake"] * float(active_bet["odds"]))
		if _run_manager and _run_manager.has_method("add_coins"):
			_run_manager.add_coins(payout)
	active_bet = {}
	_arena_active = false

func reset_bet_state() -> void:
	active_bet = {}
	player_damage_taken = false
	start_time = 0.0
	end_time = 0.0
	_arena_active = false
	GameEvents.bet_ui_closed.emit()
	GameEvents.betting_closed.emit()

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
			return (end_time - start_time) <= 30.0
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
