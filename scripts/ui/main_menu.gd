extends Control

@onready var menu_vbox: VBoxContainer = get_node("CenterContainer/MenuVBox") as VBoxContainer
@onready var achievements_panel: Control = get_node("AchievementsPanel") as Control
@onready var new_game_button: Button = get_node("CenterContainer/MenuVBox/NewGameButton") as Button
@onready var load_game_button: Button = get_node("CenterContainer/MenuVBox/LoadGameButton") as Button
@onready var achievements_button: Button = get_node("CenterContainer/MenuVBox/AchievementsButton") as Button
@onready var settings_button: Button = get_node("CenterContainer/MenuVBox/SettingsButton") as Button
@onready var credits_button: Button = get_node("CenterContainer/MenuVBox/CreditsButton") as Button
@onready var back_button: Button = get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/BackButton") as Button

func _ready() -> void:
	_show_menu()
	_disable_placeholder_buttons()
	achievements_button.pressed.connect(_on_achievements_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _show_menu() -> void:
	menu_vbox.visible = true
	achievements_panel.visible = false

func _show_achievements() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = true

func _disable_placeholder_buttons() -> void:
	new_game_button.disabled = true
	load_game_button.disabled = true
	settings_button.disabled = true
	credits_button.disabled = true

func _on_achievements_pressed() -> void:
	_show_achievements()

func _on_back_pressed() -> void:
	_show_menu()
