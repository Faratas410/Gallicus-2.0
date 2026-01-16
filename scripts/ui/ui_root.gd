extends CanvasLayer

const FAST_SELECTION_SECONDS: int = 12

@onready var coins_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/CoinsRow/CoinsContent/CoinsLabel") as Label
@onready var tokens_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/TokensRow/TokensLabel") as Label
@onready var level_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/LevelRow/LevelLabel") as Label
@onready var bet_info_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/BetRow/BetContent/BetInfoLabel") as Label
@onready var xp_bar: ProgressBar = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/XPRow/XPBar") as ProgressBar
@onready var xp_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/XPRow/XPLabel") as Label
@onready var player_hp_bar: ProgressBar = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/PlayerHPRow/PlayerHPContent/PlayerHPBar") as ProgressBar
@onready var player_hp_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/PlayerHPRow/PlayerHPContent/PlayerHPLabel") as Label
@onready var bet_panel: Panel = _req("Modals/BetPanel") as Panel
@onready var buy_token_button: Button = get_node_or_null("Modals/BetPanel/BetScroll/BetVBox/BuyTokenRow/BuyTokenButton") as Button
@onready var buy_token_info: Label = get_node_or_null("Modals/BetPanel/BetScroll/BetVBox/BuyTokenRow/BuyTokenInfo") as Label
@onready var coins_icon: TextureRect = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/CoinsRow/CoinsContent/CoinIcon") as TextureRect
@onready var tokens_icon: TextureRect = get_node_or_null("HUD/SafeMargin/TopRow/LeftColumn/TokensRow/TokenIcon") as TextureRect
@onready var modal_dimmer: ColorRect = get_node_or_null("Modals/ModalDimmer") as ColorRect
@onready var stake_row: Control = get_node_or_null("Modals/BetPanel/BetScroll/BetVBox/StakeRow") as Control
@onready var stake_input: SpinBox = _req("Modals/BetPanel/BetScroll/BetVBox/StakeRow/StakeInput") as SpinBox
@onready var bet_win_button: Button = _req("Modals/BetPanel/BetScroll/BetVBox/BetButtons/BetWinButton") as Button
@onready var bet_no_hit_button: Button = _req("Modals/BetPanel/BetScroll/BetVBox/BetButtons/BetNoHitButton") as Button
@onready var bet_fast_button: Button = _req("Modals/BetPanel/BetScroll/BetVBox/BetButtons/BetFastButton") as Button
@onready var debug_overlay: Label = get_node_or_null("HUD/DebugOverlay") as Label
@onready var level_up_popup: Label = get_node_or_null("HUD/LevelUpPopup") as Label
@onready var scar_popup: Label = get_node_or_null("HUD/ScarPopup") as Label
@onready var sfx_level_up: AudioStreamPlayer = get_node_or_null("SFX/SfxLevelUp") as AudioStreamPlayer
@onready var sfx_buy_token: AudioStreamPlayer = get_node_or_null("SFX/SfxBuyToken") as AudioStreamPlayer
@onready var game_over_panel: Panel = get_node_or_null("Modals/GameOverPanel") as Panel
@onready var push_luck_panel: Panel = get_node_or_null("Modals/PushLuckPanel") as Panel
@onready var push_luck_title: Label = get_node_or_null("Modals/PushLuckPanel/PushLuckVBox/PushLuckTitle") as Label
@onready var push_luck_info: Label = get_node_or_null("Modals/PushLuckPanel/PushLuckVBox/PushLuckInfo") as Label
@onready var push_luck_details: Label = get_node_or_null("Modals/PushLuckPanel/PushLuckVBox/PushLuckDetails") as Label
@onready var push_luck_cashout_button: Button = get_node_or_null("Modals/PushLuckPanel/PushLuckVBox/PushLuckButtons/PushLuckCashoutButton") as Button
@onready var push_luck_double_button: Button = get_node_or_null("Modals/PushLuckPanel/PushLuckVBox/PushLuckButtons/PushLuckDoubleButton") as Button
@onready var game_over_title: Label = get_node_or_null("Modals/GameOverPanel/GameOverVBox/GameOverTitle") as Label
@onready var game_over_epilogue: Label = get_node_or_null("Modals/GameOverPanel/GameOverVBox/GameOverEpilogue") as Label
@onready var game_over_scars: Label = get_node_or_null("Modals/GameOverPanel/GameOverVBox/GameOverScars") as Label
@onready var game_over_hint: Label = get_node_or_null("Modals/GameOverPanel/GameOverVBox/GameOverHint") as Label
@onready var restart_button: Button = get_node_or_null("Modals/GameOverPanel/GameOverVBox/RestartButton") as Button
@onready var next_bet_button: Button = get_node_or_null("Modals/GameOverPanel/GameOverVBox/NextBetButton") as Button
@onready var quit_button: Button = get_node_or_null("Modals/GameOverPanel/GameOverVBox/QuitButton") as Button
@onready var controls_hint_panel: Panel = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ControlsHintPanel") as Panel
@onready var scars_panel: Panel = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ScarsPanel") as Panel
@onready var scars_label: Label = get_node_or_null("HUD/SafeMargin/TopRow/RightColumn/ScarsPanel/ScarsVBox/ScarsScroll/ScarsLabel") as Label
@onready var countdown_label: Label = get_node_or_null("Modals/CountdownLabel") as Label
@onready var fast_countdown_label: Label = get_node_or_null("Modals/FastCountdownLabel") as Label
@onready var fast_blink_timer: Timer = get_node_or_null("Modals/FastBlinkTimer") as Timer
@onready var enemy_bars: Control = get_node_or_null("WorldUI/EnemyBars") as Control

@export var sfx_level_up_path: String = "res://assets/audio/ui/level_up.ogg"
@export var sfx_buy_token_path: String = "res://assets/audio/ui/buy_token.ogg"

