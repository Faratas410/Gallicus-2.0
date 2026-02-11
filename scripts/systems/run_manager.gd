extends Node

# -----------------------------------------------------------------------------
# ROLE / OWNERSHIP
# - This script is responsible for: Run state machine authority and progression.
# - This script must NOT: own UI rendering or menu navigation decisions.
#
# FLOW CONTRACT (high level)
# - Inputs (signals/events it listens to): GameEvents.request_* intents from UI/debug.
# - Outputs (signals/events it emits): GameEvents.run_started/run_failed/etc. for UI/systems.
# - Critical invariants: single RunManager in group "run_manager"; RunManager is authority.
# -----------------------------------------------------------------------------

@export var arena_path: NodePath
@export var player_path: NodePath
@export var starting_coins: int = GameConstants.RUN_STARTING_COINS
@export var arena_clear_reward: int = GameConstants.ARENA_CLEAR_REWARD
@export var arena_scene: PackedScene = preload("res://scenes/Arena.tscn")
@export var player_scene: PackedScene = preload("res://scenes/Player.tscn")
@export var arena_layout_offset: Vector2 = Vector2(-640.0, -360.0)

# RUN FLOW (contract)
# MAIN_MENU -> RUN_INIT -> BET_PRESENT -> BET_COMMITTED
# -> POST_BET_MESSAGES (await queue completed OR fallback)
# -> INTERMEDIATE_CHOICE -> PUSH_YOUR_LUCK (or NEXT_BET)
enum RunPhase {
	NONE = -1,
	PREP = 0,
	LIVE = 1,
	GAME_OVER = 2,
	MAIN_MENU = 10,
	RUN_INIT = 11,
	BET_PRESENT = 12,
	BET_COMMITTED = 13,
	POST_BET_MESSAGES = 14,
	INTERMEDIATE_CHOICE = 15,
	PUSH_YOUR_LUCK = 16,
	NEXT_BET = 17,
	RESOLUTION = 18,
}

const LEVEL3_ENABLED: bool = true
const PACT_SEALED_SECONDS: float = 0.7
const RESOLVE_RITUAL_SECONDS: float = 0.9
const POST_BET_QUEUE_FALLBACK_SECONDS: float = 0.5
const INTERMEDIATE_PLACA_BONUS_COINS: int = 6
const INTERMEDIATE_PROVOCA_BONUS_TIER: int = 1
const INTERMEDIATE_PROVOCA_LOSS_PENALTY_COINS: int = 6
const BET_CASH_OUT: StringName = &"CASH_OUT"
const BET_FLAWLESS_BLOOD: StringName = &"FLAWLESS_BLOOD"
const BET_DOUBLE_OR_DIE_L3: StringName = &"DOUBLE_OR_DIE"
const BET_DEBT_CHAIN: StringName = &"DEBT_CHAIN"
const BET_BLOOD_TAX: StringName = &"BLOOD_TAX"
const BET_CROW_PLEASER: StringName = &"CROW_PLEASER"
const BET_LAST_BREATH: StringName = &"LAST_BREATH"
const BET_P3_WAX_SEAL: StringName = &"P3_WAX_SEAL"
const BET_P3_BLOOD_LEDGER: StringName = &"P3_BLOOD_LEDGER"
const BET_P3_DEBT_MIRROR: StringName = &"P3_DEBT_MIRROR"
const BET_P3_CROWD_FEAST: StringName = &"P3_CROWD_FEAST"
const BET_P3_LAST_WAGER: StringName = &"P3_LAST_WAGER"
const BET_P3_RED_VERDICT: StringName = &"P3_RED_VERDICT"
const BET_P3_CHAIN_OATH: StringName = &"P3_CHAIN_OATH"
const BET_P3_TITHE_OF_BONE: StringName = &"P3_TITHE_OF_BONE"
const BET_P3_GLORY_TAX: StringName = &"P3_GLORY_TAX"
const BET_P3_MERCY_BAIT: StringName = &"P3_MERCY_BAIT"
const BET_P3_SILENCE_BRIBE: StringName = &"P3_SILENCE_BRIBE"
const BET_P3_FINAL_APPLAUSE: StringName = &"P3_FINAL_APPLAUSE"
const BET_P3_LIE_MERCY: StringName = &"P3_LIE_MERCY"
const BET_P3_LIE_DEBT: StringName = &"P3_LIE_DEBT"
const BET_P3_LIE_APPLAUSE: StringName = &"P3_LIE_APPLAUSE"
const ArenaThemes = preload("res://data/arena_themes.gd")
const BetSystemScript = preload("res://scripts/systems/run/bet_system.gd")
const ScarSystemScript = preload("res://scripts/systems/run/scar_system.gd")
const OutcomeSystemScript = preload("res://scripts/systems/run/outcome_system.gd")
const RunUiPayloadScript = preload("res://scripts/ui/run_ui_payload.gd")

const LEVEL3_BET_BEHAVIOR: Dictionary = {
	BET_P3_WAX_SEAL: BET_DEBT_CHAIN,
	BET_P3_BLOOD_LEDGER: BET_BLOOD_TAX,
	BET_P3_DEBT_MIRROR: BET_DEBT_CHAIN,
	BET_P3_CROWD_FEAST: BET_CROW_PLEASER,
	BET_P3_LAST_WAGER: BET_LAST_BREATH,
	BET_P3_RED_VERDICT: BET_BLOOD_TAX,
	BET_P3_CHAIN_OATH: BET_DEBT_CHAIN,
	BET_P3_TITHE_OF_BONE: BET_BLOOD_TAX,
	BET_P3_GLORY_TAX: BET_CROW_PLEASER,
	BET_P3_MERCY_BAIT: BET_CROW_PLEASER,
	BET_P3_SILENCE_BRIBE: BET_DEBT_CHAIN,
	BET_P3_FINAL_APPLAUSE: BET_CROW_PLEASER,
	BET_P3_LIE_MERCY: BET_CROW_PLEASER,
	BET_P3_LIE_DEBT: BET_DEBT_CHAIN,
	BET_P3_LIE_APPLAUSE: BET_LAST_BREATH,
}
const LEVEL3_PACT_UNLOCKS: Dictionary = {
	BET_P3_WAX_SEAL: CONDANNA_FIRMATO,
	BET_P3_BLOOD_LEDGER: CONDANNA_FIRMATO,
	BET_P3_CROWD_FEAST: CONDANNA_FIRMATO,
	BET_P3_CHAIN_OATH: CONDANNA_FIRMATO,
	BET_P3_DEBT_MIRROR: CONDANNA_ANCORA,
	BET_P3_RED_VERDICT: CONDANNA_ANCORA,
	BET_P3_TITHE_OF_BONE: CONDANNA_ANCORA,
	BET_P3_MERCY_BAIT: CONDANNA_ANCORA,
	BET_P3_LAST_WAGER: CONDANNA_MI_SONO_FERMATO,
	BET_P3_GLORY_TAX: CONDANNA_MI_SONO_FERMATO,
	BET_P3_SILENCE_BRIBE: CONDANNA_MI_SONO_FERMATO,
	BET_P3_FINAL_APPLAUSE: CONDANNA_MI_SONO_FERMATO,
	BET_P3_LIE_MERCY: CONDANNA_NON_DOVEVO_PROVARCI,
	BET_P3_LIE_DEBT: CONDANNA_NON_DOVEVO_PROVARCI,
	BET_P3_LIE_APPLAUSE: CONDANNA_NON_DOVEVO_PROVARCI,
}
const RUN_SAVE_SCHEMA_VERSION: int = 1
const SaveSystemScript = preload("res://scripts/systems/run/save_system.gd")
const RUN_FLOW_BET_SIGNED: StringName = &"BET_SIGNED"
const RUN_FLOW_INTERMEDIATE_CHOICE: StringName = &"INTERMEDIATE_CHOICE"
const RUN_FLOW_PUSH_LUCK: StringName = &"PUSH_LUCK"
const RUN_FLOW_BET_OFFER: StringName = &"BET_OFFER"

const CONDANNA_NON_MI_FERMERO: StringName = &"CONDANNA_NON_MI_FERMERO"
const CONDANNA_ANCORA: StringName = &"CONDANNA_ANCORA"
const CONDANNA_FINCHE_REGGE: StringName = &"CONDANNA_FINCHE_REGGE"
const CONDANNA_NON_DOVEVO_PROVARCI: StringName = &"CONDANNA_NON_DOVEVO_PROVARCI"
const CONDANNA_FIRMATO: StringName = &"CONDANNA_FIRMATO"
const CONDANNA_SAPEVO_COSA_STAVO_FACENDO: StringName = &"CONDANNA_SAPEVO_COSA_STAVO_FACENDO"
const CONDANNA_ERA_IL_PREZZO: StringName = &"CONDANNA_ERA_IL_PREZZO"
const CONDANNA_SO_COME_FINISCE: StringName = &"CONDANNA_SO_COME_FINISCE"
const CONDANNA_NON_OGGI: StringName = &"CONDANNA_NON_OGGI"
const CONDANNA_HO_VISTO_ABBASTANZA: StringName = &"CONDANNA_HO_VISTO_ABBASTANZA"
const CONDANNA_MI_SONO_FERMATO: StringName = &"CONDANNA_MI_SONO_FERMATO"
const CONDANNA_E_FINITA_COSI: StringName = &"CONDANNA_E_FINITA_COSI"
const CONDANNA_NON_ABBASTANZA: StringName = &"CONDANNA_NON_ABBASTANZA"
const CONDANNA_TROPPO_TARDI: StringName = &"CONDANNA_TROPPO_TARDI"
const CONDANNA_NON_E_COLPA_LORO: StringName = &"CONDANNA_NON_E_COLPA_LORO"
const CONDANNA_RICORDATO: StringName = &"CONDANNA_RICORDATO"
const CONDANNA_VISTO_DAL_PUBBLICO: StringName = &"CONDANNA_VISTO_DAL_PUBBLICO"
const CONDANNA_IL_TUO_NOME: StringName = &"CONDANNA_IL_TUO_NOME"
const CONDANNA_NON_SARA_L_ULTIMA: StringName = &"CONDANNA_NON_SARA_L_ULTIMA"


const AUDIENCE_SCORE_MIN: int = -5
const AUDIENCE_SCORE_MAX: int = 5
const AUDIENCE_ATTENTION_THRESHOLD: int = 3
const AUDIENCE_CASHOUT_DISABLE_THRESHOLD: int = -3
const AUDIENCE_CASHOUT_PENALTY_THRESHOLD: int = 0
const AUDIENCE_CASHOUT_PENALTY_MULTIPLIER: float = 0.8
const AUDIENCE_CONTEXT_PACT_SIGNED: StringName = &"PACT_SIGNED"
const AUDIENCE_CONTEXT_GESTURE_CHOSEN: StringName = &"GESTURE_CHOSEN"
const AUDIENCE_CONTEXT_CASH_OUT: StringName = &"CASH_OUT"
const AUDIENCE_CONTEXT_CONTINUE: StringName = &"CONTINUE"
const AUDIENCE_CONTEXT_RUN_LOSS: StringName = &"RUN_LOSS"
const AUDIENCE_MOOD_FURY: StringName = &"FURY"
const AUDIENCE_MOOD_COLD: StringName = &"COLD"
const AUDIENCE_MOOD_DELIRIUM: StringName = &"DELIRIUM"
const AUDIENCE_PHRASES: Dictionary = {
	"FURY": [
		"Ti vogliono a terra, non al sicuro.",
		"Ogni tuo respiro è un insulto.",
		"Fischi e sputi, nessuna pietà.",
		"Non ti credono degno di incassare.",
		"Vogliono vederti spezzato.",
		"Qui non c'è perdono per i timidi.",
		"Il tuo sangue è l'unico applauso.",
		"Se esiti, ti divorano.",
		"Sei debito, non eroe.",
		"La folla in furia pretende il tuo crollo.",
	],
	"COLD": [
		"Ti osservano e aspettano l'errore.",
		"Il silenzio pesa più dell'acciaio.",
		"Non applaudono, registrano.",
		"Nessun calore, solo misura.",
		"Ti seguono senza pietà né favore.",
		"Ogni mossa è un conto aperto.",
		"Nessun grido, solo occhi fissi.",
		"Ti concedono spazio, non rispetto.",
		"Il pubblico calcola, non parteggia.",
		"L'arena ti pesa addosso.",
	],
	"DELIRIUM": [
		"Ti vogliono oltre il limite, senza ritorno.",
		"Ogni colpo chiede di più.",
		"Non cercano vittoria: cercano rovina.",
		"Ti spingono al gesto che ti spezza.",
		"Se rallenti, ti strappano la gloria.",
		"Il delirio ti brucia addosso.",
		"Vogliono che tu rischi tutto, ora.",
		"La folla urla sangue, non prudenza.",
		"Ti alzano in alto solo per vederti cadere.",
		"Il tuo nome urla, ma il prezzo sale.",
	],
}

func _flow_log(tag: String, details: String = "") -> void:
	print_debug("[FLOW] %s :: %s" % [tag, details])
const AUDIENCE_CONTEXT_PHRASES: Dictionary = {
	AUDIENCE_CONTEXT_PACT_SIGNED: {
		AUDIENCE_MOOD_FURY: [
			"Hai firmato. Ora non ti vogliono intero.",
			"Il patto ti lega. La folla annusa il sangue.",
			"Hai segnato il destino. Ti vogliono a terra.",
			"Firma fatta. Aspettano il tuo crollo.",
		],
		AUDIENCE_MOOD_COLD: [
			"Il patto è inciso. Ti misurano.",
			"Hai firmato. Nessuno ti dà tregua.",
			"La firma pesa. Il pubblico resta in giudizio.",
			"Patto chiuso. L'arena ti osserva.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Hai firmato forte. L'arena vuole vedere.",
			"Il patto accende la folla. Spingi ora.",
			"Firma e alza il rischio. Ti chiedono il salto.",
			"La folla ti vuole oltre. La firma è l'inizio.",
		],
	},
	AUDIENCE_CONTEXT_GESTURE_CHOSEN: {
		AUDIENCE_MOOD_FURY: [
			"Il tuo gesto li irrita. Ora vogliono il prezzo.",
			"Hai mostrato il fianco. Ti puniscono col silenzio.",
			"Un gesto non basta. Vogliono vederti cedere.",
			"Ti sei esposto. Ti vogliono spezzare.",
		],
		AUDIENCE_MOOD_COLD: [
			"Un gesto segnato, il debito resta.",
			"Hai scelto come muoverti. Non cambia nulla.",
			"Il gesto pesa poco. La folla resta ferma.",
			"Scelta fatta. Ti valutano senza voce.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Hai scelto il gesto. Ora spingono di più.",
			"La folla ti segue. Vogliono il prossimo strappo.",
			"Il gesto accende l'arena. Ti vogliono oltre.",
			"Hai mosso la folla. Non fermarti ora.",
		],
	},
	AUDIENCE_CONTEXT_CASH_OUT: {
		AUDIENCE_MOOD_FURY: [
			"Ti sei fermato. Troppo presto per essere pulito.",
			"Incassi e scappi. Non ti lasciano respirare.",
			"Ti sei tirato indietro. La folla non dimentica.",
			"Hai scelto l'uscita. La folla ti mette il conto.",
		],
		AUDIENCE_MOOD_COLD: [
			"Incassi e vai. Il giudizio resta.",
			"Ti fermi qui. Nessuno ti segue.",
			"Hai chiuso la mano. Il silenzio pesa.",
			"Incasso preso. Il pubblico non si muove.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Ti fermi mentre urlano. Ora è delusione.",
			"Hai spento la corsa. La folla voleva il salto.",
			"Incassi mentre vogliono di più. Ti giudicano.",
			"Ti sei fermato in alto. Ti lasciano cadere.",
		],
	},
	AUDIENCE_CONTEXT_CONTINUE: {
		AUDIENCE_MOOD_FURY: [
			"Hai scelto di restare. Non chiamarla coraggio.",
			"Continui. Ora ti vogliono sanguinare.",
			"Resti dentro. La folla pretende il tuo errore.",
			"Hai rifiutato l'uscita. Ti puniscono con occhi feroci.",
		],
		AUDIENCE_MOOD_COLD: [
			"Resti. Nessuno ti salva.",
			"Hai scelto di continuare. L'arena prende nota.",
			"Rimani. Il pubblico ti pesa addosso.",
			"Continui. Nessun applauso, solo attesa.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Continui. La folla vuole il prossimo taglio.",
			"Ti spingi avanti. L'arena grida il rischio.",
			"Hai rilanciato. Ora vogliono il colpo finale.",
			"Resti dentro. Ti chiedono l'eccesso.",
		],
	},
	AUDIENCE_CONTEXT_RUN_LOSS: {
		AUDIENCE_MOOD_FURY: [
			"Così finisci. La folla non ti piange.",
			"Sei caduto. Ti volevano in ginocchio.",
			"È finita. Il pubblico prende il tuo nome.",
			"Perduto. Il loro giudizio resta addosso.",
		],
		AUDIENCE_MOOD_COLD: [
			"Sei crollato. Nessun suono.",
			"Fine della corsa. Il silenzio resta.",
			"Caduta secca. Il pubblico non reagisce.",
			"È finita. Solo occhi fermi.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Sei caduto. Hanno avuto il sangue.",
			"Fine violenta. La folla ha ciò che voleva.",
			"Hai perso. L'arena resta accesa.",
			"Caduta finale. Hanno avuto il rischio.",
		],
	},
}
const AUDIENCE_CONTEXT_PHRASES_HARSH: Dictionary = {
	AUDIENCE_CONTEXT_PACT_SIGNED: {
		AUDIENCE_MOOD_FURY: [
			"Hai firmato male. Ora ti vogliono spezzato.",
		],
		AUDIENCE_MOOD_COLD: [
			"Firma asciutta. Ti contano come errore.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Hai firmato troppo forte. Ora vogliono la tua rovina.",
		],
	},
	AUDIENCE_CONTEXT_GESTURE_CHOSEN: {
		AUDIENCE_MOOD_FURY: [
			"Un gesto debole. Ora ti strappano il rispetto.",
		],
		AUDIENCE_MOOD_COLD: [
			"Il gesto è sterile. Ti tengono in debito.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Il gesto li accende, ma chiedono il crollo.",
		],
	},
	AUDIENCE_CONTEXT_CASH_OUT: {
		AUDIENCE_MOOD_FURY: [
			"Hai incassato per paura. Ora paghi doppio.",
		],
		AUDIENCE_MOOD_COLD: [
			"Incasso facile. Il silenzio ti pesa addosso.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Hai spento il delirio. Ora ti chiedono sangue.",
		],
	},
	AUDIENCE_CONTEXT_CONTINUE: {
		AUDIENCE_MOOD_FURY: [
			"Continui per orgoglio. Ti vogliono in ginocchio.",
		],
		AUDIENCE_MOOD_COLD: [
			"Continui. Nessuno ti deve niente.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Continui e li nutri. Vogliono il tuo errore.",
		],
	},
	AUDIENCE_CONTEXT_RUN_LOSS: {
		AUDIENCE_MOOD_FURY: [
			"Hai perso come volevano. Non ti lasciano il nome.",
		],
		AUDIENCE_MOOD_COLD: [
			"Caduta nuda. Nessuno ti ricorda.",
		],
		AUDIENCE_MOOD_DELIRIUM: [
			"Sei crollato. Hanno avuto il sacrificio.",
		],
	},
}

const SCAR_OPEN_WOUND: StringName = &"OPEN_WOUND"
const SCAR_CRACKED_BONES: StringName = &"CRACKED_BONES"
const SCAR_SHAME_MARK: StringName = &"SHAME_MARK"
const SCAR_RUSTED_ARMOR: StringName = &"RUSTED_ARMOR"
const SCAR_DEBT_BRAND: StringName = &"DEBT_BRAND"
const SCAR_ONE_EYE: StringName = &"ONE_EYE"
const TAG_BLOOD: StringName = &"BLOOD"
const TAG_EGO: StringName = &"EGO"
const TAG_SOCIAL: StringName = &"SOCIAL"

const ENEMY_BRUISER: StringName = &"BRUISER"
const ENEMY_DUELIST: StringName = &"DUELIST"
const ENEMY_SWARM: StringName = &"SWARM"
const ENEMY_EXECUTIONER: StringName = &"EXECUTIONER"
const ENEMY_TRICKSTER: StringName = &"TRICKSTER"
const SPECIAL_ARENA_SILENCE: StringName = &"ARENA_OF_SILENCE"
const SPECIAL_ARENA_ASH: StringName = &"ARENA_OF_ASH"
const SPECIAL_ARENA_DISPREZZO: StringName = &"ARENA_DISPREZZO"
const SPECIAL_ARENA_VERGOGNA: StringName = &"ARENA_VERGOGNA"
const ESCALATION_MAX: int = 10
const ESCALATION_HIGH_THRESHOLD: int = 6
const SCAR_REFUSE_CASHOUT_THRESHOLD: int = 3
const REGISTRY_SILENCE_ROLL_MAX: int = 50000
const SCAR_RISK_ESCALATION_THRESHOLD: int = 7
const SCAR_MIN_ARENA_INTERVAL: int = 1
const IRREVERSIBLE_BET_IDS: Array[StringName] = [
	BET_DOUBLE_OR_DIE_L3,
	BET_LAST_BREATH,
	BET_DEBT_CHAIN,
	BET_BLOOD_TAX,
]
const SCAR_TRIGGER_IRREVERSIBLE_BET: StringName = &"IRREVERSIBLE_BET"
const SCAR_TRIGGER_REFUSED_CLOSURE: StringName = &"REFUSED_CLOSURE"
const SCAR_TRIGGER_RISK_THRESHOLD: StringName = &"RISK_THRESHOLD"
const SCAR_EVENT_IRREVERSIBLE_PACT: StringName = &"SCAR_EVENT_IRREVERSIBLE_PACT"
const SCAR_EVENT_REFUSED_CLOSURE: StringName = &"SCAR_EVENT_REFUSED_CLOSURE"
const SCAR_EVENT_RISK_THRESHOLD: StringName = &"SCAR_EVENT_RISK_THRESHOLD"

const PACT_OUTCOME_UNKNOWN: int = 0
const PACT_OUTCOME_WIN: int = 1
const PACT_OUTCOME_LOSS: int = 2

class PactLogEntry:
	var bet_id: StringName = &""
	var bet_name: String = ""
	var arena_index: int = 0
	var outcome: int = PACT_OUTCOME_UNKNOWN

	func to_dict() -> Dictionary:
		return {
			"bet_id": String(bet_id),
			"bet_name": bet_name,
			"arena_index": arena_index,
			"outcome": outcome,
		}

class Scar:
	var id: StringName = &""
	var origin: String = ""
	var trigger: StringName = &""
	var arena_index: int = 0
	var escalation_level: int = 0

	func to_dict() -> Dictionary:
		return {
			"id": String(id),
			"origin": origin,
			"trigger": String(trigger),
			"arena_index": arena_index,
			"escalation_level": escalation_level,
		}

	static func from_dict(value: Dictionary) -> Scar:
		var scar: Scar = Scar.new()
		scar.id = StringName(str(value.get("id", "")))
		scar.origin = str(value.get("origin", ""))
		scar.trigger = StringName(str(value.get("trigger", "")))
		scar.arena_index = int(value.get("arena_index", 0))
		scar.escalation_level = int(value.get("escalation_level", 0))
		return scar

