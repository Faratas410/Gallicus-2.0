extends Control
class_name BettingCircleUI

const EMPTY_PAGE_TITLE: String = "---"
const EMPTY_PAGE_BODY: String = "[i]Nessuna proposta disponibile.[/i]"
const SCREEN_TITLE: String = "SCEGLI LA VIA"
const SCREEN_SUBTITLE: String = "Ogni firma apre una promessa e una condanna."
const CLOSED_SCREEN_TITLE: String = "REGISTRO DELL'ARENA"
const CLOSED_SCREEN_SUBTITLE: String = "Apertura del verbale"
const REGISTRY_RITUAL_BACKGROUND: Texture2D = preload("res://assets/backgrounds/bg_registry_ritual.png")
const BOOK_TITLE_PULSE_SPEED: float = 1.15
const BOOK_DROP_OFFSET: Vector2 = Vector2(0.0, -34.0)
const BOOK_DROP_SECONDS: float = 0.62
const BOOK_OPEN_SECONDS: float = 0.48
const BOOK_SETTLE_SECONDS: float = 0.18
const BOOK_CONTENT_REVEAL_SECONDS: float = 0.36
const CONTRACT_WRITE_SECONDS: float = 2.25
const PAGE_IDLE_DRIFT_PIXELS: float = 1.4

@onready var left_select_button: Button = $CenterContainer/BookFrame/LeftPage/Btn_Select_Left as Button
@onready var right_select_button: Button = $CenterContainer/BookFrame/RightPage/Btn_Select_Right as Button
@onready var left_sign_button: Button = $CenterContainer/BookFrame/LeftPage/Btn_Sign_Left as Button
@onready var right_sign_button: Button = $CenterContainer/BookFrame/RightPage/Btn_Sign_Right as Button
@onready var left_sign_label: Label = $CenterContainer/BookFrame/LeftPage/Btn_Sign_Left/Lbl_Sign_Left as Label
@onready var right_sign_label: Label = $CenterContainer/BookFrame/RightPage/Btn_Sign_Right/Lbl_Sign_Right as Label
@onready var arena_background: TextureRect = $BettingArenaBackground as TextureRect
@onready var left_page: Control = $CenterContainer/BookFrame/LeftPage as Control
@onready var right_page: Control = $CenterContainer/BookFrame/RightPage as Control
@onready var left_contract_label: RichTextLabel = $CenterContainer/BookFrame/LeftPage/Content/Rtl_Left_Contract as RichTextLabel
@onready var right_contract_label: RichTextLabel = $CenterContainer/BookFrame/RightPage/Content/Rtl_Right_Contract as RichTextLabel
@onready var left_selection_outline: Control = $CenterContainer/BookFrame/LeftPage/LeftSelectionOutline as Control
@onready var right_selection_outline: Control = $CenterContainer/BookFrame/RightPage/RightSelectionOutline as Control
@onready var header_label: Label = get_node_or_null("CenterContainer/BookFrame/Title") as Label
@onready var book_frame: Control = $CenterContainer/BookFrame as Control
@onready var open_book_bg: Control = $CenterContainer/BookFrame/SpellbookBg as Control
@onready var closed_book_bg: Control = $CenterContainer/BookFrame/ClosedBookBg as Control
@onready var closed_intro: Control = $CenterContainer/BookFrame/ClosedIntro as Control
@onready var intro_text: Label = $CenterContainer/BookFrame/ClosedIntro/IntroText as Label
@onready var intro_body: Label = $CenterContainer/BookFrame/ClosedIntro/IntroBodyPanel/IntroBody as Label
@onready var intro_seal: Label = $CenterContainer/BookFrame/ClosedIntro/IntroSealPanel/IntroSeal as Label
@onready var open_book_button: Button = $CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book as Button
@onready var open_book_label: Label = $CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book/Lbl_Open_Book as Label

var selected_bet_id: StringName = &""
var _betting_circle_options: Array[Dictionary] = []
var _submit_locked: bool = false
var _opening_locked: bool = false
var _idle_time: float = 0.0
var _left_page_base_position: Vector2 = Vector2.ZERO
var _right_page_base_position: Vector2 = Vector2.ZERO
var _book_base_scale: Vector2 = Vector2.ONE
var _book_base_position: Vector2 = Vector2.ZERO
var _nodes_ready: bool = false
var _open_tween: Tween = null
var _contract_write_tween: Tween = null
var _book_content_nodes: Array[CanvasItem] = []
var _book_content_target_modulates: Dictionary = {}
var _awaiting_open_request: bool = false
var _arena_background_default_texture: Texture2D = null

