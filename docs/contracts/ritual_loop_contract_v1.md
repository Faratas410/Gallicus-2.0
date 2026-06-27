# Ritual Loop Contract v1

Status: Active
Scope: Canonical Gallicus ritual-loop baseline based on stabilized runtime/UI flow.

## Loop Scope

This is the smallest coherent run loop that must remain understandable, testable, and repeatable throughout development toward Gallicus 1.0:

1. Start run from main menu.
2. Reach BET_PRESENT and select/sign one bet.
3. Pass through pact ritual open/close.
4. Make one intermediate choice (placa/provoca).
5. Pass through resolve ritual open/close.
6. Reach PUSH_YOUR_LUCK and make a decision.
7. Reach deterministic GAME_OVER/finale output with explicit end markers.

This contract protects the existing loop. It does not define the complete 1.0 campaign.

## Loop Gate

The baseline is healthy when all of the following are true:

- Runtime smoke BET_PRESENT scenario passes headlessly on canonical CI/Linux surface.
- Runtime smoke FULL_RUN scenario passes headlessly on canonical CI/Linux surface and includes:
  - `BET_PRESENT`
  - `PACT_SEALED_OPENED/CLOSED`
  - `INTERMEDIATE_CHOICE`
  - `RESOLVE_OPENED/CLOSED`
  - `PUSH_YOUR_LUCK`
  - `END_RUN` and `END_RUN_FINAL`
- Canonical request/flow signals for the loop remain present in `GameEvents`.
- RunManager remains sole authority for request handling and phase progression.
- Local Windows headless smoke runs are diagnostic-only and non-signoff.

## Required Systems

- RunManager phase/request orchestration.
- GameEvents runtime bus with request + runtime signals.
- UI Root reactive consumption and request intent emission.
- Level-3 bet present -> ritual -> choice -> push-your-luck -> end-run path.
- Headless smoke runtime validator (`scripts/ci/run_headless_smoke.py`).
- CI smoke workflow (`.github/workflows/godot_smoke_runtime.yml`).

## Outside This Baseline

- New content, new mechanics, or progression layers.
- UX polish and visual tuning not required for loop readability.
- Balance tuning beyond what is needed for deterministic completion.
- Broad UI rewrite or additional architecture refactor.

## Allowed Compatibility Residue

The following residue is acceptable while it remains explicit and tested:

- Compatibility phase/container naming tombstones (e.g. legacy container names).
- Contract-level compatibility ids normalized at load/continue boundary.
- Consumer mirrors explicitly documented as non-authoritative.

## Regression Guard Rule

Any change that removes the minimum loop smoke milestones or request-signal surfaces is a ritual-loop regression and must fail CI/static guards.