var _enemy_bar_scene: PackedScene = preload("res://scenes/ui/EnemyHealthBar.tscn")
var _bets_by_id: Dictionary = {}
var _bet_manager: Node
var _run_manager: Node
var _arena: Node
var _player: Node = null
var _has_seen_controls: bool = false
var _fast_countdown_active: bool = false
var _controls_first_run_active: bool = true
var _selected_bet_id: String = ""
var _pending_bets: Array = []
var _xp_current: int = 0
var _xp_to_next: int = 6
var _level: int = 1
var _tokens: int = 0
var _coins: int = 0
var _popup_tween: Tween = null
var _scar_popup_tween: Tween = null
var _last_level: int = 1
var _last_tokens: int = 0
var _xp_anim_tween: Tween = null
var _xp_punch_tween: Tween = null
var _last_xp_to_next: int = 0
var _enemy_bar_nodes: Dictionary = {}
var _last_finale_title: String = "RUN FAILED"
var _last_finale_text: String = ""
var _last_finale_scars: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if controls_hint_panel != null:
		controls_hint_panel.visible = true
		_has_seen_controls = false
		_controls_first_run_active = true
	var coins_changed_callable: Callable = Callable(self, "_on_coins_changed")
	if not GameEvents.coins_changed.is_connected(coins_changed_callable):
		GameEvents.coins_changed.connect(coins_changed_callable)
	var bet_placed_callable: Callable = Callable(self, "_on_bet_placed")
	if not GameEvents.bet_placed.is_connected(bet_placed_callable):
		GameEvents.bet_placed.connect(bet_placed_callable)
	var run_started_callable: Callable = Callable(self, "_on_run_started")
	if not GameEvents.run_started.is_connected(run_started_callable):
		GameEvents.run_started.connect(run_started_callable)
	var run_started_ui_callable: Callable = Callable(self, "_on_run_started_ui")
	if not GameEvents.run_started.is_connected(run_started_ui_callable):
		GameEvents.run_started.connect(run_started_ui_callable)
	var run_failed_callable: Callable = Callable(self, "_on_run_failed")
	if not GameEvents.run_failed.is_connected(run_failed_callable):
		GameEvents.run_failed.connect(run_failed_callable)
	var run_finale_callable: Callable = Callable(self, "_on_run_finale_selected")
	if GameEvents.has_signal("run_finale_selected") and not GameEvents.run_finale_selected.is_connected(run_finale_callable):
		GameEvents.run_finale_selected.connect(run_finale_callable)
	var bet_failed_callable: Callable = Callable(self, "_on_bet_failed")
	if not GameEvents.bet_failed.is_connected(bet_failed_callable):
		GameEvents.bet_failed.connect(bet_failed_callable)
	var run_started_controls_callable: Callable = Callable(self, "_on_run_started_controls")
	if not GameEvents.run_started.is_connected(run_started_controls_callable):
		GameEvents.run_started.connect(run_started_controls_callable)
	var run_failed_controls_callable: Callable = Callable(self, "_on_run_failed_controls")
	if not GameEvents.run_failed.is_connected(run_failed_controls_callable):
		GameEvents.run_failed.connect(run_failed_controls_callable)
	var bet_ui_opened_callable: Callable = Callable(self, "_on_bet_ui_opened")
	if not GameEvents.bet_ui_opened.is_connected(bet_ui_opened_callable):
		GameEvents.bet_ui_opened.connect(bet_ui_opened_callable)
	var bet_ui_closed_callable: Callable = Callable(self, "_on_bet_ui_closed")
	if not GameEvents.bet_ui_closed.is_connected(bet_ui_closed_callable):
		GameEvents.bet_ui_closed.connect(bet_ui_closed_callable)
	var betting_opened_callable: Callable = Callable(self, "_on_betting_opened")
	if not GameEvents.betting_opened.is_connected(betting_opened_callable):
		GameEvents.betting_opened.connect(betting_opened_callable)
	var push_luck_opened_callable: Callable = Callable(self, "_on_push_luck_opened")
	if GameEvents.has_signal("push_luck_opened") and not GameEvents.push_luck_opened.is_connected(push_luck_opened_callable):
		GameEvents.push_luck_opened.connect(push_luck_opened_callable)
	var push_luck_closed_callable: Callable = Callable(self, "_on_push_luck_closed")
	if GameEvents.has_signal("push_luck_closed") and not GameEvents.push_luck_closed.is_connected(push_luck_closed_callable):
		GameEvents.push_luck_closed.connect(push_luck_closed_callable)
	var countdown_callable: Callable = Callable(self, "_on_countdown_requested")
	if not GameEvents.countdown_requested.is_connected(countdown_callable):
		GameEvents.countdown_requested.connect(countdown_callable)
	var player_level_callable: Callable = Callable(self, "_on_player_level_changed")
	if not GameEvents.player_level_changed.is_connected(player_level_callable):
		GameEvents.player_level_changed.connect(player_level_callable)
	var player_xp_callable: Callable = Callable(self, "_on_player_xp_changed")
	if not GameEvents.player_xp_changed.is_connected(player_xp_callable):
		GameEvents.player_xp_changed.connect(player_xp_callable)
	var level_changed_callable: Callable = Callable(self, "_on_player_level_changed")
	if not GameEvents.level_changed.is_connected(level_changed_callable):
		GameEvents.level_changed.connect(level_changed_callable)
	var xp_changed_callable: Callable = Callable(self, "_on_player_xp_changed")
	if not GameEvents.xp_changed.is_connected(xp_changed_callable):
		GameEvents.xp_changed.connect(xp_changed_callable)
	var tokens_changed_callable: Callable = Callable(self, "_on_tokens_changed")
	if not GameEvents.tokens_changed.is_connected(tokens_changed_callable):
		GameEvents.tokens_changed.connect(tokens_changed_callable)
	var scars_updated_callable: Callable = Callable(self, "_on_scars_updated")
	if GameEvents.has_signal("scars_updated") and not GameEvents.scars_updated.is_connected(scars_updated_callable):
		GameEvents.scars_updated.connect(scars_updated_callable)
	var scar_applied_callable: Callable = Callable(self, "_on_scar_applied")
	if GameEvents.has_signal("scar_applied") and not GameEvents.scar_applied.is_connected(scar_applied_callable):
		GameEvents.scar_applied.connect(scar_applied_callable)
	_ensure_token_icons()
	_refresh_progression_ui()
	_refresh_scars_ui([])

	_wire_buy_token_button()
	_refresh_buy_token_ui()
	_try_load_sfx_streams()

	if bet_panel == null:
		push_warning("Bet UI missing, disabling betting panel.")
	else:
		bet_panel.visible = false
		if stake_input == null or bet_win_button == null or bet_no_hit_button == null or bet_fast_button == null:
			push_warning("Bet UI nodes incomplete, disabling betting panel.")
			bet_panel.visible = false
		else:
			if stake_row != null:
				stake_row.visible = false
			stake_input.editable = false
			stake_input.value = 0
			if not bet_win_button.pressed.is_connected(Callable(self, "_on_bet_win_pressed")):
				bet_win_button.pressed.connect(Callable(self, "_on_bet_win_pressed"))
			if not bet_no_hit_button.pressed.is_connected(Callable(self, "_on_bet_no_hit_pressed")):
				bet_no_hit_button.pressed.connect(Callable(self, "_on_bet_no_hit_pressed"))
			if not bet_fast_button.pressed.is_connected(Callable(self, "_on_bet_fast_pressed")):
				bet_fast_button.pressed.connect(Callable(self, "_on_bet_fast_pressed"))

	if debug_overlay != null:
		debug_overlay.visible = false
	if level_up_popup != null:
		level_up_popup.visible = false
	if scar_popup != null:
		scar_popup.visible = false

	if fast_blink_timer != null:
		var blink_callable: Callable = Callable(self, "_on_fast_blink_tick")
		if not fast_blink_timer.timeout.is_connected(blink_callable):
			fast_blink_timer.timeout.connect(blink_callable)

	if restart_button != null:
		if not restart_button.pressed.is_connected(Callable(self, "_on_restart_pressed")):
			restart_button.pressed.connect(Callable(self, "_on_restart_pressed"))
	if next_bet_button != null:
		if not next_bet_button.pressed.is_connected(Callable(self, "_on_retry_pressed")):
			next_bet_button.pressed.connect(Callable(self, "_on_retry_pressed"))
	if quit_button != null:
		if not quit_button.pressed.is_connected(Callable(self, "_on_quit_pressed")):
			quit_button.pressed.connect(Callable(self, "_on_quit_pressed"))
	if push_luck_panel != null:
		push_luck_panel.visible = false
	if modal_dimmer != null:
		modal_dimmer.visible = false
		modal_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wire_push_luck_buttons()

	var arena: Node = get_tree().get_first_node_in_group("arena")
	if arena != null and arena.has_signal("player_spawned"):
		var arena_player_callable: Callable = Callable(self, "_on_player_spawned")
		if not arena.player_spawned.is_connected(arena_player_callable):
			arena.player_spawned.connect(arena_player_callable)
		if arena.has_signal("enemy_spawned"):
			var enemy_spawn_callable: Callable = Callable(self, "_on_enemy_spawned")
			if not arena.enemy_spawned.is_connected(enemy_spawn_callable):
				arena.enemy_spawned.connect(enemy_spawn_callable)
		if arena.has_signal("enemy_despawned"):
			var enemy_despawn_callable: Callable = Callable(self, "_on_enemy_despawned")
			if not arena.enemy_despawned.is_connected(enemy_despawn_callable):
				arena.enemy_despawned.connect(enemy_despawn_callable)
		_sync_enemy_bars()

	var p: Node = get_tree().get_first_node_in_group("player")
	if p != null:
		_bind_player(p)

	print("UI ready: coins=%s bet_panel=%s debug=%s" % [coins_label != null, bet_panel != null, debug_overlay != null])