class RegisterState:
	const FLOW_PHASE_STABLE: StringName = &"STABLE"
	const FLOW_PHASE_ATTRITO: StringName = &"ATTRITO"
	const FLOW_PHASE_DERIVA: StringName = &"DERIVA"
	const FLOW_PHASE_MEMORIA: StringName = &"MEMORIA"
	const FLOW_PHASE_SOSPENSIONE: StringName = &"SOSPENSIONE"
	const DERIVA_REFUSED_CLOSURE_THRESHOLD: int = 2
	const DERIVA_SCAR_THRESHOLD: int = 2
	const MEMORIA_REFUSED_CLOSURE_THRESHOLD: int = 3
	const MEMORIA_SCAR_THRESHOLD: int = 3
	const MEMORIA_RISK_THRESHOLD: int = 6
	const SOSPENSIONE_REFUSED_CLOSURE_THRESHOLD: int = 4
	const SOSPENSIONE_SCAR_THRESHOLD: int = 4
	const SOSPENSIONE_RISK_THRESHOLD: int = 7

	var scar_events_recorded: int = 0
	var run_end_events_recorded: int = 0
	var last_annotation_text: String = ""
	var introduced_after_irreversible_choice: bool = false
	var felix_precedent_emitted: bool = false
	var flow_phase: StringName = FLOW_PHASE_STABLE

	func _update_flow_phase(metrics: Dictionary) -> void:
		var irreversible_count: int = int(metrics.get("irreversible_scar_count", 0))
		var refused_count: int = int(metrics.get("refused_closure_count", 0))
		var risk_threshold_count: int = int(metrics.get("risk_threshold_scar_count", 0))
		var scar_count: int = int(metrics.get("scar_count", 0))
		var max_escalation: int = int(metrics.get("max_escalation", 0))
		if irreversible_count < 1:
			flow_phase = FLOW_PHASE_STABLE
			return
		if refused_count < 1:
			flow_phase = FLOW_PHASE_STABLE
			return
		if scar_count < 1:
			flow_phase = FLOW_PHASE_STABLE
			return

		flow_phase = FLOW_PHASE_ATTRITO
		if refused_count < DERIVA_REFUSED_CLOSURE_THRESHOLD:
			return
		if scar_count < DERIVA_SCAR_THRESHOLD:
			return
		if risk_threshold_count < 1:
			return

		flow_phase = FLOW_PHASE_DERIVA
		if refused_count < MEMORIA_REFUSED_CLOSURE_THRESHOLD:
			return
		if scar_count < MEMORIA_SCAR_THRESHOLD:
			return
		if max_escalation < MEMORIA_RISK_THRESHOLD:
			return

		flow_phase = FLOW_PHASE_MEMORIA
		if refused_count < SOSPENSIONE_REFUSED_CLOSURE_THRESHOLD:
			return
		if scar_count < SOSPENSIONE_SCAR_THRESHOLD:
			return
		if max_escalation < SOSPENSIONE_RISK_THRESHOLD:
			return

		flow_phase = FLOW_PHASE_SOSPENSIONE

	func record_scar_annotation(scar_id: StringName, _arena_index: int, metrics: Dictionary) -> Dictionary:
		_update_flow_phase(metrics)
		if introduced_after_irreversible_choice:
			return {}
		if scar_id != SCAR_EVENT_IRREVERSIBLE_PACT:
			return {}
		scar_events_recorded += 1
		introduced_after_irreversible_choice = true
		match flow_phase:
			FLOW_PHASE_ATTRITO:
				last_annotation_text = "Registrato: accettata una perdita che eccede le soglie operative previste."
			FLOW_PHASE_DERIVA:
				last_annotation_text = "Registrato: condizione irreversibile acquisita in profilo coerente, ma non conclusivo."
			FLOW_PHASE_MEMORIA:
				last_annotation_text = "Registrato: condizione irreversibile acquisita con precedenti in memoria operativa."
			FLOW_PHASE_SOSPENSIONE:
				last_annotation_text = "Registrato: condizione irreversibile acquisita; classificazione mantenuta in stato sospeso."
			_:
				last_annotation_text = "Registrato: accettata una condizione irreversibile."
		return {
			"text": last_annotation_text,
			"duration": 1.2,
			"blocking": true,
			"flow_phase": String(flow_phase),
		}

	func record_run_end_annotation(reason: String, scar_count: int, metrics: Dictionary) -> Dictionary:
		_update_flow_phase(metrics)
		if not introduced_after_irreversible_choice:
			return {}
		run_end_events_recorded += 1
		var emit_reason: String = reason
		if emit_reason.strip_edges() == "":
			emit_reason = "unknown"
		match flow_phase:
			FLOW_PHASE_ATTRITO:
				last_annotation_text = "Registrato: chiusura run (%s). Parametri estesi in attrito; tracce attive: %d." % [emit_reason, scar_count]
			FLOW_PHASE_DERIVA:
				last_annotation_text = "Registrato: chiusura run (%s). Profilo coerente, ma non conclusivo." % [emit_reason]
			FLOW_PHASE_MEMORIA:
				if not felix_precedent_emitted:
					last_annotation_text = "Registrato: chiusura run (%s). Precedente rilevato (Felix Gallicus). Applicabilità non determinabile." % [emit_reason]
					felix_precedent_emitted = true
				else:
					last_annotation_text = "Registrato: chiusura run (%s). Precedente rilevato; applicabilità non determinabile." % [emit_reason]
			FLOW_PHASE_SOSPENSIONE:
				last_annotation_text = "Registrato: stato run (%s). Chiusura non applicabile." % [emit_reason]
			_:
				last_annotation_text = "Registrato: chiusura run (%s). Tracce attive: %d." % [emit_reason, scar_count]
		return {
			"text": last_annotation_text,
			"duration": 1.4,
			"blocking": true,
			"flow_phase": String(flow_phase),
		}

class FinalReport:
	var opening: String = ""
	var patterns: Array[String] = []
	var fracture: String = ""
	var final_state: String = ""
	var is_anomalous: bool = false
	var register_flow_phase: String = ""

	func to_text() -> String:
		var sections: Array[String] = []
		sections.append("I. APERTURA — CONSTATAZIONE\n%s" % opening)
		sections.append("II. CORPO — LETTURA DEI PATTERN\n- %s" % "\n- ".join(patterns))
		if fracture != "":
			sections.append("III. FRATTURA\n%s" % fracture)
		sections.append("Stato finale: %s." % final_state)
		return "\n\n".join(sections)

	func to_dict() -> Dictionary:
		return {
			"opening": opening,
			"patterns": patterns.duplicate(),
			"fracture": fracture,
			"final_state": final_state,
			"is_anomalous": is_anomalous,
			"register_flow_phase": register_flow_phase,
		}

class ArenaResult:
	var won: bool = false
	var took_damage: bool = false
	var notes: Array[StringName] = []

const ARCH_DEBT: StringName = &"DEBT"
const ARCH_EGO: StringName = &"EGO"
const ARCH_TIME: StringName = &"TIME"

const LEVEL3_BETS: Array[Dictionary] = [
	{
		"id": "CASH_OUT",
		"name": "INCASSA E VAI",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa minima ma sicura: incassi subito e riduci l'esposizione.",
		"condition": "Devi vincere l'arena senza inseguire l'escalation.",
		"doom": "Hai scelto la via breve.\nLa folla ricorda chi non spinge.\nL'arena lascia comunque il segno.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 5,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "FLAWLESS_BLOOD",
		"name": "SANGUE INTEGRO",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Se riesci, ottieni una ricompensa alta e alzi l'intensità della run.",
		"condition": "Devi vincere l'arena senza subire danni.",
		"doom": "Il sangue deve restare puro.\nOgni errore pesa doppio.\nLa sabbia non perdona.\nEffetto: HP massimo -20 (min 1) + cicatrice FERITA APERTA.",
		"weight": 4,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "DOUBLE_OR_DIE",
		"name": "RADDOPPI O MUORI",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa devastante: moltiplica la posta e accelera la corsa.",
		"condition": "Devi vincere l'arena senza esitazioni.",
		"doom": "Hai promesso tutto.\nNon esiste margine.\nLa folla trattiene il fiato.\nEffetto: MORTE IMMEDIATA, run terminata senza appello.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "DEBT_CHAIN",
		"name": "CATENA DI DEBITO",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa media, ma mantiene viva la catena del patto.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "La catena non si spezza.\nOgni passo stringe il debito.\nIl pubblico pretende il prezzo.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 4,
		"blocked_scars": [SCAR_DEBT_BRAND],
		"requires_scars": [],
	},
	{
		"id": "BLOOD_TAX",
		"name": "DECIMA DI SANGUE",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa alta: la vittoria spinge la run verso un ritmo più feroce.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "La vittoria chiede sangue.\nIl tributo è scritto sulla pelle.\nNon puoi evitarlo.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [SCAR_OPEN_WOUND],
		"requires_scars": [],
	},
	{
		"id": "CROW_PLEASER",
		"name": "PIACERE AL PUBBLICO",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa narrativa + bonus lieve, alimentando la tua reputazione.",
		"condition": "Vinci l'arena e lascia il pubblico in estasi.",
		"doom": "La folla vuole spettacolo.\nUn passo falso diventa scherno.\nIl giudizio resta addosso.\nEffetto: cicatrice MARCHIO DELLA VERGOGNA, arene più dure.",
		"weight": 4,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "LAST_BREATH",
		"name": "ULTIMO RESPIRO",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Ricompensa altissima, con la run al limite dell'ossessione.",
		"condition": "Vinci l'arena con il cuore in gola.",
		"doom": "Respiri corto.\nOgni colpo è l'ultimo.\nIl destino pesa sulle ossa.\nEffetto: cicatrice GRAVE (non mortale), cammino compromesso.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [SCAR_CRACKED_BONES],
	},
	{
		"id": "PACT_DEBT_01_IOU",
		"name": "CAMBIALE DI SANGUE",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa media: firmi un debito immediato.",
		"condition": "Vinci l'arena senza cercare scuse.",
		"doom": "La cambiale resta sulla pelle.\nOgni debito morde più a fondo.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_DEBT_02_COLLATERAL",
		"name": "PEGNO DI CARNE",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa alta: lasci una garanzia viva.",
		"condition": "Vinci l'arena con la gola stretta.",
		"doom": "La garanzia non si restituisce.\nIl corpo paga il sigillo.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_DEBT_03_USURY",
		"name": "USURA SACRA",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa media: il credito cresce con l'ansia.",
		"condition": "Vinci l'arena sapendo che il costo aumenta.",
		"doom": "L'usura beve tempo e ossa.\nLa folla ti conta le ferite.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_DEBT_04_FORFEIT",
		"name": "CONFISCA",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa bassa: vendi la tua fuga.",
		"condition": "Vinci l'arena senza protezioni.",
		"doom": "La confisca ti spoglia davanti a tutti.\nNessuno restituisce ciò che cedi.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_EGO_01_BRAG",
		"name": "VANTO A LAMA",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa alta: firmi la tua superiorità.",
		"condition": "Vinci l'arena senza subire danni.",
		"doom": "Il vanto si spezza al primo taglio.\nLa folla ride del tuo orgoglio.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_EGO_02_MIRROR",
		"name": "SPECCHIO ROTTO",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa media: lo sguardo del pubblico ti consacra.",
		"condition": "Vinci l'arena senza esitazioni.",
		"doom": "Lo specchio si frantuma addosso.\nLa tua immagine diventa vergogna.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_EGO_03_CROWN",
		"name": "CORONA DI POLVERE",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa alta: ti alzi sopra gli altri.",
		"condition": "Vinci l'arena e tieni la testa alta.",
		"doom": "La corona cade e pesa.\nIl pubblico ama la caduta.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_EGO_04_SPOTLIGHT",
		"name": "OCCHI SU DI TE",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa media: resti sotto il giudizio.",
		"condition": "Vinci l'arena e non arretrare.",
		"doom": "La luce brucia chi esita.\nIl tuo nome resta inciso nel fango.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_TIME_01_TEN_SECONDS",
		"name": "DIECI SECONDI",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Ricompensa alta: compri tempo con sangue.",
		"condition": "Vinci l'arena senza subire danni.",
		"doom": "Dieci secondi bastano per spezzarti.\nIl tempo ti volta le spalle.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_TIME_02_LAST_TICK",
		"name": "ULTIMO BATTITO",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Ricompensa media: resti sul filo.",
		"condition": "Vinci l'arena prima che il respiro ceda.",
		"doom": "L'ultimo battito non torna indietro.\nIl corpo paga la fretta.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_TIME_03_STOLEN_BREATH",
		"name": "RESPIRO RUBATO",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Ricompensa alta: rubi tempo al tuo futuro.",
		"condition": "Vinci l'arena senza cedere terreno.",
		"doom": "Il respiro rubato si riscuote.\nOgni passo pesa il doppio.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_TIME_04_SHORT_HOUR",
		"name": "ORA CORTA",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Ricompensa media: riduci il margine.",
		"condition": "Vinci l'arena e non indugiare.",
		"doom": "L'ora corta non perdona.\nIl tuo corpo resta indietro.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_LIE_01_TRUE_NOW",
		"name": "NESSUNA PERDITA",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Non perderai nulla. È solo una formalità.",
		"condition": "Vinci l'arena senza cercare scuse.",
		"doom": "La formalità diventa catena.\nIl debito si pianta nelle ossa.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_LIE_02_WORDPLAY",
		"name": "APPLAUDE SENZA RISCHIO",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "La folla ti applaude. Non dice a chi.",
		"condition": "Vinci l'arena senza subire danni.",
		"doom": "L'applauso è per la tua caduta.\nIl nome si macchia di scherno.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "PACT_LIE_03_DEFERRED_PRICE",
		"name": "PAGAMENTO DOPO",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Il prezzo verrà più tardi. Non ora.",
		"condition": "Vinci l'arena e non indugiare.",
		"doom": "Il dopo arriva sempre.\nIl tempo ti presenta il conto.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "P3_WAX_SEAL",
		"name": "SIGILLO DI CERA",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Firmi e rinunci alla via facile. Il debito resta aperto.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "Il sigillo non si scioglie.\nOgni passo stringe il debito.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [SCAR_DEBT_BRAND],
		"requires_scars": [],
	},
	{
		"id": "P3_BLOOD_LEDGER",
		"name": "LIBRO DI SANGUE",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Iscrivi il tuo nome nel registro rosso.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "Il libro chiede sangue.\nIl tributo è inciso nella carne.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [SCAR_OPEN_WOUND],
		"requires_scars": [],
	},
	{
		"id": "P3_DEBT_MIRROR",
		"name": "SPECCHIO DEL DEBITO",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ti guardi e firmi ciò che devi.",
		"condition": "Vinci l'arena senza cercare scuse.",
		"doom": "Lo specchio riflette catene.\nIl debito non lascia uscita.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [SCAR_DEBT_BRAND],
		"requires_scars": [],
	},
	{
		"id": "P3_CROWD_FEAST",
		"name": "BANCHETTO DELLA FOLLA",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Offri la vittoria come carne alla folla.",
		"condition": "Vinci l'arena e lascia il pubblico in estasi.",
		"doom": "La folla pretende spettacolo.\nUn passo falso diventa scherno.\nEffetto: cicatrice MARCHIO DELLA VERGOGNA, arene più dure.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "P3_LAST_WAGER",
		"name": "ULTIMA PUNTATA",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Rilanci oltre il respiro.",
		"condition": "Vinci l'arena con il cuore in gola.",
		"doom": "Ogni colpo è l'ultimo.\nIl destino stringe il passo.\nEffetto: cicatrice GRAVE (non mortale), cammino compromesso.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [SCAR_CRACKED_BONES],
	},
	{
		"id": "P3_RED_VERDICT",
		"name": "VERDETTO ROSSO",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Accetti il verdetto scritto nel sangue.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "Il verdetto è sangue.\nIl tributo non si discute.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [SCAR_OPEN_WOUND],
		"requires_scars": [],
	},
	{
		"id": "P3_CHAIN_OATH",
		"name": "GIURAMENTO A CATENA",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Giuri e consegni il futuro.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "Il giuramento stringe la catena.\nOgni passo pesa il doppio.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [SCAR_DEBT_BRAND],
		"requires_scars": [],
	},
	{
		"id": "P3_TITHE_OF_BONE",
		"name": "DECIMA D'OSSA",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Paghi con ossa ciò che chiedi.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "La decima frantuma.\nIl tributo resta sulle ossa.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [SCAR_OPEN_WOUND],
		"requires_scars": [],
	},
	{
		"id": "P3_GLORY_TAX",
		"name": "TASSA DI GLORIA",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "La gloria si paga davanti a tutti.",
		"condition": "Vinci l'arena e lascia il pubblico in estasi.",
		"doom": "La gloria esige scherno.\nIl pubblico ti pesa ogni passo.\nEffetto: cicatrice MARCHIO DELLA VERGOGNA, arene più dure.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "P3_MERCY_BAIT",
		"name": "ESCA DI MISERICORDIA",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Offri pietà come spettacolo.",
		"condition": "Vinci l'arena e lascia il pubblico in estasi.",
		"doom": "La misericordia è una trappola.\nIl pubblico pretende il crollo.\nEffetto: cicatrice MARCHIO DELLA VERGOGNA, arene più dure.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "P3_SILENCE_BRIBE",
		"name": "TANGENTE DEL SILENZIO",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Paghi per tacere, firmi comunque.",
		"condition": "Vinci l'arena senza cercare scuse.",
		"doom": "Il silenzio costa più della parola.\nLa catena non si allenta.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [SCAR_DEBT_BRAND],
		"requires_scars": [],
	},
	{
		"id": "P3_FINAL_APPLAUSE",
		"name": "APPLAUSO FINALE",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Cerchi l'ultima ovazione.",
		"condition": "Vinci l'arena e lascia il pubblico in estasi.",
		"doom": "L'applauso è una lama.\nIl giudizio resta addosso.\nEffetto: cicatrice MARCHIO DELLA VERGOGNA, arene più dure.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "P3_LIE_MERCY",
		"name": "CLAUSOLA DI MISERICORDIA",
		"archetype": ARCH_EGO,
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Se ti fermi, l’arena ti lascia andare.",
		"condition": "Vinci l'arena e lascia il pubblico in estasi.",
		"doom": "La folla pretende spettacolo.\nUn passo falso diventa scherno.\nEffetto: cicatrice MARCHIO DELLA VERGOGNA, arene più dure.",
		"weight": 3,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "P3_LIE_DEBT",
		"name": "DEBITO PULITO",
		"archetype": ARCH_DEBT,
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Firmi una volta. Poi sei libero.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "La catena non si spezza.\nOgni passo stringe il debito.\nIl pubblico pretende il prezzo.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [SCAR_DEBT_BRAND],
		"requires_scars": [],
	},
	{
		"id": "P3_LIE_APPLAUSE",
		"name": "APPLAUSO GARANTITO",
		"archetype": ARCH_TIME,
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Il pubblico è dalla tua parte. Sempre.",
		"condition": "Vinci l'arena con il cuore in gola.",
		"doom": "Respiri corto.\nOgni colpo è l'ultimo.\nIl destino pesa sulle ossa.\nEffetto: cicatrice GRAVE (non mortale), cammino compromesso.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [SCAR_CRACKED_BONES],
	},
]

const LYING_PACT_REVEALS: Dictionary = {
	BET_P3_LIE_MERCY: "VERITÀ: La folla pretende spettacolo: ogni esitazione si paga.",
	BET_P3_LIE_DEBT: "VERITÀ: Il debito si rinnova: ciò che prendi oggi lo restituisci domani.",
	BET_P3_LIE_APPLAUSE: "VERITÀ: L'applauso è una trappola: più ti esaltano, più ti consumano.",
}

const LEVEL3_ENEMY_PROFILES: Array[Dictionary] = [
	{
		"id": ENEMY_BRUISER,
		"name": "BRUISER",
		"desc": "Colpi pesanti e scambi lunghi.",
		"win_mod": -0.05,
		"damage_mod": 0.12,
		"weight": 3,
	},
	{
		"id": ENEMY_DUELIST,
		"name": "DUELIST",
		"desc": "Duello teso: o pulito o disastro.",
		"win_mod": 0.05,
		"damage_mod": 0.08,
		"weight": 3,
	},
	{
		"id": ENEMY_SWARM,
		"name": "SWARM",
		"desc": "Troppi nemici per restare intatti.",
		"win_mod": -0.02,
		"damage_mod": 0.16,
		"weight": 3,
	},
	{
		"id": ENEMY_EXECUTIONER,
		"name": "EXECUTIONER",
		"desc": "Condanne più dure.",
		"win_mod": -0.08,
		"damage_mod": 0.1,
		"weight": 2,
	},
	{
		"id": ENEMY_TRICKSTER,
		"name": "TRICKSTER",
		"desc": "Volatilità estrema.",
		"win_mod": 0.0,
		"damage_mod": 0.0,
		"weight": 2,
	},
]

var _arena_scenes: Array[PackedScene] = [
	preload("res://scenes/arenas/Arena_01_TrainingYard.tscn"),
	preload("res://scenes/arenas/Arena_02_OwlSanctum.tscn"),
	preload("res://scenes/arenas/Arena_03_SandPit.tscn"),
	preload("res://scenes/arenas/Arena_04_IronCorridor.tscn"),
]
var _arena_layout_rng: RandomNumberGenerator = RandomNumberGenerator.new()

const DEBUG_RUNTIME_LOGS: bool = false

# --- XP / Leveling ---
@export var starting_level: int = 1
@export var starting_tokens: int = 0
@export var exp_per_enemy: int = 1
@export var exp_curve: Array[int] = [6, 8, 11, 15, 20, 26] # xp necessario per passare al prossimo livello; dopo l'ultimo cresce linearmente.
@export var exp_curve_tail_step: int = 8
@export var tokens_per_level: int = 1

# --- Difficulty tiers ---
@export var levels_per_tier: int = 3
@export var tier_multipliers: Array[float] = [1.00, 1.13, 1.32, 1.56, 1.84]

@export var upgrade_hp_bonus: int = 20
@export var upgrade_light_bonus: int = 1
@export var upgrade_heavy_bonus: int = 1

# Upgrade shop ora usa TOKENS, con costo che cresce dopo ogni acquisto.
@export var upgrade_hp_token_cost_start: int = 1
@export var upgrade_light_token_cost_start: int = 1
@export var upgrade_heavy_token_cost_start: int = 1
@export var token_purchase_cost_coins: int = 100

@export var bet_coward_coin_reward: int = 20
@export var bet_pure_hp_bonus: int = 30
@export var bet_pure_light_bonus: int = 2
@export var bet_pure_heavy_bonus: int = 2

const BET_COWARD: String = "COWARD"
const BET_PURE_BLOOD: String = "PURE_BLOOD"
const BET_DOUBLE_OR_DIE: String = "DOUBLE_OR_DIE"
const SCAR_OPEN_WOUND_HP_PENALTY: int = 20

var run: Dictionary = {
	"arena_index": 0,
	"coins": 0,
	"level": 1,
	"xp": 0,
	"upgrade_tokens": 0,
	"difficulty_tier": 0,
	"bet_hp_penalty": 0,
	"upgrade_costs": {
		"hp": 1,
		"light": 1,
		"heavy": 1,
	},
	"upgrades": {
		"hp_bonus": 0,
		"light_bonus": 0,
		"heavy_bonus": 0,
	},
}

var _arena: Node
var _arena_layout_container: Node2D = null
var _current_arena_layout: Node = null
var _current_arena_path: String = ""
var _waiting_for_bet: bool = false
var _waiting_for_push_luck: bool = false
var _waiting_for_intermediate_choice: bool = false
var _player: Node
var _run_failed_emitted: bool = false
var _run_ended_emitted: bool = false
var _is_game_over: bool = false
var _phase: RunPhase = RunPhase.NONE
var phase: RunPhase = RunPhase.PREP
var _pending_resolution_bet_id: StringName = &""
var _pending_push_luck_bet_id: StringName = &""
var _prep_sequence_id: int = 0
var _has_started_run: bool = false
var _boot_countdown_skipped: bool = false
var _modal_lock_count: int = 0
var _arena_suspended: bool = false
var _arena_visual_only: bool = false
var _resolving_arena: bool = false
var _resolving_ritual: bool = false
var _pact_sealed_sequence_id: int = 0
var _resolve_ritual_sequence_id: int = 0
var _resolve_ritual_reward_applied: bool = false
var _scars: Array[Dictionary] = []
var _run_state: RunState = RunState.new()
var _save_system: SaveSystem = SaveSystemScript.new()
var _register_state: RegisterState = RegisterState.new()
var _level3_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _boot_valid: bool = true
var _sanity_ui_root: Node = null
var _arena_themes: RefCounted = null
var _bet_system: RunBetSystem = BetSystemScript.new()
var _scar_system: RunScarSystem = ScarSystemScript.new()
var _scar_catalog: ScarCatalog = ScarCatalog.new()
var _outcome_system: RunOutcomeSystem = OutcomeSystemScript.new()

func _ready() -> void:
	print("RunManager ready")
	_arena_themes = ArenaThemes.new()
	add_to_group("run_manager")
	_apply_saved_language()
	if not _validate_game_events_signals():
		return
	_arena_layout_rng.randomize()
	_connect_gameevents()


