# UI Sprite Assignment Audit (Global)

## Summary

* Total scenes scanned: 15
* Non-compliant Buttons: 0
* Non-compliant Labels/RichTextLabels: 0
* Runtime factory gaps: 2

## Scenes — Main/Menu Scope

* No non-compliant scene nodes found.

## Scenes — Run/HUD Scope

* No non-compliant scene nodes found.

## Scenes — Popups/Overlays

* No non-compliant scene nodes found.

## Scenes — Other/Secondary Screens

* No non-compliant scene nodes found.

## Runtime Factory Gaps

* scripts/ui/main_menu.gd::_create_condanna_entry_panel — creates Label at runtime outside scripts/ui/ui_root.gd (wrapped in PanelContainer with sb_panel_main); reachable from scripts/ui/main_menu.gd::_build_condanne_list
* scripts/ui/main_menu.gd::_create_museo_entry_panel — creates Label at runtime outside scripts/ui/ui_root.gd (wrapped in PanelContainer with sb_panel_main); reachable from scripts/ui/main_menu.gd::_add_museo_header and scripts/ui/main_menu.gd::_add_museo_item
