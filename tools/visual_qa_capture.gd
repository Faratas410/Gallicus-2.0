extends Node

const MAIN_SCENE_PATH: String = "res://scenes/Main.tscn"
const OUTPUT_DIR: String = "res://artifacts/visual_qa"
const CANONICAL_VISUAL_QA_SEED: String = "1782373819"
const CAPTURE_ENVIRONMENT_KEYS: Array[String] = [
	"GALLICUS_SMOKE",
	"GALLICUS_SMOKE_SCENARIO",
	"GALLICUS_SMOKE_SEED",
]
const VIEWPORT_SIZE: Vector2i = Vector2i(1280, 720)
const THRESHOLD_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const THRESHOLD_LOCALES: Array[String] = ["it", "en", "es"]
const THRESHOLD_BUTTON_PATH: String = "Main/MenuLayer/MainMenu/CenterContainer/MenuVBox/NewGameButton"
const MAIN_MENU_PATH: String = "Main/MenuLayer/MainMenu"
const ACCESSIBILITY_SETTINGS_SECTION: String = "accessibility_settings"
const SETTINGS_PANEL_PATH: String = "Main/MenuLayer/MainMenu/SettingsPanel"
const SETTINGS_SFX_SLIDER_PATH: String = "Main/MenuLayer/MainMenu/SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/SfxVolumeSlider"
const SETTINGS_REDUCED_MOTION_PATH: String = "Main/MenuLayer/MainMenu/SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ReducedMotionToggle"
const ACCESSIBILITY_SETTINGS_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const ACCESSIBILITY_SETTINGS_LOCALES: Array[String] = ["it", "en", "es"]
const REGISTRY_TABLE_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const REGISTRY_TABLE_LOCALES: Array[String] = ["it", "en", "es"]
const REGISTRY_TABLE_PATH: String = "Main/UI/UI_RunRoot/BettingCircle"
const REGISTRY_TABLE_BUTTON_PATH: String = "Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book"
const PROMISE_SIGNATURE_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const PROMISE_SIGNATURE_LOCALES: Array[String] = ["it", "en", "es"]
const PROMISE_SIGNATURE_LEFT_PATH: String = "Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/LeftPage/Btn_Sign_Left"
const PROMISE_SIGNATURE_RIGHT_PATH: String = "Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/RightPage/Btn_Sign_Right"
const PACT_TABLET_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const PACT_TABLET_LOCALES: Array[String] = ["it", "en", "es"]
const PACT_TABLET_BUTTON_PATH: String = "Main/UI/UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Btn_FIRST_REACTION_NEXT"
const PACT_TABLET_SECTION: String = "pact_tablet"
const GESTURE_CHOICE_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const GESTURE_CHOICE_LOCALES: Array[String] = ["it", "en", "es"]
const GESTURE_CHOICE_PLACA_PATH: String = "Main/UI/UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0"
const GESTURE_CHOICE_PROVOCA_PATH: String = "Main/UI/UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_1"
const GESTURE_CHOICE_SECTION: String = "gesture_choice"
const JUDGMENT_SEAL_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const JUDGMENT_SEAL_LOCALES: Array[String] = ["it", "en", "es"]
const JUDGMENT_SEAL_BUTTON_PATH: String = "Main/UI/UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Btn_RESOLUTION_STRIKE"
const JUDGMENT_SEAL_PANEL_PATH: String = "Main/UI/UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION"
const JUDGMENT_SEAL_SECTION: String = "judgment_seal"
const FINAL_DOSSIER_VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]
const FINAL_DOSSIER_LOCALES: Array[String] = ["it", "en", "es"]
const FINAL_DOSSIER_PANEL_PATH: String = "Main/UI/UI_RunRoot/Phase_END_RUN/Panel_END_RUN"
const FINAL_DOSSIER_RESTART_PATH: String = "Main/UI/UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_RESTART"
const FINAL_DOSSIER_NEXT_BET_PATH: String = "Main/UI/UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_NEXT_BET"
const FINAL_DOSSIER_QUIT_PATH: String = "Main/UI/UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_QUIT"
const FINAL_DOSSIER_SECTION: String = "final_dossier"
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
var _main_scene: PackedScene = null
var _failures: PackedStringArray = PackedStringArray()
var _capture_section: String = ""
var _capture_environment_snapshot: Dictionary = {}
var _capture_environment_saved: bool = false

