extends RefCounted

# The last Era's records as the sheet and the Archive say them. Italian source
# keys only; RunManager decides, SaveManager keeps, the UI translates.
const RESULTS: Dictionary = {
  "lauro": "Il conto di Vessa ha pagato la strofa di Lauro.",
  "crowd": "Il conto di Vessa è tornato alla gradinata.",
  "vessa": "Vessa ha tenuto il conto chiuso.",
  "voice": "Il debito è stato pagato con la voce.",
  "debt": "Il debito è rimasto scritto nel Registro.",
  "seat": "Nerio ha copiato il posto nell'ultimo foglio.",
  "gesta": "Nerio ha copiato la gesta più alta nell'ultimo foglio.",
  "scars": "Nerio ha copiato i Segni nell'ultimo foglio."
}

# Who keeps what Nerio does not copy.
const KEEPERS: Dictionary = {
  "seat": "Il posto: Dima lo ricorda.",
  "gesta": "La gesta più alta: Lauro la canta.",
  "scars": "I Segni: il corpo li porta."
}

const BANDO: Dictionary = {
  "closed": "L'ultimo bando è stato chiuso. Lauro ne ha fatto l'ultima strofa:",
  "missed": "L'ultimo bando non è stato chiuso. Lauro lo canta lo stesso:"
}

const WRITTEN_GESTA: String = "Lauro ha scritto la gesta più alta: %d Gloria in %d arene."

# Every source key, for the localisation contract.
static func all_keys() -> Array[String]:
	var keys: Array[String] = [WRITTEN_GESTA]
	for table: Dictionary in [RESULTS, KEEPERS, BANDO]:
		for key: String in table.values():
			keys.append(key)
	return keys
