# Integrazione locale dei contesti - 8 ottobre 2026

## Candidato e richiesta

Richiesta: risolvere i conflitti di GitHub Desktop applicando i contesti
piu' recenti. Stato iniziale pulito su main, HEAD
`0fe269991a60ef1b5f5f60b72e1b7d324951b7b1` (UI, 8 ottobre), un commit locale
e tre remoti oltre la base `da99a64`. Fetch aggiornato prima dell'integrazione:
origin/main `2e2ab6b22250c36f775d2898632a506d8dda0d57` (benchmark, 7 ottobre).

Il merge e' avviato con `--no-commit --no-ff`: HEAD resta il commit UI,
MERGE_HEAD identifica il remoto. Il candidato e' il working tree risolto,
non un nuovo commit o un export. Nessun branch, commit, push o PR creato.

## Risoluzioni

- I tre CSV conservano le chiavi del pass editoriale e aggiungono quelle
  di Lauro e del benchmark; i binari Translation sono rigenerati da Godot.
  Il termine spagnolo della quietanza e' `recibo`, anche nelle note del debito.
- Il manifest conserva tutti gli asset locali e aggiunge `dialogue_lauro`.
- Content bible e testing conservano entrambe le sezioni aggiunte in parallelo.
- Il fascicolo mantiene corpo 16 px e allineamento sinistro dell'8 ottobre;
  integra la colonna allargata di Lauro e rimuove il clipping del testo.
- Dima e Rugo conservano il pass editoriale piu' recente; gli scambi aggiunti
  di Lauro restano. La sua scheda riceve il campo `portrait` richiesto dal
  nuovo Archivio, collegato al segnaposto gia' presente nel remoto.
- La nota del banco mantiene la brevità locale e dichiara il doppio valore
  della quietanza in debito e la condizione di riapertura. Le tre lingue
  seguono lo stesso consumer. L'assicurazione esclude esplicitamente Hybris.
- Le integrazioni automatiche conservano gesta, salvataggio del massimo,
  nuovi racconti e priorita' per Era, guadagni reali/preview, uno o tre scambi,
  sblocco dei patti dalla scala e moltiplicatore del deposito in debito.

Owner invariati: RunManager decide, GameEvents trasporta, UI osserva.
La patch concilia le implementazioni esistenti; non inventa regole ulteriori.

## Verifica locale

Godot 4.6.2 Windows, profili temporanei distinti dai salvataggi personali.
Evidenze in `artifacts/merge_resolution_2026-10-08/` (directory ignorata).

- Import completato senza errori di script o risorse, log `import.log`.
- Playbook completo: 57/57 step verdi, summary
  `playbook/testing_playbook_summary.json`; include statici, CP-02, audit,
  audiovisivo, sei personaggi e dialoghi IT/EN/ES, campagna e otto smoke:
  BET_PRESENT, FULL_RUN, KEYBOARD_FULL_RUN, ROUTE_CASHOUT, ROUTE_DOUBLE,
  ROUTE_CONDANNA, ROUTE_REGISTER_FINAL, CORE_CONTINUITY.
- Campagna reale guidata automaticamente fino all'Assenza in 49 percorsi,
  resume e secondo processo terminale verificati; log in `playbook/campaign/`.
  Il tempo accelerato non misura durata o accettazione umana.
- Sei fixture renderizzate e ispezionate: banco in debito, gesta a quattro
  cifre e scheda di Lauro, IT a 1280x720 e 1920x1080. `MERGE_REVIEW_OK 6`;
  nessun taglio nelle superfici controllate. Output `screenshots/summary.json`.
  La prima prova usava un riferimento allo stato precedente al nuovo percorso:
  corretto nel solo fixture e ripetuto in un nuovo profilo. Il log precedente
  e' conservato come `visual_fixture_stale_state.log`.
- Dopo l'uniformazione finale ES: reimport e controllo i18n ripetuti.
- Docs refs, mojibake, marker di conflitto e diff check verificati sul finale.

Il PASS del runner non significa log interamente privi di diagnostica.
CP-02 inserisce intenzionalmente JSON corrotto per provare il recupero;
il suo script esistente crea due SaveManager fuori dall'albero senza
rilasciarli e riporta ObjectDB/resource leak in chiusura. La campagna riporta
anch'essa un warning ObjectDB al teardown. I contratti restituiscono exit 0
e i marker richiesti; queste diagnostiche sono conservate, non silenziate.
Import, AV/personaggi/dialoghi e le sei catture non riportano ERROR.

## File del candidato rispetto a HEAD

L'inventario comprende le aggiunte remote oltre alle risoluzioni manuali.

```text
assets/i18n/en.csv
assets/i18n/en.en.translation
assets/i18n/es.csv
assets/i18n/es.es.translation
assets/i18n/it.csv
assets/i18n/it.it.translation
assets/ui/generated/dialogue_lauro.png
assets/ui/generated/dialogue_lauro.png.import
assets/ui/generated/manifest.json
docs/README.md
docs/canon/GLOSSARY_ENTITIES.md
docs/canon/LORE_UNIFIED.md
docs/canon/MECHANICS_UNIFIED.md
docs/canon/RUN_ARCHITECTURE_CANON.md
docs/canon/UI_CANON.md
docs/content_bible.md
docs/development_plan.md
docs/direction.md
docs/support/benchmark_bcde_2026-10-07.md
docs/support/cantastorie_2026-10-07.md
docs/support/merge_integration_2026-10-08.md
docs/support/motivazione_2026-10-07.md
docs/testing.md
scenes/UI.tscn
scripts/ci/av_runtime_contract.gd
scripts/ci/campaign_runtime_contract.gd
scripts/ci/character_runtime_contract.gd
scripts/ci/illustrated_dialogue_contract.gd
scripts/ci/test_bando_ladder_contract.py
scripts/content/arena_characters.gd
scripts/content/campaign_dialogues.gd
scripts/content/cantastorie.gd
scripts/content/cantastorie.gd.uid
scripts/systems/run/run_state.gd
scripts/systems/run_manager.gd
scripts/systems/save_manager.gd
scripts/ui/betting_circle_ui.gd
scripts/ui/ui_root.gd
tools/campaign_sim.gd
tools/campaign_sim.gd.uid
```

## Handoff

I conflitti sono segnati risolti nell'indice; il merge attende il commit
manuale dell'utente in GitHub Desktop. Non ripetere pull o abortire il merge
per completare questo candidato: rivedere il diff e completare il commit.
Il push segue la scelta dell'utente.

Stage invariato: Core Playable Candidate. Checkpoint Linux sul nuovo commit,
playtest umano, valutazione artistica/audio e accettazione restano aperti.
Lauro conserva il segnaposto gia' dichiarato dal pacchetto remoto; nessuna
nuova art finale, build Windows, export o pubblicazione Steam in questa patch.
