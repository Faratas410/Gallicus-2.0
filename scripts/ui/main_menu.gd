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
const BetCatalogScript = preload("res://scripts/content/bet_catalog.gd")
const ArenaCharacters = preload("res://scripts/content/arena_characters.gd")
const FinalEra = preload("res://scripts/content/final_era.gd")
const UIFactoryScript = preload("res://scripts/ui/ui_factory.gd")
const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const Palette = preload("res://scripts/ui/manifesto_palette.gd")
const LanguagesScript = preload("res://assets/i18n/languages.gd")
const ARENA_THRESHOLD_STYLE_CROSSED: StyleBox = preload("res://assets/ui/official/objects/arena_threshold/sb_arena_threshold_crossed.tres")
const ARENA_THRESHOLD_STYLE_DISABLED: StyleBox = preload("res://assets/ui/official/objects/arena_threshold/sb_arena_threshold_disabled.tres")
const ARENA_THRESHOLD_CROSSED_META: StringName = &"arena_threshold_crossed"

@onready var menu_vbox: VBoxContainer = get_node("CenterContainer/MenuVBox") as VBoxContainer
@onready var achievements_panel: Control = get_node("AchievementsPanel") as Control
@onready var credits_panel: Control = get_node("CreditsPanel") as Control
@onready var settings_panel: Control = get_node("SettingsPanel") as Control
@onready var title_artwork: TextureRect = get_node("CenterContainer/MenuVBox/TitlePanel/TitleArtwork") as TextureRect
@onready var tagline_label: Label = get_node("CenterContainer/MenuVBox/Tagline") as Label
@onready var settings_title: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsTitlePanel/SettingsTitle") as Label
@onready var brightness_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/BrightnessLabelPanel/BrightnessLabel") as Label
@onready var language_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/LanguageLabelPanel/LanguageLabel") as Label
@onready var volume_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/VolumeLabelPanel/VolumeLabel") as Label
@onready var music_volume_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/MusicVolumeLabelPanel/MusicVolumeLabel") as Label
@onready var sfx_volume_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/SfxVolumeLabelPanel/SfxVolumeLabel") as Label
@onready var sfx_volume_label_panel: PanelContainer = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/SfxVolumeLabelPanel") as PanelContainer
@onready var resolution_label: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ResolutionLabelPanel/ResolutionLabel") as Label
@onready var continue_button: Button = get_node("CenterContainer/MenuVBox/ContinueButton") as Button
@onready var continue_hint_panel: PanelContainer = get_node("CenterContainer/MenuVBox/ContinueHintPanel") as PanelContainer
@onready var continue_hint_label: Label = get_node("CenterContainer/MenuVBox/ContinueHintPanel/ContinueHintLabel") as Label
@onready var new_game_button: Button = get_node("CenterContainer/MenuVBox/NewGameButton") as Button
@onready var load_game_button: Button = get_node("CenterContainer/MenuVBox/LoadGameButton") as Button
@onready var achievements_button: Button = get_node("CenterContainer/MenuVBox/UtilityRow/AchievementsButton") as Button
@onready var settings_button: Button = get_node("CenterContainer/MenuVBox/UtilityRow/SettingsButton") as Button
@onready var credits_button: Button = get_node("CenterContainer/MenuVBox/UtilityRow/CreditsButton") as Button
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
@onready var sfx_volume_slider: HSlider = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/SfxVolumeSlider") as HSlider
@onready var sfx_volume_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsRightColumn/SfxVolumeValuePanel/SfxVolumeValue") as Label
@onready var resolution_option: OptionButton = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ResolutionOption") as OptionButton
@onready var resolution_value: Label = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ResolutionValuePanel/ResolutionValue") as Label
@onready var fullscreen_toggle: CheckBox = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/SchermoInteroToggle") as CheckBox
@onready var reduced_motion_toggle: CheckBox = get_node("SettingsPanel/SettingsCenter/SettingsVBox/SettingsColumns/SettingsLeftColumn/ReducedMotionToggle") as CheckBox
@onready var brightness_modulate: CanvasModulate = get_node_or_null("../../BrightnessModulate") as CanvasModulate
@onready var brightness_overlay: ColorRect = get_node_or_null("../../BrightnessOverlayLayer/BrightnessOverlay") as ColorRect

