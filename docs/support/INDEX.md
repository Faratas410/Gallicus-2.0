# Support Documentation Index

Questa cartella contiene inventari e procedure subordinate agli owner
operativi e canonici.

## Entry operative

- `docs/README.md` - documentation OS.
- `docs/development_plan.md` - roadmap 1.0.
- `docs/testing.md` - gate statici, runtime e manuali.
- `docs/code_quality.md` - ownership e patch discipline.
- `docs/support/repo_map.md` - inventario del repository.

## Contratti

- `docs/contracts/gameevents_signal_contract_v1.md`
- `docs/contracts/run_phase_identity_contract_v1.md`
- `docs/contracts/run_save_flow_step_contract_v1.md`
- `docs/contracts/ritual_loop_contract_v1.md`
- `docs/contracts/ui_art_direction_contract_v1.md`

## UI e asset

- `docs/support/ui/object_first_ui_pipeline.md` - produzione UI da intento a verifica.
- `docs/support/ui/object_asset_brief.md` - famiglie oggetto e gap asset.
- `docs/support/ui/run_ui_phase_paths.md` - riferimento tecnico a path e nodi.

## Regola

- Il supporto non ridefinisce gameplay o canon.
- I path citati devono esistere.
- Materiale ritirato non resta come guida attiva.
- Verifica: `python scripts/ci/check_docs_active_refs.py`.

## Storico

La sola lineage conservata vive in `docs/archive/`. Non e' una fonte operativa.
