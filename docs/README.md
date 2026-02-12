# Docs Map

**Status:** CANON  
**Scope:** Master index for all flat `docs/` files, statuses, and ownership boundaries.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/run_architecture_ledger.md, docs/repo_map.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: all documentation domains by definition.

## Overlap
- Overlaps with: all documentation domains by definition.

This index defines the explicit status of documents in `docs/` and the current ownership boundaries for canon alignment.

## Status Legend
- **CANON**: source-level authority, must be kept current.
- **SUPPORTING**: aligned references, may summarize canon.
- **DRAFT**: work-in-progress narrative/design material.
- **REPORT**: historical snapshot; not canon.
- **ARCHIVE-CANDIDATE**: kept for traceability, eligible for later archive after consolidation.

## Foundation / Rules
- `00_RISK_DRIVEN_DESIGN_BIBLE` — Constitutional design doctrine focused on risk and irreversible choice. **[SUPPORTING]** Owner: Design doctrine authority
- `CODEX_GOLDEN_CHECKLIST.md` — Non-negotiable technical and architecture invariants for safe patches. **[CANON]** Owner: Codex safety invariants authority
- `FASE_10_FREEZE.md` — See file header for scope. **[SUPPORTING]** Owner: Patch discipline authority
- `repo_map.md` — Canonical map of repository structure and runtime ownership boundaries. **[CANON]** Owner: Repository map authority

## Runtime Architecture
- `run_architecture_ledger.md` — Canonical ownership of run flow, systems, and extension rules. **[CANON]** Owner: RunManager authority
- `Flow Observability Stack` — Operational layer composed of `FlowLogger`, `Watchdog`, and RunManager flow snapshots. **[CANON via run_architecture_ledger.md]** Owner: RunManager observability authority
- `Debug Overlay` — Read-only F3 diagnostics surface for phase/request/UI tail inspection. **[CANON via run_architecture_ledger.md]** Owner: RunManager debug authority
- `Watchdog` — Stall-detection and activity-tracking diagnostics with no gameplay authority. **[CANON via run_architecture_ledger.md]** Owner: RunManager diagnostics authority
- `flow_wiring_contract.md` — Canonical runtime flow wiring contract and event boundaries. **[CANON]** Owner: Flow wiring contract authority
- `FLOW_OFFICIAL_EA.md` — See file header for scope. **[SUPPORTING]** Owner: Flow narrative reference authority
- `runtime_architecture_split.md` — See file header for scope. **[SUPPORTING]** Owner: Runtime split reference owner
- `game_flow_v2.md` — See file header for scope. **[SUPPORTING]** Owner: Flow v2 supporting owner
- `game_flow.md` — See file header for scope. **[ARCHIVE-CANDIDATE]** Owner: Legacy flow snapshot owner
- `technical_resume_level3_canonical_it.md` — See file header for scope. **[SUPPORTING]** Owner: Technical summary owner
- `technical_review_resume_it.md` — See file header for scope. **[SUPPORTING]** Owner: Technical review owner

## Game Design
- `bet_progression.md` — See file header for scope. **[SUPPORTING]** Owner: Bet philosophy authority
- `scar_system.md` — See file header for scope. **[SUPPORTING]** Owner: Scar system design owner
- `meta_progression.md` — See file header for scope. **[SUPPORTING]** Owner: Meta progression rules owner

## Lore / Narrative
- `the_register.md` — See file header for scope. **[SUPPORTING]** Owner: Registro doctrine owner
- `final_narrative_structure.md` — See file header for scope. **[SUPPORTING]** Owner: Narrative structure authority
- `felix_gallicus.md` — See file header for scope. **[DRAFT]** Owner: Narrative draft owner
- `registry_corruption.md` — See file header for scope. **[DRAFT]** Owner: Narrative draft owner
- `registry_silence.md` — See file header for scope. **[DRAFT]** Owner: Narrative draft owner

## UI / Audio
- `ui_official_ledger.md` — Canonical UI asset/theme ledger and replacement policy. **[CANON]** Owner: UI ledger authority
- `ui_audio_map.md` — See file header for scope. **[SUPPORTING]** Owner: UI audio mapping owner
- `audio_paths.md` — See file header for scope. **[SUPPORTING]** Owner: Audio path policy authority

## Reports / Temporary
- `reports/run_manager_function_inventory.md` — RunManager function inventory and refactor snapshot. **[REPORT]** Owner: Runtime audit owner
- `level3_integrity_audit_report.md` — See file header for scope. **[REPORT]** Owner: Historical integrity audit owner
- `level3_open_questions_log.md` — See file header for scope. **[REPORT]** Owner: Historical open-questions owner
- `codex_report_1_0_gap.md` — See file header for scope. **[REPORT]** Owner: Historical gap snapshot owner

## Canonical Docs

- [LORE_UNIFIED](docs/canon/LORE_UNIFIED.md)
- [GLOSSARY_ENTITIES](docs/canon/GLOSSARY_ENTITIES.md)
- [MECHANICS_UNIFIED](docs/canon/MECHANICS_UNIFIED.md)
- [RUN_ARCHITECTURE_CANON](docs/canon/RUN_ARCHITECTURE_CANON.md)
- [UI_CANON](docs/canon/UI_CANON.md)
- [PROCESS_AND_FREEZE](docs/canon/PROCESS_AND_FREEZE.md)
- [Reports index](docs/reports/INDEX.md)
