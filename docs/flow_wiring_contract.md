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
| `request_open_bet_ui` | UNKNOWN (needs editor validation) | BetManager | `scripts/systems/bet_manager.gd::_ready` |
| `request_place_bet` | UI Root | RunManager, BetManager | `scripts/ui/ui_root.gd::_place_bet` → `scripts/systems/run_manager.gd::_ready`, `scripts/systems/bet_manager.gd::_ready` |
| `bet_ui_opened` | RunManager, BetManager | UI Root | `scripts/systems/run_manager.gd::_open_level3_bet_ui`, `scripts/systems/bet_manager.gd::open_bet_ui_before_arena` → `scripts/ui/ui_root.gd::_ready` |
| `bet_placed` | RunManager, BetManager | UI Root, RunManager | `scripts/systems/run_manager.gd::select_bet`, `scripts/systems/bet_manager.gd::place_bet` → `scripts/ui/ui_root.gd::_ready`, `scripts/systems/run_manager.gd::_ready` |
| `pact_sealed_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_pact_sealed_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `pact_sealed_closed` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_pact_sealed_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `resolve_ritual_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_resolve_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `resolve_ritual_closed` | RunManager | UI Root | `scripts/systems/run_manager.gd::_start_resolve_ritual` → `scripts/ui/ui_root.gd::_ready` |
| `arena_started` | RunManager | UI Root | `scripts/systems/run_manager.gd::_resolve_ritual_outcome` → `scripts/ui/ui_root.gd::_ready` |
| `arena_completed` | RunManager | UNKNOWN (needs editor validation) | `scripts/systems/run_manager.gd::_resolve_ritual_outcome` |
| `request_intermediate_choice` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_intermediate_choice_*` → `scripts/systems/run_manager.gd::_ready` |
| `push_luck_opened` | RunManager | UI Root | `scripts/systems/run_manager.gd::_open_push_luck_choice` → `scripts/ui/ui_root.gd::_ready` |
| `request_push_luck_cashout` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_push_luck_cashout_pressed` → `scripts/systems/run_manager.gd::_ready` |
| `request_push_luck_double` | UI Root | RunManager | `scripts/ui/ui_root.gd::_on_push_luck_double_pressed` → `scripts/systems/run_manager.gd::_ready` |
| `run_finale_selected` | RunManager | UI Root | `scripts/systems/run_manager.gd::_emit_run_finale` → `scripts/ui/ui_root.gd::_ready` |
| `run_failed` | RunManager | UI Root, Arena | `scripts/systems/run_manager.gd::_emit_run_failed` → `scripts/ui/ui_root.gd::_ready`, `scripts/Arena.gd::_ready` |
| `request_show_main_menu` | UI Root | MainMenu UI, RunManager (log-only) | `scripts/ui/ui_root.gd::_on_quit_pressed` → `scripts/ui/main_menu.gd::_ready`, `scripts/systems/run_manager.gd::_ready` |
