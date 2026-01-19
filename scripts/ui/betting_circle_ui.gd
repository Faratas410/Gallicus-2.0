extends Control
class_name BettingCircleUI

const BETTING_CIRCLE_OPTIONS: Array[Dictionary] = [
	{
		"id": &"CASH_OUT",
		"name": "INCASSA E VAI",
		"doom": "❌ CONDANNA: Nessuna. La folla ti ricorderà come prudente.",
		"condition": "⚠️ CONDIZIONE: Vinci l’arena.",
		"pact": "✅ PATTO: Ricompensa minore, ma sicura.",
	},
	{
		"id": &"FLAWLESS_BLOOD",
		"name": "SANGUE INTEGRO",
		"doom": "❌ CONDANNA: Se fallisci, perdi parte della tua forza per tutta la run.",
		"condition": "⚠️ CONDIZIONE: Vinci senza subire danni.",
		"pact": "✅ PATTO: Ricompensa alta.",
	},
	{
		"id": &"DOUBLE_OR_DIE",
		"name": "RADDOPPI O MUORI",
		"doom": "❌ CONDANNA: Se fallisci, la run termina.",
		"condition": "⚠️ CONDIZIONE: Vinci l’arena.",
		"pact": "✅ PATTO: Ricompensa devastante.",
	},
]

@onready var sigilla_button: Button = $ContractPanel/ContractVBox/SigillaButton as Button
@onready var bet_option_1: Button = $ContractPanel/ContractVBox/BetOptions/BetOption1 as Button
@onready var bet_option_2: Button = $ContractPanel/ContractVBox/BetOptions/BetOption2 as Button
@onready var bet_option_3: Button = $ContractPanel/ContractVBox/BetOptions/BetOption3 as Button
@onready var bet_option_1_name: Label = $ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/BetNameLabel as Label
@onready var bet_option_1_doom: Label = $ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/CondannaLabel as Label
@onready var bet_option_1_condition: Label = $ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/CondizioneLabel as Label
@onready var bet_option_1_pact: Label = $ContractPanel/ContractVBox/BetOptions/BetOption1/CardVBox/PattoLabel as Label
@onready var bet_option_2_name: Label = $ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/BetNameLabel as Label
@onready var bet_option_2_doom: Label = $ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/CondannaLabel as Label
@onready var bet_option_2_condition: Label = $ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/CondizioneLabel as Label
@onready var bet_option_2_pact: Label = $ContractPanel/ContractVBox/BetOptions/BetOption2/CardVBox/PattoLabel as Label
@onready var bet_option_3_name: Label = $ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/BetNameLabel as Label
@onready var bet_option_3_doom: Label = $ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/CondannaLabel as Label
@onready var bet_option_3_condition: Label = $ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/CondizioneLabel as Label
@onready var bet_option_3_pact: Label = $ContractPanel/ContractVBox/BetOptions/BetOption3/CardVBox/PattoLabel as Label

var selected_bet_id: StringName = &""

func _ready() -> void:
	visible = false
	var bet_group: ButtonGroup = ButtonGroup.new()
	var bet_buttons: Array[Button] = [bet_option_1, bet_option_2, bet_option_3]
	_setup_group(bet_buttons, bet_group)
	_apply_option_copy()
	bet_option_1.pressed.connect(_on_bet_selected.bind(BETTING_CIRCLE_OPTIONS[0].get("id", &"")))
	bet_option_2.pressed.connect(_on_bet_selected.bind(BETTING_CIRCLE_OPTIONS[1].get("id", &"")))
	bet_option_3.pressed.connect(_on_bet_selected.bind(BETTING_CIRCLE_OPTIONS[2].get("id", &"")))
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
	selected_bet_id = &""
	_reset_button_state()

func _setup_group(buttons: Array[Button], group: ButtonGroup) -> void:
	for button: Button in buttons:
		button.toggle_mode = true
		button.button_group = group

func _reset_button_state() -> void:
	bet_option_1.button_pressed = false
	bet_option_2.button_pressed = false
	bet_option_3.button_pressed = false
	_update_sigilla_state()

func _on_bet_selected(bet_id: Variant) -> void:
	selected_bet_id = bet_id as StringName
	_update_sigilla_state()

func _on_sigilla_pressed() -> void:
	if selected_bet_id == &"":
		return
	if GameEvents.has_signal("bet_selected"):
		GameEvents.bet_selected.emit(String(selected_bet_id))
	close()

func _update_sigilla_state() -> void:
	var ready: bool = selected_bet_id != &""
	sigilla_button.disabled = not ready

func _apply_option_copy() -> void:
	if BETTING_CIRCLE_OPTIONS.size() < 3:
		return
	_apply_card_copy(BETTING_CIRCLE_OPTIONS[0], bet_option_1_name, bet_option_1_doom, bet_option_1_condition, bet_option_1_pact)
	_apply_card_copy(BETTING_CIRCLE_OPTIONS[1], bet_option_2_name, bet_option_2_doom, bet_option_2_condition, bet_option_2_pact)
	_apply_card_copy(BETTING_CIRCLE_OPTIONS[2], bet_option_3_name, bet_option_3_doom, bet_option_3_condition, bet_option_3_pact)

func _apply_card_copy(bet_data: Dictionary, name_label: Label, doom_label: Label, condition_label: Label, pact_label: Label) -> void:
	name_label.text = str(bet_data.get("name", ""))
	doom_label.text = str(bet_data.get("doom", ""))
	condition_label.text = str(bet_data.get("condition", ""))
	pact_label.text = str(bet_data.get("pact", ""))
