# Support Documentation Index

Documentazione operativa non canonica da usare come supporto ai file owner canonici.

## Primary support docs
- `docs/README.md` - operating-system entrypoint and reading order.
- `docs/development_plan.md` - current roadmap and next operational step.
- `docs/testing.md` - static, CI, Godot and manual QA gates.
- `docs/code_quality.md` - code ownership and patch discipline.
- `docs/support/repo_map.md` - inventory/ownership map allineata alla struttura reale.
- `docs/contracts/gameevents_signal_contract_v1.md` - contratto tecnico usato dalla validazione CI.
- `docs/contracts/ui_art_direction_contract_v1.md` - contratto artistico di supporto per l'overhaul UI.
- `docs/support/ui/ui_overhaul_production_pipeline.md` - pipeline operativa per brief, asset, wiring e verifica UI.
- `docs/support/ui/run_ui_phase_paths.md` - riferimento statico a phase-path e node-name UI.

## Domain operating docs
- `docs/design_skeleton.md` - progetto corrente, loop e limiti.
- `docs/game_design.md` - gameplay loop e sistemi attivi.
- `docs/content_bible.md` - tono, grammatica e copy runtime.
- `docs/data_schema.md` - cataloghi e payload dati.
- `docs/layout_rules.md` - regole UI e screenshot QA.
- `docs/asset_pipeline.md` - asset runtime, naming e verifica.
- `docs/art_direction.md` - mood, palette e divieti visuali.
- `docs/ethics_and_representation.md` - rischi di tono, temi e rappresentazione.
- `docs/release_checklist.md` - criteri beta/release.
- `docs/playtest_guide.md` - guida tester.
- `docs/playtest_feedback_log.md` - feedback normalizzato.

## Active source rule
- Active documentation may reference only existing paths under `docs/`.
- Retired merged sources are represented as `legacy:<slug>` markers.
- `legacy:<slug>` markers are lineage notes only; they are not operational source files.
- Guard: `python scripts/ci/check_docs_active_refs.py`.

## Historical surfaces
- `docs/reports/INDEX.md` - indice della superficie report corrente.
- `docs/archive/INDEX.md` - indice del materiale storico archiviato.
- `legacy:risk_driven_design_bible` - lineage storica archiviata, non fonte operativa.
