# Gallicus — Repo Map

**Status:** CANON  
**Scope:** Authoritative repository map and system ownership overview for runtime and UI.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/run_architecture_ledger.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/runtime_architecture_split.md, docs/technical_review_resume_it.md.

## Overlap
- Overlaps with: docs/runtime_architecture_split.md, docs/technical_review_resume_it.md.

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
  - **run/** (modular run-domain systems)
    - `run_state.gd`, `bet_system.gd`, `outcome_system.gd`, `scar_system.gd`, `save_system.gd`
- **ui/** (UI logic: `ui_root.gd`, `main_menu.gd`, `betting_circle_ui.gd`, `enemy_health_bar.gd`)
  - `run_ui_payload.gd` (reactive UI payload contract from RunManager)
- **content/** (run content catalogs / lookup only)
  - `scar_catalog.gd`
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

## Architecture docs
- `res://docs/run_architecture_ledger.md` (run modular boundaries, authority, and phase-add checklist)
