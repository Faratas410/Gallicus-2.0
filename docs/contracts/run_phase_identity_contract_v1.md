# RunPhase Identity Contract v1

Status: Active  
Scope: Single source of truth for RunPhase ids/names and consumer ownership boundaries.

## Authoritative Source

`res://scripts/contracts/run_phase_contract.gd` is the only authoritative source of RunPhase identity.

Authoritative in this contract means:

- Numeric phase ids
- Canonical phase names (`NAME_BY_ID`)
- Canonical live set (`CANONICAL_LIVE_PHASE_IDS`)
- Canonical phase-name rendering via `RunPhaseContract.get_phase_name(...)`

No other runtime, UI, tool, or test file may redefine numeric ids for RunPhase.

## Canonical Identity Set

- `MAIN_MENU = 10`
- `RUN_INIT = 11`
- `BET_PRESENT = 12`
- `BET_COMMITTED = 13`
- `POST_BET_MESSAGES = 14` (legacy reserved slot; non-mainline)
- `INTERMEDIATE_CHOICE = 15`
- `PUSH_YOUR_LUCK = 16`
- `NEXT_BET = 17`
- `RESOLUTION = 18` (compatibility residue only; non-authoritative in live runtime)

Runtime gate/internal ids also remain in contract:

- `NONE = -1`
- `PREP = 0`
- `LIVE = 1`
- `GAME_OVER = 2`

## Consumer Rules

- `RunManager` may keep a local typed `enum RunPhase` mirror only as a consumer surface.
  - Every enum value must reference `RunPhaseContractScript.<NAME>`.
  - Hardcoded numeric ids inside `RunManager` enum are forbidden.
- Runtime/UI/tools diagnostics must render phase names via `RunPhaseContract.get_phase_name(...)`.
- Consumer-local phase-name maps or ad-hoc phase stringification are forbidden.
- UI must consume `RunPhaseContract` (or `RunPhaseContractScript`) constants directly.
- UI runtime lifecycle wiring must keep one primary handler per lifecycle signal (`run_started`, `run_failed`) in `ui_root.gd`; duplicate auxiliary handlers for the same signal are forbidden.
- UI payload application must dispatch directly through `apply_run_ui_payload(...)`; wrapper aliases around this entrypoint are forbidden.
- Standard `GameEvents` wiring in `ui_root.gd` must use declarative specs (`_GAME_EVENT_WIRING_REQUIRED`, `_GAME_EVENT_WIRING_GUARDED`) plus one guarded helper (`_connect_game_event_signal(...)`).
- Repetitive per-signal inline connect branches in `_ready()` are non-authoritative for standard runtime->UI event wiring.
- UI outbound intent emission (`request_*`) must route through `_emit_game_event_signal_if_available(...)`; ad-hoc per-call `has_signal("request_*")` + direct `GameEvents.request_*.emit(...)` branches are forbidden.
- UI modal telemetry emission (`modal_opened` / `modal_closed`) must route through `_emit_modal_telemetry(...)`.
- Local UI phase alias constants such as `RUN_PHASE_*` are forbidden by default.
  - Exception: a compatibility-only alias may exist only when explicitly marked inline with `COMPAT_ONLY_PHASE_ALIAS`.
- Tools and CI checks must read `run_phase_contract.gd` for phase identity.

## Compatibility Boundary

- `RESOLUTION` remains as compatibility residue id only.
- Live runtime flow must not require entering `RESOLUTION`.
- Any legacy `RESOLUTION` value must be normalized at load/continue boundary before active runtime flow proceeds.
- `POST_BET_MESSAGES` remains compatibility residue only and must not be wired into live UI phase maps, live request/guard/routing surfaces, or active phase-driven consumer behavior.
- Any legacy `POST_BET_MESSAGES` phase occurrence at continue/load boundary must be normalized immediately to canonical live resume semantics (`INTERMEDIATE_CHOICE`) before runtime resume dispatch.

## Invalid Ownership Patterns (Forbidden)

- Duplicate phase-id definitions in RunManager/UI/tests/tools.
- Duplicate phase-name lookup maps outside `RunPhaseContract` (for example local `NAME_BY_ID` tables).
- Numeric switch/match guards that assume phase ids from local literals.
- UI-local `RUN_PHASE_*` alias layers without explicit compatibility-only justification.
- Parallel UI lifecycle handlers that split one runtime signal into overlapping local-authority branches.
- Wrapper alias helpers that create duplicate payload-apply entrypoints in UI consumers.
- Ad-hoc duplicated `GameEvents` connect blocks for standard runtime->UI signals outside the declarative wiring specs.
- Direct scattered `request_*`/`modal_*` UI emission branches that bypass canonical UI emission helpers.
- Contract drift where names/ids disagree between consumers and `RunPhaseContract`.
