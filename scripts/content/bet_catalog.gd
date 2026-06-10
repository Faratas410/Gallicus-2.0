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



const PATH_UNKNOWN: StringName = &"PATH_UNKNOWN"
const PATH_PRUDENCE: StringName = &"PATH_PRUDENCE"
const PATH_HUBRIS: StringName = &"PATH_HUBRIS"
const PATH_PENITENCE: StringName = &"PATH_PENITENCE"
const PATH_VIOLENCE: StringName = &"PATH_VIOLENCE"

const BET_CASH_OUT: StringName = &"CASH_OUT"
const BET_DOUBLE_OR_DIE: StringName = &"DOUBLE_OR_DIE"

const L3_ACTIVE_BET_IDENTITIES: Dictionary[StringName, Dictionary] = {
	BET_CASH_OUT: {
		"token": "BET_CASH_OUT",
		"display_title": "VIA DELLA PRUDENZA",
		"display_subtitle": "Tieni il margine. Ricompensa bassa, pressione stabile.",
		"path_tag": PATH_PRUDENCE,
		"behavior": BET_CASH_OUT,
	},
	BET_DOUBLE_OR_DIE: {
		"token": "BET_DOUBLE_OR_DIE",
		"display_title": "VIA DELL'HYBRIS",
		"display_subtitle": "Spingi oltre. Ritorno alto, margine nullo.",
		"path_tag": PATH_HUBRIS,
		"behavior": BET_DOUBLE_OR_DIE,
	},
	BET_P3_WAX_SEAL: {
		"token": "BET_P3_WAX_SEAL",
		"display_title": "SIGILLO DI CERA",
		"display_subtitle": "Il debito resta aperto, ma il Registro concede margine.",
		"path_tag": PATH_PRUDENCE,
		"behavior": BET_DEBT_CHAIN,
	},
	BET_P3_BLOOD_LEDGER: {
		"token": "BET_P3_BLOOD_LEDGER",
		"display_title": "LIBRO DI SANGUE",
		"display_subtitle": "Il tributo alza la posta e sporca ogni vittoria.",
		"path_tag": PATH_VIOLENCE,
		"behavior": BET_BLOOD_TAX,
	},
	BET_P3_CROWD_FEAST: {
		"token": "BET_P3_CROWD_FEAST",
		"display_title": "BANCHETTO DELLA FOLLA",
		"display_subtitle": "La folla paga in gloria e pretende spettacolo.",
		"path_tag": PATH_HUBRIS,
		"behavior": BET_CROW_PLEASER,
	},
	BET_P3_LAST_WAGER: {
		"token": "BET_P3_LAST_WAGER",
		"display_title": "ULTIMA PUNTATA",
		"display_subtitle": "Rilanci oltre il respiro: alto ritorno, margine fragile.",
		"path_tag": PATH_VIOLENCE,
		"behavior": BET_LAST_BREATH,
	},
	BET_P3_RED_VERDICT: {
		"token": "BET_P3_RED_VERDICT",
		"display_title": "VERDETTO ROSSO",
		"display_subtitle": "Accetti che ogni colpo abbia costo amministrativo.",
		"path_tag": PATH_VIOLENCE,
		"behavior": BET_BLOOD_TAX,
	},
	BET_P3_CHAIN_OATH: {
		"token": "BET_P3_CHAIN_OATH",
		"display_title": "GIURAMENTO A CATENA",
		"display_subtitle": "Prometti continuita': meno caos, piu' debito.",
		"path_tag": PATH_PRUDENCE,
		"behavior": BET_DEBT_CHAIN,
	},
	BET_P3_MERCY_BAIT: {
		"token": "BET_P3_MERCY_BAIT",
		"display_title": "ESCA DI MISERICORDIA",
		"display_subtitle": "La pieta' diventa scena: il pubblico giudica la posa.",
		"path_tag": PATH_PENITENCE,
		"behavior": BET_CROW_PLEASER,
	},
	BET_P3_SILENCE_BRIBE: {
		"token": "BET_P3_SILENCE_BRIBE",
		"display_title": "TANGENTE DEL SILENZIO",
		"display_subtitle": "Paghi per tacere: pressione piu' bassa, debito piu' saldo.",
		"path_tag": PATH_PENITENCE,
		"behavior": BET_DEBT_CHAIN,
	},
	BET_P3_LIE_APPLAUSE: {
		"token": "BET_P3_LIE_APPLAUSE",
		"display_title": "APPLAUSO GARANTITO",
		"display_subtitle": "La promessa e' falsa, ma il rischio e' vero.",
		"path_tag": PATH_HUBRIS,
		"behavior": BET_LAST_BREATH,
	},
}