const ACHIEVEMENTS_TAB_CONDANNE: StringName = &"CONDANNE"
const ACHIEVEMENTS_TAB_MUSEO: StringName = &"MUSEO"
const ARCHIVE_TAB_WIDTH: float = 220.0
const CONDANNA_UNLOCKED_ALPHA: float = 1.0
const CONDANNA_LOCKED_ALPHA: float = 0.78
const MENU_TITLE_PULSE_SPEED: float = 1.8
const MENU_TITLE_PULSE_BASE: float = 0.95
const MENU_TITLE_PULSE_AMPLITUDE: float = 0.05
const SETTINGS_RESOLUTIONS: Array[String] = [
	"960x540",
	"1280x720",
	"1600x900",
	"1920x1080",
]
const RunPhaseContractScript = preload("res://scripts/contracts/run_phase_contract.gd")
const MENU_TAGLINE: String = "L'arena dimentica. Il Registro no."
const MENU_RETURNED_RUN_HINT: String = "Il tuo passaggio è registrato."

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
var reset_campaign_button: Button = null
var _reset_campaign_armed: bool = false

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
	_build_reset_campaign_button()
	_cache_menu_buttons()
	_apply_manifesto_skin()
	_wire_menu_button_animations()
	_wire_menu_button_sfx()
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
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_volume_slider.focus_entered.connect(_on_sfx_focus_changed.bind(true))
	sfx_volume_slider.focus_exited.connect(_on_sfx_focus_changed.bind(false))
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	reduced_motion_toggle.toggled.connect(_on_reduced_motion_toggled)
	_configure_focus_order()
		# TranslationServer has no translation-changed signal to connect here.
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
	if GameEvents.has_signal("campaign_reset"):
		var campaign_reset_callable: Callable = Callable(self, "_on_campaign_reset")
		if not GameEvents.campaign_reset.is_connected(campaign_reset_callable):
			GameEvents.campaign_reset.connect(campaign_reset_callable)
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
		if _load_imported_translation(path, locale):
			return
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

func _load_imported_translation(csv_path: String, locale: String) -> bool:
	var translation_path: String = _compiled_translation_path(csv_path, locale)
	if not ResourceLoader.exists(translation_path):
		return false
	var resource: Resource = ResourceLoader.load(translation_path, "Translation")
	var translation: Translation = resource as Translation
	if translation == null:
		push_warning("[I18N] Imported translation has an invalid type: %s" % translation_path)
		return false
	TranslationServer.add_translation(translation)
	return true

func _compiled_translation_path(csv_path: String, locale: String) -> String:
	return "%s.%s.translation" % [csv_path.get_basename(), locale]

func _translation_resource_exists(csv_path: String, locale: String) -> bool:
	return FileAccess.file_exists(csv_path) or ResourceLoader.exists(
		_compiled_translation_path(csv_path, locale)
	)

func _show_menu() -> void:
	menu_vbox.visible = true
	_set_arena_threshold_crossed_state(false)
	achievements_panel.visible = false
	credits_panel.visible = false
	settings_panel.visible = false
	condanna_tooltip.visible = false
	_refresh_continue_button()
	call_deferred("_focus_main_menu")

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
	_build_museo_list()
	_set_achievements_tab(ACHIEVEMENTS_TAB_CONDANNE)
	_refresh_condanne_visuals()
	call_deferred("_focus_first_available", [condanne_tab_button, museo_tab_button, back_button])

func _show_credits() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = false
	credits_panel.visible = true
	settings_panel.visible = false
	call_deferred("_focus_first_available", [credits_back_button])

func _show_settings() -> void:
	menu_vbox.visible = false
	achievements_panel.visible = false
	credits_panel.visible = false
	settings_panel.visible = true
	_disarm_reset_campaign()
	call_deferred("_focus_first_available", [language_option])

func _build_reset_campaign_button() -> void:
	# Built in code so the scene stays untouched; it sits beside TORNA AL MENU.
	reset_campaign_button = Button.new()
	reset_campaign_button.name = "ResetCampaignButton"
	reset_campaign_button.custom_minimum_size = Vector2(280, 52)
	reset_campaign_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var row: Node = settings_back_button.get_parent()
	row.add_child(reset_campaign_button)
	row.move_child(reset_campaign_button, 0)
	(row as HBoxContainer).add_theme_constant_override("separation", 24)
	reset_campaign_button.pressed.connect(_on_reset_campaign_pressed)
	_disarm_reset_campaign()

