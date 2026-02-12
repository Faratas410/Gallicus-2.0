# Flow Integrity Audit

## Invariants Checked

- **Single RunManager authority**: canon requires `RunManager` as the only flow authority and only owner of phase advancement + outcome/global emissions. (`docs/canon/RUN_ARCHITECTURE_CANON.md`)【file:docs/canon/RUN_ARCHITECTURE_CANON.md:39】【file:docs/canon/RUN_ARCHITECTURE_CANON.md:101】【file:docs/canon/RUN_ARCHITECTURE_CANON.md:127】
- **GameEvents-only cross-layer signaling**: canon requires `request_*` as inputs and cross-layer communication via `GameEvents`. (`docs/canon/MECHANICS_UNIFIED.md`, `docs/canon/RUN_ARCHITECTURE_CANON.md`)【file:docs/canon/MECHANICS_UNIFIED.md:554】【file:docs/canon/MECHANICS_UNIFIED.md:555】【file:docs/canon/RUN_ARCHITECTURE_CANON.md:124】
- **No parallel terminal/phase authority**: no parallel flow controller allowed by canon. (`docs/canon/RUN_ARCHITECTURE_CANON.md`)【file:docs/canon/RUN_ARCHITECTURE_CANON.md:44】
- **Runtime wiring assumptions** from repo map and project config: entry scene is `Main.tscn`, `GameEvents` autoloaded, `RunManager` in `run_manager` group. 【file:docs/repo_map.md:14】【file:docs/repo_map.md:15】【file:docs/repo_map.md:16】【file:project.godot:7】【file:project.godot:11】【file:scenes/Main.tscn:31】

## Findings Summary

- Parallel flow risks: **1**
- Duplicate authority risks: **0**
- Direct terminal emits outside RunManager: **0**
- Unhandled request_* or fallback terminal emits: **1**

### Summary notes

1. No non-RunManager script emits `GameEvents.run_failed` or `GameEvents.run_ended`; both are emitted only in `RunManager`.【file:scripts/systems/run_manager.gd:4413】【file:scripts/systems/run_manager.gd:4428】【file:scripts/systems/run_manager.gd:4432】
2. A **single architectural risk** exists: `RunManager` subscribes to `GameEvents.run_failed` while also emitting it. Guard logic currently prevents re-entry loops, but this remains a parallel-path smell for terminal flow handling.【file:scripts/systems/run_manager.gd:1229】【file:scripts/systems/run_manager.gd:3766】【file:scripts/systems/run_manager.gd:3773】【file:scripts/systems/run_manager.gd:4409】
3. A fallback terminal path exists in `_fail_flow(...)` that forces `_enter_end_run("RUN_FAILED")` on sanity violations (missing flow panels), i.e. terminalization from infrastructure failure rather than gameplay request. This is still inside RunManager authority but should be tracked as fallback terminal logic.【file:scripts/systems/run_manager.gd:1414】【file:scripts/systems/run_manager.gd:1424】【file:scripts/systems/run_manager.gd:1429】

## Event Map

### GameEvents.run_failed

- Emits:
  - [scripts/systems/run_manager.gd:4413](scripts/systems/run_manager.gd:4413) `_emit_run_failed` — emitted when game-over processing finalizes a loss path.
- Handlers:
  - [scripts/systems/run_manager.gd:3766](scripts/systems/run_manager.gd:3766) `_on_run_failed` — forwards to `_on_request_fail_run("RUN_FAILED")`.
  - [scripts/ui/ui_root.gd:1104](scripts/ui/ui_root.gd:1104) `_on_run_failed` — opens verdict/game-over modal.
  - [scripts/ui/ui_root.gd:1340](scripts/ui/ui_root.gd:1340) `_on_run_failed_controls` — applies control-state changes.
  - [scripts/Arena.gd:281](scripts/Arena.gd:281) `_on_run_failed` — disables arena processing.
- Assessment:
  - **Authority mostly OK**, because emit authority is RunManager-only.
  - **Risk**: RunManager self-subscribes to its own terminal event (`run_failed`) which is an avoidable parallel ingress to terminal logic; currently mitigated by `_is_game_over/_run_failed_emitted` and phase guard.【file:scripts/systems/run_manager.gd:1229】【file:scripts/systems/run_manager.gd:3771】【file:scripts/systems/run_manager.gd:3773】
  - Recommendation: remove RunManager subscription to `run_failed` and keep terminal ingress only through request handlers / internal methods.

