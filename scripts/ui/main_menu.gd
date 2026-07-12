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
const LanguagesScript = preload("res://assets/i18n/languages.gd")
const ARENA_THRESHOLD_STYLE_CROSSED: StyleBox = preload("res://assets/ui/official/objects/arena_threshold/sb_arena_threshold_crossed.tres")
const ARENA_THRESHOLD_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/arena_threshold/sb_arena_threshold_disabled.tres")
const ARENA_THRESHOLD_CROSSED_META: StringName = &"arena_threshold_crossed"

@onready var menu_vbox: VBoxContainer = get_node("CenterContainer/MenuVBox") as VBoxContainer
@onready var menu_center: CenterContainer = get_node("CenterContainer") as CenterContainer
@onready var achievements_panel: Control = get_node("AchievementsPanel") as Control
@onready var credits_panel: Control = get_node("CreditsPanel") as Control
@onready var settings_panel: Control = get_node("SettingsPanel") as Control
@onready var title_label: Label = get_node("CenterContainer/MenuVBox/TitlePanel/TitleLabel") as Label
@onready var settings_title: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsTitlePanel/SettingsTitle") as Label
@onready var brightness_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/BrightnessLabelPanel/BrightnessLabel") as Label
@onready var language_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/LanguageLabelPanel/LanguageLabel") as Label
@onready var volume_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/VolumeLabelPanel/VolumeLabel") as Label
@onready var music_volume_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/MusicVolumeLabelPanel/MusicVolumeLabel") as Label
@onready var resolution_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ResolutionLabelPanel/ResolutionLabel") as Label
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
@onready var settings_back_button: Button = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsButtonRow/SettingsBackButton") as Button
@onready var brightness_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/BrightnessSlider") as HSlider
@onready var brightness_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/BrightnessValuePanel/BrightnessValue") as Label
@onready var language_option: OptionButton = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/LanguageOption") as OptionButton
@onready var language_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/LanguageValuePanel/LanguageValue") as Label
@onready var master_volume_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/MasterVolumeSlider") as HSlider
@onready var master_volume_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/MasterVolumeValuePanel/MasterVolumeValue") as Label
@onready var music_volume_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/MusicVolumeSlider") as HSlider
@onready var music_volume_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/MusicVolumeValuePanel/MusicVolumeValue") as Label
@onready var resolution_option: OptionButton = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ResolutionOption") as OptionButton
@onready var resolution_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ResolutionValuePanel/ResolutionValue") as Label
@onready var fullscreen_toggle: CheckBox = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/SchermoInteroToggle") as CheckBox
@onready var brightness_modulate: CanvasModulate = get_node_or_null("../../BrightnessModulate") as CanvasModulate
@onready var brightness_overlay: ColorRect = get_node_or_null("../../BrightnessOverlayLayer/BrightnessOverlay") as ColorRect

const ACHIEVEMENTS_TAB_CONDANNE: StringName = &"CONDANNE"
const ACHIEVEMENTS_TAB_MUSEO: StringName = &"MUSEO"
const CONDANNA_UNLOCKED_ALPHA: float = 1.0
const CONDANNA_LOCKED_ALPHA: float = 0.35
const MENU_IDLE_BOB_AMPLITUDE: float = 2.0
const MENU_IDLE_BOB_SPEED: float = 1.25
const MENU_TITLE_PULSE_SPEED: float = 1.8
const MENU_TITLE_PULSE_BASE: float = 0.95
const MENU_TITLE_PULSE_AMPLITUDE: float = 0.05
const MENU_BUTTON_HOVER_SCALE: float = 1.02
const SETTINGS_RESOLUTIONS: Array[String] = [
	"960x540",
	"1280x720",
	"1600x900",
	"1920x1080",
]
const RunPhaseContractScript = preload("res://scripts/contracts/run_phase_contract.gd")
const MENU_EMPTY_RUN_HINT: String = "Obiettivo: firma un patto, supera i riti del Registro, poi incassa o rischia fino al fascicolo finale."
const MENU_RETURNED_RUN_HINT: String = "Registro aggiornato. Puoi tornare nell'arena quando vuoi."

