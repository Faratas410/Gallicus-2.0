extends Control

@onready var menu_vbox: VBoxContainer = get_node("CenterContainer/MenuVBox") as VBoxContainer
@onready var achievements_panel: Control = get_node("AchievementsPanel") as Control
@onready var settings_panel: Control = get_node("SettingsPanel") as Control
@onready var new_game_button: Button = get_node("CenterContainer/MenuVBox/NewGameButton") as Button
@onready var load_game_button: Button = get_node("CenterContainer/MenuVBox/LoadGameButton") as Button
@onready var achievements_button: Button = get_node("CenterContainer/MenuVBox/AchievementsButton") as Button
@onready var settings_button: Button = get_node("CenterContainer/MenuVBox/SettingsButton") as Button
@onready var credits_button: Button = get_node("CenterContainer/MenuVBox/CreditsButton") as Button
@onready var back_button: Button = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/BackButton") as Button
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

func _ready() -> void:
	_show_menu()
	_disable_placeholder_buttons()
	_setup_language_options()
	_setup_initial_values()
	achievements_button.pressed.connect(_on_achievements_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	back_button.pressed.connect(_on_back_pressed)
	settings_back_button.pressed.connect(_on_settings_back_pressed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	language_option.item_selected.connect(_on_language_selected)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)

func _show_menu() -> void:
	menu_vbox.visible = true
	achievements_panel.visible = false
	settings_panel.visible = false

func _show_achievements() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = true
	settings_panel.visible = false

func _show_settings() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = false
	settings_panel.visible = true

func _disable_placeholder_buttons() -> void:
	new_game_button.disabled = true
	load_game_button.disabled = true
	credits_button.disabled = true

func _on_achievements_pressed() -> void:
	_show_achievements()

func _on_back_pressed() -> void:
	_show_menu()

func _on_settings_pressed() -> void:
	_show_settings()

func _on_settings_back_pressed() -> void:
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
