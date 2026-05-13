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
- Resolve ritual overlay (container `Phase_RESOLUTION`) utilizza resolve_ritual_opened / resolve_ritual_closed

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

Last merged from: legacy:ui_official_ledger, legacy:ui_audio_map, legacy:audio_paths

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

## SOURCE: legacy:ui_official_ledger

# UI Official Ledger (Foundation Patch)

**Status:** CANON  
**Scope:** Official UI asset and theme ledger, including authority and replacement policy.  
**Legacy source lineage:** legacy:CODEX_GOLDEN_CHECKLIST, docs/support/repo_map.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/support/repo_map.md.

## Overlap
- Overlaps with: docs/support/repo_map.md.

## Scope
- Patch type: Foundation only (no scene-wide texture replacement in this patch).
- Source-of-truth UI asset folder for adopted runtime main-menu atlas source: `res://assets/MainMenu/`.
- `res://assets/ui/official_source/` remains the raw external reference pack.
- `res://assets/ui/third_party/rpg_ui_pack/` contains purchased RPG UI Pack candidate/reference material; it is not authoritative runtime UI until a later explicit wiring patch adopts specific assets.
- Authoritative theme resource: `res://assets/ui/theme/official_theme.tres`.
- Authoritative UI font wrapper: `res://assets/ui/fonts/italiana_regular_font.tres`.

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
  - se `meta.register_final=false` -> titolo `AGGIORNAMENTO DEL REGISTRO`, icona nascosta/placeholder, Next Bet governato da `meta.next_bet_enabled`
  - se `meta.register_final=true` -> titolo derivato da `meta.register_ending_key` (mappa UI-only):
    - `ending_corruption` -> `FASCICOLO CHIUSO - COMPROMISSIONE`
    - `ending_glory` -> `FASCICOLO CHIUSO - ASCESA`
    - `ending_scars` -> `FASCICOLO CHIUSO - CONSUMO`
    - `ending_pattern` -> `FASCICOLO CHIUSO - PATTERN`
    - fallback titolo `FASCICOLO CHIUSO`
  - Ending icons currently use the tracked fallback `res://assets/ui/icons/icon_condition.png`; dedicated ending icons are deferred until real assets exist.
- UI must derive END_RUN `Next Bet` visibility/enabled state **only** from `meta.next_bet_enabled` (reactive rule, no local gameplay decision).
- UI must not infer ending category locally: `meta.register_ending_key` is RunManager authority.
- UI must not unlock achievements or perform meta-save side effects: achievements wiring is a RunManager -> meta-system side effect only.

## Non-negotiable visual rules
1. **Base UI scale**: active UI theme assets are texture-backed resources selected from the tracked Wooden UI source pack and must render pixel-crisp at game resolution.
2. **Font rule**: `Italiana-Regular.ttf` is the only official UI font source.
3. **No mixed style**: legacy and official widgets must not be mixed inside a single finalized screen once replacement patches start.

## Import standard (UI PNG)
The active source pack is tracked at:
- `res://assets/ui/official_source/Wooden_UI_png/`
- `res://assets/ui/third_party/rpg_ui_pack/` is staged third-party source/reference material only. Keep imports versioned for tracked PNG/TTF files, but do not treat examples as runtime scene authority.
- Runtime adoption exception: settings sliders may use extracted, isolated derivatives under `res://assets/ui/third_party/rpg_ui_pack/extracted/settings/`; these are visual-only controls and do not redefine the global UI theme.

For UI pixel-art textures that are adopted into runtime resources, keep the generated `.png.import` sidecar versioned with the source `.png`. The `.godot/` import cache remains ignored and must not be used as a contract surface.

For source UI textures adopted in future replacement patches, preserve these import settings:
- `flags/filter=false` (nearest, no blur)
- `flags/mipmaps=false` (no mipmaps)
- `compress/mode=0`
- `compress/high_quality=false`
- `compress/lossy_quality=0.7`

Stop-condition note (active): version `.png.import` sidecars only for tracked source assets that are intended to remain runtime-loadable. Do not keep import sidecars for deleted or archive-only legacy PNGs.

## Resolution/stretch baseline (UI hardening)
- Project display baseline keeps the existing canonical 16:9 internal viewport (`1280x720`) with `window/stretch/mode="viewport"` and `window/stretch/aspect="keep"` to prevent cross-screen distortion.
- Runtime root UI controls in `res://scenes/Main.tscn` and `res://scenes/UI.tscn` must remain full-rect (`anchor_left/top=0`, `anchor_right/bottom=1`) with expand/fill size flags where applicable for menu/run root containers.
- `res://scenes/UI.tscn` includes an always-on fallback `ColorRect` background at root level to avoid white-screen output when higher UI layers are hidden.

