# Gallicus Design Skeleton

## Identita'

Gallicus e' un gioco Godot rituale/narrativo centrato su promessa, rischio e Registro. La build corrente punta a una v0.5 internal beta: tester esterni al team devono poter avviare, capire il loop, completare piu' run e dare feedback senza spiegazione live.

## Loop attivo

Il loop canonico e':

`menu -> new run -> bet -> pact ritual -> scelta intermedia -> resolve ritual -> push-your-luck -> END_RUN`

Il core non include action combat, nemici real-time, upgrade action o sistemi di controllo avatar. Qualsiasi riferimento a player/enemy nei test o negli asset e' compatibilita' storica o audio temporaneo, non direzione di design.

## Stato corrente

- Classificazione operativa: v0.5 internal beta candidate.
- CI/Linux smoke matrix: firmata nella documentazione di stato corrente.
- Manual QA: ancora necessaria per firmare v0.5.
- Core authority: `RunManager`.
- Event bus: `GameEvents`.
- UI: reattiva, non autoritativa.
- Content expansion: usa cataloghi esistenti, non nuove meccaniche.

## Pilastri

- Decisione leggibile: il giocatore deve sempre sapere cosa sta firmando, rischiando o chiudendo.
- Rito prima di simulazione fisica: pressione, segni, condanne e Registro sono il linguaggio del gioco.
- Contenuto verificabile: bet, condanne, endings e payload devono avere test o checklist.
- Build testabile: ogni milestone deve avere static guard, smoke o QA manuale.

## Fuori scope fino a v0.5 signed

- Nuovo combat/action loop.
- Nuove meccaniche con ownership non documentata.
- Redesign UI esteso.
- Lore expansion non collegata al loop giocabile.
- Asset concept-only non usabili runtime.

## Verifica

- Leggere `docs/development_plan.md` per il prossimo blocco.
- Usare `docs/testing.md` prima di chiudere una patch.
- Se un cambio modifica il loop, aggiornare prima il canon owner pertinente.