### GameEvents.run_ended

- Emits:
  - [scripts/systems/run_manager.gd:4428](scripts/systems/run_manager.gd:4428) `_emit_run_ended` — emits reason with empty summary in registry-silence mode.
  - [scripts/systems/run_manager.gd:4432](scripts/systems/run_manager.gd:4432) `_emit_run_ended` — emits reason + summary payload.
- Handlers:
  - [scripts/ui/ui_root.gd:1140](scripts/ui/ui_root.gd:1140) `_on_run_ended` — ensures game-over modal visibility.
- Assessment:
  - **Authority OK** (single emitter, reactive UI handler).
  - Recommendation: none.

### Player died signal (`Player.died`) -> terminal flow

- Emits:
  - [scripts/Player.gd:262](scripts/Player.gd:262) `take_damage` — local `died` signal emitted when HP reaches 0.
- Handlers:
  - [scripts/systems/run_manager.gd:3762](scripts/systems/run_manager.gd:3762) `_connect_player_signals` wires player `died` to RunManager.
  - [scripts/systems/run_manager.gd:3781](scripts/systems/run_manager.gd:3781) `_on_player_died` — enters end-run (`death`).
  - [scripts/Arena.gd:145](scripts/Arena.gd:145) / [scripts/Arena.gd:153](scripts/Arena.gd:153) — Arena also listens to `died` for local enemy cleanup counters.
- Assessment:
  - **Authority OK**: terminal decision remains in RunManager (`_enter_end_run`). Arena’s handler is non-terminal cleanup only.【file:scripts/Arena.gd:225】
  - Recommendation: none.

### request_fail_run (intent channel)

- Emits:
  - No active emit sites found via search for `request_fail_run.emit` in `scripts/` and `scenes/`.
- Handlers:
  - [scripts/systems/run_manager.gd:3769](scripts/systems/run_manager.gd:3769) `_on_request_fail_run`.
- Assessment:
  - **Authority OK** (request intent reserved for RunManager).
  - Recommendation: keep as reserved ingress; document current emitters if future systems re-enable it.

### run_phase_changed

- Emits:
  - [scripts/systems/run_manager.gd:4915](scripts/systems/run_manager.gd:4915) `set_phase` emits `GameEvents.run_phase_changed`.
- Handlers:
  - [scripts/ui/main_menu.gd:113](scripts/ui/main_menu.gd:113) `_on_run_phase_changed`.
  - Additional UI subscriptions in `ui_root.gd` readiness wiring (reactive usage).【file:scripts/ui/ui_root.gd:279】
- Assessment:
  - **Authority OK**: phase broadcast emitted by RunManager only.
  - Recommendation: none.

### request_end_run_restart / request_end_run_next_bet / request_end_run_quit

- Emits:
  - [scripts/ui/ui_root.gd:1948](scripts/ui/ui_root.gd:1948) `_on_restart_pressed` emits `request_end_run_restart`.
  - [scripts/ui/ui_root.gd:1952](scripts/ui/ui_root.gd:1952) `_on_retry_pressed` emits `request_end_run_next_bet`.
  - [scripts/ui/ui_root.gd:1975](scripts/ui/ui_root.gd:1975) `_on_quit_pressed` emits `request_end_run_quit`.
- Handlers:
  - [scripts/systems/run_manager.gd:3173](scripts/systems/run_manager.gd:3173) `_on_request_end_run_restart`.
  - [scripts/systems/run_manager.gd:3179](scripts/systems/run_manager.gd:3179) `_on_request_end_run_next_bet`.
  - [scripts/systems/run_manager.gd:3188](scripts/systems/run_manager.gd:3188) `_on_request_end_run_quit`.
- Assessment:
  - **Authority OK**: UI emits request intents only; RunManager executes transitions.
  - Recommendation: none.

## Flow Paths

### New Game -> Run Start

