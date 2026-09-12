extends RefCounted

# Text-only administration; never the voice or decisions of the Register.
const CHARACTERS: Array[Dictionary] = [
  {
    "id": "nerio",
    "name": "Nerio",
    "role": "Gufo scrivano",
    "description": "Nerio allinea le copie con il bordo dell’ala. Ricorda ogni raschiatura, mai il motivo di chi l’ha chiesta. Per lui una pagina fuori posto è un lavoro lasciato a metà."
  },
  {
    "id": "vessa",
    "name": "Vessa",
    "role": "Gufo delle quote",
    "description": "Vessa conta gli spazi rimasti sulla tavola delle quote. Il suo piumaggio è sempre composto. Parla di margine anche quando gli altri parlano di ferite."
  },
  {
    "id": "orvo",
    "name": "Orvo",
    "role": "Gufo banditore",
    "description": "Orvo rivolge un ciuffo alla gradinata e l’altro ai colleghi. Prova le parole sottovoce prima di lanciarle all’arena. Detesta sprecare un annuncio su chi non ascolta."
  }
]

const DIALOGUES: Dictionary = {
  "pact": [
    [
      "Nerio: La firma è asciutta.",
      "Vessa: Il margine resta in vendita."
    ],
    [
      "Orvo: Posso annunciarlo?",
      "Nerio: Prima lascia ferma la copia."
    ],
    [
      "Vessa: Hai lasciato spazio?",
      "Nerio: Fra le righe. Non nella firma."
    ]
  ],
  "gesture": [
    [
      "Orvo: L’ultima fila vuole sentire.",
      "Vessa: Tu conta chi resta."
    ],
    [
      "Vessa: La gradinata aspetta.",
      "Orvo: Le pause sono parte del richiamo."
    ],
    [
      "Nerio: Hai già finito l’annuncio?",
      "Orvo: Sto aspettando che mi ascoltino."
    ]
  ],
  "pact_worn": [
    [
      "Nerio: Un’altra copia.",
      "Vessa: Lo spazio si vende ancora."
    ],
    [
      "Orvo: Lo stesso annuncio?",
      "Nerio: Un foglio diverso."
    ],
    [
      "Vessa: È rimasto margine?",
      "Nerio: Sul bordo."
    ]
  ],
  "gesture_worn": [
    [
      "Orvo: Ancora l’ultima fila.",
      "Vessa: È ancora qui."
    ],
    [
      "Vessa: Aspettano.",
      "Orvo: Tengo la voce."
    ],
    [
      "Nerio: L’annuncio?",
      "Orvo: Più corto."
    ]
  ]
}

static func lines(context: String, variant: int, worn: bool, terminal: bool) -> Array[String]:
	var result: Array[String] = []
	if terminal or context not in ["pact", "gesture"]:
		return result
	var key: String = context + ("_worn" if worn else "")
	var options: Array = DIALOGUES[key]
	for line: String in options[posmod(variant, options.size())]:
		result.append(line)
	return result
