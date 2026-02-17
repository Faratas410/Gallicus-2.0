# CANON — UI CANON

Status: Single source of truth

If another doc conflicts, this doc wins.

Last merged from: docs/ui_official_ledger.md, docs/ui_audio_map.md, docs/audio_paths.md

## Canon Contract

This document is authoritative for its category.
No other file may redefine these concepts.
All changes to systems described here must update this document in the same PR.


## Index

- [Scope](#scope)
- [Non-negotiable visual rules](#non-negotiable-visual-rules)
- [Theme assignment point](#theme-assignment-point-single-authority)
- [Main menu / idle ambience](#main-menu-idle-ambience)
- [Arena tension](#arena-tension)

## SOURCE: docs/ui_official_ledger.md

# UI Official Ledger (Foundation Patch)

**Status:** CANON  
**Scope:** Official UI asset and theme ledger, including authority and replacement policy.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/repo_map.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/repo_map.md, docs/technical_review_resume_it.md.

## Overlap
- Overlaps with: docs/repo_map.md, docs/technical_review_resume_it.md.

## Scope
- Patch type: Foundation only (no scene-wide texture replacement in this patch).
- Source-of-truth UI asset folder: `res://UI Official/`.
- Authoritative theme resource: `res://ui/theme/official_theme.tres`.
- Authoritative UI font wrapper: `res://ui/fonts/italiana_regular_font.tres`.

## Non-negotiable visual rules
1. **Base UI scale**: UI assets are **1x** and must render pixel-crisp at game resolution (baseline: `UI assets (1x)` reference sheet).
2. **Font rule**: `Italiana-Regular.ttf` is the only official UI font source.
3. **No mixed style**: legacy and official widgets must not be mixed inside a single finalized screen once replacement patches start.

## Import standard (UI Official PNG)
Because this repository does not track per-file `.png.import` files, the closest existing authoritative texture import template is:
- `res://.godot/import_defaults.cfg` (`[importer_defaults] texture=...`).

For UI Official pixel-art UI textures that will be adopted in future replacement patches, preserve these keys from the existing template:
- `flags/filter=false` (nearest, no blur)
- `flags/mipmaps=false` (no mipmaps)
- `compress/mode=0`
- `compress/high_quality=false`
- `compress/lossy_quality=0.7`

Stop-condition note (satisfied): no `.png.import` files are versioned; import defaults above are the canonical tracked template to follow.

## Theme assignment point (single authority)
- Chosen authority: **ProjectSettings → GUI → Theme → Custom** (`project.godot`, `[gui] theme/custom`).
- Patch decision (active): **assigned** at ProjectSettings level via `project.godot` `[gui] theme/custom="res://ui/theme/official_theme.tres"`.
- Rationale: establish a single fallback theme authority for controls without altering runtime flow authority; per-scene/per-node overrides remain allowed as localized exceptions during migration.
- Runtime visual baseline: `res://ui/theme/official_theme.tres` defines non-empty stylebox entries for `Button` states (`normal`, `hover`, `pressed`, `disabled`) and `PanelContainer.panel` using official stylebox resources.
- Runtime scenes `res://scenes/UI.tscn` and `res://scenes/ui/BettingCircle.tscn` remove local `theme_override_styles/*`, `theme_override_fonts/*`, `theme_override_constants/*`, and `theme_override_colors/*` assignments so controls inherit global theme authority by default.

## Replacement mapping tracker (Patch 1 scaffold)

### Buttons (Main Menu pilot)
- Official assets selected:
  - `res://ui/official/atlas/at_button_primary_normal.tres` (`Rect2(0, 160, 48, 16)` from `UI assets (1x).png`)
  - `res://ui/official/atlas/at_button_primary_hover.tres` (`Rect2(48, 160, 48, 16)`)
  - `res://ui/official/atlas/at_button_primary_pressed.tres` (`Rect2(96, 160, 48, 16)`)
  - `res://ui/official/atlas/at_button_primary_disabled.tres` (`Rect2(0, 160, 48, 16)`, muted via `modulate_color`)
- Applied on scene: `res://scenes/Main.tscn` main menu buttons (`ContinueButton`, `NewGameButton`, `LoadGameButton`, `AchievementsButton`, `SettingsButton`, `CreditsButton`) through local `theme_override_styles/*`.
- Legacy references replaced: removed main-menu dependency on `res://assets/ui/gallicus_ui_theme.tres` for button rendering in this scene.

### Panels / Background boxes (Main Menu pilot)
- Official assets selected:
  - `res://ui/official/atlas/at_panel_main.tres` (`Rect2(0, 0, 48, 48)` from `UI assets (1x).png`)
- Applied on scene: `res://scenes/Main.tscn` node `MenuLayer/MainMenu/CenterContainer/MainPanel` via `res://ui/official/styleboxes/sb_panel_main.tres`.
- Legacy references replaced: no legacy panel texture remained on the visible main menu root container (new `MainPanel` is official atlas-backed).

### Banners / Dividers
- Official assets selected: _TBD_
- Legacy references to replace: _TBD_
- Notes: _TBD_

### Checkboxes / Sliders
- Official assets selected: _TBD_
- Legacy references to replace: _TBD_
- Notes: _TBD_

### Icons (if used)
- Official assets selected: _TBD_
- Legacy references to replace: _TBD_
- Notes: _TBD_

### Gallicus-special widgets (bet/choice UI, etc.)
- Official assets selected: _TBD_
- Legacy references to replace: _TBD_
- Notes: _TBD_

## Search checklist (where UI assets can hide)
- `.tscn`: `TextureRect` / `NinePatchRect` texture paths.
- Scene-local theme overrides inside `.tscn` files.
- `.tres`: `StyleBoxTexture` / `StyleBoxFlat` and other style resources.
- Scripts with explicit texture loading (`load("res://...png")`, `preload("res://...png")`).

## References used
- `res://UI Official/Reference sheet.png`
- `res://UI Official/UI assets (1x).png`
- `res://UI Official/Italiana-Regular.ttf`

## SOURCE: docs/ui_audio_map.md

# UI Audio Map

**Status:** SUPPORTING  
**Scope:** UI-to-audio mood mapping for menu, arena, boss, and ending phases.  
**Source of truth:** docs/audio_paths.md, docs/ui_official_ledger.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/audio_paths.md.

## Overlap
- Overlaps with: docs/audio_paths.md.

## Main menu / idle ambience
- Ambient2.mp3
- Ambient4.mp3
- Darkness.mp3

## Arena tension
- HellfireEchoes.mp3
- Infernal.mp3
- Doomfire.mp3

## Boss / escalation
- TyrantsOfHell.mp3
- MarchOfDemonicLegions.mp3
- ApocalypticCarnage.mp3

## End run / verdict
- LamentOfTheFallen.mp3
- ScreamsFromTheVoid.mp3

## Credits
- CreditsOrCutscene1.mp3
- PianoMarch.mp3

## SOURCE: docs/audio_paths.md

# Audio path hygiene

**Status:** SUPPORTING  
**Scope:** Canonical runtime audio path policy and tracked Music assets.  
**Source of truth:** docs/repo_map.md, docs/ui_audio_map.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/ui_audio_map.md.

## Overlap
- Overlaps with: docs/ui_audio_map.md.

Canonical runtime audio location: `res://Music/`.

Rules:
- All runtime audio references must use `res://Music/<file>.mp3`.
- Root-level references like `res://<file>.mp3` are not allowed.
- This patch does not move or rename audio binaries; it only documents canonical paths.

Current MP3 files under `res://Music/`:
- AbyssalEcho.mp3
- Ambient1.mp3
- Ambient2.mp3
- Ambient3.mp3
- Ambient4.mp3
- Ambient5.mp3
- Ambient6.mp3
- ApocalypticCarnage.mp3
- ClassicScream.mp3
- CreditsOrCutscene1.mp3
- DamnedSouls.mp3
- Darkness.mp3
- DemonicOverture.mp3
- Diabolic.mp3
- Doomfire.mp3
- EclipseOfSouls.mp3
- EternalDescent.mp3
- Havoc.mp3
- HellfireEchoes.mp3
- Infernal.mp3
- LamentOfTheFallen.mp3
- MarchOfDemonicLegions.mp3
- Necroverse.mp3
- PianoMarch.mp3
- RageRequiem.mp3
- RagingInferno.mp3
- ScreamsFromTheVoid.mp3
- Tormentor.mp3
- TyrantsOfHell.mp3
- VoidSerpent.mp3


## Run/HUD sprite-backed overlay labels (Patch 2 scope)
- Runtime scene `res://scenes/UI.tscn` keeps button sprite states from Patch 1 and extends sprite-backed presentation to high-visibility runtime overlays by wrapping labels in `PanelContainer` nodes using existing official atlas styleboxes already present in the scene (`StyleBoxTexture_1`).
- Wrapped runtime labels: arena resolution, audience context, register annotation, arena theme title/subtitle, countdown, and fast-countdown.
- Binding contract: `res://scripts/ui/ui_root.gd` remains the only authority for toggling these nodes; when a wrapped label visibility changes, the matching wrapper panel visibility must change in the same branch.
- HUD includes a sprite-backed `GloryPanel` with numeric `GloryValueLabel` at `HUD/SafeMargin/TopRow/LeftColumn/GloryPanel/...`; UI updates it reactively from RunManager-emitted state payloads without adding gameplay authority to UI.
- `Phase_INTRO` Level 3 contract excludes upgrade-token shop controls: no BUY TOKEN button/panel, no token-cost lookup, and no token purchase request emission from `res://scripts/ui/ui_root.gd`.
- Active Level 3 HUD contract excludes legacy XP/level-up/token-progression reactive wiring and related level-up SFX/popup handling.

Runtime enforcement note (Level 3): enemy health-bar UI wiring/assets are removed from active runtime path (no enemy combat HUD authority).
- Runtime enforcement note (Level 3): player HP UI reactive wiring is removed from active runtime path (no `health_changed`/`get_health` bindings in UIRoot).
