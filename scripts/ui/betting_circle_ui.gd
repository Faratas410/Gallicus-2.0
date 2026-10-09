extends Control
class_name BettingCircleUI

const EMPTY_PAGE_TITLE: String = "---"
const EMPTY_PAGE_BODY: String = "[i]Nessuna proposta disponibile.[/i]"
const Kit = preload("res://scripts/ui/manifesto_kit.gd")
const CONTRACT_TITLE_SIZE: int = Kit.CONTRACT_TITLE_SIZE
const CONTRACT_HEADING_SIZE: int = Kit.CONTRACT_HEADING_SIZE
const CONTRACT_TITLE_COLOR: Color = Kit.Palette.INK
const CONTRACT_HOLDS_COLOR: Color = Kit.Palette.INK
const CONTRACT_BREAKS_COLOR: Color = Kit.Palette.INK
const CONTRACT_NOTE_COLOR: Color = Kit.Palette.INK
const SCREEN_TITLE: String = "SCEGLI LA VIA"
const SCREEN_SUBTITLE: String = "Leggi la promessa e il costo. Poi firma."
const CLOSED_SCREEN_TITLE: String = "REGISTRO DELL'ARENA"
const CLOSED_SCREEN_SUBTITLE: String = "Apertura del verbale"
const REGISTRY_RITUAL_BACKGROUND: Texture2D = preload("res://assets/ui/generated/registry_counter.png")
const REGISTRY_TABLE_STATE_NORMAL: StringName = &"normal"
const REGISTRY_TABLE_STATE_FOCUS: StringName = &"focus"
const REGISTRY_TABLE_STATE_PRESSED: StringName = &"pressed"
const REGISTRY_TABLE_STATE_DISABLED: StringName = &"disabled"
const REGISTRY_TABLE_STATE_META: StringName = &"registry_table_state"
const PROMISE_SIGNATURE_STATE_NORMAL: StringName = &"normal"
const PROMISE_SIGNATURE_STATE_SELECTED: StringName = &"selected"
const PROMISE_SIGNATURE_STATE_SIGNED: StringName = &"signed"
const PROMISE_SIGNATURE_STATE_DISABLED: StringName = &"disabled"
const PROMISE_SIGNATURE_STATE_META: StringName = &"registry_promise_signature_state"
const BOOK_TITLE_PULSE_SPEED: float = 1.15
const BOOK_DROP_OFFSET: Vector2 = Vector2(0.0, -34.0)
const BOOK_DROP_SECONDS: float = 0.22
const BOOK_OPEN_SECONDS: float = 0.24
const BOOK_SETTLE_SECONDS: float = 0.12
const BOOK_CONTENT_REVEAL_SECONDS: float = 0.18
const CONTRACT_WRITE_SECONDS: float = 0.35
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
@onready var closed_book_bg: PanelContainer = $CenterContainer/BookFrame/ClosedBookBg as PanelContainer
@onready var closed_intro: Control = $CenterContainer/BookFrame/ClosedIntro as Control
@onready var intro_text: Label = $CenterContainer/BookFrame/ClosedIntro/IntroText as Label
@onready var intro_body: Label = $CenterContainer/BookFrame/ClosedIntro/IntroBodyPanel/IntroBody as Label
@onready var intro_seal: Label = $CenterContainer/BookFrame/ClosedIntro/IntroSealPanel/IntroSeal as Label
@onready var open_book_button: Button = $CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book as Button
@onready var open_book_label: Label = $CenterContainer/BookFrame/ClosedIntro/Btn_Open_Book/Lbl_Open_Book as Label
@onready var banco_title: Label = $CenterContainer/BookFrame/ClosedIntro/BancoPanel/BancoTitle as Label
@onready var banco_note: Label = $CenterContainer/BookFrame/ClosedIntro/BancoPanel/BancoNote as Label
@onready var banco_row: HBoxContainer = $CenterContainer/BookFrame/ClosedIntro/BancoPanel/BancoRow as HBoxContainer