const LEVEL3_BETS: Array[Dictionary] = [
	{
		"id": "CASH_OUT",
		"name": "INCASSA E VAI",
		"display_title": "VIA DELLA PRUDENZA",
		"display_subtitle": "Tieni il margine. Ricompensa bassa, pressione stabile.",
		"path_tag": PATH_PRUDENCE,
		"archetype": &"DEBT",
		"archetype_label": "ARCHETIPO: DEBITO",
		"pact": "Ricompensa contenuta: registri poco, ma tieni margine e pressione sotto controllo.",
		"condition": "Vinci l'arena senza rilanciare la pressione.",
		"doom": "Hai scelto il margine.\nLa folla non esulta, ma il Registro resta aperto.\nL'arena lascia comunque il segno.\nEffetto: cicatrice OSSA INCRINATE, le future scommesse restano rischiose.",
		"weight": 5,
		"blocked_scars": [],
		"requires_scars": [],
	},
	{
		"id": "DOUBLE_OR_DIE",
		"name": "RADDOPPI O MUORI",
		"display_title": "VIA DELL'HYBRIS",
		"display_subtitle": "Spingi oltre. Ritorno alto, margine nullo.",
		"path_tag": PATH_HUBRIS,
		"archetype": &"EGO",
		"archetype_label": "ARCHETIPO: EGO",
		"pact": "Ricompensa alta: moltiplica la posta, ma ogni rilancio alza la pressione.",
		"condition": "Vinci l'arena accettando che il fallimento chiuda il percorso.",
		"doom": "Hai promesso tutto.\nNon esiste margine.\nLa folla trattiene il fiato.\nEffetto: MORTE IMMEDIATA, percorso terminato senza appello.",
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
		"pact": "Ricompensa alta: la vittoria spinge il percorso verso un ritmo più feroce.",
		"condition": "Vinci l'arena sapendo che ogni colpo ha un prezzo.",
		"doom": "La vittoria chiede sangue.\nIl tributo e scritto sulla pelle.\nNon puoi evitarlo.\nEffetto: esposizione rituale +25 + incasso bloccato per 1 arena.",
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
		"pact": "Ricompensa altissima, con il percorso al limite dell'ossessione.",
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
		"condition": "Vinci l'arena senza subire condanne.",
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
		"condition": "Vinci l'arena senza subire condanne.",
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
		"condition": "Vinci l'arena senza subire condanne.",
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
		"doom": "Il libro chiede sangue.\nIl tributo e inciso nella carne.\nEffetto: esposizione rituale +25 + incasso bloccato per 1 arena.",
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
		"doom": "Il verdetto e sangue.\nIl tributo non si discute.\nEffetto: esposizione rituale +25 + incasso bloccato per 1 arena.",
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
		"doom": "La decima frantuma.\nIl tributo resta sulle ossa.\nEffetto: esposizione rituale +25 + incasso bloccato per 1 arena.",
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
	var ids: Array[StringName] = []
	for bet_id: StringName in L3_ACTIVE_BET_IDENTITIES.keys():
		ids.append(bet_id)
	ids.sort_custom(func(a: StringName, b: StringName) -> bool:
		return String(a) < String(b)
	)
	return ids

static func level3_active_bets() -> Array[Dictionary]:
	var active_ids: Array[StringName] = level3_active_bet_ids()
	var active: Array[Dictionary] = []
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		var bet_id: StringName = StringName(str(bet.get("id", "")))
		if active_ids.has(bet_id):
			var merged: Dictionary = bet.duplicate(true)
			var identity: Dictionary = resolve_bet_identity(bet_id)
			merged["display_title"] = str(identity.get("display_title", merged.get("display_title", merged.get("name", String(bet_id)))))
			merged["display_subtitle"] = str(identity.get("display_subtitle", merged.get("display_subtitle", "")))
			merged["path_tag"] = identity.get("path_tag", merged.get("path_tag", PATH_UNKNOWN))
			active.append(merged)
	return active

static func level3_bets() -> Array[Dictionary]:
	return LEVEL3_BETS.duplicate(true)

static func level3_bet_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for bet_id: StringName in level3_active_bet_ids():
		ids.append(String(bet_id))
	return ids


static func map_level3_behavior(bet_id: StringName) -> StringName:
	var identity: Dictionary = resolve_bet_identity(bet_id)
	var behavior: StringName = identity.get("behavior", &"") as StringName
	if behavior != &"UNKNOWN" and behavior != &"":
		return behavior
	return LEVEL3_BET_BEHAVIOR.get(bet_id, bet_id)

static func resolve_bet_identity(bet_id: StringName) -> Dictionary:
	if L3_ACTIVE_BET_IDENTITIES.has(bet_id):
		var identity: Dictionary = L3_ACTIVE_BET_IDENTITIES.get(bet_id, {}) as Dictionary
		var merged: Dictionary = identity.duplicate(true)
		merged["id"] = bet_id
		return merged
	return {
		"id": bet_id,
		"token": "BET_UNKNOWN",
		"display_title": "-",
		"display_subtitle": "",
		"path_tag": PATH_UNKNOWN,
		"behavior": &"UNKNOWN",
	}

static func get_bet_identity_token(bet_id: StringName) -> String:
	var identity: Dictionary = resolve_bet_identity(bet_id)
	return str(identity.get("token", "BET_UNKNOWN"))

static func get_level3_pact_unlock(bet_id: StringName) -> StringName:
	return LEVEL3_PACT_UNLOCKS.get(bet_id, &"")

static func get_level3_display_title(bet_id: StringName) -> String:
	var identity: Dictionary = resolve_bet_identity(bet_id)
	if str(identity.get("token", "BET_UNKNOWN")) != "BET_UNKNOWN":
		return str(identity.get("display_title", String(bet_id)))
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			return str(bet.get("display_title", bet.get("name", String(bet_id))))
	return String(bet_id)

static func get_level3_display_subtitle(bet_id: StringName) -> String:
	var identity: Dictionary = resolve_bet_identity(bet_id)
	if str(identity.get("token", "BET_UNKNOWN")) != "BET_UNKNOWN":
		return str(identity.get("display_subtitle", ""))
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			return str(bet.get("display_subtitle", ""))
	return ""

static func get_path_tag_for_bet_id(bet_id: StringName) -> StringName:
	var identity: Dictionary = resolve_bet_identity(bet_id)
	if str(identity.get("token", "BET_UNKNOWN")) != "BET_UNKNOWN":
		return identity.get("path_tag", PATH_UNKNOWN) as StringName
	for bet_value: Dictionary in LEVEL3_BETS:
		var bet: Dictionary = bet_value as Dictionary
		if StringName(str(bet.get("id", ""))) == bet_id:
			var tag: StringName = StringName(str(bet.get("path_tag", "")))
			if tag == &"":
				return PATH_UNKNOWN
			return tag
	return PATH_UNKNOWN

static func get_level3_path_tag(bet_id: StringName) -> StringName:
	# Deprecated alias for one sprint: use get_path_tag_for_bet_id().
	return get_path_tag_for_bet_id(bet_id)
