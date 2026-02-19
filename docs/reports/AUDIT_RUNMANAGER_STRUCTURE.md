# AUDIT — RunManager Structure

## 1. File Overview

- Target: `res://scripts/systems/run_manager.gd`
- Total lines: **5198**
- Total functions (`^func`): **306**

### High-level contiguous section breakdown

1. **Header, contracts, enums, constants, static payload dictionaries, state fields** (`1–1171`)
2. **Smoke/bootstrap/lifecycle wiring and boot validation** (`1172–1542`)
3. **Public request API and phase guards** (`1543–1639`)
4. **Run start, pact/bet commit, rituals, arena resolution entry** (`1640–2126`)
5. **Bet presentation, RNG/scar/corruption, save/autosave and continue apply path** (`2127–2596`)
6. **Arena theme/special arena/pact log/outcome handlers** (`2597–3012`)
7. **Arena/player scene orchestration and gameplay setup** (`3021–3208`)
8. **GameEvents request handlers, post-arena choices, push-your-luck handlers** (`3221–3650`)
9. **Currency/progression legacy bridge and gameplay callbacks** (`3661–3928`)
10. **Intermediate/push-your-luck UI payloads, audience contract, reward text** (`3932–4424`)
11. **Run end/finale/log/export + authority helpers + scar/register mutations + runtime debug** (`4439–5302`)

## 2. Section Mapping (by line ranges)

| Line range | Section label | Responsibility summary | Dependencies | Canon classification | Risk |
|---|---|---|---|---|---|
| `1–1171` | Definitions + static config + runtime fields | Declares phase enum, constants, bet IDs, phrase dictionaries, preload dependencies, and mutable runtime fields. | RunState, GameEvents (contract comments), SaveSystem (preload), Helpers (`SmokeDriver`, `FlowWatchdog`, `FlowDiagnostics`, `FinaleBuilder`), UI payload type refs. | **MUST STAY** | Medium |
| `1172–1542` | Smoke gate + boot + event wiring + validation | Initializes manager/session, validates GameEvents contract, binds request/event signals, applies language, performs boot sanity checks. | GameEvents, UI/scene tree (`add_to_group`, deferred boot), Helpers (`SmokeDriver`, `FlowWatchdog`, `FlowDiagnostics`), SaveManager language state. | **MUST STAY** | High |
| `1543–1639` | Public request surface and phase guards | Exposes callable request methods (`request_*`) and enforces phase-gated intent handling before flow mutation. | RunState (phase gates), GameEvents (request semantics), SaveSystem (continue load/apply). | **MUST STAY** | High |
| `1640–2126` | New run path, level3 run setup, pact and ritual sequencing | Resets run state, starts run flow, commits bet/pact, orchestrates timed rituals and resolution phase entry. | RunState, GameEvents emissions, UI payload emissions, scene tree timers. | **MUST STAY** | High |
| `2127–2596` | Bet UI opening, RNG/scar mutation helpers, autosave/continue serialization boundary | Builds bet offers, computes seeds, mutates corruption/scars/glory, builds and applies save payload, rejection path, resume path. | RunState, SaveSystem, GameEvents, Helpers (`RunUiPayload`); minor UI emit coupling. | **CAN EXTRACT** (logic helpers), **CAN MIGRATE** (save boundary hardening) | High |
| `2597–3012` | Arena theme + special arena + outcome reward/scar application | Handles thematic progression, special arena activation hooks, level3 win/loss reward/scar flows and ending selection. | RunState, GameEvents (theme/escalation emissions), helpers (`ScarCatalog`/outcome systems). | **CAN EXTRACT** | Medium |
| `3021–3208` | Arena/player scene orchestration | Ensures arena/player nodes exist, chooses scenes/layouts, respawns and resets runtime actors. | UI/scene tree, groups (`arena`, `player`, `enemies`), GameEvents gameplay enable toggles. | **CAN EXTRACT** | Medium |
| `3221–3650` | Request handlers and post-arena decision adapters | Receives GameEvents request signals, validates current phase, forwards into canonical internal handlers (`_take_payout`, `_push_your_luck`, etc.). | GameEvents (request_* authority), RunState/phase checks, UI flow state. | **MUST STAY** | High |
| `3661–3928` | Coins/progression bridge and combat callbacks | Currency mutators, legacy progression math, player signal wiring, fail-run and bet failure processing. | RunState, GameEvents (coins/run fail), scene tree player node. | **CAN EXTRACT** (legacy progression), core failure stays | Medium |
| `3932–4424` | Intermediate/push-your-luck payloads + audience contract | Builds UI payloads, sentence/doom texts, post-bet queue fallback, audience policy/phrases, scaled bet rewards. | RunState, GameEvents (UI events/queue), RunUiPayload, helper systems. | **CAN EXTRACT** | Medium |
| `4439–5302` | End-run finalization, phase authority core, scar/register mutation helpers, diagnostics | Ends run, emits finale/log/export, owns `_set_phase`/enter dispatch, runtime watchdog, scars/register annotations, runtime snapshot logging. | RunState, GameEvents, SaveSystem (export/clear path), Helpers (`FinaleBuilder`, `FlowDiagnostics`, `FlowWatchdog`), UI payload emission. | **MUST STAY** for phase authority; **CAN EXTRACT** for finale/scar/report helpers | High |