## Theme assignment point (single authority)
- Chosen authority: **ProjectSettings -> GUI -> Theme -> Custom** (`project.godot`, `[gui] theme/custom`).
- Patch decision (active): **assigned** at ProjectSettings level via `project.godot` `[gui] theme/custom="res://assets/ui/theme/official_theme.tres"`.
- Rationale: establish a single fallback theme authority for controls without altering runtime flow authority; per-scene/per-node overrides remain allowed as localized exceptions during migration.
- Runtime visual baseline: `res://assets/ui/theme/official_theme.tres` defines non-empty stylebox entries for `Button` states (`normal`, `hover`, `pressed`, `disabled`) and `PanelContainer.panel` using official stylebox resources.
- Runtime scenes `res://scenes/UI.tscn` and `res://scenes/ui/BettingCircle.tscn` remove local `theme_override_styles/*`, `theme_override_fonts/*`, `theme_override_constants/*`, and `theme_override_colors/*` assignments so controls inherit global theme authority by default.
- Pilot redundancy trim: in `res://scenes/Main.tscn`, main menu buttons `ContinueButton`, `NewGameButton`, and `LoadGameButton` now inherit global `Button` styleboxes from `project.godot` theme authority instead of duplicating identical local `theme_override_styles/*`.

## Replacement mapping tracker

### Buttons (Main Menu pilot)
- Active wooden assets:
  - `res://assets/ui/official_source/Wooden_UI_png/plank_13.png` via `res://assets/ui/official/styleboxes/sb_button_primary_normal.tres`
  - `res://assets/ui/official_source/Wooden_UI_png/plank_15.png` via `res://assets/ui/official/styleboxes/sb_button_primary_hover.tres`
  - `res://assets/ui/official_source/Wooden_UI_png/plank_14.png` via `res://assets/ui/official/styleboxes/sb_button_primary_pressed.tres`
  - `res://assets/ui/official_source/Wooden_UI_png/plank_16.png` via `res://assets/ui/official/styleboxes/sb_button_primary_disabled.tres`
- Applied through global theme/stylebox references, not runtime logic.
- Legacy references replaced: primary buttons no longer depend on the previous atlas button slices.

### Panels / Background boxes (Main Menu pilot)
- Active wooden asset:
  - `res://assets/ui/official_source/Wooden_UI_png/bg_01_02.png` via `res://assets/ui/official/styleboxes/sb_panel_main.tres`
- Applied through the shared panel stylebox so existing scenes inherit the visual pass.
- Runtime backgrounds are intentionally out of scope for the wooden UI import pass.

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
- Active wooden assets:
  - `res://assets/ui/official_source/Wooden_UI_png/book.png` for `res://scenes/ui/BettingCircle.tscn`
  - `res://assets/ui/official_source/Wooden_UI_png/book_closed_cover.png` for the player-confirmed betting-circle intro state
  - `res://assets/ui/official_source/Wooden_UI_png/plank_13.png`, `plank_15.png`, `plank_14.png`, and `plank_16.png` for betting-circle sign buttons
- Legacy references replaced: `Spellbook & Tabs` PNG assets are no longer part of active runtime scenes.
- Notes: runtime behavior remains UI-presentational; RunManager flow authority is unchanged.

## Visual binding audit baseline (placeholder policy)
- Runtime scene audit baseline uses a single known-good placeholder texture resource `res://assets/ui/icons/icon_condition.png` when `TextureRect` bindings are null in active UI scenes.
- Placeholder assignment is scene-local and diagnostic only; it does not introduce additional theme authority and does not alter runtime flow logic.
- `TextureRect.texture` placeholders must be real `Texture2D` resources (PNG/AtlasTexture), never `StyleBox*`.

## Search checklist (where UI assets can hide)
- `.tscn`: `TextureRect` / `NinePatchRect` texture paths.
- Scene-local theme overrides inside `.tscn` files.
- `.tres`: `StyleBoxTexture` / `StyleBoxFlat` and other style resources.
- Scripts with explicit texture loading (`load(...)`, `preload(...)`).

## References used
- `res://assets/ui/icons/icon_condition.png`
- `res://assets/ui/official_source/Italiana-Regular.ttf`
- `res://assets/ui/official_source/Wooden_UI_png/README.md`

## SOURCE: legacy:ui_audio_map

# UI Audio Map

