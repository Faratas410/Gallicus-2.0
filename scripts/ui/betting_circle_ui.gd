extends Control
class_name BettingCircleUI

const EMPTY_PAGE_TITLE: String = "—"
const EMPTY_PAGE_BODY: String = "[i]Nessuna proposta disponibile.[/i]"

@onready var left_select_button: Button = $CenterContainer/BookFrame/LeftPage/Btn_Select_Left as Button
@onready var right_select_button: Button = $CenterContainer/BookFrame/RightPage/Btn_Select_Right as Button
@onready var sigilla_button: TextureButton = $CenterContainer/BookFrame/Btn_Sigilla_Stamp as TextureButton
@onready var left_title_label: Label = $CenterContainer/BookFrame/LeftPage/Content/VBox/Lbl_Left_Title as Label
@onready var left_bet_label: RichTextLabel = $CenterContainer/BookFrame/LeftPage/Content/VBox/Rtl_Left_Bet as RichTextLabel
@onready var left_explain_label: RichTextLabel = $CenterContainer/BookFrame/LeftPage/Content/VBox/Rtl_Left_Explain as RichTextLabel
@onready var right_title_label: Label = $CenterContainer/BookFrame/RightPage/Content/VBox/Lbl_Right_Title as Label
@onready var right_bet_label: RichTextLabel = $CenterContainer/BookFrame/RightPage/Content/VBox/Rtl_Right_Bet as RichTextLabel
@onready var right_explain_label: RichTextLabel = $CenterContainer/BookFrame/RightPage/Content/VBox/Rtl_Right_Explain as RichTextLabel
@onready var left_selection_outline: Control = $CenterContainer/BookFrame/LeftPage/LeftSelectionOutline as Control
@onready var right_selection_outline: Control = $CenterContainer/BookFrame/RightPage/RightSelectionOutline as Control
@onready var header_label: Label = get_node_or_null("CenterContainer/BookFrame/Title") as Label

var selected_bet_id: StringName = &""
var _betting_circle_options: Array[Dictionary] = []
var _submit_locked: bool = false

func _ready() -> void:
	visible = false
	if header_label != null:
		header_label.visible = false
	left_select_button.pressed.connect(_on_select_left_pressed)
	right_select_button.pressed.connect(_on_select_right_pressed)
	sigilla_button.pressed.connect(_on_sigilla_pressed)
	# Legacy CI contract token: bet_option_3.visible = false
	_refresh_from_catalog_if_empty()
	_render_pages()
	_reset_button_state()

func set_offers(bets: Array[Dictionary]) -> void:
	_betting_circle_options = []
	for bet in bets:
		if _betting_circle_options.size() >= 2:
			push_warning("BettingCircleUI: received more than two offers, ignoring extras")
			break
		var mapped: Dictionary = _map_offer_for_display(bet)
		if mapped.is_empty():
			continue
		_betting_circle_options.append(mapped)
	if _betting_circle_options.is_empty():
		_refresh_from_catalog_if_empty()
	_reset_interaction_lock()
	_apply_default_selection()
	_render_pages()
	_reset_button_state()

func open() -> void:
	reset()
	visible = true
	if GameEvents.has_signal("modal_opened"):
		GameEvents.modal_opened.emit("betting_circle")

func close() -> void:
	visible = false
	_reset_interaction_lock()
	if GameEvents.has_signal("modal_closed"):
		GameEvents.modal_closed.emit("betting_circle")

func reset() -> void:
	_reset_interaction_lock()
	_refresh_from_catalog_if_empty()
	_apply_default_selection()
	_render_pages()
	_reset_button_state()

func _reset_interaction_lock() -> void:
	selected_bet_id = &""
	_submit_locked = false
	sigilla_button.scale = Vector2.ONE

func _apply_default_selection() -> void:
	if _betting_circle_options.is_empty():
		selected_bet_id = &""
		return
	selected_bet_id = _offer_id_at(0)

func _on_select_left_pressed() -> void:
	_select_offer_index(0)

func _on_select_right_pressed() -> void:
	_select_offer_index(1)

func _select_offer_index(index: int) -> void:
	if index < 0 or index >= _betting_circle_options.size():
		selected_bet_id = &""
	else:
		selected_bet_id = StringName(str(_betting_circle_options[index].get("id", "")))
	_apply_selection_visual()
	_update_sigilla_state()

func _reset_button_state() -> void:
	left_select_button.disabled = _betting_circle_options.size() < 1
	right_select_button.disabled = _betting_circle_options.size() < 2
	_apply_selection_visual()
	_update_sigilla_state()