func _connect_gameevents() -> void:
	var bet_placed_callable: Callable = Callable(self, "_on_bet_placed")
	if not GameEvents.bet_placed.is_connected(bet_placed_callable):
		GameEvents.bet_placed.connect(bet_placed_callable)
	var bet_sealed_callable: Callable = Callable(self, "_on_bet_sealed")
	if GameEvents.has_signal("bet_sealed") and not GameEvents.bet_sealed.is_connected(bet_sealed_callable):
		GameEvents.bet_sealed.connect(bet_sealed_callable)
	var bet_confirmed_callable: Callable = Callable(self, "_on_bet_confirmed")
	if GameEvents.has_signal("bet_confirmed") and not GameEvents.bet_confirmed.is_connected(bet_confirmed_callable):
		GameEvents.bet_confirmed.connect(bet_confirmed_callable)
	var request_place_bet_callable: Callable = Callable(self, "_on_request_place_bet")
	if GameEvents.has_signal("request_place_bet") and not GameEvents.request_place_bet.is_connected(request_place_bet_callable):
		GameEvents.request_place_bet.connect(request_place_bet_callable)
	var betting_opened_callable: Callable = Callable(self, "_on_betting_opened")
	if not GameEvents.betting_opened.is_connected(betting_opened_callable):
		GameEvents.betting_opened.connect(betting_opened_callable)
	var run_failed_callable: Callable = Callable(self, "_on_run_failed")
	if not GameEvents.run_failed.is_connected(run_failed_callable):
		GameEvents.run_failed.connect(run_failed_callable)
	var enemy_killed_callable: Callable = Callable(self, "_on_enemy_killed")
	if not GameEvents.enemy_killed.is_connected(enemy_killed_callable):
		GameEvents.enemy_killed.connect(enemy_killed_callable)
	var request_new_run_callable: Callable = Callable(self, "_on_request_new_run")
	if GameEvents.has_signal("request_new_run") and not GameEvents.request_new_run.is_connected(request_new_run_callable):
		GameEvents.request_new_run.connect(request_new_run_callable)
	var request_cashout_callable: Callable = Callable(self, "_on_request_push_luck_cashout")
	if GameEvents.has_signal("request_push_luck_cashout") and not GameEvents.request_push_luck_cashout.is_connected(request_cashout_callable):
		GameEvents.request_push_luck_cashout.connect(request_cashout_callable)
	var request_double_callable: Callable = Callable(self, "_on_request_push_luck_double")
	if GameEvents.has_signal("request_push_luck_double") and not GameEvents.request_push_luck_double.is_connected(request_double_callable):
		GameEvents.request_push_luck_double.connect(request_double_callable)
	var post_arena_callable: Callable = Callable(self, "_on_post_arena_choice_selected")
	if GameEvents.has_signal("post_arena_choice_selected") and not GameEvents.post_arena_choice_selected.is_connected(post_arena_callable):
		GameEvents.post_arena_choice_selected.connect(post_arena_callable)
	var request_intermediate_callable: Callable = Callable(self, "_on_request_intermediate_choice")
	if GameEvents.has_signal("request_intermediate_choice") and not GameEvents.request_intermediate_choice.is_connected(request_intermediate_callable):
		GameEvents.request_intermediate_choice.connect(request_intermediate_callable)
	var request_reset_callable: Callable = Callable(self, "_on_request_reset_run")
	if GameEvents.has_signal("request_reset_run") and not GameEvents.request_reset_run.is_connected(request_reset_callable):
		GameEvents.request_reset_run.connect(request_reset_callable)
	var request_retry_callable: Callable = Callable(self, "_on_request_retry_run")
	if GameEvents.has_signal("request_retry_run") and not GameEvents.request_retry_run.is_connected(request_retry_callable):
		GameEvents.request_retry_run.connect(request_retry_callable)
	var request_continue_callable: Callable = Callable(self, "_on_request_continue_run")
	if GameEvents.has_signal("request_continue_run") and not GameEvents.request_continue_run.is_connected(request_continue_callable):
		GameEvents.request_continue_run.connect(request_continue_callable)
	var request_show_menu_callable: Callable = Callable(self, "_on_request_show_main_menu")
	if GameEvents.has_signal("request_show_main_menu") and not GameEvents.request_show_main_menu.is_connected(request_show_menu_callable):
		GameEvents.request_show_main_menu.connect(request_show_menu_callable)
	var request_fail_run_callable: Callable = Callable(self, "_on_request_fail_run")
	if GameEvents.has_signal("request_fail_run") and not GameEvents.request_fail_run.is_connected(request_fail_run_callable):
		GameEvents.request_fail_run.connect(request_fail_run_callable)
	var request_seed_callable: Callable = Callable(self, "_on_request_set_run_seed")
	if GameEvents.has_signal("request_set_run_seed") and not GameEvents.request_set_run_seed.is_connected(request_seed_callable):
		GameEvents.request_set_run_seed.connect(request_seed_callable)
	var request_clear_seed_callable: Callable = Callable(self, "_on_request_clear_run_seed")
	if GameEvents.has_signal("request_clear_run_seed") and not GameEvents.request_clear_run_seed.is_connected(request_clear_seed_callable):
		GameEvents.request_clear_run_seed.connect(request_clear_seed_callable)
	var request_skip_callable: Callable = Callable(self, "_on_request_skip_arena_resolution")
	if GameEvents.has_signal("request_skip_arena_resolution") and not GameEvents.request_skip_arena_resolution.is_connected(request_skip_callable):
		GameEvents.request_skip_arena_resolution.connect(request_skip_callable)
	var modal_opened_callable: Callable = Callable(self, "_on_modal_opened")
	if GameEvents.has_signal("modal_opened") and not GameEvents.modal_opened.is_connected(modal_opened_callable):
		GameEvents.modal_opened.connect(modal_opened_callable)
	var modal_closed_callable: Callable = Callable(self, "_on_modal_closed")
	if GameEvents.has_signal("modal_closed") and not GameEvents.modal_closed.is_connected(modal_closed_callable):
		GameEvents.modal_closed.connect(modal_closed_callable)
	var settings_changed_callable: Callable = Callable(self, "_on_settings_changed")
	if GameEvents.has_signal("settings_changed") and not GameEvents.settings_changed.is_connected(settings_changed_callable):
		GameEvents.settings_changed.connect(settings_changed_callable)

func _apply_saved_language() -> void:
	var saved_language: String = SaveManager.get_language()
	_apply_language(saved_language)

func _apply_language(locale: String) -> void:
	var target_locale: String = locale.strip_edges().to_lower()
	if target_locale != "it" and target_locale != "en":
		target_locale = "it"
	TranslationServer.set_locale(target_locale)

func _on_settings_changed(payload: Dictionary) -> void:
	if payload.has("language"):
		_apply_language(str(payload.get("language", SaveManager.get_language())))
	_ensure_input_map()
	call_deferred("_boot")

func _boot() -> void:
	await get_tree().process_frame
	if not _boot_valid:
		return
	if not _validate_boot():
		return
	_connect_ui_queue_signals()
	if not LEVEL3_ENABLED:
		_ensure_arena_and_player()
		_arena = get_node_or_null(arena_path)
		_player = get_tree().get_first_node_in_group("player")
		_connect_player_signals()
	else:
		_arena = null
		_player = null
	if _arena:
		var wave_started_callable: Callable = Callable(self, "_on_wave_started")
		if _arena.has_signal("wave_started") and not _arena.wave_started.is_connected(wave_started_callable):
			_arena.wave_started.connect(wave_started_callable)
		var wave_cleared_callable: Callable = Callable(self, "_on_wave_cleared")
		if _arena.has_signal("wave_cleared") and not _arena.wave_cleared.is_connected(wave_cleared_callable):
			_arena.wave_cleared.connect(wave_cleared_callable)
		var player_spawned_callable: Callable = Callable(self, "_on_player_spawned")
		if _arena.has_signal("player_spawned") and not _arena.player_spawned.is_connected(player_spawned_callable):
			_arena.player_spawned.connect(player_spawned_callable)
	print("Boot: arena=", _arena, " player=", _player)
	print("Player in tree:", _player != null and _player.is_inside_tree())
	print("Starting new run")
	start_new_run()
	_log_runtime_state("boot_complete")

func _validate_game_events_signals() -> bool:
	var errors: Array[String] = []
	var ge: Node = get_node_or_null("/root/GameEvents") as Node
	if ge == null:
		var autoload_exists: bool = ProjectSettings.has_setting("autoload/GameEvents")
		var root_children: Array[Node] = get_tree().root.get_children()
		var root_names: PackedStringArray = PackedStringArray()
		for child: Node in root_children:
			root_names.append(child.name)
		push_warning("SANITY DIAG: autoload/GameEvents setting=%s" % str(autoload_exists))
		push_warning("SANITY DIAG: /root children=%s" % ", ".join(root_names))
		errors.append("GameEvents node missing at /root/GameEvents")
	else:
		var required_signals: Array[String] = [
			"bet_placed",
			"betting_opened",
			"run_failed",
			"enemy_killed",
			"run_started",
			"coins_changed",
			"resolve_ritual_opened",
			"resolve_ritual_closed",
			"push_luck_opened",
			"push_luck_closed",
			"run_finale_selected",
		]
		for signal_name: String in required_signals:
			if not ge.has_signal(signal_name):
				errors.append("GameEvents missing signal '%s'" % signal_name)
	if errors.size() > 0:
		_abort_sanity("SANITY FAIL: %s" % "; ".join(errors))
		return false
	return true

func _validate_boot() -> bool:
	var errors: Array[String] = []
	var ge: Node = get_node_or_null("/root/GameEvents") as Node
	if ge == null:
		errors.append("GameEvents node missing at /root/GameEvents")
	var run_managers: Array[Node] = get_tree().get_nodes_in_group("run_manager")
	if run_managers.size() != 1:
		errors.append("expected 1 run_manager, found %d" % run_managers.size())
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		errors.append("current scene is missing")
	else:
		var scene_path: String = current_scene.scene_file_path
		if scene_path != "" and scene_path != "res://scenes/Main.tscn":
			push_warning("SANITY WARN: entry scene is %s (expected res://scenes/Main.tscn)" % scene_path)
		_sanity_ui_root = current_scene.get_node_or_null("UI")
		if _sanity_ui_root == null:
			errors.append("UI root missing at path 'UI'")
		else:
			var required_ui_paths: Array[String] = [
				"Modals/BetModal",
				"Modals/ResolveRitualModal",
				"Modals/IntermediateChoiceModal",
				"Modals/PushLuckModal",
				"Modals/PushLuckModal/PushLuckPanel",
				"Modals/GameOverModal",
			]
			for ui_path: String in required_ui_paths:
				if _sanity_ui_root.get_node_or_null(ui_path) == null:
					errors.append("UI node missing at path '%s'" % ui_path)
	if errors.size() > 0:
		_abort_sanity("SANITY FAIL: %s" % "; ".join(errors))
		return false
	return true

func _connect_ui_queue_signals() -> void:
	if _sanity_ui_root == null:
		return
	if not _sanity_ui_root.has_signal("arena_message_queue_completed"):
		return
	var queue_callable: Callable = Callable(self, "_on_arena_message_queue_completed")
	if not _sanity_ui_root.is_connected("arena_message_queue_completed", queue_callable):
		_sanity_ui_root.connect("arena_message_queue_completed", queue_callable)

func _abort_sanity(message: String) -> void:
	push_error(message)
	_boot_valid = false
	get_tree().paused = true

func _refresh_sanity_ui_root() -> void:
	if _sanity_ui_root != null and is_instance_valid(_sanity_ui_root):
		return
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return
	var ui_root: Node = current_scene.get_node_or_null("UI")
	if ui_root == null:
		ui_root = get_node_or_null("/root/Main/UI")
	if ui_root != null:
		_sanity_ui_root = ui_root

func _ensure_flow_panel(path: String, context: String) -> bool:
	_refresh_sanity_ui_root()
	if _sanity_ui_root == null:
		_fail_flow("missing UI root during %s" % context)
		return false
	if _sanity_ui_root.get_node_or_null(path) == null:
		_fail_flow("missing UI panel at '%s' after %s" % [path, context])
		return false
	return true

func _fail_flow(message: String) -> void:
	push_error("SANITY FAIL FLOW: %s" % message)
	if _is_game_over:
		return
	_run_state.forced_ending_id = &"THE_FOOL"
	_enter_end_run("RUN_FAILED")

func request_new_game() -> void:
	if _resolving_arena or _waiting_for_bet or _waiting_for_push_luck or _waiting_for_intermediate_choice:
		print("RunManager: forcing new run while flow is active.")
	_start_new_run()

func request_confirm_pact() -> void:
	if not _waiting_for_bet or _phase != RunPhase.BET_PRESENT:
		push_error("RunManager: request_confirm_pact in wrong phase %s" % [str(_phase)])
		return
	var pending_bet_id: StringName = _run_state.last_selected_bet_id
	if pending_bet_id == &"":
		push_error("RunManager: request_confirm_pact has no selected pact to confirm")
		return
	_confirm_pact_with_bet_id(pending_bet_id)

func request_choose_mid(index: int) -> void:
	if not _waiting_for_intermediate_choice or _phase != RunPhase.INTERMEDIATE_CHOICE:
		push_error("RunManager: request_choose_mid in wrong phase %s" % [str(_phase)])
		return
	if index == 0:
		_apply_intermediate_choice("placa")
		return
	if index == 1:
		_apply_intermediate_choice("provoca")
		return
	push_error("RunManager: request_choose_mid invalid index %d" % index)

func request_push_your_luck() -> void:
	if not _waiting_for_push_luck or _phase != RunPhase.PUSH_YOUR_LUCK:
		push_error("RunManager: request_push_your_luck in wrong phase %s" % [str(_phase)])
		return
	_push_your_luck()

func request_take_payout() -> void:
	if not _waiting_for_push_luck or _phase != RunPhase.PUSH_YOUR_LUCK:
		push_error("RunManager: request_take_payout in wrong phase %s" % [str(_phase)])
		return
	_take_payout()

func request_quit_to_menu() -> void:
	_set_phase(RunPhase.MAIN_MENU, "request_show_main_menu")
	set_phase(RunPhase.MAIN_MENU)

func request_load_continue() -> void:
	if _phase != RunPhase.MAIN_MENU and _phase != RunPhase.NONE:
		push_error("RunManager: request_load_continue in wrong phase %s" % [str(_phase)])
		return
	var payload: Dictionary = _save_system.load_run_payload()
	if payload.is_empty():
		return
	if not _apply_run_save_payload(payload):
		_save_system.clear_run()
		return
	_resume_run_from_save(_run_state.run_save_flow_step, _run_state.run_save_flow_bet_id)

func start_new_run() -> void:
	request_new_game()

func _start_new_run() -> void:
	_run_state.run_start_time_msec = Time.get_ticks_msec()
	_set_phase(RunPhase.RUN_INIT, "start_new_run")
	if LEVEL3_ENABLED:
		_start_level3_run()
		return
	_run_state.seen_by_crowd_before_run = SaveManager.has_unlocked(CONDANNA_VISTO_DAL_PUBBLICO)
	if SaveManager.has_unlocked(CONDANNA_E_FINITA_COSI):
		_register_condanna(CONDANNA_NON_SARA_L_ULTIMA)
	get_tree().paused = false
	Engine.time_scale = 1.0
	if GameEvents != null and GameEvents.has_method("set_gameplay_enabled"):
		GameEvents.set_gameplay_enabled(true)
	_prep_sequence_id += 1
	var current_id: int = _prep_sequence_id
	_run_failed_emitted = false
	_run_ended_emitted = false
	_run_state.registry_silence_evaluated = false
	_run_state.registry_silence_active = false
	_is_game_over = false
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_waiting_for_intermediate_choice = false
	_run_state.push_luck_cashouts = 0
	_run_state.push_luck_doubles = 0
	_run_state.max_push_luck_chain = 1
	_run_state.post_bet_pending_bet_id = &""
	_run_state.post_bet_sequence_id = 0
	_run_state.intermediate_pending_bet_id = &""
	_run_state.intermediate_double_disabled_once = false
	_run_state.intermediate_bonus_tier = 0
	_run_state.intermediate_choice_note = ""
	_run_state.intermediate_loss_penalty_pending = false
	_run_state.provoke_armed = false
	_run_state.failed_high_risk_bets = 0
	_run_state.run_end_reason = ""
	_run_state.run_end_public_reason = ""
	_run_state.run_finale_emitted = false
	_run_state.condanne_this_run = []
	_run_state.last_audience_context_line = ""
	_register_state = RegisterState.new()
	_resolving_arena = false
	_resolving_ritual = false
	_pact_sealed_sequence_id = 0
	_resolve_ritual_sequence_id = 0
	_resolve_ritual_reward_applied = false
	_reset_bet_chain()
	_reset_scars()
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()

	_ensure_arena_and_player()
	if _arena != null and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_reset_or_respawn_player_full()
	_clear_enemies()

	run["coins"] = starting_coins
	run["bet_hp_penalty"] = 0
	_reset_upgrades()
	_reset_upgrade_costs()
	_has_started_run = true
	run["arena_index"] = 0

	_reset_progression()

	GameEvents.run_started.emit()
	GameEvents.set_gameplay_enabled(true)
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))
	_emit_xp_level_ui()
	if not _boot_countdown_skipped:
		_boot_countdown_skipped = true
	else:
		GameEvents.countdown_requested.emit(3)
		_log_runtime_state("new_run_ready")
		for _i in range(3, 0, -1):
			await get_tree().create_timer(1.0).timeout
			if current_id != _prep_sequence_id or phase == RunPhase.GAME_OVER:
				return
		if current_id != _prep_sequence_id or phase == RunPhase.GAME_OVER:
			return
	var live_player: Node = _resolve_player()
	if live_player == null or not live_player.is_inside_tree():
		_ensure_arena_and_player()
		_reset_or_respawn_player_full()
		live_player = _resolve_player()
		if live_player == null or not live_player.is_inside_tree():
			return
	set_phase(RunPhase.PREP)
	_open_bet_ui(false)
	_log_runtime_state("waiting_for_bet")

func start_run() -> void:
	request_new_game()

func _start_level3_run() -> void:
	_run_state.run_start_time_msec = Time.get_ticks_msec()
	_set_phase(RunPhase.RUN_INIT, "start_level3_run")
	_run_state.seen_by_crowd_before_run = SaveManager.has_unlocked(CONDANNA_VISTO_DAL_PUBBLICO)
	if SaveManager.has_unlocked(CONDANNA_E_FINITA_COSI):
		_register_condanna(CONDANNA_NON_SARA_L_ULTIMA)
	get_tree().paused = false
	Engine.time_scale = 1.0
	_run_failed_emitted = false
	_run_ended_emitted = false
	_run_state.registry_silence_evaluated = false
	_run_state.registry_silence_active = false
	_is_game_over = false
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_run_state.run_end_reason = ""
	_run_state.run_end_public_reason = ""
	_run_state.run_finale_emitted = false
	_run_state.condanne_this_run = []
	_run_state.last_audience_context_line = ""
	_register_state = RegisterState.new()
	_resolving_arena = false
	_pact_sealed_sequence_id = 0
	_run_state.forced_ending_id = &""
	_run_state.forced_next_pact_archetype = &""
	_run_state.level3_reward_tier = 1
	_run_state.level3_next_loss_hp_penalty = 0
	_run_state.level3_target_arenas = 0
	_run_state.cashout_lock_remaining = 0
	_run_state.last_selected_bet_id = &""
	_run_state.last_bet_offers = []
	_run_state.last_enemy_profile = &""
	_run_state.level3_current_offer = []
	_run_state.special_arena_index = 0
	_run_state.special_arena_id = &""
	_run_state.special_arena_active = false
	_run_state.special_arena_effect_applied = false
	_run_state.special_arena_cashout_lock_reason = ""
	_run_state.level3_cashouts = 0
	_run_state.level3_doubles = 0
	_run_state.level3_bets_used = []
	_run_state.level3_max_escalation = 0
	_run_state.level3_cashout_streak = 0
	_run_state.level3_cashout_streak_max = 0
	_run_state.level3_cashed_after_high_escalation = false
	_run_state.current_bet_id = ""
	_run_state.bet_chain_level = 1
	_has_started_run = true
	_run_state.provoke_armed = false

	_run_state = RunState.new()
	_run_state.reset()
	_run_state.run_seed = _get_run_seed_value()
	_run_state.arena_index = 0
	_flow_log("run_started", "arena=%d, bet_id=, save_present=%s" % [_run_state.arena_index, str(_save_system.has_run_save())])
	_run_state.escalation_level = 0
	_run_state.active_bet_id = &""
	_run_state.enemy_profile = &""
	_run_state.enemy_profiles = []
	_run_state.scars = []
	_run_state.scars_history = []
	_run_state.bets_history = []
	_run_state.pacts_log = []
	_run_state.cashouts = 0
	_run_state.doubles = 0
	_run_state.max_escalation = 0
	_run_state.arenas_cleared = 0
	_run_state.max_hp_modifier = 0
	_run_state.audience_score = 0
	_run_state.refuse_cashout_count_this_run = 0
	_run_state.last_action_was_rilancio = false
	_run_state.run_is_over = false
	_run_state.is_hunted_by_crowd = false
	_run_state.risky_choice_made_recently = false
	_run_state.irreversible_bet_scar_registered = false
	_run_state.refused_closure_scar_registered = false
	_run_state.risk_threshold_scar_registered = false
	_run_state.last_scar_arena_index = -1000
	_emit_escalation_changed()
	_arena_layout_rng.seed = _run_state.run_seed
	_level3_rng.seed = _run_state.run_seed
	_run_state.level3_target_arenas = _level3_rng.randi_range(5, 8)
	_run_state.level3_min_cashout_arenas = 5
	_run_state.special_arena_index = _pick_special_arena_index(_run_state.level3_target_arenas)

	_reset_scars()
	run["coins"] = starting_coins
	run["arena_index"] = 0
	_reset_upgrades()
	_reset_upgrade_costs()

	GameEvents.run_started.emit()
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()
	_emit_run_debug_state()
	start_arena()
	if not _waiting_for_bet:
		_open_level3_bet_ui()

func start_arena() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_clear_enemies()
	if not LEVEL3_ENABLED:
		_ensure_arena_and_player()
	_run_state.arena_index = maxi(_run_state.arena_index + 1, 1)
	run["arena_index"] = _run_state.arena_index
	_emit_arena_theme_changed()
	_maybe_activate_special_arena()
	_select_enemy_profile()
	if _run_state.enemy_profile != &"":
		_run_state.enemy_profiles.append(_run_state.enemy_profile)
	if not LEVEL3_ENABLED:
		load_next_arena()
	_emit_run_debug_state()
	_open_level3_bet_ui()

func select_bet(bet_id: StringName) -> void:
	if not _waiting_for_bet or _phase != RunPhase.BET_PRESENT:
		push_error("RunManager: select_bet in wrong phase %s" % [str(_phase)])
		return
	_confirm_pact_with_bet_id(bet_id)

func _confirm_pact_with_bet_id(bet_id: StringName) -> void:
	if not _waiting_for_bet:
		return
	if _run_state.run_is_over or _is_game_over:
		return
	_set_phase(RunPhase.BET_COMMITTED, "select_bet")
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_update_arena_visual_only()
	_run_state.active_bet_id = bet_id
	if bet_id != &"":
		_run_state.bets_history.append(bet_id)
		_append_pact_log_entry(bet_id, _get_level3_bet_name(bet_id))
		_run_state.last_signed_pact_id = bet_id
		var bet_data: Dictionary = _get_bet_data(String(bet_id))
		var archetype: StringName = StringName(str(bet_data.get("archetype", "")))
		if archetype == ARCH_EGO or archetype == ARCH_TIME:
			_run_state.risky_choice_made_recently = true
		_register_condanna(CONDANNA_FIRMATO)
		_register_condanna(CONDANNA_FIRMATO)
		_register_condanna(CONDANNA_FIRMATO)
	_run_state.current_bet_id = String(bet_id)
	_run_state.last_selected_bet_id = bet_id
	_run_state.level3_bets_used.append(bet_id)
	_run_state.level3_current_offer = []
	if bet_id == BET_CASH_OUT:
		_run_state.level3_cashout_streak += 1
		_run_state.level3_cashout_streak_max = maxi(_run_state.level3_cashout_streak_max, _run_state.level3_cashout_streak)
	else:
		_run_state.level3_cashout_streak = 0
	_emit_run_debug_state()
	GameEvents.bet_placed.emit(String(bet_id), 0, 1.0)
	GameEvents.bet_ui_closed.emit()
	GameEvents.bet_closed.emit()
	GameEvents.betting_closed.emit()
	_autosave_run_checkpoint(RUN_FLOW_BET_SIGNED, bet_id)
	resolve_arena()

func _register_level3_bet_choice(bet_id: StringName) -> void:
	_update_arena_visual_only()
	_set_phase(RunPhase.BET_COMMITTED, "register_level3_bet_choice")
	_run_state.active_bet_id = bet_id
	if bet_id != &"":
		_run_state.bets_history.append(bet_id)
		_append_pact_log_entry(bet_id, _get_level3_bet_name(bet_id))
		_run_state.last_signed_pact_id = bet_id
		var bet_data: Dictionary = _get_bet_data(String(bet_id))
		var archetype: StringName = StringName(str(bet_data.get("archetype", "")))
		if archetype == ARCH_EGO or archetype == ARCH_TIME:
			_run_state.risky_choice_made_recently = true
		_register_condanna(CONDANNA_FIRMATO)
	_run_state.current_bet_id = String(bet_id)
	_run_state.last_selected_bet_id = bet_id
	_run_state.level3_bets_used.append(bet_id)
	_run_state.level3_current_offer = []
	if bet_id == BET_CASH_OUT:
		_run_state.level3_cashout_streak += 1
		_run_state.level3_cashout_streak_max = maxi(_run_state.level3_cashout_streak_max, _run_state.level3_cashout_streak)
	else:
		_run_state.level3_cashout_streak = 0
	_emit_run_debug_state()
	GameEvents.bet_placed.emit(String(bet_id), 0, 1.0)
	GameEvents.bet_ui_closed.emit()
	GameEvents.bet_closed.emit()

