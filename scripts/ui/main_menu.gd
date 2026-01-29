extends Control

const CondannaDataScript = preload("res://data/condanne.gd")

@onready var menu_vbox: VBoxContainer = get_node("CenterContainer/MenuVBox") as VBoxContainer
@onready var achievements_panel: Control = get_node("AchievementsPanel") as Control
@onready var credits_panel: Control = get_node("CreditsPanel") as Control
@onready var settings_panel: Control = get_node("SettingsPanel") as Control
@onready var continue_button: Button = get_node("CenterContainer/MenuVBox/ContinueButton") as Button
@onready var continue_hint_label: Label = get_node("CenterContainer/MenuVBox/ContinueHintLabel") as Label
@onready var new_game_button: Button = get_node("CenterContainer/MenuVBox/NewGameButton") as Button
@onready var load_game_button: Button = get_node("CenterContainer/MenuVBox/LoadGameButton") as Button
@onready var achievements_button: Button = get_node("CenterContainer/MenuVBox/AchievementsButton") as Button
@onready var settings_button: Button = get_node("CenterContainer/MenuVBox/SettingsButton") as Button
@onready var credits_button: Button = get_node("CenterContainer/MenuVBox/CreditsButton") as Button
@onready var back_button: Button = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/BackButton") as Button
@onready var condanne_vbox: VBoxContainer = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/CondanneScroll/CondanneVBox") as VBoxContainer
@onready var condanna_tooltip: PanelContainer = get_node("AchievementsPanel/CondannaTooltip") as PanelContainer
@onready var tooltip_label: RichTextLabel = get_node("AchievementsPanel/CondannaTooltip/TooltipLabel") as RichTextLabel
@onready var credits_back_button: Button = get_node("CreditsPanel/CreditsCenter/CreditsVBox/CreditsBackButton") as Button
@onready var settings_back_button: Button = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsBackButton") as Button
@onready var brightness_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/BrightnessSlider") as HSlider
@onready var brightness_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/BrightnessValue") as Label
@onready var language_option: OptionButton = get_node("SettingsPanel/SettingsCenter/SettingsVBox/LanguageOption") as OptionButton
@onready var language_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/LanguageValue") as Label
@onready var master_volume_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/MasterVolumeSlider") as HSlider
@onready var master_volume_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/MasterVolumeValue") as Label
@onready var fullscreen_toggle: CheckBox = get_node("SettingsPanel/SettingsCenter/SettingsVBox/FullscreenToggle") as CheckBox
@onready var brightness_modulate: CanvasModulate = get_node("../../BrightnessModulate") as CanvasModulate

var selected_language: String = "Italiano"
var condanne_populated: bool = false
var condanna_entries: Dictionary = {}

const CONDANNA_UNLOCKED_ALPHA: float = 1.0
const CONDANNA_LOCKED_ALPHA: float = 0.35

func _ready() -> void:
	_show_menu()
	_disable_placeholder_buttons()
	_refresh_continue_button()
	_setup_language_options()
	_setup_initial_values()
	_build_condanne_list()
	continue_button.pressed.connect(_on_continue_pressed)
	achievements_button.pressed.connect(_on_achievements_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
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

func _show_menu() -> void:
	menu_vbox.visible = true
	achievements_panel.visible = false
	credits_panel.visible = false
	settings_panel.visible = false
	condanna_tooltip.visible = false
	_refresh_continue_button()

func _show_achievements() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = true
	credits_panel.visible = false
	settings_panel.visible = false
	if not condanne_populated:
		_build_condanne_list()
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
	new_game_button.disabled = true
	load_game_button.disabled = true

func _build_condanne_list() -> void:
	if condanne_populated:
		return
	var condanne: Array[CondannaData] = CondannaDataScript.defaults()
	for condanna in condanne:
		var entry_label := Label.new()
		entry_label.text = "— %s" % condanna.title
		entry_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		entry_label.mouse_filter = Control.MOUSE_FILTER_STOP
		condanna_entries[condanna.id] = entry_label
		_apply_condanna_style(condanna.id, entry_label)
		entry_label.mouse_entered.connect(_on_condanna_mouse_entered.bind(condanna))
		entry_label.mouse_exited.connect(_on_condanna_mouse_exited)
		condanne_vbox.add_child(entry_label)
	condanne_populated = true

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
	var tooltip_text := "%s\n\nCome è stata ottenuta:\n%s\n\n%s" % [
		condanna.title,
		condanna.condition_text,
		condanna.lore_text
	]
	tooltip_label.text = tooltip_text
	condanna_tooltip.visible = true
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	condanna_tooltip.global_position = mouse_pos + Vector2(16, 16)

func _on_condanna_mouse_exited() -> void:
	condanna_tooltip.visible = false

func _refresh_continue_button() -> void:
	var has_run_save: bool = FileAccess.file_exists("user://run.save")
	continue_button.disabled = not has_run_save
	continue_hint_label.visible = not has_run_save
	if not has_run_save:
		continue_hint_label.text = "Nessuna partita salvata."

func _on_continue_pressed() -> void:
	if continue_button.disabled:
		return
	if Engine.has_singleton("GameEvents") and GameEvents != null and GameEvents.has_signal("request_continue_run"):
		GameEvents.request_continue_run.emit()
		var connections: Array = GameEvents.request_continue_run.get_connections()
		if connections.is_empty():
			continue_hint_label.text = "In arrivo."
			continue_hint_label.visible = true
	else:
		continue_hint_label.text = "In arrivo."
		continue_hint_label.visible = true

func _on_achievements_pressed() -> void:
	_show_achievements()

func _on_back_pressed() -> void:
	_show_menu()

func _on_settings_pressed() -> void:
	_show_settings()

func _on_credits_pressed() -> void:
	_show_credits()

func _on_settings_back_pressed() -> void:
	_show_menu()

func _on_credits_back_pressed() -> void:
	_show_menu()

func _setup_language_options() -> void:
	language_option.clear()
	language_option.add_item("Italiano")
	language_option.add_item("English")
	language_option.select(0)
	_update_language_label()

func _setup_initial_values() -> void:
	_apply_brightness(brightness_slider.value)
	_update_volume_label(master_volume_slider.value)
	_update_fullscreen_toggle()

func _on_brightness_changed(value: float) -> void:
	_apply_brightness(value)

func _apply_brightness(value: float) -> void:
	brightness_modulate.color = Color(value, value, value, 1.0)
	brightness_value.text = "Luminosità: %.2f" % value

func _on_language_selected(index: int) -> void:
	selected_language = language_option.get_item_text(index)
	_update_language_label()

func _update_language_label() -> void:
	language_value.text = "Lingua selezionata: %s" % selected_language

func _on_master_volume_changed(value: float) -> void:
	_update_volume_label(value)
	_apply_master_volume(value)

func _update_volume_label(value: float) -> void:
	master_volume_value.text = "Volume: %d%%" % int(round(value * 100.0))

func _apply_master_volume(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _update_fullscreen_toggle() -> void:
	fullscreen_toggle.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_fullscreen_toggled(toggled: bool) -> void:
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