func _disarm_reset_campaign() -> void:
	_reset_campaign_armed = false
	if reset_campaign_button == null:
		return
	reset_campaign_button.disabled = false
	reset_campaign_button.text = tr("AZZERA LA CAMPAGNA")
	reset_campaign_button.tooltip_text = tr("Riparte tutto: Registro, conto di Vessa, scala dei bandi, racconti e Archivio delle condanne. Restano solo le impostazioni.")

func _on_reset_campaign_pressed() -> void:
	# Two presses: the first arms the button, the second asks RunManager to reset.
	if not _reset_campaign_armed:
		_reset_campaign_armed = true
		reset_campaign_button.text = tr("CONFERMA: AZZERA")
		return
	_reset_campaign_armed = false
	if GameEvents.has_signal("request_reset_campaign"):
		GameEvents.request_reset_campaign.emit()

func _on_campaign_reset() -> void:
	_disarm_reset_campaign()
	_refresh_condanne_visuals()
	# The menu hint waits for TORNA AL MENU; the button itself confirms the reset.
	_menu_next_step_hint = tr("Campagna azzerata. Restano solo le impostazioni.")
	if settings_panel.visible:
		reset_campaign_button.text = tr("CAMPAGNA AZZERATA")
		reset_campaign_button.disabled = true
		return
	visible = true
	_show_menu()

func _disable_unavailable_buttons() -> void:
	load_game_button.disabled = true
	load_game_button.visible = false
	load_game_button.tooltip_text = tr("Funzione disattiva in L3.")

func _build_condanne_list() -> void:
	if condanne_populated:
		return
	var condanne: Array[CondannaData] = CondannaDataScript.defaults()
	for condanna in condanne:
		var entry_panel: PanelContainer = _create_condanna_entry_panel("- %s" % tr(condanna.title))
		var entry_label: Label = entry_panel.get_child(0) as Label
		entry_label.set_meta("source_title", condanna.title)
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

func _final_era_lines(record: Dictionary, seat_known: bool) -> Array[String]:
	# Vessa's last figure, Lauro's last strophe and what Nerio copied, as recorded.
	var lines: Array[String] = []
	var ledger := str(record.get("ledger", ""))
	if FinalEra.RESULTS.has(ledger):
		lines.append(tr(str(FinalEra.RESULTS[ledger])))
		var best: Dictionary = record.get("gesta_best", {}) as Dictionary
		if ledger == "lauro" and int(best.get("glory", 0)) > 0:
			lines.append(tr(FinalEra.WRITTEN_GESTA) % [int(best.glory), maxi(int(best.get("arenas", 1)), 1)])
	var bando := str(record.get("bando", ""))
	if FinalEra.BANDO.has(bando):
		var verses: Array[String] = []
		for line_value: Variant in record.get("strophe", []) as Array:
			var line: Dictionary = line_value as Dictionary
			var verse: String = tr(str(line.get("key", "")))
			if int(line.get("value", -1)) >= 0 and verse.contains("%d"):
				verse = verse % int(line.value)
			verses.append(verse)
		lines.append("%s %s" % [tr(str(FinalEra.BANDO[bando])), " ".join(verses)])
	var copy := str(record.get("copy", ""))
	if FinalEra.RESULTS.has(copy):
		lines.append(tr(str(FinalEra.RESULTS[copy])))
		for option: String in ["seat", "gesta"]:
			if option != copy and (option == "gesta" or seat_known):
				lines.append(tr(str(FinalEra.KEEPERS[option])))
	return lines

