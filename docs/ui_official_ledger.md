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
- Patch 1 decision: **deferred assignment** to avoid immediate broad visual churn while legacy per-scene overrides are still present.
- Rationale: `Main.tscn` and `UI.tscn` currently contain scene/theme overrides and per-node theme overrides; assignment will be performed in a later controlled replacement patch.

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