var selected_bet_id: StringName = &""
var _betting_circle_options: Array[Dictionary] = []
var _submit_locked: bool = false
var _opening_locked: bool = false
var _idle_time: float = 0.0
var _left_page_base_offsets: Vector4 = Vector4.ZERO
var _right_page_base_offsets: Vector4 = Vector4.ZERO
var _book_base_scale: Vector2 = Vector2.ONE
var _book_base_offsets: Vector4 = Vector4.ZERO
var _nodes_ready: bool = false
var _open_tween: Tween = null
var _contract_write_tween: Tween = null
var _book_content_nodes: Array[CanvasItem] = []
var _book_content_target_modulates: Dictionary = {}
var _awaiting_open_request: bool = false
var _arena_background_default_texture: Texture2D = null
# Vessa's banco renders the last ledger payload; RunManager prices and decides.
var _banco_view: Dictionary = {}
var _bando_view: Dictionary = {}
var _banco_note_text: String = ""

func _ready() -> void:
	_nodes_ready = true
	visible = false
	_apply_manifesto_surfaces()
	_refresh_localized_text()
	left_select_button.pressed.connect(_on_select_left_pressed)
	right_select_button.pressed.connect(_on_select_right_pressed)
	left_sign_button.pressed.connect(_on_sign_left_pressed)
	right_sign_button.pressed.connect(_on_sign_right_pressed)
	if open_book_button != null:
		open_book_button.pressed.connect(_on_open_book_pressed)
		open_book_button.mouse_entered.connect(_on_open_book_focus_entered)
		open_book_button.mouse_exited.connect(_on_open_book_focus_exited)
		open_book_button.focus_entered.connect(_on_open_book_focus_entered)
		open_book_button.focus_exited.connect(_on_open_book_focus_exited)
		open_book_button.button_down.connect(_on_open_book_button_down)
		open_book_button.button_up.connect(_on_open_book_button_up)
	# Exported builds can drop the instance's anchors (binary scene conversion);
	# the circle must always cover the run root so the book sits centred.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wire_banco()
	_wire_button_feedback_sfx()
	# Legacy CI contract token: bet_option_3.visible = false
	_refresh_from_catalog_if_empty()
	_render_pages()
	_reset_button_state()
	if left_page != null:
		_left_page_base_offsets = _layout_offsets(left_page)
	if right_page != null:
		_right_page_base_offsets = _layout_offsets(right_page)
	if book_frame != null:
		_book_base_scale = book_frame.scale
		_book_base_offsets = _layout_offsets(book_frame)
	if arena_background != null:
		_arena_background_default_texture = arena_background.texture
	_build_book_content_node_list()
	if GameEvents != null and GameEvents.has_signal("settings_changed"):
		var settings_callable: Callable = Callable(self, "_on_settings_changed")
		if not GameEvents.settings_changed.is_connected(settings_callable):
			GameEvents.settings_changed.connect(settings_callable)

func _apply_manifesto_surfaces() -> void:
	Kit.apply_document(open_book_bg, &"ink")
	Kit.apply_document(closed_book_bg, &"ink")
	for page: Control in [left_page, right_page]:
		Kit.apply_document(page.get_node("LeftPaper" if page == left_page else "RightPaper"))
	for label: RichTextLabel in [left_contract_label, right_contract_label]:
		Kit.apply_rich_text(label)
		label.resized.connect(_refresh_contract_scroll.bind(label))
	for button: Button in [left_select_button, right_select_button]:
		Kit.apply_page_selection(button)
	for label: Label in [header_label, intro_body, intro_seal, banco_note]:
		Kit.apply_label(label)
	for label: Label in [intro_text, banco_title]:
		Kit.apply_label(label, &"title")
	banco_title.add_theme_font_size_override("font_size", Kit.ACTION_COMPACT)
	Kit.apply_document(intro_body.get_parent() as Control, &"ink")
	(intro_seal.get_parent() as Control).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	# Native Button text is the single printed CTA; keep legacy labels as bindings.
	open_book_label.hide()
	left_sign_label.hide()
	right_sign_label.hide()
	Kit.apply_action(open_book_button, &"paper", true)

func _refresh_contract_scroll(label: RichTextLabel) -> void:
	var overflowing: bool = label.get_content_height() > label.size.y
	label.scroll_active = overflowing
	label.mouse_filter = Control.MOUSE_FILTER_STOP if overflowing else Control.MOUSE_FILTER_IGNORE

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
	_render_bando_intro()
	if open_book_label != null:
		open_book_label.text = tr("APRI IL REGISTRO")
		open_book_button.text = "APRI IL REGISTRO"
	_render_pages()

