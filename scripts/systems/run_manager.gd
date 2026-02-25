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
@export var arena_scene: PackedScene
@export var player_scene: PackedScene

# RUN FLOW (contract)
# MAIN_MENU -> RUN_INIT -> BET_PRESENT -> BET_COMMITTED
# -> INTERMEDIATE_CHOICE -> RESOLUTION -> PUSH_YOUR_LUCK (or NEXT_BET)
enum RunPhase {
	NONE = -1,
	PREP = 0,
	LIVE = 1,
	GAME_OVER = 2,
	MAIN_MENU = 10,
	RUN_INIT = 11,
	BET_PRESENT = 12,
	BET_COMMITTED = 13,
	POST_BET_MESSAGES = 14, # RESERVED (removed in L3)
	INTERMEDIATE_CHOICE = 15,
	PUSH_YOUR_LUCK = 16,
	NEXT_BET = 17,
	RESOLUTION = 18,
}

const PACT_SEALED_SECONDS: float = 0.7
const RESOLVE_RITUAL_SECONDS: float = 0.9
const INTERMEDIATE_PLACA_BONUS_COINS: int = 6
const INTERMEDIATE_PROVOCA_BONUS_TIER: int = 1
const INTERMEDIATE_PROVOCA_LOSS_PENALTY_COINS: int = 6
const BetCatalog = preload("res://scripts/content/bet_catalog.gd")
const BET_CASH_OUT: StringName = BetCatalog.BET_CASH_OUT
const BET_DOUBLE_OR_DIE_L3: StringName = BetCatalog.BET_DOUBLE_OR_DIE
const BET_DEBT_CHAIN: StringName = BetCatalog.BET_DEBT_CHAIN
const BET_BLOOD_TAX: StringName = BetCatalog.BET_BLOOD_TAX
const BET_CROW_PLEASER: StringName = BetCatalog.BET_CROW_PLEASER
const BET_LAST_BREATH: StringName = BetCatalog.BET_LAST_BREATH
const BET_P3_WAX_SEAL: StringName = BetCatalog.BET_P3_WAX_SEAL
const BET_P3_BLOOD_LEDGER: StringName = BetCatalog.BET_P3_BLOOD_LEDGER
const BET_P3_DEBT_MIRROR: StringName = BetCatalog.BET_P3_DEBT_MIRROR
const BET_P3_CROWD_FEAST: StringName = BetCatalog.BET_P3_CROWD_FEAST
const BET_P3_LAST_WAGER: StringName = BetCatalog.BET_P3_LAST_WAGER
const BET_P3_RED_VERDICT: StringName = BetCatalog.BET_P3_RED_VERDICT
const BET_P3_CHAIN_OATH: StringName = BetCatalog.BET_P3_CHAIN_OATH
const BET_P3_TITHE_OF_BONE: StringName = BetCatalog.BET_P3_TITHE_OF_BONE
const BET_P3_GLORY_TAX: StringName = BetCatalog.BET_P3_GLORY_TAX
const BET_P3_MERCY_BAIT: StringName = BetCatalog.BET_P3_MERCY_BAIT
const BET_P3_SILENCE_BRIBE: StringName = BetCatalog.BET_P3_SILENCE_BRIBE
const BET_P3_FINAL_APPLAUSE: StringName = BetCatalog.BET_P3_FINAL_APPLAUSE
const BET_P3_LIE_MERCY: StringName = BetCatalog.BET_P3_LIE_MERCY
const BET_P3_LIE_DEBT: StringName = BetCatalog.BET_P3_LIE_DEBT
const BET_P3_LIE_APPLAUSE: StringName = BetCatalog.BET_P3_LIE_APPLAUSE
const ArenaThemes = preload("res://data/arena_themes.gd")
const GameConstants = preload("res://scripts/systems/constants.gd")
const SmokeDriverScript = preload("res://scripts/systems/run/smoke_driver.gd")
const FlowWatchdogScript = preload("res://scripts/systems/run/flow_watchdog.gd")
const BetSystemScript = preload("res://scripts/systems/run/bet_system.gd")
const BettingPolicyScript = preload("res://scripts/systems/run/betting_policy.gd")
const BettingPayloadFactoryScript = preload("res://scripts/systems/run/betting_payload_factory.gd")
const ScarSystemScript = preload("res://scripts/systems/run/scar_system.gd")
const OutcomeSystemScript = preload("res://scripts/systems/run/outcome_system.gd")
const ScarPolicyScript = preload("res://scripts/systems/run/scar_policy.gd")
const RunUiPayloadScript = preload("res://scripts/ui/run_ui_payload.gd")

const LEVEL3_BET_BEHAVIOR: Dictionary[StringName, StringName] = BetCatalog.LEVEL3_BET_BEHAVIOR
const LEVEL3_PACT_UNLOCKS: Dictionary[StringName, StringName] = BetCatalog.LEVEL3_PACT_UNLOCKS
const SaveSystemScript = preload("res://scripts/systems/run/save_system.gd")
const SaveContinueBoundaryScript = preload("res://scripts/systems/run/save_continue_boundary.gd")
const RunSaveBoundaryHelperScript = preload("res://scripts/systems/run/run_save_boundary_helper.gd")
const RunFlowExecutorScript = preload("res://scripts/systems/run/run_flow_executor.gd")
const RunFlowExecutorHooksScript = preload("res://scripts/systems/run/run_flow_executor_hooks.gd")
const RunFlowCatalogScript = preload("res://scripts/systems/run/run_flow_catalog.gd")
const RequestRouterScript = preload("res://scripts/systems/run/request_router.gd")
const RunEndPayloadBuilderScript = preload("res://scripts/systems/run/run_end_payload_builder.gd")
const RunArenaThemePolicyScript = preload("res://scripts/systems/run/run_arena_theme_policy.gd")
const RunUiPayloadFactoryScript = preload("res://scripts/systems/run/run_ui_payload_factory.gd")
const RunRegisterAnnotationPolicyScript = preload("res://scripts/systems/run/run_register_annotation_policy.gd")
const I18N_EN_PATH: String = "res://assets/i18n/en.csv"
const I18N_IT_PATH: String = "res://assets/i18n/it.csv"

const RUN_FLOW_BET_SIGNED: StringName = &"BET_SIGNED"
const RUN_FLOW_INTERMEDIATE_CHOICE: StringName = &"INTERMEDIATE_CHOICE"
const RUN_FLOW_PUSH_LUCK: StringName = &"PUSH_LUCK"
const RUN_FLOW_BET_OFFER: StringName = &"BET_OFFER"
const CORRUPTION_MAX: int = 100
const CORRUPTION_DOUBLE: int = 1
const CORRUPTION_PACT_HIGH: int = 1
const SCAR_DOUBLE_BASE_CHANCES: Array[float] = [0.10, 0.20, 0.35, 0.50]
const SCAR_PACT_BASE_MIN: float = 0.25
const SCAR_PACT_BASE_MAX: float = 0.55
const SCAR_PACT_STEP: float = 0.05
const SCAR_VOLATILITY_SHIFT_CAP: int = 3
const GLORY_PER_SUCCESS: int = 1
const GLORY_MULT_BASE: int = 1
const GLORY_MULT_STEPS: Array[int] = [1, 2, 4, 7, 11]

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
const CONDANNA_REGISTRO_COMPROMISSIONE: StringName = &"CONDANNA_REGISTRO_COMPROMISSIONE"
const CONDANNA_REGISTRO_ASCESA: StringName = &"CONDANNA_REGISTRO_ASCESA"
const CONDANNA_REGISTRO_CONSUMO: StringName = &"CONDANNA_REGISTRO_CONSUMO"
const CONDANNA_REGISTRO_PATTERN: StringName = &"CONDANNA_REGISTRO_PATTERN"


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
const AUDIENCE_POOL_SAFE: Array[String] = [
	"Guarda come trema. Vuole vivere un altro giorno.",
	"Non è un leone. È un topo con un casco.",
	"Scommessa piccola per un cuore piccolo.",
	"Non cerca gloria. Cerca scuse.",
	"Così si sopravvive… ma non si diventa leggenda.",
]
const AUDIENCE_POOL_MID: Array[String] = [
	"Non troppo audace… non troppo vile.",
	"Gioca con misura. Forse troppo.",
	"Un passo avanti, ma non abbastanza.",
	"Vuole vincere. Non vuole rischiare tutto.",
	"È ambizione… o è paura mascherata?",
]
const AUDIENCE_POOL_HIGH: Array[String] = [
	"Ah! Finalmente qualcuno che osa.",
	"Sfida la sorte… o la provoca?",
	"Vuole tutto. Potrebbe perdere tutto.",
	"Se cade, farà rumore.",
	"O sarà leggenda… o sarà cenere.",
]
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
	_flow_logger.log(tag, details)

func _smoke_mark(tag: String) -> void:
	if OS.has_environment("GALLICUS_SMOKE_SCENARIO"):
		print("SMOKE:MILESTONE=" + tag)

func _smoke_mark_kv(tag: String, key: String, value: String) -> void:
	if OS.has_environment("GALLICUS_SMOKE_SCENARIO"):
		print("SMOKE:MILESTONE=" + tag + " " + key + "=" + value)
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
const UNLOCK_REGISTRY_PRECEDENT: StringName = &"registry_precedent"
const LIBERTY_THRESHOLD: int = 8
const MORAL_THRESHOLD: int = 8
const FALL_THRESHOLD: int = 5
const CORRUPTION_FINAL_THRESHOLD: int = 70
const GLORY_FINAL_THRESHOLD: int = 100
const SCARS_FINAL_THRESHOLD: int = 3
const MIN_BETS_FOR_SENTENCE: int = 3
const REGISTER_ENDING_CORRUPTION: String = "ending_corruption"
const REGISTER_ENDING_GLORY: String = "ending_glory"
const REGISTER_ENDING_SCARS: String = "ending_scars"
const REGISTER_ENDING_PATTERN: String = "ending_pattern"
const ENDING_TO_ACHIEVEMENT_CONDANNA: Dictionary = {
	REGISTER_ENDING_CORRUPTION: CONDANNA_REGISTRO_COMPROMISSIONE,
	REGISTER_ENDING_GLORY: CONDANNA_REGISTRO_ASCESA,
	REGISTER_ENDING_SCARS: CONDANNA_REGISTRO_CONSUMO,
	REGISTER_ENDING_PATTERN: CONDANNA_REGISTRO_PATTERN,
}
const ENDING_TO_ARCHIVE_ENTRY: Dictionary = {
	REGISTER_ENDING_CORRUPTION: "archive_corruption_case",
	REGISTER_ENDING_GLORY: "archive_glory_case",
	REGISTER_ENDING_SCARS: "archive_scars_case",
	REGISTER_ENDING_PATTERN: "archive_pattern_case",
}
const SCAR_RISK_ESCALATION_THRESHOLD: int = 7
const SCAR_MIN_ARENA_INTERVAL: int = 1
const REGISTER_POOL_PROVISIONAL: Array[String] = [
	"Fascicolo aggiornato. Valutazione sospesa.",
	"Atto registrato. Campione insufficiente.",
	"Dati acquisiti. Analisi in corso.",
	"Aggiornamento completato. Nessuna conclusione emessa.",
	"Il soggetto resta in osservazione.",
	"Archiviazione parziale. Raccolta incompleta.",
	"Evento conforme. Interpretazione rinviata.",
	"Nuova evidenza inserita. Profilo non definito.",
	"Registrazione valida. Sentenza non autorizzata.",
	"Traiettoria non stabilizzata. Attendere ulteriori eventi.",
	"Documento acquisito. Il Registro non conclude.",
	"Pattern non consolidato. Prosecuzione richiesta.",
]
const REGISTER_POOL_FINAL_CORRUPTION: Array[String] = [
	"Soglia di deviazione superata. Fascicolo chiuso.",
	"Corruzione confermata. Archiviazione definitiva.",
	"Indice di compromissione: critico. Sentenza emessa.",
	"Integrità del soggetto: insufficiente. Caso concluso.",
	"Deriva irreversibile rilevata. Il Registro conclude.",
	"Evidenza prevalente: debito. Fascicolo definito.",
	"Profilo compromesso. Non sono richiesti ulteriori dati.",
	"Scostamento oltre limite. Atto finale registrato.",
]
const REGISTER_POOL_FINAL_GLORY: Array[String] = [
	"Indice di gloria: eccedente. Fascicolo chiuso.",
	"Rilevanza confermata. Archiviazione definitiva.",
	"Profilo di eccezione registrato. Sentenza emessa.",
	"Valore del soggetto: determinato. Caso concluso.",
	"Evidenza prevalente: ascesa. Il Registro conclude.",
	"Traccia storica sufficiente. Fascicolo definito.",
	"Comportamento coerente con grandezza. Atto finale registrato.",
	"Risultato consolidato. Non sono richiesti ulteriori dati.",
]
const REGISTER_POOL_FINAL_SCARS: Array[String] = [
	"Danno permanente rilevato. Fascicolo chiuso.",
	"Cicatrici critiche registrate. Archiviazione definitiva.",
	"Stato del soggetto: degradato. Sentenza emessa.",
	"Accumulo irreversibile. Caso concluso.",
	"Integrità fisica compromessa. Il Registro conclude.",
	"Evidenza prevalente: consumo. Fascicolo definito.",
	"Segni sufficienti. Non sono richiesti ulteriori dati.",
	"Profilo stabilizzato su danno. Atto finale registrato.",
]
const REGISTER_POOL_FINAL_PATTERN: Array[String] = [
	"Campione minimo raggiunto. Fascicolo chiuso.",
	"Pattern confermato. Archiviazione definitiva.",
	"Coerenza comportamentale stabilita. Sentenza emessa.",
	"Traiettoria consolidata. Caso concluso.",
	"Dati sufficienti per definizione. Il Registro conclude.",
	"Ripetizione significativa rilevata. Fascicolo definito.",
	"Profilo determinato per frequenza. Atto finale registrato.",
	"Analisi completata. Non sono richiesti ulteriori dati.",
]
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
	var _annotation_policy: RunRegisterAnnotationPolicy = RunRegisterAnnotationPolicyScript.new()

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
		last_annotation_text = _annotation_policy.build_register_annotation_text("SCAR_APPLIED", {
			"flow_phase": String(flow_phase),
		})
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
		last_annotation_text = _annotation_policy.build_register_annotation_text("RUN_END", {
			"flow_phase": String(flow_phase),
			"emit_reason": emit_reason,
			"scar_count": scar_count,
			"felix_precedent_emitted": felix_precedent_emitted,
		})
		if flow_phase == FLOW_PHASE_MEMORIA and not felix_precedent_emitted:
			felix_precedent_emitted = true
		return {
			"text": last_annotation_text,
			"duration": 1.4,
			"blocking": true,
			"flow_phase": String(flow_phase),
		}