func _sync_enemy_bars() -> void:
	if enemy_bars == null:
		return
	for enemy_node: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy_node is Node2D:
			_ensure_enemy_bar(enemy_node)

func _on_enemy_spawned(enemy: Node2D) -> void:
	_ensure_enemy_bar(enemy)

func _on_enemy_despawned(enemy: Node2D) -> void:
	_remove_enemy_bar(enemy)

func _on_enemy_tree_exited(enemy: Node2D) -> void:
	_remove_enemy_bar(enemy)

func _ensure_enemy_bar(enemy: Node2D) -> void:
	if enemy_bars == null:
		return
	if _enemy_bar_nodes.has(enemy):
		return
	var bar: Control = _enemy_bar_scene.instantiate() as Control
	if bar == null:
		return
	enemy_bars.add_child(bar)
	var anchor: Node2D = _get_enemy_anchor(enemy)
	if bar.has_method("set_target"):
		bar.call("set_target", enemy, anchor)
	if enemy.has_signal("health_changed") and bar.has_method("set_health"):
		var health_callable: Callable = Callable(bar, "set_health")
		if not enemy.health_changed.is_connected(health_callable):
			enemy.health_changed.connect(health_callable)
	if enemy.has_method("get_health") and bar.has_method("set_health"):
		var health: Array = enemy.call("get_health") as Array
		if health.size() >= 2:
			bar.call("set_health", int(health[0]), int(health[1]))
	_enemy_bar_nodes[enemy] = bar
	var exit_callable: Callable = Callable(self, "_on_enemy_tree_exited").bind(enemy)
	if not enemy.tree_exited.is_connected(exit_callable):
		enemy.tree_exited.connect(exit_callable)

func _remove_enemy_bar(enemy: Node2D) -> void:
	if not _enemy_bar_nodes.has(enemy):
		return
	var bar: Control = _enemy_bar_nodes[enemy] as Control
	_enemy_bar_nodes.erase(enemy)
	if bar != null and is_instance_valid(bar):
		bar.queue_free()