func _ready() -> void:
	_nodes_ready = true
	visible = false
	_refresh_localized_text()
	left_select_button.pressed.connect(_on_select_left_pressed)
	right_select_button.pressed.connect(_on_select_right_pressed)
	left_sign_button.pressed.connect(_on_sign_left_pressed)
	right_sign_button.pressed.connect(_on_sign_right_pressed)
	if open_book_button != null:
		open_book_button.pressed.connect(_on_open_book_pressed)
	_wire_button_feedback_sfx()
	# Legacy CI contract token: bet_option_3.visible = false
	_refresh_from_catalog_if_empty()
	_render_pages()
	_reset_button_state()
	if left_page != null:
		_left_page_base_position = left_page.position
	if right_page != null:
		_right_page_base_position = right_page.position
	if book_frame != null:
		_book_base_scale = book_frame.scale
		_book_base_position = book_frame.position
	if arena_background != null:
		_arena_background_default_texture = arena_background.texture
	_build_book_content_node_list()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not _nodes_ready:
			return
		_refresh_localized_text()
		_render_pages()

func _refresh_localized_text() -> void:
	if header_label != null:
		header_label.visible = true
		header_label.text = "%s\n%s" % [tr(SCREEN_TITLE), tr(SCREEN_SUBTITLE)]
	if left_sign_label != null:
		left_sign_label.text = tr("FIRMA")
	if right_sign_label != null:
		right_sign_label.text = tr("FIRMA")
	if intro_text != null:
		intro_text.text = tr("IL REGISTRO E' CHIUSO")
	if intro_body != null:
		intro_body.text = tr("La pietra attende una firma.\nOgni patto lascia un segno.")
	if intro_seal != null:
		intro_seal.text = tr("I    II    III")
	if open_book_label != null:
		open_book_label.text = tr("APRI IL REGISTRO")

func _process(delta: float) -> void:
	if not visible:
		return
	_idle_time += delta
	if header_label != null:
		var pulse: float = 0.9 + (sin(_idle_time * BOOK_TITLE_PULSE_SPEED) * 0.1)
		header_label.modulate = Color(pulse, pulse, pulse, 1.0)
	_update_page_idle_motion()

func set_offers(bets: Array[Dictionary]) -> void:
	_betting_circle_options = []
	for bet in bets:
		if _betting_circle_options.size() >= 2:
			break
		var mapped: Dictionary = _map_offer_for_display(bet)
		if mapped.is_empty():
			continue
		if str(mapped.get("id", "")).strip_edges() == "":
			mapped["id"] = StringName("offer_%d" % _betting_circle_options.size())
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
	_show_closed_intro()
	if GameEvents.has_signal("modal_opened"):
		GameEvents.modal_opened.emit("betting_circle")

func close() -> void:
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	if _contract_write_tween != null and _contract_write_tween.is_valid():
		_contract_write_tween.kill()
	_awaiting_open_request = false
	_opening_locked = false
	_hide_closed_intro()
	_set_book_input_enabled(true)
	_show_book_open_state()
	_set_registry_background_active(false)
	_show_book_content_immediate()
	_show_contract_text_immediate()
	visible = false
	if left_page != null:
		left_page.position = _left_page_base_position
	if right_page != null:
		right_page.position = _right_page_base_position
	if book_frame != null:
		book_frame.scale = _book_base_scale
		book_frame.position = _book_base_position
	_reset_interaction_lock()
	if GameEvents.has_signal("modal_closed"):
		GameEvents.modal_closed.emit("betting_circle")

func reset() -> void:
	_reset_interaction_lock()
	_refresh_from_catalog_if_empty()
	_apply_default_selection()
	_render_pages()
	_reset_button_state()