static var _i18n_bootstrap_done: bool = false
var _language_fallback_logged: bool = false
var selected_language: String = "Italiano"
var condanne_populated: bool = false
var condanna_entries: Dictionary = {}
var _active_achievements_tab: StringName = ACHIEVEMENTS_TAB_CONDANNE
var _suppress_settings_events: bool = false
var _arena_themes: RefCounted = null
var _run_manager_port: RunManagerUiPort = null
var _menu_next_step_hint: String = ""
var _menu_idle_time: float = 0.0
var _menu_buttons: Array[Button] = []
var _menu_button_tweens: Dictionary = {}
var _menu_center_base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_ensure_i18n_loaded()
	_arena_themes = ArenaThemes.new()
	_run_manager_port = RunManagerUiPort.new(get_tree())
	_show_menu()
	_disable_unavailable_buttons()
	_refresh_continue_button()
	_setup_language_options()
	_setup_resolution_options()
	_setup_initial_values()
	_refresh_localized_ui()
	_build_condanne_list()
	_cache_menu_buttons()
	_wire_menu_button_animations()
	_wire_menu_button_sfx()
	if menu_center != null:
		_menu_center_base_position = menu_center.position
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
	resolution_option.item_selected.connect(_on_resolution_selected)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
		# Godot 4.6: TranslationServer no longer exposes a translation-changed signal.
	# UI refresh on locale updates is handled in _notification(NOTIFICATION_TRANSLATION_CHANGED).
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
	if GameEvents.has_signal("continue_rejected"):
		var continue_rejected_callable: Callable = Callable(self, "_on_continue_rejected")
		if not GameEvents.continue_rejected.is_connected(continue_rejected_callable):
			GameEvents.continue_rejected.connect(continue_rejected_callable)

func _ensure_i18n_loaded() -> void:
	if _i18n_bootstrap_done:
		return
	for entry: Dictionary in LanguagesScript.all():
		_load_csv_translation(str(entry.get("path", "")), str(entry.get("locale", "")))
	_i18n_bootstrap_done = true

func _load_csv_translation(path: String, locale: String) -> void:
	if not FileAccess.file_exists(path):
		push_warning("[I18N] Missing CSV translation file: %s" % path)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("[I18N] Unable to open CSV translation file: %s" % path)
		return
	var translation: Translation = Translation.new()
	translation.locale = locale
	var is_header: bool = true
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.is_empty():
			continue
		if is_header:
			is_header = false
			continue
		if row.size() < 2:
			continue
		var key: String = row[0].strip_edges()
		if key.is_empty():
			continue
		translation.add_message(key, row[1])
	TranslationServer.add_translation(translation)

func _show_menu() -> void:
	menu_vbox.visible = true
	_set_arena_threshold_crossed_state(false)
	achievements_panel.visible = false
	credits_panel.visible = false
	settings_panel.visible = false
	condanna_tooltip.visible = false
	_refresh_continue_button()

func _hide_menu() -> void:
	visible = false

func _set_arena_threshold_crossed_state(crossed: bool) -> void:
	if new_game_button == null:
		return
	new_game_button.set_meta(ARENA_THRESHOLD_CROSSED_META, crossed)
	new_game_button.disabled = crossed
	new_game_button.add_theme_stylebox_override(
		"disabled",
		ARENA_THRESHOLD_STYLE_CROSSED if crossed else ARENA_THRESHOLD_STYLE_DISABLED
	)
	new_game_button.add_theme_color_override(
		"font_disabled_color",
		Color(1.0, 0.84, 0.66, 1.0) if crossed else Color(0.54, 0.52, 0.48, 1.0)
	)

func _on_run_phase_changed(next_phase: int) -> void:
	if next_phase == RunPhaseContractScript.MAIN_MENU:
		visible = true
		_menu_next_step_hint = tr(MENU_RETURNED_RUN_HINT)
		_show_menu()

func _show_achievements() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = true
	credits_panel.visible = false
	settings_panel.visible = false
	if not condanne_populated:
		_build_condanne_list()
	_cache_menu_buttons()
	_wire_menu_button_animations()
	if menu_center != null:
		_menu_center_base_position = menu_center.position
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

func _disable_unavailable_buttons() -> void:
	load_game_button.disabled = true
	load_game_button.tooltip_text = tr("Funzione disattiva in L3.")

