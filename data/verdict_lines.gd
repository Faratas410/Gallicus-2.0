extends Resource
class_name VerdictLines

const OUTCOME_LOSS: String = "LOSS"
const OUTCOME_CASHOUT: String = "CASHOUT"
const OUTCOME_WIN: String = "WIN"

const SENTENCES_BY_OUTCOME: Dictionary = {
	OUTCOME_LOSS: [
		"Decadenza immediata della run.",
		"Esito negativo registrato.",
		"Caduta conclusiva senza appello.",
		"Sconfitta esecutiva.",
		"Interruzione per incapacità di proseguire.",
		"Cessazione per perdita di controllo.",
		"Fine per collasso del patto.",
		"Esito terminale: arena chiusa.",
		"Sentenza di caduta eseguita.",
		"Chiusura per decesso rituale.",
	],
	OUTCOME_CASHOUT: [
		"Cessazione con incasso.",
		"Uscita anticipata con liquidazione.",
		"Chiusura per riscossione.",
		"Ritiro registrato.",
		"Interruzione volontaria con pagamento.",
		"Fine di run per conservazione.",
		"Cessazione per tutela residua.",
		"Esito sospeso: incasso eseguito.",
		"Uscita controllata dall'arena.",
		"Run estinta per monetazione.",
	],
	OUTCOME_WIN: [
		"Esito di superamento registrato.",
		"Arena conclusa senza estinzione.",
		"Conclusione con obiettivo raggiunto.",
		"Esito valido a verbale.",
		"Chiusura per completamento.",
		"Run confermata, rischio adempiuto.",
		"Uscita dopo compimento del ciclo.",
		"Esito determinato: arena superata.",
		"Completamento sotto giudizio.",
		"Fine per esecuzione della prova.",
	],
}

const CHARGES_BY_OUTCOME: Dictionary = {
	OUTCOME_LOSS: [
		"Inidoneità alla tenuta del rischio.",
		"Rottura del patto in fase critica.",
		"Esposizione oltre capacità.",
		"Imprudenza non sostenuta.",
		"Insufficiente disciplina del sangue.",
		"Errore di valutazione del limite.",
		"Crollo per sovraesposizione.",
		"Cedimento in sede d'arena.",
		"Incapacità di sostenere il vincolo.",
		"Violazione del margine di sopravvivenza.",
	],
	OUTCOME_CASHOUT: [
		"Recesso anticipato.",
		"Interruzione per conservazione indebita.",
		"Ritiro prima della chiusura.",
		"Cessazione per tutela del residuo.",
		"Abbandono dell'escalation.",
		"Inadempienza alla prova finale.",
		"Rinuncia al compimento.",
		"Interruzione con saldo immediato.",
		"Sospensione dell'esito per lucro.",
		"Uscita per calcolo.",
	],
	OUTCOME_WIN: [
		"Persistenza oltre il limite consentito.",
		"Scommessa portata a compimento senza attenuanti.",
		"Ricerca di esito pieno senza indulgenza.",
		"Esecuzione integrale del rischio.",
		"Superamento con esposizione volontaria.",
		"Determinazione a costo totale.",
		"Ostinazione fino alla prova finale.",
		"Eccesso di fiducia nel patto.",
		"Aderenza totale alla posta.",
		"Pressione sostenuta fino all'ultimo atto.",
	],
}

const SENTENCE_MODIFIERS: Dictionary = {
	"many_pacts": [
		"Accumulo di patti aggravante.",
		"Serialità di firme registrata.",
		"Molteplicità di patti non attenuata.",
		"Sommatoria di vincoli riconosciuta.",
	],
	"high_risk": [
		"Escalation elevata accertata.",
		"Rischio oltre soglia registrato.",
		"Soglia di pericolo superata.",
		"Pressione estrema certificata.",
	],
	"lying_pact": [
		"Patto menzognero rilevato.",
		"Doppia clausola emersa.",
		"Contratto fallace individuato.",
		"Dichiarazione mendace agli atti.",
	],
	"condanna": [
		"Condanna acquisita nella run.",
		"Recidiva con marchio.",
		"Condanna formale applicata.",
		"Nuova condanna iscritta.",
	],
}

