# Coins Audit

## Declaration

### Active runtime coin variable

- **Primary coin state** is declared inside `RunManager` as `run["coins"]` in the `run` dictionary (`int` usage throughout). Owner: **`scripts/systems/run_manager.gd`**.  
- Initialization inputs for this value:
  - `starting_coins: int = GameConstants.RUN_STARTING_COINS` in `RunManager`.
  - `GameConstants.RUN_STARTING_COINS := 40` in constants.

### Other currency-related declarations (active)

- `token_purchase_cost_coins: int` (coin cost to buy a token) in `RunManager`.
- `bet_coward_coin_reward: int` (coin reward amount for COWARD bet branch) in `RunManager`.
- `GameEvents` exposes `signal coins_changed(coins: int)` used for reactive UI updates.
- `UIRoot` holds `_coins: int` as UI cache only.

### Legacy/secondary coin variables

- `legacy_runtime/gameplay/player_legacy.gd` contains `var coins: int = 0` and `add_coins(amount)`.
- `legacy_runtime/pickups/Pickup.gd` includes `PickupType.COINS` and attempts to emit `GameEvents.request_add_coins`.
- `request_add_coins` signal is **not declared** in active `scripts/systems/game_events.gd`, so this legacy path is not wired into active runtime authority.

## Lifecycle

### Run initialization/reset behavior

- Coins are explicitly reset to `starting_coins` when a new run starts (both standard and Level 3 paths).
- Coins are also reset in `reset_run()` and in `restart_run(preserve_coins = false)`.

### Save/load behavior during a run

- Coins are included in run checkpoint payload under `run["coins"]` via `_build_run_save_payload()`.
- On loading a run payload, `run["coins"]` is restored from serialized `run_data["coins"]`.
- After load or new-run setup, `GameEvents.coins_changed` is emitted to synchronize UI.

### End/new-run behavior and persistence boundaries

- Starting a new run request clears run save (`_save_system.clear_run()`).
- Entering game-over also clears run save.
- Therefore coin values survive only as long as run-save checkpoints exist; they are reset on new run/game-over flow.

## Persistence

### Authority and storage

- **Authority owner:** `RunManager` (not `RunState`, not UI).
- `RunState` has many fields but no `coins` field.
- Runtime checkpoint persistence is handled by `SaveSystem` to `user://run.save` payloads.
- Profile/meta persistence in `SaveManager` stores unlocked IDs + settings; no dedicated persistent coin/meta-currency field.

### Serialization summary

- Coins are serialized inside run payload (`"run": { "coins": ... }`) and recovered from the same field on load.
- This is **run continuation persistence**, not account/profile meta currency persistence.

## Gameplay Usage

### Incremented (`add_coins` call sites)

1. `RunManager._apply_special_arena_ash_reward`  
   - Purpose: reward for special arena outcome (`+12` on win path).
2. `RunManager._apply_level3_reward`  
   - Purpose: level 3 reward computed by outcome system.
3. `RunManager._on_wave_cleared` (non-Level3 branch)  
   - Purpose: arena clear reward (`arena_clear_reward`).
4. `RunManager._apply_bet_reward_scaled` (`BET_COWARD`)  
   - Purpose: bet reward payout (`bet_coward_coin_reward * reward_scale`).

### Decremented (`spend_coins` call sites)

1. `RunManager.purchase_token`  
   - Purpose: spend coin cost to buy one upgrade token.
2. `RunManager._apply_intermediate_loss_penalty_if_needed`  
   - Purpose: intermediate-flow coin penalty (`INTERMEDIATE_PROVOCA_LOSS_PENALTY_COINS`).

### Read/condition checks

- `RunManager.spend_coins`: checks affordability (`current coins < amount`).
- `RunManager.get_coins`: accessor used by UI compatibility path.
- `UIRoot._refresh_buy_token_ui`: reads current coins (`_coins` cache + `RunManager.get_coins`) and disables buy button if `coins < cost`.

### Purchase/reward/multiplier-related references

- Purchase input path: `UIRoot._on_buy_token_pressed` -> `GameEvents.request_intro_buy_token` -> `RunManager._on_request_intro_buy_token` -> `purchase_token`.
- Reward text path: `BetSystem.build_pact_text` renders COWARD reward as coin text for UI/UX messaging.

## UI Binding

- HUD display: `UIRoot` updates `coins_label` in `_on_coins_changed(coins)`.
- On run start, UI first resets label to `Coins: 0`, then relies on `coins_changed` emission from `RunManager` to show actual value.
- Buy-token panel also reflects coin availability and cost in `_refresh_buy_token_ui`.
- Binding mechanism is event-driven: `UIRoot` connects to `GameEvents.coins_changed` in `_ready()`.

## Final Classification

Coins are currently:

- [x] **Per-run only**
- [ ] Persistent meta currency
- [ ] Hybrid
- [ ] Unused/legacy

Notes:
- Active runtime coins are run-scoped with run-save checkpoint serialization.
- Legacy coin code paths exist under `legacy_runtime/` and are not part of active runtime authority.
