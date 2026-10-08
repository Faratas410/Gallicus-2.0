extends RefCounted

# Arena inhabitants; portraits never own the voice or decisions of the Register.
const CHARACTERS: Array[Dictionary] = [
  {
    "id": "nerio",
    "portrait": "res://assets/ui/generated/dialogue_nerio_cutout.png",
    "name": "Nerio",
    "role": "Gufo scrivano",
    "description": "Nerio allinea le copie con il bordo dell’ala. Di una raschiatura ricorda il punto esatto, non perché gli sia stata chiesta. Una pagina storta gli lascia il lavoro a metà."
  },
  {
    "id": "vessa",
    "portrait": "res://assets/ui/generated/dialogue_vessa_cutout.png",
    "name": "Vessa",
    "role": "Gufo delle quote",
    "description": "Vessa tiene il piumaggio composto e conta gli spazi vuoti sulla tavola delle quote. Gli altri le mostrano le ferite; lei guarda quanto margine rimane."
  },
  {
    "id": "orvo",
    "portrait": "res://assets/ui/generated/dialogue_orvo_cutout.png",
    "name": "Orvo",
    "role": "Gufo banditore",
    "description": "Orvo tiene un ciuffo verso i colleghi e l’altro verso la gradinata. Prova il richiamo sottovoce. Prima di lanciarlo aspetta che l’ultima fila ascolti: un annuncio sprecato non lo recupera."
  },
  {
    "id": "rugo",
    "portrait": "res://assets/ui/generated/dialogue_rugo_cutout.png",
    "name": "Rugo",
    "role": "Gallo della soglia",
    "description": "Rugo liscia sempre la stessa penna del petto. Nella cresta ha una tacca dei giorni in cui copriva gli annunci. Ora ascolta dalla soglia, col becco basso. La voce ce l’ha ancora; sceglie quando usarla."
  },
  {
    "id": "dima",
    "portrait": "res://assets/ui/generated/dialogue_dima_cutout.png",
    "name": "Dima",
    "role": "Gallina della gradinata",
    "description": "Dima tiene la zampa sul posto accanto finché la gradinata si riempie. Poi la toglie. Le basta il passo sulla pietra per sapere chi è arrivato. Vessa conta i posti; Dima ricorda chi ci sedeva."
  }
]

const DIALOGUES: Dictionary = {
  "pact": [
    [
      "Nerio: Aspetta. La firma è ancora fresca.",
      "Vessa: Intanto posso vendere il margine."
    ],
    [
      "Orvo: Posso annunciarlo?",
      "Nerio: Quando hai finito di muovermi la copia."
    ],
    [
      "Vessa: Fra quelle righe ci sta ancora qualcosa.",
      "Nerio: Ci sta la raschiatura. Lascia stare."
    ],
    [
      "Rugo: Hai copiato anche la tacca?",
      "Nerio: Sul foglio non c’era."
    ],
    [
      "Vessa: Quel posto è libero, Dima.",
      "Dima: Il righello lascialo dov’è."
    ],
    [
      "Vessa: Il conto è aperto.",
      "Nerio: La cifra l’ho copiata. Ora puoi riprenderlo."
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
      "Orvo: Dall’ultima fila non mi sentono.",
      "Vessa: Ma restano seduti. Continua."
    ],
    [
      "Vessa: La gradinata aspetta.",
      "Orvo: Aspetto che smettano di parlare."
    ],
    [
      "Nerio: Hai saltato l’ultima riga.",
      "Orvo: La tengo per quando ascoltano."
    ],
    [
      "Orvo: Non canti più, Rugo?",
      "Rugo: Aspetto che finisca il tuo richiamo."
    ],
    [
      "Dima: Ti ho sentito arrivare, prima del richiamo.",
      "Rugo: Il passo non l’ho cambiato."
    ],
    [
      "Orvo: Guarda come ti studiano.",
      "Rugo: Li vedo. Non ho ancora aperto il becco."
    ],
    [
      "Vessa: Guarda le monete. Basta tenerli dalla tua parte.",
      "Orvo: Se si rivoltano, il conto lo mandi tu."
    ],
    [
      "Dima: Sento la sabbia nelle tasche.",
      "Rugo: Aspetta. Non chiamarli ancora."
    ]
  ],
  "pact_worn": [
    [
      "Nerio: Un’altra copia.",
      "Vessa: Il margine lo prendo io."
    ],
    [
      "Orvo: Lo stesso annuncio?",
      "Nerio: Guarda il foglio."
    ],
    [
      "Vessa: È rimasto margine?",
      "Nerio: Serve a me."
    ],
    [
      "Rugo: La tacca resta.",
      "Nerio: Qui non c’è."
    ],
    [
      "Vessa: Posso misurare?",
      "Dima: Fino a qui."
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
      "Orvo: L’ultima fila non sente.",
      "Vessa: Ma resta."
    ],
    [
      "Vessa: Aspettano.",
      "Orvo: Aspetto anch’io."
    ],
    [
      "Nerio: L’annuncio?",
      "Orvo: Manca l’ultima riga."
    ],
    [
      "Orvo: Rugo, ci sei?",
      "Rugo: Ho ancora voce."
    ],
    [
      "Dima: Lo stesso passo.",
      "Rugo: Mi hai sentito."
    ],
    [
      "Orvo: Ti guardano.",
      "Rugo: Lo so."
    ],
    [
      "Vessa: Le monete.",
      "Orvo: O il conto."
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
