# Gallicus Code Quality

## Regola primaria

Finire il prodotto senza spostare autorita' o riscrivere sistemi funzionanti.
Ogni patch dichiara obiettivo, zona, owner e prova di chiusura.

Il ciclo operativo con Astra e' in `docs/development_workflow.md`. Il modello
non modifica gli owner o i gate. La review finale verifica il comportamento
dal punto di ingresso reale, oltre ai singoli helper, con evidenza legata
alla build corrente. Il rischio determina le prove in `docs/testing.md`.

## Ownership

- `RunManager`: flow, transizioni e decisioni di run.
- `GameEvents`: bus di intenti ed eventi.
- UI: rendering reattivo e invio intenti.
- Cataloghi: contenuto e configurazione.
- Save boundary: validazione, serializzazione e migrazione.
- Tooling/CI: verifica, mai dipendenza runtime.

## Zone

- **Core Authority:** cambi minimi, canon e test obbligatori.
- **Flexible Domain:** UI, contenuto, audio e asset entro i contratti.
- **Tooling:** liberta' maggiore, senza introdurre logica runtime.

La classificazione dettagliata resta in `docs/canon/PROCESS_AND_FREEZE.md`.

## Patch feature

Prima di implementare:

1. identificare stage della roadmap;
2. leggere owner documentale e canon;
3. compilare la scheda object-first se player-facing;
4. identificare API, payload e save coinvolti;
5. definire test e screenshot prima dell'edit.

Durante:

- preferire pattern e helper esistenti;
- non aggiungere un manager per comodita';
- non duplicare dati o segnali;
- mantenere il cambiamento nel dominio previsto;
- aggiornare docs e test insieme al comportamento.

## Refactor ammessi

- necessari a un deliverable concreto;
- locali e coperti;
- senza cambio pubblico accidentale;
- con migrazione esplicita se toccano save o contract.

## Refactor vietati

- spostare flow fuori da `RunManager`;
- far decidere outcome alla UI;
- bus paralleli o segnali duplicati;
- fallback nascosti che saltano fasi;
- parsing fragile di copy per ottenere dati;
- rinomina massiva non richiesta dal deliverable;
- feature estranee inserite in un bugfix.

## Dati e asset

- Nuovo campo: default, owner, consumer, test.
- Nuovo `res://`: path validation.
- Nuovo asset: uso, licenza, import e prova visuale/audio.
- Nuova stringa: chiavi IT/EN/ES e controllo layout.

## Chiusura

- test pertinenti da `docs/testing.md`;
- docs refs e mojibake;
- `git diff --check`;
- test non eseguiti dichiarati;
- nessun gate segnato completo senza evidenza;
- roadmap aggiornata quando uno stage cambia stato.