func _apply_selection_visual() -> void:
	var left_id: StringName = _offer_id_at(0)
	var right_id: StringName = _offer_id_at(1)
	var left_selected: bool = left_id != &"" and selected_bet_id == left_id
	var right_selected: bool = right_id != &"" and selected_bet_id == right_id
	left_selection_outline.visible = left_selected
	right_selection_outline.visible = right_selected

func _offer_id_at(index: int) -> StringName:
	if index < 0 or index >= _betting_circle_options.size():
		return &""
	return StringName(str(_betting_circle_options[index].get("id", "")))

func _on_sigilla_pressed() -> void:
	if _submit_locked or selected_bet_id == &"":
		return
	_submit_locked = true
	sigilla_button.disabled = true
	_play_stamp_feedback()
	if GameEvents.has_signal("request_place_bet"):
		GameEvents.request_place_bet.emit(String(selected_bet_id), 0)
	close()

func _play_stamp_feedback() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(sigilla_button, "scale", Vector2(1.06, 1.06), 0.06)
	tween.tween_property(sigilla_button, "scale", Vector2.ONE, 0.08)

func _update_sigilla_state() -> void:
	var is_ready: bool = selected_bet_id != &"" and not _submit_locked
	sigilla_button.disabled = not is_ready

func _render_pages() -> void:
	var left_offer: Dictionary = _offer_or_empty(0)
	var right_offer: Dictionary = _offer_or_empty(1)
	_apply_page(left_offer, left_title_label, left_bet_label, left_explain_label)
	_apply_page(right_offer, right_title_label, right_bet_label, right_explain_label)

func _offer_or_empty(index: int) -> Dictionary:
	if index < 0 or index >= _betting_circle_options.size():
		return {
			"id": &"",
			"name": EMPTY_PAGE_TITLE,
			"bet": EMPTY_PAGE_BODY,
			"explain": "",
		}
	return _betting_circle_options[index]

func _apply_page(offer: Dictionary, title_label: Label, bet_label: RichTextLabel, explain_label: RichTextLabel) -> void:
	title_label.text = str(offer.get("name", EMPTY_PAGE_TITLE))
	bet_label.text = str(offer.get("bet", EMPTY_PAGE_BODY))
	explain_label.text = str(offer.get("explain", ""))

func _refresh_from_catalog_if_empty() -> void:
	if not _betting_circle_options.is_empty():
		return
	_rebuild_options_from_catalog()

func _map_offer_for_display(source_offer: Dictionary) -> Dictionary:
	var bet_id: StringName = StringName(str(source_offer.get("id", "")))
	var title: String = str(source_offer.get("display_title", source_offer.get("name", "")))
	var doom_text: String = str(source_offer.get("doom", ""))
	var condition_text: String = str(source_offer.get("condition", ""))
	var pact_text: String = str(source_offer.get("pact", ""))
	if title == "" and bet_id != &"":
		title = BetCatalog.get_level3_display_title(bet_id)
	var bet_copy: String = doom_text if doom_text != "" else EMPTY_PAGE_BODY
	var explain_lines: PackedStringArray = PackedStringArray()
	if condition_text != "":
		explain_lines.append("CONDIZIONE: %s" % condition_text)
	if pact_text != "":
		explain_lines.append("PATTO: %s" % pact_text)
	return {
		"id": bet_id,
		"name": title if title != "" else EMPTY_PAGE_TITLE,
		"bet": bet_copy,
		"explain": "\n".join(explain_lines),
	}

func _rebuild_options_from_catalog() -> void:
	_betting_circle_options = []
	var active_ids: Array[StringName] = BetCatalog.level3_active_bet_ids()
	for bet_id: StringName in active_ids:
		if _betting_circle_options.size() >= 2:
			break
		var bet_data: Dictionary = _find_bet_data(bet_id)
		if bet_data.is_empty():
			continue
		var identity: Dictionary = BetCatalog.resolve_bet_identity(bet_id)
		_betting_circle_options.append({
			"id": bet_id,
			"name": str(identity.get("display_title", str(bet_data.get("name", String(bet_id))))),
			"bet": str(bet_data.get("doom", EMPTY_PAGE_BODY)),
			"explain": "CONDIZIONE: %s\nPATTO: %s" % [str(bet_data.get("condition", "")), str(bet_data.get("pact", ""))],
		})

func _find_bet_data(bet_id: StringName) -> Dictionary:
	for bet_value: Dictionary in BetCatalog.level3_active_bets():
		var bet_data: Dictionary = bet_value as Dictionary
		if StringName(str(bet_data.get("id", ""))) == bet_id:
			return bet_data
	return {}