class ArenaResult:
	var won: bool = false
	var condemnation_flag: bool = false
	var notes: Array[StringName] = []

const ARCH_DEBT: StringName = &"DEBT"
const ARCH_EGO: StringName = &"EGO"
const ARCH_TIME: StringName = &"TIME"

const LEVEL3_BETS: Array[Dictionary] = BetCatalog.LEVEL3_BETS

const LYING_PACT_REVEALS: Dictionary = {
	BET_P3_LIE_MERCY: "VERITÀ: La folla pretende spettacolo: ogni esitazione si paga.",
	BET_P3_LIE_DEBT: "VERITÀ: Il debito si rinnova: ciò che prendi oggi lo restituisci domani.",
	BET_P3_LIE_APPLAUSE: "VERITÀ: L'applauso è una trappola: più ti esaltano, più ti consumano.",
}

# LEGACY NAME: "damage_mod" profiles ritual adverse pressure in L3 (non-combat).
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


const DEBUG_RUNTIME_LOGS: bool = false

@export var bet_coward_coin_reward: int = 20
@export var bet_pure_hp_bonus: int = 30

const BET_COWARD: String = "COWARD"
const BET_PURE_BLOOD: String = "PURE_BLOOD"
const BET_DOUBLE_OR_DIE: String = String(BetCatalog.BET_DOUBLE_OR_DIE)
const SCAR_OPEN_WOUND_HP_PENALTY: int = 20

var run: Dictionary = {
	"arena_index": 0,
	"coins": 0,
	"corruption": 0,
	"upgrades": {},
}

var _arena: Node
var _waiting_for_bet: bool = false
var _waiting_for_push_luck: bool = false
var _waiting_for_intermediate_choice: bool = false
var _player: Node
var _run_failed_emitted: bool = false
var _run_ended_emitted: bool = false
var _meta_unlock_emitted_this_run: bool = false
var _end_run_meta_emitted: bool = false
var _is_game_over: bool = false
var _phase: RunPhase = RunPhase.NONE
var _gameplay_phase: RunPhase = RunPhase.PREP
var _pending_resolution_bet_id: StringName = &""
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
var _run_state: RunState = RunState.new()
var _save_system: SaveSystem = SaveSystemScript.new()
var _save_continue_boundary: SaveContinueBoundary = SaveContinueBoundaryScript.new()
var _save_boundary: RunSaveBoundaryHelper = RunSaveBoundaryHelperScript.new()
var _arena_theme_policy: RunArenaThemePolicy = RunArenaThemePolicyScript.new()
var _ui_payload_factory: RunUiPayloadFactory = RunUiPayloadFactoryScript.new()
var _register_state: RegisterState = RegisterState.new()
var _level3_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _boot_valid: bool = true
var _sanity_ui_root: Node = null
var _arena_themes: RefCounted = null
var _bet_system: RunBetSystem = BetSystemScript.new()
var _betting_policy: BettingPolicy = BettingPolicyScript.new()
var _betting_payload_factory: BettingPayloadFactory = BettingPayloadFactoryScript.new()
var _scar_system: RunScarSystem = ScarSystemScript.new()
var _scar_catalog: ScarCatalog = ScarCatalog.new()
var _outcome_system: RunOutcomeSystem = OutcomeSystemScript.new()
var _runstate_kernel: RunStateKernel = RunStateKernel.new()
var _flow_executor: RunFlowExecutor = null
var _flow_event_router: RunFlowEventRouter = null
var _flow_mutation_registry: RunFlowMutationRegistry = null
var _request_router: RequestRouter = RequestRouterScript.new()
var _run_end_payload_builder: RunEndPayloadBuilder = RunEndPayloadBuilderScript.new()
var _scar_policy: ScarPolicy = ScarPolicyScript.new()
var _flow_logger: FlowLogger = FlowLogger.new()
var _last_resolve_debug: Dictionary = {}
var _phase_run_init_handler: PhaseRunInitHandler = PhaseRunInitHandler.new()
var _phase_bet_present_handler: PhaseBetPresentHandler = PhaseBetPresentHandler.new()
var _phase_intermediate_choice_handler: PhaseIntermediateChoiceHandler = PhaseIntermediateChoiceHandler.new()
var _phase_push_your_luck_handler: PhasePushYourLuckHandler = PhasePushYourLuckHandler.new()
var _phase_resolution_handler: PhaseResolutionHandler = PhaseResolutionHandler.new()
var _phase_game_over_handler: PhaseGameOverHandler = PhaseGameOverHandler.new()
var _phase_main_menu_handler: PhaseMainMenuHandler = PhaseMainMenuHandler.new()
var _phase_handler_map: Dictionary = {}
var _session_id: String = ""
var _run_counter: int = 0
var _last_request: String = ""
var _events_wired: bool = false
var _last_phase_change_ms: int = 0
var _language_fallback_logged: bool = false
var _last_save_reject_reason: String = ""
var _last_ui_render_ms: int = 0
var _last_activity_ms: int = 0
var _watchdog_enabled: bool = true
var _registry_has_precedent: bool = false
var _glory_multiplier: int = GLORY_MULT_BASE
var _smoke: SmokeDriver = null
var _smoke_timeout_deadline_msec: int = -1
var _smoke_driver_active: bool = false
var _smoke_driver_next_tick_msec: int = -1
var _smoke_full_run_step: String = ""
var _flow_watchdog: FlowWatchdog = FlowWatchdogScript.new()
var _flow_diagnostics: FlowDiagnostics = FlowDiagnostics.new()
var _finale_builder: FinaleBuilder = FinaleBuilder.new()

const WATCHDOG_STALL_MS: int = 6000

func _smoke_init_if_needed() -> void:
	if _smoke != null:
		return
	_smoke = SmokeDriverScript.new()


func _is_smoke_mode() -> bool:
	_smoke_init_if_needed()
	return _smoke.is_smoke_mode()


func _phase_to_name(phase: RunPhase) -> String:
	match phase:
		RunPhase.NONE:
			return "NONE"
		RunPhase.PREP:
			return "PREP"
		RunPhase.LIVE:
			return "LIVE"
		RunPhase.GAME_OVER:
			return "GAME_OVER"
		RunPhase.MAIN_MENU:
			return "MAIN_MENU"
		RunPhase.RUN_INIT:
			return "RUN_INIT"
		RunPhase.BET_PRESENT:
			return "BET_PRESENT"
		RunPhase.BET_COMMITTED:
			return "BET_COMMITTED"
		RunPhase.POST_BET_MESSAGES:
			return "POST_BET_MESSAGES"
		RunPhase.INTERMEDIATE_CHOICE:
			return "INTERMEDIATE_CHOICE"
		RunPhase.PUSH_YOUR_LUCK:
			return "PUSH_YOUR_LUCK"
		RunPhase.NEXT_BET:
			return "NEXT_BET"
		RunPhase.RESOLUTION:
			return "RESOLUTION"
		_:
			return str(phase)


func _start_smoke_timeout_timer() -> void:
	if not _is_smoke_mode():
		return
	_smoke_init_if_needed()
	var timeout_sec: float = _smoke.get_timeout_seconds()
	_smoke_timeout_deadline_msec = Time.get_ticks_msec() + int(timeout_sec * 1000.0)


func _smoke_start_scenario() -> void:
	_smoke_init_if_needed()
	if not _smoke.should_start_driver_scenario():
		return
	if _smoke_driver_active:
		return
	_smoke_full_run_step = ""
	var scenario: String = OS.get_environment("GALLICUS_SMOKE_SCENARIO")
	if scenario == "FULL_RUN":
		print("SMOKE:STEP=SCENARIO_FULL_RUN_START")
	else:
		var start_logs: PackedStringArray = _smoke.begin_scenario()
		for line: String in start_logs:
			print(line)
	_smoke_driver_active = true
	_smoke_driver_next_tick_msec = Time.get_ticks_msec()


func _stop_smoke_driver() -> void:
	_smoke_driver_active = false
	_smoke_driver_next_tick_msec = -1


func _on_smoke_driver_tick() -> void:
	if OS.get_environment("GALLICUS_SMOKE_SCENARIO") == "FULL_RUN":
		_run_smoke_full_run_driver()
		return
	_smoke_init_if_needed()
	var smoke_step: Dictionary = _smoke.on_tick(
		_phase_to_name(_phase),
		_get_smoke_selected_bet_id(),
		_run_state.bets_history.size(),
		_is_register_final()
	)
	var smoke_logs: PackedStringArray = smoke_step.get("logs", PackedStringArray()) as PackedStringArray
	if bool(smoke_step.get("stop_driver", false)):
		_stop_smoke_driver()
	for line: String in smoke_logs:
		print(line)
	if bool(smoke_step.get("request_quit_gate", false)):
		_smoke_quit_gate()
	if bool(smoke_step.get("stop_driver", false)):
		return
	if bool(smoke_step.get("request_new_run", false)):
		_on_request_new_run()
	if bool(smoke_step.get("request_place_bet", false)):
		var bet_id: String = str(smoke_step.get("place_bet_id", ""))
		if bet_id != "":
			_on_request_place_bet(bet_id, 0)
	if bool(smoke_step.get("request_mid_choice_select", false)):
		var choice_index: int = int(smoke_step.get("mid_choice_index", 0))
		_on_request_mid_choice_select(choice_index)
	if bool(smoke_step.get("request_pyl_double", false)):
		_on_request_pyl_double()
	if bool(smoke_step.get("request_pyl_cashout", false)):
		_on_request_pyl_cashout()