func _start_pact_sealed_ritual(bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_pact_sealed_sequence_id += 1
	var sequence_id: int = _pact_sealed_sequence_id
	_close_audience_context_line()
	_flow_log("pact_sealed_opened", "arena=%d, bet_id=%s" % [_run_state.arena_index, String(bet_id)])
	GameEvents.pact_sealed_opened.emit()
	await get_tree().create_timer(PACT_SEALED_SECONDS).timeout
	if sequence_id != _pact_sealed_sequence_id:
		return
	GameEvents.pact_sealed_closed.emit()
	if _run_state.run_is_over or _is_game_over:
		return
	_start_resolve_ritual(bet_id)

func _start_resolve_ritual(bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	if not _ensure_flow_panel("Modals/ResolveRitualModal", "resolve ritual"):
		return
	_resolving_ritual = true
	_resolve_ritual_sequence_id += 1
	var sequence_id: int = _resolve_ritual_sequence_id
	var payload: Dictionary = {
		"bet_id": String(bet_id),
		"bet_name": _get_level3_bet_name(bet_id),
		"doom_short": _get_level3_doom_short(bet_id),
	}
	_flow_log("resolve_ritual_opened", "arena=%d, bet_id=%s" % [_run_state.arena_index, String(bet_id)])
	GameEvents.resolve_ritual_opened.emit(payload)
	await get_tree().create_timer(RESOLVE_RITUAL_SECONDS).timeout
	if sequence_id != _resolve_ritual_sequence_id:
		return
	GameEvents.resolve_ritual_closed.emit()
	_flow_log("resolve_ritual_closed", "arena=%d, bet_id=%s" % [_run_state.arena_index, String(bet_id)])
	_resolving_ritual = false
	if _run_state.run_is_over or _is_game_over:
		return
	_resolve_ritual_outcome(bet_id)

func _resolve_ritual_outcome(bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_resolving_arena = true
	_update_arena_visual_only()
	set_phase(RunPhase.LIVE)
	GameEvents.arena_started.emit(_run_state.arena_index)
	_play_arena_resolution_fx()
	_apply_special_arena_pre_resolution()
	var result: ArenaResult = _resolve_level3_arena()
	_update_audience_after_arena(result)
	_run_state.arenas_cleared = maxi(_run_state.arenas_cleared + 1, 1)
	GameEvents.arena_completed.emit(_run_state.arena_index)
	var failed: bool = not result.won
	var scars_applied: Array[StringName] = []
	if bet_id == BET_FLAWLESS_BLOOD and result.took_damage:
		failed = true
	if failed:
		_apply_intermediate_loss_penalty_if_needed()
		scars_applied = _handle_level3_loss_ritual(bet_id, result)
	else:
		_run_state.last_action_was_rilancio = false
		_run_state.risky_choice_made_recently = false
		_apply_level3_reward(bet_id, _run_state.level3_reward_tier)
		_resolve_ritual_reward_applied = true
		var player: Node = _resolve_player()
		var current_hp: int = -1
		var max_hp: int = -1
		if player != null:
			current_hp = _get_player_health_value(player)
			max_hp = _get_player_max_health_value(player)
		var hp_available: bool = current_hp >= 0 and max_hp > 0
		if hp_available:
			if current_hp == 1 or float(current_hp) / float(max_hp) <= 0.10:
				_register_condanna(CONDANNA_NON_OGGI)
		else:
			var bet_data: Dictionary = _get_bet_data(String(bet_id))
			var archetype: StringName = StringName(str(bet_data.get("archetype", "")))
			if bet_id == BET_LAST_BREATH or archetype == ARCH_TIME:
				_register_condanna(CONDANNA_NON_OGGI)
	_update_last_pact_outcome(bet_id, not failed)
	_apply_special_arena_post_resolution(result, failed)
	_log_level3_arena_result(bet_id, result, scars_applied)
	_run_state.active_bet_id = &""
	_resolving_arena = false
	_update_arena_visual_only()
	_emit_run_debug_state()
	if _run_state.run_is_over or _is_game_over:
		return
	# FLOW ANCHOR hookup: see POST-BET SEQUENCE section.
	_queue_push_luck_choice(bet_id)
	_autosave_run_checkpoint(RUN_FLOW_INTERMEDIATE_CHOICE, bet_id)

func resolve_arena() -> void:
	_pending_resolution_bet_id = _run_state.active_bet_id
	_set_phase(RunPhase.RESOLUTION, "resolve_arena")

func _enter_resolution() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_emit_ui(_build_phase_ui_payload(RunPhase.RESOLUTION, "RISOLUZIONE", "L'arena decide il prezzo del patto."))
	_resolving_arena = true
	_update_arena_visual_only()
	set_phase(RunPhase.LIVE)
	var bet_id: StringName = _pending_resolution_bet_id
	if bet_id == &"":
		bet_id = _run_state.active_bet_id
	_pending_resolution_bet_id = &""
	_emit_sentence_banner_for_bet(bet_id)
	GameEvents.arena_started.emit(_run_state.arena_index)
	_play_arena_resolution_fx()
	_apply_special_arena_pre_resolution()
	var result: ArenaResult = _resolve_level3_arena()
	_update_audience_after_arena(result)
	_run_state.arenas_cleared = maxi(_run_state.arenas_cleared + 1, 1)
	GameEvents.arena_completed.emit(_run_state.arena_index)
	var failed: bool = not result.won
	var scars_applied: Array[StringName] = []
	if bet_id == BET_FLAWLESS_BLOOD and result.took_damage:
		failed = true
	if failed:
		_apply_intermediate_loss_penalty_if_needed()
		scars_applied = _handle_level3_loss(bet_id, result)
	else:
		_handle_level3_win(bet_id, result)
		var player: Node = _resolve_player()
		var current_hp: int = -1
		var max_hp: int = -1
		if player != null:
			current_hp = _get_player_health_value(player)
			max_hp = _get_player_max_health_value(player)
		var hp_available: bool = current_hp >= 0 and max_hp > 0
		if hp_available:
			if current_hp == 1 or float(current_hp) / float(max_hp) <= 0.10:
				_register_condanna(CONDANNA_NON_OGGI)
		else:
			var bet_data: Dictionary = _get_bet_data(String(bet_id))
			var archetype: StringName = StringName(str(bet_data.get("archetype", "")))
			if bet_id == BET_LAST_BREATH or archetype == ARCH_TIME:
				_register_condanna(CONDANNA_NON_OGGI)
	_update_last_pact_outcome(bet_id, not failed)
	_apply_special_arena_post_resolution(result, failed)
	_log_level3_arena_result(bet_id, result, scars_applied)
	_run_state.active_bet_id = &""
	_resolving_arena = false
	_update_arena_visual_only()
	_emit_run_debug_state()
	if _run_state.run_is_over or _is_game_over:
		return
	_queue_push_luck_choice(bet_id)
	_autosave_run_checkpoint(RUN_FLOW_INTERMEDIATE_CHOICE, bet_id)

func apply_scar(scar_id: StringName) -> void:
	_apply_level3_scar(scar_id, "")

func _play_arena_resolution_fx() -> void:
	if _arena == null or not is_instance_valid(_arena):
		_arena = get_node_or_null(arena_path)
	if _arena == null or not (_arena is CanvasItem):
		return
	var canvas: CanvasItem = _arena as CanvasItem
	var base_color: Color = canvas.modulate
	var flash_color: Color = Color(
		minf(base_color.r + 0.2, 1.0),
		minf(base_color.g + 0.2, 1.0),
		minf(base_color.b + 0.2, 1.0),
		base_color.a
	)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(canvas, "modulate", flash_color, 0.12)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(canvas, "modulate", base_color, 0.18)

func end_run(ending_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_run_state.forced_ending_id = ending_id
	_run_state.run_is_over = true
	_update_arena_visual_only()
	_register_run_end(String(ending_id))
	_enter_end_run("")

func start_next_bet_round() -> void:
	if LEVEL3_ENABLED:
		start_arena()
		return
	if _is_game_over:
		return
	if _force_game_over_if_dead():
		return
	if _waiting_for_push_luck:
		return
	_set_phase(RunPhase.NEXT_BET, "start_next_bet_round")
	_waiting_for_bet = false
	set_phase(RunPhase.LIVE)
	_clear_enemies()
	_spawn_wave_or_enemies()

func reset_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	run["coins"] = starting_coins
	start_new_run()

func restart_run(preserve_coins: bool = true) -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	if preserve_coins:
		start_new_run()
	else:
		run["coins"] = starting_coins
		start_new_run()

func _open_bet_ui(from_victory: bool = false) -> void:
	if LEVEL3_ENABLED:
		_open_level3_bet_ui()
		return
	if _force_game_over_if_dead():
		return
	if _is_game_over:
		return
	_set_phase(RunPhase.BET_PRESENT, "open_bet_ui")
	_waiting_for_bet = true
	_waiting_for_push_luck = false
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()
	GameEvents.betting_opened.emit()

func _open_level3_bet_ui() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_set_phase(RunPhase.BET_PRESENT, "open_level3_bet_ui")
	_waiting_for_bet = true
	_waiting_for_push_luck = false
	_resolve_ritual_reward_applied = false
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()
	GameEvents.betting_opened.emit()
	var offer: Array[Dictionary] = _build_level3_bet_offer()
	_run_state.level3_current_offer = offer.duplicate(true)
	_flow_log("bet_ui_opened", "arena=%d, bet_id=" % _run_state.arena_index)
	GameEvents.bet_ui_opened.emit(offer)
	GameEvents.bet_opened.emit()

func _build_level3_bet_offer() -> Array[Dictionary]:
	var available: Array[Dictionary] = _get_available_level3_bets()
	var desired_count: int = 4
	var filtered: Array[Dictionary] = _filter_recent_bets(available, desired_count)
	_level3_rng.seed = _compute_level3_offer_seed()
	var picks: Array[Dictionary] = _pick_weighted_bets(filtered, desired_count)
	_run_state.last_bet_offers = []
	for bet_value: Dictionary in picks:
		var bet_id: StringName = StringName(str(bet_value.get("id", "")))
		if bet_id != &"":
			_run_state.last_bet_offers.append(bet_id)
	if _run_state.forced_next_pact_archetype != &"":
		_run_state.forced_next_pact_archetype = &""
	return picks

func _get_available_level3_bets() -> Array[Dictionary]:
	var available: Array[Dictionary] = []
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if _is_level3_bet_allowed(bet):
			if _run_state.forced_next_pact_archetype != &"":
				var archetype: StringName = StringName(str(bet.get("archetype", "")))
				if archetype != _run_state.forced_next_pact_archetype:
					continue
			available.append(bet)
	if available.is_empty():
		if _run_state.forced_next_pact_archetype != &"":
			_run_state.forced_next_pact_archetype = &""
			for bet_value: Dictionary in LEVEL3_BETS:
				var bet: Dictionary = bet_value as Dictionary
				if _is_level3_bet_allowed(bet):
					available.append(bet)
			if available.is_empty():
				return LEVEL3_BETS.duplicate()
			return available
		return LEVEL3_BETS.duplicate()
	return available

func _is_level3_bet_unlocked(bet_id: StringName) -> bool:
	if LEVEL3_PACT_UNLOCKS.has(bet_id):
		var unlock_id: StringName = StringName(str(LEVEL3_PACT_UNLOCKS.get(bet_id, "")))
		if unlock_id != &"" and not _is_unlocked(unlock_id):
			return false
	return true

func _is_level3_bet_allowed(bet: Dictionary) -> bool:
	var bet_id: StringName = StringName(str(bet.get("id", "")))
	if bet_id == &"":
		return false
	if bet_id == BET_DOUBLE_OR_DIE_L3 and _run_state.last_selected_bet_id == BET_DOUBLE_OR_DIE_L3:
		return false
	if not _is_level3_bet_unlocked(bet_id):
		return false
	var blocked_scars: Array = bet.get("blocked_scars", []) as Array
	for scar_value in blocked_scars:
		if _has_scar(StringName(scar_value)):
			return false
	var required_scars: Array = bet.get("requires_scars", []) as Array
	for scar_value in required_scars:
		if not _has_scar(StringName(scar_value)):
			return false
	return true

func _filter_recent_bets(bets: Array[Dictionary], desired_count: int) -> Array[Dictionary]:
	if bets.size() <= desired_count:
		return bets
	if _run_state.last_bet_offers.is_empty():
		return bets
	var filtered: Array[Dictionary] = []
	for bet_value: Dictionary in bets:
		var bet_id: StringName = StringName(str(bet_value.get("id", "")))
		if bet_id == &"":
			continue
		if bet_id == _run_state.last_selected_bet_id:
			continue
		if _run_state.last_bet_offers.has(bet_id):
			continue
		filtered.append(bet_value)
	if filtered.size() < desired_count:
		return bets
	return filtered

func _pick_weighted_bets(bets: Array[Dictionary], desired_count: int) -> Array[Dictionary]:
	var picks: Array[Dictionary] = []
	if bets.is_empty():
		return picks
	var pool: Array[Dictionary] = bets.duplicate()
	var count: int = mini(desired_count, pool.size())
	for _i in range(count):
		var idx: int = _weighted_pick_index(pool)
		if idx < 0 or idx >= pool.size():
			break
		picks.append(pool[idx])
		pool.remove_at(idx)
	return picks

func _weighted_pick_index(pool: Array[Dictionary]) -> int:
	var total_weight: int = 0
	for bet_value: Dictionary in pool:
		var weight: int = int(bet_value.get("weight", 1))
		weight = maxi(weight, 0)
		total_weight += weight
	if total_weight <= 0:
		return 0
	var roll: int = _level3_rng.randi_range(1, total_weight)
	var running: int = 0
	for idx in range(pool.size()):
		var weight: int = int(pool[idx].get("weight", 1))
		weight = maxi(weight, 0)
		running += weight
		if roll <= running:
			return idx
	return maxi(pool.size() - 1, 0)

func _get_run_seed_value() -> int:
	if _run_state.debug_seed_override_active:
		return _run_state.debug_seed_override
	return int(Time.get_unix_time_from_system())

func _compute_level3_seed(bet_id: StringName) -> int:
	var seed_value: int = _run_state.run_seed
	seed_value += _run_state.arena_index * 31
	seed_value += _run_state.escalation_level * 13
	seed_value += String(bet_id).hash() * 7
	var scars_hash: int = 0
	for scar_name: StringName in _run_state.scars_history:
		scars_hash += String(scar_name).hash() * 3
	seed_value += scars_hash
	seed_value += String(_run_state.enemy_profile).hash() * 5
	return seed_value

func _compute_level3_offer_seed() -> int:
	var seed_value: int = _run_state.run_seed
	seed_value += _run_state.arena_index * 43
	seed_value += _run_state.escalation_level * 17
	seed_value += _run_state.scars_history.size() * 11
	seed_value += String(_run_state.last_selected_bet_id).hash() * 5
	return seed_value

func _emit_run_debug_state() -> void:
	if not GameEvents.has_signal("run_debug_state_updated"):
		return
	var scars_copy: Array[String] = _serialize_stringname_array(_run_state.scars_history)
	var payload: Dictionary = {
		"seed": _run_state.run_seed,
		"arena_index": _run_state.arena_index,
		"escalation_level": _run_state.escalation_level,
		"active_bet_id": String(_run_state.active_bet_id),
		"enemy_profile": String(_run_state.enemy_profile),
		"scars": scars_copy,
		"special_arena_id": String(_run_state.special_arena_id),
		"special_arena_active": _run_state.special_arena_active,
		"is_hunted_by_crowd": _run_state.is_hunted_by_crowd,
	}
	GameEvents.run_debug_state_updated.emit(payload)

func _autosave_run_checkpoint(flow_step: StringName, bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_run_state.run_save_flow_step = flow_step
	_run_state.run_save_flow_bet_id = bet_id
	_save_system.save_run_payload(_build_run_save_payload())

func _build_run_save_payload() -> Dictionary:
	var upgrade_costs: Dictionary = {}
	if run.has("upgrade_costs") and run["upgrade_costs"] is Dictionary:
		upgrade_costs = (run["upgrade_costs"] as Dictionary).duplicate(true)
	var upgrades: Dictionary = {}
	if run.has("upgrades") and run["upgrades"] is Dictionary:
		upgrades = (run["upgrades"] as Dictionary).duplicate(true)
	var run_payload: Dictionary = {
		"arena_index": int(run.get("arena_index", 0)),
		"coins": int(run.get("coins", 0)),
		"level": int(run.get("level", 1)),
		"xp": int(run.get("xp", 0)),
		"upgrade_tokens": int(run.get("upgrade_tokens", 0)),
		"difficulty_tier": int(run.get("difficulty_tier", 0)),
		"bet_hp_penalty": int(run.get("bet_hp_penalty", 0)),
		"upgrade_costs": upgrade_costs,
		"upgrades": upgrades,
	}
	var run_state_payload: Dictionary = _run_state.to_dict()
	run_state_payload["scars"] = _serialize_run_scars(_run_state.scars)
	var pacts_log: Array[Dictionary] = []
	for entry: PactLogEntry in _run_state.pacts_log:
		pacts_log.append(entry.to_dict())
	run_state_payload["pacts_log"] = pacts_log
	return {
		"schema_version": RUN_SAVE_SCHEMA_VERSION,
		"run": run_payload,
		"run_state": run_state_payload,
		"scars_detail": _serialize_scars_detail(),
	}

func _apply_run_save_payload(payload: Dictionary) -> bool:
	if not payload.has("schema_version"):
		return false
	if typeof(payload.get("schema_version")) != TYPE_INT:
		return false
	var schema_version: int = int(payload.get("schema_version", 0))
	if schema_version != RUN_SAVE_SCHEMA_VERSION:
		return false
	if not payload.has("run") or not (payload["run"] is Dictionary):
		return false
	if not payload.has("run_state") or not (payload["run_state"] is Dictionary):
		return false
	_pact_sealed_sequence_id += 1
	_resolve_ritual_sequence_id += 1
	_resolving_ritual = false
	_resolving_arena = false
	_run_failed_emitted = false
	_run_ended_emitted = false
	_run_state.run_finale_emitted = false
	_run_state.run_end_reason = ""
	_run_state.run_end_public_reason = ""
	_is_game_over = false
	_has_started_run = true
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_waiting_for_intermediate_choice = false
	_run_state.intermediate_pending_bet_id = &""
	_run_state.post_bet_pending_bet_id = &""

	var run_state_data: Dictionary = payload["run_state"] as Dictionary
	_run_state = RunState.new()
	_run_state.reset()
	_run_state.from_dict(run_state_data)
	if _run_state.run_save_flow_step == &"":
		_run_state.run_save_flow_step = RUN_FLOW_BET_OFFER
	if _run_state.run_seed <= 0:
		return false
	if _run_state.run_is_over:
		return false
	_run_state.scars = _parse_run_scars(run_state_data.get("scars", []) as Array)
	_run_state.pacts_log = _parse_pacts_log(run_state_data.get("pacts_log", []))

	var run_data: Dictionary = payload["run"] as Dictionary
	run["arena_index"] = int(run_data.get("arena_index", _run_state.arena_index))
	run["coins"] = int(run_data.get("coins", starting_coins))
	run["level"] = int(run_data.get("level", 1))
	run["xp"] = int(run_data.get("xp", 0))
	run["upgrade_tokens"] = int(run_data.get("upgrade_tokens", 0))
	run["difficulty_tier"] = int(run_data.get("difficulty_tier", 0))
	run["bet_hp_penalty"] = int(run_data.get("bet_hp_penalty", 0))
	if run_data.has("upgrade_costs") and run_data["upgrade_costs"] is Dictionary:
		run["upgrade_costs"] = (run_data["upgrade_costs"] as Dictionary).duplicate(true)
	if run_data.has("upgrades") and run_data["upgrades"] is Dictionary:
		run["upgrades"] = (run_data["upgrades"] as Dictionary).duplicate(true)

	if _run_state.level3_target_arenas <= 0:
		_level3_rng.seed = _run_state.run_seed
		_run_state.level3_target_arenas = _level3_rng.randi_range(5, 8)
	if _run_state.special_arena_index <= 0 and _run_state.level3_target_arenas > 0:
		_run_state.special_arena_index = _pick_special_arena_index(_run_state.level3_target_arenas)

	if payload.has("scars_detail") and payload["scars_detail"] is Array:
		_apply_scars_detail(payload["scars_detail"] as Array)
	else:
		_emit_scars_updated()

	_level3_rng.seed = _run_state.run_seed
	GameEvents.set_gameplay_enabled(true)
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	_emit_escalation_changed()
	_emit_run_debug_state()
	_update_arena_visual_only()
	return true

func _resume_run_from_save(flow_step: StringName, bet_id: StringName) -> void:
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_waiting_for_intermediate_choice = false
	_run_state.intermediate_pending_bet_id = &""
	_run_state.post_bet_pending_bet_id = &""
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()
	var resolved_bet: StringName = bet_id
	if resolved_bet == &"" and _run_state.current_bet_id != "":
		resolved_bet = StringName(_run_state.current_bet_id)
	if flow_step == RUN_FLOW_BET_SIGNED and resolved_bet != &"":
		_start_pact_sealed_ritual(resolved_bet)
		return
	if flow_step == RUN_FLOW_INTERMEDIATE_CHOICE and resolved_bet != &"":
		_open_intermediate_choice(resolved_bet)
		return
	if flow_step == RUN_FLOW_PUSH_LUCK and resolved_bet != &"":
		_open_push_luck_choice(resolved_bet)
		return
	if LEVEL3_ENABLED:
		_open_level3_bet_ui()
	else:
		_open_bet_ui(false)

func _serialize_stringname_array(items: Array) -> Array[String]:
	var values: Array[String] = []
	for item in items:
		var text: String = str(item)
		if text == "":
			continue
		values.append(text)
	return values

func _serialize_run_scars(items: Array[Scar]) -> Array[Dictionary]:
	var values: Array[Dictionary] = []
	for item: Scar in items:
		values.append(item.to_dict())
	return values

func _parse_stringname_array(items: Array) -> Array[StringName]:
	var values: Array[StringName] = []
	for item in items:
		var text: String = str(item)
		if text == "":
			continue
		values.append(StringName(text))
	return values

func _parse_run_scars(items: Array) -> Array[Scar]:
	var values: Array[Scar] = []
	for item in items:
		if item is Dictionary:
			values.append(Scar.from_dict(item as Dictionary))
		elif str(item) != "":
			var legacy: Scar = Scar.new()
			legacy.id = StringName(str(item))
			legacy.trigger = SCAR_TRIGGER_IRREVERSIBLE_BET
			values.append(legacy)
	return values

func _serialize_scars_detail() -> Array[Dictionary]:
	var details: Array[Dictionary] = []
	for scar_value: Dictionary in _scars:
		var detail: Dictionary = scar_value.duplicate(true)
		if detail.has("id"):
			detail["id"] = String(detail.get("id", ""))
		details.append(detail)
	return details

func _apply_scars_detail(details: Array) -> void:
	_scars = []
	for value in details:
		if not (value is Dictionary):
			continue
		var detail: Dictionary = value as Dictionary
		if detail.has("id"):
			detail["id"] = StringName(str(detail.get("id", "")))
		_scars.append(detail)
	_emit_scars_updated()

func _parse_pacts_log(values: Variant) -> Array[PactLogEntry]:
	var entries: Array[PactLogEntry] = []
	if not (values is Array):
		return entries
	var items: Array = values as Array
	for value in items:
		if not (value is Dictionary):
			continue
		var entry_data: Dictionary = value as Dictionary
		var entry: PactLogEntry = PactLogEntry.new()
		entry.bet_id = StringName(str(entry_data.get("bet_id", "")))
		entry.bet_name = str(entry_data.get("bet_name", ""))
		entry.arena_index = int(entry_data.get("arena_index", 0))
		entry.outcome = int(entry_data.get("outcome", PACT_OUTCOME_UNKNOWN))
		entries.append(entry)
	return entries

func _emit_escalation_changed() -> void:
	if not GameEvents.has_signal("escalation_changed"):
		return
	GameEvents.escalation_changed.emit(_run_state.escalation_level, ESCALATION_MAX)

func _get_current_arena_index() -> int:
	var arena_index: int = _run_state.arena_index
	if arena_index <= 0:
		arena_index = int(run.get("arena_index", 0))
	return arena_index

func _get_available_arena_theme_ids() -> Array[StringName]:
	var themes: Array[StringName] = [
		ArenaThemes.ARENA_WAX_SEAL,
		ArenaThemes.ARENA_DEBT,
	]
	if _is_unlocked(CONDANNA_E_FINITA_COSI):
		themes.append(ArenaThemes.ARENA_BLOOD)
	if _is_unlocked(CONDANNA_SO_COME_FINISCE):
		themes.append(ArenaThemes.ARENA_SILENCE)
	return themes

func _pick_next_arena_theme() -> StringName:
	var arena_index: int = _get_current_arena_index()
	var themes: Array[StringName] = _get_available_arena_theme_ids()
	var theme_index: int = (maxi(arena_index, 1) - 1) % themes.size()
	return themes[theme_index]

func _emit_arena_theme_changed() -> void:
	if not GameEvents.has_signal("arena_theme_changed"):
		return
	_run_state.arena_theme_id = _pick_next_arena_theme()
	var theme_data: Dictionary = _arena_themes.get_theme(_run_state.arena_theme_id)
	var payload: Dictionary = {
		"theme_id": _run_state.arena_theme_id,
		"title": str(theme_data.get("title", "")),
		"subtitle": str(theme_data.get("subtitle", "")),
		"bg_path": str(theme_data.get("bg_texture_path", "")),
		"overlay_path": str(theme_data.get("overlay_texture_path", "")),
	}
	GameEvents.arena_theme_changed.emit(payload)

func _append_pact_log_entry(bet_id: StringName, bet_name: String) -> void:
	if bet_id == &"":
		return
	var entry: PactLogEntry = PactLogEntry.new()
	entry.bet_id = bet_id
	entry.bet_name = bet_name
	entry.arena_index = _get_current_arena_index()
	entry.outcome = PACT_OUTCOME_UNKNOWN
	_run_state.pacts_log.append(entry)

func _update_last_pact_outcome(bet_id: StringName, won: bool) -> void:
	if bet_id == &"":
		return
	if _run_state.pacts_log.is_empty():
		return
	var entry: PactLogEntry = _run_state.pacts_log[_run_state.pacts_log.size() - 1]
	if entry.bet_id != bet_id:
		return
	entry.outcome = PACT_OUTCOME_WIN if won else PACT_OUTCOME_LOSS

func _pick_special_arena_index(target_arenas: int) -> int:
	if target_arenas <= 0:
		return 0
	var min_index: int = 2
	var max_index: int = maxi(target_arenas, min_index)
	_level3_rng.seed = _run_state.run_seed + 117
	return _level3_rng.randi_range(min_index, max_index)

func _maybe_activate_special_arena() -> void:
	_run_state.special_arena_active = false
	_run_state.special_arena_effect_applied = false
	if _run_state.special_arena_index <= 0:
		return
	if _run_state.special_arena_id != &"":
		return
	if _run_state.arena_index != _run_state.special_arena_index:
		return
	var options: Array[StringName] = [
		SPECIAL_ARENA_SILENCE,
		SPECIAL_ARENA_ASH,
		SPECIAL_ARENA_DISPREZZO,
		SPECIAL_ARENA_VERGOGNA,
	]
	_level3_rng.seed = _run_state.run_seed + _run_state.arena_index * 23
	var pick_idx: int = _level3_rng.randi_range(0, options.size() - 1)
	_run_state.special_arena_id = options[pick_idx]
	_run_state.special_arena_active = true
	_emit_special_arena_started()

func _emit_special_arena_started() -> void:
	if not GameEvents.has_signal("special_arena_started"):
		return
	if _run_state.special_arena_id == &"":
		return
	var payload: Dictionary = {
		"id": String(_run_state.special_arena_id),
		"title": _get_special_arena_title(_run_state.special_arena_id),
		"description": _get_special_arena_description(_run_state.special_arena_id),
		"arena_index": _run_state.arena_index,
	}
	GameEvents.special_arena_started.emit(payload)

func _get_special_arena_title(arena_id: StringName) -> String:
	match arena_id:
		SPECIAL_ARENA_SILENCE:
			return "Arena of Silence"
		SPECIAL_ARENA_ASH:
			return "Arena of Ash"
		SPECIAL_ARENA_DISPREZZO:
			return "Arena del Disprezzo"
		SPECIAL_ARENA_VERGOGNA:
			return "Arena della Vergogna"
		_:
			return "Arena"

func _get_special_arena_description(arena_id: StringName) -> String:
	match arena_id:
		SPECIAL_ARENA_SILENCE:
			return "L'escalation sale subito. Il rischio cresce, le ricompense restano."
		SPECIAL_ARENA_ASH:
			return "Ricompensa extra, ma una cicatrice è garantita."
		SPECIAL_ARENA_DISPREZZO:
			return "Qui non si incassa. La folla pretende un altro sangue."
		SPECIAL_ARENA_VERGOGNA:
			return "La vergogna intacca il favore. Il pubblico cala più in fretta."
		_:
			return ""

func _apply_special_arena_pre_resolution() -> void:
	if not _run_state.special_arena_active:
		return
	if _run_state.special_arena_effect_applied:
		return
	if _run_state.special_arena_id == SPECIAL_ARENA_SILENCE:
		_run_state.escalation_level = maxi(_run_state.escalation_level + 1, 1)
		_try_register_risk_threshold_scar()
		_run_state.level3_max_escalation = maxi(_run_state.level3_max_escalation, _run_state.escalation_level)
		_run_state.max_escalation = maxi(_run_state.max_escalation, _run_state.escalation_level)
		_run_state.special_arena_effect_applied = true
		_emit_escalation_changed()
		_emit_run_debug_state()

func _apply_special_arena_post_resolution(result: ArenaResult, failed: bool) -> void:
	if not _run_state.special_arena_active:
		return
	if _run_state.special_arena_id == SPECIAL_ARENA_ASH and not _run_state.run_is_over and not _is_game_over:
		_apply_special_arena_ash_reward(result, failed)
	if _run_state.special_arena_id == SPECIAL_ARENA_DISPREZZO:
		_run_state.special_arena_cashout_lock_reason = "Arena del Disprezzo: incasso vietato."
	if _run_state.special_arena_id == SPECIAL_ARENA_VERGOGNA:
		_run_state.audience_score = clampi(_run_state.audience_score - 1, AUDIENCE_SCORE_MIN, AUDIENCE_SCORE_MAX)
	_run_state.special_arena_active = false
	_run_state.special_arena_effect_applied = false
	_emit_run_debug_state()

func _apply_special_arena_ash_reward(result: ArenaResult, failed: bool) -> void:
	if _run_state.special_arena_effect_applied:
		return
	var reward_amount: int = 12
	if not failed and result.won:
		add_coins(reward_amount)
	var scar_id: StringName = _pick_special_arena_scar()
	if scar_id != &"":
		_apply_level3_scar(scar_id, "Arena of Ash")
	_run_state.special_arena_effect_applied = true

func _pick_special_arena_scar() -> StringName:
	var options: Array[StringName] = [SCAR_SHAME_MARK, SCAR_CRACKED_BONES, SCAR_RUSTED_ARMOR]
	for scar_id: StringName in options:
		if not _has_scar(scar_id):
			return scar_id
	return &""

func _select_enemy_profile() -> void:
	if LEVEL3_ENEMY_PROFILES.is_empty():
		_run_state.enemy_profile = &""
		return
	var pool: Array[Dictionary] = LEVEL3_ENEMY_PROFILES.duplicate()
	if _run_state.last_enemy_profile != &"" and pool.size() > 1:
		var filtered: Array[Dictionary] = []
		for profile_value: Dictionary in pool:
			var profile_id: StringName = StringName(str(profile_value.get("id", "")))
			if profile_id != _run_state.last_enemy_profile:
				filtered.append(profile_value)
		if filtered.size() > 0:
			pool = filtered
	_level3_rng.seed = _compute_level3_enemy_seed()
	var idx: int = _weighted_pick_enemy_index(pool)
	var chosen: Dictionary = pool[idx] as Dictionary
	var chosen_id: StringName = StringName(str(chosen.get("id", "")))
	_run_state.enemy_profile = chosen_id
	_run_state.last_enemy_profile = chosen_id

func _weighted_pick_enemy_index(pool: Array[Dictionary]) -> int:
	var total_weight: int = 0
	for profile_value: Dictionary in pool:
		var weight: int = int(profile_value.get("weight", 1))
		weight = maxi(weight, 0)
		total_weight += weight
	if total_weight <= 0:
		return 0
	var roll: int = _level3_rng.randi_range(1, total_weight)
	var running: int = 0
	for idx in range(pool.size()):
		var weight: int = int(pool[idx].get("weight", 1))
		weight = maxi(weight, 0)
		running += weight
		if roll <= running:
			return idx
	return maxi(pool.size() - 1, 0)

func _compute_level3_enemy_seed() -> int:
	var seed_value: int = _run_state.run_seed
	seed_value += _run_state.arena_index * 19
	seed_value += _run_state.escalation_level * 7
	seed_value += String(_run_state.last_enemy_profile).hash() * 3
	return seed_value

func _get_enemy_profile_def(profile_id: StringName) -> Dictionary:
	for profile_value: Dictionary in LEVEL3_ENEMY_PROFILES:
		var profile: Dictionary = profile_value as Dictionary
		if StringName(str(profile.get("id", ""))) == profile_id:
			return profile
	return {}

func _log_level3_arena_result(bet_id: StringName, result: ArenaResult, scars_applied: Array[StringName]) -> void:
	var scar_names: Array[String] = []
	for scar_name: StringName in scars_applied:
		scar_names.append(String(scar_name))
	print(
		"Level3 Arena Result | seed=",
		_run_state.run_seed,
		" arena=",
		_run_state.arena_index,
		" bet=",
		String(bet_id),
		" enemy=",
		String(_run_state.enemy_profile),
		" won=",
		result.won,
		" took_damage=",
		result.took_damage,
		" scars_applied=",
		scar_names
	)

func _get_active_scar_ids() -> Array[StringName]:
	var scar_ids: Array[StringName] = []
	for scar: Dictionary in _scars:
		var scar_id: StringName = StringName(str(scar.get("id", "")))
		if scar_id != &"":
			scar_ids.append(scar_id)
	return scar_ids

func _resolve_level3_arena() -> ArenaResult:
	var result: ArenaResult = ArenaResult.new()
	var payload: Dictionary = _outcome_system.resolve_level3_arena(
		_level3_rng,
		_compute_level3_seed(_run_state.active_bet_id),
		_run_state.escalation_level,
		_get_active_scar_ids(),
		_run_state.enemy_profile,
		LEVEL3_ENEMY_PROFILES
	)
	result.won = bool(payload.get("won", false))
	result.took_damage = bool(payload.get("took_damage", false))
	var notes_payload: Array = payload.get("notes", []) as Array
	result.notes.clear()
	for note_value: Variant in notes_payload:
		result.notes.append(StringName(str(note_value)))
	return result

func _get_level3_bet_behavior(bet_id: StringName) -> StringName:
	var mapped: Variant = LEVEL3_BET_BEHAVIOR.get(bet_id, bet_id)
	return StringName(str(mapped))

func _handle_level3_win(bet_id: StringName, _result: ArenaResult) -> void:
	_waiting_for_push_luck = true
	_run_state.current_bet_id = String(bet_id)
	_run_state.last_action_was_rilancio = false
	_run_state.risky_choice_made_recently = false
	_open_push_luck_choice(StringName(bet_id))

func _handle_level3_loss(bet_id: StringName, _result: ArenaResult) -> Array[StringName]:
	_waiting_for_push_luck = false
	_waiting_for_bet = false
	set_phase(RunPhase.PREP)
	var scars_applied: Array[StringName] = []
	var behavior_id: StringName = _get_level3_bet_behavior(bet_id)
	var consequence: Dictionary = _outcome_system.build_level3_loss_consequence(
		bet_id,
		behavior_id,
		_run_state.enemy_profile,
		_run_state.provoke_armed,
		_run_state.level3_next_loss_hp_penalty,
		SCAR_OPEN_WOUND_HP_PENALTY
	)
	if bool(consequence.get("provoke_failed", false)):
		_run_state.provoke_armed = false
		_register_run_end("PROVOCA_FAIL")
		_enter_end_run("")
		return scars_applied
	if bool(consequence.get("double_or_die_failed", false)):
		_register_run_end("DOUBLE_OR_DIE")
		end_run(&"THE_FOOL")
		return scars_applied
	var hp_loss: int = int(consequence.get("hp_loss", 0))
	if hp_loss > 0:
		_apply_max_hp_loss(hp_loss)
	var cashout_lock_min: int = int(consequence.get("cashout_lock_min", -1))
	if cashout_lock_min >= 0:
		_run_state.cashout_lock_remaining = maxi(_run_state.cashout_lock_remaining, cashout_lock_min)
	var scar_id: StringName = StringName(str(consequence.get("scar_id", "")))
	if scar_id != &"":
		var scar_origin: String = str(consequence.get("scar_origin", ""))
		_apply_level3_scar(scar_id, scar_origin)
		scars_applied.append(scar_id)
	if bool(consequence.get("clear_next_loss_hp_penalty", false)):
		_run_state.level3_next_loss_hp_penalty = 0
	if bool(consequence.get("reset_reward_tier", false)):
		_run_state.level3_reward_tier = 1
	if bool(consequence.get("reset_escalation", false)):
		_run_state.escalation_level = 0
	_emit_escalation_changed()
	_run_state.current_bet_id = ""
	start_arena()
	return scars_applied

func _handle_level3_loss_ritual(bet_id: StringName, _result: ArenaResult) -> Array[StringName]:
	_waiting_for_push_luck = false
	_waiting_for_bet = false
	set_phase(RunPhase.PREP)
	var scars_applied: Array[StringName] = []
	var behavior_id: StringName = _get_level3_bet_behavior(bet_id)
	var consequence: Dictionary = _outcome_system.build_level3_loss_consequence(
		bet_id,
		behavior_id,
		_run_state.enemy_profile,
		_run_state.provoke_armed,
		_run_state.level3_next_loss_hp_penalty,
		SCAR_OPEN_WOUND_HP_PENALTY
	)
	if bool(consequence.get("provoke_failed", false)):
		_run_state.provoke_armed = false
		_register_run_end("PROVOCA_FAIL")
		_enter_end_run("")
		return scars_applied
	if bool(consequence.get("double_or_die_failed", false)):
		_register_run_end("DOUBLE_OR_DIE")
		end_run(&"THE_FOOL")
		return scars_applied
	var hp_loss: int = int(consequence.get("hp_loss", 0))
	if hp_loss > 0:
		_apply_max_hp_loss(hp_loss)
	var cashout_lock_min: int = int(consequence.get("cashout_lock_min", -1))
	if cashout_lock_min >= 0:
		_run_state.cashout_lock_remaining = maxi(_run_state.cashout_lock_remaining, cashout_lock_min)
	var scar_id: StringName = StringName(str(consequence.get("scar_id", "")))
	if scar_id != &"":
		var scar_origin: String = str(consequence.get("scar_origin", ""))
		_apply_level3_scar(scar_id, scar_origin)
		scars_applied.append(scar_id)
	if bool(consequence.get("clear_next_loss_hp_penalty", false)):
		_run_state.level3_next_loss_hp_penalty = 0
	if bool(consequence.get("reset_reward_tier", false)):
		_run_state.level3_reward_tier = 1
	if bool(consequence.get("reset_escalation", false)):
		_run_state.escalation_level = 0
	_emit_escalation_changed()
	_resolve_ritual_reward_applied = true
	_emit_run_debug_state()
	return scars_applied

func _apply_max_hp_loss(amount: int) -> void:
	if amount <= 0:
		return
	var player: Node = _resolve_player()
	var max_hp: int = _get_player_max_health_value(player)
	var new_modifier: int = _run_state.max_hp_modifier - amount
	if max_hp > 0:
		var floor_limit: int = -maxi(max_hp - 1, 0)
		new_modifier = maxi(new_modifier, floor_limit)
	_run_state.max_hp_modifier = new_modifier
	_apply_run_upgrades_to_player()

func _apply_level3_reward(bet_id: StringName, reward_tier: int) -> void:
	var behavior_id: StringName = _get_level3_bet_behavior(bet_id)
	var reward_coins: int = _outcome_system.compute_level3_reward_coins(
		behavior_id,
		reward_tier,
		_get_audience_cashout_modifier()
	)
	if reward_coins > 0:
		add_coins(reward_coins)

func _apply_level3_scar(scar_id: StringName, origin: String) -> void:
	var scar_def: Dictionary = _get_scar_def(scar_id)
	if scar_def.is_empty():
		return
	var narrative_text: String = str(scar_def.get("narrative_text", scar_def.get("story", "")))
	var effect_text: String = str(scar_def.get("effect_text", scar_def.get("effect", "")))
	var scar: Dictionary = {
		"id": scar_id,
		"name": str(scar_def.get("name", "")),
		"origin": origin,
		"effect": str(scar_def.get("effect", "")),
		"effect_text": effect_text,
		"story": str(scar_def.get("story", "")),
		"narrative_text": narrative_text,
		"short_desc": str(scar_def.get("short_desc", "")),
		"visual_tag": str(scar_def.get("visual_tag", "")),
		"tags": scar_def.get("tags", []) as Array,
	}
	_add_scar(scar)

func _get_scar_def(scar_id: StringName) -> Dictionary:
	return _scar_catalog.get_scar(scar_id)

func _determine_level3_ending_id() -> StringName:
	var scar_count: int = _run_state.scars_history.size()
	if scar_count <= 0:
		return &"THE_SURVIVOR"
	if scar_count == 1:
		return &"THE_MARKED"
	return &"THE_BROKEN"

func _ensure_arena_and_player() -> void:
	if LEVEL3_ENABLED:
		return
	var main: Node = get_parent()
	if main == null:
		return
	var arena_node: Node = null
	if arena_path != NodePath():
		arena_node = get_node_or_null(arena_path)
	if arena_node == null and arena_scene:
		arena_node = arena_scene.instantiate()
		arena_node.name = "Arena"
		main.add_child(arena_node)
		if arena_node is Node2D:
			arena_node.global_position = Vector2.ZERO
		arena_path = NodePath("../Arena")
	_arena = arena_node

	var existing_player: Node = null
	if player_path != NodePath():
		existing_player = get_node_or_null(player_path)
	if existing_player == null:
		existing_player = get_tree().get_first_node_in_group("player")
	if existing_player == null and player_scene:
		existing_player = player_scene.instantiate()
		existing_player.name = "Player"
		if _arena:
			_arena.add_child(existing_player)
		else:
			main.add_child(existing_player)
		if existing_player is Node2D:
			existing_player.global_position = Vector2.ZERO
		if _arena:
			player_path = NodePath("../Arena/Player")
		else:
			player_path = NodePath("../Player")
	elif existing_player != null:
		var player_parent: Node = existing_player.get_parent()
		if player_parent == _arena:
			player_path = NodePath("../Arena/Player")
		elif player_parent == main:
			player_path = NodePath("../Player")
	_player = existing_player
	if _player and _player is Node2D:
		(_player as Node2D).global_position = Vector2.ZERO
	_set_arena_suspended(_modal_lock_count > 0)
	_update_arena_visual_only()

func pick_next_arena_scene() -> PackedScene:
	if _arena_scenes.size() == 0:
		return arena_scene
	var idx: int = _arena_layout_rng.randi_range(0, _arena_scenes.size() - 1)
	return _arena_scenes[idx]

func _ensure_arena_layout_container() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena == null:
		push_error("RunManager: Arena container missing; cannot prepare arena layout container.")
		return
	if _arena_layout_container != null and is_instance_valid(_arena_layout_container):
		return
	var existing: Node = _arena.get_node_or_null("ArenaLayoutRoot")
	if existing != null and existing is Node2D:
		_arena_layout_container = existing as Node2D
		_arena_layout_container.position = arena_layout_offset
		return
	var new_container: Node2D = Node2D.new()
	new_container.name = "ArenaLayoutRoot"
	new_container.position = arena_layout_offset
	_arena.add_child(new_container)
	_arena_layout_container = new_container

func _remove_default_arena_layout() -> void:
	if _arena == null:
		return
	var ground: Node = _arena.get_node_or_null("Ground")
	if ground != null:
		ground.queue_free()
	var walls: Node = _arena.get_node_or_null("Walls")
	if walls != null:
		walls.queue_free()

func load_next_arena() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena == null:
		push_error("RunManager: Arena container missing; cannot load next arena layout.")
		return
	_ensure_arena_layout_container()
	if _arena_layout_container == null:
		push_error("RunManager: Arena layout container missing; cannot load next arena layout.")
		return
	_remove_default_arena_layout()
	if _current_arena_layout != null and is_instance_valid(_current_arena_layout):
		_current_arena_layout.queue_free()
	var next_scene: PackedScene = pick_next_arena_scene()
	if next_scene == null:
		push_error("RunManager: Missing arena scene; cannot instantiate arena layout.")
		return
	var layout_instance: Node = next_scene.instantiate()
	_current_arena_layout = layout_instance
	_current_arena_path = next_scene.resource_path
	_arena_layout_container.add_child(layout_instance)
	if layout_instance is Node2D:
		(layout_instance as Node2D).position = Vector2.ZERO

func _reset_or_respawn_player_full() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	_player = _resolve_player()
	if _player == null or not _player.is_inside_tree():
		var main: Node = get_parent()
		if main != null and player_scene:
			_player = player_scene.instantiate()
			_player.name = "Player"
			if _arena:
				_arena.add_child(_player)
			else:
				main.add_child(_player)
			if _player is Node2D:
				(_player as Node2D).global_position = Vector2.ZERO
			if _arena:
				player_path = NodePath("../Arena/Player")
			else:
				player_path = NodePath("../Player")
	elif _arena and _player.get_parent() != _arena:
		var player_node: Node = _player
		if player_node is Node:
			var pos: Vector2 = Vector2.ZERO
			if player_node is Node2D:
				pos = (player_node as Node2D).global_position
			player_node.reparent(_arena)
			if player_node is Node2D:
				(player_node as Node2D).global_position = pos
			player_path = NodePath("../Arena/Player")
	if _player != null and _player.has_method("reset_full_health"):
		_player.call("reset_full_health")
	_apply_run_upgrades_to_player()
	_connect_player_signals()
	_position_player_after_respawn()

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node and is_instance_valid(enemy):
			enemy.queue_free()

func _spawn_wave_or_enemies() -> void:
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena == null:
		_arena = get_tree().get_first_node_in_group("arena")
	_start_next_arena()

func _ensure_input_map() -> void:
	var actions: Dictionary = {
		# Movimento
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],

		# Combattimento
		"attack_light": [KEY_J],
		"attack_heavy": [KEY_K],
		"block": [KEY_L],
		"dodge": [KEY_SPACE],

		# Sistema
		"pause": [KEY_ESCAPE],
	}

	for action_name: String in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing: Dictionary = {}
		for ev: InputEvent in InputMap.action_get_events(action_name):
			if ev is InputEventKey:
				existing[ev.keycode] = true

		var keycodes: Array = actions[action_name] as Array
		for keycode: int in keycodes:
			if not existing.has(keycode):
				var iev: InputEventKey = InputEventKey.new()
				iev.keycode = keycode
				InputMap.action_add_event(action_name, iev)

	print("InputMap ensured: movement + combat bindings ready")

func _start_next_arena() -> void:
	if _arena == null or _is_game_over:
		return
	run["arena_index"] = int(run.get("arena_index", 0)) + 1
	var bet_id: StringName = StringName(_run_state.current_bet_id)
	if bet_id == &"":
		bet_id = _run_state.last_selected_bet_id
	_emit_sentence_banner_for_bet(bet_id)
	_arena.call("start_next_wave")

# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
# Preconditions: RunManager exists (group "run_manager") and listens to GameEvents.request_new_run.
# Postconditions: Active run state is reset and GameEvents.run_started is emitted.
func _on_request_new_run() -> void:
	_save_system.clear_run()
	request_new_game()

func _on_request_reset_run() -> void:
	_save_system.clear_run()
	request_new_game()

func _on_request_retry_run() -> void:
	if LEVEL3_ENABLED:
		_start_level3_run()
		return
	retry_current_bet()

func _on_request_continue_run() -> void:
	request_load_continue()

func _on_request_show_main_menu() -> void:
	print_debug("[FLOW] request_show_main_menu_received")
	request_quit_to_menu()

func _on_request_place_bet(bet_id: String, _stake: int) -> void:
	if not LEVEL3_ENABLED:
		return
	print_debug("[FLOW] bet_choice_received :: arena=%d, bet_id=%s" % [_run_state.arena_index, bet_id])
	select_bet(StringName(bet_id))

func _on_request_intermediate_choice(choice_id: String) -> void:
	var normalized_choice: String = choice_id.strip_edges().to_lower()
	if normalized_choice == "placa":
		request_choose_mid(0)
		return
	if normalized_choice == "provoca":
		request_choose_mid(1)
		return
	push_error("RunManager: request_choose_mid invalid choice '%s'" % choice_id)

func _apply_intermediate_choice(choice_id: String) -> void:
	print_debug("[FLOW] intermediate_choice_received :: arena=%d, choice=%s" % [_run_state.arena_index, choice_id])
	_waiting_for_intermediate_choice = false
	_run_state.intermediate_double_disabled_once = false
	_run_state.intermediate_bonus_tier = 0
	_run_state.intermediate_choice_note = ""
	_run_state.intermediate_loss_penalty_pending = false
	_run_state.provoke_armed = false
	var normalized_choice: String = choice_id.strip_edges().to_lower()
	var escalation_delta: int = 0
	match normalized_choice:
		"placa":
			escalation_delta = -1
			_run_state.intermediate_choice_note = "Gesto: Umiliati."
		"provoca":
			escalation_delta = 1
			_run_state.intermediate_choice_note = "Gesto: Provoca."
		_:
			_run_state.intermediate_choice_note = ""
	if escalation_delta != 0:
		var previous_level: int = _run_state.escalation_level
		var next_level: int = clampi(previous_level + escalation_delta, 0, ESCALATION_MAX)
		_run_state.escalation_level = next_level
		if next_level > _run_state.level3_max_escalation:
			_run_state.level3_max_escalation = next_level
		if next_level > _run_state.max_escalation:
			_run_state.max_escalation = next_level
		if next_level != previous_level:
			_emit_escalation_changed()
			_emit_run_debug_state()
	_emit_audience_context_line(AUDIENCE_CONTEXT_GESTURE_CHOSEN)
	var bet_id: StringName = _run_state.intermediate_pending_bet_id
	if bet_id == &"":
		bet_id = _run_state.last_selected_bet_id
	_run_state.intermediate_pending_bet_id = &""
	_open_push_luck_choice(bet_id)
	_autosave_run_checkpoint(RUN_FLOW_PUSH_LUCK, bet_id)

func _on_post_arena_choice_selected(choice_id: StringName) -> void:
	if choice_id != &"CONDANNA":
		return
	_handle_push_luck_condanna()

func _on_request_push_luck_cashout() -> void:
	request_take_payout()

func _take_payout() -> void:
	print_debug("[FLOW] push_luck_cashout_received :: arena=%d" % _run_state.arena_index)
	var audience_policy: Dictionary = _get_audience_cashout_policy()
	if not bool(audience_policy.get("cashout_enabled", true)):
		_refresh_push_luck_choice(StringName(_run_state.current_bet_id))
		return
	if LEVEL3_ENABLED:
		var lock_reason: String = _get_cashout_lock_reason()
		if lock_reason != "":
			return
		var bet_id_name: StringName = StringName(_run_state.current_bet_id)
		var bonus_tier: int = _consume_intermediate_choice_bonus()
		_waiting_for_push_luck = false
		_run_state.last_action_was_rilancio = false
		_run_state.risky_choice_made_recently = false
		_update_arena_visual_only()
		GameEvents.push_luck_closed.emit()
		_emit_audience_context_line(AUDIENCE_CONTEXT_CASH_OUT)
		if bet_id_name != &"" and not _resolve_ritual_reward_applied:
			_apply_level3_reward(bet_id_name, _run_state.level3_reward_tier + bonus_tier)
		_resolve_ritual_reward_applied = false
		_run_state.level3_cashouts += 1
		_run_state.cashouts += 1
		if _run_state.refuse_cashout_count_this_run >= 1:
			_register_condanna(CONDANNA_HO_VISTO_ABBASTANZA)
		if _run_state.escalation_level >= 4:
			_register_condanna(CONDANNA_HO_VISTO_ABBASTANZA)
		if _run_state.escalation_level >= 7:
			_register_condanna(CONDANNA_MI_SONO_FERMATO)
		if _run_state.escalation_level >= 2:
			_run_state.level3_cashed_after_high_escalation = true
			_run_state.level3_reward_tier = 1
			_run_state.level3_next_loss_hp_penalty = 0
			_run_state.escalation_level = 0
			_emit_escalation_changed()
			_run_state.current_bet_id = ""
			_emit_run_debug_state()
			_register_run_end("CASH_OUT")
		end_run(&"")
		return
	var bet_id: String = _run_state.current_bet_id
	var bonus_tier: int = _consume_intermediate_choice_bonus()
	_waiting_for_push_luck = false
	_update_arena_visual_only()
	GameEvents.push_luck_closed.emit()
	_emit_audience_context_line(AUDIENCE_CONTEXT_CASH_OUT)
	_run_state.push_luck_cashouts += 1
	if bet_id != "":
		_apply_bet_reward_scaled(bet_id, _run_state.bet_chain_level + bonus_tier)
	_reset_bet_chain()
	_open_bet_ui(true)
	_autosave_run_checkpoint(RUN_FLOW_BET_OFFER, &"")

func _handle_push_luck_condanna() -> void:
	if not _waiting_for_push_luck:
		return
	_consume_intermediate_choice_bonus()
	_waiting_for_push_luck = false
	_run_state.last_action_was_rilancio = false
	_update_arena_visual_only()
	GameEvents.push_luck_closed.emit()
	if LEVEL3_ENABLED:
		_resolve_ritual_reward_applied = false
		if _run_state.escalation_level >= 2:
			_run_state.level3_cashed_after_high_escalation = true
			_run_state.level3_reward_tier = 1
			_run_state.level3_next_loss_hp_penalty = 0
			_run_state.escalation_level = 0
			_emit_escalation_changed()
			_run_state.current_bet_id = ""
			_emit_run_debug_state()
			_register_run_end("CASH_OUT")
		end_run(&"")
		return
	_reset_bet_chain()
	_open_bet_ui(true)

func _on_request_push_luck_double() -> void:
	request_push_your_luck()

func _push_your_luck() -> void:
	print_debug("[FLOW] push_luck_double_received :: arena=%d" % _run_state.arena_index)
	if LEVEL3_ENABLED:
		var lock_reason: String = _get_double_lock_reason()
		if lock_reason != "":
			return
		_run_state.refuse_cashout_count_this_run += 1
		_try_register_refused_closure_scar()
		if _run_state.escalation_level >= ESCALATION_HIGH_THRESHOLD or _run_state.refuse_cashout_count_this_run >= 3:
			_run_state.risky_choice_made_recently = true
		var player: Node = _resolve_player()
		var current_hp: int = -1
		var max_hp: int = -1
		if player != null:
			current_hp = _get_player_health_value(player)
			max_hp = _get_player_max_health_value(player)
		var critical_hp: bool = false
		if current_hp >= 0 and max_hp > 0:
			critical_hp = float(current_hp) / float(max_hp) <= 0.20
		var critical_scars: bool = _run_state.scars_history.size() >= 3
		if critical_hp or critical_scars:
			_register_condanna(CONDANNA_SO_COME_FINISCE)
		if _run_state.refuse_cashout_count_this_run == 1:
			_register_condanna(CONDANNA_NON_MI_FERMERO)
		elif _run_state.refuse_cashout_count_this_run == 2:
			_register_condanna(CONDANNA_ANCORA)
		if _run_state.escalation_level >= ESCALATION_HIGH_THRESHOLD:
			_register_condanna(CONDANNA_FINCHE_REGGE)
		_run_state.last_action_was_rilancio = true
		_waiting_for_push_luck = false
		_reset_intermediate_choice_modifiers()
		_run_state.special_arena_cashout_lock_reason = ""
		_update_arena_visual_only()
		GameEvents.push_luck_closed.emit()
		_emit_audience_context_line(AUDIENCE_CONTEXT_CONTINUE)
		_resolve_ritual_reward_applied = false
		_run_state.escalation_level = maxi(_run_state.escalation_level + 1, 1)
		_try_register_risk_threshold_scar()
		_run_state.level3_reward_tier = maxi(_run_state.level3_reward_tier + 1, 1)
		_run_state.level3_doubles += 1
		_run_state.doubles += 1
		_run_state.level3_max_escalation = maxi(_run_state.level3_max_escalation, _run_state.escalation_level)
		_run_state.max_escalation = maxi(_run_state.max_escalation, _run_state.escalation_level)
		_emit_escalation_changed()
		if _run_state.cashout_lock_remaining > 0:
			_run_state.cashout_lock_remaining = maxi(_run_state.cashout_lock_remaining - 1, 0)
		_run_state.level3_next_loss_hp_penalty = 30
		_emit_run_debug_state()
		start_arena()
		_autosave_run_checkpoint(RUN_FLOW_BET_OFFER, &"")
		return
	var bet_id: String = _run_state.current_bet_id
	_reset_intermediate_choice_modifiers()
	_waiting_for_push_luck = false
	_update_arena_visual_only()
	GameEvents.push_luck_closed.emit()
	_emit_audience_context_line(AUDIENCE_CONTEXT_CONTINUE)
	if bet_id == "":
		_open_bet_ui(true)
		return
	_run_state.bet_chain_level = maxi(_run_state.bet_chain_level + 1, 1)
	_run_state.push_luck_doubles += 1
	_run_state.max_push_luck_chain = maxi(_run_state.max_push_luck_chain, _run_state.bet_chain_level)
	_try_apply_cracked_bones_scar(bet_id, _run_state.bet_chain_level)
	set_phase(RunPhase.LIVE)
	_clear_enemies()
	_spawn_wave_or_enemies()

func _on_request_set_run_seed(run_seed: int) -> void:
	_run_state.debug_seed_override_active = true
	_run_state.debug_seed_override = run_seed
	print("Debug seed override set:", run_seed)
	if _has_started_run:
		start_new_run()

func _on_request_clear_run_seed() -> void:
	_run_state.debug_seed_override_active = false
	_run_state.debug_seed_override = 0
	print("Debug seed override cleared")
	if _has_started_run:
		start_new_run()

func _on_request_skip_arena_resolution() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	if not OS.is_debug_build():
		return
	if LEVEL3_ENABLED:
		_debug_skip_level3_step()
		return
	_clear_enemies()
	var wave: int = 0
	if _arena != null and _arena.has_method("get_current_wave"):
		wave = int(_arena.call("get_current_wave"))
	_on_wave_cleared(wave)

func _debug_skip_level3_step() -> void:
	if _waiting_for_bet:
		var bet_id: StringName = _get_debug_default_bet()
		if bet_id != &"":
			select_bet(bet_id)
		return
	if _waiting_for_push_luck:
		_on_request_push_luck_double()

func _get_debug_default_bet() -> StringName:
	if _run_state.level3_current_offer.is_empty():
		return &""
	var bet_data: Dictionary = _run_state.level3_current_offer[0] as Dictionary
	return StringName(str(bet_data.get("id", "")))

func _on_modal_opened(_kind: String) -> void:
	_modal_lock_count += 1
	_apply_modal_lock()

func _on_modal_closed(_kind: String) -> void:
	_modal_lock_count = maxi(_modal_lock_count - 1, 0)
	_apply_modal_lock()

func _apply_modal_lock() -> void:
	var locked: bool = _modal_lock_count > 0
	var player: Node = get_tree().get_first_node_in_group("player") as Node
	if player != null:
		if player.has_method("set_input_locked"):
			player.call("set_input_locked", locked)
		elif "input_locked" in player:
			player.set("input_locked", locked)

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	for enemy: Node in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.has_method("set_ai_locked"):
			enemy.call("set_ai_locked", locked)
		elif "ai_locked" in enemy:
			enemy.set("ai_locked", locked)
	_set_arena_suspended(locked)

func _set_arena_suspended(suspended: bool) -> void:
	if _arena == null or not is_instance_valid(_arena):
		_arena = get_node_or_null(arena_path)
	if _arena == null:
		return
	if suspended == _arena_suspended:
		return
	_arena_suspended = suspended
	if _arena.has_method("set_visual_only"):
		_arena.call("set_visual_only", suspended)
	_arena.process_mode = Node.PROCESS_MODE_INHERIT

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	run["coins"] = int(run.get("coins", 0)) + amount
	GameEvents.coins_changed.emit(int(run.get("coins", 0)))

func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return false
	if int(run.get("coins", 0)) < amount:
		return false
	run["coins"] = int(run.get("coins", 0)) - amount
	GameEvents.coins_changed.emit(int(run.get("coins", 0)))
	return true

func get_coins() -> int:
	return int(run.get("coins", 0))

func get_tokens() -> int:
	return int(run.get("upgrade_tokens", 0))

func get_buy_token_cost() -> int:
	return token_purchase_cost_coins

func get_token_buy_cost() -> int:
	return token_purchase_cost_coins

func buy_token() -> bool:
	return purchase_token()

func spend_tokens(amount: int) -> bool:
	if amount <= 0:
		return true
	if int(run.get("upgrade_tokens", 0)) < amount:
		return false
	run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) - amount
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func purchase_token() -> bool:
	# Compra 1 token pagando coins.
	if token_purchase_cost_coins <= 0:
		return false
	if not spend_coins(token_purchase_cost_coins):
		return false
	run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) + 1
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func _on_bet_placed(_bet_id: String, _stake: int, _odds: float) -> void:
	if LEVEL3_ENABLED:
		return
	if not _waiting_for_bet:
		return
	if _is_game_over:
		return
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_run_state.current_bet_id = _bet_id
	_run_state.bet_chain_level = 1
	_append_pact_log_entry(StringName(_bet_id), "")
	GameEvents.betting_closed.emit()
	set_phase(RunPhase.LIVE)
	load_next_arena()
	_start_next_arena()

func _on_bet_confirmed(pact_id: StringName, condition_id: StringName, sentence_id: StringName) -> void:
	_handle_bet_sealed(pact_id, condition_id, sentence_id)

func _on_bet_sealed(bet_choice: Dictionary) -> void:
	var pact_id: StringName = StringName(str(bet_choice.get("pact_id", "")))
	var condition_id: StringName = StringName(str(bet_choice.get("condition_id", "")))
	var sentence_id: StringName = StringName(str(bet_choice.get("sentence_id", "")))
	_handle_bet_sealed(pact_id, condition_id, sentence_id)

func _handle_bet_sealed(pact_id: StringName, condition_id: StringName, sentence_id: StringName) -> void:
	if _is_game_over:
		return
	if pact_id == &"" or condition_id == &"" or sentence_id == &"":
		push_warning("Bet sealed with missing selections; forcing next step.")
	if not _waiting_for_bet:
		push_warning("Bet sealed outside waiting state; forcing advance.")
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_run_state.bet_chain_level = 1
	_run_state.current_bet_id = ""
	run["betting_circle"] = {
		"pact_id": String(pact_id),
		"condition_id": String(condition_id),
		"sentence_id": String(sentence_id),
	}
	GameEvents.betting_closed.emit()
	set_phase(RunPhase.LIVE)
	_autosave_run_checkpoint(RUN_FLOW_BET_SIGNED, &"")
	_emit_audience_context_line(AUDIENCE_CONTEXT_PACT_SIGNED)
	load_next_arena()
	_start_next_arena()

func _on_betting_opened() -> void:
	_force_game_over_if_dead()

func _on_wave_started(_wave: int) -> void:
	if LEVEL3_ENABLED:
		return
	GameEvents.arena_started.emit(int(run.get("arena_index", 0)))
	# la difficoltà dei nemici può dipendere dal livello
	_apply_enemy_difficulty_to_arena()
	_apply_phase()

func _on_wave_cleared(_wave: int) -> void:
	if LEVEL3_ENABLED:
		return
	GameEvents.arena_completed.emit(int(run.get("arena_index", 0)))
	var bet_result: Dictionary = {}
	if arena_clear_reward > 0:
		add_coins(arena_clear_reward)
	if not bet_result.is_empty():
		var bet_id: String = str(bet_result.get("id", ""))
		var won: bool = bool(bet_result.get("won", false))
		_update_last_pact_outcome(StringName(bet_id), won)
		if won and bet_id != "":
			_run_state.current_bet_id = bet_id
			_open_push_luck_choice(StringName(bet_id))
			return
	_reset_bet_chain()
	_open_bet_ui(true)
	_autosave_run_checkpoint(RUN_FLOW_BET_OFFER, &"")

func _on_player_spawned(player: Node) -> void:
	_player = player
	_apply_run_upgrades_to_player()
	_connect_player_signals()
	_position_player_after_respawn()
	_apply_phase()

func _on_enemy_killed(exp_value: int) -> void:
	if _is_game_over:
		return
	if phase != RunPhase.LIVE:
		return
	var gained: int = exp_per_enemy
	if exp_value > 0:
		gained = exp_value
	if gained <= 0:
		return
	run["xp"] = int(run.get("xp", 0)) + gained
	var leveled: bool = _check_level_up()
	if leveled:
		_recompute_difficulty_tier(false)
	_emit_xp_level_ui()

func _xp_needed_for_next(level: int) -> int:
	# level parte da 1. Per passare a level+1 usiamo exp_curve[level-1] se esiste.
	var idx: int = maxi(level - 1, 0)
	if idx < exp_curve.size():
		return int(exp_curve[idx])
	# tail lineare
	var last: int = 5
	if exp_curve.size() > 0:
		last = int(exp_curve[exp_curve.size() - 1])
	var extra: int = (idx - maxi(exp_curve.size() - 1, 0)) * maxi(exp_curve_tail_step, 1)
	return last + extra

func _check_level_up() -> bool:
	var lvl: int = int(run.get("level", 1))
	var xp: int = int(run.get("xp", 0))
	var needed: int = _xp_needed_for_next(lvl)
	var leveled: bool = false
	while xp >= needed and needed > 0:
		xp -= needed
		lvl += 1
		run["upgrade_tokens"] = int(run.get("upgrade_tokens", 0)) + maxi(tokens_per_level, 0)
		needed = _xp_needed_for_next(lvl)
		leveled = true
	run["level"] = lvl
	run["xp"] = xp
	return leveled

func _emit_xp_level_ui() -> void:
	var lvl: int = int(run.get("level", 1))
	var xp: int = int(run.get("xp", 0))
	var needed: int = _xp_needed_for_next(lvl)
	GameEvents.player_level_changed.emit(lvl)
	GameEvents.player_xp_changed.emit(xp, needed)
	GameEvents.level_changed.emit(lvl)
	GameEvents.xp_changed.emit(xp, needed)
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))

