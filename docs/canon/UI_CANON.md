# UI Boundary Model — Level 3

## Phase Containers vs Event Queue Overlays

Level 3 UI distingue esplicitamente tra:

### 1. Phase-driven Containers (Phase_*)

Questi pannelli sono controllati esclusivamente da:

- RunManager._set_phase(...)
- RunManager._emit_ui(payload)
- payload.phase + show_phase(...)

Esempi:

- Phase_INTRO
- Phase_FIRST_REACTION (solo quando phase-driven)
- Phase_MID_CHOICE
- Phase_PUSH_YOUR_LUCK
- Phase_END_RUN

Regola:

La UI non decide la fase.
La UI reagisce al payload.phase autoritativo.


### 2. Event-Queue Overlays (Modal / Ritual UI)

Alcune superfici UI non sono phase containers,
ma overlay attivati tramite eventi e payload "kind".

In Level 3 attuale:

- FIRST_REACTION post-bet messaging utilizza queue/event payload (kind/title/subtitle)
- RESOLUTION ritual utilizza resolve_ritual_opened / resolve_ritual_closed

Questi NON sono guidati da payload.phase,
ma da eventi GameEvents e queue payload.


## Contract Rule

Lo split tra:

- phase containers
- event-driven overlays

è intenzionale e fa parte del contract Level 3.

Non deve essere unificato o refactorizzato
senza task esplicita di redesign.


## Anti-Regression Guardrail

È vietato:

- sostituire overlay event-driven con show_phase(...)
- aprire phase container tramite signal paralleli
- creare doppie vie di apertura per la stessa superficie UI


## Authority Reminder

Solo RunManager può:

- cambiare fase
- emettere payload UI autoritativi

La UI:

