# Asset Audit and Safe Migration Report

## 1 VERIFY-FIRST
- Total asset count: 674
- Duplicate hash clusters: 2
- Zero-static-reference assets remaining: 636 (mostly external UI pack files and HOLD candidates).
- Suspicious directory structures: `assets/ui` vs `ui`, and `UI Official` external pack path.
- Runtime critical assets checked: `scenes/Main.tscn`, `scenes/UI.tscn`, `assets/ui/gallicus_ui_theme.tres`.

## 2 ASSET INVENTORY SUMMARY
- Full table: `docs/reports/asset_inventory_summary.tsv` (path, type, family, size, hash, reference count).

## 3 DUPLICATION CLUSTERS
### Cluster 1 (hash `9ceff34d405527478a52c006e5c0315a775d51ff5a16bb015746f390536277a6`)
- `assets/ui/fonts/font_body.tres` (refs: 2)
- `assets/ui/fonts/font_title_outline.tres` (refs: 2)
- `ui/fonts/italiana_regular_font.tres` (refs: 1)

### Cluster 2 (hash `180571e61f1224bda5a617a313f0d7932254ff34cb323a495111e51d66e4763b`)
- `ui/official/atlas/at_button_primary_disabled.tres` (refs: 0)
- `ui/official/atlas/at_button_primary_normal.tres` (refs: 0)

## 4 MIGRATION PLAN
- Canonical selection for removed legacy gameplay placeholders: none required; assets were standalone unreferenced sprites/fx.
- Deleted obsolete unreferenced files under `assets/sprites/` and `assets/fx/` after static reference verification.
- No runtime scene/resource references required updates because deleted files had zero references in `.tscn/.tres/.res/.gd` scan.
- Remaining non-referenced assets in external packs remain HOLD unless explicitly approved for pack-wide pruning.

## 5 PATCH PROPOSAL
- Objective: final pass removing clearly obsolete, unreferenced local gameplay placeholder assets.
- Files moved: 0.
- References updated: none needed.
- Duplicates archived: 0.
- Duplicates/obsolete deleted: 18 (`assets/fx/particles_dust.png` + 17 files in `assets/sprites/`).

## 6 PATCH REPORT
- FAST LANE: Asset governance cleanup.
- Zone: Flexible Domain (asset wiring / static resources).
- Change Type: Non-runtime obsolete asset deletion.
- Behavioral Impact: None expected.
- Canon Impact: Tightens canonical runtime set by removing dead placeholder assets.
- Files Moved: 0
- Files Archived: 0
- Files Deleted: 18
- Files Held: non-referenced assets in external UI pack and uncertain dynamic-use candidates.

## 7 ACCEPTANCE CRITERIA
- No broken references in scanned Godot text resources.
- Entry scene remains `res://scenes/Main.tscn` (unchanged).
- No runtime-referenced asset deleted.
- Each touched asset family has a canonical source of truth.

## 8 STOP CONDITIONS
- Dynamic reference uncertainty: mitigated by limiting deletion to hash-stable, standalone placeholders with zero static references.
- No runtime logic/scripts modified.