1. Entry scene is `Main.tscn`; it instantiates a `RunManager` node in group `run_manager` plus `UI` and `MainMenu`.【file:project.godot:7】【file:scenes/Main.tscn:31】【file:scenes/Main.tscn:34】【file:scenes/Main.tscn:47】
2. Main menu New Game button emits `GameEvents.request_new_run` (intent only).【file:scripts/ui/main_menu.gd:311】【file:scripts/ui/main_menu.gd:318】
3. RunManager subscribes to `request_new_run` in `_connect_gameevents`.【file:scripts/systems/run_manager.gd:1231】
4. `_on_request_new_run` phase-guards then calls `request_new_game()` -> `_start_new_run()`.【file:scripts/systems/run_manager.gd:3048】【file:scripts/systems/run_manager.gd:3050】【file:scripts/systems/run_manager.gd:3053】【file:scripts/systems/run_manager.gd:1431】【file:scripts/systems/run_manager.gd:1515】
5. RunManager emits `run_started` and updates reactive UI/event channels (`coins_changed`, optional countdown).【file:scripts/systems/run_manager.gd:1584】【file:scripts/systems/run_manager.gd:1586】【file:scripts/systems/run_manager.gd:1591】
6. UI root/Arena are listeners that react to `run_started`; no phase authority is delegated to UI/Arena.【file:scripts/ui/ui_root.gd:285】【file:scripts/Arena.gd:56】

### Player Death -> End Run

1. Player HP reaches 0 in `Player.take_damage`, which emits local `died` signal and frees player node.【file:scripts/Player.gd:246】【file:scripts/Player.gd:262】【file:scripts/Player.gd:263】
2. RunManager connects to player `died` and handles it in `_on_player_died()` by calling `_enter_end_run("death")`.【file:scripts/systems/run_manager.gd:3762】【file:scripts/systems/run_manager.gd:3781】【file:scripts/systems/run_manager.gd:3782】
3. `_enter_end_run` records end reason then enters `_enter_game_over`.【file:scripts/systems/run_manager.gd:4352】【file:scripts/systems/run_manager.gd:4359】【file:scripts/systems/run_manager.gd:4362】
4. `_enter_game_over` sets `GAME_OVER` phase and emits terminal events in order: `run_finale_selected`, `run_ended`, `run_failed`.【file:scripts/systems/run_manager.gd:4372】【file:scripts/systems/run_manager.gd:4404】【file:scripts/systems/run_manager.gd:4405】【file:scripts/systems/run_manager.gd:4406】
5. UI/Arena consume terminal events reactively (`_on_run_ended`, `_on_run_failed`).【file:scripts/ui/ui_root.gd:1140】【file:scripts/ui/ui_root.gd:1104】【file:scripts/Arena.gd:281】

## Stop Conditions Audit

- **Direct calls bypassing RunManager for terminal globals**: none found (`run_failed.emit` / `run_ended.emit` only in RunManager).【file:scripts/systems/run_manager.gd:4413】【file:scripts/systems/run_manager.gd:4428】【file:scripts/systems/run_manager.gd:4432】
- **Multiple systems emitting same terminal event**: none found for `run_failed`, `run_ended`, `run_phase_changed`.
- **Fallback terminal emits when flow missing**: present in `_fail_flow` -> `_enter_end_run("RUN_FAILED")` when required UI panel missing. This is inside authority boundaries but should be explicitly accepted or isolated as infra-fail path.【file:scripts/systems/run_manager.gd:1414】【file:scripts/systems/run_manager.gd:1424】【file:scripts/systems/run_manager.gd:1429】

## Patch Plan (do not implement)

### Violation/Risk A — RunManager self-subscription to run_failed (parallel-ingress smell)

- Target file(s): `scripts/systems/run_manager.gd`
- Single objective: remove `run_failed -> _on_run_failed` binding from RunManager so `run_failed` is output-only for terminal flow.
- Acceptance criteria:
  - `run_failed` remains emitted only in `_emit_run_failed`.
  - No RunManager handler remains connected to `run_failed`.
  - End-run behavior unchanged for UI/Arena listeners.
- Stop condition: if any gameplay path currently relies on synthetic `run_failed` re-entry to end run, stop and re-audit before patching.

### Violation/Risk B — Fallback terminalization from `_fail_flow`

- Target file(s): `scripts/systems/run_manager.gd`
- Single objective: classify infra sanity failures distinctly from gameplay loss (e.g., dedicated debug-only failure state) without auto-coercing gameplay `RUN_FAILED` outcome.
- Acceptance criteria:
  - Missing UI panel sanity failure no longer forces normal gameplay `run_failed` flow unless explicitly desired by canon.
  - Existing gameplay failure semantics unchanged.
- Stop condition: if canon requires infra failure to be represented as normal gameplay failure, keep current behavior and document as intentional.