func _play_open_animation() -> void:
	if book_frame == null:
		return
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	_book_base_position = book_frame.position
	_opening_locked = true
	_set_book_input_enabled(false)
	if _book_content_target_modulates.is_empty():
		_hide_book_content_for_opening()
	_hide_closed_intro()
	_show_book_closed_state()
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	book_frame.pivot_offset = book_frame.size * 0.5
	book_frame.position = _book_base_position + BOOK_DROP_OFFSET
	book_frame.scale = _book_base_scale * Vector2(0.92, 0.92)
	_open_tween = create_tween()
	_open_tween.set_trans(Tween.TRANS_QUAD)
	_open_tween.set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(book_frame, "position", _book_base_position, BOOK_DROP_SECONDS)
	_open_tween.parallel().tween_property(book_frame, "scale", _book_base_scale * Vector2(0.98, 0.98), BOOK_DROP_SECONDS)
	_open_tween.tween_callback(Callable(self, "_begin_book_open_swap"))
	_open_tween.tween_callback(Callable(self, "_show_book_open_shell"))
	_open_tween.set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(book_frame, "scale", _book_base_scale * Vector2(1.012, 1.012), BOOK_OPEN_SECONDS)
	_open_tween.parallel().tween_property(open_book_bg, "modulate:a", 1.0, BOOK_OPEN_SECONDS)
	_open_tween.parallel().tween_property(closed_book_bg, "modulate:a", 0.0, BOOK_OPEN_SECONDS)
	_open_tween.set_ease(Tween.EASE_IN_OUT)
	_open_tween.tween_property(book_frame, "scale", _book_base_scale, BOOK_SETTLE_SECONDS)
	_open_tween.tween_callback(Callable(self, "_reveal_book_content"))
	for node: CanvasItem in _book_content_nodes:
		var target_modulate: Color = _book_content_target_modulates.get(node, Color(1.0, 1.0, 1.0, 1.0)) as Color
		_open_tween.parallel().tween_property(node, "modulate", target_modulate, BOOK_CONTENT_REVEAL_SECONDS)
	_open_tween.tween_callback(Callable(self, "_start_contract_write_animation"))

func _show_closed_intro() -> void:
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	if _contract_write_tween != null and _contract_write_tween.is_valid():
		_contract_write_tween.kill()
	_awaiting_open_request = true
	_opening_locked = true
	_hide_book_content_for_opening()
	_prepare_contract_text_for_writing()
	_show_book_closed_state()
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	if header_label != null:
		header_label.visible = true
		header_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		header_label.text = "%s\n%s" % [tr(CLOSED_SCREEN_TITLE), tr(CLOSED_SCREEN_SUBTITLE)]
	_set_registry_background_active(true)
	if book_frame != null:
		book_frame.pivot_offset = book_frame.size * 0.5
		book_frame.position = _book_base_position
		book_frame.scale = _book_base_scale
	if closed_intro != null:
		closed_intro.visible = true
		closed_intro.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if open_book_button != null:
		open_book_button.disabled = false
	_set_book_input_enabled(false)

func _hide_closed_intro() -> void:
	if closed_intro != null:
		closed_intro.visible = false
	if open_book_button != null:
		open_book_button.disabled = true

func _on_open_book_pressed() -> void:
	if not _awaiting_open_request:
		return
	_play_sfx(&"button_click")
	_awaiting_open_request = false
	_play_open_animation()

func _build_book_content_node_list() -> void:
	_book_content_nodes = [] as Array[CanvasItem]
	for node: CanvasItem in [header_label, left_page, right_page]:
		if node != null:
			_book_content_nodes.append(node)

func _hide_book_content_for_opening() -> void:
	_book_content_target_modulates.clear()
	for node: CanvasItem in _book_content_nodes:
		_book_content_target_modulates[node] = node.modulate
		node.visible = false
		var hidden_modulate: Color = node.modulate
		hidden_modulate.a = 0.0
		node.modulate = hidden_modulate

func _reveal_book_content() -> void:
	if header_label != null:
		header_label.text = "%s\n%s" % [tr(SCREEN_TITLE), tr(SCREEN_SUBTITLE)]
	_set_registry_background_active(false)
	for node: CanvasItem in _book_content_nodes:
		node.visible = true

func _show_book_content_immediate() -> void:
	if header_label != null:
		header_label.text = "%s\n%s" % [tr(SCREEN_TITLE), tr(SCREEN_SUBTITLE)]
	_set_registry_background_active(false)
	for node: CanvasItem in _book_content_nodes:
		node.visible = true
		if _book_content_target_modulates.has(node):
			node.modulate = _book_content_target_modulates[node] as Color
	_book_content_target_modulates.clear()

func _prepare_contract_text_for_writing() -> void:
	for contract_label: RichTextLabel in [left_contract_label, right_contract_label]:
		if contract_label != null:
			contract_label.visible_characters = 0

