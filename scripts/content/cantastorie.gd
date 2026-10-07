extends RefCounted

# Lauro's gesta: the strophe the storno cantastorie sings over a closed percorso.
# Authored verses only. The facts come from RunManager; this file never
# computes outcomes, it picks lines. Every line is an Italian source key with
# an optional number, translated by the UI.
const SINGER: String = "Lauro"

const OPENINGS: Dictionary = {
  "one": [
    "Udite: una soglia, una sola arena.",
    "Udite: un passo solo sulla sabbia."
  ],
  "few": [
    "Udite: %d arene sotto la stessa gradinata.",
    "Udite: %d arene, e la gradinata non perde un gesto."
  ],
  "many": [
    "Udite: %d arene, e nessuno lascia il suo posto.",
    "Udite: %d arene, fino a far tacere Orvo."
  ],
  "all": [
    "Udite: sette arene, fino all'ultima soglia.",
    "Udite: sette arene, e la sabbia non basta più."
  ]
}

# The highlight is the first fact that holds, in this order.
const HIGHLIGHTS: Dictionary = {
  "bando": [
    "Il bando di Orvo, chiuso prima dell'ultimo richiamo.",
    "Il bando chiuso, e Orvo resta senza voce."
  ],
  "chain": [
    "%d sigilli di fila, e la cera non cede.",
    "%d sigilli di fila: la catena suona come un coro."
  ],
  "triumph": [
    "La gradinata si alza insieme, come uno stormo.",
    "La gradinata porta il passo, fila dopo fila."
  ],
  "scar_shown": [
    "Un Segno mostrato alla folla, invece della posta.",
    "Il corpo mostra un Segno, e la posta resta intera."
  ],
  "riot": [
    "La sabbia vola dalla prima fila, e il passo non si ferma.",
    "La prima fila lancia sabbia; la sabbia non basta."
  ],
  "glory": [
    "%d Gloria, e Vessa la conta due volte.",
    "%d Gloria, e la terza fila si alza."
  ],
  "plain": [
    "Pochi colpi al sigillo, ognuno ascoltato.",
    "Un patto firmato, e la gradinata trattiene il fiato."
  ]
}

const CLOSINGS: Dictionary = {
  "quietanza": [
    "Poi la quietanza: il Registro copia la cifra, io il resto.",
    "Poi la quietanza, presa a mano ferma."
  ],
  "marchio": [
    "Poi il marchio, scelto a mano ferma.",
    "Poi il marchio: la posta resta sulla sabbia."
  ],
  "cede": [
    "Poi la cera cede. Finisce la strofa, non la voce.",
    "Poi la cera cede. Domani la canto meglio."
  ],
  "fascicolo": [
    "Il Registro chiude il fascicolo. La strofa resta aperta.",
    "Il Registro classifica. Io canto."
  ]
}

const CHAIN_HIGHLIGHT_MIN: int = 3
const GLORY_HIGHLIGHT_MIN: int = 20

# facts: arenas, glory, bando_closed, chain_peak, triumphs, riots, scar_shown,
# end ("quietanza", "marchio", "cede", "fascicolo"), seed.
static func compose(facts: Dictionary) -> Array[Dictionary]:
	var pick: int = int(facts.get("seed", 0))
	var arenas: int = maxi(int(facts.get("arenas", 1)), 1)
	var glory: int = maxi(int(facts.get("glory", 0)), 0)
	var chain: int = int(facts.get("chain_peak", 0))
	var opening_kind: String = "one"
	if arenas >= 7:
		opening_kind = "all"
	elif arenas >= 5:
		opening_kind = "many"
	elif arenas >= 2:
		opening_kind = "few"
	var highlight_kind: String = "plain"
	var highlight_value: int = -1
	if bool(facts.get("bando_closed", false)):
		highlight_kind = "bando"
	elif chain >= CHAIN_HIGHLIGHT_MIN:
		highlight_kind = "chain"
		highlight_value = chain
	elif int(facts.get("triumphs", 0)) > 0:
		highlight_kind = "triumph"
	elif bool(facts.get("scar_shown", false)):
		highlight_kind = "scar_shown"
	elif int(facts.get("riots", 0)) > 0:
		highlight_kind = "riot"
	elif glory >= GLORY_HIGHLIGHT_MIN:
		highlight_kind = "glory"
		highlight_value = glory
	var closing_kind: String = str(facts.get("end", "cede"))
	if not CLOSINGS.has(closing_kind):
		closing_kind = "cede"
	var opening_value: int = arenas if opening_kind in ["few", "many"] else -1
	return [
		_line(OPENINGS[opening_kind], pick, opening_value),
		_line(HIGHLIGHTS[highlight_kind], pick + 1, highlight_value),
		_line(CLOSINGS[closing_kind], pick + 2, -1),
	]

static func _line(options: Array, pick: int, value: int) -> Dictionary:
	return {"key": str(options[posmod(pick, options.size())]), "value": value}

# Every source key, for the localisation contract.
static func all_keys() -> Array[String]:
	var keys: Array[String] = []
	for table: Dictionary in [OPENINGS, HIGHLIGHTS, CLOSINGS]:
		for options: Array in table.values():
			for key: String in options:
				keys.append(key)
	return keys