func _get_enemy_anchor(enemy: Node2D) -> Node2D:
	var anchor: Node2D = enemy.get_node_or_null("HpAnchor") as Node2D
	if anchor != null:
		return anchor
	return enemy

func _on_player_level_changed(level: int) -> void:
	_level = maxi(level, 1)
	if level_label != null:
		level_label.text = "Level: %d" % _level
	if _level > _last_level:
		_show_level_up_popup("+1 TOKEN")
		_play_sfx(sfx_level_up)
	_last_level = _level

func _on_player_xp_changed(xp: int, xp_to_next: int) -> void:
	_animate_xp_bar(xp, xp_to_next)
	if xp_label != null:
		xp_label.text = "XP: %d/%d" % [xp, xp_to_next]

func _on_tokens_changed(tokens: int) -> void:
	_tokens = maxi(tokens, 0)
	if tokens_label != null:
		tokens_label.text = "Tokens: %d" % _tokens
	_last_tokens = _tokens
	_refresh_buy_token_ui()

func _refresh_progression_ui() -> void:
	if level_label != null:
		level_label.text = "Level: %d" % _level
	if tokens_label != null:
		tokens_label.text = "Tokens: %d" % _tokens
	if xp_bar != null:
		xp_bar.max_value = float(maxi(_xp_to_next, 1))
	if xp_label != null:
		xp_label.text = "XP: %d/%d" % [_xp_current, _xp_to_next]

func _wire_buy_token_button() -> void:
	if buy_token_button == null:
		return
	var buy_token_callable: Callable = Callable(self, "_on_buy_token_pressed")
	if not buy_token_button.pressed.is_connected(buy_token_callable):
		buy_token_button.pressed.connect(buy_token_callable)

func _refresh_buy_token_ui() -> void:
	if buy_token_button == null:
		return
	var manager: Node = _get_run_manager()
	if manager == null:
		buy_token_button.disabled = true
		buy_token_button.text = "BUY TOKEN"
		if buy_token_info != null:
			buy_token_info.text = "-"
		return

	var cost: int = 100
	if manager.has_method("get_token_buy_cost"):
		cost = int(manager.call("get_token_buy_cost"))
	elif manager.has_method("get_buy_token_cost"):
		cost = int(manager.call("get_buy_token_cost"))
	elif manager.has_method("get_token_purchase_cost"):
		cost = int(manager.call("get_token_purchase_cost"))
	elif manager.has_variable("token_buy_cost"):
		cost = int(manager.get("token_buy_cost"))
	elif manager.has_variable("token_purchase_cost_coins"):
		cost = int(manager.get("token_purchase_cost_coins"))

	var coins: int = _coins
	if manager.has_method("get_coins"):
		coins = int(manager.call("get_coins"))

	buy_token_button.text = "BUY TOKEN (%dc)" % cost
	buy_token_button.disabled = coins < cost
	if buy_token_info != null:
		buy_token_info.text = "Coins: %d" % coins

func _animate_xp_bar(xp: int, xp_to_next: int) -> void:
	if xp_bar == null:
		return
	_xp_current = maxi(xp, 0)
	_xp_to_next = maxi(xp_to_next, 1)
	var maxv: float = float(_xp_to_next)
	xp_bar.max_value = maxv

	var changed_curve: bool = xp_to_next != _last_xp_to_next and _last_xp_to_next != 0
	_last_xp_to_next = xp_to_next

	var target: float = float(clamp(_xp_current, 0, _xp_to_next))
	var current: float = float(xp_bar.value)

	_kill_xp_tweens()

	if target < current:
		_xp_anim_tween = create_tween()
		_xp_anim_tween.set_trans(Tween.TRANS_QUAD)
		_xp_anim_tween.set_ease(Tween.EASE_OUT)
		var anim_duration: float = 0.14
		if changed_curve:
			anim_duration = 0.10
		_xp_anim_tween.tween_property(xp_bar, "value", target, anim_duration)
		return

	_xp_anim_tween = create_tween()
	_xp_anim_tween.set_trans(Tween.TRANS_QUAD)
	_xp_anim_tween.set_ease(Tween.EASE_OUT)
	_xp_anim_tween.tween_property(xp_bar, "value", target, 0.18)

	_xp_punch_tween = create_tween()
	_xp_punch_tween.set_trans(Tween.TRANS_BACK)
	_xp_punch_tween.set_ease(Tween.EASE_OUT)
	_xp_punch_tween.tween_property(xp_bar, "scale", Vector2(1.02, 1.02), 0.08)
	_xp_punch_tween.tween_property(xp_bar, "scale", Vector2.ONE, 0.10)

func _kill_xp_tweens() -> void:
	if _xp_anim_tween != null and is_instance_valid(_xp_anim_tween):
		_xp_anim_tween.kill()
	_xp_anim_tween = null
	if _xp_punch_tween != null and is_instance_valid(_xp_punch_tween):
		_xp_punch_tween.kill()
	_xp_punch_tween = null

func _try_load_sfx_streams() -> void:
	_safe_assign_stream(sfx_level_up, sfx_level_up_path)
	_safe_assign_stream(sfx_buy_token, sfx_buy_token_path)

func _safe_assign_stream(player: AudioStreamPlayer, path: String) -> void:
	if player == null:
		return
	if path == "":
		return
	if ResourceLoader.exists(path):
		var stream: Resource = load(path)
		if stream is AudioStream:
			player.stream = stream

