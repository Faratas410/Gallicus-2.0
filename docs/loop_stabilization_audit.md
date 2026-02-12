# Loop Stabilization Audit

Target: `scripts/systems/run_manager.gd`

## Phase List

Runtime enum phases (`RunPhase`):

* `NONE`
* `PREP`
* `LIVE`
* `GAME_OVER` (UI alias: `END_RUN`)
* `MAIN_MENU`
* `RUN_INIT` (UI alias: `INTRO`)
* `BET_PRESENT`
* `BET_COMMITTED`
* `POST_BET_MESSAGES` (UI alias: `FIRST_REACTION`)
* `INTERMEDIATE_CHOICE` (UI alias: `MID_CHOICE`)
* `PUSH_YOUR_LUCK`
* `NEXT_BET`
* `RESOLUTION`

Notes:

* `_phase` is the authoritative flow phase variable.
* `phase` (set via `set_phase`) is a gameplay/reactivity flag (`PREP`/`LIVE`/`GAME_OVER`) and does **not** drive `_phase` transitions.

## Phase Graph

Below are all `_phase` transitions found via `_set_phase(...)`, with conditions and transition functions.

* `NONE -> RUN_INIT` (`_start_new_run` / `_start_level3_run`; boot or new-run request accepted)
* `ANY_ALLOWED -> MAIN_MENU` (`request_quit_to_menu`; guarded by `_guard_request_phase("request_show_main_menu", [...])`)
* `RUN_INIT -> BET_PRESENT` (`_open_level3_bet_ui` / `_open_bet_ui`; run initialized and not game-over)
* `BET_PRESENT -> BET_COMMITTED` (`_confirm_pact_with_bet_id` or `_register_level3_bet_choice`; requires `_waiting_for_bet` and non-terminal run)
* `BET_COMMITTED -> RESOLUTION` (`resolve_arena` after pact confirmation)
* `RESOLUTION -> POST_BET_MESSAGES` (`_queue_push_luck_choice`; only if run not already terminal after arena resolution)
* `POST_BET_MESSAGES -> INTERMEDIATE_CHOICE` (`_open_intermediate_choice`; either immediate, on `arena_message_queue_completed`, or fallback timer)
* `INTERMEDIATE_CHOICE -> PUSH_YOUR_LUCK` (`_apply_intermediate_choice`; valid mid-choice input required)
* `PUSH_YOUR_LUCK -> RESOLUTION` (`_push_your_luck` with "double" path; guarded by `request_*` phase checks and lock-reason guards)
* `PUSH_YOUR_LUCK -> GAME_OVER` (`_take_payout` / `_handle_push_luck_condanna` -> `end_run` -> `_enter_end_run`)
* `RESOLUTION -> GAME_OVER` (`_handle_level3_loss*`, `_on_request_fail_run`, `_on_player_died`, `_fail_flow`, etc., all converge to `_enter_end_run`)
* `GAME_OVER -> RUN_INIT` (`request_end_run_restart` or `request_end_run_next_bet` in Level3)

Legacy/non-Level3 branch also contains:

* `LIVE -> NEXT_BET` (`start_next_bet_round`, non-Level3)
* `NEXT_BET -> BET_PRESENT` (next wager opening)

### Transition authority check

No external authority was found for `_phase` mutation:

* `_phase` is mutated only inside `_set_phase(next, reason)`.
* All phase transition entry points call methods in this same `RunManager` script.
* External systems interact through `GameEvents` requests, but the guard + transition execution remains in `RunManager`.

## Cycles Found

Primary gameplay cycle (Level3):

* `BET_PRESENT -> BET_COMMITTED -> RESOLUTION -> POST_BET_MESSAGES -> INTERMEDIATE_CHOICE -> PUSH_YOUR_LUCK -> RESOLUTION`
  * Intentional: **yes** (core risk/escalation loop).

Secondary loop via replay from terminal panel:

* `GAME_OVER -> RUN_INIT -> BET_PRESENT -> ... -> GAME_OVER`
  * Intentional: **yes** (new run lifecycle, not same-run continuation).

Legacy/non-Level3 loop:

* `BET_PRESENT -> ... -> NEXT_BET -> BET_PRESENT`
  * Intentional: **yes** (legacy bet chaining).

## Infinite Loop Risk

No unconditional infinite phase cycle was found.

Observed safeguards:

* Every user-triggered transition is phase-guarded (`_guard_request_phase`) and in many cases also gated by waiting flags.
* `POST_BET_MESSAGES` has deterministic exit via one of:
  * immediate open of `INTERMEDIATE_CHOICE`,
  * `arena_message_queue_completed` signal,
  * forced fallback timer (`POST_BET_QUEUE_FALLBACK_SECONDS`).
* `PUSH_YOUR_LUCK` requires explicit user action and has lock guards for illegal options; with no input, watchdog reports stall (diagnostic fail-fast), rather than hidden uncontrolled transition.

Residual operational risk (not a logic loop bug):

* If a player always chooses "double" when available, the cycle can persist for many arenas by design. This is bounded by gameplay outcomes and end conditions, not by a hard iteration cap.

## Termination Guarantees

A run can terminate through multiple deterministic gates:

* Explicit close from push-luck choices (`cashout` / `condanna`) -> `end_run` -> `GAME_OVER`.
* Arena failure outcomes (`_handle_level3_loss*`) can force `_enter_end_run`/`end_run`.
* Fatal events (`_on_player_died`, `request_fail_run`, infrastructure flow fail) force `_enter_end_run`.
* `GAME_OVER` marks terminal flags (`_is_game_over = true`, `_run_state.run_is_over = true`) and emits end/fail signals.

### Explicit verifications requested

* **PUSH_YOUR_LUCK loop termination condition**:
  * Exit to terminal is always available once cashout lock reasons clear (`_get_cashout_lock_reason`), and hard-forced at/after target arenas (`_get_double_lock_reason` returns `"Fine run: incassa ora"` when arena target reached).
  * Any fail/death path exits to `GAME_OVER`.

* **MID_CHOICE transition guard**:
  * `request_mid_choice_select` is accepted only in `INTERMEDIATE_CHOICE`.
  * `request_choose_mid` additionally requires `_waiting_for_intermediate_choice` and valid index {0,1}; otherwise no transition.

* **INTRO only once per run**:
  * `INTRO` corresponds to `RUN_INIT` entry (`_enter_intro`).
  * `RUN_INIT` is entered at run start (`_start_new_run` / `_start_level3_run`), i.e., once per run instance. Re-entry occurs only when starting a **new** run (e.g., from `GAME_OVER` restart), not mid-run.

* **END_RUN cannot transition back to gameplay**:
  * `END_RUN` corresponds to `GAME_OVER` phase.
  * Allowed requests from `GAME_OVER` are restart/next-run/menu, all routed to `RUN_INIT` or `MAIN_MENU`; there is no direct `GAME_OVER -> RESOLUTION/INTERMEDIATE_CHOICE/PUSH_YOUR_LUCK/BET_*` path.

## Patch Plan (if needed)

No violations requiring code patch were found in this audit scope.

* Minimal patch count: **0**.
* Code changes: **none**.
