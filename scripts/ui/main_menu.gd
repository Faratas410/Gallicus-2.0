extends Control

# -----------------------------------------------------------------------------
# ROLE / OWNERSHIP
# - This script is responsible for: Main menu navigation and emitting UI intents.
# - This script must NOT: start or manage gameplay/run state directly.
#
# FLOW CONTRACT (high level)
# - Inputs (signals/events it listens to): GameEvents.run_phase_changed, GameEvents.settings_opened/closed, GameEvents.condanna_registered
# - Outputs (signals/events it emits): GameEvents.request_new_run, GameEvents.request_continue_run, GameEvents.settings_opened/closed
# - Critical invariants: UI only emits intent; gameplay authority lives in RunManager.
# -----------------------------------------------------------------------------

const CondannaDataScript = preload("res://data/condanne.gd")
const ArenaThemes = preload("res://data/arena_themes.gd")
const UIFactoryScript = preload("res://scripts/ui/ui_factory.gd")

@onready var menu_vbox: VBoxContainer = get_node("CenterContainer/MenuVBox") as VBoxContainer
@onready var achievements_panel: Control = get_node("AchievementsPanel") as Control
@onready var credits_panel: Control = get_node("CreditsPanel") as Control
@onready var settings_panel: Control = get_node("SettingsPanel") as Control
@onready var continue_button: Button = get_node("CenterContainer/MenuVBox/ContinueButton") as Button
@onready var continue_hint_panel: PanelContainer = get_node("CenterContainer/MenuVBox/ContinueHintPanel") as PanelContainer
@onready var continue_hint_label: Label = get_node("CenterContainer/MenuVBox/ContinueHintPanel/ContinueHintLabel") as Label
@onready var new_game_button: Button = get_node("CenterContainer/MenuVBox/NewGameButton") as Button
@onready var load_game_button: Button = get_node("CenterContainer/MenuVBox/LoadGameButton") as Button
@onready var achievements_button: Button = get_node("CenterContainer/MenuVBox/AchievementsButton") as Button
@onready var settings_button: Button = get_node("CenterContainer/MenuVBox/SettingsButton") as Button
@onready var credits_button: Button = get_node("CenterContainer/MenuVBox/CreditsButton") as Button
@onready var condanne_tab_button: Button = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/TabsHBox/CondanneTabButton") as Button
@onready var museo_tab_button: Button = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/TabsHBox/MuseoTabButton") as Button
@onready var condanne_container: Control = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/CondanneContainer") as Control
@onready var museo_container: Control = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/MuseoContainer") as Control
@onready var back_button: Button = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/BackButton") as Button
@onready var condanne_vbox: VBoxContainer = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/CondanneContainer/CondanneScroll/CondanneVBox") as VBoxContainer
@onready var museo_vbox: VBoxContainer = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/MuseoContainer/MuseoScroll/MuseoVBox") as VBoxContainer
@onready var condanna_tooltip: PanelContainer = get_node("AchievementsPanel/CondannaTooltip") as PanelContainer
@onready var tooltip_label: RichTextLabel = get_node("AchievementsPanel/CondannaTooltip/TooltipLabel") as RichTextLabel
@onready var credits_back_button: Button = get_node("CreditsPanel/CreditsCenter/CreditsVBox/CreditsBackButton") as Button
@onready var settings_back_button: Button = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsBackButton") as Button
@onready var brightness_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/BrightnessSlider") as HSlider
@onready var brightness_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/BrightnessValuePanel/BrightnessValue") as Label
@onready var language_option: OptionButton = get_node("SettingsPanel/SettingsCenter/SettingsVBox/LanguageOption") as OptionButton
@onready var language_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/LanguageValuePanel/LanguageValue") as Label
@onready var master_volume_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/MasterVolumeSlider") as HSlider
@onready var master_volume_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/MasterVolumeValuePanel/MasterVolumeValue") as Label
@onready var fullscreen_toggle: CheckBox = get_node("SettingsPanel/SettingsCenter/SettingsVBox/FullscreenToggle") as CheckBox
@onready var brightness_modulate: CanvasModulate = get_node("../../BrightnessModulate") as CanvasModulate