func _play_sfx(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	player.stop()
	player.play()

func _show_level_up_popup(suffix: String) -> void:
	if level_up_popup == null:
		return
	level_up_popup.visible = true
	level_up_popup.text = "LEVEL UP! %s" % suffix
	level_up_popup.modulate.a = 0.0
	level_up_popup.scale = Vector2(0.92, 0.92)
	if _popup_tween != null and _popup_tween.is_valid():
		_popup_tween.kill()
	_popup_tween = create_tween()
	_popup_tween.set_trans(Tween.TRANS_QUAD)
	_popup_tween.set_ease(Tween.EASE_OUT)
	_popup_tween.tween_property(level_up_popup, "modulate:a", 1.0, 0.12)
	_popup_tween.parallel().tween_property(level_up_popup, "scale", Vector2(1.02, 1.02), 0.12)
	_popup_tween.tween_interval(0.55)
	_popup_tween.set_ease(Tween.EASE_IN)
	_popup_tween.tween_property(level_up_popup, "modulate:a", 0.0, 0.20)
	_popup_tween.parallel().tween_property(level_up_popup, "scale", Vector2(0.98, 0.98), 0.20)
	_popup_tween.tween_callback(Callable(self, "_hide_level_up_popup"))

func _hide_level_up_popup() -> void:
	if level_up_popup != null:
		level_up_popup.visible = false

func _show_scar_popup(scar: Dictionary) -> void:
	if scar_popup == null:
		return
	var scar_name: String = str(scar.get("name", "Cicatrice"))
	var scar_story: String = str(scar.get("story", ""))
	var text_lines: Array[String] = ["CICATRICE: %s" % scar_name]
	if scar_story != "":
		text_lines.append(scar_story)
	scar_popup.text = "\n".join(text_lines)
	scar_popup.visible = true
	scar_popup.modulate.a = 0.0
	scar_popup.scale = Vector2(0.96, 0.96)
	if _scar_popup_tween != null and _scar_popup_tween.is_valid():
		_scar_popup_tween.kill()
	_scar_popup_tween = create_tween()
	_scar_popup_tween.set_trans(Tween.TRANS_QUAD)
	_scar_popup_tween.set_ease(Tween.EASE_OUT)
	_scar_popup_tween.tween_property(scar_popup, "modulate:a", 1.0, 0.15)
	_scar_popup_tween.parallel().tween_property(scar_popup, "scale", Vector2(1.02, 1.02), 0.15)
	_scar_popup_tween.tween_interval(1.0)
	_scar_popup_tween.set_ease(Tween.EASE_IN)
	_scar_popup_tween.tween_property(scar_popup, "modulate:a", 0.0, 0.25)
	_scar_popup_tween.parallel().tween_property(scar_popup, "scale", Vector2(0.98, 0.98), 0.25)
	_scar_popup_tween.tween_callback(Callable(self, "_hide_scar_popup"))

func _hide_scar_popup() -> void:
	if scar_popup != null:
		scar_popup.visible = false

func _on_buy_token_pressed() -> void:
	if GameEvents.has_signal("request_purchase_token"):
		GameEvents.request_purchase_token.emit()

func _ensure_token_icons() -> void:
	if coins_icon != null and coins_icon.texture == null:
		coins_icon.texture = _make_solid_icon(Color(1.0, 0.85, 0.25, 1.0))
	if tokens_icon != null and tokens_icon.texture == null:
		tokens_icon.texture = _make_solid_icon(Color(0.55, 0.85, 1.0, 1.0))

func _make_solid_icon(c: Color) -> Texture2D:
	var image: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(c)
	for x in range(8):
		image.set_pixel(x, 0, Color(0, 0, 0, 1))
		image.set_pixel(x, 7, Color(0, 0, 0, 1))
	for y in range(8):
		image.set_pixel(0, y, Color(0, 0, 0, 1))
		image.set_pixel(7, y, Color(0, 0, 0, 1))
	return ImageTexture.create_from_image(image)

func show_countdown(seconds: int = 3) -> void:
	if countdown_label == null:
		return
	countdown_label.visible = true
	for i in range(seconds, 0, -1):
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO"
	await get_tree().create_timer(0.5).timeout
	countdown_label.visible = false

func _on_run_started() -> void:
	if coins_label != null:
		coins_label.text = "Coins: 0"
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	if bet_panel != null:
		bet_panel.visible = false
	if level_up_popup != null:
		level_up_popup.visible = false
	_refresh_buy_token_ui()
	# IMPORTANT: if the player picked FAST, we must keep the FAST timer state into the round.
	# countdown_requested will drive the actual seconds during the round.
	if not _fast_countdown_active:
		_reset_fast_countdown()
	else:
		if fast_countdown_label != null:
			fast_countdown_label.visible = true
			fast_countdown_label.text = "FAST: %ds" % FAST_SELECTION_SECONDS
			fast_countdown_label.modulate.a = 1.0
	_set_push_luck_modal(false)
	_pending_bets = []
	if game_over_panel != null:
		game_over_panel.visible = false
	if next_bet_button != null:
		next_bet_button.visible = true
	_last_finale_title = "RUN FAILED"
	_last_finale_text = ""
	_last_finale_scars = []
	_refresh_game_over_scars()
	if not _fast_countdown_active:
		_reset_fast_countdown()
	_refresh_modal_dimmer()

func _on_run_started_ui() -> void:
	_last_level = 1
	_last_tokens = 0
	_last_xp_to_next = 0
	_kill_xp_tweens()
	_xp_current = 0
	if xp_bar != null:
		xp_bar.value = 0
	_refresh_buy_token_ui()
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node != null:
		_bind_player(player_node)

func _on_run_finale_selected(payload: Dictionary) -> void:
	if payload.has("title"):
		_last_finale_title = str(payload["title"])
	else:
		_last_finale_title = "RUN FAILED"
	if payload.has("text"):
		_last_finale_text = str(payload["text"])
	else:
		_last_finale_text = ""
	if payload.has("scars"):
		_last_finale_scars = (payload["scars"] as Array).duplicate(true)
	else:
		_last_finale_scars = []
	_refresh_game_over_scars()
	if game_over_title != null:
		game_over_title.text = _last_finale_title
	if game_over_epilogue != null:
		game_over_epilogue.text = _last_finale_text

func _on_run_failed() -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: -"
	if bet_panel != null:
		bet_panel.visible = false
	if level_up_popup != null:
		level_up_popup.visible = false
	_reset_fast_countdown()
	_set_push_luck_modal(false)
	if game_over_panel != null:
		game_over_panel.visible = true
	if next_bet_button != null:
		next_bet_button.visible = false
	if game_over_title != null:
		game_over_title.text = _last_finale_title
	if game_over_epilogue != null:
		game_over_epilogue.text = _last_finale_text
	_refresh_game_over_scars()
	if game_over_hint != null:
		game_over_hint.text = "Vuoi riprovare?"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
	_reset_fast_countdown()
	_refresh_modal_dimmer()

func _on_betting_opened() -> void:
	if game_over_panel != null and game_over_panel.visible:
		if bet_panel != null:
			bet_panel.visible = false
		return
	if push_luck_panel != null and push_luck_panel.visible:
		return

func _on_countdown_requested(seconds: int) -> void:
	# FAST countdown must be visible during the round ONLY if the player selected FAST.
	if _fast_countdown_active:
		_handle_fast_countdown(mini(seconds, FAST_SELECTION_SECONDS))
		return
	if seconds <= 0:
		return
	if seconds > 3:
		return
	await show_countdown(seconds)

func _on_run_started_controls() -> void:
	if controls_hint_panel == null:
		return
	controls_hint_panel.visible = _controls_first_run_active and (not _has_seen_controls)

func _on_run_failed_controls() -> void:
	if controls_hint_panel != null and _has_seen_controls:
		controls_hint_panel.visible = false

func _on_coins_changed(coins: int) -> void:
	if coins_label != null:
		coins_label.text = "Coins: %d" % coins
	_coins = coins
	_refresh_buy_token_ui()

func _on_bet_placed(bet_id: String, _stake: int, _odds: float) -> void:
	if bet_info_label != null:
		bet_info_label.text = "Bet: %s" % _get_bet_name(bet_id)

func _on_bet_ui_opened(bets: Array) -> void:
	if bet_panel == null:
		return
	if game_over_panel != null and game_over_panel.visible:
		return
	if push_luck_panel != null and push_luck_panel.visible:
		_pending_bets = bets
		return
	_bets_by_id.clear()
	for bet_value: Dictionary in bets:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: String = str(bet.get("id", ""))
		_bets_by_id[bet_id] = bet
	_update_bet_buttons()
	bet_panel.visible = true
	_reset_fast_countdown()
	_refresh_buy_token_ui()
	_refresh_modal_dimmer()

func _on_bet_ui_closed() -> void:
	if bet_panel != null:
		bet_panel.visible = false

func _on_scars_updated(scars: Array) -> void:
	_refresh_scars_ui(scars)

func _on_scar_applied(scar: Dictionary) -> void:
	_show_scar_popup(scar)

func _refresh_scars_ui(scars: Array) -> void:
	if scars_label == null:
		return
	if scars_panel != null:
		scars_panel.visible = true
	if scars.is_empty():
		scars_label.text = "Nessuna cicatrice."
		return
	var lines: Array[String] = []
	for scar_value: Dictionary in scars:
		var scar: Dictionary = scar_value as Dictionary
		var scar_name: String = str(scar.get("name", "Cicatrice"))
		var story: String = str(scar.get("story", ""))
		var origin: String = str(scar.get("origin", ""))
		var effect: String = str(scar.get("effect", ""))
		lines.append("• %s" % scar_name)
		if story != "":
			lines.append("  %s" % story)
		if origin != "":
			lines.append("  Origine: %s" % origin)
		if effect != "":
			lines.append("  Effetto: %s" % effect)
		lines.append("")
	if lines.size() > 0 and lines[lines.size() - 1] == "":
		lines.remove_at(lines.size() - 1)
	scars_label.text = "\n".join(lines)
	# If FAST was selected, keep the FAST countdown state for the round.
	# The label is driven by countdown_requested during the round.
	if not _fast_countdown_active:
		_reset_fast_countdown()
	get_viewport().gui_release_focus()
	_refresh_modal_dimmer()

func _refresh_game_over_scars() -> void:
	if game_over_scars == null:
		return
	if _last_finale_scars.is_empty():
		game_over_scars.text = ""
		game_over_scars.visible = false
		return
	var lines: Array[String] = []
	lines.append("Cicatrici rilevanti:")
	for scar_value: Dictionary in _last_finale_scars:
		var scar: Dictionary = scar_value as Dictionary
		var scar_name: String = "Cicatrice"
		if scar.has("name"):
			scar_name = str(scar["name"])
		lines.append("• %s" % scar_name)
	game_over_scars.text = "\n".join(lines)
	game_over_scars.visible = true

func _on_push_luck_opened(payload: Dictionary) -> void:
	if push_luck_panel == null:
		return
	if bet_panel != null:
		bet_panel.visible = false
	var bet_name: String = str(payload.get("bet_name", ""))
	var current_level: int = int(payload.get("current_level", 1))
	var next_level: int = int(payload.get("next_level", 2))
	if push_luck_title != null:
		push_luck_title.text = "PUSH YOUR LUCK — %s" % bet_name
	if push_luck_info != null:
		push_luck_info.text = "Vittoria x%d → Rischio x%d" % [current_level, next_level]
	var doom_text: String = str(payload.get("next_doom", ""))
	var condition_text: String = str(payload.get("condition", ""))
	var pact_text: String = str(payload.get("next_pact", ""))
	var lines: Array[String] = []
	if doom_text != "":
		lines.append("❌ Condanna futura: %s" % doom_text)
	if condition_text != "":
		lines.append("⚠️ Condizione: %s" % condition_text)
	if pact_text != "":
		lines.append("✅ Patto potenziato: %s" % pact_text)
	if push_luck_details != null:
		push_luck_details.text = "\n".join(lines)
	_set_push_luck_modal(true)

func _on_push_luck_closed() -> void:
	_set_push_luck_modal(false)

func _wire_push_luck_buttons() -> void:
	if push_luck_cashout_button != null:
		var cashout_callable: Callable = Callable(self, "_on_push_luck_cashout_pressed")
		if not push_luck_cashout_button.pressed.is_connected(cashout_callable):
			push_luck_cashout_button.pressed.connect(cashout_callable)
	if push_luck_double_button != null:
		var double_callable: Callable = Callable(self, "_on_push_luck_double_pressed")
		if not push_luck_double_button.pressed.is_connected(double_callable):
			push_luck_double_button.pressed.connect(double_callable)

func _on_push_luck_cashout_pressed() -> void:
	if GameEvents.has_signal("request_push_luck_cashout"):
		GameEvents.request_push_luck_cashout.emit()

func _on_push_luck_double_pressed() -> void:
	if GameEvents.has_signal("request_push_luck_double"):
		GameEvents.request_push_luck_double.emit()

func _on_bet_win_pressed() -> void:
	_place_bet("DOUBLE_OR_DIE")

func _on_bet_no_hit_pressed() -> void:
	_place_bet("FLAWLESS_BLOOD")

func _on_bet_fast_pressed() -> void:
	_place_bet("CASH_OUT")

func _on_restart_pressed() -> void:
	_request_reset()

func _on_retry_pressed() -> void:
	_request_retry()

func _request_reset() -> void:
	if game_over_panel != null:
		game_over_panel.visible = false

	if GameEvents.has_signal("request_reset_run"):
		GameEvents.request_reset_run.emit()
	_refresh_modal_dimmer()

func _request_next_bet() -> void:
	if game_over_panel != null and game_over_panel.visible:
		return

	if GameEvents.has_signal("request_next_bet"):
		GameEvents.request_next_bet.emit()

func _request_retry() -> void:
	if game_over_panel != null:
		game_over_panel.visible = false
	if GameEvents.has_signal("request_retry_run"):
		GameEvents.request_retry_run.emit()
	_refresh_modal_dimmer()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_player_health_changed(current: int, max_value: int) -> void:
	player_hp_bar.max_value = max_value
	player_hp_bar.value = current
	player_hp_label.text = "HP: %d/%d" % [current, max_value]

func _handle_fast_countdown(seconds: int) -> void:
	if fast_countdown_label == null:
		return
	if not _fast_countdown_active:
		_stop_fast_blink()
		fast_countdown_label.visible = false
		return
	if seconds <= 0:
		_reset_fast_countdown()
		return
	fast_countdown_label.visible = true
	fast_countdown_label.text = "FAST: %ds" % seconds
	if seconds <= 5:
		_start_fast_blink()
	else:
		_stop_fast_blink()
		fast_countdown_label.modulate.a = 1.0

func _start_fast_blink() -> void:
	if fast_blink_timer == null:
		return
	if not fast_blink_timer.is_stopped():
		return
	fast_blink_timer.start()

func _stop_fast_blink() -> void:
	if fast_blink_timer != null and not fast_blink_timer.is_stopped():
		fast_blink_timer.stop()
	if fast_countdown_label != null:
		fast_countdown_label.modulate.a = 1.0

func _on_fast_blink_tick() -> void:
	if fast_countdown_label == null:
		return
	var next_alpha: float = 1.0
	if fast_countdown_label.modulate.a > 0.6:
		next_alpha = 0.2
	fast_countdown_label.modulate.a = next_alpha

func _on_player_spawned(p: Node) -> void:
	_bind_player(p)

func _bind_player(p: Node) -> void:
	if _player != null and _player.has_signal("health_changed"):
		var health_callable: Callable = Callable(self, "_on_player_health_changed")
		if _player.health_changed.is_connected(health_callable):
			_player.health_changed.disconnect(health_callable)

	_player = p

	if _player != null and _player.has_signal("health_changed"):
		var health_callable: Callable = Callable(self, "_on_player_health_changed")
		if not _player.health_changed.is_connected(health_callable):
			_player.health_changed.connect(health_callable)

	if _player != null and _player.has_method("get_health"):
		var h: Array = _player.call("get_health")
		if h.size() >= 2:
			_on_player_health_changed(int(h[0]), int(h[1]))

func _update_bet_buttons() -> void:
	if bet_win_button == null or bet_no_hit_button == null or bet_fast_button == null:
		return
	bet_win_button.disabled = false
	bet_no_hit_button.disabled = false
	bet_fast_button.disabled = false
	bet_win_button.mouse_filter = Control.MOUSE_FILTER_STOP
	bet_no_hit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	bet_fast_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_set_bet_button_text(bet_win_button, "DOUBLE_OR_DIE")
	_set_bet_button_text(bet_no_hit_button, "FLAWLESS_BLOOD")
	_set_bet_button_text(bet_fast_button, "CASH_OUT")
	_apply_bet_button_style(bet_win_button, "DOUBLE_OR_DIE")
	_apply_bet_button_style(bet_no_hit_button, "FLAWLESS_BLOOD")
	_apply_bet_button_style(bet_fast_button, "CASH_OUT")

func _set_bet_button_text(button: Button, bet_id: String) -> void:
	if not _bets_by_id.has(bet_id):
		button.text = bet_id
		return
	var bet: Dictionary = _bets_by_id.get(bet_id, {}) as Dictionary
	if bet.is_empty():
		push_warning("Bet id not found: %s" % bet_id)
		return
	var name_text: String = str(bet.get("name", bet_id))
	var condition_text: String = str(bet.get("condition", ""))
	var pact_text: String = str(bet.get("pact", ""))
	var doom_text: String = str(bet.get("doom", ""))
	var lines: Array[String] = []
	if doom_text != "":
		lines.append("❌ %s — Condanna: %s" % [name_text, doom_text])
	else:
		lines.append("❌ %s — Condanna" % name_text)
	if condition_text != "":
		lines.append("⚠️ Condizione: %s" % condition_text)
	if pact_text != "":
		lines.append("✅ Patto: %s" % pact_text)
	button.text = "\n".join(lines)

func _apply_bet_button_style(button: Button, bet_id: String) -> void:
	if button == null:
		return
	if bet_id == "DOUBLE_OR_DIE":
		button.modulate = Color(1.0, 0.75, 0.75, 1.0)
		button.add_theme_color_override("font_color", Color(0.75, 0.05, 0.05, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.9, 0.2, 0.2, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.9, 0.2, 0.2, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.35, 0.35, 1.0))
		return
	if bet_id == "FLAWLESS_BLOOD":
		button.modulate = Color(1.0, 0.95, 0.8, 1.0)
		button.add_theme_color_override("font_color", Color(0.6, 0.45, 0.0, 1.0))
		button.add_theme_color_override("font_hover_color", Color(0.75, 0.55, 0.1, 1.0))
		button.add_theme_color_override("font_focus_color", Color(0.75, 0.55, 0.1, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(0.9, 0.65, 0.15, 1.0))
		return
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.remove_theme_color_override("font_color")
	button.remove_theme_color_override("font_hover_color")
	button.remove_theme_color_override("font_focus_color")
	button.remove_theme_color_override("font_pressed_color")

func _on_bet_failed(can_retry: bool) -> void:
	if bet_panel != null:
		bet_panel.visible = false
	_reset_fast_countdown()
	if game_over_panel != null:
		game_over_panel.visible = true
	if game_over_title != null:
		game_over_title.text = "RUN FAILED"
		if can_retry:
			game_over_title.text = "BET FAILED"
	if game_over_epilogue != null:
		game_over_epilogue.text = ""
	_last_finale_text = ""
	_last_finale_scars = []
	_refresh_game_over_scars()
	if game_over_hint != null:
		game_over_hint.text = "Vuoi riprovare?"
		if can_retry:
			game_over_hint.text = "Riprova la scommessa?"
	if next_bet_button != null:
		next_bet_button.visible = can_retry
		next_bet_button.text = "RETRY BET"
	if restart_button != null:
		restart_button.text = "RESTART RUN"
	_reset_fast_countdown()

func _place_bet(bet_id: String) -> void:
	_selected_bet_id = bet_id
	_reset_fast_countdown()
	if GameEvents.has_signal("request_place_bet"):
		GameEvents.request_place_bet.emit(bet_id, 0)

func _get_bet_name(bet_id: String) -> String:
	if not _bets_by_id.has(bet_id):
		return bet_id
	var bet: Dictionary = _bets_by_id.get(bet_id, {}) as Dictionary
	if bet.is_empty():
		return bet_id
	return str(bet.get("name", bet_id))

func _set_push_luck_modal(active: bool) -> void:
	if push_luck_panel != null:
		push_luck_panel.visible = active
	if active:
		if GameEvents.has_signal("modal_opened"):
			GameEvents.modal_opened.emit("push_luck")
	else:
		if GameEvents.has_signal("modal_closed"):
			GameEvents.modal_closed.emit("push_luck")
	_refresh_modal_dimmer()
	get_viewport().gui_release_focus()

func _refresh_modal_dimmer() -> void:
	if modal_dimmer == null:
		return
	var active: bool = false
	if bet_panel != null and bet_panel.visible:
		active = true
	if push_luck_panel != null and push_luck_panel.visible:
		active = true
	if game_over_panel != null and game_over_panel.visible:
		active = true
	modal_dimmer.visible = active
	modal_dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _reset_fast_countdown() -> void:
	_selected_bet_id = ""
	_fast_countdown_active = false
	_stop_fast_blink()
	if fast_countdown_label != null:
		fast_countdown_label.visible = false

func _process(_delta: float) -> void:
	if debug_overlay == null or not debug_overlay.visible:
		return
	var fps: int = Engine.get_frames_per_second()
	var arena_index: int = _get_arena_index()
	var enemies_alive: int = _get_enemies_alive()
	var bet_active: bool = _is_bet_active()
	debug_overlay.text = "FPS: %d\nArena: %d\nEnemies: %d\nBet active: %s" % [
		fps,
		arena_index,
		enemies_alive,
		str(bet_active)
	]

func _unhandled_input(event: InputEvent) -> void:
	if _controls_first_run_active and (not _has_seen_controls) and controls_hint_panel != null and controls_hint_panel.visible:
		var should_dismiss: bool = false
		if event is InputEventKey and event.pressed and not event.echo:
			should_dismiss = true
		elif event is InputEventMouseButton and event.pressed:
			should_dismiss = true
		elif event is InputEventJoypadButton and event.pressed:
			should_dismiss = true
		if should_dismiss:
			_has_seen_controls = true
			_controls_first_run_active = false
			controls_hint_panel.visible = false
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		if debug_overlay != null:
			debug_overlay.visible = not debug_overlay.visible

func _req(path: String) -> Node:
	var n: Node = get_node_or_null(path)
	if n == null:
		push_error("UI missing node at path: %s" % path)
	return n

func _get_run_manager() -> Node:
	if _run_manager and is_instance_valid(_run_manager):
		return _run_manager
	_run_manager = get_tree().get_first_node_in_group("run_manager")
	return _run_manager

func _get_arena() -> Node:
	if _arena and is_instance_valid(_arena):
		return _arena
	var manager: Node = _get_run_manager()
	if manager and manager.has_method("get_arena"):
		_arena = manager.get_arena()
	if _arena:
		return _arena
	_arena = get_tree().get_first_node_in_group("arena")
	return _arena

func _get_arena_index() -> int:
	var manager: Node = _get_run_manager()
	if manager and manager.has_method("get_arena_index"):
		return manager.get_arena_index()
	return 0

func _get_enemies_alive() -> int:
	var arena: Node = _get_arena()
	if arena and arena.has_method("get_enemies_remaining"):
		return int(arena.get_enemies_remaining())
	return 0

func _is_bet_active() -> bool:
	var manager: Node = _get_bet_manager()
	if manager and manager.has_method("is_bet_active"):
		return manager.is_bet_active()
	return false

func _get_bet_manager() -> Node:
	if _bet_manager and is_instance_valid(_bet_manager):
		return _bet_manager
	_bet_manager = get_tree().get_first_node_in_group("bet_manager")
	return _bet_manager
