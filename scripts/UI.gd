extends CanvasLayer

@export var run_manager_path: NodePath
@export var arena_path: NodePath

@onready var _label_health: Label = $HUD/Panel/VBox/HealthLabel
@onready var _label_gold: Label = $HUD/Panel/VBox/GoldLabel
@onready var _label_bet: Label = $HUD/Panel/VBox/BetLabel
@onready var _label_wave: Label = $HUD/Panel/VBox/WaveLabel
@onready var _label_state: Label = $HUD/Panel/VBox/StateLabel
@onready var _label_hint: Label = $HUD/Panel/VBox/HintLabel

var _run_manager: Node
var _arena: Node

func _ready() -> void:
	_run_manager = get_node_or_null(run_manager_path)
	_arena = get_node_or_null(arena_path)
	if _run_manager:
		_run_manager.connect("gold_changed", _on_gold_changed)
		_run_manager.connect("bet_changed", _on_bet_changed)
		_run_manager.connect("state_changed", _on_state_changed)
		_run_manager.connect("run_over", _on_run_over)
		if _run_manager.has_method("get_current_bet"):
			_on_bet_changed(_run_manager.call("get_current_bet"))
		if _run_manager.has_method("is_betting_open"):
			_on_state_changed(_run_manager.call("is_betting_open"))
	if _arena:
		_arena.connect("player_spawned", _on_player_spawned)
		_arena.connect("wave_started", _on_wave_started)
		_arena.connect("wave_cleared", _on_wave_cleared)
		if _arena.has_method("get_current_wave"):
			_on_wave_started(_arena.call("get_current_wave"))
	_update_hint()

func _on_player_spawned(player: Node) -> void:
	if player and player.has_signal("health_changed"):
		player.connect("health_changed", _on_health_changed)

func _on_health_changed(current: int, max_value: int) -> void:
	_label_health.text = "HP: %d / %d" % [current, max_value]

func _on_gold_changed(amount: int) -> void:
	_label_gold.text = "Gold: %d" % amount

func _on_bet_changed(amount: int) -> void:
	_label_bet.text = "Bet: %d" % amount

func _on_state_changed(betting_open: bool) -> void:
	_label_state.text = betting_open ? "State: Betting" : "State: Fighting"
	_update_hint()

func _on_wave_started(wave: int) -> void:
	_label_wave.text = "Wave: %d" % wave

func _on_wave_cleared(wave: int) -> void:
	_label_wave.text = "Wave: %d (cleared)" % wave

func _on_run_over() -> void:
	_label_state.text = "State: Defeated"
	_label_hint.text = "Run over"

func _update_hint() -> void:
	if _run_manager and _run_manager.has_method("is_betting_open") and _run_manager.call("is_betting_open"):
		_label_hint.text = "E: cycle bet | J: start wave"
	else:
		_label_hint.text = "J/K: attack | Space: block | Shift: dodge"
