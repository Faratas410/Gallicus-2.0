# Gallicus Design Skeleton

## Promessa

Gallicus e' un gioco rituale e narrativo in cui il giocatore e' il soggetto
portato davanti a un apparato che registra promesse, rischio e irreversibilita'.
Non controlla un avatar in combattimento: firma, espone gesti, accetta segni e
costringe il Registro a produrre una classificazione.

La prima campagna completa deve durare indicativamente 2-4 ore.

## Forma del prodotto

- Piattaforma di release: Windows x64.
- Superficie automatica canonica: CI Linux.
- Lingue di release: italiano, inglese e spagnolo.
- Struttura: campagna finita attraverso Ere `0..4`.
- Fine canonica: Assenza del Registro.
- Dopo la fine non esiste New Game+ che riattivi il Registro.

## Unita' giocabile

Il ciclo rituale di una singola run e':

```text
soglia -> Registro -> firma -> patto -> gesto pubblico
-> rito di giudizio -> incasso/condanna/rilancio -> fascicolo
```

Il ciclo tecnico sottostante resta:

```text
menu -> new run -> bet -> pact ritual -> intermediate choice
-> resolve ritual -> push your luck -> END_RUN
```

## Arco della campagna

1. Il Registro integro osserva e classifica.
2. Le scelte ripetute formano una firma comportamentale nascosta.
3. La firma converge con isteresi e modifica il tono amministrativo.
4. I Silenzi fanno avanzare il Registro attraverso quattro Ere.
5. Materiali, offerte, linguaggio e suono mostrano il deterioramento senza
   esporre numeri o nomi di Era.
6. Il Silenzio terminale conduce all'Assenza del Registro e chiude il gioco.

## Stato reale

Disponibile:

- ritual loop end-to-end;
- bet, scars, condanne, ending e temi arena;
- save/continue e impostazioni;
- Archivio e segnali di riconoscimento;
- smoke automatici per loop e route principali;
- prime variazioni visuali legate al Registro.

Da completare per 1.0:

- pass object-first su tutte le azioni gameplay;
- leggibilita' e feedback completi;
- firma comportamentale, coerenza e isteresi;
- avanzamento reale delle Ere tramite Silenzio;
- ramp, campagna terminale e blocco post-finale;
- contenuti e localizzazioni completi;
- identita' audio, VFX e cinematiche in-engine;
- accessibilita', export e QA pubblica.

## Pilastri

- **Atto fisico:** il player manipola oggetti credibili, non menu astratti.
- **Conseguenza leggibile:** rischio e costo sono comprensibili prima del gesto.
- **Memoria:** ogni atto lascia una registrazione, un segno o un'assenza.
- **Convergenza nascosta:** il sistema osserva senza mostrare una build statistica.
- **Finalita':** la campagna tende a una conclusione, non a una farm infinita.
- **Autorita' unica:** flow, eventi e UI rispettano gli owner esistenti.

## Non obiettivi

- action combat o nemici real-time;
- controllo diretto di Felix;
- power scaling tradizionale;
- economy aggiuntive non canoniche;
- modalita' endless o stagionale;
- store page, trailer o marketing nella roadmap produttiva.

## Definition of Done 1.0

Gallicus 1.0 e' finito quando:

- una nuova persona completa la campagna senza guida live;
- la durata mediana della prima campagna e' 2-4 ore;
- ogni azione critica ha feedback visivo, audio e testuale;
- Ere, Silenzi e Assenza rispettano il canon e persistono correttamente;
- nessun contenuto player-facing usa fallback o placeholder;
- IT/EN/ES sono complete e leggibili;
- save, continue, settings, route finali e stato terminale sono affidabili;
- export Windows, CI Linux e release checklist sono verdi;
- non restano fatal error, path mancanti o blocker noti.
