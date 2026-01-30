# Gallicus — Repo Map

**Last updated:** 2026-01-30

## Project Invariants (Golden Checklist snapshot)
- **Engine:** Godot 4.6
- **Language:** strict typed GDScript
- **Warnings = Errors:** zero warnings allowed
- **Entry point:** `res://scenes/Main.tscn`
- **Single RunManager:** `res://scripts/systems/run_manager.gd` (group: `run_manager`)
- **Allowed node groups:** `run_manager`, `arena`, `player`, `enemies`
- **Global events:** **only** via `GameEvents` autoload (`res://scripts/systems/game_events.gd`)

## Canonical entry points
- **Main scene:** `res://scenes/Main.tscn`
  - Instantiates **RunManager** (`res://scripts/systems/run_manager.gd`), **UI** (`res://scenes/UI.tscn`), and main menu layer (`res://scripts/ui/main_menu.gd`).
- **RunManager:** `res://scripts/systems/run_manager.gd`
  - Single authoritative state machine for run flow.

## Folders & responsibilities
### `res://assets/`
- **arenas/** (arena art assets)
- **backgrounds/** (includes `backgrounds/arena/`)
- **fx/** (VFX)
- **sprites/**
- **tiles/**
- **ui/**
  - **dividers/**, **icons/**, **overlays/**, **panels/**
  - **fonts/** (OTF font + UI font assets)

### `res://scenes/`
Core scenes (examples):
- `Main.tscn`
- `UI.tscn`
- `Arena.tscn`
- `Player.tscn`
- `arenas/Arena_01_TrainingYard.tscn`
- `arenas/Arena_02_OwlSanctum.tscn`
- `arenas/Arena_03_SandPit.tscn`
- `arenas/Arena_04_IronCorridor.tscn`
- `enemies/EnemyBasic.tscn`
- `ui/BettingCircle.tscn`
- `ui/EnemyHealthBar.tscn`
- `pickups/Pickup_Coins.tscn`

### `res://scripts/`
- **systems/** (core systems)
  - `run_manager.gd`
  - `game_events.gd` (autoload event bus)
  - `bet_manager.gd`, `save_manager.gd`, `constants.gd`
- **ui/** (UI logic: `ui_root.gd`, `main_menu.gd`, `betting_circle_ui.gd`, `enemy_health_bar.gd`)
- **entities/** (`enemy_basic.gd`)
- **pickups/** (`Pickup.gd`, `PickupSpawner.gd`)
- **legacy/** (legacy scripts, see Deprecation)
- Root scripts: `Arena.gd`, `Player.gd`, `arena_tilemap.gd`

### `res://data/`
- Registries/configs: `arena_themes.gd`, `bets.gd`, `condanne.gd`, `verdict_lines.gd`

## UI & Font policy
- **Theme (UI):** `res://assets/ui/gallicus_ui_theme.tres`
- **Font policy:** single OTF font `res://assets/ui/fonts/grabstein_gotik.otf`.
  - No bitmap fonts (`.fnt` / `.png`) for text rendering.

## Deprecation / Legacy
- `res://scenes/legacy/` and `res://scripts/legacy/` are **not referenced by the entry point** (`Main.tscn`).