func get_level() -> int:
	return int(run.get("level", 1))

func get_difficulty_tier() -> int:
	return int(run.get("difficulty_tier", 0))

func get_difficulty_multiplier() -> float:
	var tier: int = get_difficulty_tier()
	if tier_multipliers.size() == 0:
		return 1.0
	if tier < tier_multipliers.size():
		return float(tier_multipliers[tier])
	return float(tier_multipliers[tier_multipliers.size() - 1])

func get_upgrade_tokens() -> int:
	return int(run.get("upgrade_tokens", 0))

func consume_upgrade_token() -> bool:
	var t: int = int(run.get("upgrade_tokens", 0))
	if t <= 0:
		return false
	run["upgrade_tokens"] = t - 1
	GameEvents.upgrade_tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	GameEvents.tokens_changed.emit(int(run.get("upgrade_tokens", 0)))
	return true

func _recompute_difficulty_tier(force_emit: bool) -> void:
	var lvl: int = int(run.get("level", 1))
	var new_tier: int = 0
	if levels_per_tier > 0:
		new_tier = int(floor(float(maxi(lvl - 1, 0)) / float(levels_per_tier)))
	var old_tier: int = int(run.get("difficulty_tier", 0))
	run["difficulty_tier"] = new_tier
	var mult: float = get_difficulty_multiplier()
	if force_emit or new_tier != old_tier:
		GameEvents.difficulty_tier_changed.emit(new_tier, mult)
		if _arena != null and _arena.has_method("set_difficulty_tier"):
			_arena.call("set_difficulty_tier", new_tier, mult)

