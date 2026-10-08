extends RefCounted

# Authored dialogue and machine status. Never computes campaign outcomes.
const SPEAKERS: Dictionary = {
  "nerio": {
    "name": "Nerio",
    "role": "Gufo scrivano",
    "portrait": "res://assets/ui/generated/dialogue_nerio_cutout.png"
  },
  "rugo": {
    "name": "Rugo",
    "role": "Gallo della soglia",
    "portrait": "res://assets/ui/generated/dialogue_rugo_cutout.png"
  },
  "dima": {
    "name": "Dima",
    "role": "Gallina della gradinata",
    "portrait": "res://assets/ui/generated/dialogue_dima_cutout.png"
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
        "text": "La tavoletta entra qui. Guarda il vetro: torna soltanto ciò che hai accettato."
      },
      {
        "speaker": "registry",
        "text": "INGRESSO APERTO\nNessuna promessa iscritta."
      },
      {
        "speaker": "rugo",
        "text": "E quando Orvo copriva la mia voce? Qui arrivava qualcosa?"
      },
      {
        "speaker": "nerio",
        "text": "Arrivava la firma."
      },
      {
        "speaker": "rugo",
        "text": "Io avevo finito il fiato. Quella l’hai presa tutta?"
      },
      {
        "speaker": "nerio",
        "text": "Tutta. È qui, se vuoi controllare."
      }
    ]
  },
  "middle": {
    "title": "La stessa riga",
    "lines": [
      {
        "speaker": "dima",
        "text": "Un altro foglio. Il posto accanto è ancora vuoto."
      },
      {
        "speaker": "rugo",
        "text": "Lo riconosceresti ancora dal passo?"
      },
      {
        "speaker": "dima",
        "text": "Si fermava qui. Orvo ora tira dritto con l’annuncio. Non lascia più quella pausa."
      },
      {
        "speaker": "registry",
        "text": "ARCHIVIO DISPONIBILE\nTracce conservate."
      },
      {
        "speaker": "nerio",
        "text": "Ho cambiato la tavoletta. Guarda: il solco torna proprio qui."
      },
      {
        "speaker": "dima",
        "text": "Sì, lo vedo. Ma ti stavo parlando del posto."
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
        "text": "Dalla soglia entra ancora aria. La senti?"
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
        "text": "No. Tolgo la zampa."
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
        "text": "Questo è il tuo conto da Vessa. Le cifre le copio io; il margine lo decide lei."
      },
      {
        "speaker": "dima",
        "text": "Prima dei Denari pagavamo con la voce. Quella dove la metti?"
      },
      {
        "speaker": "nerio",
        "text": "Sul conto ci sono i Denari, Dima. Per la voce non ho una cifra."
      },
      {
        "speaker": "rugo",
        "text": "E quando il conto scende sotto zero?"
      },
      {
        "speaker": "nerio",
        "text": "Vessa lo ricorda alla gradinata. A ogni arena, finché resta il debito."
      },
      {
        "speaker": "dima",
        "text": "Così la voce torna buona. Per riscuotere."
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
        "text": "Prima restava sotto i passi. Almeno copriva i segni."
      },
      {
        "speaker": "dima",
        "text": "Adesso se la tengono. Se il patto non piace, la tirano."
      },
      {
        "speaker": "rugo",
        "text": "E quando piace?"
      },
      {
        "speaker": "dima",
        "text": "Tirano monete. Vessa è già lì che le conta."
      },
      {
        "speaker": "rugo",
        "text": "Quelle almeno si vedono arrivare."
      }
    ]
  },
  "call": {
    "title": "Il richiamo",
    "lines": [
      {
        "speaker": "rugo",
        "text": "Orvo sta provando il richiamo. Lo sento anche quando crede di parlare piano."
      },
      {
        "speaker": "dima",
        "text": "Tu non provavi mai."
      },
      {
        "speaker": "rugo",
        "text": "Chiamavo sopra tutti. Questa tacca me la porto da allora."
      },
      {
        "speaker": "nerio",
        "text": "Qui ho l’annuncio accettato. Della tacca non c’è traccia."
      },
      {
        "speaker": "rugo",
        "text": "Allora scrivi questo: oggi ho scelto di tacere."
      },
      {
        "speaker": "nerio",
        "text": "Non ho un atto da copiare, Rugo."
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
        "text": "Mi ha dato le misure. Devo copiarle tutte."
      },
      {
        "speaker": "dima",
        "text": "Tutte? Io so chi si sedeva in ciascuno di quei posti."
      },
      {
        "speaker": "rugo",
        "text": "Anche quello accanto a te?"
      },
      {
        "speaker": "dima",
        "text": "Le ho fermato il righello. Fin qui, le ho detto. Non oltre."
      },
      {
        "speaker": "nerio",
        "text": "La mia copia finisce al tuo posto. Dopo ho lasciato bianco."
      }
    ]
  },
  "scraping": {
    "title": "La riga che resta",
    "lines": [
      {
        "speaker": "nerio",
        "text": "Le altre copie le ho raschiate. Come ogni sera. Passa l’ala: sono lisce."
      },
      {
        "speaker": "registry",
        "text": "COPIA RESPINTA\nRiga già iscritta."
      },
      {
        "speaker": "nerio",
        "text": "Questa invece è ancora qui. Tre lame, e non sono riuscito a toglierla."
      },
      {
        "speaker": "rugo",
        "text": "Che cosa dice?"
      },
      {
        "speaker": "nerio",
        "text": "Un nome. Il fascicolo è aperto. Non ho altro da trascrivere."
      },
      {
        "speaker": "dima",
        "text": "Lascia stare la lama. Io il posto lo tengo ancora."
      }
    ]
  },
  "seat_kept": {
    "title": "Il posto tenuto",
    "lines": [
      {
        "speaker": "rugo",
        "text": "Dima, la gradinata si sta riempiendo. Hai ancora la zampa lì."
      },
      {
        "speaker": "dima",
        "text": "Aspetto che si siedano. Dopo la tolgo. Tanto lì non si mette nessuno."
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
        "text": "Manca la chiusura del fascicolo. Non l’ho mai ricevuta da copiare."
      },
      {
        "speaker": "dima",
        "text": "Io l’ho visto alzarsi. Il posto era ancora caldo. La chiusura non c’è stata."
      }
    ]
  },
  "footstep": {
    "title": "Il passo",
    "lines": [
      {
        "speaker": "dima",
        "text": "Quel passo, oggi. Si è fermato sulla stessa pietra."
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
        "text": "Le righe sono distinte. Su questo non c’è dubbio."
      },
      {
        "speaker": "dima",
        "text": "Non ti ho chiesto delle righe. La pausa l’ho sentita."
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
        "text": "Parziale. Le separi o no?"
      },
      {
        "speaker": "nerio",
        "text": "La pendenza coincide. Non basta per metterle nello stesso fascicolo."
      },
      {
        "speaker": "dima",
        "text": "Il posto è sempre lì. Non aspetta te. Lo tengo io."
      },
      {
        "speaker": "nerio",
        "text": "Tengo le copie qui. Non le ho ancora archiviate."
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
