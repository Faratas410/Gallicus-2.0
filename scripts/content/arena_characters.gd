extends RefCounted

# Text-only arena inhabitants; never the voice or decisions of the Register.
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
  },
  {
    "id": "rugo",
    "name": "Rugo",
    "role": "Gallo della soglia",
    "description": "Rugo ha una tacca nella cresta e liscia sempre la stessa penna del petto. Dalla soglia ascolta il banditore senza alzare il becco. Una volta gridava sopra gli annunci; ora sceglie quando farsi sentire."
  },
  {
    "id": "dima",
    "name": "Dima",
    "role": "Gallina della gradinata",
    "description": "Dima tiene una zampa sul posto accanto finché la gradinata si riempie. Riconosce i presenti dal passo sulla pietra. Quando Vessa conta i posti, lei ricorda chi li occupava."
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
    ],
    [
      "Rugo: L’inchiostro copre anche la tacca?",
      "Nerio: La copia non ha piume."
    ],
    [
      "Vessa: Quel posto è libero, Dima.",
      "Dima: So chi ci sedeva."
    ],
    [
      "Vessa: Il conto è aperto.",
      "Nerio: Copio la cifra, non il motivo."
    ],
    [
      "Orvo: La prima fila ha le tasche piene.",
      "Vessa: Di sabbia o di monete?"
    ],
    [
      "Dima: Hanno venduto la terza fila.",
      "Vessa: Il tuo posto no. Per ora."
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
    ],
    [
      "Orvo: Non canti più, Rugo?",
      "Rugo: Aspetto che finisca il tuo richiamo."
    ],
    [
      "Dima: Ti ho sentito dalla pietra.",
      "Rugo: Il passo è rimasto quello."
    ],
    [
      "Orvo: Guarda come ti studiano.",
      "Rugo: Prima di gridare, la gradinata pesa."
    ],
    [
      "Vessa: La folla paga chi la regge.",
      "Orvo: E presenta il conto a chi la perde."
    ],
    [
      "Dima: Sento la sabbia nelle tasche.",
      "Rugo: Allora non è ancora il momento."
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
    ],
    [
      "Rugo: La tacca resta.",
      "Nerio: Anche la copia."
    ],
    [
      "Vessa: Sempre quel posto?",
      "Dima: Sempre quello."
    ],
    [
      "Vessa: Il conto.",
      "Nerio: Copiato."
    ],
    [
      "Orvo: Tasche piene.",
      "Vessa: Monete, spero."
    ],
    [
      "Dima: La terza fila.",
      "Vessa: Venduta."
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
    ],
    [
      "Orvo: Rugo, ci sei?",
      "Rugo: Ho ancora voce."
    ],
    [
      "Dima: Lo stesso passo.",
      "Rugo: Lo senti ancora."
    ],
    [
      "Orvo: Ti pesano.",
      "Rugo: Lo so."
    ],
    [
      "Vessa: Paga chi regge.",
      "Orvo: Sempre."
    ],
    [
      "Dima: La sabbia.",
      "Rugo: Non ancora."
    ]
  ]
}

static func variant_count(context: String) -> int:
	return DIALOGUES.get(context, []).size()

static func lines(context: String, variant: int, worn: bool, terminal: bool) -> Array[String]:
	var result: Array[String] = []
	if terminal or context not in ["pact", "gesture"]:
		return result
	var key: String = context + ("_worn" if worn else "")
	var options: Array = DIALOGUES[key]
	for line: String in options[posmod(variant, options.size())]:
		result.append(line)
	return result