func _wire_banco() -> void:
	if banco_row != null:
		for button_node: Node in banco_row.get_children():
			var button: Button = button_node as Button
			if button == null:
				continue
			var item_id: String = String(button.name).trim_prefix("Btn_Banco_")
			button.pressed.connect(_on_banco_pressed.bind(item_id))
	if GameEvents != null and GameEvents.has_signal("ledger_changed"):
		var ledger_callable: Callable = Callable(self, "_on_ledger_changed")
		if not GameEvents.ledger_changed.is_connected(ledger_callable):
			GameEvents.ledger_changed.connect(ledger_callable)
	if GameEvents != null and GameEvents.has_signal("bando_changed"):
		var bando_callable: Callable = Callable(self, "_on_bando_changed")
		if not GameEvents.bando_changed.is_connected(bando_callable):
			GameEvents.bando_changed.connect(bando_callable)
	_render_banco()

func _on_bando_changed(payload: Dictionary) -> void:
	_bando_view = payload.duplicate()
	_render_bando_intro()

# The closed Registry is where Orvo announces the percorso's bando.
func _render_bando_intro() -> void:
	var open_bando: bool = str(_bando_view.get("status", "")) == "open"
	if intro_text != null:
		intro_text.text = tr("IL BANDO DI ORVO") if open_bando else tr("IL REGISTRO È CHIUSO")
	if intro_body != null:
		if open_bando:
			intro_body.text = "%s\n%s" % [
				tr("Incassa %d Gloria entro l'arena %d.") % [int(_bando_view.get("quota", 0)), int(_bando_view.get("deadline", 0))],
				tr("Al bando chiuso: Denari +%d e un gradino.") % int(_bando_view.get("denari", 0)),
			]
		else:
			intro_body.text = "%s\n%s" % [
				tr("Il Registro è pronto per la firma."),
				tr("Ogni patto lascia un segno."),
			]
	if intro_seal != null:
		var steps: int = int(_bando_view.get("steps", 0))
		if open_bando and steps > 0:
			intro_seal.text = tr("Gradino %d di %d") % [mini(int(_bando_view.get("step", 0)) + 1, steps), steps]
		else:
			intro_seal.text = tr("I    II    III")

func _on_ledger_changed(payload: Dictionary) -> void:
	_banco_view = payload.get("banco", {}) as Dictionary
	var note: String = str(payload.get("note", ""))
	if note != "":
		# Ledger notes carry the amount as %d: the key stays translatable.
		_banco_note_text = tr(note) % absi(int(payload.get("delta", 0))) if note.contains("%d") else tr(note)
	_render_banco()

func _on_banco_pressed(item_id: String) -> void:
	if not bool(_banco_view.get("open", false)):
		return
	_play_sfx(&"registry_table_open")
	if GameEvents != null and GameEvents.has_signal("request_banco_purchase"):
		GameEvents.request_banco_purchase.emit(item_id)

func _render_banco() -> void:
	if not _nodes_ready:
		return
	var denari: int = int(_banco_view.get("denari", 0))
	if banco_title != null:
		banco_title.text = "%s  ·  %s" % [tr("BANCO DI VESSA"), tr("Conto %d Denari") % denari]
	var items: Array = _banco_view.get("items", []) as Array
	if banco_row != null:
		for button_node: Node in banco_row.get_children():
			var button: Button = button_node as Button
			if button == null:
				continue
			var item_id: String = String(button.name).trim_prefix("Btn_Banco_")
			var item: Dictionary = {}
			for item_value: Variant in items:
				if item_value is Dictionary and str((item_value as Dictionary).get("id", "")) == item_id:
					item = item_value as Dictionary
			button.visible = not item.is_empty()
			button.disabled = not bool(item.get("available", false))
			button.text = "%s\n%s\n%s" % [
				tr(str(item.get("title", ""))),
				tr(str(item.get("text", ""))),
				tr("%d Denari") % int(item.get("price", 0)),
			]
			Kit.apply_action(button, &"paper", true, false, Kit.ACTION_COMPACT, false, true)
	if banco_note != null:
		var note: String = _banco_note_text
		if bool(_banco_view.get("in_debt", false)):
			note = tr("Conto in debito. La quietanza vale doppio; salda il conto per riaprire il banco.")
		elif bool(_banco_view.get("insured", false)):
			note = tr("La posta di questa arena è assicurata.")
		banco_note.text = note

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
	call_deferred("_focus_open_book")
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
		_shift_layout(left_page, _left_page_base_offsets, 0.0)
	if right_page != null:
		_shift_layout(right_page, _right_page_base_offsets, 0.0)
	if book_frame != null:
		book_frame.scale = _book_base_scale
		_set_book_drop(0.0)
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
	_opening_locked = true
	_set_book_input_enabled(false)
	if _book_content_target_modulates.is_empty():
		_hide_book_content_for_opening()
	_hide_closed_intro()
	if _is_reduced_motion():
		_show_book_open_state()
		_show_book_content_immediate()
		_show_contract_text_immediate()
		_finish_open_animation()
		return
	_show_book_closed_state()
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	book_frame.pivot_offset = book_frame.size * 0.5
	_set_book_drop(BOOK_DROP_OFFSET.y)
	book_frame.scale = _book_base_scale * Vector2(0.92, 0.92)
	_open_tween = create_tween()
	_open_tween.set_trans(Tween.TRANS_QUAD)
	_open_tween.set_ease(Tween.EASE_OUT)
	_open_tween.tween_method(_set_book_drop, BOOK_DROP_OFFSET.y, 0.0, BOOK_DROP_SECONDS)
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
		_set_book_drop(0.0)
		book_frame.scale = _book_base_scale
	if closed_intro != null:
		closed_intro.visible = true
		closed_intro.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if open_book_button != null:
		open_book_button.disabled = false
	_set_registry_table_closed_state(REGISTRY_TABLE_STATE_NORMAL)
	_set_book_input_enabled(false)