func _build_museo_list() -> void:
	if museo_vbox == null:
		return
	for child in museo_vbox.get_children():
		child.queue_free()
	var pact_ids: Array[StringName] = []
	var arena_themes: Array[StringName] = []
	var harsh_unlocked: bool = false
	if _run_manager_port != null:
		pact_ids = _run_manager_port.get_available_level3_pacts()
		arena_themes = _run_manager_port.get_available_arena_themes()
		harsh_unlocked = _run_manager_port.is_harsh_crowd_unlocked()
	_add_museo_item(tr("Il fascicolo conserva gli esiti. Qui ritrovi i vincoli delle promesse disponibili."))
	if _run_manager_port != null:
		var seat_choice: String = str(_run_manager_port.get_seat_case_record().get("choice", ""))
		if seat_choice in ["reserve", "witness"]:
			_add_museo_header(tr("IL POSTO MISURATO"))
			_add_museo_item(tr("Il posto e' stato riservato con il conto di Vessa.") if seat_choice == "reserve" else tr("Dima ha testimoniato davanti alla gradinata per il posto vuoto."))
			if bool(_run_manager_port.get_seat_inquiry_record().get("complete", false)):
				_add_museo_item(tr("La copia è incompleta; il nome di chi sedeva non è provato."))
			var copy_choice := _run_manager_port.get_seat_copy_record()
			if copy_choice == "copy":
				_add_museo_item(tr("Dima tiene l'annotazione. Nerio ne riceve una copia nel suo fascicolo."))
				if _run_manager_port.get_seat_copy_discount_active():
					_add_museo_item(tr("La polizza costa 1 Denaro in meno fino al prossimo Silenzio."))
			elif copy_choice == "keep":
				_add_museo_item(tr("Dima tiene l'annotazione. Il fascicolo di Nerio resta senza quella copia."))
		var final_lines := _final_era_lines(_run_manager_port.get_final_era_record(), seat_choice != "")
		if not final_lines.is_empty():
			_add_museo_header(tr("L'ULTIMA ERA"))
			for line: String in final_lines:
				_add_museo_item(line)
	_add_museo_header(tr("PRESENZE DELL’ARENA"))
	for character: Dictionary in ArenaCharacters.CHARACTERS:
		_add_character_entry(character)
	_add_museo_header(tr("PATTI DISPONIBILI"))
	if pact_ids.is_empty():
		_add_museo_item(tr("- Nessun patto disponibile."))
	else:
		for pact_id in pact_ids:
			var pact_title: String = _get_pact_display_name(pact_id)
			var open_step: int = _run_manager_port.get_level3_pact_open_step(pact_id) if _run_manager_port != null else 0
			if open_step > 0:
				# A sealed page: its name and the ladder step that opens it, not its terms.
				_add_museo_item("%s\n%s" % [tr(pact_title), tr("Pagina sigillata: si apre al gradino %d della scala dei bandi.") % open_step])
			else:
				_add_museo_item("%s\n%s" % [tr(pact_title), tr(BetCatalogScript.get_level3_display_subtitle(pact_id))])
	_add_museo_header(tr("ARENE TEMATICHE"))
	if arena_themes.is_empty():
		_add_museo_item(tr("- Nessuna arena disponibile."))
	else:
		for theme_id in arena_themes:
			var theme_data: Dictionary = _arena_themes.get_theme(theme_id)
			var theme_title: String = str(theme_data.get("title", ""))
			if theme_title == "":
				theme_title = str(theme_id)
			_add_museo_item("- %s" % tr(theme_title))
	_add_museo_header(tr("VOCI DEL PUBBLICO"))
	_add_museo_item(tr("La gradinata ricorda l'esposizione. Le sue voci si sono fatte più dure.") if harsh_unlocked else tr("La gradinata accompagna i gesti. Le sue voci non sono il responso del Registro."))

func _add_museo_header(text: String) -> void:
	var entry_panel: PanelContainer = _create_museo_entry_panel(text, true)
	museo_vbox.add_child(entry_panel)

func _add_character_entry(character: Dictionary) -> void:
	var entry := HBoxContainer.new()
	entry.name = "Presence_" + str(character.id)
	entry.set_meta("character_id", str(character.id))
	entry.add_theme_constant_override("separation", 24)
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.texture = load(str(character.portrait)) as Texture2D
	portrait.material = preload("res://assets/ui/official/portrait_grounding.tres")
	portrait.custom_minimum_size = Vector2(112, 168)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_child(portrait)
	var biography := Label.new()
	biography.name = "Biography"
	# The assembled name/role/biography is already localized. Letting Label
	# translate its paragraphs again can select a different fallback locale.
	biography.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	biography.text = "%s — %s\n%s" % [str(character.name), tr(str(character.role)), tr(str(character.description))]
	biography.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	biography.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	biography.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	Kit.apply_body(biography)
	biography.add_theme_font_size_override("font_size", Kit.CONTROL_SIZE)
	biography.add_theme_constant_override("line_spacing", 5)
	biography.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_child(biography)
	museo_vbox.add_child(entry)

func _add_museo_item(text: String) -> void:
	var entry_panel: PanelContainer = _create_museo_entry_panel(text)
	museo_vbox.add_child(entry_panel)

