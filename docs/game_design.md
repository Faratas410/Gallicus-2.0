# Gallicus Game Design

## Loop giocabile

Il gioco attivo e' il ritual loop:

1. Il giocatore entra dall'arena/menu.
2. Firma una scommessa nel Registro.
3. Attraversa un patto rituale.
4. Sceglie un gesto intermedio davanti alla gradinata.
5. Risolve il rito di giudizio.
6. Decide se incassare, accettare condanna o rilanciare.
7. Raggiunge END_RUN o prosegue una nuova scommessa.

## Sistemi attivi

- Bet catalog: proposte e identita' di scommessa.
- Condanne/scars: conseguenze e tracce.
- Pressione: rischio leggibile e presentazione UI.
- Ending rules: fascicolo finale e classificazione.
- Registro: grammatica narrativa e meta-struttura.

## Regole di design

- Ogni scelta deve dichiarare conseguenza percepibile.
- Ogni stato deve indicare prossima azione.
- Il rischio deve essere leggibile prima della scelta.
- Il finale deve chiarire se il percorso e' chiuso, registrato o proseguibile.
- Ogni nuova azione player-facing deve partire dalla grammatica object-first in `docs/object_grammar.md`.

## Grammatica object-first

Prima di progettare pulsanti, CTA o layout, definire l'atto fisico del soggetto nell'arena:

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

Il player non deve percepire "premi un comando", ma "apri una tavola", "incidi un patto", "colpisci il sigillo", "prendi una quietanza", "accetti un marchio". I bottoni possono restare l'implementazione tecnica dell'input, ma la schermata deve far capire quale oggetto viene manipolato e cosa il Registro puo' annotare.

La mappa operativa vive in `docs/object_grammar.md`.

## Fuori scope

- Combattimento action.
- Nemici real-time.
- Skill tree action.
- Nuove risorse economiche non gia' canoniche.
- Nuove ere o sistemi narrativi senza canon amendment.

## Verifica

- I cambi di loop richiedono aggiornamento a `docs/canon/MECHANICS_UNIFIED.md`.
- I cambi di flow richiedono aggiornamento a `docs/canon/RUN_ARCHITECTURE_CANON.md`.
- I cambi di UI player-facing richiedono screenshot QA.
- Le nuove feature player-facing richiedono checklist object-first compilata.