func _ready() -> void:
	_snapshot_and_neutralize_capture_environment()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--section="):
			_capture_section = argument.trim_prefix("--section=").strip_edges().to_lower()
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	get_tree().root.content_scale_size = VIEWPORT_SIZE
	get_tree().root.size = VIEWPORT_SIZE
	call_deferred("_run")

func _run() -> void:
	_prepare_output_dir()
	var pact_tablet_only: bool = _capture_section == PACT_TABLET_SECTION
	var gesture_choice_only: bool = _capture_section == GESTURE_CHOICE_SECTION
	var judgment_seal_only: bool = _capture_section == JUDGMENT_SEAL_SECTION
	var final_dossier_only: bool = _capture_section == FINAL_DOSSIER_SECTION
	var accessibility_settings_only: bool = _capture_section == ACCESSIBILITY_SETTINGS_SECTION
	var targeted_section: bool = pact_tablet_only or gesture_choice_only or judgment_seal_only or final_dossier_only or accessibility_settings_only
	if get_node_or_null("UI") != null and get_node_or_null("RunManager") != null:
		_main = self
	else:
		_main_scene = ResourceLoader.load(MAIN_SCENE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
		if _main_scene == null:
			_failures.append("Could not load main scene for visual QA: %s" % MAIN_SCENE_PATH)
			await _finish_capture_run()
			return
		_main = _main_scene.instantiate()
		get_tree().root.add_child(_main)
	await _settle(20)
	if not targeted_section:
		await _capture_arena_threshold_matrix()
		await _capture("01_menu")
	if not targeted_section or accessibility_settings_only:
		await _capture_accessibility_settings_matrix()
	if accessibility_settings_only:
		await _finish_capture_run()
		return

	_enable_deterministic_run_seed()
	await _press_when_ready("Main/MenuLayer/MainMenu/CenterContainer/MenuVBox/NewGameButton", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/BettingCircle", true, 4.0)
	_disable_capture_overrides()
	await _settle(12)
	if not targeted_section:
		await _capture_registry_table_matrix()
		await _capture("02_register_closed")

	await _press_when_ready("Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book", 4.0)
	await _settle(360)
	await _wait_button_enabled("Main/UI/UI_RunRoot/BettingCircle/CenterContainer/BookFrame/LeftPage/Btn_Sign_Left", 6.0)
	if not targeted_section:
		await _capture_promise_signature_matrix()
		await _capture("03_register_open")

	await _press_preferred_sign_button()
	await _wait_visible("Main/UI/UI_RunRoot/Phase_FIRST_REACTION", true, 4.0)
	await _settle(60)
	if not targeted_section or pact_tablet_only:
		await _capture_pact_tablet_matrix()
	if pact_tablet_only:
		await _finish_capture_run()
		return
	if not targeted_section:
		await _capture("04_pact_signed")

	await _press_when_ready("Main/UI/UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Btn_FIRST_REACTION_NEXT", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_MID_CHOICE", true, 4.0)
	await _settle(24)
	if not targeted_section or gesture_choice_only:
		await _capture_gesture_choice_matrix()
	if gesture_choice_only:
		await _finish_capture_run()
		return
	if not targeted_section:
		await _capture("05_intermediate_choice")

	await _press_when_ready("Main/UI/UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_RESOLUTION", true, 4.0)
	_enable_favorable_capture_outcome()
	await _settle(60)
	if not targeted_section or judgment_seal_only:
		await _capture_judgment_seal_matrix()
	if judgment_seal_only:
		await _finish_capture_run()
		return
	if not targeted_section:
		await _capture("06_resolve_ritual")

	for i: int in range(3):
		await _press_when_ready("Main/UI/UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Btn_RESOLUTION_STRIKE", 4.0)
		await _settle(18)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK", true, 4.0)
	_disable_capture_overrides()
	await _settle(90)
	if not targeted_section:
		await _capture("07_push_your_luck")
		await _capture_receipt_matrix()
		await _capture_condemnation_mark_matrix()
		await _capture_second_incision_matrix()

	await _press_when_ready("Main/UI/UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Btn_PUSH_YOUR_LUCK_CONDANNA", 4.0)
	await _wait_visible("Main/UI/UI_RunRoot/Phase_END_RUN", true, 5.0)
	await _settle(240)
	await _capture_final_dossier_matrix()
	if not targeted_section:
		await _capture("08_end_run")

	await _finish_capture_run()

func _capture_accessibility_settings_matrix() -> void:
	var main_menu: Node = get_tree().root.get_node_or_null(MAIN_MENU_PATH)
	var settings_panel: Control = get_tree().root.get_node_or_null(SETTINGS_PANEL_PATH) as Control
	var sfx_slider: HSlider = get_tree().root.get_node_or_null(SETTINGS_SFX_SLIDER_PATH) as HSlider
	var reduced_motion_toggle: CheckBox = get_tree().root.get_node_or_null(SETTINGS_REDUCED_MOTION_PATH) as CheckBox
	if main_menu == null or settings_panel == null or sfx_slider == null or reduced_motion_toggle == null:
		_failures.append("CP-02 settings nodes missing for visual QA matrix")
		return
	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_reduced_motion: bool = SaveManager.get_reduced_motion()
	var previous_processing: bool = main_menu.is_processing()
	main_menu.set_process(false)
	main_menu.call("_on_settings_pressed")
	await _settle(12)
	for locale: String in ACCESSIBILITY_SETTINGS_LOCALES:
		SaveManager.set_language(locale)
		TranslationServer.set_locale(locale)
		main_menu.call("_refresh_localized_ui")
		await _settle(8)
		for viewport_size: Vector2i in ACCESSIBILITY_SETTINGS_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "09_settings_%s_%dx%d" % [locale, viewport_size.x, viewport_size.y]

			reduced_motion_toggle.set_pressed_no_signal(false)
			main_menu.call("_on_reduced_motion_toggled", false)
			sfx_slider.release_focus()
			await _settle(8)
			await _capture("%s_standard" % prefix, viewport_size)

			sfx_slider.grab_focus()
			await _settle(12)
			await _capture("%s_focus_sfx" % prefix, viewport_size)

			sfx_slider.release_focus()
			reduced_motion_toggle.set_pressed_no_signal(true)
			main_menu.call("_on_reduced_motion_toggled", true)
			await _settle(8)
			await _capture("%s_reduced" % prefix, viewport_size)

	reduced_motion_toggle.set_pressed_no_signal(previous_reduced_motion)
	main_menu.call("_on_reduced_motion_toggled", previous_reduced_motion)
	SaveManager.set_language(previous_locale)
	TranslationServer.set_locale(previous_locale)
	main_menu.call("_refresh_localized_ui")
	main_menu.call("_on_settings_back_pressed")
	main_menu.set_process(previous_processing)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	await _settle(8)

func _finish_capture_run() -> void:
	await _cleanup_capture_scene()
	if _failures.is_empty():
		print("VISUAL_QA:OK output=%s" % ProjectSettings.globalize_path(OUTPUT_DIR))
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		print("VISUAL_QA:FAILED failures=%d output=%s" % [_failures.size(), ProjectSettings.globalize_path(OUTPUT_DIR)])
		get_tree().quit(1)

func _cleanup_capture_scene() -> void:
	if _main != null and _main != self and is_instance_valid(_main):
		_main.queue_free()
		_main = null
		await _settle(16)
	_main_scene = null
	_restore_capture_environment()
	await _settle(4)

func _snapshot_and_neutralize_capture_environment() -> void:
	if _capture_environment_saved:
		return
	for key: String in CAPTURE_ENVIRONMENT_KEYS:
		_capture_environment_snapshot[key] = {
			"present": OS.has_environment(key),
			"value": OS.get_environment(key),
		}
		OS.unset_environment(key)
	_capture_environment_saved = true

func _enable_deterministic_run_seed() -> void:
	# Enable smoke seed lookup only while RunManager creates this run.
	OS.set_environment("GALLICUS_SMOKE", "1")
	OS.set_environment("GALLICUS_SMOKE_SEED", CANONICAL_VISUAL_QA_SEED)

func _enable_favorable_capture_outcome() -> void:
	# The resolve ritual is already open, so its smoke shortcut cannot activate.
	# The existing favorable outcome override only stabilizes the later result.
	OS.set_environment("GALLICUS_SMOKE", "1")
	OS.set_environment("GALLICUS_SMOKE_SCENARIO", "FULL_RUN")
	OS.set_environment("GALLICUS_SMOKE_SEED", CANONICAL_VISUAL_QA_SEED)

func _disable_capture_overrides() -> void:
	for key: String in CAPTURE_ENVIRONMENT_KEYS:
		OS.unset_environment(key)

func _restore_capture_environment() -> void:
	if not _capture_environment_saved:
		return
	for key: String in CAPTURE_ENVIRONMENT_KEYS:
		var snapshot: Dictionary = _capture_environment_snapshot.get(key, {}) as Dictionary
		if bool(snapshot.get("present", false)):
			OS.set_environment(key, str(snapshot.get("value", "")))
		else:
			OS.unset_environment(key)
	_capture_environment_snapshot.clear()
	_capture_environment_saved = false

func _capture_pact_tablet_matrix() -> void:
	var button: Button = get_tree().root.get_node_or_null(PACT_TABLET_BUTTON_PATH) as Button
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if button == null or ui_root == null:
		_failures.append("OF-07 pact tablet nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_disabled: bool = button.disabled
	var previous_validated: bool = bool(button.get_meta(&"registry_pact_tablet_validated", false))

	for locale: String in PACT_TABLET_LOCALES:
		TranslationServer.set_locale(locale)
		ui_root.call("_on_pact_sealed_opened")
		await _settle(8)
		for viewport_size: Vector2i in PACT_TABLET_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "04_pact_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			ui_root.call("_set_pact_tablet_validated_state", false)
			button.disabled = false
			button.release_focus()
			_touch_runtime_watchdog_for_pact_matrix()
			await _capture("%s_normal" % prefix, viewport_size)

			button.grab_focus()
			_touch_runtime_watchdog_for_pact_matrix()
			await _capture("%s_focus" % prefix, viewport_size)

			ui_root.call("_set_pact_tablet_validated_state", true)
			button.disabled = true
			_touch_runtime_watchdog_for_pact_matrix()
			await _capture("%s_validated" % prefix, viewport_size)

			ui_root.call("_set_pact_tablet_validated_state", false)
			button.disabled = true
			_touch_runtime_watchdog_for_pact_matrix()
			await _capture("%s_disabled" % prefix, viewport_size)

	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	ui_root.call("_set_pact_tablet_validated_state", previous_validated)
	button.disabled = previous_disabled
	button.release_focus()
	await _settle(8)

func _touch_runtime_watchdog_for_pact_matrix() -> void:
	if _main == null:
		return
	var run_manager: Node = _main.get_node_or_null("RunManager")
	if run_manager != null and run_manager.has_method("_touch_request_activity"):
		run_manager.call("_touch_request_activity", "visual_qa_pact_matrix")

func _capture_gesture_choice_matrix() -> void:
	var placa_button: Button = get_tree().root.get_node_or_null(GESTURE_CHOICE_PLACA_PATH) as Button
	var provoca_button: Button = get_tree().root.get_node_or_null(GESTURE_CHOICE_PROVOCA_PATH) as Button
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if placa_button == null or provoca_button == null or ui_root == null:
		_failures.append("OF-08 arena gesture nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size

	for locale: String in GESTURE_CHOICE_LOCALES:
		TranslationServer.set_locale(locale)
		ui_root.call("_on_intermediate_choice_opened")
		await _settle(8)
		for viewport_size: Vector2i in GESTURE_CHOICE_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "05_gesture_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			ui_root.call("_reset_gesture_choice_state")
			placa_button.release_focus()
			provoca_button.release_focus()
			_touch_runtime_watchdog_for_gesture_matrix()
			await _capture("%s_normal" % prefix, viewport_size)

			placa_button.grab_focus()
			await _settle(20)
			_touch_runtime_watchdog_for_gesture_matrix()
			await _capture("%s_focus_placa" % prefix, viewport_size)

			placa_button.release_focus()
			provoca_button.grab_focus()
			await _settle(20)
			_touch_runtime_watchdog_for_gesture_matrix()
			await _capture("%s_focus_provoca" % prefix, viewport_size)

			provoca_button.release_focus()
			ui_root.call("_reset_gesture_choice_state")
			ui_root.call("_set_gesture_choice_selected_state", 0)
			placa_button.disabled = true
			provoca_button.disabled = true
			_touch_runtime_watchdog_for_gesture_matrix()
			await _capture("%s_selected_placa" % prefix, viewport_size)

			ui_root.call("_reset_gesture_choice_state")
			ui_root.call("_set_gesture_choice_selected_state", 1)
			placa_button.disabled = true
			provoca_button.disabled = true
			_touch_runtime_watchdog_for_gesture_matrix()
			await _capture("%s_selected_provoca" % prefix, viewport_size)

			ui_root.call("_reset_gesture_choice_state")
			placa_button.disabled = true
			provoca_button.disabled = true
			_touch_runtime_watchdog_for_gesture_matrix()
			await _capture("%s_disabled" % prefix, viewport_size)

	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	ui_root.call("_on_intermediate_choice_opened")
	placa_button.release_focus()
	provoca_button.release_focus()
	await _settle(8)

func _touch_runtime_watchdog_for_gesture_matrix() -> void:
	if _main == null:
		return
	var run_manager: Node = _main.get_node_or_null("RunManager")
	if run_manager != null and run_manager.has_method("_touch_request_activity"):
		run_manager.call("_touch_request_activity", "visual_qa_gesture_matrix")

func _capture_judgment_seal_matrix() -> void:
	var button: Button = get_tree().root.get_node_or_null(JUDGMENT_SEAL_BUTTON_PATH) as Button
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if button == null or ui_root == null:
		_failures.append("OF-09 judgment seal nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_disabled: bool = button.disabled
	var previous_state: int = int(button.get_meta(&"registry_judgment_seal_state", 0))

	for locale: String in JUDGMENT_SEAL_LOCALES:
		TranslationServer.set_locale(locale)
		ui_root.call("_on_resolve_ritual_opened", {})
		await _settle(8)
		for viewport_size: Vector2i in JUDGMENT_SEAL_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(30)
			_center_judgment_panel_for_capture(viewport_size)
			var prefix: String = "06_judgment_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			ui_root.call("_reset_resolution_ritual_interaction")
			button.disabled = false
			button.release_focus()
			_touch_runtime_watchdog_for_judgment_matrix()
			await _capture("%s_normal" % prefix, viewport_size)

			button.grab_focus()
			await _settle(20)
			_touch_runtime_watchdog_for_judgment_matrix()
			await _capture("%s_focus" % prefix, viewport_size)

			button.release_focus()
			button.disabled = false
			button.text = tr("COLPISCI ANCORA")
			ui_root.call("_set_judgment_seal_state", 1)
			_touch_runtime_watchdog_for_judgment_matrix()
			await _capture("%s_strike_1" % prefix, viewport_size)

			button.text = tr("COLPISCI ANCORA")
			ui_root.call("_set_judgment_seal_state", 2)
			_touch_runtime_watchdog_for_judgment_matrix()
			await _capture("%s_strike_2" % prefix, viewport_size)

			button.text = tr("SIGILLATO")
			ui_root.call("_set_judgment_seal_state", 3)
			button.disabled = true
			_touch_runtime_watchdog_for_judgment_matrix()
			await _capture("%s_resolved" % prefix, viewport_size)

	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	await _settle(30)
	_center_judgment_panel_for_capture(previous_size)
	ui_root.call("_set_judgment_seal_state", previous_state)
	button.disabled = previous_disabled
	button.release_focus()
	await _settle(8)

func _center_judgment_panel_for_capture(viewport_size: Vector2i) -> void:
	var panel: Control = get_tree().root.get_node_or_null(JUDGMENT_SEAL_PANEL_PATH) as Control
	if panel == null:
		_failures.append("OF-09 judgment panel missing while stabilizing visual QA layout")
		return
	panel.scale = Vector2.ONE
	panel.position = (Vector2(viewport_size) - panel.size) * 0.5
	panel.pivot_offset = panel.size * 0.5
	panel.set_meta(&"motion_base_position", panel.position)

func _touch_runtime_watchdog_for_judgment_matrix() -> void:
	if _main == null:
		return
	var run_manager: Node = _main.get_node_or_null("RunManager")
	if run_manager != null and run_manager.has_method("_touch_request_activity"):
		run_manager.call("_touch_request_activity", "visual_qa_judgment_matrix")

func _capture_final_dossier_matrix() -> void:
	var panel: Control = get_tree().root.get_node_or_null(FINAL_DOSSIER_PANEL_PATH) as Control
	var restart: Button = get_tree().root.get_node_or_null(FINAL_DOSSIER_RESTART_PATH) as Button
	var next_bet: Button = get_tree().root.get_node_or_null(FINAL_DOSSIER_NEXT_BET_PATH) as Button
	var quit: Button = get_tree().root.get_node_or_null(FINAL_DOSSIER_QUIT_PATH) as Button
	var ui_root: Node = get_tree().root.get_node_or_null(UI_ROOT_PATH)
	if panel == null or restart == null or next_bet == null or quit == null or ui_root == null:
		_failures.append("OF-10 final dossier nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_register_final: bool = bool(ui_root.get("_last_register_final"))
	var previous_next_bet_enabled: bool = bool(ui_root.get("_last_next_bet_enabled"))
	var previous_title_key: String = str(ui_root.get("_last_finale_title_key"))
	var previous_state: StringName = ui_root.get("_final_dossier_state") as StringName

	for locale: String in FINAL_DOSSIER_LOCALES:
		TranslationServer.set_locale(locale)
		for viewport_size: Vector2i in FINAL_DOSSIER_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(30)
			_center_final_dossier_for_capture(viewport_size)
			var prefix: String = "08_dossier_%s_%dx%d" % [locale, viewport_size.x, viewport_size.y]

			ui_root.set("_last_register_final", false)
			ui_root.set("_last_next_bet_enabled", true)
			ui_root.call("_reset_final_dossier_route_interaction")
			ui_root.call("_set_final_dossier_state", &"open")
			ui_root.call("_refresh_verdict_panel")
			restart.release_focus()
			await _capture("%s_open" % prefix, viewport_size)

			ui_root.call("_set_final_dossier_state", &"updated")
			ui_root.call("_refresh_verdict_panel")
			await _capture("%s_updated" % prefix, viewport_size)

			ui_root.set("_last_register_final", true)
			ui_root.set("_last_next_bet_enabled", false)
			ui_root.set("_last_finale_title_key", "FASCICOLO CHIUSO - PATTERN")
			ui_root.call("_set_end_run_buttons_enabled", true)
			ui_root.call("_set_final_dossier_state", &"closed")
			ui_root.call("_refresh_verdict_panel")
			await _capture("%s_closed" % prefix, viewport_size)

			ui_root.set("_last_register_final", false)
			ui_root.set("_last_next_bet_enabled", true)
			ui_root.set("_last_finale_title_key", previous_title_key)
			ui_root.call("_reset_final_dossier_route_interaction")
			ui_root.call("_set_final_dossier_state", &"updated")
			ui_root.call("_refresh_verdict_panel")
			restart.grab_focus()
			await _settle(20)
			await _capture("%s_focus" % prefix, viewport_size)

			restart.release_focus()
			ui_root.call("_select_final_dossier_route", restart)
			ui_root.call("_set_end_run_buttons_enabled", false)
			await _capture("%s_selected" % prefix, viewport_size)

			ui_root.call("_reset_final_dossier_route_interaction")
			ui_root.call("_set_end_run_buttons_enabled", false)
			await _capture("%s_disabled" % prefix, viewport_size)

	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	await _settle(30)
	_center_final_dossier_for_capture(previous_size)
	ui_root.set("_last_register_final", previous_register_final)
	ui_root.set("_last_next_bet_enabled", previous_next_bet_enabled)
	ui_root.set("_last_finale_title_key", previous_title_key)
	ui_root.call("_reset_final_dossier_route_interaction")
	ui_root.call("_set_final_dossier_state", previous_state)
	ui_root.call("_refresh_verdict_panel")
	restart.release_focus()
	await _settle(8)

func _center_final_dossier_for_capture(viewport_size: Vector2i) -> void:
	var panel: Control = get_tree().root.get_node_or_null(FINAL_DOSSIER_PANEL_PATH) as Control
	if panel == null:
		_failures.append("OF-10 final dossier missing while stabilizing visual QA layout")
		return
	panel.scale = Vector2.ONE
	panel.position = (Vector2(viewport_size) - panel.size) * 0.5
	panel.pivot_offset = panel.size * 0.5
	panel.set_meta(&"motion_base_position", panel.position)

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

func _capture_arena_threshold_matrix() -> void:
	var button: Button = get_tree().root.get_node_or_null(THRESHOLD_BUTTON_PATH) as Button
	var main_menu: Node = get_tree().root.get_node_or_null(MAIN_MENU_PATH)
	if button == null or main_menu == null:
		_failures.append("OF-04 arena threshold nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_disabled: bool = button.disabled
	var previous_crossed: bool = bool(button.get_meta(&"arena_threshold_crossed", false))
	var previous_processing: bool = main_menu.is_processing()
	main_menu.set_process(false)

	for locale: String in THRESHOLD_LOCALES:
		TranslationServer.set_locale(locale)
		main_menu.call("_refresh_localized_ui")
		await _settle(8)
		for viewport_size: Vector2i in THRESHOLD_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "01_threshold_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			main_menu.call("_set_arena_threshold_crossed_state", false)
			button.disabled = false
			button.release_focus()
			await _capture("%s_normal" % prefix, viewport_size)

			button.grab_focus()
			await _settle(20)
			await _capture("%s_focus" % prefix, viewport_size)

			button.release_focus()
			main_menu.call("_set_arena_threshold_crossed_state", false)
			button.disabled = true
			await _capture("%s_disabled" % prefix, viewport_size)

			main_menu.call("_set_arena_threshold_crossed_state", true)
			await _capture("%s_crossed" % prefix, viewport_size)

	main_menu.call("_set_arena_threshold_crossed_state", previous_crossed)
	button.disabled = previous_disabled
	TranslationServer.set_locale(previous_locale)
	main_menu.call("_refresh_localized_ui")
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	main_menu.set_process(previous_processing)
	await _settle(8)

func _capture_registry_table_matrix() -> void:
	var registry_table: Node = get_tree().root.get_node_or_null(REGISTRY_TABLE_PATH)
	var open_button: Button = get_tree().root.get_node_or_null(REGISTRY_TABLE_BUTTON_PATH) as Button
	if registry_table == null or open_button == null:
		_failures.append("OF-05 registry table nodes missing for visual QA matrix")
		return
	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = DisplayServer.window_get_size()
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_processing: bool = registry_table.is_processing()
	registry_table.set_process(false)
	for locale: String in REGISTRY_TABLE_LOCALES:
		TranslationServer.set_locale(locale)
		await _settle(8)
		for viewport_size: Vector2i in REGISTRY_TABLE_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "02_registry_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			registry_table.call("_show_closed_intro")
			open_button.disabled = false
			open_button.release_focus()
			registry_table.call("_set_registry_table_closed_state", &"normal")
			await _capture("%s_closed_normal" % prefix, viewport_size)

			open_button.grab_focus()
			registry_table.call("_set_registry_table_closed_state", &"focus")
			await _settle(20)
			await _capture("%s_closed_focus" % prefix, viewport_size)

			open_button.release_focus()
			open_button.disabled = true
			registry_table.call("_set_registry_table_closed_state", &"disabled")
			await _capture("%s_closed_disabled" % prefix, viewport_size)

			registry_table.call("_hide_closed_intro")
			registry_table.call("_show_book_open_state")
			registry_table.call("_show_book_content_immediate")
			registry_table.call("_show_contract_text_immediate")
			await _capture("%s_open" % prefix, viewport_size)

	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	registry_table.call("_show_closed_intro")
	registry_table.set_process(previous_processing)
	await _settle(8)

func _capture_promise_signature_matrix() -> void:
	var registry_table: Node = get_tree().root.get_node_or_null(REGISTRY_TABLE_PATH)
	var left_button: Button = get_tree().root.get_node_or_null(PROMISE_SIGNATURE_LEFT_PATH) as Button
	var right_button: Button = get_tree().root.get_node_or_null(PROMISE_SIGNATURE_RIGHT_PATH) as Button
	if registry_table == null or left_button == null or right_button == null:
		_failures.append("OF-06 promise signature nodes missing for visual QA matrix")
		return

	var previous_locale: String = TranslationServer.get_locale()
	var previous_size: Vector2i = get_tree().root.size
	var previous_content_scale_size: Vector2i = get_tree().root.content_scale_size
	var previous_left_disabled: bool = left_button.disabled
	var previous_right_disabled: bool = right_button.disabled
	var previous_left_state: StringName = left_button.get_meta(&"registry_promise_signature_state", &"normal") as StringName
	var previous_right_state: StringName = right_button.get_meta(&"registry_promise_signature_state", &"normal") as StringName
	var previous_processing: bool = registry_table.is_processing()
	registry_table.set_process(false)

	for locale: String in PROMISE_SIGNATURE_LOCALES:
		TranslationServer.set_locale(locale)
		registry_table.call("_refresh_localized_text")
		await _settle(8)
		for viewport_size: Vector2i in PROMISE_SIGNATURE_VIEWPORT_SIZES:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			await _settle(20)
			var prefix: String = "03_promise_%s_%dx%d" % [
				locale,
				viewport_size.x,
				viewport_size.y,
			]

			left_button.disabled = false
			right_button.disabled = false
			left_button.release_focus()
			registry_table.call("_set_promise_signature_state", left_button, &"normal")
			registry_table.call("_set_promise_signature_state", right_button, &"normal")
			await _capture("%s_normal" % prefix, viewport_size)

			left_button.grab_focus()
			await _settle(20)
			await _capture("%s_focus" % prefix, viewport_size)

			left_button.release_focus()
			registry_table.call("_set_promise_signature_state", left_button, &"selected")
			await _capture("%s_selected" % prefix, viewport_size)

			left_button.disabled = true
			right_button.disabled = true
			registry_table.call("_set_promise_signature_state", left_button, &"signed")
			registry_table.call("_set_promise_signature_state", right_button, &"disabled")
			await _capture("%s_signed" % prefix, viewport_size)

			right_button.disabled = false
			registry_table.call("_set_promise_signature_state", left_button, &"disabled")
			registry_table.call("_set_promise_signature_state", right_button, &"normal")
			await _capture("%s_disabled" % prefix, viewport_size)

	left_button.disabled = previous_left_disabled
	right_button.disabled = previous_right_disabled
	registry_table.call("_set_promise_signature_state", left_button, previous_left_state)
	registry_table.call("_set_promise_signature_state", right_button, previous_right_state)
	TranslationServer.set_locale(previous_locale)
	registry_table.call("_refresh_localized_text")
	DisplayServer.window_set_size(previous_size)
	get_tree().root.content_scale_size = previous_content_scale_size
	get_tree().root.size = previous_size
	registry_table.set_process(previous_processing)
	await _settle(8)

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