## 3. Functional Buckets (E-block decomposition)

### C1 Save/Continue payload boundary
- Estimated lines: **~201** (`2396–2596`)
- Core functions: `_autosave_run_checkpoint`, `_build_run_save_payload`, `_build_level3_runtime_payload`, `_apply_run_save_payload`, `_reject_invalid_continue_payload`, `_resume_run_from_save`, serialization/parse helpers.
- Extraction feasibility: **High**, as pure payload build/parse and resume routing can move to `systems/run/save_boundary_helper.gd`, keeping only orchestration calls in RunManager.

### C2 Arena progression
- Estimated lines: **~402** (`2597–3012` + `3021–3208`)
- Core functions: `_get_current_arena_index`, `_pick_next_arena_theme`, `_maybe_activate_special_arena`, `_resolve_level3_arena`, `_ensure_arena_and_player`, `load_next_arena`, `_start_next_arena`.
- Extraction feasibility: **Medium**, due to scene-tree coupling and direct RunState writes.

### C3 Betting contract
- Estimated lines: **~560** (`2149–2387`, `2853–3012`, `3935–4424` subsets)
- Core functions: `_open_level3_bet_ui`, `_build_level3_bet_offer`, weighted pick helpers, `_handle_level3_win/loss`, `_apply_level3_reward`, `_apply_bet_result`, reward text builders.
- Extraction feasibility: **Medium-High**, mostly deterministic contract logic with bounded GameEvents emissions.

### C4 Ritual sequencing
- Estimated lines: **~154** (`1942–2030`, `4153–4189`)
- Core functions: `_start_pact_sealed_ritual`, `_start_resolve_ritual`, `_resolve_ritual_outcome`, `_queue_push_luck_choice`, `_on_arena_message_queue_completed`, `_force_post_bet_choice_fallback`.
- Extraction feasibility: **Medium**, timer/sequence-id handling is local but still phase-authority-adjacent.

### C5 Post-arena / Push-your-luck
- Estimated lines: **~281** (`3363–3569`, `3969–4225`)
- Core functions: `_apply_intermediate_choice`, `_take_payout`, `_handle_push_luck_condanna`, `_push_your_luck`, `_open_intermediate_choice`, `_open_push_luck_choice`, `_refresh_push_luck_choice`.
- Extraction feasibility: **Medium**, strongly coupled to phase gates and RunState mutation.

### C6 RunState mutation helpers
- Estimated lines: **~485** (`2323–2387`, `3951–3968`, `5002–5232`)
- Core functions: `_apply_corruption`, `_try_apply_*scar*`, `_reset_progression`, `_register_condanna`, `_add_scar`, `_build_run_scar`, `_recompute_scar_modifiers`, `_apply_scar_modifiers_to_player`.
- Extraction feasibility: **High** for pure mutation math; **Low** for methods that directly emit GameEvents.

### C7 Debug overlay wiring
- Estimated lines: **~320** (`1172–1279`, `3570–3616`, `4851–4897`, `5254–5302`)
- Core functions: `_smoke_*`, `_on_request_set_run_seed`, `_on_request_skip_arena_resolution`, `_set_phase` debug prints, `_watchdog_tick`, `_log_runtime_state`.
- Extraction feasibility: **High**, can move diagnostics/smoke adapters behind helper facade while keeping `_set_phase` authority local.

