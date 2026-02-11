extends RefCounted
class_name ScarCatalog

const SCARS: Array[Dictionary] = [
	{
		"id": &"OPEN_WOUND",
		"name": "FERITA APERTA",
		"short_desc": "HP massimo ridotto.",
		"effect": "HP massimo ridotto e cure meno efficaci.",
		"effect_text": "HP massimo ridotto e cure meno efficaci.",
		"story": "Il sangue non si è mai fermato.",
		"narrative_text": "Il sangue ti segue anche quando l'arena tace.\nLa folla ascolta il tuo respiro corto.\nIl giudizio è già inciso sulla pelle.",
		"visual_tag": "🩸",
		"tags": [&"BLOOD", &"physical"],
	},
	{
		"id": &"CRACKED_BONES",
		"name": "OSSA INCRINATE",
		"short_desc": "Rischio aumentato nelle arene.",
		"effect": "Movimento rallentato e schivate meno affidabili.",
		"effect_text": "Movimento rallentato e schivate meno affidabili.",
		"story": "Ogni passo fa male.",
		"narrative_text": "Cammini con onore ma ogni passo pesa.\nIl debito del corpo resta sotto la sabbia.\nIl destino ti guarda senza tregua.",
		"visual_tag": "🦴",
		"tags": [&"BLOOD", &"physical"],
	},
	{
		"id": &"SHAME_MARK",
		"name": "MARCHIO DELLA VERGOGNA",
		"short_desc": "Il pubblico ti giudica.",
		"effect": "Aumenta la probabilità di subire danni.",
		"effect_text": "Aumenta la probabilità di subire danni.",
		"story": "Il boato è diventato un sibilo.",
		"narrative_text": "La vergogna ti precede davanti alla folla.\nOgni sguardo è un giudizio che brucia.\nPorti il segno anche quando vinci.",
		"visual_tag": "🎭",
		"tags": [&"SOCIAL", &"social"],
	},
	{
		"id": &"RUSTED_ARMOR",
		"name": "ARMATURA ARRUGGINITA",
		"short_desc": "Protezione compromessa.",
		"effect": "I danni sono più probabili.",
		"effect_text": "I danni sono più probabili.",
		"story": "Le crepe non si chiudono più.",
		"narrative_text": "Hai offerto onore e sangue, ma l'armatura non regge.\nLa ruggine canta il tuo debito.\nIl giudizio scivola sulle ferite.",
		"visual_tag": "🛡️",
		"tags": [&"physical"],
	},
	{
		"id": &"DEBT_BRAND",
		"name": "MARCHIO DEL DEBITO",
		"short_desc": "Escalation più severa.",
		"effect": "Le escalation puniscono di più.",
		"effect_text": "Le escalation puniscono di più.",
		"story": "Ogni vittoria ha un prezzo.",
		"narrative_text": "Il debito ti stringe come catena sacra.\nLa folla esige il prezzo della promessa.\nIl destino pesa su ogni patto.",
		"visual_tag": "⛓️",
		"tags": [&"risk"],
	},
	{
		"id": &"ONE_EYE",
		"name": "OCCHIO PERDUTO",
		"short_desc": "Il perfetto è più raro.",
		"effect": "Peggiora le chance di outcome puliti.",
		"effect_text": "Peggiora le chance di outcome puliti.",
		"story": "La profondità si è spenta.",
		"narrative_text": "Hai perso un occhio ma non la vergogna di guardare.\nIl sangue vela il tuo destino.\nLa folla vede la tua mancanza.",
		"visual_tag": "👁️",
		"tags": [&"BLOOD", &"physical"],
	},
]

func get_scar(id: StringName) -> Dictionary:
	for scar_value: Dictionary in SCARS:
		if StringName(str(scar_value.get("id", ""))) == id:
			return scar_value
	return {}

func list_scars() -> Array[Dictionary]:
	return SCARS.duplicate(true)