func _create_museo_entry_panel(text: String, header: bool = false) -> PanelContainer:
	var entry_panel: PanelContainer = UIFactoryScript.create_sprite_label(text) as PanelContainer
	entry_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var entry_label: Label = entry_panel.get_child(0) as Label
	entry_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Read-only consultation sheet: paper and ink, no confirmation mark.
	# Section headers stay on the ink page in the title role.
	if header:
		Kit.apply_title(entry_label)
	else:
		Kit.apply_inset(entry_panel)
		Kit.apply_body(entry_label, Palette.INK)
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
	condanne_tab_button.toggle_mode = true
	museo_tab_button.toggle_mode = true
	condanne_tab_button.set_pressed_no_signal(show_condanne)
	museo_tab_button.set_pressed_no_signal(not show_condanne)
	# A consulted tab is selected (rule), never registered (mark).
	Kit.apply_secondary_button(condanne_tab_button, true, show_condanne)
	Kit.apply_secondary_button(museo_tab_button, true, not show_condanne)
	# Compact actions wrap by word; tabs in an HBox need a width or they
	# collapse to a tall empty strip. One line, same size for both.
	for tab: Button in [condanne_tab_button, museo_tab_button]:
		tab.autowrap_mode = TextServer.AUTOWRAP_OFF
		tab.custom_minimum_size = Vector2(ARCHIVE_TAB_WIDTH, 0)
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
	entry_label.text = "- %s" % tr(str(entry_label.get_meta("source_title", "")))
	var unlocked: bool = SaveManager.has_unlocked(condanna_id)
	var alpha: float = CONDANNA_UNLOCKED_ALPHA if unlocked else CONDANNA_LOCKED_ALPHA
	entry_label.modulate = Color(1.0, 1.0, 1.0, alpha)
	# Locked entries also lose the paper (shape) and drop to the muted role.
	var entry_panel := entry_label.get_parent() as Control
	if unlocked:
		Kit.apply_inset(entry_panel)
		Kit.apply_body(entry_label, Palette.INK)
	else:
		Kit.apply_panel(entry_panel, &"ink")
		Kit.apply_muted(entry_label)

func _on_condanna_registered(condanna_id: StringName) -> void:
	if condanna_entries.is_empty():
		return
	var entry_label: Label = condanna_entries.get(condanna_id) as Label
	if entry_label != null:
		_apply_condanna_style(condanna_id, entry_label)

func _on_condanna_mouse_entered(condanna: CondannaData) -> void:
	# A locked condanna says how it is earned and keeps its lore for later.
	var tooltip_label_text: String = "%s\n\n%s\n%s" % [
		tr(condanna.title),
		tr("Come si ottiene:"),
		tr(condanna.condition_text),
	]
	if SaveManager.has_unlocked(condanna.id):
		tooltip_label_text = "%s\n\n%s\n%s\n\n%s" % [
			tr(condanna.title),
			tr("Come e' stata ottenuta:"),
			tr(condanna.condition_text),
			tr(condanna.lore_text)
		]
	tooltip_label.text = tooltip_label_text
	condanna_tooltip.visible = true
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	call_deferred("_place_condanna_tooltip", mouse_pos)

func _place_condanna_tooltip(anchor: Vector2) -> void:
	condanna_tooltip.reset_size()
	var viewport_size: Vector2 = get_viewport_rect().size
	var desired: Vector2 = anchor + Vector2(16, 16)
	condanna_tooltip.position = Vector2(
		clampf(desired.x, 16.0, maxf(16.0, viewport_size.x - condanna_tooltip.size.x - 16.0)),
		clampf(desired.y, 16.0, maxf(16.0, viewport_size.y - condanna_tooltip.size.y - 16.0))
	)

func _on_condanna_mouse_exited() -> void:
	condanna_tooltip.visible = false

func _refresh_continue_button() -> void:
	var can_start: bool = _run_manager_port != null and _run_manager_port.can_start_run()
	new_game_button.disabled = not can_start
	var has_run_save: bool = SaveManager.has_run_save()
	has_run_save = has_run_save and can_start
	continue_button.disabled = not has_run_save
	continue_button.visible = has_run_save
	var has_menu_hint: bool = _menu_next_step_hint != ""
	continue_hint_panel.visible = has_menu_hint
	continue_hint_label.visible = has_menu_hint
	if has_menu_hint:
		continue_hint_label.text = _menu_next_step_hint
		_menu_next_step_hint = ""
		return
	continue_hint_label.text = ""

