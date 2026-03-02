# Gallicus — Repository Map (Effective)

**Status:** SUPPORTING (inventory map, not canon owner).  
**Purpose:** Current repository layout and ownership boundaries aligned with canon.  
**Canonical references:**
- `docs/canon/PROCESS_AND_FREEZE.md`
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/MECHANICS_UNIFIED.md`
- `docs/canon/UI_CANON.md`
- `docs/canon/CANON_DEPENDENCY_MATRIX.md`

## Runtime invariants snapshot
- Engine: **Godot 4.6**
- Entry scene: `res://scenes/Main.tscn`
- Single flow authority: `res://scripts/systems/run_manager.gd` (group `run_manager`)
- Global event authority: `res://scripts/systems/game_events.gd` (`GameEvents` autoload)
- Allowed runtime groups: `run_manager`, `arena`, `player`, `enemies`
- Level 3 run payload runtime fields: `arena_index`, `coins`, `corruption`, `upgrades` (`corruption` capped at 100).
- Level 3 RunState serialized Scar runtime fields: `scar_double_count`, `scar_pact_count`, `volatility`, `scar_rng_state`, `scar_roll_index`, `last_pact_corruption_arena_index`, `last_pact_corruption_bet_id`.
- Active Level 3 runtime authority excludes combat/health/enemy gameplay systems; arena/player/enemies groups remain reserved labels for visual/passive runtime wiring only.

## Top-level repository layout
- `project.godot` — Godot project configuration.
- `scenes/` — Runtime scenes used by the active game flow.
- `scripts/` — Runtime gameplay/UI/system scripts.
- `assets/` — Runtime art/audio-support assets used by scenes/scripts.
- `data/` — Gameplay data registries (bets, arena themes, verdict lines, condanne).
- `docs/` — Canon + supporting technical/design documentation.
- `tools/` — Developer tooling and CI helper scripts.
- `ui/` — External UI resource pack (separate from active `assets/ui/` runtime path).
- `Music/` — Audio files repository.
- `UI Official/` — Raw reference asset collection.
- `.godot/` — Godot editor/import cache metadata.

## Active runtime structure (`res://`)

### Scenes (`scenes/`)
- Core:
  - `Main.tscn` (entry)
  - `Arena.tscn`
  - Player avatar removed in Level 3 (ritual board)
  - `UI.tscn` (HUD includes sprite-backed `GloryPanel/GloryValueLabel` bound by `scripts/ui/ui_root.gd`)
- Arena variants:
  - `arenas/Arena_01_TrainingYard.tscn`
  - `arenas/Arena_02_OwlSanctum.tscn`
  - `arenas/Arena_03_SandPit.tscn`
  - `arenas/Arena_04_IronCorridor.tscn`
- Entities/UI scenes:
  - `ui/BettingCircle.tscn`

### Scripts (`scripts/`)
- Root gameplay nodes:
  - `Arena.gd`
  - Legacy avatar script removed in Level 3 (ritual board)
  - `arena_tilemap.gd`
- Systems:
  - `systems/run_manager.gd` (single run flow authority)
  - `systems/game_events.gd` (global event bus authority)
  - `systems/save_manager.gd`
  - `systems/constants.gd`
  - `systems/run/`
    - `run_state.gd`
    - `bet_system.gd`
    - `outcome_system.gd`
    - `scar_system.gd`
    - `save_system.gd`
    - `flow_logger.gd`
    - `runstate_kernel.gd`
    - `scar_policy.gd`
- UI (reactive layer):
  - `ui/ui_root.gd`
  - `ui/main_menu.gd`
  - `ui/betting_circle_ui.gd`
  - `ui/run_ui_payload.gd`
- Content/entities:
  - `content/scar_catalog.gd`

### Data (`data/`)
- `arena_themes.gd`
- `bets.gd`
- `condanne.gd`
- `verdict_lines.gd`

### Assets (`assets/`)
- Gameplay/art domains:
  - `arenas/`
  - `backgrounds/` (includes `backgrounds/arena/variants/`)
  - `sprites/`
  - `tiles/`
  - `fx/`
  - `i18n/`
- Runtime UI assets:
  - `MainMenu/` (main menu texture atlas source pack)
  - `ui/gallicus_ui_theme.tres`
  - `ui/fonts/` (includes `grabstein_gotik.otf` and `.tres` font resources)
  - `ui/icons/`, `ui/dividers/`, `ui/overlays/`, `ui/panels/`

## Legacy / non-active runtime areas
- `legacy-runtime/` directory is no longer present in the repository; legacy gameplay artifacts were removed from active storage.
- `UI Official/` is an external asset library and not part of canonical runtime authority.
- `ui/` (root-level) is a resource bundle separate from `assets/ui/` and should not be treated as implicit runtime authority without explicit scene/script wiring.

## Documentation governance alignment
- This file is an **inventory map** and does not redefine gameplay/runtime canon.
- Canon ownership follows `docs/canon/CANON_DEPENDENCY_MATRIX.md`.
- If runtime authority changes, update `docs/canon/RUN_ARCHITECTURE_CANON.md` in the same patch.
- If gameplay rules change, update `docs/canon/MECHANICS_UNIFIED.md` in the same patch.
- If UI behavior contracts change, update `docs/canon/UI_CANON.md` in the same patch.
- If process/freeze policy changes, update `docs/canon/PROCESS_AND_FREEZE.md` in the same patch.
