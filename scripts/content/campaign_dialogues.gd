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
  }
}
