# Gallicus — Repository Map (Effective)

**Status:** SUPPORTING (inventory map, not canon owner).  
**Purpose:** Current repository layout and ownership boundaries aligned with canon.  
**Canonical references:**
- `docs/canon/FOUNDATIONS.md`
- `docs/canon/PROCESS_AND_FREEZE.md`
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/MECHANICS_UNIFIED.md`
- `docs/canon/GLOSSARY_ENTITIES.md`
- `docs/canon/LORE_UNIFIED.md`
- `docs/canon/UI_CANON.md`
- `docs/canon/REGISTRY_SYSTEM_SPEC.md`
- `docs/canon/REGISTRY_ERA_CHRONICLE.md`
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
- `assets/` — Runtime art/audio/UI assets used by scenes/scripts.
- `data/` — Gameplay data registries (bets, arena themes, verdict lines, condanne).
- `docs/` — Canon, support, reports, and archive documentation.
- `tools/` — Developer tooling and CI helper scripts.
- `.github/workflows/godot_smoke_runtime.yml` — canonical Linux CI signoff workflow for import/runtime smoke evidence.

## Ignored local/generated roots
- `.godot/` — Godot editor/import cache metadata; never source authority.
- `artifacts/` — local/CI smoke output; never source authority.
- `.tmp_ci_logs/` — downloaded CI logs; local diagnostics only.
- `.tmp_smoke/` — local smoke scratch output.
- `tools/godot/` — downloaded Godot binary cache for tooling.
- `export_templates/`, `feature_profiles/`, `script_templates/`, `text_editor_themes/` — local Godot editor customization roots; track only if intentionally populated.

## Active runtime structure (`res://`)

### Scenes (`scenes/`)
- Core:
  - `Main.tscn` (entry)
  - `Arena.tscn`
  - `UI.tscn` (HUD includes sprite-backed `GloryPanel/GloryValueLabel` bound by `scripts/ui/ui_root.gd`)
- Entities/UI scenes:
  - `ui/BettingCircle.tscn`

### Scripts (`scripts/`)
- Scene-bound runtime scripts:
  - `scenes/arena/arena.gd`
  - `scenes/arena/arena_tilemap.gd`
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
- Audio/runtime support:
  - `audio/music_director.gd`
- Content/entities:
  - `content/scar_catalog.gd`
  - `content/bet_catalog.gd`

### Data (`data/`)
- `arena_themes.gd`
- `bets.gd`
- `condanne.gd`
- `ending_rules.gd`
- `verdict_lines.gd`

### Assets (`assets/`)
- Audio:
  - `audio/` (runtime music library)
- Gameplay/art domains:
  - `backgrounds/` (includes `backgrounds/arena/variants/`)
  - `tiles/`
  - `i18n/`
- Runtime UI assets:
  - `MainMenu/` (menu ambience textures)
  - `ui/fonts/`
  - `ui/icons/`
  - `ui/theme/official_theme.tres`
  - `ui/official/` (runtime theme/stylebox/material resources)
  - `ui/official_source/` (raw UI source pack textures/fonts used by runtime resources)
  - `ui/shaders/menu/`

## Documentation structure (`docs/`)
- `canon/` — authoritative ownership docs only.
- `contracts/` — technical support contracts consumed by tooling.
- `support/` — maps, operator indexes, and non-canonical support references.
- `reports/` — current report surface.
- `archive/` — historical reports and retired support material.

## Legacy / non-active runtime areas
- `legacy-runtime/` directory is no longer present in the repository; legacy gameplay artifacts were removed from active storage.
- No active asset roots remain outside `assets/`.
- `docs/archive/` is historical only and must not be treated as active canon/support input unless explicitly requested.
- `legacy:risk_driven_design_bible` is archived at `docs/archive/lineage/00_RISK_DRIVEN_DESIGN_BIBLE.md` and is not an operational source.

## Documentation governance alignment
- This file is an **inventory map** and does not redefine gameplay/runtime canon.
- Canon ownership follows `docs/canon/CANON_DEPENDENCY_MATRIX.md`.
- Active docs must reference existing `docs/...` paths. Retired merged sources use `legacy:<slug>` lineage markers instead of missing file paths.
- If runtime authority changes, update `docs/canon/RUN_ARCHITECTURE_CANON.md` in the same patch.
- If gameplay rules change, update `docs/canon/MECHANICS_UNIFIED.md` in the same patch.
- If UI behavior contracts change, update `docs/canon/UI_CANON.md` in the same patch.
- If process/freeze policy changes, update `docs/canon/PROCESS_AND_FREEZE.md` in the same patch.