func _format_continue_reject_reason(reason: String) -> String:
	if reason == "missing_run_save":
		return tr("Nessun salvataggio valido disponibile. Inizia un nuovo percorso.")
	if reason == "corrupt_run_save" or reason == "run_save_unreadable":
		return tr("Salvataggio corrotto: i file sono stati messi in quarantena.")
	if reason == "missing_backup_save":
		return tr("Salvataggio corrotto e backup non disponibile.")
	if reason == "backup_recovery_write_failed":
		return tr("Backup valido trovato, ma il ripristino non è riuscito.")
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
	_menu_next_step_hint = _format_continue_reject_reason(reason)
	visible = true
	_show_menu()

func _on_continue_pressed() -> void:
	if continue_button.disabled:
		return
	if GameEvents != null and GameEvents.has_signal("request_continue_run"):
		if _run_manager_port == null or not _run_manager_port.has_manager():
			continue_hint_label.text = tr("In arrivo.")
			continue_hint_panel.visible = true
			continue_hint_label.visible = true
			return
		_hide_menu()
		GameEvents.request_continue_run.emit()
	else:
		continue_hint_label.text = tr("In arrivo.")
		continue_hint_panel.visible = true
		continue_hint_label.visible = true

func _on_new_game_pressed() -> void:
	if _run_manager_port == null or not _run_manager_port.can_start_run():
		return
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
	condanne_tab_button.grab_focus()

func _on_museo_tab_pressed() -> void:
	_set_achievements_tab(ACHIEVEMENTS_TAB_MUSEO)
	museo_tab_button.grab_focus()

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
	var saved_sfx_volume: float = SaveManager.get_sfx_volume()
	sfx_volume_slider.set_value_no_signal(saved_sfx_volume)
	_update_sfx_volume_label(saved_sfx_volume)
	var saved_resolution: String = SaveManager.get_window_resolution()
	_select_resolution(saved_resolution)
	_apply_window_resolution(saved_resolution)
	var saved_fullscreen: bool = SaveManager.get_fullscreen()
	fullscreen_toggle.set_pressed_no_signal(saved_fullscreen)
	_apply_fullscreen(saved_fullscreen)
	reduced_motion_toggle.set_pressed_no_signal(SaveManager.get_reduced_motion())
	_update_toggle_labels()
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
		brightness_value.text = tr("Luminosità: %.2f") % value

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

func _on_sfx_volume_changed(value: float) -> void:
	if _suppress_settings_events:
		return
	SaveManager.set_sfx_volume(value)
	var applied_value: float = SaveManager.get_sfx_volume()
	if not is_equal_approx(applied_value, value):
		sfx_volume_slider.set_value_no_signal(applied_value)
	_update_sfx_volume_label(applied_value)
	_emit_settings_changed()

func _update_sfx_volume_label(value: float) -> void:
	if sfx_volume_value != null:
		sfx_volume_value.text = tr("Effetti: %d%%") % int(round(value * 100.0))

func _on_sfx_focus_changed(active: bool) -> void:
	if sfx_volume_label_panel == null:
		return
	sfx_volume_label_panel.add_theme_stylebox_override("panel", Kit.focus_rule() if active else StyleBoxEmpty.new())

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
	_refresh_condanne_visuals()
	if achievements_panel != null and achievements_panel.visible:
		_build_museo_list()
	get_node("CreditsPanel/CreditsCenter/CreditsVBox/CreditsBodyPanel/CreditsBody").text = tr("CREDITS_BODY")
	if tagline_label != null:
		tagline_label.text = tr(MENU_TAGLINE)
	if continue_button != null:
		continue_button.text = tr("RIPRENDI IL PERCORSO")
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
		brightness_label.text = tr("LUMINOSITÀ")
	if language_label != null:
		language_label.text = tr("LINGUA")
	if volume_label != null:
		volume_label.text = tr("VOLUME MASTER")
	if music_volume_label != null:
		music_volume_label.text = tr("VOLUME MUSICA")
	if sfx_volume_label != null:
		sfx_volume_label.text = tr("VOLUME EFFETTI")
	if resolution_label != null:
		resolution_label.text = tr("RISOLUZIONE")
	_update_toggle_labels()
	if back_button != null:
		back_button.text = tr("TORNA AL MENU")
	if credits_back_button != null:
		credits_back_button.text = tr("TORNA AL MENU")
	if settings_back_button != null:
		settings_back_button.text = tr("TORNA AL MENU")
	if reset_campaign_button != null:
		_disarm_reset_campaign()
	_update_language_label()
	if master_volume_slider != null:
		_update_volume_label(master_volume_slider.value)
	if music_volume_slider != null:
		_update_music_volume_label(music_volume_slider.value)
	if sfx_volume_slider != null:
		_update_sfx_volume_label(sfx_volume_slider.value)
	if brightness_slider != null:
		_apply_brightness(brightness_slider.value)
	if resolution_value != null:
		_update_resolution_label()

