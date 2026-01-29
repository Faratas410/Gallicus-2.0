extends Resource
class_name CondannaData

@export var id: StringName
@export var title: String
@export var condition_text: String
@export var lore_text: String

static func make(
		id_value: StringName,
		title_value: String,
		condition_value: String,
		lore_value: String
	) -> CondannaData:
	var condanna := CondannaData.new()
	condanna.id = id_value
	condanna.title = title_value
	condanna.condition_text = condition_value
	condanna.lore_text = lore_value
	return condanna

static func defaults() -> Array[CondannaData]:
	var entries: Array[CondannaData] = []
	entries.append(make(
		&"CONDANNA_NON_MI_FERMERO",
		"Non mi fermerò.",
		"Hai rifiutato l’incasso quando potevi fermarti.",
		"Il pubblico aveva già contato le monete.\nTu hai chiuso il pugno."
	))
	entries.append(make(
		&"CONDANNA_ANCORA",
		"Ancora.",
		"Hai rifiutato l’incasso più di una volta nella stessa run.",
		"La folla ha smesso di gridare.\nHa iniziato a guardare."
	))
	entries.append(make(
		&"CONDANNA_FINCHE_REGGE",
		"Finché regge.",
		"Hai continuato a rilanciare quando il rischio era ormai evidente.",
		"Non era più una scommessa.\nEra una dimostrazione."
	))
	entries.append(make(
		&"CONDANNA_NON_DOVEVO_PROVARCI",
		"Non dovevo provarci.",
		"Hai rilanciato e perso la run subito dopo.",
		"Il silenzio dell’arena\nè durato più del previsto."
	))
	entries.append(make(
		&"CONDANNA_FIRMATO",
		"Firmato.",
		"Hai firmato il tuo primo patto.",
		"Nessuno ti ha forzato la mano."
	))
	entries.append(make(
		&"CONDANNA_SAPEVO_COSA_STAVO_FACENDO",
		"Sapevo cosa stavo facendo.",
		"Hai firmato un patto che ti ha condotto alla morte.",
		"La sentenza era scritta.\nHai solo aggiunto il nome."
	))
	entries.append(make(
		&"CONDANNA_L_HO_ACCETTATO",
		"L’ho accettato.",
		"Hai scelto una condanna senza ricevere alcun reward.",
		"La folla non ha capito.\nTu sì."
	))
	entries.append(make(
		&"CONDANNA_ERA_IL_PREZZO",
		"Era il prezzo.",
		"Hai perso la run a causa diretta di un patto firmato.",
		"Non è stata sfortuna."
	))
	entries.append(make(
		&"CONDANNA_SO_COME_FINISCE",
		"So come finisce.",
		"Hai continuato una run nonostante le tue condizioni critiche.",
		"Il corpo era già un avviso."
	))
	entries.append(make(
		&"CONDANNA_NON_OGGI",
		"Non oggi.",
		"Hai evitato la morte per un soffio.",
		"Il pubblico ha sospirato.\nTu no."
	))
	entries.append(make(
		&"CONDANNA_HO_VISTO_ABBASTANZA",
		"Ho visto abbastanza.",
		"Hai incassato dopo una sequenza di scelte rischiose.",
		"La saggezza arriva tardi.\nMa arriva."
	))
	entries.append(make(
		&"CONDANNA_MI_SONO_FERMATO",
		"Mi sono fermato.",
		"Hai incassato con un livello di rischio estremamente alto.",
		"Questa volta."
	))
	entries.append(make(
		&"CONDANNA_E_FINITA_COSI",
		"È finita così.",
		"Hai perso la tua prima run.",
		"L’arena non fa sconti ai nuovi."
	))
	entries.append(make(
		&"CONDANNA_NON_ABBASTANZA",
		"Non abbastanza.",
		"Hai perso la run vicino a una soglia decisiva.",
		"La folla aveva già deciso."
	))
	entries.append(make(
		&"CONDANNA_TROPPO_TARDI",
		"Troppo tardi.",
		"Hai preso una decisione rischiosa un attimo prima della fine.",
		"Un secondo prima\nsarebbe bastato."
	))
	entries.append(make(
		&"CONDANNA_NON_E_COLPA_LORO",
		"Non è colpa loro.",
		"Hai perso la run senza errori meccanici evidenti.",
		"Nessuno ha barato."
	))
	entries.append(make(
		&"CONDANNA_RICORDATO",
		"Ricordato.",
		"Hai completato una run.",
		"L’arena non dimentica."
	))
	entries.append(make(
		&"CONDANNA_VISTO_DAL_PUBBLICO",
		"Visto dal pubblico.",
		"Hai attirato l’attenzione totale della folla.",
		"Non eri più solo."
	))
	entries.append(make(
		&"CONDANNA_IL_TUO_NOME",
		"Il tuo nome.",
		"Il pubblico ha iniziato a riconoscerti.",
		"Ora sanno chi sei."
	))
	entries.append(make(
		&"CONDANNA_NON_SARA_L_ULTIMA",
		"Non sarà l’ultima.",
		"Sei tornato all’arena dopo una sconfitta.",
		"L’arena è ancora lì."
	))
	return entries
