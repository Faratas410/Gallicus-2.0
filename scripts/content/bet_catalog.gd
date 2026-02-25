extends RefCounted
class_name BetCatalog

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

const CONDANNA_ANCORA: StringName = &"CONDANNA_ANCORA"
const CONDANNA_NON_DOVEVO_PROVARCI: StringName = &"CONDANNA_NON_DOVEVO_PROVARCI"
const CONDANNA_FIRMATO: StringName = &"CONDANNA_FIRMATO"
const CONDANNA_MI_SONO_FERMATO: StringName = &"CONDANNA_MI_SONO_FERMATO"

const LEVEL3_BET_BEHAVIOR: Dictionary[StringName, StringName] = {
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

const LEVEL3_PACT_UNLOCKS: Dictionary[StringName, StringName] = {
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


const BET_CASH_OUT: StringName = &"CASH_OUT"
const BET_DOUBLE_OR_DIE: StringName = &"DOUBLE_OR_DIE"

const LEVEL3_BETS: Array[Dictionary] = [
	{
		"id": "CASH_OUT",
		"name": "INCASSA E VAI",
		"display_title": "VIA DELLA PRUDENZA",
		"display_subtitle": "Chiudi ora. Salva margine, cedi gloria.",
		"path_tag": &"PATH_PRUDENCE",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa minima ma sicura: incassi subito e riduci l'esposizione.",
		"condition": "Devi vincere l'arena senza inseguire l'escalation.",
		"doom": "Hai scelto la via breve.\nLa folla ricorda chi non spinge.\nL'arena lascia comunque il segno.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa più rischiosa.",
		"weight": 5,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "DOUBLE_OR_DIE",
		"name": "RADDOPPI O MUORI",
		"display_title": "VIA DELL'HYBRIS",
		"display_subtitle": "Spingi oltre. Rischio massimo, ritorno totale.",
		"path_tag": &"PATH_HUBRIS",
		"archetype": &"EGO",
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
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa media, ma mantiene viva la catena del patto.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "La catena non si spezza.\nOgni passo stringe il debito.\nIl pubblico pretende il prezzo.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 4,
		"blocked_scars": [&"SCAR_DEBT_BRAND"],
		"requires_scars": [],
	},
	{
		"id": "BLOOD_TAX",
		"name": "DECIMA DI SANGUE",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa alta: la vittoria spinge la run verso un ritmo più feroce.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "La vittoria chiede sangue.\nIl tributo è scritto sulla pelle.\nNon puoi evitarlo.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [&"SCAR_OPEN_WOUND"],
		"requires_scars": [],
	},
	{
		"id": "CROW_PLEASER",
		"name": "PIACERE AL PUBBLICO",
		"archetype": &"EGO",
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
		"archetype": &"TIME",
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Ricompensa altissima, con la run al limite dell'ossessione.",
		"condition": "Vinci l'arena con il cuore in gola.",
		"doom": "Respiri corto.\nOgni colpo è l'ultimo.\nIl destino pesa sulle ossa.\nEffetto: cicatrice GRAVE (non mortale), cammino compromesso.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [&"SCAR_CRACKED_BONES"],
	},
	{
		"id": "PACT_DEBT_01_IOU",
		"name": "CAMBIALE DI SANGUE",
		"archetype": &"DEBT",
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
		"archetype": &"DEBT",
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
		"archetype": &"DEBT",
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
		"archetype": &"DEBT",
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
		"archetype": &"EGO",
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
		"archetype": &"EGO",
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
		"archetype": &"EGO",
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
		"archetype": &"EGO",
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
		"archetype": &"TIME",
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
		"archetype": &"TIME",
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
		"archetype": &"TIME",
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
		"archetype": &"TIME",
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
		"archetype": &"DEBT",
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
		"archetype": &"EGO",
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
		"archetype": &"TIME",
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
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Firmi e rinunci alla via facile. Il debito resta aperto.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "Il sigillo non si scioglie.\nOgni passo stringe il debito.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [&"SCAR_DEBT_BRAND"],
		"requires_scars": [],
	},
	{
		"id": "P3_BLOOD_LEDGER",
		"name": "LIBRO DI SANGUE",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Iscrivi il tuo nome nel registro rosso.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "Il libro chiede sangue.\nIl tributo è inciso nella carne.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [&"SCAR_OPEN_WOUND"],
		"requires_scars": [],
	},
	{
		"id": "P3_DEBT_MIRROR",
		"name": "SPECCHIO DEL DEBITO",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ti guardi e firmi ciò che devi.",
		"condition": "Vinci l'arena senza cercare scuse.",
		"doom": "Lo specchio riflette catene.\nIl debito non lascia uscita.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [&"SCAR_DEBT_BRAND"],
		"requires_scars": [],
	},
	{
		"id": "P3_CROWD_FEAST",
		"name": "BANCHETTO DELLA FOLLA",
		"archetype": &"EGO",
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
		"archetype": &"TIME",
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Rilanci oltre il respiro.",
		"condition": "Vinci l'arena con il cuore in gola.",
		"doom": "Ogni colpo è l'ultimo.\nIl destino stringe il passo.\nEffetto: cicatrice GRAVE (non mortale), cammino compromesso.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [&"SCAR_CRACKED_BONES"],
	},
	{
		"id": "P3_RED_VERDICT",
		"name": "VERDETTO ROSSO",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Accetti il verdetto scritto nel sangue.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "Il verdetto è sangue.\nIl tributo non si discute.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [&"SCAR_OPEN_WOUND"],
		"requires_scars": [],
	},
	{
		"id": "P3_CHAIN_OATH",
		"name": "GIURAMENTO A CATENA",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Giuri e consegni il futuro.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "Il giuramento stringe la catena.\nOgni passo pesa il doppio.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [&"SCAR_DEBT_BRAND"],
		"requires_scars": [],
	},
	{
		"id": "P3_TITHE_OF_BONE",
		"name": "DECIMA D'OSSA",
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Paghi con ossa ciò che chiedi.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "La decima frantuma.\nIl tributo resta sulle ossa.\nEffetto: HP massimo -25 + incasso bloccato per 1 arena.",
		"weight": 3,
		"blocked_scars": [&"SCAR_OPEN_WOUND"],
		"requires_scars": [],
	},
	{
		"id": "P3_GLORY_TAX",
		"name": "TASSA DI GLORIA",
		"archetype": &"EGO",
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
		"archetype": &"EGO",
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
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Paghi per tacere, firmi comunque.",
		"condition": "Vinci l'arena senza cercare scuse.",
		"doom": "Il silenzio costa più della parola.\nLa catena non si allenta.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [&"SCAR_DEBT_BRAND"],
		"requires_scars": [],
	},
	{
		"id": "P3_FINAL_APPLAUSE",
		"name": "APPLAUSO FINALE",
		"archetype": &"EGO",
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
		"archetype": &"EGO",
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
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Firmi una volta. Poi sei libero.",
		"condition": "Vinci l'arena e non spezzare la promessa.",
		"doom": "La catena non si spezza.\nOgni passo stringe il debito.\nIl pubblico pretende il prezzo.\nEffetto: cicatrice MARCHIO DEL DEBITO, ogni futura scommessa pesa di più.",
		"weight": 3,
		"blocked_scars": [&"SCAR_DEBT_BRAND"],
		"requires_scars": [],
	},
	{
		"id": "P3_LIE_APPLAUSE",
		"name": "APPLAUSO GARANTITO",
		"archetype": &"TIME",
		"archetype_label": "ARCHETIPO: TEMPO",
		"pact": "Il pubblico è dalla tua parte. Sempre.",
		"condition": "Vinci l'arena con il cuore in gola.",
		"doom": "Respiri corto.\nOgni colpo è l'ultimo.\nIl destino pesa sulle ossa.\nEffetto: cicatrice GRAVE (non mortale), cammino compromesso.",
		"weight": 2,
		"blocked_scars": [],
		"requires_scars": [&"SCAR_CRACKED_BONES"],
	},
]

static func level3_active_bet_ids() -> Array[StringName]:
	return [BET_CASH_OUT, BET_DOUBLE_OR_DIE]

static func level3_active_bets() -> Array[Dictionary]:
	var active_ids: Array[StringName] = level3_active_bet_ids()
	var active: Array[Dictionary] = []
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: StringName = StringName(str(bet.get("id", "")))
		if active_ids.has(bet_id):
			active.append(bet.duplicate(true))
	return active

static func level3_bets() -> Array[Dictionary]:
	return LEVEL3_BETS.duplicate(true)

static func level3_bet_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for bet_id: StringName in level3_active_bet_ids():
		ids.append(String(bet_id))
	return ids


static func map_level3_behavior(bet_id: StringName) -> StringName:
	return LEVEL3_BET_BEHAVIOR.get(bet_id, bet_id)

static func get_level3_pact_unlock(bet_id: StringName) -> StringName:
	return LEVEL3_PACT_UNLOCKS.get(bet_id, &"")

static func get_level3_display_title(bet_id: StringName) -> String:
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			return str(bet.get("display_title", bet.get("name", String(bet_id))))
	return String(bet_id)

static func get_level3_display_subtitle(bet_id: StringName) -> String:
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			return str(bet.get("display_subtitle", ""))
	return ""

static func get_level3_path_tag(bet_id: StringName) -> StringName:
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			return StringName(str(bet.get("path_tag", "")))
	return &""
