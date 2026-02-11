# Runtime Architecture Split (Phase 3)

## Runtime L3 (active path)

Runtime L3 includes the active boot and orchestration path used by the game flow:

- `res://scenes/Main.tscn`
- `res://scripts/systems/run_manager.gd` (single RunManager)
- `res://scripts/systems/game_events.gd` (Autoload event bus)
- Active UI scenes/scripts under `res://scenes/ui/` and `res://scripts/ui/`
- L3 visual core kept in active path:
  - `res://scripts/Arena.gd`
  - `res://scripts/Player.gd`
  - `res://scripts/entities/enemy_basic.gd`

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