func _build_condanne_list() -> void:
	if condanne_populated:
		return
	var condanne: Array[CondannaData] = CondannaDataScript.defaults()
	for condanna in condanne:
		var entry_panel: PanelContainer = _create_condanna_entry_panel("- %s" % condanna.title)
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
	var pact_ids: Array[StringName] = []
	var arena_themes: Array[StringName] = []
	var harsh_unlocked: bool = false
	var base_count: int = 0
	var harsh_count: int = 0
	if _run_manager_port != null:
		pact_ids = _run_manager_port.get_available_level3_pacts()
		arena_themes = _run_manager_port.get_available_arena_themes()
		harsh_unlocked = _run_manager_port.is_harsh_crowd_unlocked()
		base_count = _run_manager_port.get_crowd_line_count_base()
		harsh_count = _run_manager_port.get_crowd_line_count_harsh()
	var base_total: int = base_count if base_count > 0 else 60
	var harsh_total: int = harsh_count if harsh_count > 0 else 15
	_add_museo_header(tr("PATTI DISPONIBILI (LIVELLO 3)"))
	if pact_ids.is_empty():
		_add_museo_item(tr("- Nessun patto disponibile."))
	else:
		for pact_id in pact_ids:
			var pact_title: String = _get_pact_display_name(pact_id)
			_add_museo_item("- %s" % pact_title)
	_add_museo_header(tr("ARENE TEMATICHE"))
	if arena_themes.is_empty():
		_add_museo_item(tr("- Nessuna arena disponibile."))
	else:
		for theme_id in arena_themes:
			var theme_data: Dictionary = _arena_themes.get_theme(theme_id)
			var theme_title: String = str(theme_data.get("title", ""))
			if theme_title == "":
				theme_title = str(theme_id)
			_add_museo_item("- %s" % theme_title)
	_add_museo_header(tr("VOCI DEL PUBBLICO"))
	_add_museo_item(tr("Voci base: %d") % base_total)
	var harsh_status: String = tr("SBLOCCATE") if harsh_unlocked else tr("BLOCCATE")
	_add_museo_item(tr("Voci dure: %s") % harsh_status)
	if harsh_unlocked:
		_add_museo_item(tr("Voci dure: +%d") % harsh_total)

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

