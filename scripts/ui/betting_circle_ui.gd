extends Control
class_name BettingCircleUI

const PACT_ID_1: StringName = &"pact_1"
const PACT_ID_2: StringName = &"pact_2"
const PACT_ID_3: StringName = &"pact_3"
const CONDITION_ID_1: StringName = &"condition_1"
const CONDITION_ID_2: StringName = &"condition_2"
const CONDITION_ID_3: StringName = &"condition_3"
const SENTENCE_ID_1: StringName = &"sentence_1"
const SENTENCE_ID_2: StringName = &"sentence_2"
const SENTENCE_ID_3: StringName = &"sentence_3"

@onready var sigilla_button: Button = $ContractPanel/ContractVBox/SigillaButton as Button
@onready var pact_button_1: Button = $ContractPanel/ContractVBox/PactSection/PactButtons/PactOption1 as Button
@onready var pact_button_2: Button = $ContractPanel/ContractVBox/PactSection/PactButtons/PactOption2 as Button
@onready var pact_button_3: Button = $ContractPanel/ContractVBox/PactSection/PactButtons/PactOption3 as Button
@onready var condition_button_1: Button = $ContractPanel/ContractVBox/ConditionSection/ConditionButtons/ConditionOption1 as Button
@onready var condition_button_2: Button = $ContractPanel/ContractVBox/ConditionSection/ConditionButtons/ConditionOption2 as Button
@onready var condition_button_3: Button = $ContractPanel/ContractVBox/ConditionSection/ConditionButtons/ConditionOption3 as Button
@onready var sentence_button_1: Button = $ContractPanel/ContractVBox/SentenceSection/SentenceButtons/SentenceOption1 as Button
@onready var sentence_button_2: Button = $ContractPanel/ContractVBox/SentenceSection/SentenceButtons/SentenceOption2 as Button
@onready var sentence_button_3: Button = $ContractPanel/ContractVBox/SentenceSection/SentenceButtons/SentenceOption3 as Button

var selected_pact_id: StringName = &""
var selected_condition_id: StringName = &""
var selected_sentence_id: StringName = &""

func _ready() -> void:
	visible = false
	var pact_group: ButtonGroup = ButtonGroup.new()
	var condition_group: ButtonGroup = ButtonGroup.new()
	var sentence_group: ButtonGroup = ButtonGroup.new()
	var pact_buttons: Array[Button] = [pact_button_1, pact_button_2, pact_button_3]
	var condition_buttons: Array[Button] = [condition_button_1, condition_button_2, condition_button_3]
	var sentence_buttons: Array[Button] = [sentence_button_1, sentence_button_2, sentence_button_3]
	_setup_group(pact_buttons, pact_group)
	_setup_group(condition_buttons, condition_group)
	_setup_group(sentence_buttons, sentence_group)
	pact_button_1.pressed.connect(_on_pact_selected.bind(PACT_ID_1))
	pact_button_2.pressed.connect(_on_pact_selected.bind(PACT_ID_2))
	pact_button_3.pressed.connect(_on_pact_selected.bind(PACT_ID_3))
	condition_button_1.pressed.connect(_on_condition_selected.bind(CONDITION_ID_1))
	condition_button_2.pressed.connect(_on_condition_selected.bind(CONDITION_ID_2))
	condition_button_3.pressed.connect(_on_condition_selected.bind(CONDITION_ID_3))
	sentence_button_1.pressed.connect(_on_sentence_selected.bind(SENTENCE_ID_1))
	sentence_button_2.pressed.connect(_on_sentence_selected.bind(SENTENCE_ID_2))
	sentence_button_3.pressed.connect(_on_sentence_selected.bind(SENTENCE_ID_3))
	sigilla_button.pressed.connect(_on_sigilla_pressed)
	_reset_button_state()

func open() -> void:
	reset()
	visible = true
	if GameEvents.has_signal("modal_opened"):
		GameEvents.modal_opened.emit("betting_circle")

func close() -> void:
	visible = false
	if GameEvents.has_signal("modal_closed"):
		GameEvents.modal_closed.emit("betting_circle")

func reset() -> void:
	selected_pact_id = &""
	selected_condition_id = &""
	selected_sentence_id = &""
	_reset_button_state()

func _setup_group(buttons: Array[Button], group: ButtonGroup) -> void:
	for button: Button in buttons:
		button.toggle_mode = true
		button.button_group = group

func _reset_button_state() -> void:
	pact_button_1.button_pressed = false
	pact_button_2.button_pressed = false
	pact_button_3.button_pressed = false
	condition_button_1.button_pressed = false
	condition_button_2.button_pressed = false
	condition_button_3.button_pressed = false
	sentence_button_1.button_pressed = false
	sentence_button_2.button_pressed = false
	sentence_button_3.button_pressed = false
	_update_sigilla_state()

func _on_pact_selected(pact_id: StringName) -> void:
	selected_pact_id = pact_id
	_update_sigilla_state()

func _on_condition_selected(condition_id: StringName) -> void:
	selected_condition_id = condition_id
	_update_sigilla_state()

func _on_sentence_selected(sentence_id: StringName) -> void:
	selected_sentence_id = sentence_id
	_update_sigilla_state()

func _on_sigilla_pressed() -> void:
	if selected_pact_id == &"" or selected_condition_id == &"" or selected_sentence_id == &"":
		return
	GameEvents.bet_confirmed.emit(selected_pact_id, selected_condition_id, selected_sentence_id)
	close()

func _update_sigilla_state() -> void:
	var ready: bool = selected_pact_id != &"" and selected_condition_id != &"" and selected_sentence_id != &""
	sigilla_button.disabled = not ready
