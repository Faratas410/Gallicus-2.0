# Documentation Entry

La documentazione attiva e' organizzata con entrypoint operativo in:

- `docs/support/INDEX.md`

## Percorso consigliato

1. Apri `docs/support/INDEX.md`.
2. Parti da `docs/canon/FOUNDATIONS.md`.
3. Usa `docs/canon/CANON_DEPENDENCY_MATRIX.md` per ownership e precedence.
4. Consulta solo il file canon owner della categoria interessata.
5. Tratta eventuali marker `legacy:<slug>` come lineage storica gia' assorbita, non come file attivi da cercare.

## Struttura documentale

- `docs/canon/` - owner canonici e governance.
- `docs/contracts/` - contratti tecnici di supporto usati anche da tooling/CI.
- `docs/support/` - mappe, indici e riferimenti operativi non canonici.
- `docs/reports/` - superficie report attivi (vuota finche' non vengono generati nuovi report correnti).
- `docs/archive/` - materiale storico conservato fuori dai percorsi operativi correnti.

## Regola di affidabilita'

- I path sotto `docs/` citati dalla documentazione attiva devono esistere.
- Le fonti storiche assorbite nei canon sono indicate come `legacy:<slug>`.
- `docs/archive/` e i marker `legacy:<slug>` non sono source operative.
- La verifica e' `python scripts/ci/check_docs_active_refs.py`.