func _get_pact_display_name(pact_id: StringName) -> String:
	if _run_manager_port != null:
		var pact_title: String = _run_manager_port.get_level3_pact_title(pact_id)
		if pact_title != "":
			return pact_title
	return str(pact_id)

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
	var tooltip_label_text: String = "%s\n\n%s\n%s\n\n%s" % [
		condanna.title,
		tr("Come e' stata ottenuta:"),
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
	continue_button.visible = has_run_save
	var has_menu_hint: bool = _menu_next_step_hint != ""
	continue_hint_panel.visible = not has_run_save or has_menu_hint
	continue_hint_label.visible = not has_run_save or has_menu_hint
	if has_menu_hint:
		continue_hint_label.text = _menu_next_step_hint
		_menu_next_step_hint = ""
		return
	if not has_run_save:
		continue_hint_label.text = tr(MENU_EMPTY_RUN_HINT)

func _format_continue_reject_reason(reason: String) -> String:
	if reason == "missing_or_invalid_schema_version":
		return tr("Salvataggio non valido: schema del file mancante o corrotto.")
	if reason == "unsupported_save_wrapper_schema":
		return tr("Salvataggio non compatibile con questa versione.")
	if reason == "missing_run_payload":
		return tr("Salvataggio incompleto: dati del percorso mancanti.")
	if reason == "missing_level3_schema":
		return tr("Salvataggio non valido: schema Level 3 mancante.")
	if reason == "unsupported_level3_schema":
		return tr("Salvataggio non compatibile: schema Level 3 differente.")
	if reason.begins_with("legacy_run_key:"):
		return tr("Salvataggio legacy non supportato in L3.")
	if reason == "missing_run_state":
		return tr("Salvataggio incompleto: stato del percorso mancante.")
	if reason == "missing_or_invalid_scars_array":
		return tr("Salvataggio non valido: dati Condanne non leggibili.")
	if reason == "invalid_scar_item_type":
		return tr("Salvataggio non valido: formato Condanne non supportato.")
	if reason == "":
		return tr("Salvataggio non valido.")
	return tr("Salvataggio non valido: %s.") % reason

func _on_continue_rejected(reason: String) -> void:
	_refresh_continue_button()
	continue_hint_label.text = _format_continue_reject_reason(reason)
	continue_hint_panel.visible = true
	continue_hint_label.visible = true

func _on_continue_pressed() -> void:
	if continue_button.disabled:
		return
	if Engine.has_singleton("GameEvents") and GameEvents != null and GameEvents.has_signal("request_continue_run"):
		if _run_manager_port == null or not _run_manager_port.has_manager():
			continue_hint_label.text = tr("In arrivo.")
			continue_hint_panel.visible = true
			continue_hint_label.visible = true
			return
		GameEvents.request_continue_run.emit()
		_hide_menu()
	else:
		continue_hint_label.text = tr("In arrivo.")
		continue_hint_panel.visible = true
		continue_hint_label.visible = true

func _on_new_game_pressed() -> void:
	# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
	# Preconditions: GameEvents autoload is available and exposes request_new_run.
	# Postconditions: RunManager receives intent; menu hides to unblock gameplay.
	# NOTE: UI must never call gameplay/run logic directly.
	# It only emits intent via GameEvents. RunManager is the authority.
	if GameEvents != null and GameEvents.has_signal("request_new_run"):
		_play_sfx(&"arena_threshold_cross")
		_set_arena_threshold_crossed_state(true)
		GameEvents.request_new_run.emit()
		_hide_menu()
	else:
		_set_arena_threshold_crossed_state(false)
		continue_hint_label.text = tr("In arrivo.")
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
	var index: int = 0
	for entry: Dictionary in LanguagesScript.all():
		language_option.add_item(str(entry.get("label", entry.get("locale", ""))))
		language_option.set_item_metadata(index, str(entry.get("locale", "")))
		index += 1
	_select_language(SaveManager.get_language())
	_update_language_label()
	_refresh_localized_ui()

func _setup_resolution_options() -> void:
	resolution_option.clear()
	for index: int in range(SETTINGS_RESOLUTIONS.size()):
		var resolution: String = SETTINGS_RESOLUTIONS[index]
		resolution_option.add_item(resolution)
		resolution_option.set_item_metadata(index, resolution)
	_select_resolution(SaveManager.get_window_resolution())
	_update_resolution_label()

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
	var saved_music_volume: float = SaveManager.get_music_volume()
	music_volume_slider.set_value_no_signal(saved_music_volume)
	_update_music_volume_label(saved_music_volume)
	var saved_resolution: String = SaveManager.get_window_resolution()
	_select_resolution(saved_resolution)
	_apply_window_resolution(saved_resolution)
	var saved_fullscreen: bool = SaveManager.get_fullscreen()
	fullscreen_toggle.set_pressed_no_signal(saved_fullscreen)
	_apply_fullscreen(saved_fullscreen)
	var saved_language: String = SaveManager.get_language()
	_select_language(saved_language)
	_apply_language(saved_language)
	_suppress_settings_events = false

func _select_language(locale: String) -> void:
	var target_locale: String = LanguagesScript.sanitize_locale(locale)
	var selected_index: int = 0
	for index: int in range(language_option.item_count):
		var metadata_value: String = str(language_option.get_item_metadata(index)).to_lower()
		if metadata_value == target_locale:
			selected_index = index
			break
	language_option.select(selected_index)
	selected_language = _language_label_from_locale(target_locale)
	_update_language_label()

func _language_label_from_locale(locale: String) -> String:
	return tr(LanguagesScript.label_for(locale))

func _select_resolution(resolution: String) -> void:
	var target_resolution: String = _sanitize_resolution(resolution)
	var selected_index: int = 0
	for index: int in range(resolution_option.item_count):
		var metadata_value: String = str(resolution_option.get_item_metadata(index)).to_lower()
		if metadata_value == target_resolution:
			selected_index = index
			break
	resolution_option.select(selected_index)
	_update_resolution_label()

func _sanitize_resolution(resolution: String) -> String:
	var normalized: String = resolution.strip_edges().to_lower()
	if SETTINGS_RESOLUTIONS.has(normalized):
		return normalized
	return "1280x720"

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
	if brightness_modulate != null:
		brightness_modulate.color = Color(1.0, 1.0, 1.0, 1.0)
	if brightness_overlay != null:
		var overlay_alpha: float = absf(value - 1.0)
		var overlay_color: Color = Color(0.0, 0.0, 0.0, overlay_alpha)
		if value > 1.0:
			overlay_color = Color(1.0, 1.0, 1.0, overlay_alpha)
		brightness_overlay.color = overlay_color
	if brightness_value != null:
		brightness_value.text = tr("Luminosita': %.2f") % value

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

func _on_resolution_selected(index: int) -> void:
	if _suppress_settings_events:
		return
	var resolution: String = str(resolution_option.get_item_metadata(index))
	SaveManager.set_window_resolution(resolution)
	var applied_resolution: String = SaveManager.get_window_resolution()
	_select_resolution(applied_resolution)
	_apply_window_resolution(applied_resolution)
	_emit_settings_changed()

func _update_language_label() -> void:
	if language_value != null:
		language_value.text = tr("Lingua selezionata: %s") % selected_language

func _update_resolution_label() -> void:
	if resolution_value != null:
		resolution_value.text = tr("Risoluzione: %s") % SaveManager.get_window_resolution()

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
	if master_volume_value != null:
		master_volume_value.text = tr("Volume: %d%%") % int(round(value * 100.0))


func _on_music_volume_changed(value: float) -> void:
	if _suppress_settings_events:
		return
	SaveManager.set_music_volume(value)
	var applied_value: float = SaveManager.get_music_volume()
	if not is_equal_approx(applied_value, value):
		music_volume_slider.set_value_no_signal(applied_value)
	_update_music_volume_label(applied_value)
	_emit_settings_changed()

func _update_music_volume_label(value: float) -> void:
	if music_volume_value != null:
		music_volume_value.text = tr("Musica: %d%%") % int(round(value * 100.0))

func _apply_master_volume(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		var db_value: float = -80.0 if value <= 0.001 else linear_to_db(value)
		AudioServer.set_bus_volume_db(bus_index, db_value)

func _apply_window_resolution(resolution: String) -> void:
	var normalized: String = _sanitize_resolution(resolution)
	if SaveManager.get_fullscreen():
		return
	var parts: PackedStringArray = normalized.split("x", false)
	if parts.size() != 2:
		return
	var width: int = int(parts[0])
	var height: int = int(parts[1])
	if width <= 0 or height <= 0:
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(width, height))

func _apply_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_apply_window_resolution(SaveManager.get_window_resolution())

func _apply_language(locale: String) -> void:
	var target_locale: String = LanguagesScript.sanitize_locale(locale)
	var resolved_locale: String = _resolve_available_locale(target_locale)
	TranslationServer.set_locale(resolved_locale)
	selected_language = _language_label_from_locale(resolved_locale)
	_refresh_localized_ui()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh_localized_ui()

func _refresh_localized_ui() -> void:
	if title_label != null:
		title_label.text = tr("GALLICUS")
	if continue_button != null:
		continue_button.text = tr("CONTINUA")
	if new_game_button != null:
		new_game_button.text = tr("ENTRA NELL'ARENA")
	if load_game_button != null:
		load_game_button.text = tr("CARICA PARTITA")
	if achievements_button != null:
		achievements_button.text = tr("ARCHIVIO")
	if settings_button != null:
		settings_button.text = tr("OPZIONI")
	if credits_button != null:
		credits_button.text = tr("CREDITI")
	if settings_title != null:
		settings_title.text = tr("OPZIONI")
	if brightness_label != null:
		brightness_label.text = tr("LUMINOSITA'")
	if language_label != null:
		language_label.text = tr("LINGUA")
	if volume_label != null:
		volume_label.text = tr("VOLUME MASTER")
	if music_volume_label != null:
		music_volume_label.text = tr("VOLUME MUSICA")
	if resolution_label != null:
		resolution_label.text = tr("RISOLUZIONE")
	if fullscreen_toggle != null:
		fullscreen_toggle.text = tr("SCHERMO INTERO")
	if back_button != null:
		back_button.text = tr("TORNA AL MENU")
	if credits_back_button != null:
		credits_back_button.text = tr("TORNA AL MENU")
	if settings_back_button != null:
		settings_back_button.text = tr("TORNA AL MENU")
	_update_language_label()
	if master_volume_slider != null:
		_update_volume_label(master_volume_slider.value)
	if music_volume_slider != null:
		_update_music_volume_label(music_volume_slider.value)
	if brightness_slider != null:
		_apply_brightness(brightness_slider.value)
	if resolution_value != null:
		_update_resolution_label()

func _resolve_available_locale(target_locale: String) -> String:
	var requested_path: String = LanguagesScript.path_for(target_locale)
	if FileAccess.file_exists(requested_path):
		return target_locale
	var fallback_locale: String = LanguagesScript.fallback_locale(target_locale)
	var fallback_path: String = LanguagesScript.path_for(fallback_locale)
	if FileAccess.file_exists(fallback_path):
		if not _language_fallback_logged:
			print("[I18N] Missing translation resource ", requested_path, ". Fallback locale: ", fallback_locale)
			_language_fallback_logged = true
		return fallback_locale
	if not _language_fallback_logged:
		print("[I18N] Missing translation resources for locales: ", target_locale, " and ", fallback_locale)
		_language_fallback_logged = true
	return target_locale

func _emit_settings_changed() -> void:
	if GameEvents.has_signal("settings_changed"):
		var payload: Dictionary = {
			"language": SaveManager.get_language(),
			"brightness": SaveManager.get_brightness(),
			"master_volume": SaveManager.get_master_volume(),
			"music_volume": SaveManager.get_music_volume(),
			"fullscreen": SaveManager.get_fullscreen(),
			"window_resolution": SaveManager.get_window_resolution(),
		}
		GameEvents.settings_changed.emit(payload)

func _update_fullscreen_toggle() -> void:
	fullscreen_toggle.set_pressed_no_signal(SaveManager.get_fullscreen())

func _on_fullscreen_toggled(toggled: bool) -> void:
	if _suppress_settings_events:
		return
	SaveManager.set_fullscreen(toggled)
	_apply_fullscreen(SaveManager.get_fullscreen())
	_emit_settings_changed()

func _on_settings_opened() -> void:
	_show_settings()
	_apply_saved_settings()

func _on_settings_closed() -> void:
	_show_menu()

func _process(delta: float) -> void:
	_menu_idle_time += delta
	if title_label != null:
		var pulse: float = MENU_TITLE_PULSE_BASE + (sin(_menu_idle_time * MENU_TITLE_PULSE_SPEED) * MENU_TITLE_PULSE_AMPLITUDE)
		title_label.modulate = Color(pulse, pulse, pulse, 1.0)
	if menu_center != null and menu_vbox != null and menu_vbox.visible:
		var bob_y: float = sin(_menu_idle_time * MENU_IDLE_BOB_SPEED) * MENU_IDLE_BOB_AMPLITUDE
		menu_center.position = _menu_center_base_position + Vector2(0.0, bob_y)

func _cache_menu_buttons() -> void:
	_menu_buttons = [
		continue_button,
		new_game_button,
		load_game_button,
		achievements_button,
		settings_button,
		credits_button,
		condanne_tab_button,
		museo_tab_button,
		back_button,
		credits_back_button,
		settings_back_button,
	]

func _wire_menu_button_animations() -> void:
	for button: Button in _menu_buttons:
		if button == null:
			continue
		var entered_callable: Callable = Callable(self, "_on_menu_button_hover").bind(button, true)
		if not button.mouse_entered.is_connected(entered_callable):
			button.mouse_entered.connect(entered_callable)
		var exited_callable: Callable = Callable(self, "_on_menu_button_hover").bind(button, false)
		if not button.mouse_exited.is_connected(exited_callable):
			button.mouse_exited.connect(exited_callable)
		var focus_entered_callable: Callable = Callable(self, "_on_menu_button_hover").bind(button, true)
		if not button.focus_entered.is_connected(focus_entered_callable):
			button.focus_entered.connect(focus_entered_callable)
		var focus_exited_callable: Callable = Callable(self, "_on_menu_button_hover").bind(button, false)
		if not button.focus_exited.is_connected(focus_exited_callable):
			button.focus_exited.connect(focus_exited_callable)

func _wire_menu_button_sfx() -> void:
	for button: Button in _menu_buttons:
		if button == null:
			continue
		var pressed_callable: Callable = Callable(self, "_on_menu_button_pressed").bind(button)
		if not button.pressed.is_connected(pressed_callable):
			button.pressed.connect(pressed_callable)

func _on_menu_button_hover(button: Button, active: bool) -> void:
	if button == null:
		return
	if active and not button.disabled:
		_play_sfx(&"button_hover")
	button.pivot_offset = button.size * 0.5
	var target_scale: Vector2 = Vector2(MENU_BUTTON_HOVER_SCALE, MENU_BUTTON_HOVER_SCALE) if active else Vector2.ONE
	var tween_key: int = button.get_instance_id()
	var existing_tween: Tween = _menu_button_tweens.get(tween_key, null) as Tween
	if existing_tween != null and existing_tween.is_valid():
		existing_tween.kill()
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.12)
	_menu_button_tweens[tween_key] = tween

func _on_menu_button_pressed(button: Button) -> void:
	if button == null or button.disabled:
		return
	if button == new_game_button:
		return
	_play_sfx(&"button_click")

func _play_sfx(cue: StringName) -> void:
	var sfx_bus: Node = get_node_or_null("/root/SfxBus")
	if sfx_bus == null or not sfx_bus.has_method("play_cue"):
		return
	sfx_bus.call("play_cue", cue)