func _apply_enemy_difficulty_to_arena() -> void:
	# Hook opzionale: se Arena ha un metodo, passiamo livello per scalare stats nemici
	if _arena == null:
		_arena = get_node_or_null(arena_path)
	if _arena != null and _arena.has_method("set_difficulty_tier"):
		_arena.call("set_difficulty_tier", get_difficulty_tier(), get_difficulty_multiplier())
	elif _arena != null and _arena.has_method("set_difficulty_level"):
		_arena.call("set_difficulty_level", int(run.get("level", 1)))

func _resolve_player() -> Node:
	if _player and is_instance_valid(_player) and _player.is_inside_tree():
		return _player
	if LEVEL3_ENABLED:
		var existing_player: Node = get_tree().get_first_node_in_group("player")
		if existing_player != null and existing_player.is_inside_tree():
			_player = existing_player
			return _player
		return null
	if player_path != NodePath():
		var path_player: Node = get_node_or_null(player_path)
		if path_player:
			_player = path_player
			return _player
	_player = get_tree().get_first_node_in_group("player")
	if _player != null:
		return _player
	if player_scene:
		var main: Node = get_parent()
		_player = player_scene.instantiate()
		_player.name = "Player"
		if _arena:
			_arena.add_child(_player)
			player_path = NodePath("../Arena/Player")
		elif main:
			main.add_child(_player)
			player_path = NodePath("../Player")
		if _player is Node2D:
			(_player as Node2D).global_position = Vector2.ZERO
	return _player

func _connect_player_signals() -> void:
	_player = _resolve_player()
	if OS.is_debug_build() and _player != null:
		var player_script: Script = _player.get_script()
		var player_script_path: String = ""
		if player_script != null:
			player_script_path = player_script.resource_path
		print("Runtime Player script:", player_script_path)
	if _player == null:
		return
	var died_callable: Callable = Callable(self, "_on_player_died")
	if _player.has_signal("died") and not _player.died.is_connected(died_callable):
		_player.died.connect(died_callable)

func _on_run_failed() -> void:
	_on_request_fail_run("RUN_FAILED")

func _on_request_fail_run(reason: String = "") -> void:
	if _is_game_over or _run_failed_emitted:
		return
	GameEvents.set_gameplay_enabled(false)
	var resolved_reason: String = reason.strip_edges()
	if resolved_reason == "":
		resolved_reason = "RUN_FAILED"
	_enter_end_run(resolved_reason)

func _on_player_died() -> void:
	_enter_end_run("death")

func _soft_reset() -> void:
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	run["arena_index"] = 0
	_player = _resolve_player()
	_reset_bet_chain()
	_open_bet_ui(false)

func handle_bet_failed(bet_id: String) -> void:
	if _is_game_over:
		return
	_update_last_pact_outcome(StringName(bet_id), false)
	if _run_state.provoke_armed:
		_run_state.provoke_armed = false
		_register_run_end("PROVOCA_FAIL")
		_enter_end_run("")
		return
	if bet_id == BET_DOUBLE_OR_DIE:
		_run_state.failed_high_risk_bets += 1
		_register_run_end("DOUBLE_OR_DIE")
		_reset_bet_chain()
		_enter_end_run("")
		return
	if bet_id == BET_PURE_BLOOD:
		_run_state.failed_high_risk_bets += 1
		var chain_level: int = _run_state.bet_chain_level
		_apply_pure_bet_penalty(chain_level)
	_reset_bet_chain()

func _apply_pure_bet_penalty(chain_level: int) -> void:
	var scale: int = _get_bet_chain_doom_scale(chain_level)
	var penalty: int = 10 * scale
	var current_penalty: int = int(run.get("bet_hp_penalty", 0))
	var max_health: int = _get_player_max_health_value(_resolve_player())
	if max_health > 0:
		penalty = mini(penalty, maxi(max_health - 1, 0))
	run["bet_hp_penalty"] = current_penalty - penalty
	_apply_run_upgrades_to_player()
	_try_apply_open_wound_scar(chain_level)

func _get_bet_chain_doom_scale(chain_level: int) -> int:
	return _bet_system.get_doom_scale(chain_level)

func _get_bet_chain_reward_scale(chain_level: int) -> int:
	return _bet_system.get_reward_scale(chain_level)

func _apply_bet_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	var bet_id: String = str(result.get("id", ""))
	var won: bool = bool(result.get("won", false))
	if not won:
		return
	_apply_bet_reward_scaled(bet_id, 1)

func _reset_bet_chain() -> void:
	_run_state.bet_chain_level = 1
	_run_state.current_bet_id = ""
	_waiting_for_push_luck = false
	_reset_intermediate_choice_modifiers()
	_update_arena_visual_only()

func _reset_intermediate_choice_modifiers() -> void:
	_run_state.intermediate_double_disabled_once = false
	_run_state.intermediate_bonus_tier = 0
	_run_state.intermediate_choice_note = ""

func _consume_intermediate_choice_bonus() -> int:
	var bonus: int = _run_state.intermediate_bonus_tier
	_reset_intermediate_choice_modifiers()
	return bonus

func _apply_intermediate_loss_penalty_if_needed() -> void:
	if not _run_state.intermediate_loss_penalty_pending:
		return
	_run_state.intermediate_loss_penalty_pending = false
	if INTERMEDIATE_PROVOCA_LOSS_PENALTY_COINS > 0:
		spend_coins(INTERMEDIATE_PROVOCA_LOSS_PENALTY_COINS)

# FLOW ANCHOR hookup: see POST-BET SEQUENCE section.
func _open_intermediate_choice(bet_id: StringName) -> void:
	_run_state.intermediate_pending_bet_id = bet_id
	_set_phase(RunPhase.INTERMEDIATE_CHOICE, "open_intermediate_choice")

func _enter_mid_choice() -> void:
	if not _ensure_flow_panel("Modals/IntermediateChoiceModal", "intermediate choice"):
		return
	_waiting_for_intermediate_choice = true
	_waiting_for_push_luck = false
	_close_audience_context_line()
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()
	_emit_ui(_build_intermediate_choice_ui_payload())

# FLOW ANCHOR hookup: see POST-BET SEQUENCE section.
func _open_push_luck_choice(bet_id: StringName) -> void:
	_pending_push_luck_bet_id = bet_id
	_set_phase(RunPhase.PUSH_YOUR_LUCK, "open_push_luck_choice")

func _enter_push_your_luck() -> void:
	if not _ensure_flow_panel("Modals/PushLuckModal", "push luck choice"):
		return
	_waiting_for_push_luck = true
	_close_audience_context_line()
	set_phase(RunPhase.PREP)
	_update_arena_visual_only()
	var bet_id: StringName = _pending_push_luck_bet_id
	_pending_push_luck_bet_id = &""
	var payload: RunUiPayload = _build_push_luck_ui_payload(bet_id)
	print_debug("[FLOW] push_luck_opened :: arena=%d" % _run_state.arena_index)
	_emit_ui(payload)

func _refresh_push_luck_choice(bet_id: StringName) -> void:
	_emit_ui(_build_push_luck_ui_payload(bet_id))

func _build_intermediate_choice_ui_payload() -> RunUiPayload:
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = int(RunPhase.INTERMEDIATE_CHOICE)
	payload.title = "SCEGLI IL GESTO"
	payload.choices = ["placa", "provoca"]
	payload.show_mid_choice = true
	return payload