## 4. Top 15 Longest Functions

> Line spans are syntactic spans between `func` declarations.

| Function | Line span | Responsibility summary | Refactor/extract candidate |
|---|---:|---|---|
| `_flow_log` | `208–1171` (964) | Contains logger call, but declaration placement makes large constants/data block part of span. | **Yes** (data relocation), because constants currently sit after a function declaration. |
| `_start_level3_run` | `1745–1850` (106) | Full level3 run initialization, state reset, emission setup, and phase progression prep. | **Yes** (split into init/emission helpers). |
| `_start_new_run` | `1643–1741` (99) | New run reset path with phase set, state clears, and branch to level3/non-level3 setup. | **Yes** (extract reset bundle). |
| `_select_run_finale` | `4648–4727` (80) | Computes finale dictionary from run metrics/condanne/state flags. | **Yes** (pure policy helper). |
| `_apply_run_save_payload` | `2428–2494` (67) | Applies validated payload into RunState/run dict and resets multiple runtime flags. | **Yes** (save-boundary applicator helper). |
| `_push_your_luck` | `3508–3569` (62) | Executes continue-path decision, gating, state mutation, and transition routing. | **Yes** (extract decision subroutines). |
| `_take_payout` | `3425–3477` (53) | Executes cashout path, reward scaling, run finalization trigger. | **Yes** (extract reward/finale prep). |
| `_build_push_luck_payload` | `4042–4093` (52) | Builds full push-your-luck UI payload dictionary including policy and text. | **Yes** (UI payload factory). |
| `_connect_gameevents` | `1309–1359` (51) | Central request/event signal wiring matrix to local handlers. | **No** (authority-critical contract table). |
| `_log_runtime_state` | `5254–5302` (49) | Builds runtime diagnostics payload and emits debug log line. | **Yes** (debug helper). |
| `_ensure_arena_and_player` | `3021–3068` (48) | Ensures arena/player presence and wiring before gameplay steps. | **Yes** (scene orchestration helper). |
| `_handle_level3_loss` | `2888–2933` (46) | Applies loss behavior by bet type and returns generated scar IDs. | **Yes** (policy table extraction). |
| `_handle_level3_loss_ritual` | `2934–2979` (46) | Ritual-loss behavior branch with corruption/scar outcomes. | **Yes** (policy extraction). |
| `_enter_resolution` | `2030–2074` (45) | Enter-handler for resolution phase with gating and flow transitions. | **No** (phase authority must stay local). |
| `_enter_game_over` | `4451–4495` (45) | Game-over entry process and final event/UI emission control. | **No** (phase authority + end-run canonical ownership). |

## 5. Phase Authority Map

### All `_enter_*` methods
- `_enter_resolution` (`2030`)
- `_enter_mid_choice` (`3973`)
- `_enter_push_your_luck` (`3988`)
- `_enter_first_reaction` (`4157`)
- `_enter_end_run` (`4439`)
- `_enter_game_over` (`4451`)
- `_enter_main_menu` (`4940`)
- `_enter_intro` (`4943`)
- `_enter_bet_present` (`4946`)
- `_enter_bet_committed` (`4949`)
- `_enter_next_bet` (`4952`)
- `_enter_end_run_phase` (`4955`)

### All direct `_set_phase(...)` call sites
`1419`, `1625`, `1648`, `1747`, `1880`, `1916`, `2028`, `2115`, `2142`, `2152`, `2502`, `3971`, `3986`, `4155`, `4459`.

### All `request_*` handlers in RunManager
Public methods:
- `request_new_game`, `request_confirm_pact`, `request_choose_mid`, `request_push_your_luck`, `request_take_payout`, `request_quit_to_menu`, `request_load_continue`.