func _hide_closed_intro() -> void:
	if closed_intro != null:
		closed_intro.visible = false
	if open_book_button != null:
		open_book_button.disabled = true
	_set_registry_table_closed_state(REGISTRY_TABLE_STATE_DISABLED)

func _on_open_book_pressed() -> void:
	if not _awaiting_open_request:
		return
	_play_sfx(&"registry_table_open")
	_awaiting_open_request = false
	_play_open_animation()

func _on_open_book_focus_entered() -> void:
	if not _awaiting_open_request or open_book_button == null or open_book_button.disabled:
		return
	_set_registry_table_closed_state(REGISTRY_TABLE_STATE_FOCUS)

func _on_open_book_focus_exited() -> void:
	if not _awaiting_open_request or open_book_button == null or open_book_button.disabled:
		return
	if open_book_button.is_hovered():
		return
	_set_registry_table_closed_state(REGISTRY_TABLE_STATE_NORMAL)

func _on_open_book_button_down() -> void:
	if not _awaiting_open_request or open_book_button == null or open_book_button.disabled:
		return
	_set_registry_table_closed_state(REGISTRY_TABLE_STATE_PRESSED)

func _on_open_book_button_up() -> void:
	if not _awaiting_open_request or open_book_button == null or open_book_button.disabled:
		return
	var next_state: StringName = REGISTRY_TABLE_STATE_FOCUS if open_book_button.has_focus() or open_book_button.is_hovered() else REGISTRY_TABLE_STATE_NORMAL
	_set_registry_table_closed_state(next_state)

func _set_registry_table_closed_state(state: StringName) -> void:
	if closed_book_bg == null:
		return
	if open_book_button != null:
		open_book_button.set_meta(REGISTRY_TABLE_STATE_META, state)
		Kit.apply_action(open_book_button, &"paper", true)

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
			var target_modulate: Color = _book_content_target_modulates[node] as Color
			target_modulate.a = maxf(target_modulate.a, 1.0)
			node.modulate = target_modulate
		else:
			node.modulate.a = 1.0
	_book_content_target_modulates.clear()
	_force_contract_text_readable()

func _prepare_contract_text_for_writing() -> void:
	for contract_label: RichTextLabel in [left_contract_label, right_contract_label]:
		if contract_label != null:
			contract_label.visible_characters = 0

func _show_contract_text_immediate() -> void:
	for contract_label: RichTextLabel in [left_contract_label, right_contract_label]:
		if contract_label != null:
			contract_label.visible = true
			contract_label.modulate.a = 1.0
			contract_label.visible_characters = -1

func _force_contract_text_readable() -> void:
	for page: Control in [left_page, right_page]:
		if page != null:
			page.visible = true
			page.modulate.a = 1.0
	_show_contract_text_immediate()

