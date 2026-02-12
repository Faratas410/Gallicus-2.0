# Performance Structure Audit

## Snapshot Context

- Godot version: 4.6
- Entry: `res://scenes/Main.tscn`
- Runtime snapshot moment(s):
  - **Snapshot A (menu baseline):** parsed `Main.tscn` with its instanced `UI.tscn` subtree expanded.
  - **Snapshot B (HUD root):** parsed `UI.tscn` as standalone UI root.
  - **Snapshot C (arena baseline):** parsed `Arena.tscn` root scene.
- Measurement method:
  - Static structural parse of `.tscn` node trees (including `instance=ExtResource(...)` expansion for `Main -> UI` composition).
  - Runtime alignment check from code paths showing arena/runtime scene instancing (`run_manager.gd` + `Arena.gd`).
  - No runtime tool script was committed; counting was done with a one-off local parser command.
- Environment note:
  - Godot executable was not available in this container (`which godot4`/`which godot` returned none), so live in-engine runtime capture was not possible here.

## Metrics Summary (per root)

### Main (`res://scenes/Main.tscn`)

- Total nodes: **273**
- CanvasItems: **259**
- Controls: **254**
- Deepest path (depth 11):
  - `Main/UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText/BetBadgeTitlePanel/BetBadgeTitle`
- Top subtrees by node count:
  - `Main` — 273
  - `Main/UI` — 201
  - `Main/UI/UI_RunRoot` — 145
  - `Main/MenuLayer` — 67
  - `Main/MenuLayer/MainMenu` — 65
  - `Main/UI/HUD` — 51
  - `Main/UI/UI_RunRoot/Phase_INTRO` — 36
  - `Main/UI/UI_RunRoot/Phase_END_RUN` — 34
  - `Main/UI/UI_RunRoot/Phase_INTRO/Panel_INTRO` — 34
  - `Main/UI/UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin` — 33

### UI/HUD (`res://scenes/UI.tscn`)

- Total nodes: **243**
- CanvasItems: **235**
- Controls: **234**
- Deepest path (depth 10):
  - `UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText/BetBadgeTitlePanel/BetBadgeTitle`
- Top subtrees by node count:
  - `UI` — 243
  - `UI/UI_RunRoot` — 188
  - `UI/HUD` — 51
  - `UI/UI_RunRoot/BettingCircle` — 44
  - `UI/UI_RunRoot/BettingCircle/ContractPanel` — 41
  - `UI/UI_RunRoot/BettingCircle/ContractPanel/ContractVBox` — 38
  - `UI/UI_RunRoot/Phase_INTRO` — 36
  - `UI/UI_RunRoot/BettingCircle/ContractPanel/ContractVBox/BetOptions` — 34
  - `UI/UI_RunRoot/Phase_END_RUN` — 34
  - `UI/UI_RunRoot/Phase_INTRO/Panel_INTRO` — 34

### Arena / Gameplay Root

- Scene: `res://scenes/Arena.tscn`
- Total nodes: **3**
- CanvasItems: **3**
- Controls: **0**
- Deepest path (depth 1):
  - `Arena/Background`
- Top subtrees by node count:
  - `Arena` — 3
  - `Arena/Background` — 1
  - `Arena/DebugDraw` — 1
- Runtime alignment note:
  - `RunManager` instantiates arena at runtime via `arena_scene.instantiate()` and `main.add_child(arena_node)`; `Arena.gd` can also instantiate/add player (`player_scene.instantiate(); add_child(_player)`). This confirms arena tree growth in live run phases beyond static baseline.

## UI Layout Risk Findings

### Deep container chains (>= 5 levels)

- `UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText/BetBadgeTitlePanel`
  - chain depth 8: `MarginContainer -> HBoxContainer -> VBoxContainer -> PanelContainer -> MarginContainer -> HBoxContainer -> VBoxContainer -> PanelContainer`
- `UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText/BetBadgeValuePanel`
  - chain depth 8: `MarginContainer -> HBoxContainer -> VBoxContainer -> PanelContainer -> MarginContainer -> HBoxContainer -> VBoxContainer -> PanelContainer`
- `UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge/BetBadgeMargin/BetBadgeContent/BetBadgeText`
  - chain depth 7: `MarginContainer -> HBoxContainer -> VBoxContainer -> PanelContainer -> MarginContainer -> HBoxContainer -> VBoxContainer`
- `UI/UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/BuyTokenRow/BuyTokenVBox/Lbl_INTRO_CHOICE_0Panel`
  - chain depth 6: `MarginContainer -> ScrollContainer -> VBoxContainer -> HBoxContainer -> VBoxContainer -> PanelContainer`
- `UI/HUD/SafeMargin/TopRow/LeftColumn/EscalationRow/EscalationLabelPanel`
  - chain depth 5: `MarginContainer -> HBoxContainer -> VBoxContainer -> VBoxContainer -> PanelContainer`

### Potential relayout hotpaths

