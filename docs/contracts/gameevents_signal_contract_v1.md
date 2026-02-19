# GameEvents Signal Contract v1

Status: Canonical contract for CI validation of required cross-layer signals.

Scope: Presence and arity checks for the Level 3 required GameEvents signals.

Source alignment: `docs/canon/RUN_ARCHITECTURE_CANON.md` (GameEvents required for Level 3 flow).

## Version

- Contract version: `v1`
- Event bus authority: `res://scripts/systems/game_events.gd` only
- Validation mode: declaration presence + declared parameter arity

## Required signals

| Signal | Arity | Notes |
| --- | ---: | --- |
| `request_new_run` | 0 | MainMenu -> RunManager intent |
| `request_continue_run` | 0 | MainMenu -> RunManager intent |
| `request_place_bet` | 2 | UI -> RunManager intent |
| `bet_ui_opened` | 1 | RunManager -> UI |
| `bet_placed` | 3 | RunManager -> UI |
| `pact_sealed_opened` | 0 | RunManager -> UI |
| `pact_sealed_closed` | 0 | RunManager -> UI |
| `resolve_ritual_opened` | 1 | RunManager -> UI |
| `resolve_ritual_closed` | 0 | RunManager -> UI |
| `arena_started` | 1 | RunManager -> UI |
| `arena_completed` | 1 | Arena/RunManager flow |
| `request_mid_choice_select` | 1 | UI -> RunManager intent |
| `push_luck_opened` | 1 | RunManager -> UI |
| `request_pyl_cashout` | 0 | UI -> RunManager intent |
| `request_pyl_double` | 0 | UI -> RunManager intent |
| `run_debug_state_updated` | 1 | RunManager -> UI debug |
| `run_finale_selected` | 1 | RunManager -> UI |
| `run_failed` | 0 | RunManager -> UI/Arena |
| `request_show_main_menu` | 0 | UI -> MainMenu/RunManager |

## CI rule

`tools/ci/validate_gameevents_contract.py` must fail when any required signal above is missing or has different declared arity in `scripts/systems/game_events.gd`.
