# Gallicus Code Quality

## Regola primaria

Non cambiare il core di gioco per migliorare la documentazione, la leggibilita' o il polish. Ogni patch deve dichiarare se tocca Core Authority, Flexible Domain o Tooling.

## Ownership

- `RunManager` possiede flow, transizioni e decisioni di run.
- `GameEvents` possiede il bus eventi.
- UI legge payload/stato ed emette intenti, non decide outcome.
- Cataloghi e dati definiscono contenuto, non autorita' di flow.
- CI e script validano contratti, non introducono runtime dependency.

## Refactor ammessi

- Locali, meccanici e dentro un solo dominio.
- Necessari a correggere un bug concreto.
- Coperti da test statico, smoke o checklist.
- Senza cambiare shape pubblica se non richiesto da un blocker reale.

## Refactor vietati

- Spostare authority da `RunManager`.
- Duplicare segnali o payload fuori da `GameEvents`.
- Aggiungere flow paralleli o fallback nascosti.
- Rinominare path/nodi senza aggiornare contratti e test.
- Aggiungere feature per "pulire" una patch di bugfix.

## Dati e configurazioni

- Usare cataloghi strutturati quando esistono.
- Evitare parsing testuale fragile per contenuti runtime.
- Ogni nuovo campo dati deve avere default, consumer chiaro e test/checklist.
- Ogni nuovo path `res://` deve passare `tools/ci/verify_res_paths.py`.

## Chiusura patch

Prima del final:
- Eseguire i test pertinenti in `docs/testing.md`.
- Eseguire scan mojibake.
- Segnalare test non eseguiti.
- Non dichiarare v0.5 signed senza CI/Linux e manual QA.