func _show_contract_text_immediate() -> void:
	for contract_label: RichTextLabel in [left_contract_label, right_contract_label]:
		if contract_label != null:
			contract_label.visible_characters = -1

func _start_contract_write_animation() -> void:
	if _contract_write_tween != null and _contract_write_tween.is_valid():
		_contract_write_tween.kill()
	_contract_write_tween = create_tween()
	_contract_write_tween.set_trans(Tween.TRANS_LINEAR)
	_contract_write_tween.set_ease(Tween.EASE_IN_OUT)
	var has_contracts: bool = false
	for contract_label: RichTextLabel in [left_contract_label, right_contract_label]:
		if contract_label == null:
			continue
		contract_label.visible_characters = 0
		var total_characters: int = max(contract_label.get_total_character_count(), 1)
		_contract_write_tween.parallel().tween_property(contract_label, "visible_characters", total_characters, CONTRACT_WRITE_SECONDS)
		has_contracts = true
	if has_contracts:
		_contract_write_tween.tween_callback(Callable(self, "_finish_open_animation"))
	else:
		_finish_open_animation()

func _show_book_closed_state() -> void:
	if open_book_bg != null:
		open_book_bg.visible = false
		open_book_bg.modulate.a = 0.0
	if closed_book_bg != null:
		closed_book_bg.visible = true
		closed_book_bg.modulate.a = 1.0

func _set_registry_background_active(active: bool) -> void:
	if arena_background == null:
		return
	if active:
		arena_background.texture = REGISTRY_RITUAL_BACKGROUND
	elif _arena_background_default_texture != null:
		arena_background.texture = _arena_background_default_texture

func _begin_book_open_swap() -> void:
	if open_book_bg != null:
		open_book_bg.visible = true
		open_book_bg.modulate.a = 0.0

func _show_book_open_shell() -> void:
	if open_book_bg != null:
		open_book_bg.visible = true
	if closed_book_bg != null:
		closed_book_bg.visible = true

func _show_book_open_state() -> void:
	if open_book_bg != null:
		open_book_bg.visible = true
		open_book_bg.modulate.a = 1.0
	if closed_book_bg != null:
		closed_book_bg.visible = false
		closed_book_bg.modulate.a = 0.0

func _finish_open_animation() -> void:
	_opening_locked = false
	_show_book_open_state()
	_show_book_content_immediate()
	_show_contract_text_immediate()
	if book_frame != null:
		book_frame.position = _book_base_position
		book_frame.scale = _book_base_scale
	_apply_selection_visual()
	_update_sigilla_state()
	_set_book_input_enabled(true)

func _update_page_idle_motion() -> void:
	if _opening_locked or _awaiting_open_request or _submit_locked:
		return
	if left_page != null:
		left_page.position = _left_page_base_position + Vector2(0.0, sin(_idle_time * 0.72) * PAGE_IDLE_DRIFT_PIXELS)
	if right_page != null:
		right_page.position = _right_page_base_position + Vector2(0.0, sin(_idle_time * 0.68 + 0.8) * PAGE_IDLE_DRIFT_PIXELS)

func _reset_interaction_lock() -> void:
	selected_bet_id = &""
	_submit_locked = false
	if left_sign_button != null:
		left_sign_button.scale = Vector2.ONE
	if right_sign_button != null:
		right_sign_button.scale = Vector2.ONE

func _apply_default_selection() -> void:
	if _betting_circle_options.is_empty():
		selected_bet_id = &""
		return
	selected_bet_id = _offer_id_at(0)

func _on_select_left_pressed() -> void:
	if _opening_locked:
		return
	_select_offer_index(0)

func _on_select_right_pressed() -> void:
	if _opening_locked:
		return
	_select_offer_index(1)

func _select_offer_index(index: int) -> void:
	if index < 0 or index >= _betting_circle_options.size():
		selected_bet_id = &""
	else:
		selected_bet_id = StringName(str(_betting_circle_options[index].get("id", "")))
	_play_sfx(&"cursor_move")
	_apply_selection_visual()
	_update_sigilla_state()

func _reset_button_state() -> void:
	left_select_button.disabled = _opening_locked or _betting_circle_options.size() < 1
	right_select_button.disabled = _opening_locked or _betting_circle_options.size() < 2
	_apply_selection_visual()
	_update_sigilla_state()