GameEvents-adapter handlers:
- `_on_request_new_run`, `_on_request_reset_run`, `_on_request_retry_run`, `_on_request_continue_run`, `_on_request_show_main_menu`, `_on_request_intro_apply_seed`, `_on_request_intro_select_bet`, `_on_request_intro_confirm`, `_on_request_mid_choice_select`, `_on_request_pyl_cashout`, `_on_request_pyl_condanna`, `_on_request_pyl_double`, `_on_request_end_run_restart`, `_on_request_end_run_next_bet`, `_on_request_end_run_quit`, `_on_request_place_bet`, `_on_request_intermediate_choice`, `_on_request_push_luck_cashout`, `_on_request_push_luck_double`, `_on_request_set_run_seed`, `_on_request_clear_run_seed`, `_on_request_skip_arena_resolution`, `_on_request_fail_run`.

### Verification
- **Duplicate phase authority paths:** none found for authority mutation; all mutating transitions route through `_set_phase(...)`.
- **External phase mutation:** active external mutation path is blocked; public `set_phase(p)` only logs/rejects/asserts and does not mutate `_phase`.

## 6. Save/Continue Boundary Map

- **Payload built:** `_build_run_save_payload` (`2403–2414`) + `_build_level3_runtime_payload` (`2416–2426`), called by `_autosave_run_checkpoint` (`2396–2401`).
- **Payload validated:** via `_save_system.apply_level3_payload(_run_state, payload)` inside `_apply_run_save_payload` (`2430–2433`); rejection reason captured in `_last_save_reject_reason`.
- **Payload applied:** `_apply_run_save_payload` (`2435–2492`) maps parsed dictionaries into RunState/run runtime fields and re-emits runtime sync events.
- **Payload rejected:** `_reject_invalid_continue_payload` (`2495–2502`) clears persisted run and routes back to `MAIN_MENU`.
- **Continue entrypoint:** `request_load_continue` (`1627–1638`) loads payload, applies/rejects, then `_resume_run_from_save` (`2504+`).

**Boundary assessment:** partially isolated. Build/apply/reject logic is in a contiguous block, but still interwoven with direct phase mutation, GameEvents emissions, RNG reseeding, and scene-flow reentry in the same class.

## 7. Extraction Roadmap (Ordered, Minimal Risk)

| Rank | Patch name | Target bucket | Expected line reduction | Risk | Why safe |
|---:|---|---|---:|---|---|
| 1 | `extract_save_continue_boundary_helper` | C1 | 140–190 | Low | Mostly pure payload build/parse/apply methods with explicit input/output dictionaries. |
| 2 | `extract_debug_smoke_watchdog_adapter` | C7 | 180–260 | Low | Debug/smoke/watchdog paths are orthogonal to core run outcomes; can keep `_set_phase` calls in manager. |
| 3 | `extract_betting_offer_policy` | C3 | 120–180 | Medium | Weighted bet selection and behavior maps are deterministic and data-driven, low scene-tree dependency. |
| 4 | `extract_arena_theme_special_policy` | C2 | 110–160 | Medium | Theme/special-arena calculations can move to helper while RunManager retains scene mutation calls. |
| 5 | `extract_scar_state_mutation_kernel` | C6 | 130–210 | Medium | Scar math/recompute helpers are mostly RunState transformations; keep event emission wrappers in manager. |


## 8. Patch Log

### C3.1 — Extract betting offer policy + reward text builders

- Added `res://scripts/systems/run/betting_policy.gd` (`RefCounted`) to host deterministic offer-selection policy and audience/cashout reward text builders.
- RunManager keeps authority for `_set_phase(...)`, `_open_level3_bet_ui`, request handlers, `RunState` mutations, and all `GameEvents` emissions.
- Migrated deterministic functions from RunManager into helper-backed calls for:
  - weighted offer selection + anti-repeat filtering
  - registry precedent offer weight adjustments
  - audience label/phrase and cashout modifier text construction used by push-luck payloads
- Result: RunManager reduced to **5198 lines** with no phase/event authority moved out of the manager.


### C3.2 — Extract betting/push-luck payload factory

- Added `res://scripts/systems/run/betting_payload_factory.gd` (`RefCounted`) for pure UI payload dictionary assembly.
- RunManager now delegates bet-offer payload wrapping and push-your-luck payload dictionary formatting to the helper.
- Audience reward text fragments are normalized through the payload factory before use in UI payload assembly.
- Phase transitions, request gating, `GameEvents` emission timing, and all `RunState` mutation remain in `RunManager`.
- Result: RunManager reduced further to **5198 lines** after payload-assembly extraction.