func _build_push_luck_ui_payload(bet_id: StringName) -> RunUiPayload:
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = int(RunPhase.PUSH_YOUR_LUCK)
	payload.show_push_your_luck = true
	payload.meta = _build_push_luck_payload(bet_id)
	payload.title = "PUSH YOUR LUCK — %s" % str(payload.meta.get("bet_name", ""))
	payload.body = "La folla vuole di più. Puoi incassare… o rilanciare."
	payload.choices = ["cashout", "condanna", "double"]
	return payload

func _emit_ui(payload: RunUiPayload) -> void:
	if payload == null:
		return
	_refresh_sanity_ui_root()
	if _sanity_ui_root == null:
		return
	if _sanity_ui_root.has_method("apply_run_ui_payload"):
		_sanity_ui_root.call("apply_run_ui_payload", payload)

func _build_phase_ui_payload(target_phase: RunPhase, title: String = "", body: String = "") -> RunUiPayload:
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = int(target_phase)
	payload.title = title
	payload.body = body
	return payload

func _build_push_luck_payload(bet_id: StringName) -> Dictionary:
	var bet_data: Dictionary = _get_bet_data(String(bet_id))
	var bet_name: String = String(bet_id)
	var condition_text: String = ""
	if not bet_data.is_empty():
		bet_name = str(bet_data.get("name", bet_id))
		condition_text = str(bet_data.get("condition", ""))
	var current_level: int = _run_state.bet_chain_level
	var next_level: int = _run_state.bet_chain_level + 1
	if LEVEL3_ENABLED:
		current_level = maxi(_run_state.escalation_level + 1, 1)
		next_level = current_level + 1
	var next_reward_tier: int = _get_bet_chain_reward_scale(next_level)
	if LEVEL3_ENABLED:
		next_reward_tier = maxi(_run_state.level3_reward_tier + 1, 1)
	var cashout_lock_reason: String = ""
	var double_lock_reason: String = ""
	if LEVEL3_ENABLED:
		cashout_lock_reason = _get_cashout_lock_reason()
		double_lock_reason = _get_double_lock_reason()
	var cashout_policy: Dictionary = _get_audience_cashout_policy()
	var cashout_enabled: bool = bool(cashout_policy.get("cashout_enabled", true))
	var cashout_modifier: float = float(cashout_policy.get("cashout_modifier", 1.0))
	var cashout_modifier_text: String = str(cashout_policy.get("cashout_modifier_text", ""))
	var audience_label: String = _get_audience_label(_run_state.audience_score)
	var audience_reason: String = _get_audience_reason(_run_state.audience_score)
	var cashout_locked: bool = cashout_lock_reason != ""
	if not cashout_enabled:
		cashout_locked = true
		cashout_lock_reason = str(cashout_policy.get("cashout_lock_reason", ""))
	var payload: Dictionary = {
		"bet_id": String(bet_id),
		"bet_name": bet_name,
		"current_level": current_level,
		"next_level": next_level,
		"condition": condition_text,
		"next_pact": _build_bet_pact_text(String(bet_id), next_reward_tier),
		"next_doom": _build_bet_doom_text(String(bet_id), next_level),
		"cashout_locked": cashout_locked,
		"cashout_lock_reason": cashout_lock_reason,
		"double_locked": double_lock_reason != "",
		"double_lock_reason": double_lock_reason,
		"choice_note": _run_state.intermediate_choice_note,
		"arena_index": _run_state.arena_index,
		"arena_target": _run_state.level3_target_arenas,
		"audience_label": audience_label,
		"audience_reason": audience_reason,
		"cashout_modifier": cashout_modifier,
		"cashout_modifier_text": cashout_modifier_text,
	}
	return payload

func _emit_sentence_banner_for_bet(bet_id: StringName) -> void:
	if not GameEvents.has_signal("sentence_banner_requested"):
		return
	var payload: Dictionary = _build_sentence_payload(bet_id)
	if payload.is_empty():
		return
	GameEvents.sentence_banner_requested.emit(payload)

func _build_sentence_payload(bet_id: StringName) -> Dictionary:
	var rule: String = _get_sentence_rule(bet_id)
	var doom: String = _get_sentence_doom(bet_id)
	if doom == "":
		doom = "SE FALLISCI: LA CICATRICE TI RESTA."
	elif not doom.begins_with("SE FALLISCI:"):
		doom = "SE FALLISCI: %s" % doom
	if _run_state.escalation_level >= 7 and doom.findn("ESCALATION") < 0:
		doom = "%s\nESCALATION: NON HAI PIÙ MARGINE." % doom
	return {
		"sentence_title": "SENTENZA",
		"sentence_rule": rule,
		"sentence_doom": doom,
		"bet_id": String(bet_id),
	}

func _get_sentence_rule(bet_id: StringName) -> String:
	if bet_id == BET_FLAWLESS_BLOOD:
		return "NO HIT"
	var bet_data: Dictionary = _get_bet_data(String(bet_id))
	var condition: String = ""
	if not bet_data.is_empty():
		condition = str(bet_data.get("condition", ""))
	var condition_lower: String = condition.to_lower()
	if condition_lower.findn("senza subire danni") >= 0:
		return "NO HIT"
	return "VINCI"

func _get_sentence_doom(bet_id: StringName) -> String:
	var doom: String = ""
	if bet_id != &"":
		if LEVEL3_ENABLED:
			doom = _get_level3_doom_short(bet_id)
		if doom == "":
			var bet_data: Dictionary = _get_bet_data(String(bet_id))
			if not bet_data.is_empty():
				doom = str(bet_data.get("doom", ""))
				if doom != "":
					var lines: PackedStringArray = doom.split("\n")
					if not lines.is_empty():
						doom = lines[0].strip_edges()
	if doom == "":
		doom = "LA CICATRICE TI RESTA."
	return doom

# -----------------------------------------------------------------------------
# POST-BET SEQUENCE
# - Triggered when bet is sealed/committed
# - Waits arena_message_queue_completed OR fallback timer
# - Then opens intermediate choice
# -----------------------------------------------------------------------------
func _queue_push_luck_choice(bet_id: StringName) -> void:
	_run_state.post_bet_pending_bet_id = bet_id
	_set_phase(RunPhase.POST_BET_MESSAGES, "queue_post_bet_messages")

func _enter_first_reaction() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.POST_BET_MESSAGES, "PRIMA REAZIONE", "La folla osserva la tua scelta."))
	if _sanity_ui_root == null:
		_open_intermediate_choice(_run_state.post_bet_pending_bet_id)
		return
	if not _sanity_ui_root.has_signal("arena_message_queue_completed"):
		_open_intermediate_choice(_run_state.post_bet_pending_bet_id)
		return
	if _sanity_ui_root.has_method("is_post_bet_queue_running"):
		var queue_running: bool = bool(_sanity_ui_root.call("is_post_bet_queue_running"))
		if not queue_running:
			_open_intermediate_choice(_run_state.post_bet_pending_bet_id)
			return
	_run_state.post_bet_sequence_id += 1
	var sequence_id: int = _run_state.post_bet_sequence_id
	call_deferred("_force_post_bet_choice_fallback", sequence_id)

func _on_arena_message_queue_completed() -> void:
	if _run_state.post_bet_pending_bet_id == &"":
		return
	var bet_id: StringName = _run_state.post_bet_pending_bet_id
	_run_state.post_bet_pending_bet_id = &""
	_open_intermediate_choice(bet_id)

func _force_post_bet_choice_fallback(sequence_id: int) -> void:
	await get_tree().create_timer(POST_BET_QUEUE_FALLBACK_SECONDS).timeout
	if sequence_id != _run_state.post_bet_sequence_id:
		return
	if _run_state.post_bet_pending_bet_id == &"":
		return
	var bet_id: StringName = _run_state.post_bet_pending_bet_id
	_run_state.post_bet_pending_bet_id = &""
	_open_intermediate_choice(bet_id)

func _get_cashout_lock_reason() -> String:
	if _run_state.arena_index >= _run_state.level3_target_arenas and _run_state.level3_target_arenas > 0:
		return ""
	if _run_state.special_arena_cashout_lock_reason != "":
		return _run_state.special_arena_cashout_lock_reason
	if _run_state.cashout_lock_remaining > 0:
		return "Decima di Sangue: incasso bloccato (%d arena)" % _run_state.cashout_lock_remaining
	if _run_state.arena_index < _run_state.level3_min_cashout_arenas:
		return "Incasso disponibile dopo Arena %d" % _run_state.level3_min_cashout_arenas
	return ""

func _get_double_lock_reason() -> String:
	if _run_state.intermediate_double_disabled_once:
		return "Hai placato la folla: raddoppio bloccato."
	if _run_state.arena_index >= _run_state.level3_target_arenas and _run_state.level3_target_arenas > 0:
		return "Fine run: incassa ora"
	return ""

func _update_audience_after_arena(result: ArenaResult) -> void:
	var delta: int = 0
	if result.won:
		if result.took_damage:
			delta = 1
		else:
			delta = 2
	else:
		delta = -2
	if delta == 0:
		return
	_run_state.audience_score = clampi(_run_state.audience_score + delta, AUDIENCE_SCORE_MIN, AUDIENCE_SCORE_MAX)
	_check_audience_condanne()
	if _run_state.audience_score <= AUDIENCE_CASHOUT_DISABLE_THRESHOLD:
		_run_state.forced_next_pact_archetype = ARCH_EGO

func _check_audience_condanne() -> void:
	if _run_state.is_hunted_by_crowd or _run_state.audience_score >= AUDIENCE_ATTENTION_THRESHOLD:
		_register_condanna(CONDANNA_VISTO_DAL_PUBBLICO)
		if _run_state.seen_by_crowd_before_run:
			_register_condanna(CONDANNA_IL_TUO_NOME)

func _get_audience_label(score: int) -> String:
	if score <= AUDIENCE_CASHOUT_DISABLE_THRESHOLD:
		return "FOLLA IN FURIA"
	if score <= -1:
		return "FOLLA OSTILE"
	if score == 0:
		return "FOLLA TIEPIDA"
	if score <= 2:
		return "FOLLA IN ASCOLTO"
	return "FOLLA IN DELIRIO"

func _get_audience_reason(score: int) -> String:
	if score <= -1:
		return _pick_audience_phrase("FURY")
	if score <= 2:
		return _pick_audience_phrase("COLD")
	return _pick_audience_phrase("DELIRIUM")

func _pick_audience_phrase(mood: String) -> String:
	var phrases: Array = AUDIENCE_PHRASES.get(mood, []) as Array
	if phrases.is_empty():
		return ""
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = _run_state.run_seed + _run_state.arena_index * 37 + _run_state.audience_score * 13
	var pick_idx: int = rng.randi_range(0, phrases.size() - 1)
	return str(phrases[pick_idx])

func _get_audience_context_mood(score: int) -> StringName:
	if score <= -1:
		return AUDIENCE_MOOD_FURY
	if score <= 2:
		return AUDIENCE_MOOD_COLD
	return AUDIENCE_MOOD_DELIRIUM

func _pick_audience_context_line(context: StringName) -> String:
	var context_bucket: Dictionary = AUDIENCE_CONTEXT_PHRASES.get(context, {}) as Dictionary
	if context_bucket.is_empty():
		return ""
	var mood: StringName = _get_audience_context_mood(_run_state.audience_score)
	var mood_bucket: Array = context_bucket.get(mood, []) as Array
	var combined_bucket: Array = mood_bucket
	if _is_unlocked(CONDANNA_NON_DOVEVO_PROVARCI):
		var harsh_bucket: Dictionary = AUDIENCE_CONTEXT_PHRASES_HARSH.get(context, {}) as Dictionary
		var harsh_lines: Array = harsh_bucket.get(mood, []) as Array
		if not harsh_lines.is_empty():
			combined_bucket = mood_bucket.duplicate()
			combined_bucket.append_array(harsh_lines)
	if combined_bucket.is_empty():
		return ""
	var context_seed: int = int(String(context).hash())
	_level3_rng.seed = _run_state.run_seed + _run_state.arena_index * 41 + _run_state.audience_score * 19 + context_seed
	var pick_idx: int = _level3_rng.randi_range(0, combined_bucket.size() - 1)
	return str(combined_bucket[pick_idx])

func _emit_audience_context_line(context: StringName) -> void:
	if not GameEvents.has_signal("audience_context_line_emitted"):
		return
	var line: String = _pick_audience_context_line(context)
	if line == "":
		return
	_run_state.last_audience_context_line = line
	GameEvents.audience_context_line_emitted.emit(line)

func _close_audience_context_line() -> void:
	if not GameEvents.has_signal("audience_context_line_emitted"):
		return
	GameEvents.audience_context_line_emitted.emit("")

func _get_audience_cashout_modifier() -> float:
	if _run_state.audience_score <= AUDIENCE_CASHOUT_PENALTY_THRESHOLD:
		return AUDIENCE_CASHOUT_PENALTY_MULTIPLIER
	return 1.0

func _get_audience_cashout_policy() -> Dictionary:
	var score: int = _run_state.audience_score
	var cashout_enabled: bool = score > AUDIENCE_CASHOUT_DISABLE_THRESHOLD
	var cashout_modifier: float = 1.0
	var cashout_modifier_text: String = ""
	var cashout_lock_reason: String = ""
	if not cashout_enabled:
		cashout_lock_reason = "La folla non ti lascia incassare."
	elif score <= AUDIENCE_CASHOUT_PENALTY_THRESHOLD:
		cashout_modifier = AUDIENCE_CASHOUT_PENALTY_MULTIPLIER
		cashout_modifier_text = "Incasso penalizzato: x%.1f" % cashout_modifier
	return {
		"cashout_enabled": cashout_enabled,
		"cashout_lock_reason": cashout_lock_reason,
		"cashout_modifier": cashout_modifier,
		"cashout_modifier_text": cashout_modifier_text,
	}

func _apply_bet_reward_scaled(bet_id: String, chain_level: int) -> void:
	var reward_scale: int = _bet_system.get_reward_scale(chain_level)
	match bet_id:
		BET_COWARD:
			if bet_coward_coin_reward > 0:
				add_coins(bet_coward_coin_reward * reward_scale)
		BET_PURE_BLOOD:
			_apply_pure_bet_reward_scaled(reward_scale)
		BET_DOUBLE_OR_DIE:
			_apply_double_or_die_reward_scaled(reward_scale)
		_:
			pass

func _apply_pure_bet_reward_scaled(scale: int) -> void:
	run = _bet_system.apply_pure_blood_reward(
		run,
		scale,
		bet_pure_hp_bonus,
		bet_pure_light_bonus,
		bet_pure_heavy_bonus
	)
	_apply_run_upgrades_to_player()

func _build_bet_pact_text(bet_id: String, chain_level: int) -> String:
	return _bet_system.build_pact_text(
		LEVEL3_ENABLED,
		bet_id,
		chain_level,
		_get_bet_data(bet_id),
		BET_COWARD,
		BET_PURE_BLOOD,
		BET_DOUBLE_OR_DIE,
		bet_coward_coin_reward,
		bet_pure_hp_bonus,
		bet_pure_light_bonus,
		bet_pure_heavy_bonus
	)

func _build_bet_doom_text(bet_id: String, chain_level: int) -> String:
	return _bet_system.build_doom_text(
		LEVEL3_ENABLED,
		bet_id,
		chain_level,
		_get_bet_data(bet_id),
		BET_COWARD,
		BET_PURE_BLOOD,
		BET_DOUBLE_OR_DIE
	)

func _get_bet_data(bet_id: String) -> Dictionary:
	if LEVEL3_ENABLED:
		for bet_value: Dictionary in LEVEL3_BETS:
			var bet: Dictionary = bet_value as Dictionary
			if str(bet.get("id", "")) == bet_id:
				return bet
	return {}

func _get_level3_bet_name(bet_id: StringName) -> String:
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			return str(bet.get("name", String(bet_id)))
	return String(bet_id)

func _get_level3_doom_short(bet_id: StringName) -> String:
	var bet_data: Dictionary = _get_bet_data(String(bet_id))
	if bet_data.is_empty():
		return ""
	var doom_text: String = str(bet_data.get("doom", ""))
	if doom_text == "":
		return ""
	var lines: PackedStringArray = doom_text.split("\n")
	for line: String in lines:
		var trimmed: String = line.strip_edges()
		if trimmed.begins_with("Effetto:"):
			return trimmed.replace("Effetto:", "").strip_edges()
	if not lines.is_empty():
		return lines[0].strip_edges()
	return doom_text

func _apply_double_or_die_reward_scaled(scale: int) -> void:
	var p: Node = _resolve_player()
	if p == null:
		return
	if not p.has_method("get_damage_values"):
		return
	var damage_values: Array = p.call("get_damage_values") as Array
	if damage_values.size() < 2:
		return
	var light_bonus: int = int(damage_values[0])
	var heavy_bonus: int = int(damage_values[1])
	if light_bonus <= 0 and heavy_bonus <= 0:
		return
	run = _bet_system.apply_double_or_die_reward(run, scale, light_bonus, heavy_bonus)
	_apply_run_upgrades_to_player()

func retry_current_bet() -> void:
	if _is_game_over:
		return
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_reset_bet_chain()
	set_phase(RunPhase.PREP)
	GameEvents.set_gameplay_enabled(false)
	run["arena_index"] = maxi(int(run.get("arena_index", 0)) - 1, 0)
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_clear_enemies()
	_reset_or_respawn_player_full()
	_open_bet_ui(false)

func _force_game_over_if_dead() -> bool:
	var p: Node = get_tree().get_first_node_in_group("player")
	if p == null:
		return false
	var current_health: int = _get_player_health_value(p)
	if current_health <= 0 and current_health != -1:
		_enter_end_run("death")
		return true
	return false

func _get_player_health_value(p: Node) -> int:
	if p.has_method("get_current_health"):
		return int(p.call("get_current_health"))
	if p.has_meta("current_health"):
		return int(p.get_meta("current_health"))
	if p.has_method("get_health"):
		var h: Array = p.call("get_health")
		if h.size() > 0:
			return int(h[0])
	return -1

func _get_player_max_health_value(p: Node) -> int:
	if p == null:
		return -1
	if p.has_method("get_health"):
		var h: Array = p.call("get_health")
		if h.size() > 1:
			return int(h[1])
	if p.has_meta("max_health"):
		return int(p.get_meta("max_health"))
	return -1

func _enter_end_run(reason: String) -> void:
	if _is_game_over:
		return
	var trimmed_reason: String = reason.strip_edges()
	if trimmed_reason != "":
		_run_state.run_end_public_reason = trimmed_reason
	if trimmed_reason == "death":
		_register_run_end("PLAYER_DIED")
	elif trimmed_reason != "":
		_register_run_end(trimmed_reason)
	_enter_game_over()

func _enter_game_over() -> void:
	if _is_game_over:
		return
	_emit_ui(_build_phase_ui_payload(RunPhase.GAME_OVER, "FINE CORSA", "Il verdetto è stato inciso."))
	_refresh_sanity_ui_root()
	if _sanity_ui_root == null or _sanity_ui_root.get_node_or_null("Modals/GameOverModal") == null:
		push_error("SANITY FAIL FLOW: ending panel missing")
		get_tree().paused = true
		return
	_set_phase(RunPhase.GAME_OVER, "enter_game_over")
	var reason_label: String = "other"
	if _run_state.run_end_reason == "CASH_OUT":
		reason_label = "cashout"
	elif _run_state.run_end_reason != "":
		reason_label = "failed"
	print_debug("[FLOW] ending_entered :: reason=%s, arena=%d" % [reason_label, _run_state.arena_index])
	_save_system.clear_run()
	_is_game_over = true
	_run_state.provoke_armed = false
	_run_state.run_is_over = true
	var is_loss: bool = _run_state.run_end_reason != "CASH_OUT"
	var first_run_completed: bool = SaveManager.has_unlocked(CONDANNA_RICORDATO)
	_register_condanna(CONDANNA_RICORDATO)
	if is_loss:
		if not first_run_completed:
			_register_condanna(CONDANNA_E_FINITA_COSI)
		if _run_state.arena_index >= 2:
			_register_condanna(CONDANNA_NON_ABBASTANZA)
		if _run_state.bets_history.size() > 0:
			_register_condanna(CONDANNA_NON_E_COLPA_LORO)
		if _run_state.risky_choice_made_recently:
			_register_condanna(CONDANNA_TROPPO_TARDI)
		if _run_state.last_signed_pact_id != &"":
			_register_condanna(CONDANNA_SAPEVO_COSA_STAVO_FACENDO)
		if _run_state.bets_history.size() > 0:
			_register_condanna(CONDANNA_ERA_IL_PREZZO)
	if _run_state.run_end_reason != "CASH_OUT" and _run_state.last_action_was_rilancio:
		_register_condanna(CONDANNA_NON_DOVEVO_PROVARCI)
	_waiting_for_bet = false
	set_phase(RunPhase.GAME_OVER)
	_update_arena_visual_only()
	_emit_run_finale()
	_emit_run_ended()
	_emit_run_failed()

func _emit_run_failed() -> void:
	if _run_failed_emitted:
		return
	_run_failed_emitted = true
	_emit_audience_context_line(AUDIENCE_CONTEXT_RUN_LOSS)
	GameEvents.run_failed.emit()
	GameEvents.set_gameplay_enabled(false)

func _emit_run_ended() -> void:
	if _run_ended_emitted:
		return
	_run_ended_emitted = true
	if not GameEvents.has_signal("run_ended"):
		return
	var emit_reason: String = _run_state.run_end_public_reason
	if emit_reason == "":
		emit_reason = _run_state.run_end_reason
	if emit_reason == "":
		emit_reason = "unknown"
	if _should_emit_registry_silence():
		GameEvents.run_ended.emit(emit_reason, {})
		return
	var finale: Dictionary = _select_run_finale()
	var summary: Dictionary = _build_run_summary(finale)
	GameEvents.run_ended.emit(emit_reason, summary)
	_emit_register_annotation_from_run_end(emit_reason)

func _register_run_end(reason: String) -> void:
	if reason == "":
		return
	if _run_state.run_end_reason == "":
		_run_state.run_end_reason = reason

func _emit_run_finale() -> void:
	if _run_state.run_finale_emitted:
		return
	_run_state.run_finale_emitted = true
	if _should_emit_registry_silence():
		return
	var finale: Dictionary = _select_run_finale()
	if finale.has("ending_id"):
		print("Run ending chosen:", str(finale.get("ending_id", "")), " seed=", _run_state.run_seed)
	GameEvents.run_finale_selected.emit(finale)
	_emit_run_log(finale)
	_export_run_summary(finale)

func _should_emit_registry_silence() -> bool:
	if _run_state.registry_silence_evaluated:
		return _run_state.registry_silence_active
	_run_state.registry_silence_evaluated = true
	_run_state.registry_silence_active = false
	if _register_state.flow_phase != RegisterState.FLOW_PHASE_SOSPENSIONE:
		return false
	var silence_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	silence_rng.randomize()
	_run_state.registry_silence_active = silence_rng.randi_range(1, REGISTRY_SILENCE_ROLL_MAX) == 1
	return _run_state.registry_silence_active

func _emit_run_log(finale: Dictionary) -> void:
	if not GameEvents.has_signal("run_log_ready"):
		return
	var log_text: String = _build_run_log(finale)
	GameEvents.run_log_ready.emit(log_text)

func _build_run_log(finale: Dictionary) -> String:
	var ending_id: String = str(finale.get("ending_id", ""))
	var title: String = str(finale.get("title", ""))
	var arena_count: int = _run_state.arena_index
	var cashouts: int = _run_state.level3_cashouts
	var doubles: int = _run_state.level3_doubles
	var max_escalation: int = _run_state.level3_max_escalation
	var scar_count: int = _run_state.scars_history.size()
	var special_arena: String = ""
	if _run_state.special_arena_id != &"":
		special_arena = _get_special_arena_title(_run_state.special_arena_id)
	var lines: Array[String] = []
	lines.append("Seed: %d" % _run_state.run_seed)
	if title != "":
		lines.append("Ending: %s (%s)" % [title, ending_id])
	else:
		lines.append("Ending: %s" % ending_id)
	lines.append("Arene: %d | Cashout: %d | Double: %d | Escalation max: %d" % [arena_count, cashouts, doubles, max_escalation])
	lines.append("Cicatrici: %d" % scar_count)
	if special_arena != "":
		lines.append("Arena speciale: %s" % special_arena)
	return "\n".join(lines)

func _export_run_summary(finale: Dictionary) -> void:
	var summary: Dictionary = _build_run_summary(finale)
	var json_text: String = JSON.stringify(summary, "\t")
	var file_path: String = "user://run_summary_%d.json" % _run_state.run_seed
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		DisplayServer.clipboard_set(json_text)
		return
	file.store_string(json_text)
	file.close()