func _apply_selection_visual() -> void:
	var left_id: StringName = _offer_id_at(0)
	var right_id: StringName = _offer_id_at(1)
	var left_selected: bool = left_id != &"" and selected_bet_id == left_id
	var right_selected: bool = right_id != &"" and selected_bet_id == right_id
	# Legacy yellow outlines remain disabled by design.
	left_selection_outline.visible = false
	right_selection_outline.visible = false
	if left_page != null:
		left_page.modulate = Color(1.0, 0.98, 0.9, 1.0) if left_selected else Color(0.86, 0.84, 0.78, 0.96)
	if right_page != null:
		right_page.modulate = Color(1.0, 0.98, 0.9, 1.0) if right_selected else Color(0.86, 0.84, 0.78, 0.96)
	if left_sign_button != null:
		left_sign_button.scale = Vector2(1.04, 1.04) if left_selected else Vector2(0.99, 0.99)
	if right_sign_button != null:
		right_sign_button.scale = Vector2(1.04, 1.04) if right_selected else Vector2(0.99, 0.99)

func _offer_id_at(index: int) -> StringName:
	if index < 0 or index >= _betting_circle_options.size():
		return &""
	return StringName(str(_betting_circle_options[index].get("id", "")))

func _on_sign_left_pressed() -> void:
	if _opening_locked:
		return
	_submit_offer_index(0, left_sign_button)

func _on_sign_right_pressed() -> void:
	if _opening_locked:
		return
	_submit_offer_index(1, right_sign_button)

func _submit_offer_index(index: int, button: Button) -> void:
	var offer_id: StringName = _offer_id_at(index)
	if offer_id == &"":
		return
	selected_bet_id = offer_id
	_apply_selection_visual()
	_update_sigilla_state()
	_submit_selected_offer(button)

func _submit_selected_offer(button: Button) -> void:
	if _opening_locked or _submit_locked or selected_bet_id == &"":
		return
	_submit_locked = true
	_update_sigilla_state()
	_play_sfx(&"cursor_select")
	_play_stamp_feedback(button)
	if GameEvents.has_signal("request_place_bet"):
		GameEvents.request_place_bet.emit(String(selected_bet_id), 0)
	close()

func _play_stamp_feedback(button: Button) -> void:
	if button == null:
		return
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.06, 1.06), 0.06)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)

func _wire_button_feedback_sfx() -> void:
	for button: Button in [open_book_button, left_select_button, right_select_button, left_sign_button, right_sign_button]:
		if button == null:
			continue
		var hover_callable: Callable = Callable(self, "_on_feedback_button_hover").bind(button)
		if not button.mouse_entered.is_connected(hover_callable):
			button.mouse_entered.connect(hover_callable)
		var focus_callable: Callable = Callable(self, "_on_feedback_button_hover").bind(button)
		if not button.focus_entered.is_connected(focus_callable):
			button.focus_entered.connect(focus_callable)

func _on_feedback_button_hover(button: Button) -> void:
	if button == null or button.disabled:
		return
	_play_sfx(&"button_hover")

func _play_sfx(cue: StringName) -> void:
	var sfx_bus: Node = get_node_or_null("/root/SfxBus")
	if sfx_bus == null or not sfx_bus.has_method("play_cue"):
		return
	sfx_bus.call("play_cue", cue)

func _update_sigilla_state() -> void:
	var left_id: StringName = _offer_id_at(0)
	var right_id: StringName = _offer_id_at(1)
	var left_ready: bool = left_id != &"" and not _submit_locked and not _opening_locked
	var right_ready: bool = right_id != &"" and not _submit_locked and not _opening_locked
	if left_sign_button != null:
		left_sign_button.disabled = not left_ready
		if left_ready:
			left_sign_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if selected_bet_id == left_id else Color(0.98, 0.96, 0.9, 1.0)
		else:
			left_sign_button.modulate = Color(0.7, 0.66, 0.6, 0.6)
	if right_sign_button != null:
		right_sign_button.disabled = not right_ready
		if right_ready:
			right_sign_button.modulate = Color(1.0, 1.0, 1.0, 1.0) if selected_bet_id == right_id else Color(0.98, 0.96, 0.9, 1.0)
		else:
			right_sign_button.modulate = Color(0.7, 0.66, 0.6, 0.6)