func _run_smoke_full_run_driver() -> void:
	if _phase == RunPhase.MAIN_MENU and _smoke_full_run_step == "":
		_smoke_full_run_step = "NEW_RUN"
		print("SMOKE:STEP=REQUEST_NEW_RUN")
		print("SMOKE:NEW_RUN_REQUESTED")
		print("SMOKE:REQ=request_new_run")
		_on_request_new_run()
		return
	if _phase == RunPhase.RUN_INIT and _smoke_full_run_step == "NEW_RUN":
		print("SMOKE:STEP=RUN_INIT_SEEN")
		_smoke_full_run_step = "RUN_INIT"
		return
	if _phase == RunPhase.BET_PRESENT and _smoke_full_run_step != "BET_PRESENT":
		var bet_id: String = _get_smoke_selected_bet_id()
		if bet_id == "":
			return
		_smoke_full_run_step = "BET_PRESENT"
		print("SMOKE:REQ=request_place_bet bet_id=%s" % bet_id)
		_on_request_place_bet(bet_id, 0)
		return
	if _phase == RunPhase.INTERMEDIATE_CHOICE and _smoke_full_run_step != "INTERMEDIATE_CHOICE":
		_smoke_full_run_step = "INTERMEDIATE_CHOICE"
		print("SMOKE:REQ=request_mid_choice_select index=0")
		_on_request_mid_choice_select(0)
		return
	if _phase == RunPhase.PUSH_YOUR_LUCK and _smoke_full_run_step != "PUSH_YOUR_LUCK":
		_smoke_full_run_step = "PUSH_YOUR_LUCK"
		if _run_state.bets_history.size() < 3:
			print("SMOKE:REQ=request_pyl_double")
			_on_request_pyl_double()
		else:
			print("SMOKE:REQ=request_pyl_cashout")
			_on_request_pyl_cashout()
		return
	if _phase == RunPhase.GAME_OVER and _is_register_final():
		print("SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
		_stop_smoke_driver()
		_smoke_quit_gate()


func _get_smoke_selected_bet_id() -> String:
	if _run_state.level3_current_offer.is_empty():
		return ""
	var first_offer: Variant = _run_state.level3_current_offer[0]
	if first_offer is Dictionary:
		return str((first_offer as Dictionary).get("id", ""))
	return ""

func _smoke_quit_gate() -> void:
	get_tree().quit(0)


func _smoke_tick(now_msec: int) -> void:
	if _smoke_timeout_deadline_msec > 0 and now_msec >= _smoke_timeout_deadline_msec:
		if OS.get_environment("GALLICUS_SMOKE_SCENARIO") == "BET_PRESENT":
			print("SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
		_smoke_timeout_deadline_msec = -1
		get_tree().quit(0)
		return
	if not _smoke_driver_active:
		return
	if _smoke_driver_next_tick_msec > now_msec:
		return
	_smoke_driver_next_tick_msec = now_msec + 100
	_on_smoke_driver_tick()


func _ready() -> void:
	print("RunManager ready")
	_arena_themes = ArenaThemes.new()
	_session_id = str(Time.get_unix_time_from_system())
	if _flow_logger != null:
		_flow_logger.set_session(_session_id)
	if _flow_diagnostics == null:
		_flow_diagnostics = FlowDiagnostics.new()
	if _flow_event_router == null or _flow_mutation_registry == null:
		var flow_catalog_bundle: RunFlowCatalog.Bundle = RunFlowCatalogScript.new().build_bundle(self)
		_flow_event_router = flow_catalog_bundle.event_router
		_flow_mutation_registry = flow_catalog_bundle.mutation_registry
	if _flow_executor == null:
		_flow_executor = RunFlowExecutorScript.new(_build_flow_executor_hooks(), _flow_event_router, _flow_mutation_registry)
	if _finale_builder == null:
		_finale_builder = FinaleBuilder.new()
	var now_ms: int = Time.get_ticks_msec()
	_last_phase_change_ms = now_ms
	_last_ui_render_ms = now_ms
	_last_activity_ms = now_ms
	add_to_group("run_manager")
	_apply_saved_language()
	if not _validate_game_events_signals():
		return
	_connect_gameevents()
	_phase_handler_map[RunPhase.MAIN_MENU] = _phase_main_menu_handler
	_phase_handler_map[RunPhase.RUN_INIT] = _phase_run_init_handler
	_phase_handler_map[RunPhase.BET_PRESENT] = _phase_bet_present_handler
	_phase_handler_map[RunPhase.INTERMEDIATE_CHOICE] = _phase_intermediate_choice_handler
	_phase_handler_map[RunPhase.PUSH_YOUR_LUCK] = _phase_push_your_luck_handler
	_phase_handler_map[RunPhase.RESOLUTION] = _phase_resolution_handler
	_phase_handler_map[RunPhase.GAME_OVER] = _phase_game_over_handler
	_registry_has_precedent = SaveManager.has_unlocked(UNLOCK_REGISTRY_PRECEDENT)
	_start_smoke_timeout_timer()
	call_deferred("_boot")

func _process(_delta: float) -> void:
	_watchdog_tick()
	if _is_smoke_mode():
		_smoke_tick(Time.get_ticks_msec())


func _connect_gameevents() -> void:
	if _events_wired:
		return
	_events_wired = true
	var bindings: Array[Array] = [
		[&"bet_placed", &"_on_bet_placed", false],
		[&"bet_sealed", &"_on_bet_sealed", true],
		[&"bet_confirmed", &"_on_bet_confirmed", true],
		[&"request_place_bet", &"_on_request_place_bet", true],
		[&"betting_opened", &"_on_betting_opened", false],
		[&"request_new_run", &"_on_request_new_run", true],
		[&"request_push_luck_cashout", &"_on_request_push_luck_cashout", true],
		[&"request_push_luck_double", &"_on_request_push_luck_double", true],
		[&"post_arena_choice_selected", &"_on_post_arena_choice_selected", true],
		[&"request_intermediate_choice", &"_on_request_intermediate_choice", true],
		[&"request_intro_apply_seed", &"_on_request_intro_apply_seed", true],
		[&"request_intro_select_bet", &"_on_request_intro_select_bet", true],
		[&"request_intro_confirm", &"_on_request_intro_confirm", true],
		[&"request_mid_choice_select", &"_on_request_mid_choice_select", true],
		[&"request_pyl_cashout", &"_on_request_pyl_cashout", true],
		[&"request_pyl_condanna", &"_on_request_pyl_condanna", true],
		[&"request_pyl_double", &"_on_request_pyl_double", true],
		[&"request_end_run_restart", &"_on_request_end_run_restart", true],
		[&"request_end_run_next_bet", &"_on_request_end_run_next_bet", true],
		[&"request_end_run_quit", &"_on_request_end_run_quit", true],
		[&"request_reset_run", &"_on_request_reset_run", true],
		[&"request_retry_run", &"_on_request_retry_run", true],
		[&"request_continue_run", &"_on_request_continue_run", true],
		[&"request_show_main_menu", &"_on_request_show_main_menu", true],
		[&"request_fail_run", &"_on_request_fail_run", true],
		[&"request_set_run_seed", &"_on_request_set_run_seed", true],
		[&"request_clear_run_seed", &"_on_request_clear_run_seed", true],
		[&"request_skip_arena_resolution", &"_on_request_skip_arena_resolution", true],
		[&"modal_opened", &"_on_modal_opened", true],
		[&"modal_closed", &"_on_modal_closed", true],
		[&"settings_changed", &"_on_settings_changed", true],
	]
	for binding: Array in bindings:
		var signal_name: StringName = binding[0]
		var handler_name: StringName = binding[1]
		var requires_has_signal: bool = binding[2]
		if requires_has_signal and not GameEvents.has_signal(signal_name):
			continue
		var signal_ref_variant: Variant = GameEvents.get(signal_name)
		if signal_ref_variant is Signal:
			var signal_ref: Signal = signal_ref_variant as Signal
			var handler: Callable = Callable(self, handler_name)
			if not signal_ref.is_connected(handler):
				signal_ref.connect(handler)

func _apply_saved_language() -> void:
	var saved_language: String = SaveManager.get_language()
	_apply_language(saved_language)

func _apply_language(locale: String) -> void:
	var target_locale: String = locale.strip_edges().to_lower()
	if target_locale != "it" and target_locale != "en":
		target_locale = "it"
	TranslationServer.set_locale(_resolve_available_locale(target_locale))

func _resolve_available_locale(target_locale: String) -> String:
	var requested_path: String = I18N_IT_PATH if target_locale == "it" else I18N_EN_PATH
	if FileAccess.file_exists(requested_path):
		return target_locale
	var fallback_locale: String = "en" if target_locale == "it" else "it"
	var fallback_path: String = I18N_IT_PATH if fallback_locale == "it" else I18N_EN_PATH
	if FileAccess.file_exists(fallback_path):
		if not _language_fallback_logged:
			print("[I18N] Missing translation resource ", requested_path, ". Fallback locale: ", fallback_locale)
			_language_fallback_logged = true
		return fallback_locale
	if not _language_fallback_logged:
		print("[I18N] Missing translation resources for locales: ", target_locale, " and ", fallback_locale)
		_language_fallback_logged = true
	return target_locale

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
	_arena = null
	_player = null
	print("Boot: arena=", _arena, " player=", _player)
	print("Player in tree:", _player != null and _player.is_inside_tree())
	_set_phase(RunPhase.MAIN_MENU, "boot")
	if _is_smoke_mode():
		print("SMOKE:BOOT_OK")
		print("SMOKE:PHASE=MAIN_MENU")
		if OS.has_environment("GALLICUS_SMOKE_SCENARIO"):
			_smoke_start_scenario()
		elif OS.get_environment("GALLICUS_SMOKE_TRIGGER_NEW_RUN") == "1":
			print("SMOKE:NEW_RUN_REQUESTED")
			print("SMOKE:REQ=request_new_run")
			_on_request_new_run()
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
				"UI_RunRoot/Phase_INTRO",
				"UI_RunRoot/Phase_FIRST_REACTION",
				"UI_RunRoot/Phase_RESOLUTION",
				"UI_RunRoot/Phase_MID_CHOICE",
				"UI_RunRoot/Phase_PUSH_YOUR_LUCK",
				"UI_RunRoot/Phase_END_RUN",
			]
			for ui_path: String in required_ui_paths:
				if _sanity_ui_root.get_node_or_null(ui_path) == null:
					errors.append("UI node missing at path '%s'" % ui_path)
	if errors.size() > 0:
		_abort_sanity("SANITY FAIL: %s" % "; ".join(errors))
		return false
	return true

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
	_enter_end_run("INFRA_FAILURE")

func request_new_game() -> void:
	if _resolving_arena or _waiting_for_bet or _waiting_for_push_luck or _waiting_for_intermediate_choice:
		print("RunManager: forcing new run while flow is active.")
	_start_new_run()

func _guard_request_phase(request_name: String, allowed_phases: Array[RunPhase]) -> bool:
	_touch_request_activity(request_name)
	for allowed_phase: RunPhase in allowed_phases:
		if _phase == allowed_phase:
			return true
	push_error(_flow_diagnostics.format_wrong_phase_request_error(request_name, str(_phase), str(allowed_phases), _flow_logger.dump_last(30), _flow_snapshot("wrong_phase")))
	return false

func _require_phase(expected_phase: RunPhase, context: String, gate_ok: bool = true) -> bool:
	if gate_ok and _phase == expected_phase:
		return true
	push_error("RunManager: %s in wrong phase %s\nSNAPSHOT:\n%s" % [context, str(_phase), _flow_snapshot(context)])
	return false

func _guard_phase(expected_phase: int, context: String) -> bool:
	_touch_request_activity(context)
	if _phase == expected_phase:
		return true
	push_error(
		_flow_diagnostics.format_wrong_phase_request_error(
			context,
			str(_phase),
			str([expected_phase]),
			_flow_logger.dump_last(30),
			_flow_snapshot(context)
		)
	)
	return false

func _flow_snapshot(note: String) -> String:
	return _flow_watchdog.build_snapshot(
		note,
		str(_phase),
		_last_request,
		_last_phase_change_ms,
		_last_ui_render_ms,
		_last_activity_ms,
		_flow_logger.dump_last(60)
	)


func request_confirm_pact() -> void:
	_touch_request_activity("request_confirm_pact()")
	if not _require_phase(RunPhase.BET_PRESENT, "request_confirm_pact", _waiting_for_bet):
		return
	var pending_bet_id: StringName = _run_state.last_selected_bet_id
	if pending_bet_id == &"":
		push_error("RunManager: request_confirm_pact has no selected pact to confirm\nSNAPSHOT:\n%s" % _flow_snapshot("request_confirm_pact_missing_bet"))
		return
	_confirm_pact_with_bet_id(pending_bet_id)

func request_choose_mid(index: int) -> void:
	_touch_request_activity("request_choose_mid(index=%d)" % index)
	if not _require_phase(RunPhase.INTERMEDIATE_CHOICE, "request_choose_mid", _waiting_for_intermediate_choice):
		return
	if index == 0:
		_apply_intermediate_choice("placa")
		return
	if index == 1:
		_apply_intermediate_choice("provoca")
		return
	push_error("RunManager: request_choose_mid invalid index %d\nSNAPSHOT:\n%s" % [index, _flow_snapshot("request_choose_mid_invalid")])

func request_push_your_luck() -> void:
	_touch_request_activity("request_push_your_luck()")
	if not _require_phase(RunPhase.PUSH_YOUR_LUCK, "request_push_your_luck", _waiting_for_push_luck):
		return
	_push_your_luck()

func request_take_payout() -> void:
	_touch_request_activity("request_take_payout()")
	if not _require_phase(RunPhase.PUSH_YOUR_LUCK, "request_take_payout", _waiting_for_push_luck):
		return
	_take_payout()

func request_quit_to_menu() -> void:
	_touch_request_activity("request_show_main_menu()")
	_set_phase(RunPhase.MAIN_MENU, "request_show_main_menu")

func request_load_continue() -> void:
	_touch_request_activity("request_load_continue()")
	if _phase != RunPhase.MAIN_MENU and _phase != RunPhase.NONE:
		push_error("RunManager: request_load_continue in wrong phase %s\nSNAPSHOT:\n%s" % [str(_phase), _flow_snapshot("request_load_continue")])
		return
	var payload: Dictionary = _save_system.load_run_payload()
	if payload.is_empty():
		return
	if not _apply_run_save_payload(payload):
		_reject_invalid_continue_payload(_last_save_reject_reason)
		return
	_resume_run_from_save(_run_state.run_save_flow_step, _run_state.run_save_flow_bet_id)

func start_new_run() -> void:
	request_new_game()

func _start_new_run() -> void:
	_watchdog_enabled = true
	_run_counter += 1
	_flow_logger.set_run_id(_run_counter)
	_run_state.run_start_time_msec = Time.get_ticks_msec()
	_set_phase(RunPhase.RUN_INIT, "start_new_run")
	_start_level3_run()
	return

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
	_meta_unlock_emitted_this_run = false
	_end_run_meta_emitted = false
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
	_glory_multiplier = GLORY_MULT_BASE
	_run_state.run_seed = _get_run_seed_value()
	_initialize_scar_rng_state()
	_run_state.scar_double_count = 0
	_run_state.scar_pact_count = 0
	_run_state.volatility = 0
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
	_runstate_kernel.enforce_invariants(_run_state)
	_emit_escalation_changed()
	_level3_rng.seed = _run_state.run_seed
	_run_state.level3_target_arenas = _level3_rng.randi_range(5, 8)
	_run_state.level3_min_cashout_arenas = 5
	_run_state.special_arena_index = _pick_special_arena_index(_run_state.level3_target_arenas)

	_reset_scars()
	run["coins"] = starting_coins
	run["arena_index"] = 0
	run["corruption"] = 0
	_run_state.corruption = 0
	_runstate_kernel.enforce_invariants(_run_state)
	_reset_upgrades()

	GameEvents.run_started.emit()
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))
	_set_runtime_gate_phase(RunPhase.PREP)
	_update_arena_visual_only()
	_emit_run_debug_state()
	start_arena()
	if not _waiting_for_bet:
		_open_level3_bet_ui()

func start_arena() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_run_state.arena_index = maxi(_run_state.arena_index + 1, 1)
	run["arena_index"] = _run_state.arena_index
	_emit_arena_theme_changed()
	_maybe_activate_special_arena()
	_select_enemy_profile()
	if _run_state.enemy_profile != &"":
		_run_state.enemy_profiles.append(_run_state.enemy_profile)
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
		_runstate_kernel.append_bet_history(_run_state, {"bet_id": String(bet_id)})
		_append_pact_log_entry(bet_id, _get_level3_bet_name(bet_id))
		_run_state.last_signed_pact_id = bet_id
		_register_pact_corruption(bet_id)
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
	_start_pact_sealed_ritual(bet_id)