- **78 controls** use `SIZE_EXPAND_FILL` (`size_flags_* = 3`) under container parents.
- High-frequency container/expand paths to watch:
  - `UI/HUD/SafeMargin/TopRow`
  - `UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge`
  - `UI/HUD/SafeMargin/TopRow/LeftColumn/EscalationRow`
  - `UI/HUD/SafeMargin/TopRow/LeftColumn/EscalationRow/EscalationBar`
  - `UI/UI_RunRoot/Phase_MID_CHOICE/.../Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_0`
  - `UI/UI_RunRoot/Phase_MID_CHOICE/.../Box_MID_CHOICE_CHOICES/Btn_MID_CHOICE_SELECT_1`
- Runtime toggling concentration:
  - `ui_root.gd` contains frequent visibility switching for modal roots/panels and overlays (`modal.visible`, `panel.visible`, HUD overlays, dimmer, countdown panels, phase panels), which can trigger repeated container relayout when combined with deep nesting.

### Potential redraw hotpaths

- RichTextLabel + autowrap found in container-backed panels:
  - `UI/HUD/ScarPopupPanel/ScarPopupMargin/ScarPopupTextPanel/ScarPopup`
  - `UI/UI_RunRoot/DebugOverlay/Lbl_DebugOverlayPanel/Lbl_DebugOverlay`
  - `UI/UI_RunRoot/Phase_END_RUN/.../Lbl_END_RUN_PACTS_BODY`
  - `UI/UI_RunRoot/Phase_END_RUN/.../Lbl_END_RUN_CONDANNE_BODY`
  - `UI/UI_RunRoot/Phase_END_RUN/.../Lbl_END_RUN_FOOTER`
- Hidden-at-rest controls count: **35** in `UI.tscn` (several modal/overlay roots), suggesting frequent show/hide transitions under gameplay events.
- Animation track safety check:
  - `TorchFlickerPlayer` animates `TorchFlickerOverlay:modulate:a` only (safe visual property).
  - No layout-affecting AnimationPlayer tracks (size/anchor/margin) were found in scanned UI scene tracks.

## Recommendations (NO PATCH YET)

1. - Target subtree: `UI/HUD/SafeMargin/TopRow/LeftColumn/BetBadge/...`
   - Proposed change (structural only; no redesign): flatten one redundant container layer in each nested PanelContainer->MarginContainer segment.
   - Expected benefit: lower layout propagation depth on frequent HUD value updates.
   - Risk / stop condition: stop if theme/stylebox padding relies on exact nested wrappers.

2. - Target subtree: `UI/UI_RunRoot/Phase_INTRO/Panel_INTRO/BetMargin/BetScroll/Box_INTRO/...`
   - Proposed change: reduce nested VBox/HBox wrappers where rows contain single child panels.
   - Expected benefit: lower relayout cost during phase open/close and option repopulation.
   - Risk / stop condition: stop if row alignment differs across localization lengths.

3. - Target subtree: phase modal roots under `UI/UI_RunRoot`.
   - Proposed change: standardize modal shell to one reusable panel/margin/container depth pattern.
   - Expected benefit: fewer divergent layout paths and lower invalidation surface on modal toggles.
   - Risk / stop condition: stop if any phase requires unique scroll/overflow behavior.

4. - Target subtree: RichTextLabel blocks in `Phase_END_RUN`.
   - Proposed change: prefer Label where rich markup is not required; keep RichTextLabel only where BBCode is necessary.
   - Expected benefit: reduced text layout/redraw overhead on long summaries.
   - Risk / stop condition: stop if style content requires BBCode tags/inline formatting.

5. - Target subtree: HUD transient overlays (`ScarPopupPanel`, `ArenaResolutionOverlayPanel`, `AudienceContextLabelPanel`, etc.).
   - Proposed change: group transient overlays under a dedicated lightweight overlay container branch.
   - Expected benefit: isolate visibility churn from core HUD layout branch.
   - Risk / stop condition: stop if z-order/input-blocking behavior changes.

6. - Target subtree: `UI/HUD/SafeMargin/TopRow`.
   - Proposed change: replace generic spacer control + deep nested rows with a narrower fixed-width + flexible split layout.
   - Expected benefit: less container negotiation on dynamic text width changes.
   - Risk / stop condition: stop if responsive behavior across aspect ratios regresses.

7. - Target subtree: `UI/UI_RunRoot/Phase_MID_CHOICE/.../Box_MID_CHOICE_CHOICES`.
   - Proposed change: keep expand-fill on outer choice list only; use tighter per-button sizing defaults when possible.
   - Expected benefit: reduced relayout when toggling choice visibility/enabled states.
   - Risk / stop condition: stop if button readability or touch target size degrades.

8. - Target subtree: hidden-at-rest phase panels.
   - Proposed change: keep only active phase subtree visible and consider collapsing inactive phase containers with minimal parent depth.
   - Expected benefit: lower update churn when many hidden controls coexist.
   - Risk / stop condition: stop if transitions need preloaded visible geometry for animation.

9. - Target subtree: modal fade transitions.
   - Proposed change: retain current modulate-alpha animation approach (already safe) and avoid adding anchor/offset tweens.
   - Expected benefit: preserves current low-risk redraw-only behavior.
   - Risk / stop condition: stop if future transitions require geometry motion.
