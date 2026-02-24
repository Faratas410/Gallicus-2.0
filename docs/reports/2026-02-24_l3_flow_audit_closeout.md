# Gallicus — Level 3 Flow Audit Closeout

Date: 2026-02-24
Scope: Level 3 flow contract + UI boundary hardening (no redesign)
Authority: Report only (non-canonical). Canon sources remain in `docs/canon/*`.

## Context

This closeout captures the outcome of the L3 flow audit and the minimal hardening work performed to
prevent regressions around phase routing and UI overlays.

This report is **non-authoritative**. Source of truth remains:

- `docs/canon/PROCESS_AND_FREEZE.md`
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/UI_CANON.md`

## Canonical L3 Mainline (Target)

INTRO -> FIRST_REACTION -> MID_CHOICE -> PUSH_YOUR_LUCK -> END_RUN

Notes:
- The “resolution moment” between MID_CHOICE and PUSH_YOUR_LUCK is implemented as a **resolve-ritual overlay**
  (event-driven), not as a required mainline `RunPhase.RESOLUTION` step.
- FIRST_REACTION and the resolve ritual are treated as **event-queue overlays**, while other screens are
  **phase container** driven (`payload.phase` -> `show_phase`).

## Audit Findings (Risk List) and Outcomes

### P0 — Numeric alias drift in phase enter/dispatch

Risk:
Hardcoded numeric literals used for phase enter/dispatch can silently break when enum ordering changes.

Resolution:
Replaced numeric literal usage with the authoritative enum token (BET_PRESENT) in phase enter/dispatch logic.

Reference:
- Commit: `015f9be`

### P1 — Stale signal contract: duplicate mid-choice open path

Risk:
`intermediate_choice_opened` existed and UI subscribed, but the authoritative path already opened mid-choice via
payload emission. Emitting the signal would create a duplicate UI-open at the same transition point.

Resolution:
Removed the UIRoot subscription wiring to `intermediate_choice_opened`, leaving a single active mid-choice open
path (payload-driven).

Reference:
- Commit/PR: (fill once merged)

### R1-bis — UI numeric drift scan

Finding:
No numeric match/case phase routing or numeric phase literals were found in `scripts/ui/` for phase routing
(already hardened via contract-backed constants).

Resolution:
No code change required.

### R3 — Parallel UI gate paths (phase containers vs event-driven overlays)

Risk:
FIRST_REACTION and the resolve ritual are not phase-container driven; they are event/queue overlay driven.
This is a known desync risk during refactors if not documented and guarded.

Resolution:
1) Documented the split explicitly in `docs/canon/UI_CANON.md` (canon).
2) Added a static CI guard that asserts overlay wiring is present (no Godot required):
   - `resolve_ritual_opened` / `resolve_ritual_closed` exist in GameEvents
   - `ui_root` includes resolve ritual handlers/wiring
   - post-bet overlay path identifiers (`kind`/`title`/`subtitle`) remain present

Reference:
- Commit/PR: (fill once merged)

### R4 — RESOLUTION phase drift (alternate/non-mainline)

Finding:
`RunPhase.RESOLUTION` exists but the mainline uses resolve-ritual events; RESOLUTION may be reachable only via
alternate/legacy entrypoints.

Resolution:
Added canon clarification in `docs/canon/RUN_ARCHITECTURE_CANON.md` that RESOLUTION is non-mainline and must not
be used as an implicit gate for PUSH_YOUR_LUCK.

Reference:
- Commit/PR: (fill once merged)

## CI Guardrails Added

1) UI Phase Contract (Mid-choice) static test
- `scripts/ci/test_ui_phase_contract.py`
- Runs in smoke workflow (no Godot needed)
- Includes a VERSION skew guardrail to prevent “V2 label with V1 logic” regressions

2) UI Overlay Contract static test
- `scripts/ci/test_ui_overlay_contract.py`
- Runs in smoke workflow (no Godot needed)
- Guards resolve ritual overlay + post-bet overlay identifiers

## Manual Sanity Check (Recommended)

After merge, validate once in a real run:

1) Sigilla Patto -> MID_CHOICE appears (Phase_MID_CHOICE)
2) MID_CHOICE selection triggers resolve ritual overlay (open/close)
3) PUSH_YOUR_LUCK opens
4) END_RUN reachable via cashout/condanna path

## Residual Risks / Watchlist

- Any future attempt to “unify overlays into phase containers” must be a dedicated redesign task and must update canon.
- Any enum reordering must not reintroduce numeric literals in core phase dispatch or UI routing.
