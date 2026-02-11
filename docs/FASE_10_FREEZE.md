# FASE 10 — FREEZE

**Status:** SUPPORTING  
**Scope:** Operational freeze policy for patch scope and stop conditions.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/00_RISK_DRIVEN_DESIGN_BIBLE  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/CODEX_GOLDEN_CHECKLIST.md.
- Candidate for archive after consolidation patch if freeze policy is merged into canon operations docs.

## Overlap
- Overlaps with: docs/CODEX_GOLDEN_CHECKLIST.md.
- Candidate for archive after consolidation patch if freeze policy is merged into canon operations docs.

## TASK 10.1 — Freeze di design

### Scopo
- Gallicus 1.0 è in stato **chiuso**.

### Regola operativa
- **Non aggiungere feature**.
- Applicare **solo bugfix compatibili** con l'architettura attuale.
- Segnalare esplicitamente ogni tentazione di "migliorare" oltre il fix richiesto.

### Vincoli in vigore durante il freeze
- Valgono integralmente i vincoli di `docs/CODEX_GOLDEN_CHECKLIST.md`.
- Valgono integralmente gli intenti di `docs/00_RISK_DRIVEN_DESIGN_BIBLE`.
- Una task = una patch minimale, localizzata, reversibile.

### Criterio di stop
Se la correzione richiede refactor, tocca più sistemi o implica redesign: **STOP e report**, senza applicare cambiamenti strutturali.
