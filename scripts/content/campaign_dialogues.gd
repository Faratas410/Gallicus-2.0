extends RefCounted

# Authored dialogue and machine status. Never computes campaign outcomes.
const SPEAKERS: Dictionary = {
  "nerio": {
    "name": "Nerio",
    "role": "Gufo scrivano",
    "portrait": "res://assets/ui/generated/dialogue_nerio.png"
  },
  "rugo": {
    "name": "Rugo",
    "role": "Gallo della soglia",
    "portrait": "res://assets/ui/generated/dialogue_rugo.png"
  },
  "dima": {
    "name": "Dima",
    "role": "Gallina della gradinata",
    "portrait": "res://assets/ui/generated/dialogue_dima.png"
  },
  "registry": {
    "name": "Registro",
    "role": "Terminale rituale · stato",
    "portrait": "res://assets/ui/generated/dialogue_registry_terminal.png"
  }
}

const SEQUENCES: Dictionary = {
  "entry": {
    "title": "La prima copia",
    "lines": [
      {
        "speaker": "nerio",
        "text": "La tavoletta entra qui. Sul vetro torna soltanto ciò che è stato accettato."
      },
      {
        "speaker": "registry",
        "text": "INGRESSO APERTO\nNessuna promessa iscritta."
      },
      {
        "speaker": "rugo",
        "text": "Quando il banditore copriva la mia voce, credevo che qui non arrivasse niente."
      },
      {
        "speaker": "nerio",
        "text": "Arrivava la firma."
      },
      {
        "speaker": "rugo",
        "text": "Quella sì. Anche quando io non avevo più fiato."
      },
      {
        "speaker": "nerio",
        "text": "La copia resta. Il resto lo sentirà la gradinata."
      }
    ]
  },
  "middle": {
    "title": "La stessa riga",
    "lines": [
      {
        "speaker": "dima",
        "text": "La tavola cambia foglio. Quel posto è ancora vuoto."
      },
      {
        "speaker": "rugo",
        "text": "Ti ricordi ancora il passo?"
      },
      {
        "speaker": "dima",
        "text": "Si fermava qui. Ora il banditore non lascia neppure la pausa."
      },
      {
        "speaker": "registry",
        "text": "ARCHIVIO DISPONIBILE\nTracce conservate."
      },
      {
        "speaker": "nerio",
        "text": "Ho sostituito la tavoletta. Il solco torna nello stesso punto."
      },
      {
        "speaker": "dima",
        "text": "Io conto i posti che non si riempiono."
      }
    ]
  },
  "departure": {
    "title": "Il posto accanto",
    "lines": [
      {
        "speaker": "nerio",
        "text": "Ho allineato anche l’ultima pila. Non resta nulla fuori margine."
      },
      {
        "speaker": "rugo",
        "text": "Eppure dalla soglia entra ancora aria."
      },
      {
        "speaker": "dima",
        "text": "Il posto accanto lo lascio libero."
      },
      {
        "speaker": "rugo",
        "text": "Non lo tieni più?"
      },
      {
        "speaker": "dima",
        "text": "Non serve occuparlo."
      },
      {
        "speaker": "rugo",
        "text": "Allora resto qui. Senza chiamare."
      }
    ]
  },
  "ledger": {
    "title": "Il conto di Vessa",
    "lines": [
      {
        "speaker": "nerio",
        "text": "Vessa ha aperto un conto a tuo nome. Io copio le cifre, lei decide il margine."
      },
      {
        "speaker": "dima",
        "text": "Un conto? Una volta qui si pagava con la voce."
      },
      {
        "speaker": "nerio",
        "text": "La voce non si archivia. I Denari sì."
      },
      {
        "speaker": "rugo",
        "text": "E quando il conto scende sotto zero?"
      },
      {
        "speaker": "nerio",
        "text": "Vessa non dimentica un debito. Lo ricorda alla gradinata, a ogni arena."
      },
      {
        "speaker": "dima",
        "text": "Allora anche la gradinata tiene un conto. Il suo non si scrive."
      }
    ]
  },
  "sand": {
    "title": "La sabbia nelle tasche",
    "lines": [
      {
        "speaker": "dima",
        "text": "Hai visto la prima fila? Ha le tasche piene di sabbia."
      },
      {
        "speaker": "rugo",
        "text": "Una volta la sabbia restava giù, sotto i passi. Copriva i segni."
      },
      {
        "speaker": "dima",
        "text": "Ora la raccolgono. La lanciano quando un patto non piace."
      },
      {
        "speaker": "rugo",
        "text": "E quando piace?"
      },
      {
        "speaker": "dima",
        "text": "Monete. Vessa le conta prima che tocchino terra."
      },
      {
        "speaker": "rugo",
        "text": "Sabbia o monete, il corpo le ricorda tutte e due."
      }
    ]
  },
  "call": {
    "title": "Il richiamo",
    "lines": [
      {
        "speaker": "rugo",
        "text": "Orvo prova i richiami sottovoce, prima di salire. Lo sento dalla soglia."
      },
      {
        "speaker": "dima",
        "text": "Tu non provavi mai."
      },
      {
        "speaker": "rugo",
        "text": "Io chiamavo e basta, sopra tutti. La tacca nella cresta è di quei giorni."
      },
      {
        "speaker": "nerio",
        "text": "Sul foglio la tacca non c’è. C’è solo l’annuncio accettato."
      },
      {
        "speaker": "rugo",
        "text": "Allora scrivi questo: oggi ho scelto di tacere."
      },
      {
        "speaker": "nerio",
        "text": "Un gallo che tace non è un atto. Non lo copio."
      }
    ]
  },
  "seats": {
    "title": "I posti in vendita",
    "lines": [
      {
        "speaker": "dima",
        "text": "Vessa è passata con il righello. Vuole vendere anche la terza fila."
      },
      {
        "speaker": "nerio",
        "text": "Ha misurato. Lo spazio libero rende, se lo si iscrive."
      },
      {
        "speaker": "dima",
        "text": "Ogni posto ha un passo. Io li riconosco tutti."
      },
      {
        "speaker": "rugo",
        "text": "Anche quello accanto a te?"
      },
      {
        "speaker": "dima",
        "text": "Quello non si misura. L’ho detto a Vessa: il righello si ferma lì."
      },
      {
        "speaker": "nerio",
        "text": "Ho copiato la misura fino al tuo posto. Oltre, il foglio resta bianco."
      }
    ]
  },
  "scraping": {
    "title": "La riga che resta",
    "lines": [
      {
        "speaker": "nerio",
        "text": "Ogni sera raschio le copie sbagliate. La cera torna liscia."
      },
      {
        "speaker": "registry",
        "text": "COPIA RESPINTA\nRiga già iscritta."
      },
      {
        "speaker": "nerio",
        "text": "Una riga non va via. Ho consumato tre lame."
      },
      {
        "speaker": "rugo",
        "text": "Che cosa dice?"
      },
      {
        "speaker": "nerio",
        "text": "Un nome e un fascicolo aperto. Il resto non è di mia competenza."
      },
      {
        "speaker": "dima",
        "text": "Lasciala dov’è. Anch’io lascio il posto com’è."
      }
    ]
  },
  "seat_kept": {
    "title": "Il posto tenuto",
    "lines": [
      {
        "speaker": "rugo",
        "text": "Ogni volta che la gradinata si riempie, tieni la zampa su quel posto."
      },
      {
        "speaker": "dima",
        "text": "Finché si riempie. Poi la tolgo, e nessuno si siede."
      },
      {
        "speaker": "rugo",
        "text": "Chi ci sedeva?"
      },
      {
        "speaker": "dima",
        "text": "Uno che chiudeva ogni bando. Orvo non faceva in tempo a bandire il successivo."
      },
      {
        "speaker": "nerio",
        "text": "Il fascicolo di quel posto risulta aperto. Non ho mai copiato la chiusura."
      },
      {
        "speaker": "dima",
        "text": "Perché non c’è stata. Si è alzato, e il posto è rimasto caldo."
      }
    ]
  },
  "footstep": {
    "title": "Il passo",
    "lines": [
      {
        "speaker": "dima",
        "text": "Oggi ho sentito un passo sulla pietra. Si fermava dove si fermava il suo."
      },
      {
        "speaker": "rugo",
        "text": "Il nuovo?"
      },
      {
        "speaker": "dima",
        "text": "Il nuovo. Stessa pausa prima della soglia, stesso piede avanti."
      },
      {
        "speaker": "nerio",
        "text": "Due soggetti non hanno lo stesso passo. Il Registro li distingue."
      },
      {
        "speaker": "dima",
        "text": "Il Registro distingue le righe. Io sento la pietra."
      },
      {
        "speaker": "rugo",
        "text": "Allora lascia la zampa dov’è, ancora per un po’."
      }
    ]
  },
  "slope": {
    "title": "La stessa pendenza",
    "lines": [
      {
        "speaker": "nerio",
        "text": "Ho messo la tua copia accanto a quella riga. Hanno la stessa pendenza."
      },
      {
        "speaker": "registry",
        "text": "CONFRONTO IN CORSO\nCorrispondenza parziale."
      },
      {
        "speaker": "rugo",
        "text": "Che vuol dire, parziale?"
      },
      {
        "speaker": "nerio",
        "text": "Che il Registro sta cercando dove finisce l’una e comincia l’altra."
      },
      {
        "speaker": "dima",
        "text": "Il posto è sempre lì. Non aspetta te. Lo tengo io."
      },
      {
        "speaker": "nerio",
        "text": "Lo annoto. Non so ancora in quale fascicolo."
      }
    ]
  }
}

# Racconti: the prize of Orvo's ladder. Each closed bando climbs a step and the
# next percorso opens on the racconto of that step, in this order, before the
# last Era. From the third on they follow one thread: the seat Dima keeps.
const TALES: Array[Dictionary] = [
  {"id": "ledger", "step": 1},
  {"id": "sand", "step": 2},
  {"id": "seat_kept", "step": 3},
  {"id": "call", "step": 4},
  {"id": "seats", "step": 5},
  {"id": "footstep", "step": 6},
  {"id": "scraping", "step": 7},
  {"id": "slope", "step": 8}
]