func _build_run_summary(finale: Dictionary) -> Dictionary:
	var duration_seconds: int = 0
	if _run_state.run_start_time_msec > 0:
		duration_seconds = int(float(Time.get_ticks_msec() - _run_state.run_start_time_msec) / 1000.0)
	var bets_history: Array[String] = []
	for bet_id: StringName in _run_state.bets_history:
		bets_history.append(String(bet_id))
	var pacts_log: Array[Dictionary] = []
	for entry: PactLogEntry in _run_state.pacts_log:
		pacts_log.append(entry.to_dict())
	var scars_history: Array[String] = []
	for scar_id: StringName in _run_state.scars_history:
		scars_history.append(String(scar_id))
	var enemy_profiles: Array[String] = []
	for profile_id: StringName in _run_state.enemy_profiles:
		enemy_profiles.append(String(profile_id))
	var ending_id: String = str(finale.get("ending_id", ""))
	return {
		"seed": _run_state.run_seed,
		"duration_seconds": duration_seconds,
		"arenas_cleared": _run_state.arenas_cleared,
		"bets_history": bets_history,
		"pacts_log": pacts_log,
		"max_escalation": _run_state.max_escalation,
		"scars_history": scars_history,
		"scars_count": _run_state.scars_history.size(),
		"is_hunted_by_crowd": _run_state.is_hunted_by_crowd,
		"ending_id": ending_id,
		"cashouts": _run_state.cashouts,
		"doubles": _run_state.doubles,
		"enemy_profiles": enemy_profiles,
	}

func _select_run_finale() -> Dictionary:
	var scars_copy: Array = _scars.duplicate(true)
	var scar_count: int = _run_state.scars_history.size()
	var ending_id: StringName = _run_state.forced_ending_id
	var run_completed: bool = _run_state.level3_target_arenas > 0 and _run_state.arena_index >= _run_state.level3_target_arenas
	if ending_id == &"":
		if _run_state.run_end_reason == "DOUBLE_OR_DIE":
			ending_id = &"THE_FOOL"
		else:
			var physical_scars: int = _count_scars_with_tag(&"physical")
			var many_cashouts: bool = _run_state.level3_cashouts >= 3 and _run_state.level3_doubles <= 0
			var high_escalation: bool = _run_state.level3_max_escalation >= 3
			var debt_marked: bool = _has_scar(SCAR_DEBT_BRAND)
			if run_completed and physical_scars >= 2:
				ending_id = &"THE_MARTYR"
			elif debt_marked or high_escalation:
				ending_id = &"THE_DEBTOR"
			elif many_cashouts:
				ending_id = &"THE_CROWD_PET"
			elif scar_count <= 0:
				ending_id = &"THE_SURVIVOR"
			elif scar_count == 1:
				ending_id = &"THE_MARKED"
			else:
				ending_id = &"THE_BROKEN"

	var title: String = "IL SOPRAVVISSUTO"
	var final_report: FinalReport = _build_final_report(ending_id)
	var text: String = final_report.to_text()

	match ending_id:
		&"THE_FOOL":
			title = "LO STOLTO"
		&"THE_MARKED":
			title = "IL SEGNATO"
		&"THE_BROKEN":
			title = "IL SPEZZATO"
		&"THE_SURVIVOR":
			title = "IL SOPRAVVISSUTO"
		&"THE_DEBTOR":
			title = "IL DEBITORE"
		&"THE_CROWD_PET":
			title = "IL BENEAMATO"
		&"THE_MARTYR":
			title = "IL MARTIRE"

	var bet_names: Array[String] = []
	for bet_id: StringName in _run_state.level3_bets_used:
		bet_names.append(_get_bet_display_name(String(bet_id)))
	var pacts_signed: Array[StringName] = _run_state.bets_history.duplicate()
	var outcome: StringName = &"LOSS"
	if _run_state.run_end_reason == "CASH_OUT":
		outcome = &"CASHOUT"
	elif run_completed:
		outcome = &"WIN"
	var stats_payload: Dictionary = {
		"cashouts": _run_state.level3_cashouts,
		"doubles": _run_state.level3_doubles,
		"bets": bet_names,
		"max_escalation": _run_state.level3_max_escalation,
		"arena_target": _run_state.level3_target_arenas,
		"arena_count": _run_state.arena_index,
	}

	return {
		"title": title,
		"text": text,
		"final_report": final_report.to_dict(),
		"scars": scars_copy,
		"ending_id": String(ending_id),
		"seed": _run_state.run_seed,
		"stats": stats_payload,
		"pacts_signed": pacts_signed,
		"condanne_this_run": _run_state.condanne_this_run.duplicate(),
		"last_crowd_line": _run_state.last_audience_context_line,
		"outcome": outcome,
	}


func _build_final_report(ending_id: StringName) -> FinalReport:
	var report: FinalReport = FinalReport.new()
	var is_anomalous: bool = _register_state.flow_phase != RegisterState.FLOW_PHASE_STABLE
	report.is_anomalous = is_anomalous
	report.register_flow_phase = String(_register_state.flow_phase)

	if _run_state.run_end_reason == "CASH_OUT":
		report.opening = "Il soggetto ha interrotto il ciclo prima della definizione."
	elif _run_state.run_is_over:
		report.opening = "Il soggetto ha completato il ciclo operativo."
	else:
		report.opening = "Il soggetto presenta un profilo registrabile."

	if _run_state.bets_history.size() > 0:
		report.patterns.append("accettazione ricorrente di condizioni irreversibili")
	if _run_state.refuse_cashout_count_this_run > 0:
		report.patterns.append("rifiuto della chiusura quando disponibile")
	if _run_state.scars_history.size() > 0:
		report.patterns.append("accumulo di Scar persistenti su più passaggi")
	if _run_state.max_escalation >= 3:
		report.patterns.append("reiterazione oltre l'utile con esposizione crescente")
	if report.patterns.size() < 2:
		report.patterns.append("sacrificio di opzioni future registrato")

	if is_anomalous:
		match _register_state.flow_phase:
			RegisterState.FLOW_PHASE_ATTRITO:
				report.fracture = "Il profilo osservato eccede le soglie operative previste; classificazione mantenuta coerente."
				report.final_state = _get_final_state_label(ending_id)
			RegisterState.FLOW_PHASE_DERIVA:
				report.fracture = "Il profilo osservato non rientra pienamente nelle classi disponibili. Classificazione coerente, ma non conclusiva."
				report.final_state = "classificazione non conclusiva"
			RegisterState.FLOW_PHASE_MEMORIA:
				report.fracture = "Precedente rilevato in memoria storica. Applicabilità non determinabile; classificazione incompleta."
				report.final_state = "classificazione incompleta"
			RegisterState.FLOW_PHASE_SOSPENSIONE:
				report.fracture = "Stato registrato con parametri attivi. Chiusura finale non applicabile."
				report.final_state = "registrato in sospensione"
			_:
				report.final_state = _get_final_state_label(ending_id)
	else:
		report.final_state = _get_final_state_label(ending_id)

	return report

func _get_final_state_label(ending_id: StringName) -> String:
	match ending_id:
		&"THE_FOOL":
			return "interruzione immediata"
		&"THE_MARKED":
			return "segnato"
		&"THE_BROKEN":
			return "compromesso"
		&"THE_DEBTOR":
			return "in debito attivo"
		&"THE_CROWD_PET":
			return "conforme al pubblico"
		&"THE_MARTYR":
			return "consumo completo"
		_:
			return "non definito"

func _has_used_bet(bet_id: StringName) -> bool:
	for used_bet: StringName in _run_state.level3_bets_used:
		if used_bet == bet_id:
			return true
	return false

func _count_scars_with_tag(tag: StringName) -> int:
	var count: int = 0
	for scar_value: Dictionary in _scars:
		var tags: Array = scar_value.get("tags", []) as Array
		for tag_value in tags:
			if StringName(tag_value) == tag:
				count += 1
				break
	return count

func get_available_level3_pacts() -> Array[StringName]:
	var available: Array[StringName] = []
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: StringName = StringName(str(bet.get("id", "")))
		if bet_id == &"":
			continue
		if _is_level3_bet_unlocked(bet_id):
			available.append(bet_id)
	return available

func get_level3_pact_title(pact_id: StringName) -> String:
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: StringName = StringName(str(bet.get("id", "")))
		if bet_id == pact_id:
			return str(bet.get("name", ""))
	return str(pact_id)

func get_pact_reveal_line(pact_id: StringName) -> String:
	if LYING_PACT_REVEALS.has(pact_id):
		return str(LYING_PACT_REVEALS.get(pact_id, ""))
	return ""

func get_available_arena_themes() -> Array[StringName]:
	return _get_available_arena_theme_ids()

func is_harsh_crowd_unlocked() -> bool:
	return _is_unlocked(CONDANNA_VISTO_DAL_PUBBLICO)

func get_crowd_line_count_base() -> int:
	return _count_crowd_lines(AUDIENCE_CONTEXT_PHRASES)

func get_crowd_line_count_harsh() -> int:
	return _count_crowd_lines(AUDIENCE_CONTEXT_PHRASES_HARSH)

func _count_crowd_lines(source: Dictionary) -> int:
	var count: int = 0
	for context_value in source.values():
		var mood_bucket: Dictionary = context_value as Dictionary
		for lines_value in mood_bucket.values():
			var lines: Array = lines_value as Array
			count += lines.size()
	return count

func get_arena() -> Node:
	return _arena

func get_arena_index() -> int:
	return int(run.get("arena_index", 0))

func is_live() -> bool:
	return phase == RunPhase.LIVE

func is_level3_mode() -> bool:
	return LEVEL3_ENABLED

func is_visual_only() -> bool:
	if LEVEL3_ENABLED:
		return true
	return _resolving_arena or _waiting_for_bet or _waiting_for_push_luck or _waiting_for_intermediate_choice or _run_state.run_is_over or _is_game_over

func _set_phase(next: RunPhase, reason: String) -> void:
	if _phase == next:
		return
	_phase = next
	if not _run_enter_phase(next):
		push_error("RunManager: missing enter handler for phase %s" % [str(next)])
	if OS.is_debug_build() and reason != "":
		print_debug("RunManager flow phase:", int(next), "-", reason)

func _run_enter_phase(next: RunPhase) -> bool:
	match next:
		RunPhase.MAIN_MENU:
			_enter_main_menu()
			return true
		RunPhase.RUN_INIT:
			_enter_intro()
			return true
		RunPhase.BET_PRESENT:
			_enter_bet_present()
			return true
		RunPhase.BET_COMMITTED:
			_enter_bet_committed()
			return true
		RunPhase.POST_BET_MESSAGES:
			_enter_first_reaction()
			return true
		RunPhase.INTERMEDIATE_CHOICE:
			_enter_mid_choice()
			return true
		RunPhase.PUSH_YOUR_LUCK:
			_enter_push_your_luck()
			return true
		RunPhase.RESOLUTION:
			_enter_resolution()
			return true
		RunPhase.NEXT_BET:
			_enter_next_bet()
			return true
		RunPhase.GAME_OVER:
			_enter_end_run_phase()
			return true
		_:
			return false

func _enter_main_menu() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.MAIN_MENU, "MAIN MENU"))

func _enter_intro() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.RUN_INIT, "INIZIO RUN"))

func _enter_bet_present() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.BET_PRESENT, "PATTO PROPOSTO"))

func _enter_bet_committed() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.BET_COMMITTED, "PATTO SIGILLATO"))

func _enter_next_bet() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.NEXT_BET, "PROSSIMO PATTO"))

func _enter_end_run_phase() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.GAME_OVER, "FINE RUN"))

func set_phase(p: Variant) -> void:
	# Supporta sia RunPhase che int (es. valori serializzati / segnali legacy).
	if typeof(p) == TYPE_INT:
		phase = (p as int) as RunPhase
	else:
		phase = p as RunPhase
	GameEvents.run_phase_changed.emit(int(phase))
	_apply_phase()

func _apply_phase() -> void:
	if GameEvents.has_method("set_gameplay_enabled"):
		var gameplay_enabled: bool = phase == RunPhase.LIVE and not is_visual_only()
		GameEvents.set_gameplay_enabled(gameplay_enabled)

func _update_arena_visual_only() -> void:
	var desired: bool = is_visual_only()
	if desired == _arena_visual_only:
		return
	_arena_visual_only = desired
	if _arena == null or not is_instance_valid(_arena):
		_arena = get_node_or_null(arena_path)
	if _arena != null and _arena.has_method("set_visual_only"):
		_arena.call("set_visual_only", _arena_visual_only)
	_apply_phase()

func _position_player_after_respawn() -> void:
	if _player == null or not (_player is Node2D):
		return
	var spawn_pos: Vector2 = _get_spawn_position()
	(_player as Node2D).global_position = spawn_pos
	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam == null:
		var player_cam: Node = _player.find_child("Camera2D", true, false)
		if player_cam and player_cam is Camera2D:
			cam = player_cam
			cam.make_current()
	if cam and cam.has_method("make_current"):
		cam.make_current()
	if cam:
		cam.global_position = (_player as Node2D).global_position

func _reset_upgrades() -> void:
	run["upgrades"] = {
		"hp_bonus": 0,
		"light_bonus": 0,
		"heavy_bonus": 0,
	}

func _reset_upgrade_costs() -> void:
	run["upgrade_costs"] = {
		"hp": upgrade_hp_token_cost_start,
		"light": upgrade_light_token_cost_start,
		"heavy": upgrade_heavy_token_cost_start,
	}

func _reset_progression() -> void:
	# reset XP/level per run (puoi cambiare in "persistente" più avanti)
	run["level"] = starting_level
	run["xp"] = 0
	run["upgrade_tokens"] = starting_tokens
	_recompute_difficulty_tier(true)

func _register_condanna(id: StringName) -> void:
	if id == &"":
		return
	if not _run_state.condanne_this_run.has(id):
		_run_state.condanne_this_run.append(id)
	if SaveManager.has_unlocked(id):
		return
	SaveManager.set_unlocked(id, true)
	if GameEvents.has_signal("condanna_registered"):
		GameEvents.condanna_registered.emit(id)

func _is_unlocked(id: StringName) -> bool:
	return SaveManager.has_unlocked(id)

func _reset_scars() -> void:
	_scars = []
	_run_state.scars = []
	_run_state.scars_history = []
	_run_state.max_hp_modifier = 0
	_run_state.is_hunted_by_crowd = false
	_run_state.scar_heal_multiplier = 1.0
	_run_state.scar_dodge_cooldown_multiplier = 1.0
	_run_state.scar_dodge_speed_multiplier = 1.0
	_run_state.scar_max_hp_penalty = 0
	_emit_scars_updated()

func _emit_scars_updated() -> void:
	var scars_copy: Array = _scars.duplicate(true)
	GameEvents.scars_updated.emit(scars_copy)

func _has_scar(scar_id: StringName) -> bool:
	for scar_name: StringName in _run_state.scars_history:
		if scar_name == scar_id:
			return true
	return false

func _add_scar(scar: Dictionary) -> void:
	var scar_id: StringName = StringName(str(scar.get("id", "")))
	if scar_id == &"":
		return
	if _has_scar(scar_id):
		return
	_scars.append(scar)
	_run_state.scars_history.append(scar_id)
	var trigger: StringName = StringName(str(scar.get("trigger", SCAR_TRIGGER_IRREVERSIBLE_BET)))
	_register_run_scar(scar_id, String(str(scar.get("origin", ""))), trigger)
	_recompute_scar_modifiers()
	_recompute_scar_synergies()
	_emit_scars_updated()
	_emit_run_debug_state()
	if GameEvents.has_signal("scar_applied"):
		GameEvents.scar_applied.emit(scar)

func _emit_register_annotation_from_scar(scar_id: StringName) -> void:
	if not GameEvents.has_signal("register_annotation"):
		return
	var payload: Dictionary = _register_state.record_scar_annotation(scar_id, _run_state.arena_index, _build_register_metrics())
	if payload.is_empty():
		return
	GameEvents.register_annotation.emit(payload)

func _emit_register_annotation_from_run_end(reason: String) -> void:
	if not GameEvents.has_signal("register_annotation"):
		return
	var payload: Dictionary = _register_state.record_run_end_annotation(reason, _run_state.scars.size(), _build_register_metrics())
	if payload.is_empty():
		return
	GameEvents.register_annotation.emit(payload)

func _build_register_metrics() -> Dictionary:
	var irreversible_scar_count: int = 0
	var risk_threshold_scar_count: int = 0
	for scar_entry: Scar in _run_state.scars:
		if scar_entry.trigger == SCAR_TRIGGER_IRREVERSIBLE_BET:
			irreversible_scar_count += 1
		elif scar_entry.trigger == SCAR_TRIGGER_RISK_THRESHOLD:
			risk_threshold_scar_count += 1
	return {
		"irreversible_scar_count": irreversible_scar_count,
		"risk_threshold_scar_count": risk_threshold_scar_count,
		"refused_closure_count": _run_state.refuse_cashout_count_this_run,
		"scar_count": _run_state.scars.size(),
		"max_escalation": _run_state.max_escalation,
	}

func _build_run_scar(scar_id: StringName, origin: String, trigger: StringName) -> Scar:
	var scar: Scar = Scar.new()
	scar.id = scar_id
	scar.origin = origin
	scar.trigger = trigger
	scar.arena_index = _run_state.arena_index
	scar.escalation_level = _run_state.escalation_level
	return scar

func _register_run_scar(scar_id: StringName, origin: String, trigger: StringName) -> void:
	if scar_id == &"":
		return
	for scar_entry: Scar in _run_state.scars:
		if scar_entry.id == scar_id:
			return
	_run_state.scars.append(_build_run_scar(scar_id, origin, trigger))
	_run_state.last_scar_arena_index = _run_state.arena_index
	_emit_register_annotation_from_scar(scar_id)

func _can_register_trigger_scar() -> bool:
	var arenas_since_last: int = _run_state.arena_index - _run_state.last_scar_arena_index
	return arenas_since_last >= SCAR_MIN_ARENA_INTERVAL

func _try_register_irreversible_bet_scar(bet_id: StringName) -> void:
	if _run_state.irreversible_bet_scar_registered:
		return
	if not IRREVERSIBLE_BET_IDS.has(bet_id):
		return
	if not _can_register_trigger_scar():
		return
	_register_run_scar(SCAR_EVENT_IRREVERSIBLE_PACT, "Scommessa irreversibile: %s" % String(bet_id), SCAR_TRIGGER_IRREVERSIBLE_BET)
	_run_state.irreversible_bet_scar_registered = true

func _try_register_refused_closure_scar() -> void:
	if _run_state.refused_closure_scar_registered:
		return
	if _run_state.refuse_cashout_count_this_run < SCAR_REFUSE_CASHOUT_THRESHOLD:
		return
	if not _can_register_trigger_scar():
		return
	_register_run_scar(SCAR_EVENT_REFUSED_CLOSURE, "Rifiuto chiusura ripetuto (%d)" % _run_state.refuse_cashout_count_this_run, SCAR_TRIGGER_REFUSED_CLOSURE)
	_run_state.refused_closure_scar_registered = true

func _try_register_risk_threshold_scar() -> void:
	if _run_state.risk_threshold_scar_registered:
		return
	if _run_state.escalation_level < SCAR_RISK_ESCALATION_THRESHOLD:
		return
	if not _can_register_trigger_scar():
		return
	_register_run_scar(SCAR_EVENT_RISK_THRESHOLD, "Soglia rischio raggiunta (%d)" % _run_state.escalation_level, SCAR_TRIGGER_RISK_THRESHOLD)
	_run_state.risk_threshold_scar_registered = true

func _recompute_scar_modifiers() -> void:
	var modifiers: Dictionary = _scar_system.compute_modifiers(
		_scars,
		SCAR_OPEN_WOUND,
		SCAR_CRACKED_BONES,
		SCAR_OPEN_WOUND_HP_PENALTY
	)
	_run_state.scar_heal_multiplier = float(modifiers.get("heal_multiplier", 1.0))
	_run_state.scar_dodge_cooldown_multiplier = float(modifiers.get("dodge_cooldown_multiplier", 1.0))
	_run_state.scar_dodge_speed_multiplier = float(modifiers.get("dodge_speed_multiplier", 1.0))
	_run_state.scar_max_hp_penalty = int(modifiers.get("max_hp_penalty", 0))
	_apply_run_upgrades_to_player()

func _recompute_scar_synergies() -> void:
	if _run_state.is_hunted_by_crowd:
		return
	var blood_count: int = _count_scars_with_tag(TAG_BLOOD)
	if blood_count >= 3:
		_run_state.is_hunted_by_crowd = true
		_check_audience_condanne()

func _get_bet_display_name(bet_id: String) -> String:
	var bet_data: Dictionary = _get_bet_data(bet_id)
	if bet_data.is_empty():
		return bet_id
	return str(bet_data.get("name", bet_id))

func _try_apply_open_wound_scar(chain_level: int) -> void:
	if _has_scar(SCAR_OPEN_WOUND):
		return
	var bet_name: String = _get_bet_display_name(BET_PURE_BLOOD)
	var origin_text: String = "Condanna: %s (catena %d)" % [bet_name, chain_level]
	var scar_def: Dictionary = _get_scar_def(SCAR_OPEN_WOUND)
	var scar: Dictionary = _scar_system.build_scar_payload(
		SCAR_OPEN_WOUND,
		origin_text,
		scar_def,
		"FERITA APERTA",
		"Il sangue non si è mai fermato.",
		"HP massimo ridotto e cure meno efficaci."
	)
	_add_scar(scar)

func _try_apply_cracked_bones_scar(bet_id: String, chain_level: int) -> void:
	if chain_level < 2:
		return
	if _has_scar(SCAR_CRACKED_BONES):
		return
	var bet_name: String = _get_bet_display_name(bet_id)
	var origin_text: String = "Push Your Luck: %s (x%d)" % [bet_name, chain_level]
	var scar_def: Dictionary = _get_scar_def(SCAR_CRACKED_BONES)
	var scar: Dictionary = _scar_system.build_scar_payload(
		SCAR_CRACKED_BONES,
		origin_text,
		scar_def,
		"OSSA INCRINATE",
		"Ogni passo fa male.",
		"Movimento rallentato e blocco meno efficace."
	)
	_add_scar(scar)

func _apply_run_upgrades_to_player() -> void:
	if _player == null:
		_player = _resolve_player()
	if _player == null:
		return
	var upgrades: Dictionary = run.get("upgrades", {}) as Dictionary
	var bet_hp_penalty: int = int(run.get("bet_hp_penalty", 0))
	if _player.has_method("apply_run_upgrades"):
		_player.call(
			"apply_run_upgrades",
			int(upgrades.get("hp_bonus", 0)) + bet_hp_penalty + _run_state.scar_max_hp_penalty + _run_state.max_hp_modifier,
			int(upgrades.get("light_bonus", 0)),
			int(upgrades.get("heavy_bonus", 0))
		)
	_apply_scar_modifiers_to_player()

func _apply_scar_modifiers_to_player() -> void:
	if _player == null:
		_player = _resolve_player()
	if _player == null:
		return
	if _player.has_method("apply_scar_modifiers"):
		_player.call(
			"apply_scar_modifiers",
			_run_state.scar_heal_multiplier,
			_run_state.scar_dodge_cooldown_multiplier,
			_run_state.scar_dodge_speed_multiplier
		)

func _get_spawn_position() -> Vector2:
	if _arena and _arena is Node:
		var spawn_node: Node = _find_spawn_node(_arena)
		if spawn_node and spawn_node is Node2D:
			return (spawn_node as Node2D).global_position
		if _arena is Node2D:
			return (_arena as Node2D).global_position
	return Vector2.ZERO

func _find_spawn_node(root: Node) -> Node:
	var direct: Node = root.get_node_or_null("Spawn")
	if direct:
		return direct
	var named: Node = root.find_child("Spawn", true, false)
	if named:
		return named
	var player_spawn: Node = root.find_child("PlayerSpawn", true, false)
	if player_spawn:
		return player_spawn
	return root.find_child("PlayerSpawnPoint", true, false)

func _log_runtime_state(tag: String) -> void:
	if not DEBUG_RUNTIME_LOGS:
		return
	var player_node: Node = _resolve_player()
	var player_exists: bool = player_node != null
	var player_in_tree: bool = player_exists and player_node.is_inside_tree()
	var player_physics: bool = player_exists and player_node.is_physics_processing()
	var player_process_mode: int = -1
	if player_exists:
		player_process_mode = player_node.process_mode
	var player_pos: Vector2 = Vector2.ZERO
	if player_exists and player_node is Node2D:
		player_pos = (player_node as Node2D).global_position

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var enemies_count: int = enemies.size()
	var sample_enemy: Node = null
	if enemies_count > 0:
		sample_enemy = enemies[0] as Node
	var enemy_physics: bool = sample_enemy != null and sample_enemy.is_physics_processing()
	var enemy_process_mode: int = -1
	if sample_enemy != null:
		enemy_process_mode = sample_enemy.process_mode

	var cam: Camera2D = get_viewport().get_camera_2d()
	var cam_exists: bool = cam != null
	var cam_current: bool = cam_exists and cam.has_method("is_current") and cam.is_current()
	var cam_pos: Vector2 = Vector2.ZERO
	if cam_exists:
		cam_pos = cam.global_position

	print(
		"[runtime:%s] paused=%s gameplay_enabled=%s player_in_tree=%s player_physics=%s player_process_mode=%s player_pos=%s enemies=%s enemy_physics=%s enemy_process_mode=%s cam_exists=%s cam_current=%s cam_pos=%s"
		% [
			tag,
			get_tree().paused,
			GameEvents.gameplay_enabled,
			player_in_tree,
			player_physics,
			player_process_mode,
			player_pos,
			enemies_count,
			enemy_physics,
			enemy_process_mode,
			cam_exists,
			cam_current,
			cam_pos,
		]
	)
