# Support Documentation Index

Documentazione operativa non canonica da usare come supporto ai file owner canonici.

## Primary support docs
- `docs/support/repo_map.md` - inventory/ownership map allineata alla struttura reale.
- `docs/contracts/gameevents_signal_contract_v1.md` - contratto tecnico usato dalla validazione CI.
- `docs/contracts/ui_art_direction_contract_v1.md` - contratto artistico di supporto per l'overhaul UI.
- `docs/support/ui/ui_overhaul_production_pipeline.md` - pipeline operativa per brief, asset, wiring e verifica UI.
- `docs/support/ui/run_ui_phase_paths.md` - riferimento statico a phase-path e node-name UI.

## Active source rule
- Active documentation may reference only existing paths under `docs/`.
- Retired merged sources are represented as `legacy:<slug>` markers.
- `legacy:<slug>` markers are lineage notes only; they are not operational source files.
- Guard: `python scripts/ci/check_docs_active_refs.py`.

## Historical surfaces
- `docs/reports/INDEX.md` - indice della superficie report corrente.
- `docs/archive/INDEX.md` - indice del materiale storico archiviato.
- `legacy:risk_driven_design_bible` - lineage storica archiviata, non fonte operativa.
