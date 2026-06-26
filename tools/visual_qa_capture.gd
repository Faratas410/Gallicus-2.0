extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const OUTPUT_DIR: String = "res://artifacts/visual_qa"
const VIEWPORT_SIZE: Vector2i = Vector2i(1280, 720)

var _main: Node = null
var _failures: PackedStringArray = PackedStringArray()

func _ready() -> void:
	get_tree().root.size = VIEWPORT_SIZE
	call_deferred("_run")

func _run() -> void:
	_prepare_output_dir()
	if get_node_or_null("UI") != null and get_node_or_null("RunManager") != null:
		_main = self
	else:
		_main = MAIN_SCENE.instantiate()
		get_tree().root.add_child(_main)
	await _settle(20)
	await _capture("01_menu")

	await _press_when_ready("Main/MenuLayer/MainMenu/CenterContainer/MenuVBox/NewGameButton", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/BettingCircle", true, 4.0)
	await _settle(12)
	await _capture("02_register_closed")

	await _press_when_ready("Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book", 4.0)
	await _settle(360)
	await _wait_button_enabled("Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/LeftPage/Btn_Sign_Left", 6.0)
	await _capture("03_register_open")

	await _press_preferred_sign_button()
	await _wait_visible("Main/UI/UI_RunRoot/Phase_FIRST_REACTION", true, 4.0)
	await _settle(60)
	await _capture("04_pact_signed")

	await _press_when_ready("Main/UI/UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Btn_FIRST_REACTION_NEXT", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_MID_CHOICE", true, 4.0)
	await _settle(24)
	await _capture("05_intermediate_choice")

	await _press_when_ready("Main/UI/UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_RESOLUTION", true, 4.0)
	await _settle(60)
	await _capture("06_resolve_ritual")

	for i: int in range(3):
		await _press_when_ready("Main/UI/UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Btn_RESOLUTION_STRIKE", 4.0)
		await _settle(18)
	await _press_when_ready("Main/UI/UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Btn_RESOLUTION_NEXT", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK", true, 4.0)
	await _settle(90)
	await _capture("07_push_your_luck")

	await _press_when_ready("Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Btn_PUSH_YOUR_LUCK_CONDANNA", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_END_RUN", true, 5.0)
	await _settle(240)
	await _capture("08_end_run")

	if _failures.is_empty():
		print("VISUAL_QA:OK output=%s" % ProjectSettings.globalize_path(OUTPUT_DIR))
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("VISUAL_QA:FAILED failures=%d output=%s" % [_failures.size(), ProjectSettings.globalize_path(OUTPUT_DIR)])
		get_tree().quit(1)

func _prepare_output_dir() -> void:
	var absolute_path: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	var err: int = DirAccess.make_dir_recursive_absolute(absolute_path)
	if err != OK:
		_failures.append("Could not create visual QA output directory: %s err=%d" % [absolute_path, err])

func _capture(name: String) -> void:
	await _settle(2)
	var image: Image = get_tree().root.get_texture().get_image()
	var path: String = "%s/%s.png" % [OUTPUT_DIR, name]
	var err: int = image.save_png(path)
	if err != OK:
		_failures.append("Could not save screenshot %s err=%d" % [path, err])
	else:
		print("VISUAL_QA:CAPTURE=%s" % ProjectSettings.globalize_path(path))

func _emit_game_event(signal_name: StringName) -> void:
	if GameEvents == null or not GameEvents.has_signal(signal_name):
		_failures.append("Missing GameEvents signal: %s" % String(signal_name))
		return
	GameEvents.emit_signal(signal_name)

func _press_when_ready(path: String, timeout_seconds: float) -> void:
	var timeout_msec: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_msec:
		var button: Button = get_tree().root.get_node_or_null(path) as Button
		if button != null and button.visible and not button.disabled:
			button.emit_signal("pressed")
			return
		await get_tree().process_frame
	_failures.append("Button not ready: %s" % path)

func _wait_button_enabled(path: String, timeout_seconds: float) -> void:
	var timeout_msec: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_msec:
		var button: Button = get_tree().root.get_node_or_null(path) as Button
		if button != null and button.visible and not button.disabled:
			return
		await get_tree().process_frame
	_failures.append("Button did not become enabled: %s" % path)

func _press_preferred_sign_button() -> void:
	var circle: Node = get_tree().root.get_node_or_null("Main/UI/UI_RunRoot/BettingCircle")
	if circle == null:
		_failures.append("BettingCircle missing for preferred sign selection")
		return
	var left_id: String = String(circle.call("_offer_id_at", 0))
	var right_id: String = String(circle.call("_offer_id_at", 1))
	var sign_path: String = "Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/LeftPage/Btn_Sign_Left"
	if left_id == "BET_DOUBLE_OR_DIE" and right_id != "":
		sign_path = "Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/RightPage/Btn_Sign_Right"
	await _press_when_ready(sign_path, 4.0)

func _wait_visible(path: String, expected: bool, timeout_seconds: float) -> void:
	var timeout_msec: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_msec:
		var canvas_item: CanvasItem = get_tree().root.get_node_or_null(path) as CanvasItem
		if canvas_item != null and canvas_item.visible == expected:
			return
		await get_tree().process_frame
	_failures.append("Visibility timeout: %s expected=%s" % [path, str(expected)])

func _settle(frame_count: int) -> void:
	for i: int in range(frame_count):
		await get_tree().process_frame