const ACHIEVEMENTS_TAB_CONDANNE: StringName = &"CONDANNE"
const ACHIEVEMENTS_TAB_MUSEO: StringName = &"MUSEO"
const CONDANNA_UNLOCKED_ALPHA: float = 1.0
const CONDANNA_LOCKED_ALPHA: float = 0.35
const RUN_PHASE_MAIN_MENU: int = 10

var selected_language: String = "Italiano"
var condanne_populated: bool = false
var condanna_entries: Dictionary = {}
var _active_achievements_tab: StringName = ACHIEVEMENTS_TAB_CONDANNE
var _suppress_settings_events: bool = false
var _arena_themes: RefCounted = null

func _ready() -> void:
	_arena_themes = ArenaThemes.new()
	_show_menu()
	_disable_placeholder_buttons()
	_refresh_continue_button()
	_setup_language_options()
	_setup_initial_values()
	_build_condanne_list()
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	achievements_button.pressed.connect(_on_achievements_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	condanne_tab_button.pressed.connect(_on_condanne_tab_pressed)
	museo_tab_button.pressed.connect(_on_museo_tab_pressed)
	back_button.pressed.connect(_on_back_pressed)
	credits_back_button.pressed.connect(_on_credits_back_pressed)
	settings_back_button.pressed.connect(_on_settings_back_pressed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	language_option.item_selected.connect(_on_language_selected)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	if GameEvents.has_signal("condanna_registered"):
		var condanna_callable: Callable = Callable(self, "_on_condanna_registered")
		if not GameEvents.condanna_registered.is_connected(condanna_callable):
			GameEvents.condanna_registered.connect(condanna_callable)
	if GameEvents.has_signal("run_phase_changed"):
		var run_phase_callable: Callable = Callable(self, "_on_run_phase_changed")
		if not GameEvents.run_phase_changed.is_connected(run_phase_callable):
			GameEvents.run_phase_changed.connect(run_phase_callable)
	if GameEvents.has_signal("settings_opened"):
		var settings_open_callable: Callable = Callable(self, "_on_settings_opened")
		if not GameEvents.settings_opened.is_connected(settings_open_callable):
			GameEvents.settings_opened.connect(settings_open_callable)
	if GameEvents.has_signal("settings_closed"):
		var settings_closed_callable: Callable = Callable(self, "_on_settings_closed")
		if not GameEvents.settings_closed.is_connected(settings_closed_callable):
			GameEvents.settings_closed.connect(settings_closed_callable)

func _show_menu() -> void:
	menu_vbox.visible = true
	achievements_panel.visible = false
	credits_panel.visible = false
	settings_panel.visible = false
	condanna_tooltip.visible = false
	_refresh_continue_button()

func _hide_menu() -> void:
	visible = false

func _on_run_phase_changed(next_phase: int) -> void:
	if next_phase == RUN_PHASE_MAIN_MENU:
		visible = true
		_show_menu()

func _show_achievements() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = true
	credits_panel.visible = false
	settings_panel.visible = false
	if not condanne_populated:
		_build_condanne_list()
	_build_museo_list()
	_set_achievements_tab(ACHIEVEMENTS_TAB_CONDANNE)
	_refresh_condanne_visuals()

func _show_credits() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = false
	credits_panel.visible = true
	settings_panel.visible = false

func _show_settings() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = false
	credits_panel.visible = false
	settings_panel.visible = true

func _disable_placeholder_buttons() -> void:
	load_game_button.disabled = true
	load_game_button.tooltip_text = "NON DISPONIBILE"

func _build_condanne_list() -> void:
	if condanne_populated:
		return
	var condanne: Array[CondannaData] = CondannaDataScript.defaults()
	for condanna in condanne:
		var entry_panel: PanelContainer = _create_condanna_entry_panel("— %s" % condanna.title)
		var entry_label: Label = entry_panel.get_child(0) as Label
		condanna_entries[condanna.id] = entry_label
		_apply_condanna_style(condanna.id, entry_label)
		entry_label.mouse_entered.connect(_on_condanna_mouse_entered.bind(condanna))
		entry_label.mouse_exited.connect(_on_condanna_mouse_exited)
		condanne_vbox.add_child(entry_panel)
	condanne_populated = true

func _create_condanna_entry_panel(text: String) -> PanelContainer:
	var entry_panel: PanelContainer = UIFactoryScript.create_sprite_label(text) as PanelContainer
	entry_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var entry_label: Label = entry_panel.get_child(0) as Label
	entry_label.mouse_filter = Control.MOUSE_FILTER_STOP
	return entry_panel

func _build_museo_list() -> void:
	if museo_vbox == null:
		return
	for child in museo_vbox.get_children():
		child.queue_free()
	var run_manager: Node = _get_run_manager()
	var pact_ids: Array[StringName] = []
	var arena_themes: Array[StringName] = []
	var harsh_unlocked: bool = false
	var base_count: int = 0
	var harsh_count: int = 0
	if run_manager != null:
		if run_manager.has_method("get_available_level3_pacts"):
			pact_ids = run_manager.get_available_level3_pacts() as Array[StringName]
		if run_manager.has_method("get_available_arena_themes"):
			arena_themes = run_manager.get_available_arena_themes() as Array[StringName]
		if run_manager.has_method("is_harsh_crowd_unlocked"):
			harsh_unlocked = bool(run_manager.is_harsh_crowd_unlocked())
		if run_manager.has_method("get_crowd_line_count_base"):
			base_count = int(run_manager.get_crowd_line_count_base())
		if run_manager.has_method("get_crowd_line_count_harsh"):
			harsh_count = int(run_manager.get_crowd_line_count_harsh())
	var base_total: int = base_count if base_count > 0 else 60
	var harsh_total: int = harsh_count if harsh_count > 0 else 15
	_add_museo_header("PATTI DISPONIBILI (LIVELLO 3)")
	if pact_ids.is_empty():
		_add_museo_item("— Nessun patto disponibile.")
	else:
		for pact_id in pact_ids:
			var pact_title: String = _get_pact_display_name(run_manager, pact_id)
			_add_museo_item("— %s" % pact_title)
	_add_museo_header("ARENE TEMATICHE")
	if arena_themes.is_empty():
		_add_museo_item("— Nessuna arena disponibile.")
	else:
		for theme_id in arena_themes:
			var theme_data: Dictionary = _arena_themes.get_theme(theme_id)
			var theme_title: String = str(theme_data.get("title", ""))
			if theme_title == "":
				theme_title = str(theme_id)
			_add_museo_item("— %s" % theme_title)
	_add_museo_header("VOCI DEL PUBBLICO")
	_add_museo_item("Voci base: %d" % base_total)
	var harsh_status: String = "SBLOCCATE" if harsh_unlocked else "BLOCCATE"
	_add_museo_item("Voci dure: %s" % harsh_status)
	if harsh_unlocked:
		_add_museo_item("Voci dure: +%d" % harsh_total)

func _add_museo_header(text: String) -> void:
	var entry_panel: PanelContainer = _create_museo_entry_panel(text)
	museo_vbox.add_child(entry_panel)

func _add_museo_item(text: String) -> void:
	var entry_panel: PanelContainer = _create_museo_entry_panel(text)
	museo_vbox.add_child(entry_panel)

func _create_museo_entry_panel(text: String) -> PanelContainer:
	var entry_panel: PanelContainer = UIFactoryScript.create_sprite_label(text) as PanelContainer
	entry_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var entry_label: Label = entry_panel.get_child(0) as Label
	entry_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return entry_panel

func _get_pact_display_name(run_manager: Node, pact_id: StringName) -> String:
	if run_manager != null and run_manager.has_method("get_level3_pact_title"):
		var pact_title: String = str(run_manager.get_level3_pact_title(pact_id))
		if pact_title != "":
			return pact_title
	return str(pact_id)

func _get_run_manager() -> Node:
	return get_tree().get_first_node_in_group("run_manager")

func _set_achievements_tab(tab_id: StringName) -> void:
	_active_achievements_tab = tab_id
	var show_condanne: bool = tab_id == ACHIEVEMENTS_TAB_CONDANNE
	condanne_container.visible = show_condanne
	museo_container.visible = not show_condanne
	condanne_tab_button.disabled = show_condanne
	museo_tab_button.disabled = not show_condanne
	if not show_condanne:
		condanna_tooltip.visible = false

func _refresh_condanne_visuals() -> void:
	if condanna_entries.is_empty():
		return
	for condanna_id in condanna_entries.keys():
		var condanna_id_name: StringName = StringName(condanna_id)
		var entry_label: Label = condanna_entries.get(condanna_id_name) as Label
		if entry_label != null:
			_apply_condanna_style(condanna_id_name, entry_label)

func _apply_condanna_style(condanna_id: StringName, entry_label: Label) -> void:
	if entry_label == null:
		return
	var unlocked: bool = SaveManager.has_unlocked(condanna_id)
	var alpha: float = CONDANNA_UNLOCKED_ALPHA if unlocked else CONDANNA_LOCKED_ALPHA
	entry_label.modulate = Color(1.0, 1.0, 1.0, alpha)

func _on_condanna_registered(condanna_id: StringName) -> void:
	if condanna_entries.is_empty():
		return
	var entry_label: Label = condanna_entries.get(condanna_id) as Label
	if entry_label != null:
		_apply_condanna_style(condanna_id, entry_label)

func _on_condanna_mouse_entered(condanna: CondannaData) -> void:
	var tooltip_label_text: String = "%s\n\nCome è stata ottenuta:\n%s\n\n%s" % [
		condanna.title,
		condanna.condition_text,
		condanna.lore_text
	]
	tooltip_label.text = tooltip_label_text
	condanna_tooltip.visible = true
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	condanna_tooltip.global_position = mouse_pos + Vector2(16, 16)

func _on_condanna_mouse_exited() -> void:
	condanna_tooltip.visible = false

func _refresh_continue_button() -> void:
	var has_run_save: bool = SaveManager.has_run_save()
	continue_button.disabled = not has_run_save
	continue_hint_panel.visible = not has_run_save
	continue_hint_label.visible = not has_run_save
	if not has_run_save:
		continue_hint_label.text = "Nessuna partita salvata."

func _on_continue_pressed() -> void:
	if continue_button.disabled:
		return
	if Engine.has_singleton("GameEvents") and GameEvents != null and GameEvents.has_signal("request_continue_run"):
		var run_manager: Node = _get_run_manager()
		if run_manager == null:
			continue_hint_label.text = "In arrivo."
			continue_hint_panel.visible = true
			continue_hint_label.visible = true
			return
		GameEvents.request_continue_run.emit()
		_hide_menu()
	else:
		continue_hint_label.text = "In arrivo."
		continue_hint_panel.visible = true
		continue_hint_label.visible = true

func _on_new_game_pressed() -> void:
	# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
	# Preconditions: GameEvents autoload is available and exposes request_new_run.
	# Postconditions: RunManager receives intent; menu hides to unblock gameplay.
	# NOTE: UI must never call gameplay/run logic directly.
	# It only emits intent via GameEvents. RunManager is the authority.
	if GameEvents != null and GameEvents.has_signal("request_new_run"):
		GameEvents.request_new_run.emit()
		_hide_menu()
	else:
		continue_hint_label.text = "In arrivo."
		continue_hint_panel.visible = true
		continue_hint_label.visible = true

func _on_achievements_pressed() -> void:
	_show_achievements()

func _on_condanne_tab_pressed() -> void:
	_set_achievements_tab(ACHIEVEMENTS_TAB_CONDANNE)

func _on_museo_tab_pressed() -> void:
	_set_achievements_tab(ACHIEVEMENTS_TAB_MUSEO)

func _on_back_pressed() -> void:
	_show_menu()

func _on_settings_pressed() -> void:
	if GameEvents.has_signal("settings_opened"):
		GameEvents.settings_opened.emit()
	else:
		_show_settings()

func _on_credits_pressed() -> void:
	_show_credits()

func _on_settings_back_pressed() -> void:
	if GameEvents.has_signal("settings_closed"):
		GameEvents.settings_closed.emit()
	else:
		_show_menu()

func _on_credits_back_pressed() -> void:
	_show_menu()

func _setup_language_options() -> void:
	language_option.clear()
	language_option.add_item("Italiano")
	language_option.set_item_metadata(0, "it")
	language_option.add_item("English")
	language_option.set_item_metadata(1, "en")
	language_option.select(0)
	_update_language_label()

func _setup_initial_values() -> void:
	_apply_saved_settings()
	_update_fullscreen_toggle()

func _apply_saved_settings() -> void:
	_suppress_settings_events = true
	var saved_brightness: float = SaveManager.get_brightness()
	brightness_slider.set_value_no_signal(saved_brightness)
	_apply_brightness(saved_brightness)
	var saved_volume: float = SaveManager.get_master_volume()
	master_volume_slider.set_value_no_signal(saved_volume)
	_update_volume_label(saved_volume)
	_apply_master_volume(saved_volume)
	var saved_language: String = SaveManager.get_language()
	_select_language(saved_language)
	_apply_language(saved_language)
	_suppress_settings_events = false

func _select_language(locale: String) -> void:
	var target_locale: String = locale.to_lower()
	var selected_index: int = 0
	for index in language_option.item_count:
		var metadata_value: String = str(language_option.get_item_metadata(index)).to_lower()
		if metadata_value == target_locale:
			selected_index = index
			break
	language_option.select(selected_index)
	selected_language = _language_label_from_locale(target_locale)
	_update_language_label()

func _language_label_from_locale(locale: String) -> String:
	return "English" if locale == "en" else "Italiano"

func _on_brightness_changed(value: float) -> void:
	if _suppress_settings_events:
		return
	SaveManager.set_brightness(value)
	var applied_value: float = SaveManager.get_brightness()
	if not is_equal_approx(applied_value, value):
		brightness_slider.set_value_no_signal(applied_value)
	_apply_brightness(applied_value)
	_emit_settings_changed()

func _apply_brightness(value: float) -> void:
	brightness_modulate.color = Color(value, value, value, 1.0)
	brightness_value.text = "Luminosità: %.2f" % value

func _on_language_selected(index: int) -> void:
	if _suppress_settings_events:
		return
	var locale_value: String = str(language_option.get_item_metadata(index))
	SaveManager.set_language(locale_value)
	var applied_locale: String = SaveManager.get_language()
	_suppress_settings_events = true
	_select_language(applied_locale)
	_suppress_settings_events = false
	_apply_language(applied_locale)
	_emit_settings_changed()

func _update_language_label() -> void:
	language_value.text = "Lingua selezionata: %s" % selected_language

func _on_master_volume_changed(value: float) -> void:
	if _suppress_settings_events:
		return
	SaveManager.set_master_volume(value)
	var applied_value: float = SaveManager.get_master_volume()
	if not is_equal_approx(applied_value, value):
		master_volume_slider.set_value_no_signal(applied_value)
	_update_volume_label(applied_value)
	_apply_master_volume(applied_value)
	_emit_settings_changed()

func _update_volume_label(value: float) -> void:
	master_volume_value.text = "Volume: %d%%" % int(round(value * 100.0))

func _apply_master_volume(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		var db_value: float = -80.0 if value <= 0.001 else linear_to_db(value)
		AudioServer.set_bus_volume_db(bus_index, db_value)

func _apply_language(locale: String) -> void:
	var target_locale: String = locale.to_lower()
	if target_locale != "it" and target_locale != "en":
		target_locale = "it"
	TranslationServer.set_locale(target_locale)
	selected_language = _language_label_from_locale(target_locale)
	_update_language_label()

func _emit_settings_changed() -> void:
	if GameEvents.has_signal("settings_changed"):
		var payload: Dictionary = {
			"language": SaveManager.get_language(),
			"brightness": SaveManager.get_brightness(),
			"master_volume": SaveManager.get_master_volume(),
		}
		GameEvents.settings_changed.emit(payload)

func _update_fullscreen_toggle() -> void:
	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_fullscreen_toggled(toggled: bool) -> void:
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_settings_opened() -> void:
	_show_settings()
	_apply_saved_settings()

func _on_settings_closed() -> void:
	_show_menu()
