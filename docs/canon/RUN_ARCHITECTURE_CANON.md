# CANON — RUN ARCHITECTURE CANON

Status: Single source of truth

If another doc conflicts, this doc wins.

Last merged from: docs/run_architecture_ledger.md, docs/runtime_architecture_split.md, docs/flow_wiring_contract.md, docs/run_ui_phase_paths_and_names.md

## Canon Contract

This document is authoritative for its category.
No other file may redefine these concepts.
All changes to systems described here must update this document in the same PR.


## Index

- [Core authority](#core-authority)
- [Phase contract](#phase-contract)
- [Event rules (GameEvents)](#event-rules-gameevents)
- [GameEvents signals](#gameevents-signals-required-for-level-3-flow)
- [Runtime L3 (active path)](#runtime-l3-active-path)

## SOURCE: docs/run_architecture_ledger.md

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
- Economy/progression legacy systems (`coins`/`tokens`/`xp`/`level`): partially purged; intro token-shop request/cost API and progression event-bus signal wiring are removed from active Level 3 flow and must not be reintroduced as RunManager authority.
- Run save payload for active Level 3 excludes legacy progression/shop keys (`level`, `xp`, `difficulty_tier`, `upgrade_tokens`, `upgrade_costs`) and keeps only runtime-required fields (`arena_index`, `coins`, `corruption`, `upgrades`).
- In active Level 3, `run.corruption` is an integer runtime field with hard cap `100`; it initializes at `0` on new run and is clamped on load.
- In active Level 3, `RunState` also serializes passive Scar runtime fields: `scar_double_count`, `scar_pact_count`, `volatility`, `scar_rng_state`, `scar_roll_index`, `last_pact_corruption_arena_index`, `last_pact_corruption_bet_id` (save/load deterministic Scar RNG continuity + idempotent pact corruption ingestion guard).
- In active Level 3, `run.upgrades` is sanitized to an empty schema (`{}`) on init/load/save; legacy stat keys are ignored.
- In active Level 3, combat authority is disabled (`Player`/enemy damage-death runtime is inert) and run termination must not originate from player-death signals.
- In active Level 3, enemy instantiation runtime is removed from `Arena`; `Player` is a visual-only `Node2D` (no CharacterBody2D physics authority), and player/enemy collision-combat runtime is not authoritative.
- In active Level 3, no combat/health/enemy gameplay authority is active; groups and scene nodes remain visual/passive runtime surfaces only.
- In active Level 3, enemy combat HUD assets/wiring (enemy health bars) are removed from active UI runtime path.
- In active Level 3, outcome payload semantics are ritual-only: legacy combat keys are deprecated, and UI bindings must target ritual keys only (no exposed enemy/damage/HP semantics).
- In active Level 3, `resolve_level3_arena` payload no longer emits legacy aliases (`enemy_profile`, `damage_mod`, `damage_chance`, `took_damage`); runtime flow consumes canonical ritual keys (`risk_profile`, `pressure_mod`, `failure_chance`, `condemnation_flag`, `outcome_tier`, `outcome_reason`) plus flow keys (`won`, `notes`).
- In active Level 3, RunManager flow consumes `condemnation_flag` as authoritative adverse/condanna signal; legacy `took_damage` alias is non-authoritative and must not drive flow branches.
- In active Level 3 loss ingestion, RunManager consumes canonical consequence keys `corruption_gain` and `end_reason`; legacy `hp_loss`/`provoke_failed`/`double_or_die_failed` are removed from active Level 3 consequence contract.
- In active Level 3 run save payload, `run.level3_schema = 2` marks the hard-sealed canonical loss contract boundary.
- Continue-load is strict-sealed: payloads missing `run.level3_schema` or with `run.level3_schema != 2` are rejected without migration, run save is cleared, and flow returns to `MAIN_MENU` via RunManager phase setter.
- Serialized `run_state.scars` must be canonical `Array[Dictionary]`; legacy scalar scar forms are rejected and trigger the same clear-to-menu gate.
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

### SmokeDriver

- `RefCounted` helper at `res://scripts/systems/run/smoke_driver.gd` dedicated to smoke scenario decisions/flags.
- Consumes environment inputs and phase snapshots only.
- Must not call `get_tree()` and must not emit `GameEvents`.
- `RunManager` remains the sole smoke flow authority for timer node ownership, quit gate, and event emission.

### Watchdog

- `RefCounted` helper at `res://scripts/systems/run/flow_watchdog.gd` encapsulates watchdog diagnostics logic (stall hint + snapshot string composition).
- `RunManager` remains the sole authority for timing source (`Time.get_ticks_msec()`), phase gating, and watchdog enable/disable lifecycle.
- Tracks activity markers generated during flow progression.
- Single-shot stall detection for dead-flow diagnosis.
- Snapshot capture via `_flow_snapshot()`.
- No automatic gameplay state mutation when watchdog signals are emitted.

### FlowDiagnostics

- `RefCounted` helper at `res://scripts/systems/run/flow_diagnostics.gd` encapsulates diagnostics formatting/composition (debug payload dictionary and error/log string composition).
- Helper is pure formatting: no phase mutation, no `GameEvents` emission, no scene-tree access.
- `RunManager` keeps overlay wiring and emission authority (`run_debug_state_updated`).

### FinaleBuilder

- `RefCounted` helper at `res://scripts/systems/run/finale_builder.gd` encapsulates finale payload construction/report text composition from read-only inputs.
- `RunManager` remains the sole authority for finale timing, ending selection, phase/end-flow decisions, and `GameEvents.run_finale_selected` emission.
- Helper must remain pure: no `GameEvents` emission, no scene-tree access, no `RunState` mutation.

### BettingPolicy

- `RefCounted` helper at `res://scripts/systems/run/betting_policy.gd` encapsulates deterministic betting contract computations.
- Scope includes weighted offer selection, registry-precedent weight policy, and audience/cashout reward text dictionary building used by push-luck payload assembly.
- `RunManager` remains sole authority for: phase transitions (`_set_phase(...)`), deciding when bet UI opens/commits, all `GameEvents` emissions, and all `RunState` mutation application.
- Helper invariants: no `GameEvents` emission, no scene-tree access, no direct `RunState` mutation.

### BettingPayloadFactory

- `RefCounted` helper at `res://scripts/systems/run/betting_payload_factory.gd` encapsulates deterministic UI payload dictionary assembly for bet offer and push-your-luck payloads.
- Accepts only explicit primitive/dictionary inputs and returns dictionaries with no side effects.
- `RunManager` remains sole authority for payload emission timing, phase gating, `GameEvents` emission, and `RunState` mutation.
- Helper invariants: no `GameEvents` emission, no `_set_phase(...)`, no scene-tree access.
- Payload stability rule: helper output schema is fixed and keys are always emitted with explicit defaults (no optional/missing output keys for declared payload contracts).

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
- Legacy `set_phase(...)` wrapper is non-authoritative and fail-fast: it logs + errors and must never mutate `RunPhase`.
- Boot must enter `MAIN_MENU` via `_set_phase(...)` before any `request_new_run` handling.
- Any gameplay enable/disable gate phase must be stored in a separate non-authoritative runtime variable and must not mutate `RunPhase` directly.
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
  - serializes/deserializes `RunState` and performs low-level persistence read/write.
  - no phase orchestration, no `GameEvents` emission, and no UI authority.
- `SaveContinueBoundary` (`res://scripts/systems/run/save_continue_boundary.gd`)
  - builds Level 3 save payloads, validates continue payload seal/boundary, and applies pure payload-to-state mapping before RunManager orchestration/routing.
  - no phase orchestration, no scene-tree access, and no `GameEvents` emission.

## Event rules (GameEvents)

- `request_*` events are **inputs** (intent from UI/external triggers).
- Outcome/global events are emitted only by `RunManager` after state transitions.
- Systems do not publish global events directly.
- `INFRA_FAILURE` is treated as infrastructure termination: emit `run_ended` but do not emit `run_failed`.

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

## SOURCE: docs/runtime_architecture_split.md

# Runtime Architecture Split (Phase 3)

**Status:** SUPPORTING  
**Scope:** High-level split between canonical runtime and legacy/non-runtime code surfaces.  
**Source of truth:** docs/run_architecture_ledger.md, docs/repo_map.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/repo_map.md, docs/technical_resume_level3_canonical_it.md.

## Overlap
- Overlaps with: docs/repo_map.md, docs/technical_resume_level3_canonical_it.md.

## Runtime L3 (active path)

Runtime L3 includes the active boot and orchestration path used by the game flow:

- `res://scenes/Main.tscn`
- `res://scripts/systems/run_manager.gd` (single RunManager)
- `res://scripts/systems/game_events.gd` (Autoload event bus)
- Active UI scenes/scripts under `res://scenes/ui/` and `res://scripts/ui/`
- L3 visual core kept in active path:
  - `res://scripts/Arena.gd`
  - `res://scripts/Player.gd`

## Legacy runtime (non-L3)

Legacy gameplay systems are confined under `res://legacy_runtime/`:

- Gameplay scripts:
  - `res://legacy_runtime/gameplay/player_legacy.gd`
  - `res://legacy_runtime/gameplay/enemy_legacy.gd`
- Legacy scene:
  - `res://legacy_runtime/scenes/Enemy.tscn`
- Legacy pickups:
  - `res://legacy_runtime/pickups/Pickup.gd`
  - `res://legacy_runtime/pickups/PickupSpawner.gd`
  - `res://legacy_runtime/pickups/Pickup_Heal.tscn`
  - `res://legacy_runtime/pickups/Pickup_Coins.tscn`
  - `res://legacy_runtime/pickups/Pickup_SpeedBoost.tscn`

## Rule

No file under `res://legacy_runtime/` may be referenced by:

- `res://scenes/Main.tscn`
- `res://scripts/systems/run_manager.gd`

This keeps Level 3 runtime active and boot-safe while preserving legacy gameplay assets in an isolated namespace.

## SOURCE: docs/flow_wiring_contract.md

# Flow Wiring Contract (Level 3)

**Status:** CANON  
**Scope:** Official runtime wiring contract for flow events, ownership boundaries, and phase transitions.  
**Source of truth:** docs/run_architecture_ledger.md, docs/CODEX_GOLDEN_CHECKLIST.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/FLOW_OFFICIAL_EA.md, docs/game_flow_v2.md.

## Overlap
- Overlaps with: docs/FLOW_OFFICIAL_EA.md, docs/game_flow_v2.md.

This document is a repo-only wiring contract for debugging the Level 3 flow without Godot.
It records the expected UI paths, required GameEvents signals, and connection points that
RunManager depends on.

## UI Root

* **Expected path:** `UI` under the current scene (`res://scenes/Main.tscn`).
* **Fallback path:** `/root/Main/UI`.
* **Resolution in RunManager:** `_refresh_sanity_ui_root()` stores the resolved node in `_sanity_ui_root`.

## Critical UI Panels (Level 3 flow)

These panels must exist and must not be freed while a run is active.

| Panel | Expected path | Scene | Notes |
| --- | --- | --- | --- |
| Bet UI panel | `Modals/BetModal` | `res://scenes/UI.tscn` | **must exist** / **must not be freed** |
| Pact sealed panel | `Modals/PactSealedModal` | `res://scenes/UI.tscn` | **must exist** / **must not be freed** |
| Resolve ritual panel | `Modals/ResolveRitualModal` | `res://scenes/UI.tscn` | **must exist** / **must not be freed** |
| Ending panel | `Modals/GameOverModal` | `res://scenes/UI.tscn` | **must exist** / **must not be freed** |

## GameEvents Signals (required for Level 3 flow)

> If a signal’s emitter/listener cannot be proven from code, it is marked as:
> **UNKNOWN (needs editor validation)**.

| Signal | Emitted by | Listened by | Connection (file/func) |
| --- | --- | --- | --- |
| `request_new_run` | MainMenu UI | RunManager | `scripts/ui/main_menu.gd::_on_new_game_pressed` → `scripts/systems/run_manager.gd::_ready` |
| `request_continue_run` | MainMenu UI | RunManager | `scripts/ui/main_menu.gd::_on_continue_pressed` → `scripts/systems/run_manager.gd::_ready` |
| `request_place_bet` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_intro_bet_selected` → `scripts/systems/run_manager.gd::_ready` |
| `bet_ui_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_open_level3_bet_ui` → `scripts/ui/ui_root.gd::_ready` |
| `bet_placed` | RunManager | UI Root, RunManager | `scripts/systems/run_manager.gd::select_bet` → `scripts/ui/ui_root.gd::_ready`, `scripts/systems/run_manager.gd::_ready` |
| `pact_sealed_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_pact_sealed_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `pact_sealed_closed` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_pact_sealed_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `resolve_ritual_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_resolve_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `resolve_ritual_closed` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_resolve_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `arena_started` | RunManager | UI Root | `scripts/systems/run_manager.gd::_resolve_ritual_outcome` → `scripts/ui/ui_root.gd::_ready` |
| `arena_completed` | RunManager | UNKNOWN (needs editor validation) | `scripts/systems/run_manager.gd::_resolve_ritual_outcome` |
| `request_mid_choice_select` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_phase_mid_choice_select` → `scripts/systems/run_manager.gd::_ready` |
| `push_luck_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_open_push_luck_choice` → `scripts/ui/ui_root.gd::_ready` |
| `request_pyl_cashout` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_phase_push_luck_action` → `scripts/systems/run_manager.gd::_ready` |
| `request_pyl_double` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_phase_push_luck_action` → `scripts/systems/run_manager.gd::_ready` |
| `run_debug_state_updated` | RunManager | UI Root | `scripts/systems/run_manager.gd::_emit_run_debug_state` (includes `glory`, `scar_double_count`, `scar_pact_count`, `volatility`) → `scripts/ui/ui_root.gd::_on_run_debug_state_updated` |
| `run_finale_selected` | RunManager | UI Root | `scripts/systems/run_manager.gd::_emit_run_finale` → `scripts/ui/ui_root.gd::_ready` |
| `run_failed` | RunManager | UI Root, Arena | `scripts/systems/run_manager.gd::_emit_run_failed` (gameplay failure reasons only; excludes `INFRA_FAILURE`) → `scripts/ui/ui_root.gd::_ready`, `scripts/Arena.gd::_ready` |
| `request_show_main_menu` | UI Root | MainMenu UI, RunManager (log-only) | `scripts/ui/ui_root.gd::_on_quit_pressed` → `scripts/ui/main_menu.gd::_ready`, `scripts/systems/run_manager.gd::_ready` |

## SOURCE: docs/run_ui_phase_paths_and_names.md

# Run UI — Phase Paths and Node Names

This document lists the canonical run UI phase containers and their key node names after the phase-based rename.

Scene: `res://scenes/UI.tscn`

## UI root

- `UI_RunRoot`

## Phase containers

- `UI_RunRoot/Phase_INTRO`
- `UI_RunRoot/Phase_FIRST_REACTION`
- `UI_RunRoot/Phase_MID_CHOICE`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK`
- `UI_RunRoot/Phase_RESOLUTION`
- `UI_RunRoot/Phase_END_RUN`

## Key nodes by phase

### INTRO

- `UI_RunRoot/Phase_INTRO/Panel_INTRO`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_TITLE`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_SUBTITLE`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/Lbl_INTRO_HINT`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/SeedRow/Lbl_INTRO_BODY`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/StakeRow/Lbl_INTRO_BODY_STAKE`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Lbl_INTRO_FOOTER`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/SeedRow/Btn_INTRO_APPLY_SEED`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons/Btn_INTRO_SELECT_WIN`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons/Btn_INTRO_SELECT_NO_HIT`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetButtons/Btn_INTRO_SELECT_FAST`
- `UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BetConfirmRow/Btn_INTRO_CONFIRM`

### FIRST_REACTION

- `UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION`
- `UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_TITLE`
- `UI_RunRoot/Phase_FIRST_REACTION/Panel_FIRST_REACTION/Box_FIRST_REACTION/Lbl_FIRST_REACTION_BODY`

### MID_CHOICE

- `UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE`
- `UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Lbl_MID_CHOICE_TITLE`
- `UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0`
- `UI_RunRoot/Phase_MID_CHOICE/Panel_MID_CHOICE/Box_MID_CHOICE/Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_1`

### PUSH_YOUR_LUCK

- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_TITLE`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_BODY`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_SUBTITLE`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_HINT`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Lbl_PUSH_YOUR_LUCK_FOOTER`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Btn_PUSH_YOUR_LUCK_CASHOUT`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_0/Lbl_PUSH_YOUR_LUCK_CHOICE_0`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Btn_PUSH_YOUR_LUCK_CONDANNA`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_1/Lbl_PUSH_YOUR_LUCK_CHOICE_1`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Btn_PUSH_YOUR_LUCK_DOUBLE`
- `UI_RunRoot/Phase_PUSH_YOUR_LUCK/Panel_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK/Box_PUSH_YOUR_LUCK_CHOICES/Box_PUSH_YOUR_LUCK_CHOICE_2/Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICE`

### RESOLUTION

- `UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION`
- `UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_TITLE`
- `UI_RunRoot/Phase_RESOLUTION/Panel_RESOLUTION/Box_RESOLUTION/Lbl_RESOLUTION_BODY`

### END_RUN

- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_TITLE`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_SUBTITLE`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_BODY`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_HINT`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_PACTS_TITLE`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_PACTS_BODY`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_CONDANNE_TITLE`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Lbl_END_RUN_CONDANNE_BODY`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_TITLE`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS/Box_END_RUN_CROWD/Lbl_END_RUN_CROWD_BODY`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_SCROLL/Box_END_RUN_MARGIN/Lbl_END_RUN_FOOTER`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Btn_END_RUN_RESTART`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Btn_END_RUN_NEXT_BET`
- `UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Btn_END_RUN_QUIT`

## Script mapping references

- `scripts/ui/ui_root.gd`
  - onready path bindings for renamed nodes
  - phase map (`_phase_node_map`) and `show_phase(phase: int)`
- `scripts/systems/run_manager.gd`
  - sanity checks and `_ensure_flow_panel(...)` paths updated to `UI_RunRoot/Phase_*`