func _start_contract_write_animation() -> void:
	if _contract_write_tween != null and _contract_write_tween.is_valid():
		_contract_write_tween.kill()
	if _is_reduced_motion():
		_show_contract_text_immediate()
		_finish_open_animation()
		return
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
		_set_book_drop(0.0)
		book_frame.scale = _book_base_scale
	_apply_selection_visual()
	_update_sigilla_state()
	_set_book_input_enabled(true)
	call_deferred("_focus_first_signature")

func _update_page_idle_motion() -> void:
	if _is_reduced_motion():
		_restore_page_positions()
		return
	if _opening_locked or _awaiting_open_request or _submit_locked:
		return
	if left_page != null:
		_shift_layout(left_page, _left_page_base_offsets, sin(_idle_time * 0.72) * PAGE_IDLE_DRIFT_PIXELS)
	if right_page != null:
		_shift_layout(right_page, _right_page_base_offsets, sin(_idle_time * 0.68 + 0.8) * PAGE_IDLE_DRIFT_PIXELS)

func _layout_offsets(control: Control) -> Vector4:
	return Vector4(control.offset_left, control.offset_top, control.offset_right, control.offset_bottom)

# Book and pages move through their anchored offsets, never an absolute position,
# so a layout pass or window change cannot strand them off centre.
func _shift_layout(control: Control, base: Vector4, shift_y: float) -> void:
	if control == null:
		return
	control.offset_left = base.x
	control.offset_top = base.y + shift_y
	control.offset_right = base.z
	control.offset_bottom = base.w + shift_y

func _set_book_drop(shift_y: float) -> void:
	_shift_layout(book_frame, _book_base_offsets, shift_y)

func _restore_page_positions() -> void:
	if left_page != null:
		_shift_layout(left_page, _left_page_base_offsets, 0.0)
	if right_page != null:
		_shift_layout(right_page, _right_page_base_offsets, 0.0)

func _is_reduced_motion() -> bool:
	return SaveManager != null and SaveManager.has_method("get_reduced_motion") and SaveManager.get_reduced_motion()

func _on_settings_changed(payload: Dictionary) -> void:
	if not payload.has("reduced_motion") or not bool(payload.get("reduced_motion", false)):
		return
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	if _contract_write_tween != null and _contract_write_tween.is_valid():
		_contract_write_tween.kill()
	if visible and not _awaiting_open_request:
		_finish_open_animation()
	_restore_page_positions()

func _focus_open_book() -> void:
	if open_book_button != null and open_book_button.visible and not open_book_button.disabled:
		open_book_button.grab_focus()

func _focus_first_signature() -> void:
	for button: Button in [left_sign_button, right_sign_button]:
		if button != null and button.visible and not button.disabled:
			button.grab_focus()
			return

func _reset_interaction_lock() -> void:
	selected_bet_id = &""
	_submit_locked = false
	_set_promise_signature_state(left_sign_button, PROMISE_SIGNATURE_STATE_NORMAL)
	_set_promise_signature_state(right_sign_button, PROMISE_SIGNATURE_STATE_NORMAL)

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
	# A rule identifies the consulted page without tinting its content or signing it.
	left_selection_outline.visible = false
	right_selection_outline.visible = false
	if left_page != null:
		left_page.modulate = Color.WHITE
		Kit.apply_document(left_page.get_node("LeftPaper"), &"paper", left_selected)
	if right_page != null:
		right_page.modulate = Color.WHITE
		Kit.apply_document(right_page.get_node("RightPaper"), &"paper", right_selected)

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
	_set_promise_signature_state(button, PROMISE_SIGNATURE_STATE_SIGNED)
	_submit_locked = true
	_update_sigilla_state()
	_play_sfx(&"registry_promise_sign")
	if GameEvents.has_signal("request_place_bet"):
		GameEvents.request_place_bet.emit(String(selected_bet_id), 0)
	close()

func _set_promise_signature_state(button: Button, state: StringName) -> void:
	if button == null:
		return
	button.set_meta(PROMISE_SIGNATURE_STATE_META, state)
	button.text = "FIRMA"
	Kit.apply_action(button, &"wax", true, state == PROMISE_SIGNATURE_STATE_SIGNED, Kit.ACTION_COMPACT, state == PROMISE_SIGNATURE_STATE_SELECTED)
	var trace := button.get_node_or_null("WaxTrace") as TextureRect
	if trace != null:
		trace.hide()

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
	var feedback: Node = get_tree().get_first_node_in_group("ritual_feedback")
	if feedback != null:
		feedback.call("play_cue", cue, get_viewport().gui_get_focus_owner())
	var sfx_bus: Node = get_node_or_null("/root/SfxBus")
	if sfx_bus == null or not sfx_bus.has_method("play_cue"):
		return
	sfx_bus.call("play_cue", cue)