func _resolve_available_locale(target_locale: String) -> String:
	var requested_path: String = LanguagesScript.path_for(target_locale)
	if _translation_resource_exists(requested_path, target_locale):
		return target_locale
	var fallback_locale: String = LanguagesScript.fallback_locale(target_locale)
	var fallback_path: String = LanguagesScript.path_for(fallback_locale)
	if _translation_resource_exists(fallback_path, fallback_locale):
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
			"sfx_volume": SaveManager.get_sfx_volume(),
			"reduced_motion": SaveManager.get_reduced_motion(),
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
	_update_toggle_labels()
	_emit_settings_changed()

func _on_reduced_motion_toggled(toggled: bool) -> void:
	if _suppress_settings_events:
		return
	SaveManager.set_reduced_motion(toggled)
	_update_toggle_labels()
	_reset_menu_motion_if_reduced()
	_emit_settings_changed()

func _update_toggle_labels() -> void:
	if fullscreen_toggle != null:
		# The incised box already shows the state; no bracket prefix in the label.
		fullscreen_toggle.text = tr("SCHERMO INTERO")
	if reduced_motion_toggle != null:
		reduced_motion_toggle.text = tr("MOVIMENTO RIDOTTO")

func _on_settings_opened() -> void:
	_show_settings()
	_apply_saved_settings()

func _on_settings_closed() -> void:
	_show_menu()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	if SaveManager != null and SaveManager.get_reduced_motion():
		_reset_menu_motion_if_reduced()
		return
	_menu_idle_time += delta
	if title_artwork != null:
		var pulse: float = MENU_TITLE_PULSE_BASE + (sin(_menu_idle_time * MENU_TITLE_PULSE_SPEED) * MENU_TITLE_PULSE_AMPLITUDE)
		title_artwork.modulate = Color(pulse, pulse, pulse, 1.0)

func _reset_menu_motion_if_reduced() -> void:
	if SaveManager == null or not SaveManager.get_reduced_motion():
		return
	if title_artwork != null:
		title_artwork.modulate = Color.WHITE
	for button: Button in _menu_buttons:
		if button != null:
			button.scale = Vector2.ONE

func _configure_focus_order() -> void:
	_set_focus_cycle([continue_button, new_game_button, achievements_button, settings_button, credits_button])
	_set_focus_cycle([
		language_option,
		resolution_option,
		fullscreen_toggle,
		reduced_motion_toggle,
		brightness_slider,
		master_volume_slider,
		music_volume_slider,
		sfx_volume_slider,
		reset_campaign_button,
		settings_back_button,
	])
	_set_focus_cycle([condanne_tab_button, museo_tab_button, back_button])

func _set_focus_cycle(controls: Array[Control]) -> void:
	var valid_controls: Array[Control] = []
	for control: Control in controls:
		if control != null:
			control.focus_mode = Control.FOCUS_ALL
			valid_controls.append(control)
	if valid_controls.size() < 2:
		return
	for index: int in range(valid_controls.size()):
		var control: Control = valid_controls[index]
		var next_control: Control = valid_controls[(index + 1) % valid_controls.size()]
		var previous_control: Control = valid_controls[(index - 1 + valid_controls.size()) % valid_controls.size()]
		control.focus_next = control.get_path_to(next_control)
		control.focus_previous = control.get_path_to(previous_control)

func _focus_main_menu() -> void:
	_focus_first_available([continue_button, new_game_button, achievements_button, settings_button, credits_button])

