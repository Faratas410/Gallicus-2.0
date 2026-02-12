# Run Architecture Ledger

**Status:** CANON  
**Scope:** Authoritative run architecture ownership ledger and extension rules.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/flow_wiring_contract.md, docs/FLOW_OFFICIAL_EA.md.

## Overlap
- Overlaps with: docs/flow_wiring_contract.md, docs/FLOW_OFFICIAL_EA.md.

## Core authority

- `RunManager` (`res://scripts/systems/run_manager.gd`) is the **only** flow authority.
- `RunManager` is the only runtime owner allowed to:
  - advance phases,
  - apply outcomes to `RunState`,
  - emit global outcome events through `GameEvents`.
- No parallel flow controller is allowed.

## RunManager Responsibilities (Current Canon)

`RunManager` currently owns and coordinates the following runtime responsibilities:

### Owns

- Phase state machine ownership (`RunPhase`) and progression authority.
- Request handling via `GameEvents` request signals.
- `RunState` mutation as the single source of gameplay state changes.
- Phase transitions exclusively via `_set_phase(...)`.
- UI trigger authority (`emit payload` / `show_phase`), while keeping UI reactive.
- Watchdog activity tracking and stall monitoring hooks.
- Session/run correlation id lifecycle used by `FlowLogger` traces.

### Does NOT Own

- Rendering and visual composition.
- Direct UI node mutation as gameplay authority.
- Economy legacy systems (`coins`/`tokens`): partially purged, no new authority expansion.
- Logging internals: delegated to `FlowLogger`.

## Flow Observability Stack

### FlowLogger

- `RefCounted` helper dedicated to run-flow observability.
- Multi-level logging support for flow diagnostics.
- In-memory ring buffer tail (bounded size) for recent events.
- Structured logging entry points:
  - `log_phase(...)`
  - `log_request(...)`
  - `log_ui(...)`
- `dump_last(...)` support for targeted tail inspection.

### Watchdog

- Tracks activity markers generated during flow progression.
- Single-shot stall detection for dead-flow diagnosis.
- Snapshot capture via `_flow_snapshot()`.
- No automatic gameplay state mutation when watchdog signals are emitted.

### Debug Overlay

- Toggle path: `F3`.
- Read-only inspection of:
  - current phase,
  - last request,
  - last UI render,
  - flow tail.
- Diagnostic-only surface: no authority and no flow mutation rights.

## Phase Contract

The phase contract is explicit and mandatory:

- `_set_phase()` is the **only** method allowed to mutate `RunPhase`.
- Every `_enter_*()` must trigger exactly one UI render.
- Every request handler must, in order:
  1. guard current phase validity,
  2. mutate `RunState`,
  3. call `_set_phase(next)`.

## Module boundaries

- `res://scripts/systems/run/*` = pure-ish run systems.
  - Operate on passed state/data.
  - No `get_tree()` traversal.
  - No direct `GameEvents` emission.
- `res://scripts/content/*` = catalogs / lookup content.
  - Data lookup only.
  - No flow decisions.
- `res://scripts/ui/run_ui_payload.gd` = UI projection contract.
  - `RunManager` builds payloads.
  - UI consumes payloads reactively.
- `SaveSystem` (`res://scripts/systems/run/save_system.gd`)
  - serializes/deserializes `RunState` only.
  - no phase orchestration and no UI authority.

## Event rules (GameEvents)

- `request_*` events are **inputs** (intent from UI/external triggers).
- Outcome/global events are emitted only by `RunManager` after state transitions.
- Systems do not publish global events directly.

## Dependency direction (allowed)

- `RunManager` → `RunState`
- `RunManager` → `scripts/systems/run/*`
- `RunManager` → `scripts/content/*`
- `RunManager` → `RunUiPayload` → UI render scripts
- `RunManager` ↔ `GameEvents` (request in, outcome out)
- `RunManager` → `SaveSystem` (`RunState` persistence)

Forbidden direction examples:

- UI → phase mutation
- systems/run/* → `GameEvents.emit_*`
- systems/run/* → scene-tree authority (`get_tree`) for flow control
- catalogs → gameplay mutation

## Where to add things

- **New gameplay rule:** add/update a run system under `scripts/systems/run/*`, then integrate in `RunManager`.
- **New content (bets/scars/outcomes data):** add/update catalogs under `scripts/content/*`.
- **New UI presentation:** extend `RunUiPayload` and update UI render scripts; keep decisions in `RunManager`.

## Recipe: add a new phase

1. Add enum value in `RunPhase`.
2. Implement matching `_enter_*` in `RunManager`.
3. Build/update `RunUiPayload` for that phase.
4. Add UI render handling for the new payload/phase.
5. Add `request_*` handler(s) in `RunManager`.
6. Hook outcome + catalog usage if the phase needs new data/effects.