func _update_sigilla_state() -> void:
	var left_id: StringName = _offer_id_at(0)
	var right_id: StringName = _offer_id_at(1)
	var left_ready: bool = left_id != &"" and not _submit_locked and not _opening_locked
	var right_ready: bool = right_id != &"" and not _submit_locked and not _opening_locked
	_update_promise_signature_button(left_sign_button, left_id, left_ready)
	_update_promise_signature_button(right_sign_button, right_id, right_ready)

func _update_promise_signature_button(button: Button, offer_id: StringName, ready: bool) -> void:
	if button == null:
		return
	var current_state: StringName = button.get_meta(PROMISE_SIGNATURE_STATE_META, PROMISE_SIGNATURE_STATE_NORMAL) as StringName
	if current_state == PROMISE_SIGNATURE_STATE_SIGNED:
		button.disabled = true
		_set_promise_signature_state(button, PROMISE_SIGNATURE_STATE_SIGNED)
		return
	button.disabled = not ready
	if not ready:
		_set_promise_signature_state(button, PROMISE_SIGNATURE_STATE_DISABLED)
	elif offer_id != &"" and selected_bet_id == offer_id:
		_set_promise_signature_state(button, PROMISE_SIGNATURE_STATE_SELECTED)
	else:
		_set_promise_signature_state(button, PROMISE_SIGNATURE_STATE_NORMAL)

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
		var localized: Dictionary = _map_offer_for_display(offer.source) if offer.has("source") else offer
		contract_label.text = str(localized.get("contract", EMPTY_PAGE_BODY))
		contract_label.scroll_to_line(0)
		_refresh_contract_scroll.call_deferred(contract_label)

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
		"source": source_offer.duplicate(true),
		"name": title if title != "" else EMPTY_PAGE_TITLE,
		"contract": _format_contract_body(title if title != "" else EMPTY_PAGE_TITLE, subtitle, doom_text, condition_text, pact_text, bet_id, int(source_offer.get("stake_gain", -1)), source_offer.get("seal_conditions", {}) as Dictionary),
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
		var source: Dictionary = bet_data.duplicate(true)
		source["display_title"] = identity.get("display_title", bet_data.get("name", String(bet_id)))
		source["display_subtitle"] = identity.get("display_subtitle", "")
		_betting_circle_options.append(_map_offer_for_display(source))

func _find_bet_data(bet_id: StringName) -> Dictionary:
	for bet_value: Dictionary in BetCatalog.level3_active_bets():
		var bet_data: Dictionary = bet_value as Dictionary
		if StringName(str(bet_data.get("id", ""))) == bet_id:
			return bet_data
	return {}

func _format_contract_body(title: String, subtitle: String, doom_text: String, condition_text: String, pact_text: String, bet_id: StringName = &"", stake_gain: int = -1, conditions: Dictionary = {}) -> String:
	# Three levels only (docs/direction.md): title, the deal, then what holds and
	# what breaks. Shared body typography preserves the existing BBCode content.
	var lines: Array[String] = []
	var title_text: String = tr(title.strip_edges())
	if title_text != "":
		lines.append("[center]%s[/center]" % Kit.format_heading(title_text, CONTRACT_TITLE_SIZE, CONTRACT_TITLE_COLOR))
	var subtitle_text: String = tr(subtitle.strip_edges())
	if subtitle_text != "":
		lines.append("[center]%s[/center]" % _escape_bbcode(subtitle_text))
	var holds: Array[String] = _translated_lines(condition_text)
	var stake_terms: Dictionary = _stake_terms(bet_id, stake_gain)
	if not stake_terms.is_empty():
		# The family's odds and stake replace the generic condition sentence.
		holds = [str(stake_terms.holds)]
	if not holds.is_empty():
		lines.append(_contract_heading(tr("SE IL PATTO REGGE"), CONTRACT_HOLDS_COLOR))
		lines.append(_escape_bbcode(" ".join(holds)))
		var today: String = _seal_conditions_text(conditions)
		if today != "":
			lines.append("[color=#%s]%s[/color]" % [CONTRACT_NOTE_COLOR.to_html(false), _escape_bbcode(today)])
	var breaks: Array[String] = _translated_lines(doom_text)
	if not breaks.is_empty():
		lines.append(_contract_heading(tr("SE IL PATTO CEDE"), CONTRACT_BREAKS_COLOR))
		# The catalog closes every doom block with its mechanical effect.
		var effect_line: String = _strip_effect_prefix(breaks[breaks.size() - 1])
		if not stake_terms.is_empty():
			effect_line = "%s %s" % [str(stake_terms.breaks), effect_line]
		lines.append(_escape_bbcode(effect_line))
		if breaks.size() > 1:
			lines.append("[color=#%s]%s[/color]" % [CONTRACT_NOTE_COLOR.to_html(false), _escape_bbcode(breaks[0])])
	var pact_lines: Array[String] = _translated_lines(pact_text)
	if not stake_terms.is_empty():
		# The old reward blurb would contradict the stake line above.
		pact_lines = []
	if not pact_lines.is_empty():
		lines.append("\n[center][color=#%s]%s[/color][/center]" % [CONTRACT_NOTE_COLOR.to_html(false), _escape_bbcode(" ".join(pact_lines))])
	if lines.is_empty():
		return EMPTY_PAGE_BODY
	return "\n".join(lines)