func _start_pact_sealed_ritual(bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_pact_sealed_sequence_id += 1
	var sequence_id: int = _pact_sealed_sequence_id
	_close_audience_context_line()
	_flow_log("pact_sealed_opened", "arena=%d, bet_id=%s" % [_run_state.arena_index, String(bet_id)])
	_smoke_mark("PACT_SEALED_OPENED")
	GameEvents.pact_sealed_opened.emit()
	await get_tree().create_timer(PACT_SEALED_SECONDS).timeout
	if sequence_id != _pact_sealed_sequence_id:
		return
	GameEvents.pact_sealed_closed.emit()
	_smoke_mark("PACT_SEALED_CLOSED")
	if _run_state.run_is_over or _is_game_over:
		return
	_open_intermediate_choice(bet_id)

func _start_resolve_ritual(bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	if not _ensure_flow_panel("UI_RunRoot/Phase_RESOLUTION", "resolve ritual"):
		return
	_resolving_ritual = true
	_resolve_ritual_sequence_id += 1
	var sequence_id: int = _resolve_ritual_sequence_id
	var payload: Dictionary = _ui_payload_factory.build_resolve_ritual_payload(
		bet_id,
		_get_level3_bet_name(bet_id),
		_get_level3_doom_short(bet_id)
	)
	_flow_log("resolve_ritual_opened", "arena=%d, bet_id=%s" % [_run_state.arena_index, String(bet_id)])
	_smoke_mark("RESOLVE_OPENED")
	GameEvents.resolve_ritual_opened.emit(payload)
	await get_tree().create_timer(RESOLVE_RITUAL_SECONDS).timeout
	if sequence_id != _resolve_ritual_sequence_id:
		return
	GameEvents.resolve_ritual_closed.emit()
	_flow_log("resolve_ritual_closed", "arena=%d, bet_id=%s" % [_run_state.arena_index, String(bet_id)])
	_smoke_mark("RESOLVE_CLOSED")
	_resolving_ritual = false
	if _run_state.run_is_over or _is_game_over:
		return
	_resolve_ritual_outcome(bet_id)

func _resolve_ritual_outcome(bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_resolving_arena = true
	_update_arena_visual_only()
	_set_runtime_gate_phase(RunPhase.LIVE)
	GameEvents.arena_started.emit(_run_state.arena_index)
	_play_arena_resolution_fx()
	_apply_special_arena_pre_resolution()
	var result: ArenaResult = _resolve_level3_arena()
	_update_audience_after_arena(result)
	_run_state.arenas_cleared = maxi(_run_state.arenas_cleared + 1, 1)
	GameEvents.arena_completed.emit(_run_state.arena_index)
	var failed: bool = not result.won
	var scars_applied: Array[StringName] = []
	if failed:
		_apply_intermediate_loss_penalty_if_needed()
		scars_applied = _handle_level3_loss_ritual(bet_id, result)
	else:
		_apply_glory_on_success()
		_run_state.last_action_was_rilancio = false
		_run_state.risky_choice_made_recently = false
		_apply_level3_reward(bet_id, _run_state.level3_reward_tier)
		_resolve_ritual_reward_applied = true
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
	_open_push_luck_choice(bet_id)
	_autosave_run_checkpoint(RUN_FLOW_INTERMEDIATE_CHOICE, bet_id)

func _apply_resolution_advance_state() -> void:
	_resolving_arena = true
	_update_arena_visual_only()
	_set_runtime_gate_phase(RunPhase.LIVE)
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
	if failed:
		_apply_intermediate_loss_penalty_if_needed()
		scars_applied = _handle_level3_loss(bet_id, result)
	else:
		_apply_glory_on_success()
		_handle_level3_win(bet_id, result)
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
	_open_push_luck_choice(bet_id)
	_autosave_run_checkpoint(RUN_FLOW_INTERMEDIATE_CHOICE, bet_id)

func resolve_arena() -> void:
	_pending_resolution_bet_id = _run_state.active_bet_id
	_set_phase(RunPhase.RESOLUTION, "resolve_arena")

func _enter_resolution() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	var view: Dictionary = _phase_resolution_handler.build_view(_run_state)
	_emit_ui(_build_phase_ui_payload(RunPhase.RESOLUTION, str(view.get("title", "")), str(view.get("body", ""))))
	var res: PhaseResult = _phase_resolution_handler.handle_request("request_resolution_advance", _run_state, {})
	if not res.handled:
		return
	_apply_mutation_plan(res)
	return

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
	start_arena()

func reset_run() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	run["coins"] = starting_coins
	start_new_run()

func _open_bet_ui(_from_victory: bool = false) -> void:
	_open_level3_bet_ui()

func _open_level3_bet_ui() -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_set_phase(RunPhase.BET_PRESENT, "open_level3_bet_ui")
	_waiting_for_bet = true
	_waiting_for_push_luck = false
	_resolve_ritual_reward_applied = false
	_set_runtime_gate_phase(RunPhase.PREP)
	_update_arena_visual_only()
	GameEvents.betting_opened.emit()
	var offer: Array[Dictionary] = _build_level3_bet_offer()
	_run_state.level3_current_offer = offer.duplicate(true)
	var offer_payload: Dictionary = _betting_payload_factory.build_bet_offer_payload({"offer": offer})
	var emitted_offer: Array[Dictionary] = offer_payload.get("offer", []) as Array[Dictionary]
	_flow_log("bet_ui_opened", "arena=%d, bet_id=" % _run_state.arena_index)
	GameEvents.bet_ui_opened.emit(emitted_offer)
	GameEvents.bet_opened.emit()

func _build_level3_bet_offer() -> Array[Dictionary]:
	var available: Array[Dictionary] = BetCatalog.level3_active_bets()
	var desired_count: int = BetCatalog.level3_active_bet_ids().size()
	var offer_seed: int = _compute_level3_offer_seed()
	var result: Dictionary = _betting_policy.build_bet_offer(
		offer_seed,
		_run_state.arena_index,
		_run_state.corruption,
		_run_state.glory,
		_run_state.doubles,
		_run_state.bets_history,
		{
			"available_bets": available,
			"desired_count": desired_count,
			"last_bet_offers": _run_state.last_bet_offers,
			"last_selected_bet_id": _run_state.last_selected_bet_id,
			"forced_archetype": _run_state.forced_next_pact_archetype,
			"registry_has_precedent": _registry_has_precedent,
			"level3_bet_behavior": LEVEL3_BET_BEHAVIOR,
			"high_risk_behaviors": [BET_DOUBLE_OR_DIE_L3, BET_DEBT_CHAIN, BET_BLOOD_TAX, BET_LAST_BREATH],
			"cash_out_behavior": BET_CASH_OUT,
		}
	)
	var picks: Array[Dictionary] = result.get("offer", []) as Array[Dictionary]
	_run_state.last_bet_offers = result.get("last_bet_offers", []) as Array[StringName]
	if bool(result.get("clear_forced_archetype", false)):
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
	var unlock_id: StringName = BetCatalog.get_level3_pact_unlock(bet_id)
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

func _initialize_scar_rng_state() -> void:
	if _run_state.scar_rng_state != 0:
		return
	var derived_seed: int = (_run_state.run_seed * 1103515245 + _run_counter * 12345) & 0x7fffffff
	if derived_seed <= 0:
		derived_seed = 1
	_run_state.scar_rng_state = derived_seed
	_run_state.scar_roll_index = 0

func _scar_roll(chance: float) -> bool:
	_initialize_scar_rng_state()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.state = _run_state.scar_rng_state
	var safe_chance: float = clampf(chance, 0.0, 1.0)
	var success: bool = rng.randf() <= safe_chance
	_run_state.scar_rng_state = int(rng.state)
	_run_state.scar_roll_index += 1
	return success

func _apply_corruption(delta: int) -> void:
	_run_state.corruption = int(run.get("corruption", _run_state.corruption))
	_runstate_kernel.apply_failure(_run_state, {
		"corruption_delta": delta,
		"corruption_max": CORRUPTION_MAX,
	})
	run["corruption"] = _run_state.corruption

func _total_passive_scar_count() -> int:
	return _run_state.scar_double_count + _run_state.scar_pact_count

func _double_scar_base_chance(doubles_count: int) -> float:
	var idx: int = clampi(doubles_count - 1, 0, SCAR_DOUBLE_BASE_CHANCES.size() - 1)
	return SCAR_DOUBLE_BASE_CHANCES[idx]

func _try_apply_double_scar_pool(next_doubles_count: int) -> void:
	var base_chance: float = _double_scar_base_chance(next_doubles_count)
	var chance: float = base_chance * (1.0 / float(1 + _run_state.scar_double_count))
	if _scar_roll(chance):
		_run_state.scar_double_count += 1
		_apply_corruption(1)
		_run_state.volatility += 1
	_apply_corruption(CORRUPTION_DOUBLE)
	var total_scars: int = _total_passive_scar_count()
	if total_scars > 0:
		var pressure_extra: int = mini(total_scars, 2)
		_apply_corruption(pressure_extra)
		_run_state.volatility += 1

func _try_apply_pact_scar_pool() -> void:
	var run_progress: int = mini(_run_state.arena_index, 5)
	var base_chance: float = clampf(SCAR_PACT_BASE_MIN + SCAR_PACT_STEP * float(run_progress), SCAR_PACT_BASE_MIN, SCAR_PACT_BASE_MAX)
	var chance: float = base_chance * (1.0 / float(1 + _run_state.scar_pact_count))
	if not _scar_roll(chance):
		return
	_run_state.scar_pact_count += 1
	_apply_corruption(1)
	_run_state.volatility += 1

func _compute_volatility_shift() -> int:
	if _run_state.volatility <= 0:
		return 0
	var trigger_chance: float = clampf(0.12 * float(_run_state.volatility), 0.0, 0.66)
	if not _scar_roll(trigger_chance):
		return 0
	var direction: int = 1 if _scar_roll(0.5) else -1
	var amplitude: int = mini(_run_state.volatility, SCAR_VOLATILITY_SHIFT_CAP)
	return direction * amplitude

func _emit_run_debug_state() -> void:
	if not GameEvents.has_signal("run_debug_state_updated"):
		return
	var scars_copy: Array[String] = _serialize_stringname_array(_run_state.scars_history)
	var resolve_debug_payload: Dictionary = {}
	if OS.is_debug_build():
		resolve_debug_payload = _last_resolve_debug.duplicate(true)
	var payload: Dictionary = _flow_diagnostics.build_run_debug_payload(_run_state.run_seed, _run_state.arena_index, _run_state.escalation_level, String(_run_state.active_bet_id), String(_run_state.enemy_profile), scars_copy, String(_run_state.special_arena_id), _run_state.special_arena_active, _run_state.is_hunted_by_crowd, _run_state.glory, int(run.get("corruption", 0)), _run_state.scar_double_count, _run_state.scar_pact_count, _run_state.volatility, resolve_debug_payload)
	GameEvents.run_debug_state_updated.emit(payload)

func _apply_glory_on_success() -> void:
	_runstate_kernel.apply_success(_run_state, {
		"glory_per_success": GLORY_PER_SUCCESS,
		"glory_multiplier": _glory_multiplier,
	})

func _update_glory_multiplier_from_doubles(double_count: int) -> void:
	var safe_count: int = maxi(double_count, 0)
	var idx: int = mini(safe_count, GLORY_MULT_STEPS.size() - 1)
	_glory_multiplier = GLORY_MULT_STEPS[idx]

func _autosave_run_checkpoint(flow_step: StringName, bet_id: StringName) -> void:
	if _run_state.run_is_over or _is_game_over:
		return
	_run_state.run_save_flow_step = flow_step
	_run_state.run_save_flow_bet_id = bet_id
	var runtime_fields: Dictionary = _save_boundary.build_run_payload(_run_state, run)
	var pacts_log: Array[Dictionary] = []
	for entry: PactLogEntry in _run_state.pacts_log:
		pacts_log.append(entry.to_dict())
	runtime_fields["scars"] = _serialize_run_scars(_run_state.scars)
	runtime_fields["pacts_log"] = pacts_log
	runtime_fields["scars_detail"] = _serialize_scars_detail()
	_save_system.save_run_payload(_save_continue_boundary.build_save_payload(_run_state, runtime_fields))

func _apply_run_save_payload(payload: Dictionary) -> bool:
	_last_save_reject_reason = ""
	var result: Dictionary = _save_continue_boundary.apply_payload_to_state(_run_state, payload)
	if not bool(result.get("ok", false)):
		_last_save_reject_reason = str(result.get("reason", "invalid_continue_payload"))
		return false

	var run_state_data: Dictionary = result.get("run_state", {}) as Dictionary
	var applied_runtime: Dictionary = result.get("applied_runtime", {}) as Dictionary
	var parsed_scars: Array[Scar] = _parse_run_scars(run_state_data.get("scars", []) as Array)
	var parsed_pacts: Array[PactLogEntry] = _parse_pacts_log(run_state_data.get("pacts_log", []))
	var next_payload: Dictionary = {
		"arena_index": int(applied_runtime.get("arena_index", _run_state.arena_index)),
		"coins": int(applied_runtime.get("coins", starting_coins)),
		"corruption": clampi(int(applied_runtime.get("corruption", 0)), 0, CORRUPTION_MAX),
		"glory": int(run_state_data.get("glory", _run_state.glory)),
	}

	_pact_sealed_sequence_id += 1
	_resolve_ritual_sequence_id += 1
	_resolving_ritual = false
	_resolving_arena = false
	_run_failed_emitted = false
	_run_ended_emitted = false
	_meta_unlock_emitted_this_run = false
	_run_state.run_finale_emitted = false
	_run_state.run_end_reason = ""
	_run_state.run_end_public_reason = ""
	_is_game_over = false
	_has_started_run = true
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_waiting_for_intermediate_choice = false

	_run_state.scars = parsed_scars
	_run_state.pacts_log = parsed_pacts
	_run_state.intermediate_pending_bet_id = &""
	_run_state.post_bet_pending_bet_id = &""
	_save_boundary.apply_run_payload(_run_state, run, next_payload)
	_runstate_kernel.enforce_invariants(_run_state)
	_initialize_scar_rng_state()
	_update_glory_multiplier_from_doubles(_run_state.level3_doubles)

	run["upgrades"] = {}

	if _run_state.level3_target_arenas <= 0:
		_level3_rng.seed = _run_state.run_seed
		_run_state.level3_target_arenas = _level3_rng.randi_range(5, 8)
	if _run_state.special_arena_index <= 0 and _run_state.level3_target_arenas > 0:
		_run_state.special_arena_index = _pick_special_arena_index(_run_state.level3_target_arenas)

	if result.has("scars_detail") and result["scars_detail"] is Array:
		_apply_scars_detail(result["scars_detail"] as Array)
	else:
		_emit_scars_updated()

	_level3_rng.seed = _run_state.run_seed
	GameEvents.set_gameplay_enabled(true)
	GameEvents.coins_changed.emit(int(run.get("coins", starting_coins)))

	_emit_escalation_changed()
	_emit_run_debug_state()
	_update_arena_visual_only()
	return true


func _reject_invalid_continue_payload(reason: String) -> void:
	var final_reason: String = reason
	if final_reason == "":
		final_reason = "invalid_continue_payload"
	_flow_log("continue_rejected", final_reason)
	push_warning("RUN_SAVE_REJECTED: %s" % final_reason)
	if Engine.has_singleton("GameEvents") and GameEvents != null and GameEvents.has_signal("continue_rejected"):
		GameEvents.continue_rejected.emit(final_reason)
	_save_system.clear_run()
	_set_phase(RunPhase.MAIN_MENU, "continue_rejected_invalid_save")

func _resume_run_from_save(flow_step: StringName, bet_id: StringName) -> void:
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_waiting_for_intermediate_choice = false
	_run_state.intermediate_pending_bet_id = &""
	_run_state.post_bet_pending_bet_id = &""
	_set_runtime_gate_phase(RunPhase.PREP)
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
	_open_level3_bet_ui()

func _serialize_stringname_array(items: Array) -> Array[String]:
	var values: Array[String] = []
	for item in items:
		var text: String = str(item)
		if text == "":
			continue
		values.append(text)
	return values

func _serialize_run_scars(items: Array) -> Array[Dictionary]:
	var values: Array[Dictionary] = []
	for item: Scar in items:
		values.append(item.to_dict())
	return values

func _parse_run_scars(items: Array) -> Array[Scar]:
	var values: Array[Scar] = []
	for item in items:
		var scar_data: Dictionary = item as Dictionary
		values.append(Scar.from_dict(scar_data))
	return values

func _serialize_scars_detail() -> Array[Dictionary]:
	var details: Array[Dictionary] = []
	for scar_value: Dictionary in _run_state.scars_payload:
		var detail: Dictionary = scar_value.duplicate(true)
		if detail.has("id"):
			detail["id"] = String(detail.get("id", ""))
		details.append(detail)
	return details

func _apply_scars_detail(details: Array) -> void:
	_run_state.scars_payload = []
	for value in details:
		if not (value is Dictionary):
			continue
		var detail: Dictionary = value as Dictionary
		if detail.has("id"):
			detail["id"] = StringName(str(detail.get("id", "")))
		_run_state.scars_payload.append(detail)
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
	var is_finita_unlocked: bool = _is_unlocked(CONDANNA_E_FINITA_COSI)
	var is_so_come_finisce_unlocked: bool = _is_unlocked(CONDANNA_SO_COME_FINISCE)
	return _arena_theme_policy.get_available_arena_theme_ids(is_finita_unlocked, is_so_come_finisce_unlocked)

func _pick_next_arena_theme() -> StringName:
	var arena_index: int = _get_current_arena_index()
	var themes: Array[StringName] = _get_available_arena_theme_ids()
	return _arena_theme_policy.pick_next_arena_theme(arena_index, themes)

func _emit_arena_theme_changed() -> void:
	if not GameEvents.has_signal("arena_theme_changed"):
		return
	_run_state.arena_theme_id = _pick_next_arena_theme()
	var theme_data: Dictionary = _arena_themes.get_theme(_run_state.arena_theme_id)
	var payload: Dictionary = _ui_payload_factory.build_arena_theme_payload(
		_run_state.arena_theme_id,
		str(theme_data.get("title", "")),
		str(theme_data.get("subtitle", "")),
		str(theme_data.get("bg_texture_path", "")),
		str(theme_data.get("overlay_texture_path", ""))
	)
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
	return _arena_theme_policy.pick_special_arena_index(target_arenas, _run_state.run_seed, _level3_rng)

func _maybe_activate_special_arena() -> void:
	_run_state.special_arena_active = false
	_run_state.special_arena_effect_applied = false
	var should_activate: bool = _arena_theme_policy.should_activate_special_arena(_run_state.arena_index, _run_state.special_arena_index, _run_state.special_arena_id)
	if not should_activate:
		return
	_run_state.special_arena_id = _arena_theme_policy.pick_special_arena_id(_run_state.run_seed, _run_state.arena_index, _level3_rng)
	_run_state.special_arena_active = true
	_emit_special_arena_started()

func _emit_special_arena_started() -> void:
	if not GameEvents.has_signal("special_arena_started"):
		return
	if _run_state.special_arena_id == &"":
		return
	var payload: Dictionary = _ui_payload_factory.build_special_arena_payload(
		_run_state.special_arena_id,
		_get_special_arena_title(_run_state.special_arena_id),
		_get_special_arena_description(_run_state.special_arena_id),
		_run_state.arena_index
	)
	GameEvents.special_arena_started.emit(payload)

func _get_special_arena_title(arena_id: StringName) -> String:
	return _arena_theme_policy.get_special_arena_title(arena_id)

func _get_special_arena_description(arena_id: StringName) -> String:
	return _arena_theme_policy.get_special_arena_description(arena_id)

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

func _log_level3_arena_result(bet_id: StringName, result: ArenaResult, scars_applied: Array[StringName]) -> void:
	var scar_names: Array[String] = []
	var bet_token: String = BetCatalog.get_bet_debug_token(bet_id)
	for scar_name: StringName in scars_applied:
		scar_names.append(String(scar_name))
	print(
		"Level3 Arena Result | seed=",
		_run_state.run_seed,
		" arena=",
		_run_state.arena_index,
		" bet=",
		bet_token,
		" enemy=",
		String(_run_state.enemy_profile),
		" won=",
		result.won,
		" condemnation_flag=",
		result.condemnation_flag,
		" scars_applied=",
		scar_names
	)

func _get_active_scar_ids() -> Array[StringName]:
	var scar_ids: Array[StringName] = []
	for scar: Dictionary in _run_state.scars_payload:
		var scar_id: StringName = StringName(str(scar.get("id", "")))
		if scar_id != &"":
			scar_ids.append(scar_id)
	return scar_ids

func _resolve_level3_arena() -> ArenaResult:
	var result: ArenaResult = ArenaResult.new()
	var effective_escalation: int = _run_state.escalation_level
	if _registry_has_precedent:
		effective_escalation += 1
	var volatility_shift: int = _compute_volatility_shift()
	var outcome_seed: int = _compute_level3_seed(_run_state.active_bet_id) + volatility_shift * 97
	var adjusted_escalation: int = maxi(effective_escalation + volatility_shift, 0)
	var payload: Dictionary = _outcome_system.resolve_level3_arena(
		_level3_rng,
		outcome_seed,
		adjusted_escalation,
		_get_active_scar_ids(),
		_run_state.enemy_profile,
		LEVEL3_ENEMY_PROFILES
	)
	result.won = bool(payload.get("won", false))
	result.condemnation_flag = bool(payload.get("condemnation_flag", false))
	_last_resolve_debug = payload.get("resolve_debug", {}) as Dictionary
	_flow_logger.log_resolve_debug(_last_resolve_debug)
	var notes_payload: Array = payload.get("notes", []) as Array
	result.notes.clear()
	for note_value: Variant in notes_payload:
		result.notes.append(StringName(str(note_value)))
	return result

func _get_level3_bet_behavior(bet_id: StringName) -> StringName:
	var mapped: StringName = BetCatalog.map_level3_behavior(bet_id)
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
	_set_runtime_gate_phase(RunPhase.PREP)
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
	var end_reason: String = str(consequence.get("end_reason", ""))
	if end_reason == "PROVOCA_FAIL":
		_run_state.provoke_armed = false
		_register_run_end("PROVOCA_FAIL")
		_enter_end_run("")
		return scars_applied
	if end_reason == "THE_FOOL":
		_register_run_end("DOUBLE_OR_DIE")
		end_run(&"THE_FOOL")
		return scars_applied
	var corruption_gain: int = int(consequence.get("corruption_gain", 0))
	if corruption_gain > 0:
		_apply_corruption(corruption_gain)
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
	_set_runtime_gate_phase(RunPhase.PREP)
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
	var end_reason: String = str(consequence.get("end_reason", ""))
	if end_reason == "PROVOCA_FAIL":
		_run_state.provoke_armed = false
		_register_run_end("PROVOCA_FAIL")
		_enter_end_run("")
		return scars_applied
	if end_reason == "THE_FOOL":
		_register_run_end("DOUBLE_OR_DIE")
		end_run(&"THE_FOOL")
		return scars_applied
	var corruption_gain: int = int(consequence.get("corruption_gain", 0))
	if corruption_gain > 0:
		_apply_corruption(corruption_gain)
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

func _ensure_arena_and_player() -> void:
	return

func _ensure_input_map() -> void:
	var actions: Dictionary = {
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

	print("InputMap ensured: system bindings ready")

func _apply_phase_result(res: PhaseResult) -> void:
	if res == null or not res.handled:
		return
	for event_name: String in res.emit_events:
		_flow_event_router.emit_by_name(event_name, res.ui_payload)
	if res.next_phase >= 0:
		_set_phase(res.next_phase, "apply_phase_result")

func _mut_pyl_cashout(_step: Dictionary) -> void:
	request_take_payout()

func _mut_pyl_double(_step: Dictionary) -> void:
	request_push_your_luck()

func _mut_pyl_condanna(_step: Dictionary) -> void:
	_handle_push_luck_condanna()

func _mut_betp_place_bet(step: Dictionary) -> void:
	if not step.has("bet_id"):
		_report_mutation_executor_error("BETP_PLACE_BET missing bet_id")
		return
	var bet_id: String = str(step.get("bet_id", ""))
	_debug_bet_choice_received(bet_id)
	select_bet(StringName(bet_id))

func _mut_intro_select_bet(step: Dictionary) -> void:
	if not step.has("bet_id"):
		_report_mutation_executor_error("INTRO_SELECT_BET missing bet_id")
		return
	_apply_intro_select_bet_request(str(step.get("bet_id", "")))

func _mut_intro_confirm(_step: Dictionary) -> void:
	request_confirm_pact()

func _mut_intm_select(step: Dictionary) -> void:
	if not step.has("index"):
		_report_mutation_executor_error("INTM_SELECT missing index")
		return
	request_choose_mid(int(step.get("index", -1)))

func _mut_resolution_advance(_step: Dictionary) -> void:
	_apply_resolution_advance_state()

func _mut_gameover_show_menu(_step: Dictionary) -> void:
	request_quit_to_menu()

func _mut_gameover_restart(_step: Dictionary) -> void:
	request_new_game()

func _mut_mainmenu_new_run(_step: Dictionary) -> void:
	_clear_run_from_executor()
	request_new_game()

func _mut_mainmenu_continue_run(_step: Dictionary) -> void:
	request_load_continue()

func _mut_mainmenu_show_menu(_step: Dictionary) -> void:
	_debug_show_main_menu_received()
	request_quit_to_menu()

func _apply_state_mutation(name: String) -> void:
	_apply_state_mutation_step({"name": name})

func _build_flow_executor_hooks() -> RunFlowExecutorHooks:
	return RunFlowExecutorHooksScript.new(
		Callable(self, "_flow_log"),
		Callable(self, "_autosave_run_checkpoint_from_executor"),
		Callable(self, "_set_phase"),
		Callable(self, "_end_run_from_pyl"),
		Callable(self, "_report_mutation_executor_error")
	)

func _apply_state_mutation_step(step: Dictionary) -> void:
	_flow_mutation_registry.apply(step)

func _autosave_run_checkpoint_from_executor(checkpoint: StringName) -> void:
	_autosave_run_checkpoint(checkpoint, &"")

func _clear_run_from_executor() -> void:
	_save_system.clear_run()

func _report_mutation_executor_error(message: String) -> void:
	push_error(message)

func _debug_bet_choice_received(bet_id: String) -> void:
	print_debug("[FLOW] bet_choice_received :: arena=%d, bet_id=%s" % [_run_state.arena_index, bet_id])

func _debug_show_main_menu_received() -> void:
	print_debug("[FLOW] request_show_main_menu_received")

func _end_run_from_pyl(reason: String) -> void:
	if reason != "":
		_register_run_end(reason)
	end_run(&"")

func _apply_mutation_plan(res: PhaseResult) -> void:
	_flow_executor.apply_mutation_plan(res)

func _route_guarded_phase_request(
	request_name: String,
	allowed_phases: Array[RunPhase],
	handler: Variant,
	payload: Dictionary,
	legacy_callback: Callable = Callable()
) -> bool:
	if not _guard_request_phase(request_name, allowed_phases):
		return false
	if handler == null:
		if legacy_callback.is_valid():
			legacy_callback.call()
		return true
	var typed_handler: RunPhaseHandlerBase = handler as RunPhaseHandlerBase
	if typed_handler == null:
		return false
	return _request_router.route_guarded_phase_request(
		request_name,
		allowed_phases,
		payload,
		_run_state,
		Callable(self, "_guard_request_phase"),
		Callable(typed_handler, "handle_request"),
		Callable(self, "_apply_mutation_plan")
	)

func _dispatch_phase_request(request_name: String, payload: Dictionary) -> PhaseResult:
	var handler: RunPhaseHandlerBase = _phase_handler_map.get(_phase, null)
	if handler != null and handler.can_accept_request(request_name):
		var result: PhaseResult = handler.handle_request(request_name, _run_state, payload)
		if result.handled:
			return result
	if request_name == "request_new_run" or request_name == "request_continue_run" or request_name == "request_show_main_menu":
		if not _phase_main_menu_handler.can_accept_request(request_name):
			return PhaseResult.new()
		return _phase_main_menu_handler.handle_request(request_name, _run_state, payload)
	return PhaseResult.new()

# FLOW: MainMenu -> GameEvents.request_new_run -> RunManager.start_new_run -> UI updates
# Preconditions: RunManager exists (group "run_manager") and listens to GameEvents.request_new_run.
# Postconditions: Active run state is reset and GameEvents.run_started is emitted.
func _on_request_new_run() -> void:
	_route_guarded_phase_request("request_new_run", [RunPhase.NONE, RunPhase.PREP, RunPhase.LIVE, RunPhase.GAME_OVER, RunPhase.MAIN_MENU, RunPhase.RUN_INIT, RunPhase.BET_PRESENT, RunPhase.BET_COMMITTED, RunPhase.INTERMEDIATE_CHOICE, RunPhase.PUSH_YOUR_LUCK, RunPhase.NEXT_BET, RunPhase.RESOLUTION], _phase_main_menu_handler, {})
	return

func _on_request_reset_run() -> void:
	_touch_request_activity("request_reset_run()")
	_route_guarded_phase_request("request_reset_run", [RunPhase.MAIN_MENU, RunPhase.NONE, RunPhase.GAME_OVER], _phase_main_menu_handler, {})
	return

func _on_request_retry_run() -> void:
	_touch_request_activity("request_retry_run()")
	_route_guarded_phase_request("request_retry_run", [RunPhase.GAME_OVER], _phase_game_over_handler, {})
	return

func _on_request_continue_run() -> void:
	_route_guarded_phase_request("request_continue_run", [RunPhase.NONE, RunPhase.PREP, RunPhase.LIVE, RunPhase.GAME_OVER, RunPhase.MAIN_MENU, RunPhase.RUN_INIT, RunPhase.BET_PRESENT, RunPhase.BET_COMMITTED, RunPhase.INTERMEDIATE_CHOICE, RunPhase.PUSH_YOUR_LUCK, RunPhase.NEXT_BET, RunPhase.RESOLUTION], _phase_main_menu_handler, {})
	return

func _on_request_show_main_menu() -> void:
	_route_guarded_phase_request("request_show_main_menu", [RunPhase.MAIN_MENU, RunPhase.NONE, RunPhase.GAME_OVER, RunPhase.RUN_INIT, RunPhase.BET_PRESENT, RunPhase.BET_COMMITTED, RunPhase.INTERMEDIATE_CHOICE, RunPhase.PUSH_YOUR_LUCK, RunPhase.RESOLUTION, RunPhase.NEXT_BET], _phase_main_menu_handler, {})
	return

func _on_request_intro_apply_seed(seed_text: String) -> void:
	_touch_request_activity("request_intro_apply_seed(seed_text=%s)" % seed_text)
	if not _guard_request_phase("request_intro_apply_seed", [RunPhase.RUN_INIT, RunPhase.BET_PRESENT]):
		return
	var normalized_text: String = seed_text.strip_edges()
	if normalized_text == "":
		_on_request_clear_run_seed()
		return
	if not normalized_text.is_valid_int():
		push_error("RunManager: request_intro_apply_seed invalid seed '%s'" % seed_text)
		return
	_on_request_set_run_seed(int(normalized_text))
	if _phase == RunPhase.RUN_INIT:
		_enter_intro()
	else:
		_enter_bet_present()

func _on_request_intro_select_bet(bet_id: String) -> void:
	_touch_request_activity("request_intro_select_bet(bet_id=%s)" % bet_id)
	_route_guarded_phase_request("request_place_bet", [RunPhase.BET_PRESENT], _phase_bet_present_handler, {"bet_id": bet_id})
	return

func _apply_intro_select_bet_request(bet_id: String) -> void:
	if not _waiting_for_bet:
		push_error("RunManager: request_intro_select_bet in wrong phase %s" % [str(_phase)])
		return
	var selected_bet_id: StringName = StringName(bet_id.strip_edges())
	if selected_bet_id == &"":
		push_error("RunManager: request_intro_select_bet missing bet id")
		return
	var offer_has_bet: bool = false
	for offer_value in _run_state.level3_current_offer:
		var offer_entry: Dictionary = offer_value as Dictionary
		if StringName(str(offer_entry.get("id", ""))) == selected_bet_id:
			offer_has_bet = true
			break
	if not offer_has_bet:
		push_error("RunManager: request_intro_select_bet invalid bet '%s'" % bet_id)
		return
	_run_state.last_selected_bet_id = selected_bet_id
	_enter_bet_present()

func _on_request_intro_confirm() -> void:
	_touch_request_activity("request_intro_confirm()")
	_route_guarded_phase_request("request_intro_confirm", [RunPhase.BET_PRESENT], _phase_bet_present_handler, {})
	return

func _on_request_mid_choice_select(index: int) -> void:
	_touch_request_activity("request_mid_choice_select(index=%d)" % index)
	_flow_logger.log_request("request_mid_choice_select", "index=%d" % index)
	_route_guarded_phase_request("request_mid_choice_select", [RunPhase.INTERMEDIATE_CHOICE], _phase_intermediate_choice_handler, {"index": index})
	return

func _on_request_pyl_cashout() -> void:
	_touch_request_activity("request_pyl_cashout()")
	_flow_logger.log_request("request_pyl_cashout")
	_route_guarded_phase_request("request_pyl_cashout", [RunPhase.PUSH_YOUR_LUCK], _phase_push_your_luck_handler, {})
	return

func _on_request_pyl_condanna() -> void:
	_touch_request_activity("request_pyl_condanna()")
	_flow_logger.log_request("request_pyl_condanna")
	_route_guarded_phase_request("request_pyl_condanna", [RunPhase.PUSH_YOUR_LUCK], _phase_push_your_luck_handler, {})
	return

func _on_request_pyl_double() -> void:
	_touch_request_activity("request_pyl_double()")
	_flow_logger.log_request("request_pyl_double")
	_route_guarded_phase_request("request_pyl_double", [RunPhase.PUSH_YOUR_LUCK], _phase_push_your_luck_handler, {})
	return

func _on_request_end_run_restart() -> void:
	_touch_request_activity("request_end_run_restart()")
	_route_guarded_phase_request("request_end_run_restart", [RunPhase.GAME_OVER], _phase_game_over_handler, {})
	return

func _on_request_end_run_next_bet() -> void:
	_touch_request_activity("request_end_run_next_bet()")
	_route_guarded_phase_request("request_end_run_next_bet", [RunPhase.GAME_OVER], _phase_game_over_handler, {})
	return

func _on_request_end_run_quit() -> void:
	_touch_request_activity("request_end_run_quit()")
	_route_guarded_phase_request("request_end_run_quit", [RunPhase.GAME_OVER], _phase_game_over_handler, {})
	return

func _on_request_place_bet(bet_id: String, _stake: int) -> void:
	_route_guarded_phase_request("request_place_bet", [RunPhase.BET_PRESENT], _phase_bet_present_handler, {"bet_id": bet_id})
	return

func _on_request_intermediate_choice(choice_id: String) -> void:
	_touch_request_activity("request_intermediate_choice(choice_id=%s)" % choice_id)
	if not _guard_request_phase("request_intermediate_choice", [RunPhase.INTERMEDIATE_CHOICE]):
		return
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
	_start_resolve_ritual(bet_id)
	_autosave_run_checkpoint(RUN_FLOW_PUSH_LUCK, bet_id)

func _on_post_arena_choice_selected(choice_id: StringName) -> void:
	if choice_id != &"CONDANNA":
		return
	_handle_push_luck_condanna()

func _on_request_push_luck_cashout() -> void:
	_touch_request_activity("request_push_luck_cashout()")
	_route_guarded_phase_request("request_pyl_cashout", [RunPhase.PUSH_YOUR_LUCK], _phase_push_your_luck_handler, {})
	return

func _take_payout() -> void:
	print_debug("[FLOW] push_luck_cashout_received :: arena=%d" % _run_state.arena_index)
	var audience_policy: Dictionary = _build_audience_reward_text()
	if not bool(audience_policy.get("cashout_enabled", true)):
		_refresh_push_luck_choice(StringName(_run_state.current_bet_id))
		return
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

func _handle_push_luck_condanna() -> void:
	if not _waiting_for_push_luck:
		return
	_consume_intermediate_choice_bonus()
	_waiting_for_push_luck = false
	_run_state.last_action_was_rilancio = false
	_update_arena_visual_only()
	GameEvents.push_luck_closed.emit()
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

func _on_request_push_luck_double() -> void:
	_touch_request_activity("request_push_luck_double()")
	_route_guarded_phase_request("request_pyl_double", [RunPhase.PUSH_YOUR_LUCK], _phase_push_your_luck_handler, {})
	return

func _push_your_luck() -> void:
	print_debug("[FLOW] push_luck_double_received :: arena=%d" % _run_state.arena_index)
	var lock_reason: String = _get_double_lock_reason()
	if lock_reason != "":
		return
	_run_state.refuse_cashout_count_this_run += 1
	_try_register_refused_closure_scar()
	if _run_state.escalation_level >= ESCALATION_HIGH_THRESHOLD or _run_state.refuse_cashout_count_this_run >= 3:
		_run_state.risky_choice_made_recently = true
	var critical_scars: bool = _run_state.scars_history.size() >= 3
	if critical_scars:
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
	var next_doubles_count: int = _run_state.level3_doubles + 1
	_try_apply_double_scar_pool(next_doubles_count)
	_run_state.level3_doubles = next_doubles_count
	_run_state.doubles += 1
	_update_glory_multiplier_from_doubles(_run_state.level3_doubles)
	_run_state.level3_max_escalation = maxi(_run_state.level3_max_escalation, _run_state.escalation_level)
	_run_state.max_escalation = maxi(_run_state.max_escalation, _run_state.escalation_level)
	_emit_escalation_changed()
	if _run_state.cashout_lock_remaining > 0:
		_run_state.cashout_lock_remaining = maxi(_run_state.cashout_lock_remaining - 1, 0)
	_run_state.level3_next_loss_hp_penalty = 30
	_emit_run_debug_state()
	start_arena()
	_autosave_run_checkpoint(RUN_FLOW_BET_OFFER, &"")

func _on_request_set_run_seed(run_seed: int) -> void:
	_touch_request_activity("request_set_run_seed(run_seed=%d)" % run_seed)
	if not _guard_request_phase("request_set_run_seed", [RunPhase.RUN_INIT, RunPhase.BET_PRESENT]):
		return
	_run_state.debug_seed_override_active = true
	_run_state.debug_seed_override = run_seed
	print("Debug seed override set:", run_seed)
	if _has_started_run:
		start_new_run()

func _on_request_clear_run_seed() -> void:
	_touch_request_activity("request_clear_run_seed()")
	if not _guard_request_phase("request_clear_run_seed", [RunPhase.RUN_INIT, RunPhase.BET_PRESENT]):
		return
	_run_state.debug_seed_override_active = false
	_run_state.debug_seed_override = 0
	print("Debug seed override cleared")
	if _has_started_run:
		start_new_run()

func _on_request_skip_arena_resolution() -> void:
	_touch_request_activity("request_skip_arena_resolution()")
	if not _guard_request_phase("request_skip_arena_resolution", [RunPhase.RESOLUTION, RunPhase.INTERMEDIATE_CHOICE, RunPhase.PUSH_YOUR_LUCK]):
		return
	if _run_state.run_is_over or _is_game_over:
		return
	if not OS.is_debug_build():
		return
	_debug_skip_level3_step()

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

func _on_bet_placed(_bet_id: String, _stake: int, _odds: float) -> void:
	return

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
	_set_runtime_gate_phase(RunPhase.LIVE)
	_autosave_run_checkpoint(RUN_FLOW_BET_SIGNED, &"")
	_emit_audience_context_line(AUDIENCE_CONTEXT_PACT_SIGNED)

func _on_betting_opened() -> void:
	pass

func _resolve_player() -> Node:
	if _player and is_instance_valid(_player) and _player.is_inside_tree():
		return _player
	var existing_player: Node = get_tree().get_first_node_in_group("player")
	if existing_player != null and existing_player.is_inside_tree():
		_player = existing_player
		return _player
	return null

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

func _on_request_fail_run(reason: String = "") -> void:
	_touch_request_activity("request_fail_run(reason=%s)" % reason)
	if not _guard_request_phase("request_fail_run", [RunPhase.RUN_INIT, RunPhase.BET_PRESENT, RunPhase.BET_COMMITTED, RunPhase.INTERMEDIATE_CHOICE, RunPhase.PUSH_YOUR_LUCK, RunPhase.RESOLUTION, RunPhase.NEXT_BET]):
		return
	if _is_game_over or _run_failed_emitted:
		return
	GameEvents.set_gameplay_enabled(false)
	var resolved_reason: String = reason.strip_edges()
	if resolved_reason == "":
		resolved_reason = "RUN_FAILED"
	_enter_end_run(resolved_reason)

func _get_bet_chain_reward_scale(chain_level: int) -> int:
	return _bet_system.get_reward_scale(chain_level)

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
	_waiting_for_intermediate_choice = true
	_smoke_mark("INTERMEDIATE_CHOICE")
	_set_phase(RunPhase.INTERMEDIATE_CHOICE, "open_intermediate_choice")

func _enter_mid_choice() -> void:
	_emit_ui(_build_intermediate_choice_ui_payload())

# FLOW ANCHOR hookup: see POST-BET SEQUENCE section.
func _open_push_luck_choice(_bet_id: StringName) -> void:
	_waiting_for_push_luck = true
	_smoke_mark("PUSH_YOUR_LUCK")
	_set_phase(RunPhase.PUSH_YOUR_LUCK, "open_push_luck_choice")

func _enter_push_your_luck() -> void:
	var view: Dictionary = _phase_push_your_luck_handler.build_view(_run_state)
	GameEvents.push_luck_opened.emit(view)

func _refresh_push_luck_choice(bet_id: StringName) -> void:
	_emit_ui(_build_push_luck_ui_payload(bet_id, {}))

func _build_intermediate_choice_ui_payload() -> RunUiPayload:
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = int(RunPhase.INTERMEDIATE_CHOICE)
	var view: Dictionary = _phase_intermediate_choice_handler.build_view(_run_state)
	var title: String = str(view.get("title", ""))
	var pending_bet_id: StringName = _run_state.intermediate_pending_bet_id
	var behavior_id: StringName = _get_level3_bet_behavior(pending_bet_id)
	var risk_level: String = "mid"
	if _is_high_risk_behavior(behavior_id):
		risk_level = "high"
	elif behavior_id == BET_CROW_PLEASER or behavior_id == BET_CASH_OUT:
		risk_level = "safe"
	var audience_message: String = _pick_audience_message_for_risk(risk_level)
	if audience_message == "":
		audience_message = "La folla osserva la tua scelta."
	payload.title = "%s\n%s" % [audience_message, title]
	payload.meta = {
		"audience_message": audience_message,
	}
	var choices: Array = view.get("choices", []) as Array
	payload.choices = []
	for choice_value: Variant in choices:
		payload.choices.append(str(choice_value))
	payload.show_mid_choice = bool(view.get("show_mid_choice", false))
	return payload

func _build_push_luck_ui_payload(bet_id: StringName, view: Dictionary = {}) -> RunUiPayload:
	var payload: RunUiPayload = RunUiPayloadScript.new()
	payload.phase = int(RunPhase.PUSH_YOUR_LUCK)
	payload.meta = _build_push_luck_payload(bet_id)
	var local_view: Dictionary = view
	if local_view.is_empty():
		local_view = _phase_push_your_luck_handler.build_view(_run_state, {
			"bet_name": str(payload.meta.get("bet_name", "")),
		})
	payload.title = str(local_view.get("title", ""))
	payload.body = str(local_view.get("body", ""))
	var choices: Array = local_view.get("choices", []) as Array
	payload.choices = []
	for choice_value: Variant in choices:
		payload.choices.append(str(choice_value))
	payload.show_push_your_luck = bool(local_view.get("show_push_your_luck", false))
	return payload

func _emit_ui(payload: RunUiPayload) -> void:
	if payload == null:
		return
	var now_ms: int = Time.get_ticks_msec()
	_last_ui_render_ms = now_ms
	_last_activity_ms = now_ms
	_flow_logger.log_ui("emit_payload", "phase=%s" % str(payload.phase))
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
	var next_level: int = maxi(_run_state.escalation_level + 1, 1) + 1
	var next_reward_tier: int = maxi(_run_state.level3_reward_tier + 1, 1)
	var cashout_lock_reason: String = _get_cashout_lock_reason()
	var double_lock_reason: String = _get_double_lock_reason()
	var reward_text: Dictionary = _build_audience_reward_text()
	return _betting_payload_factory.build_pyl_offer_payload({
		"bet_id": String(bet_id),
		"bet_data": bet_data,
		"level3_enabled": true,
		"bet_chain_level": _run_state.bet_chain_level,
		"escalation_level": _run_state.escalation_level,
		"next_pact": _build_bet_pact_text(String(bet_id), next_reward_tier),
		"next_doom": _build_bet_doom_text(String(bet_id), next_level),
		"cashout_enabled": bool(reward_text.get("cashout_enabled", true)),
		"cashout_lock_reason": cashout_lock_reason,
		"audience_cashout_lock_reason": str(reward_text.get("cashout_lock_reason", "")),
		"double_lock_reason": double_lock_reason,
		"choice_note": _run_state.intermediate_choice_note,
		"arena_index": _run_state.arena_index,
		"arena_target": _run_state.level3_target_arenas,
		"audience_label": str(reward_text.get("audience_label", "")),
		"audience_reason": str(reward_text.get("audience_reason", "")),
		"cashout_modifier": float(reward_text.get("cashout_modifier", 1.0)),
		"cashout_modifier_text": str(reward_text.get("cashout_modifier_text", "")),
	})

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
	return _ui_payload_factory.build_sentence_payload("SENTENZA", rule, doom, bet_id)

func _get_sentence_rule(bet_id: StringName) -> String:
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
		if result.condemnation_flag:
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
	var reward_text: Dictionary = _build_audience_reward_text()
	return float(reward_text.get("cashout_modifier", 1.0))

func _build_audience_reward_text() -> Dictionary:
	var reward_text: Dictionary = _betting_policy.build_reward_text({
		"audience_score": _run_state.audience_score,
		"run_seed": _run_state.run_seed,
		"arena_index": _run_state.arena_index,
		"audience_phrases": AUDIENCE_PHRASES,
		"cashout_disable_threshold": AUDIENCE_CASHOUT_DISABLE_THRESHOLD,
		"cashout_penalty_threshold": AUDIENCE_CASHOUT_PENALTY_THRESHOLD,
		"cashout_penalty_multiplier": AUDIENCE_CASHOUT_PENALTY_MULTIPLIER,
		"registry_has_precedent": _registry_has_precedent,
	})
	return _betting_payload_factory.build_audience_payload_fragments(reward_text)

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

func _apply_pure_bet_reward_scaled(_scale: int) -> void:
	return

func _build_bet_pact_text(bet_id: String, chain_level: int) -> String:
	var tier: int = _bet_system.get_reward_scale(chain_level)
	var bet_data: Dictionary = _get_bet_data(bet_id)
	if not bet_data.is_empty():
		var pact_base: String = str(bet_data.get("pact", ""))
		if pact_base != "":
			return "%s x%d" % [pact_base, tier]
	return bet_id

func _build_bet_doom_text(bet_id: String, chain_level: int) -> String:
	return _bet_system.build_doom_text(
		true,
		bet_id,
		chain_level,
		_get_bet_data(bet_id),
		BET_COWARD,
		BET_PURE_BLOOD,
		BET_DOUBLE_OR_DIE
	)

func _get_bet_data(bet_id: String) -> Dictionary:
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

func _apply_double_or_die_reward_scaled(_scale: int) -> void:
	return

func retry_current_bet() -> void:
	if _is_game_over:
		return
	_waiting_for_bet = false
	_waiting_for_push_luck = false
	_reset_bet_chain()
	_set_runtime_gate_phase(RunPhase.PREP)
	GameEvents.set_gameplay_enabled(false)
	run["arena_index"] = maxi(int(run.get("arena_index", 0)) - 1, 0)
	if _arena and _arena.has_method("soft_reset"):
		_arena.call("soft_reset")
	_open_bet_ui(false)

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
	_refresh_sanity_ui_root()
	if _sanity_ui_root == null or _sanity_ui_root.get_node_or_null("UI_RunRoot/Phase_END_RUN") == null:
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
	_set_runtime_gate_phase(RunPhase.GAME_OVER)
	_update_arena_visual_only()
	_emit_run_finale()
	_emit_run_ended()
	if _run_state.run_end_reason != "INFRA_FAILURE":
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
	_smoke_mark("END_RUN")
	var finale_meta: Dictionary = finale.get("meta", {}) as Dictionary
	var register_final: bool = bool(finale_meta.get("register_final", false))
	var register_ending_key: String = str(finale_meta.get("register_ending_key", ""))
	if register_final and register_ending_key != "":
		_smoke_mark_kv("END_RUN_FINAL", "ending_key", register_ending_key)
	if register_final and register_ending_key != "" and not _end_run_meta_emitted:
		_end_run_meta_emitted = true
		if not _meta_unlock_emitted_this_run and GameEvents.has_signal("meta_progress_unlocked"):
			_meta_unlock_emitted_this_run = true
			GameEvents.meta_progress_unlocked.emit(register_ending_key)
		var achievement_condanna_id: StringName = ENDING_TO_ACHIEVEMENT_CONDANNA.get(register_ending_key, &"") as StringName
		if achievement_condanna_id != &"":
			_register_condanna(achievement_condanna_id)
		if GameEvents.has_signal("archive_entry_unlocked"):
			var archive_entry_id: String = str(ENDING_TO_ARCHIVE_ENTRY.get(register_ending_key, ""))
			if archive_entry_id != "":
				GameEvents.archive_entry_unlocked.emit(archive_entry_id)
	if bool(finale.get("classified_terminal", false)) and not _registry_has_precedent:
		SaveManager.set_unlocked(UNLOCK_REGISTRY_PRECEDENT)
		_registry_has_precedent = true
	_log_balance_terminal_metrics(finale)
	if finale.has("ending_id"):
		print("Run ending chosen:", str(finale.get("ending_id", "")), " seed=", _run_state.run_seed)
	GameEvents.run_finale_selected.emit(finale)
	_emit_run_log(finale)
	_export_run_summary(finale)

func _log_balance_terminal_metrics(finale: Dictionary) -> void:
	if not OS.is_debug_build():
		return
	var terminal_classification: String = str(finale.get("ending_id", ""))
	print(
		"[BALANCE] doubles=%d escalation=%d glory=%d coins=%d corruption=%d finale=%s precedent=%s"
		% [
			_run_state.level3_doubles,
			_run_state.level3_max_escalation,
			_run_state.glory,
			int(run.get("coins", 0)),
			_run_state.corruption,
			terminal_classification,
			str(_registry_has_precedent),
		]
	)

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
	return _run_end_payload_builder.build_run_summary(_run_state, finale, Time.get_ticks_msec())

func _build_game_over_stats_payload(bet_names: Array[String]) -> Dictionary:
	return {
		"cashouts": _run_state.level3_cashouts,
		"doubles": _run_state.level3_doubles,
		"bets": bet_names,
		"max_escalation": _run_state.level3_max_escalation,
		"arena_target": _run_state.level3_target_arenas,
		"arena_count": _run_state.arena_index,
	}

func _build_game_over_anomaly_flow_tag() -> String:
	match _register_state.flow_phase:
		RegisterState.FLOW_PHASE_ATTRITO:
			return "ATTRITO"
		RegisterState.FLOW_PHASE_DERIVA:
			return "DERIVA"
		RegisterState.FLOW_PHASE_MEMORIA:
			return "MEMORIA"
		RegisterState.FLOW_PHASE_SOSPENSIONE:
			return "SOSPENSIONE"
		_:
			return ""

func _build_game_over_finale_inputs(
	ending_id: StringName,
	run_completed: bool,
	scars_copy: Array,
	stats_payload: Dictionary,
	pacts_signed: Array[StringName],
	anomaly_flow_tag: String
) -> Dictionary:
	return {
		"ending_id": String(ending_id),
		"is_anomalous": _register_state.flow_phase != RegisterState.FLOW_PHASE_STABLE,
		"register_flow_phase": String(_register_state.flow_phase),
		"anomaly_flow_tag": anomaly_flow_tag,
		"run_completed": run_completed,
		"scars": scars_copy,
		"stats": stats_payload,
		"pacts_signed": pacts_signed,
	}

func _build_game_over_copy_inputs(finale: Dictionary) -> Dictionary:
	return {
		"title": str(finale.get("title", "")),
		"body": str(finale.get("text", "")),
	}

func _get_completed_bets_count() -> int:
	return _run_state.bets_history.size()

func _is_register_final() -> bool:
	return _get_register_final_ending_key() != ""

func _get_register_final_ending_key() -> String:
	if _get_completed_bets_count() < MIN_BETS_FOR_SENTENCE:
		return ""
	if _run_state.corruption >= CORRUPTION_FINAL_THRESHOLD:
		return REGISTER_ENDING_CORRUPTION
	if _run_state.glory >= GLORY_FINAL_THRESHOLD:
		return REGISTER_ENDING_GLORY
	if _run_state.scars.size() >= SCARS_FINAL_THRESHOLD:
		return REGISTER_ENDING_SCARS
	return REGISTER_ENDING_PATTERN

func _pick_from_pool(pool: Array[String]) -> String:
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]

func _pick_register_message(ending_key: String) -> String:
	if ending_key == "":
		return _pick_from_pool(REGISTER_POOL_PROVISIONAL)
	match ending_key:
		REGISTER_ENDING_CORRUPTION:
			return _pick_from_pool(REGISTER_POOL_FINAL_CORRUPTION)
		REGISTER_ENDING_GLORY:
			return _pick_from_pool(REGISTER_POOL_FINAL_GLORY)
		REGISTER_ENDING_SCARS:
			return _pick_from_pool(REGISTER_POOL_FINAL_SCARS)
		REGISTER_ENDING_PATTERN:
			return _pick_from_pool(REGISTER_POOL_FINAL_PATTERN)
		_:
			return _pick_from_pool(REGISTER_POOL_FINAL_PATTERN)

func _select_run_finale() -> Dictionary:
	var scars_copy: Array = _run_state.scars_payload.duplicate(true)
	var scar_count: int = _run_state.scars_history.size()
	var ending_id: StringName = _run_state.forced_ending_id
	var run_completed: bool = _run_state.level3_target_arenas > 0 and _run_state.arena_index >= _run_state.level3_target_arenas
	_update_hidden_run_metrics()
	if _registry_has_precedent and ending_id == &"THE_LIBERTY":
		ending_id = &""
	if ending_id == &"":
		var ending_trace: Dictionary = _build_level3_ending_trace()
		var rule_match: Dictionary = _finale_builder.select_level3_ending_key(_run_state, ending_trace)
		var matched_rule_id: String = str(rule_match.get("id", ""))
		if matched_rule_id != "":
			_flow_log("ending_rule_matched", matched_rule_id)
		var matched_ending: StringName = StringName(str(rule_match.get("ending_key", "")))
		if matched_ending != &"":
			ending_id = matched_ending
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

	var bet_names: Array[String] = []
	for bet_id: StringName in _run_state.level3_bets_used:
		bet_names.append(_get_bet_display_name(String(bet_id)))
	var pacts_signed: Array[StringName] = _run_state.bets_history.duplicate()
	var stats_payload: Dictionary = _build_game_over_stats_payload(bet_names)
	var anomaly_flow_tag: String = _build_game_over_anomaly_flow_tag()
	var finale_inputs: Dictionary = _build_game_over_finale_inputs(
		ending_id,
		run_completed,
		scars_copy,
		stats_payload,
		pacts_signed,
		anomaly_flow_tag
	)
	var finale_payload: Dictionary = _phase_game_over_handler.build_ui_payload(_run_state, finale_inputs)
	var finale: Dictionary = _finale_builder.build_finale_payload(finale_payload)
	var pacts_text: String = str(finale.get("pacts_text", ""))
	var condanne_text: String = str(finale.get("condanne_text", ""))
	var crowd_text: String = str(finale.get("crowd_text", ""))
	var copy_inputs: Dictionary = _build_game_over_copy_inputs(finale)
	var copy: Dictionary = _phase_game_over_handler.build_view(_run_state, pacts_text, condanne_text, crowd_text, copy_inputs)
	finale["title"] = str(copy.get("title", ""))
	finale["subtitle"] = str(copy.get("subtitle", ""))
	finale["body"] = str(copy.get("body", ""))
	finale["hint"] = str(copy.get("hint", ""))
	finale["footer"] = str(copy.get("footer", ""))
	finale["pacts_text"] = str(copy.get("pacts_text", ""))
	finale["condanne_text"] = str(copy.get("condanne_text", ""))
	finale["crowd_text"] = str(copy.get("crowd_text", ""))
	var meta_payload: Dictionary = finale.get("meta", {}) as Dictionary
	var register_ending_key: String = _get_register_final_ending_key()
	meta_payload["register_message"] = _pick_register_message(register_ending_key)
	meta_payload["register_final"] = register_ending_key != ""
	meta_payload["register_ending_key"] = register_ending_key
	meta_payload["next_bet_enabled"] = register_ending_key == ""
	finale["meta"] = meta_payload
	return finale

func _build_level3_ending_trace() -> Dictionary:
	# Condanna source is intentionally unique for ending rules:
	# registry-issued condanne_this_run only (not inferred PYL actions).
	var condanna_registry_count: int = _run_state.condanne_this_run.size()
	var trace: Dictionary = _finale_builder.build_path_trace_from_bet_history(_run_state.bets_history)
	trace["cashout_count"] = _run_state.push_luck_cashouts
	trace["double_count"] = _run_state.push_luck_doubles
	trace["condanna_count"] = condanna_registry_count
	trace["condanna_registry_count"] = condanna_registry_count
	trace["provoke_armed"] = _run_state.provoke_armed
	return trace

func _update_hidden_run_metrics() -> void:
	var corruption_value: int = 0
	for bet_id: StringName in _run_state.bets_history:
		var behavior_id: StringName = _get_level3_bet_behavior(bet_id)
		if behavior_id == BET_DOUBLE_OR_DIE_L3:
			corruption_value += 3
		elif _is_high_risk_behavior(behavior_id):
			corruption_value += 2
		else:
			corruption_value += 1
	corruption_value += maxi(_run_state.escalation_level - 1, 0)
	corruption_value += maxi(_run_state.level3_max_escalation - 2, 0)
	corruption_value += _run_state.doubles
	_run_state.glory = maxi(_run_state.glory, 0)
	var runtime_corruption: int = int(run.get("corruption", 0))
	_run_state.corruption = maxi(maxi(corruption_value, runtime_corruption), 0)

func _is_high_risk_behavior(behavior_id: StringName) -> bool:
	return behavior_id == BET_DOUBLE_OR_DIE_L3 or behavior_id == BET_DEBT_CHAIN or behavior_id == BET_BLOOD_TAX or behavior_id == BET_LAST_BREATH

func _pick_audience_message_for_risk(risk_level: String) -> String:
	var pool: Array[String]
	match risk_level:
		"safe":
			pool = AUDIENCE_POOL_SAFE
		"mid":
			pool = AUDIENCE_POOL_MID
		"high":
			pool = AUDIENCE_POOL_HIGH
		_:
			pool = AUDIENCE_POOL_MID
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]

func _register_pact_corruption(bet_id: StringName) -> void:
	if bet_id == &"":
		return
	if _run_state.last_pact_corruption_arena_index == _run_state.arena_index and _run_state.last_pact_corruption_bet_id == bet_id:
		return
	var behavior_id: StringName = _get_level3_bet_behavior(bet_id)
	if not _is_high_risk_behavior(behavior_id):
		return
	_run_state.last_pact_corruption_arena_index = _run_state.arena_index
	_run_state.last_pact_corruption_bet_id = bet_id
	_apply_corruption(CORRUPTION_PACT_HIGH)
	_try_apply_pact_scar_pool()

func _count_scars_with_tag(tag: StringName) -> int:
	var count: int = 0
	for scar_value: Dictionary in _run_state.scars_payload:
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

func get_level3_pact_reveal_text(pact_id: StringName) -> String:
	return get_pact_reveal_line(pact_id)

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
	return _gameplay_phase == RunPhase.LIVE

func is_level3_mode() -> bool:
	return true

func is_visual_only() -> bool:
	return true

func get_debug_phase_name() -> String:
	return _phase_to_name(_phase)

func get_debug_last_request() -> String:
	return _last_request

func get_debug_last_ui_render_ms() -> int:
	return _last_ui_render_ms

func get_debug_flow_tail(lines: int = 10) -> String:
	return _flow_logger.dump_last(lines)

func _set_phase(next: RunPhase, reason: String) -> void:
	if _phase == next:
		return
	if next == RunPhase.BET_PRESENT:
		var previous_phase: RunPhase = _phase
		_flow_logger.log_phase(str(next), "from=%s reason=%s" % [str(previous_phase), reason])
		var now_ms: int = Time.get_ticks_msec()
		_last_phase_change_ms = now_ms
		_last_activity_ms = now_ms
		_phase = next
		_enter_bet_present()
		if _is_smoke_mode():
			print("SMOKE:PHASE=%s" % _phase_to_name(next))
		if OS.is_debug_build() and reason != "":
			print_debug(_flow_diagnostics.format_phase_debug_line(int(next), reason))
		return
	if not _has_enter_phase_handler(next):
		push_error(_flow_diagnostics.format_missing_enter_phase_error(str(next), _flow_logger.dump_last(30)))
		return
	var previous_phase: RunPhase = _phase
	_flow_logger.log_phase(str(next), "from=%s reason=%s" % [str(previous_phase), reason])
	var now_ms: int = Time.get_ticks_msec()
	_last_phase_change_ms = now_ms
	_last_activity_ms = now_ms
	_phase = next
	if not _run_enter_phase(next):
		push_error(_flow_diagnostics.format_missing_enter_phase_error(str(next), _flow_logger.dump_last(30)))
		return
	if _is_smoke_mode():
		print("SMOKE:PHASE=%s" % _phase_to_name(next))
	if OS.is_debug_build() and reason != "":
		print_debug(_flow_diagnostics.format_phase_debug_line(int(next), reason))

func _touch_request_activity(request_name: String) -> void:
	_last_request = request_name
	_last_activity_ms = Time.get_ticks_msec()

func _watchdog_stall_hint(now_ms: int) -> String:
	return _flow_watchdog.watchdog_stall_hint(
		now_ms,
		_last_phase_change_ms,
		_last_ui_render_ms,
		_last_activity_ms,
		_last_request,
		WATCHDOG_STALL_MS
	)

func _watchdog_tick() -> void:
	if not _watchdog_enabled:
		return
	if _phase == RunPhase.NONE or _phase == RunPhase.MAIN_MENU:
		return
	if _phase == RunPhase.BET_PRESENT and _waiting_for_bet:
		return
	if _phase == RunPhase.INTERMEDIATE_CHOICE and _waiting_for_intermediate_choice:
		return
	if _phase == RunPhase.PUSH_YOUR_LUCK and _waiting_for_push_luck:
		return
	var now_ms: int = Time.get_ticks_msec()
	if not _flow_watchdog.should_report_stall(now_ms, _last_activity_ms, WATCHDOG_STALL_MS):
		return
	var stall_ms: int = now_ms - _last_activity_ms
	var hint: String = _watchdog_stall_hint(now_ms)
	push_error(_flow_diagnostics.format_watchdog_stall_error(stall_ms, hint, _flow_snapshot("stall")))
	_watchdog_enabled = false

func _has_enter_phase_handler(next: RunPhase) -> bool:
	match next:
		RunPhase.MAIN_MENU, RunPhase.RUN_INIT, RunPhase.BET_PRESENT, RunPhase.BET_COMMITTED, RunPhase.INTERMEDIATE_CHOICE, RunPhase.PUSH_YOUR_LUCK, RunPhase.RESOLUTION, RunPhase.NEXT_BET, RunPhase.GAME_OVER:
			return true
		_:
			return false

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
	var ui_payload: RunUiPayload = _build_phase_ui_payload(RunPhase.RUN_INIT, "INIZIO RUN")
	var payload: Dictionary = _phase_run_init_handler.build_ui_payload(_run_state, {"coins": int(run.get("coins", 0))})
	ui_payload.meta = payload
	_emit_ui(ui_payload)

func _enter_bet_present() -> void:
	_smoke_mark("BET_PRESENT")
	var view: Dictionary = _phase_bet_present_handler.build_view(_run_state, {"coins": int(run.get("coins", 0))})
	var offer: Array[Dictionary] = []
	var raw_offer: Variant = view.get("offer", null)
	if raw_offer is Array:
		for offer_value in raw_offer:
			if offer_value is Dictionary:
				offer.append(offer_value as Dictionary)
	GameEvents.bet_ui_opened.emit(offer)

func _enter_bet_committed() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.BET_COMMITTED, "PATTO SIGILLATO"))

