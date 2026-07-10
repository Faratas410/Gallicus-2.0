extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/Main.tscn")
const OUTPUT_DIR: String = "res://artifacts/visual_qa"
const VIEWPORT_SIZE: Vector2i = Vector2i(1280, 720)
const RECEIPT_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const RECEIPT_LOCALES: Array[String] = ["it", "en", "es"]
const RECEIPT_BUTTON_PATH: String = "Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Btn_PUSH_YOUR_LUCK_CASHOUT"
const RECEIPT_NOTE_PATH: String = "Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Lbl_PUSH_YOUR_LUCK_CHOICE_0Panel/Lbl_PUSH_YOUR_LUCK_CHOICE_0"
const MARK_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const MARK_LOCALES: Array[String] = ["it", "en", "es"]
const MARK_BUTTON_PATH: String = "Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Btn_PUSH_YOUR_LUCK_CONDANNA"
const MARK_NOTE_PATH: String = "Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Lbl_PUSH_YOUR_LUCK_CHOICE_1Panel/Lbl_PUSH_YOUR_LUCK_CHOICE_1"
const INCISION_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const INCISION_LOCALES: Array[String] = ["it", "en", "es"]
const INCISION_BUTTON_PATH: String = "Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Btn_PUSH_YOUR_LUCK_DOUBLE"
const INCISION_NOTE_PATH: String = "Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICEPanel/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICE"
const UI_ROOT_PATH: String = "Main/UI"

var _main: Node = null
var _failures: PackedStringArray = PackedStringArray()

func _ready() -> void:
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	get_tree().root.content_scale_size = VIEWPORT_SIZE
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
	await _capture_receipt_matrix()
	await _capture_condemnation_mark_matrix()
	await _capture_second_incision_matrix()

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

func _capture(name: String, expected_size: Vector2i = Vector2i.ZERO) -> void:
	await _settle(2)
	var viewport_texture: ViewportTexture = get_tree().root.get_texture()
	if viewport_texture == null:
		_failures.append("Viewport texture unavailable for screenshot %s" % name)
		return
	var image: Image = viewport_texture.get_image()
	if image == null:
		_failures.append("Viewport image unavailable for screenshot %s" % name)
		return
	if expected_size != Vector2i.ZERO and image.get_size() != expected_size:
		_failures.append(
			"Screenshot %s has size %s, expected %s" % [
				name,
				str(image.get_size()),
				str(expected_size),
			]
		)
		return
	var path: String = "%s/%s.png" % [OUTPUT_DIR, name]
	var err: int = image.save_png(path)
	if err != OK:
		_failures.append("Could not save screenshot %s err=%d" % [path, err])
	else:
		print("VISUAL_QA:CAPTURE=%s" % ProjectSettings.globalize_path(path))

func _capture_receipt_matrix() -> void:
	var button: Button = get_tree().root.get_node_or_null(RECEIPT_BUTTON_PATH) as Button
	var note: Label = get_tree().root.get_node_or_null(RECEIPT_NOTE_PATH) as Label
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if button == null or note == null or ui_root == null:
		_failures.append("OF-01 receipt nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_disabled: bool = button.disabled
	var previous_note_text: String = note.text
	var previous_note_visible: bool = note.visible

	for locale: String in RECEIPT_LOCALES:
		TranslationServer.set_locale(locale)
		await _settle(8)
		for viewport_size: Vector2i in RECEIPT_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "07_receipt_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			ui_root.call("_set_receipt_taken_state", false)
			button.disabled = false
			button.release_focus()
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_normal" % prefix, viewport_size)

			button.grab_focus()
			await _settle(20)
			await _capture("%s_focus" % prefix, viewport_size)

			button.release_focus()
			button.disabled = true
			note.text = tr("Disponibile dopo l'arena in corso.")
			note.visible = true
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_disabled" % prefix, viewport_size)

	button.disabled = previous_disabled
	note.text = previous_note_text
	note.visible = previous_note_visible
	ui_root.call("_set_receipt_taken_state", false)
	ui_root.call("_apply_push_luck_button_visual", button)
	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	await _settle(8)

func _capture_condemnation_mark_matrix() -> void:
	var button: Button = get_tree().root.get_node_or_null(MARK_BUTTON_PATH) as Button
	var note: Label = get_tree().root.get_node_or_null(MARK_NOTE_PATH) as Label
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if button == null or note == null or ui_root == null:
		_failures.append("OF-02 condemnation mark nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_disabled: bool = button.disabled
	var previous_note_text: String = note.text
	var previous_note_visible: bool = note.visible

	for locale: String in MARK_LOCALES:
		TranslationServer.set_locale(locale)
		await _settle(8)
		for viewport_size: Vector2i in MARK_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "07_mark_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			ui_root.call("_set_condemnation_mark_registered_state", false)
			button.disabled = false
			button.release_focus()
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_normal" % prefix, viewport_size)

			button.grab_focus()
			await _settle(20)
			await _capture("%s_focus" % prefix, viewport_size)

			button.release_focus()
			button.disabled = true
			note.visible = true
			ui_root.call("_set_condemnation_mark_registered_state", true)
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_registered" % prefix, viewport_size)

	button.disabled = previous_disabled
	note.text = previous_note_text
	note.visible = previous_note_visible
	ui_root.call("_set_condemnation_mark_registered_state", false)
	ui_root.call("_apply_push_luck_button_visual", button)
	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	await _settle(8)

func _capture_second_incision_matrix() -> void:
	var button: Button = get_tree().root.get_node_or_null(INCISION_BUTTON_PATH) as Button
	var note: Label = get_tree().root.get_node_or_null(INCISION_NOTE_PATH) as Label
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if button == null or note == null or ui_root == null:
		_failures.append("OF-03 second incision nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_disabled: bool = button.disabled
	var previous_note_text: String = note.text
	var previous_note_visible: bool = note.visible

	for locale: String in INCISION_LOCALES:
		TranslationServer.set_locale(locale)
		await _settle(8)
		for viewport_size: Vector2i in INCISION_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "07_incision_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			ui_root.call("_set_second_incision_sealed_state", false)
			button.disabled = false
			note.text = tr("Prossima posta +%d Gloria | Pressione +%d") % [2, 1]
			note.visible = true
			button.release_focus()
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_normal" % prefix, viewport_size)

			button.grab_focus()
			await _settle(20)
			await _capture("%s_focus" % prefix, viewport_size)

			button.release_focus()
			ui_root.call("_set_second_incision_sealed_state", false)
			button.disabled = true
			note.text = tr("Disponibile dopo l'arena in corso.")
			note.visible = true
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_disabled" % prefix, viewport_size)

			ui_root.call("_set_second_incision_sealed_state", true)
			button.disabled = true
			note.text = tr("Prossima posta +%d Gloria | Pressione +%d") % [2, 1]
			note.visible = true
			ui_root.call("_apply_push_luck_button_visual", button)
			await _capture("%s_sealed" % prefix, viewport_size)

	button.disabled = previous_disabled
	note.text = previous_note_text
	note.visible = previous_note_visible
	ui_root.call("_set_second_incision_sealed_state", false)
	ui_root.call("_apply_push_luck_button_visual", button)
	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	await _settle(8)

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