func _seal_conditions_text(conditions: Dictionary) -> String:
	# Today's Favore, Pressione and Segni move every page's odds the same way.
	if conditions.is_empty():
		return ""
	var helps: Array[String] = []
	var weighs: Array[String] = []
	var favor: int = int(conditions.get("favor", 0))
	if favor > 0:
		helps.append(tr("Favore +%d") % favor)
	elif favor < 0:
		weighs.append(tr("Favore -%d") % -favor)
	var pressure: int = int(conditions.get("pressure", 0))
	if pressure > 0:
		weighs.append(tr("Pressione %d") % pressure)
	if int(conditions.get("scars", 0)) > 0:
		weighs.append(tr("i Segni"))
	var parts: Array[String] = []
	if not helps.is_empty():
		parts.append(tr("Oggi, a favore del sigillo: %s.") % ", ".join(helps))
	if not weighs.is_empty():
		parts.append(tr("Oggi, contro il sigillo: %s.") % ", ".join(weighs))
	if parts.is_empty():
		return tr("Oggi niente sposta il sigillo.")
	return " ".join(parts)

func _stake_terms(bet_id: StringName, stake_gain: int = -1) -> Dictionary:
	if bet_id == &"":
		return {}
	var profile: Dictionary = BetCatalog.get_pact_family_profile(bet_id)
	var odds: String = tr(str(profile.get("odds", "")))
	# RunManager sends the gain for the current arena; the catalog base covers previews.
	var gain: int = stake_gain if stake_gain >= 0 else int(profile.get("stake_gain", 0))
	var holds: String = tr("%s: +%d Gloria in posta.") % [odds, gain]
	if bet_id == BetCatalog.BET_DOUBLE_OR_DIE:
		holds = tr("%s: la posta raddoppia.") % odds
	if int(profile.get("pressure_relief", 0)) > 0:
		holds = "%s %s" % [holds, tr("Pressione -1.")]
	var breaks: String = tr("Perdi metà della posta.")
	if StringName(str(profile.get("stake_loss", ""))) == BetCatalog.STAKE_LOSS_ALL:
		breaks = tr("Perdi tutta la posta.")
	return {"holds": holds, "breaks": breaks}

func _contract_heading(text: String, color: Color) -> String:
	return "\n" + Kit.format_heading(text, CONTRACT_HEADING_SIZE, color)

func _translated_lines(source: String) -> Array[String]:
	var result: Array[String] = []
	for raw_line: String in tr(source.strip_edges()).split("\n", false):
		var line: String = tr(raw_line.strip_edges())
		if line != "":
			result.append(line)
	return result

func _strip_effect_prefix(line: String) -> String:
	# "Effetto: ...", "Effect: ...", "Efecto: ..." -> the effect alone.
	var colon: int = line.find(":")
	if colon > 0 and colon <= 8:
		var effect: String = line.substr(colon + 1).strip_edges()
		if effect != "":
			return effect.left(1).to_upper() + effect.substr(1)
	return line

func _escape_bbcode(value: String) -> String:
	# Godot 4.6 does not expose String.escape_bbcode(); escaping the opening
	# bracket is the supported way to prevent user/content text from becoming tags.
	return value.replace("[", "[lb]")