- non muta fase
- non prende decisioni di flow
- non apre pannelli phase-driven senza payload

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
- [Run flow payload contract (INTERMEDIATE_CHOICE)](#run-flow-payload-contract-intermediate_choice)
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
**Notes:** Overlaps with: docs/repo_map.md, docs/reports/technical_review_resume_it.md.

## Overlap
- Overlaps with: docs/repo_map.md, docs/reports/technical_review_resume_it.md.

## Scope
- Patch type: Foundation only (no scene-wide texture replacement in this patch).
- Source-of-truth UI asset folder for adopted runtime main-menu atlas source: `res://assets/MainMenu/`.
- `res://UI Official/` remains the raw external reference pack.
- Authoritative theme resource: `res://ui/theme/official_theme.tres`.
- Authoritative UI font wrapper: `res://ui/fonts/italiana_regular_font.tres`.

## Run flow payload contract (INTERMEDIATE_CHOICE)
- `RunManager` remains sole authority for phase progression and emits `RunUiPayload` for `INTERMEDIATE_CHOICE`.
- Active Level 3 contract: `INTERMEDIATE_CHOICE` payload carries both gesture options and a public reaction message via `meta.audience_message`.
- UI remains reactive: it must render the provided payload and must not gate this phase through queue/callback side flows.
- Active runtime UI contract does not expose or emit a post-bet queue completion signal for phase progression authority.

## END_RUN payload contract
- END_RUN payload meta keys are canonical and always emitted by RunManager:
  - `meta.register_message: String` (sempre mostrato)
  - `meta.register_final: bool`
  - `meta.register_ending_key: String` (`""` quando l'aggiornamento non è finale)
  - `meta.next_bet_enabled: bool`
- END_RUN UI map rule (UI-only, reactive):
  - se `meta.register_final=false` → titolo `AGGIORNAMENTO DEL REGISTRO`, icona nascosta/placeholder, Next Bet governato da `meta.next_bet_enabled`
  - se `meta.register_final=true` → titolo+icona derivati da `meta.register_ending_key` (mappa UI-only):
    - `ending_corruption` → `FASCICOLO CHIUSO — COMPROMISSIONE` + `res://assets/ui/icons/icon_ending_corruption.png`
    - `ending_glory` → `FASCICOLO CHIUSO — ASCESA` + `res://assets/ui/icons/icon_ending_glory.png`
    - `ending_scars` → `FASCICOLO CHIUSO — CONSUMO` + `res://assets/ui/icons/icon_ending_scars.png`
    - `ending_pattern` → `FASCICOLO CHIUSO — PATTERN` + `res://assets/ui/icons/icon_ending_pattern.png`
    - fallback titolo `FASCICOLO CHIUSO`; fallback icona `res://assets/ui/icons/icon_condition.png`
- UI must derive END_RUN `Next Bet` visibility/enabled state **only** from `meta.next_bet_enabled` (reactive rule, no local gameplay decision).
- UI must not infer ending category locally: `meta.register_ending_key` is RunManager authority.
- UI must not unlock achievements or perform meta-save side effects: achievements wiring is a RunManager→meta-system side effect only.

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

## Resolution/stretch baseline (UI hardening)
- Project display baseline keeps the existing canonical 16:9 internal viewport (`1280x720`) with `window/stretch/mode="viewport"` and `window/stretch/aspect="keep"` to prevent cross-screen distortion.
- Runtime root UI controls in `res://scenes/Main.tscn` and `res://scenes/UI.tscn` must remain full-rect (`anchor_left/top=0`, `anchor_right/bottom=1`) with expand/fill size flags where applicable for menu/run root containers.
- `res://scenes/UI.tscn` includes an always-on fallback `ColorRect` background at root level to avoid white-screen output when higher UI layers are hidden.

## Theme assignment point (single authority)
- Chosen authority: **ProjectSettings → GUI → Theme → Custom** (`project.godot`, `[gui] theme/custom`).
- Patch decision (active): **assigned** at ProjectSettings level via `project.godot` `[gui] theme/custom="res://ui/theme/official_theme.tres"`.
- Rationale: establish a single fallback theme authority for controls without altering runtime flow authority; per-scene/per-node overrides remain allowed as localized exceptions during migration.
- Runtime visual baseline: `res://ui/theme/official_theme.tres` defines non-empty stylebox entries for `Button` states (`normal`, `hover`, `pressed`, `disabled`) and `PanelContainer.panel` using official stylebox resources.
- Runtime scenes `res://scenes/UI.tscn` and `res://scenes/ui/BettingCircle.tscn` remove local `theme_override_styles/*`, `theme_override_fonts/*`, `theme_override_constants/*`, and `theme_override_colors/*` assignments so controls inherit global theme authority by default.
- Pilot redundancy trim: in `res://scenes/Main.tscn`, main menu buttons `ContinueButton`, `NewGameButton`, and `LoadGameButton` now inherit global `Button` styleboxes from `project.godot` theme authority instead of duplicating identical local `theme_override_styles/*`.

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

## Visual binding audit baseline (placeholder policy)
- Runtime scene audit baseline uses a single known-good placeholder texture resource `res://assets/ui/icons/icon_condition.png` when `TextureRect` bindings are null in active UI scenes.
- Placeholder assignment is scene-local and diagnostic only; it does not introduce additional theme authority and does not alter runtime flow logic.
- `TextureRect.texture` placeholders must be real `Texture2D` resources (PNG/AtlasTexture), never `StyleBox*`.

## Search checklist (where UI assets can hide)
- `.tscn`: `TextureRect` / `NinePatchRect` texture paths.
- Scene-local theme overrides inside `.tscn` files.
- `.tres`: `StyleBoxTexture` / `StyleBoxFlat` and other style resources.
- Scripts with explicit texture loading (`load("res://...png")`, `preload("res://...png")`).

## References used
- `res://UI Official/Reference sheet.png`
- `res://assets/ui/icons/icon_condition.png`
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
- `Phase_INTRO` bet selection contract (L3 active): exactly 2 buttons (`Btn_INTRO_SELECT_WIN`, `Btn_INTRO_SELECT_FAST`) in `BetButtons` with centered HBox layout; UI emits `request_place_bet(bet_id, 0)` using `BetCatalog.level3_bet_ids()` slots `[0]` and `[1]` (no `Btn_INTRO_SELECT_NO_HIT`/third-option wiring).
- Active Level 3 HUD contract excludes legacy XP/level-up/token-progression reactive wiring and related level-up SFX/popup handling.
- Active Level 3 UI↔RunManager contract uses `res://scripts/ui/run_manager_ui_port.gd` as a typed adapter for read-only UI queries, avoiding direct UI-side `has_method` branching while keeping RunManager authority unchanged.
- `res://scripts/ui/ui_root.gd` keeps a small runtime group-ref cache (`run_manager` via adapter, `arena`, `player`) with explicit refresh on `_ready` and run-start handlers; missing refs must still surface as `push_error` (no silent masking).
- During pre-`BET_COMMITTED` phases (`BET_PRESENT` and earlier), missing `arena`/`player` group refs are non-invariant and must not emit ERROR logs; from later phases where those refs are required by runtime wiring, missing refs remain ERROR-level.

Runtime enforcement note (Level 3): enemy health-bar UI wiring/assets are removed from active runtime path (no enemy combat HUD authority).
- Runtime enforcement note (Level 3): player HP UI reactive wiring is removed from active runtime path (no `health_changed`/`get_health` bindings in UIRoot).
- Main menu visual ambience contract: `res://scenes/Main.tscn` includes `MenuLayer/MainMenu/MenuAmbience` with visual-only layered textures (`Base`, `CloudsLayer`, `LightOverlay`, `FelixStatue`, `FlagRoot/Pole`, `FlagRoot/FlagCloth`, `FogLayer_Back`, `FogLayer_Mid`, `FogLayer_Front`, `TorchFlames`) driven by `res://scripts/ui/menu_ambience.gd`; no GameEvents wiring and no flow authority changes are allowed in this node.
- Flag motion contract: only `FlagRoot/FlagCloth` receives wind deformation material; `FlagRoot/Pole` remains static.
- Fog placement and top-band contract: menu fog layers remain constrained to the lower ambience band (no sky coverage), while the upper CloudsLayer remains static on X and applies an intentionally harsh strobing tint effect for degraded visual style.

## UI boot-failure fallback surface (Patch: UX robustness)
- Runtime scene `res://scenes/UI.tscn` includes `UI_RunRoot/Overlays/BootFailOverlay` as a user-facing fallback surface, hidden by default in healthy runs.
- Runtime script `res://scripts/ui/ui_root.gd` performs a UI-side wiring contract check with `has_node()` for critical modal paths (`Modals/BetModal`, `Modals/PactSealedModal`, `Modals/ResolveRitualModal`, `Modals/GameOverModal`) and activates the overlay only if the contract is broken.
- Boot-fail mode is presentation-only: the overlay does not attempt runtime repair, does not call RunManager, and does not mutate phase authority.
- Allowed escape intent is only `GameEvents.request_show_main_menu`; no new `request_*` signals are introduced.

## BettingCircle pact card readability baseline (Patch: minimal UI visibility)
- Runtime scene: `res://scenes/ui/BettingCircle.tscn`.
- Pact option buttons `BetOption1`, `BetOption2`, `BetOption3` use `custom_minimum_size = Vector2(0, 240)` to preserve vertical room for descriptive lines.
- Each bet card root `CardVBox` uses vertical expand/fill (`size_flags_vertical = 3`) so label content consumes available height instead of compressing.
- Descriptive labels `CondannaLabel`, `CondizioneLabel`, `PattoLabel` use smart wrapping (`autowrap_mode = 3`) with `clip_text = false` to avoid silent truncation of pact text.
- `CondannaIcon` remains present but non-dominant (`custom_minimum_size = Vector2(0, 32)`, non-expanding stretch mode), so iconography does not displace label readability.
- Scope guard: this baseline is visual-only and does not change `RunManager`, `GameEvents`, bet payload content, or flow authority.

## Post-bet ritual subtitle contract (Patch L3: remove post-bet text layer)
- `Phase_FIRST_REACTION` (`IL PATTO È SIGILLATO.`) uses a fixed title and an empty subtitle payload; no per-bet subtitle selection layer is active in UI runtime.
- `Phase_RESOLUTION` (`RITO DI GIUDIZIO`) keeps the existing condanna subtitle behavior unchanged.
- Scope guard: this contract removes only legacy post-bet copy selection (`POST_BET_TEXTS`) and does not alter phase/event sequencing authority.