func _enter_next_bet() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.NEXT_BET, "PROSSIMO PATTO"))

func _enter_end_run_phase() -> void:
	_emit_ui(_build_phase_ui_payload(RunPhase.GAME_OVER, "FINE RUN"))

func set_phase(p: Variant) -> void:
	var legacy_intent: String = "phase=%s reason=legacy_set_phase" % [str(p)]
	_flow_log("legacy_set_phase_rejected", legacy_intent)
	push_error("RunManager: legacy set_phase call rejected (%s)" % legacy_intent)
	if OS.is_debug_build():
		assert(false, "RunManager legacy set_phase backdoor invoked")

func _set_runtime_gate_phase(next: RunPhase) -> void:
	_gameplay_phase = next
	GameEvents.run_phase_changed.emit(int(_gameplay_phase))
	_apply_phase()

func _apply_phase() -> void:
	if GameEvents.has_method("set_gameplay_enabled"):
		var gameplay_enabled: bool = _gameplay_phase == RunPhase.LIVE and not is_visual_only()
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

func _reset_upgrades() -> void:
	run["upgrades"] = {}

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
	_runstate_kernel.reset_scars(_run_state)
	_emit_scars_updated()

func _emit_scars_updated() -> void:
	var scars_copy: Array = _run_state.scars_payload.duplicate(true)
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
	var trigger: StringName = StringName(str(scar.get("trigger", SCAR_TRIGGER_IRREVERSIBLE_BET)))
	var run_scar: Scar = _build_run_scar(scar_id, String(str(scar.get("origin", ""))), trigger)
	var inserted: bool = _runstate_kernel.upsert_run_scar(_run_state, String(scar_id), _run_state.arena_index, {
		"scar_payload": scar,
		"run_scar": run_scar,
	})
	if not inserted:
		return
	_emit_register_annotation_from_scar(scar_id)
	_runstate_kernel.recompute_scar_modifiers(_run_state)
	var hunted_changed: bool = _runstate_kernel.recompute_scar_synergies(_run_state)
	if hunted_changed:
		_check_audience_condanne()
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
	var inserted: bool = _runstate_kernel.upsert_run_scar(_run_state, String(scar_id), _run_state.arena_index, {
		"run_scar": _build_run_scar(scar_id, origin, trigger),
		"append_history": false,
	})
	if not inserted:
		return
	_emit_register_annotation_from_scar(scar_id)

