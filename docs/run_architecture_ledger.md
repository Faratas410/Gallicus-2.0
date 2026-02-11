# Run Architecture Ledger

**Status:** canonical guardrails for the modular run flow.

## Core authority

- `RunManager` (`res://scripts/systems/run_manager.gd`) is the **only** flow authority.
- `RunManager` is the only runtime owner allowed to:
  - advance phases,
  - apply outcomes to `RunState`,
  - emit global outcome events through `GameEvents`.
- No parallel flow controller is allowed.

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