const CHARGE_MODIFIERS: Dictionary = {
	"many_pacts": [
		"Pluralità di patti come aggravante.",
		"Eccesso di firme.",
		"Accumulo contrattuale.",
		"Serialità di vincoli.",
	],
	"high_risk": [
		"Escalation oltre soglia.",
		"Rifiuto reiterato di uscita.",
		"Persistenza ad alto rischio.",
		"Sovraesposizione volontaria.",
	],
	"lying_pact": [
		"Inganno contrattuale accertato.",
		"Inganno in sede di patto.",
		"Clausola d'inganno sottoscritta.",
		"Inganno deliberato a verbale.",
	],
	"condanna": [
		"Condanna in atti, aggravante.",
		"Recidiva di condanna.",
		"Condanna rilevata in sede di giudizio.",
		"Presenza di condanna operativa.",
	],
}

static func pick_sentence(summary: Dictionary) -> String:
	var lines: Array[String] = _build_pool(summary, SENTENCES_BY_OUTCOME, SENTENCE_MODIFIERS)
	return _pick_line(lines, summary, 0)

static func pick_charge(summary: Dictionary) -> String:
	var lines: Array[String] = _build_pool(summary, CHARGES_BY_OUTCOME, CHARGE_MODIFIERS)
	return _pick_line(lines, summary, 17)

static func _build_pool(summary: Dictionary, outcome_bank: Dictionary, modifier_bank: Dictionary) -> Array[String]:
	var pool: Array[String] = []
	var outcome: String = _get_outcome(summary)
	var base_lines: Array = outcome_bank.get(outcome, []) as Array
	for line in base_lines:
		pool.append(str(line))
	if _has_many_pacts(summary):
		_append_modifier(pool, modifier_bank, "many_pacts")
	if _is_high_risk(summary):
		_append_modifier(pool, modifier_bank, "high_risk")
	if _has_lying_pact(summary):
		_append_modifier(pool, modifier_bank, "lying_pact")
	if _has_condanna(summary):
		_append_modifier(pool, modifier_bank, "condanna")
	return pool

static func _append_modifier(pool: Array[String], modifier_bank: Dictionary, key: String) -> void:
	var modifier_lines: Array = modifier_bank.get(key, []) as Array
	for line in modifier_lines:
		pool.append(str(line))

static func _get_outcome(summary: Dictionary) -> String:
	var raw_outcome: String = str(summary.get("outcome", OUTCOME_LOSS)).to_upper()
	match raw_outcome:
		OUTCOME_CASHOUT, OUTCOME_WIN, OUTCOME_LOSS:
			return raw_outcome
		_:
			return OUTCOME_LOSS

static func _has_many_pacts(summary: Dictionary) -> bool:
	var count_value: int = _get_count(summary, "pacts_signed_count", "pacts_signed")
	return count_value >= 3

static func _has_condanna(summary: Dictionary) -> bool:
	var count_value: int = _get_count(summary, "condanne_this_run_count", "condanne_this_run")
	return count_value >= 1

static func _is_high_risk(summary: Dictionary) -> bool:
	var escalation_value: int = int(summary.get("escalation_level", summary.get("max_escalation", 0)))
	var refuse_value: int = int(summary.get("refuse_cashout_count", summary.get("refuse_cashout_count_this_run", 0)))
	return escalation_value >= 7 or refuse_value >= 3

static func _has_lying_pact(summary: Dictionary) -> bool:
	return bool(summary.get("lying_pact_present", false))

static func _get_count(summary: Dictionary, count_key: String, list_key: String) -> int:
	if summary.has(count_key):
		return int(summary.get(count_key, 0))
	if summary.has(list_key) and summary[list_key] is Array:
		return int((summary[list_key] as Array).size())
	return 0

static func _pick_line(lines: Array[String], summary: Dictionary, seed_offset: int) -> String:
	if lines.is_empty():
		return ""
	var rng := RandomNumberGenerator.new()
	var seed_value: int = int(summary.get("seed", 0))
	if seed_value != 0:
		rng.seed = int(seed_value + seed_offset)
	else:
		rng.randomize()
	return lines[rng.randi_range(0, lines.size() - 1)]