func _set_book_input_enabled(enabled: bool) -> void:
	if left_select_button != null:
		left_select_button.disabled = (not enabled) or _betting_circle_options.size() < 1
	if right_select_button != null:
		right_select_button.disabled = (not enabled) or _betting_circle_options.size() < 2
	_update_sigilla_state()

func _render_pages() -> void:
	var left_offer: Dictionary = _offer_or_empty(0)
	var right_offer: Dictionary = _offer_or_empty(1)
	_apply_page(left_offer, left_contract_label)
	_apply_page(right_offer, right_contract_label)

func _offer_or_empty(index: int) -> Dictionary:
	if index < 0 or index >= _betting_circle_options.size():
		return {
			"id": &"",
			"name": EMPTY_PAGE_TITLE,
			"contract": EMPTY_PAGE_BODY,
		}
	return _betting_circle_options[index]

func _apply_page(offer: Dictionary, contract_label: RichTextLabel) -> void:
	if contract_label != null:
		contract_label.text = str(offer.get("contract", EMPTY_PAGE_BODY))

func _refresh_from_catalog_if_empty() -> void:
	if not _betting_circle_options.is_empty():
		return
	_rebuild_options_from_catalog()

func _map_offer_for_display(source_offer: Dictionary) -> Dictionary:
	var bet_id: StringName = StringName(str(source_offer.get("id", source_offer.get("bet_id", ""))))
	var title: String = str(source_offer.get("display_title", source_offer.get("name", "")))
	var subtitle: String = str(source_offer.get("display_subtitle", ""))
	var doom_text: String = str(source_offer.get("doom", ""))
	var condition_text: String = str(source_offer.get("condition", ""))
	var pact_text: String = str(source_offer.get("pact", ""))
	if title == "" and bet_id != &"":
		title = BetCatalog.get_level3_display_title(bet_id)
	return {
		"id": bet_id,
		"name": title if title != "" else EMPTY_PAGE_TITLE,
		"contract": _format_contract_body(title if title != "" else EMPTY_PAGE_TITLE, subtitle, doom_text, condition_text, pact_text),
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
			"contract": _format_contract_body(
				str(identity.get("display_title", str(bet_data.get("name", String(bet_id))))),
				str(identity.get("display_subtitle", "")),
				str(bet_data.get("doom", "")),
				str(bet_data.get("condition", "")),
				str(bet_data.get("pact", ""))
			),
		})

func _find_bet_data(bet_id: StringName) -> Dictionary:
	for bet_value: Dictionary in BetCatalog.level3_active_bets():
		var bet_data: Dictionary = bet_value as Dictionary
		if StringName(str(bet_data.get("id", ""))) == bet_id:
			return bet_data
	return {}

func _format_contract_body(title: String, subtitle: String, doom_text: String, condition_text: String, pact_text: String) -> String:
	var lines: Array[String] = []
	var title_text: String = title.strip_edges()
	if title_text != "":
		lines.append("[center][b]%s[/b][/center]" % _escape_bbcode(title_text))
	var subtitle_text: String = subtitle.strip_edges()
	if subtitle_text != "":
		lines.append("[center][i]%s[/i][/center]" % _escape_bbcode(subtitle_text))
	_append_contract_section(lines, tr("CONDANNA"), doom_text, true)
	_append_contract_section(lines, tr("CONDIZIONE"), condition_text, false)
	_append_contract_section(lines, tr("PATTO"), pact_text, false)
	if lines.is_empty():
		return EMPTY_PAGE_BODY
	return "\n\n".join(lines)

func _append_contract_section(lines: Array[String], section_title: String, body_text: String, emphasize_effect: bool) -> void:
	var body: String = body_text.strip_edges()
	if body == "":
		return
	var section_lines: Array[String] = ["[b]%s[/b]" % _escape_bbcode(section_title)]
	var body_lines: PackedStringArray = body.split("\n", false)
	for raw_line: String in body_lines:
		var line: String = raw_line.strip_edges()
		if line == "":
			continue
		if emphasize_effect and line.begins_with("Effetto:"):
			section_lines.append("[b]%s[/b]" % _escape_bbcode(line))
		else:
			section_lines.append(_escape_bbcode(line))
	lines.append("\n".join(section_lines))

func _escape_bbcode(value: String) -> String:
	# Godot 4.6 does not expose String.escape_bbcode(); escaping the opening
	# bracket is the supported way to prevent user/content text from becoming tags.
	return value.replace("[", "[lb]")