**Status:** SUPPORTING  
**Scope:** UI-to-audio mood mapping for menu, arena, boss, and ending phases.  
**Legacy source lineage:** legacy:audio_paths, legacy:ui_official_ledger  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: legacy:audio_paths.

## Overlap
- Overlaps with: legacy:audio_paths.

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

## SOURCE: legacy:audio_paths

# Audio path hygiene

**Status:** SUPPORTING  
**Scope:** Canonical runtime audio path policy and tracked Music assets.  
**Legacy source lineage:** docs/support/repo_map.md, legacy:ui_audio_map  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: legacy:ui_audio_map.

## Overlap
- Overlaps with: legacy:ui_audio_map.

Canonical runtime audio location: `res://assets/audio/`.

Rules:
- All runtime audio references must use `res://assets/audio/<file>.mp3`.
- Root-level references like `res://<file>.mp3` are not allowed.
- This patch does not move or rename audio binaries; it only documents canonical paths.

Current MP3 files under `res://assets/audio/`:
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
- Player-facing pressure contract: the only numeric pressure meter shown to players is `PRESSIONE X/10`, sourced from RunManager `RunState.escalation_level` via `GameEvents.escalation_changed(level, max_value)`.
- Pressure HUD placement is the bottom `HUD/PressureRail`, not the top-left stat stack; the meter should read as ritual risk feedback, not debug telemetry.
- `RunState.audience_pressure` remains runtime-internal push-your-luck policy state. It must not be presented as numeric `Pressione` in HUD, Push Your Luck, or END_RUN surfaces.
- Player-facing text follows `docs/canon/GLOSSARY_ENTITIES.md`: `run`, `escalation`, `cashout`, and `double` remain technical terms; visible UI copy should use `percorso`, `pressione`, `incassa/incasso`, and `rilancia`/button `RADDOPPIA`.
- Pressure presentation thresholds are UI-only labels: `0-2` under control, `3-5` warming crowd, `6-8` high risk, `9-10` out of control. These labels do not define gameplay rules.
- Push Your Luck must show current `PRESSIONE X/10` plus the threshold label and must describe `RADDOPPIA` as `Pressione +1`; `INCASSA` must state that it closes/records the result.
- END_RUN must show peak pressure as `Pressione massima: X/10`, derived from run stats `max_escalation` when available.
- Motion Contract:
  - UI motion is presentational-only; it must not emit `GameEvents`, mutate run state, or create phase authority.
  - Motion helpers in `res://scripts/ui/ui_root.gd` are local UI helpers and must not block outbound gameplay intents.
  - Button intent handlers must not `await` animation before emitting `request_*` signals.
  - Standard modal motion kinds are `standard`, `ritual`, and `ending`; ritual motion is reserved for pact, resolve, intermediate choice, Push Your Luck, and END_RUN surfaces.
  - Betting-circle book reveal is player-confirmed: the closed-book intro exposes only `APRI`, and the open animation remains presentational-only with no `GameEvents` emission.
  - Shake/glitch/flash remain bounded to existing ritual or quick-cut feedback surfaces, not generic hover states.
- `Phase_INTRO` Level 3 contract excludes upgrade-token shop controls: no BUY TOKEN button/panel, no token-cost lookup, and no token purchase request emission from `res://scripts/ui/ui_root.gd`.
- `Phase_INTRO` bet selection contract (L3 active): exactly 2 buttons (`Btn_INTRO_SELECT_WIN`, `Btn_INTRO_SELECT_FAST`) in `BetButtons` with centered HBox layout; UI emits `request_place_bet(bet_id, 0)` using `BetCatalog.level3_bet_ids()` slots `[0]` and `[1]` (no `Btn_INTRO_SELECT_NO_HIT`/third-option wiring).
- Active Level 3 HUD contract excludes legacy XP/level-up/token-progression reactive wiring and related level-up SFX/popup handling.
- Active Level 3 UI<->RunManager contract uses `res://scripts/ui/run_manager_ui_port.gd` as a typed adapter for read-only UI queries, avoiding direct UI-side `has_method` branching while keeping RunManager authority unchanged.
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
- `Phase_FIRST_REACTION` (`IL PATTO E' SIGILLATO.`) uses a fixed title and an empty subtitle payload; no per-bet subtitle selection layer is active in UI runtime.
- Resolve ritual overlay container `Phase_RESOLUTION` (`RITO DI GIUDIZIO`) keeps the existing condanna subtitle behavior unchanged.
- Scope guard: this contract removes only legacy post-bet copy selection (`POST_BET_TEXTS`) and does not alter phase/event sequencing authority.
