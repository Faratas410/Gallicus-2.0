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
  "lauro": {
    "name": "Lauro",
    "role": "Storno cantastorie",
    "portrait": "res://assets/ui/generated/dialogue_lauro_cutout.png"
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
  "seat_reserved_followup": {
    "title": "La ricevuta piegata",
    "lines": [
      {"speaker": "dima", "text": "Vessa ha fermato il righello. Mi ha dato questa ricevuta: tienila tu, ha detto."},
      {"speaker": "rugo", "text": "Il posto è pagato. Perché la pieghi proprio lì?"},
      {"speaker": "dima", "text": "C'è un foro sul margine. La piega passa di lì, ma il foglio sotto non c'è."},
      {"speaker": "nerio", "text": "La copia del Registro finisce prima del foro. Avevo ricevuto solo quella parte."},
      {"speaker": "rugo", "text": "E da quella copia puoi sapere chi sedeva lì?"},
      {"speaker": "dima", "text": "Lascio la ricevuta sul posto. Se torna il foglio sotto, sapremo dove attaccarlo."}
    ]
  },
  "seat_witness_followup": {
    "title": "La voce nella fila",
    "lines": [
      {"speaker": "dima", "text": "Ho indicato il posto davanti a tutti. La prima fila ha smesso di contare le monete."},
      {"speaker": "rugo", "text": "E dopo? Ti hanno lasciata parlare?"},
      {"speaker": "dima", "text": "Una voce ha detto che il foglio era più lungo. Poi la gradinata ha coperto il resto."},
      {"speaker": "nerio", "text": "La copia che ho ricevuto finisce prima del posto. Sul margine c'è un foro senza fermaglio."},
      {"speaker": "rugo", "text": "E da quella copia puoi sapere chi sedeva lì?"},
      {"speaker": "dima", "text": "Chi ha parlato era nella prima fila. La prossima volta ascolterò da lì."}
    ]
  },
  "seat_receipt_after_inquiry": {
    "title": "Il margine piegato",
    "lines": [
      {"speaker": "dima", "text": "Ho lasciato la ricevuta sul posto. Stanotte qualcuno l'ha ripiegata sul foro."},
      {"speaker": "rugo", "text": "Hai visto chi?"},
      {"speaker": "dima", "text": "No. Ma la piega non era la mia. Io la lascio sempre aperta."},
      {"speaker": "nerio", "text": "La mia copia si ferma qui. Posso segnare il margine, non chi l'ha toccato."},
      {"speaker": "rugo", "text": "E la ricevuta?"},
      {"speaker": "dima", "text": "La tengo sul posto. Se torna un'altra mano, troverà ancora il foro."}
    ]
  },
  "seat_voice_after_inquiry": {
    "title": "La fila ascolta",
    "lines": [
      {"speaker": "dima", "text": "Sono tornata nella prima fila. Alla domanda sul foglio, nessuno ha detto il proprio nome."},
      {"speaker": "rugo", "text": "E quella voce?"},
      {"speaker": "dima", "text": "Non l'ho ritrovata. Qualcuno ha fatto spazio accanto a me, senza parlare."},
      {"speaker": "nerio", "text": "Nella copia posso lasciare il margine aperto. Non posso scrivere chi ha parlato."},
      {"speaker": "rugo", "text": "La fila ha sentito la domanda."},
      {"speaker": "dima", "text": "Sì. La prossima volta lascio spazio anch'io, se qualcuno vuole rispondere."}
    ]
  },
  "seat_copy_for_nerio": {
    "title": "Il margine copiato",
    "lines": [
      {"speaker": "nerio", "text": "Ho trascritto la tua annotazione sul margine. Non è il foglio che manca."},
      {"speaker": "dima", "text": "La mia resta qui, vicino al posto."},
      {"speaker": "rugo", "text": "Se una sparisce, l'altra può ancora parlare?"},
      {"speaker": "nerio", "text": "Può mostrare che abbiamo trovato una lacuna. Non può dire chi sedeva."}
    ]
  },
  "seat_copy_for_dima": {
    "title": "Il foglio di Dima",
    "lines": [
      {"speaker": "nerio", "text": "Nel mio fascicolo non c'è una copia dell'annotazione."},
      {"speaker": "dima", "text": "La tengo io, accanto al posto. Il margine è piegato verso l'interno."},
      {"speaker": "rugo", "text": "Se qualcuno la chiede?"},
      {"speaker": "dima", "text": "Può guardarla qui. Non gli dirà chi sedeva, ma vedrà quello che manca."}
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
  },
  "first_strophe": {
    "title": "La prima strofa",
    "lines": [
      {
        "speaker": "lauro",
        "text": "Udite, gradinata! Un passo nuovo sulla sabbia. Cerco già la rima."
      },
      {
        "speaker": "dima",
        "text": "Lauro è tornato. Ha imparato il richiamo di Orvo prima di Orvo."
      },
      {
        "speaker": "nerio",
        "text": "Il cantastorie non copia. Ogni sera cambia una parola."
      },
      {
        "speaker": "lauro",
        "text": "Tu copi le righe, Nerio. Io canto quello che le righe lasciano fuori."
      },
      {
        "speaker": "rugo",
        "text": "Nella sua strofa la mia cresta è ogni volta più alta."
      },
      {
        "speaker": "lauro",
        "text": "L’arena dimentica. Il Registro no. Io ricordo male, ma ricordo."
      }
    ]
  },
  "open_strophe": {
    "title": "La strofa aperta",
    "lines": [
      {
        "speaker": "lauro",
        "text": "C’è una gesta che canto da anni. Uno che chiudeva ogni bando, senza fretta."
      },
      {
        "speaker": "dima",
        "text": "E la gradinata non applaude mai. Ascolta e basta."
      },
      {
        "speaker": "lauro",
        "text": "Perché non finisce. Arrivo a quando si alza, e la rima non viene."
      },
      {
        "speaker": "nerio",
        "text": "Non viene perché manca la chiusura. Quel fascicolo risulta aperto."
      },
      {
        "speaker": "rugo",
        "text": "Inventala. È il tuo mestiere."
      },
      {
        "speaker": "lauro",
        "text": "Una fine inventata la canta chiunque. Questa la lascio aperta, come il posto."
      }
    ]
  }
}

# Racconti: the prize of Orvo's ladder. Each closed bando climbs a step and the
# next percorso opens on the racconto of that step, in this order, before the
# last Era. The first brings Lauro, the cantastorie; from the fourth on they
# follow one thread: the seat Dima keeps, and the strophe Lauro cannot close.
# The racconti with an "era" carry the empty seat the farewell rests on: the
# campaign tells them from that Era even without the bando, always before the
# farewell. The ladder only brings them sooner.
const TALES: Array[Dictionary] = [
  {"id": "first_strophe", "step": 1},
  {"id": "ledger", "step": 2},
  {"id": "sand", "step": 3},
  {"id": "seat_kept", "step": 4, "era": 1},
  {"id": "call", "step": 5},
  {"id": "seats", "step": 6},
  {"id": "footstep", "step": 7, "era": 1},
  {"id": "open_strophe", "step": 8, "era": 2},
  {"id": "scraping", "step": 9},
  {"id": "slope", "step": 10, "era": 2}
]