func _try_register_refused_closure_scar() -> void:
	var should_try: bool = _scar_policy.should_try_scar(String(SCAR_EVENT_REFUSED_CLOSURE), {
		"already_registered": _run_state.refused_closure_scar_registered,
		"refuse_cashout_count_this_run": _run_state.refuse_cashout_count_this_run,
		"refuse_cashout_threshold": SCAR_REFUSE_CASHOUT_THRESHOLD,
		"arena_index": _run_state.arena_index,
		"last_scar_arena_index": _run_state.last_scar_arena_index,
		"min_arena_interval": SCAR_MIN_ARENA_INTERVAL,
	})
	if not should_try:
		return
	_register_run_scar(SCAR_EVENT_REFUSED_CLOSURE, "Rifiuto chiusura ripetuto (%d)" % _run_state.refuse_cashout_count_this_run, SCAR_TRIGGER_REFUSED_CLOSURE)
	_run_state.refused_closure_scar_registered = true

func _try_register_risk_threshold_scar() -> void:
	var should_try: bool = _scar_policy.should_try_scar(String(SCAR_EVENT_RISK_THRESHOLD), {
		"already_registered": _run_state.risk_threshold_scar_registered,
		"escalation_level": _run_state.escalation_level,
		"risk_escalation_threshold": SCAR_RISK_ESCALATION_THRESHOLD,
		"arena_index": _run_state.arena_index,
		"last_scar_arena_index": _run_state.last_scar_arena_index,
		"min_arena_interval": SCAR_MIN_ARENA_INTERVAL,
	})
	if not should_try:
		return
	_register_run_scar(SCAR_EVENT_RISK_THRESHOLD, "Soglia rischio raggiunta (%d)" % _run_state.escalation_level, SCAR_TRIGGER_RISK_THRESHOLD)
	_run_state.risk_threshold_scar_registered = true

func _recompute_scar_modifiers() -> void:
	_runstate_kernel.recompute_scar_modifiers(_run_state)

func _recompute_scar_synergies() -> void:
	var hunted_changed: bool = _runstate_kernel.recompute_scar_synergies(_run_state)
	if hunted_changed:
		_check_audience_condanne()

func _get_bet_display_name(bet_id: String) -> String:
	var bet_data: Dictionary = _get_bet_data(bet_id)
	if bet_data.is_empty():
		return bet_id
	return str(bet_data.get("display_title", bet_data.get("name", bet_id)))

func _try_apply_open_wound_scar(chain_level: int) -> void:
	var should_try: bool = _scar_policy.should_try_scar(String(SCAR_OPEN_WOUND), {
		"existing_scar_ids": _serialize_stringname_array(_run_state.scars_history),
	})
	if not should_try:
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
	var should_try: bool = _scar_policy.should_try_scar(String(SCAR_CRACKED_BONES), {
		"chain_level": chain_level,
		"existing_scar_ids": _serialize_stringname_array(_run_state.scars_history),
	})
	if not should_try:
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