func _focus_first_available(controls: Array) -> void:
	for candidate: Variant in controls:
		var control: Control = candidate as Control
		if control != null and control.visible and not control.is_in_group("disabled"):
			var button: BaseButton = control as BaseButton
			if button != null and button.disabled:
				continue
			control.grab_focus()
			return

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if settings_panel.visible or credits_panel.visible or achievements_panel.visible:
		_show_menu()
		get_viewport().set_input_as_handled()

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
		reset_campaign_button,
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
	# UI canon: no scale or offset on hover/focus. The stylus accent belongs
	# to the kit surface and already honours reduced motion.
	button.scale = Vector2.ONE

func _on_menu_button_pressed(button: Button) -> void:
	if button == null or button.disabled:
		return
	if button == new_game_button:
		return
	_play_sfx(&"button_click")

func _play_sfx(cue: StringName) -> void:
	var feedback: Node = get_tree().get_first_node_in_group("ritual_feedback")
	if feedback != null:
		feedback.call("play_cue", cue, get_viewport().gui_get_focus_owner())
	var sfx_bus: Node = get_node_or_null("/root/SfxBus")
	if sfx_bus == null or not sfx_bus.has_method("play_cue"):
		return
	sfx_bus.call("play_cue", cue)

func _apply_manifesto_skin() -> void:
	# Atto a stampa, packages 5-6: menu, utilities, settings, credits, Archive.
	# The arena threshold keeps its object skin; only native commands migrate.
	new_game_button.add_theme_font_override("font", Kit.DISPLAY_FONT)
	new_game_button.add_theme_font_size_override("font_size", Kit.ACTION_COMPACT)
	Kit.apply_primary_button(continue_button)
	for menu_action: Button in [achievements_button, settings_button, credits_button]:
		# Regular-width serif must keep each short menu word on one line.
		menu_action.custom_minimum_size = Vector2(190, 50)
	for button: Button in [achievements_button, settings_button, credits_button, back_button, credits_back_button, reset_campaign_button, settings_back_button]:
		Kit.apply_secondary_button(button)
	for panel_path: String in ["AchievementsPanel/UtilitySurface", "CreditsPanel/UtilitySurface", "SettingsPanel/UtilitySurface"]:
		Kit.apply_panel(get_node(panel_path) as Control, &"ink")
	for title_path: String in [
		"AchievementsPanel/AchievementsCenter/AchievementsVBox/AchievementsTitlePanel/AchievementsTitle",
		"CreditsPanel/CreditsCenter/CreditsVBox/CreditsTitlePanel/CreditsTitle",
		"SettingsPanel/SettingsCenter/SettingsVBox/SettingsTitlePanel/SettingsTitle",
	]:
		var title := get_node(title_path) as Label
		(title.get_parent() as Control).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		Kit.apply_title(title)
	Kit.apply_body(get_node("CreditsPanel/CreditsCenter/CreditsVBox/CreditsBodyPanel/CreditsBody") as Label)
	Kit.apply_muted(get_node("AchievementsPanel/AchievementsCenter/AchievementsVBox/ArchivioDisclaimerPanel/ArchivioDisclaimer") as Label)
	Kit.apply_muted(continue_hint_label)
	for label: Label in [brightness_label, language_label, volume_label, music_volume_label, sfx_volume_label, resolution_label]:
		(label.get_parent() as Control).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		Kit.apply_body(label)
	for label: Label in [brightness_value, language_value, master_volume_value, music_volume_value, sfx_volume_value, resolution_value]:
		(label.get_parent() as Control).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		Kit.apply_muted(label)
		label.add_theme_font_size_override("font_size", Kit.CONTROL_SIZE)
	for slider: HSlider in [brightness_slider, master_volume_slider, music_volume_slider, sfx_volume_slider]:
		Kit.apply_slider(slider)
	for option: OptionButton in [language_option, resolution_option]:
		Kit.apply_option_button(option)
	for toggle: CheckBox in [fullscreen_toggle, reduced_motion_toggle]:
		Kit.apply_toggle(toggle)
	for scroll_path: String in [
		"AchievementsPanel/AchievementsCenter/AchievementsVBox/CondanneContainer/CondanneScroll",
		"AchievementsPanel/AchievementsCenter/AchievementsVBox/MuseoContainer/MuseoScroll",
	]:
		Kit.apply_scroll(get_node(scroll_path) as ScrollContainer)
	Kit.apply_tooltip(condanna_tooltip, tooltip_label)
