# UI Overhaul Production Pipeline

Status: supporting workflow, not gameplay canon.  
Purpose: Make Gallicus UI work contract-first, traceable, and production-ready.

## Principle

Every UI-overhaul change should move through the same chain:

brief -> source asset -> runtime resource -> scene binding -> verification -> report

This is the "The Cursor-like" production rule for Gallicus: do not improvise visual changes directly in scenes. Start with the contract, name the asset role, then wire only the smallest runtime surface that proves the direction.

## Inputs

- `docs/canon/UI_CANON.md` - canon owner for UI behavior and visual governance.
- `docs/contracts/ui_art_direction_contract_v1.md` - active art-direction acceptance contract.
- `docs/support/ui/lapidary_ui_asset_brief.md` - current source brief for lapidary registry assets.
- `docs/support/ui/run_ui_phase_paths.md` - active UI phase/node reference.
- `assets/ui/third_party/gowl_stonepixel/` - primary StonePixel 1.2 runtime-safe source subset.

## Workflow

1. Select one surface.
   - Example: betting contract pages, pact sealed modal, resolve ritual modal, push-your-luck panel, END_RUN register.
   - Do not combine multiple surfaces unless they share one asset family and one scene.

2. Classify the work lane.
   - Docs lane: contract, prompt, brief, naming, acceptance criteria.
   - Asset lane: PNG/source import and `.import` sidecar.
   - Resource lane: `.tres` stylebox/material/theme resource.
   - Scene lane: presentation-only scene binding.
   - Verification lane: smoke/static/render evidence.

3. Write or update the asset brief.
   - Include use case, asset type, primary request, composition, state list, text rule, constraints, and runtime destination.
   - Keep generated imagery textless unless the art-direction contract explicitly allows otherwise.

4. Stage the source asset.
   - Prefer existing StonePixel files under `assets/ui/third_party/gowl_stonepixel/`.
   - Raw/source candidates belong under `assets/ui/official_source/` or a clearly named staged UI source folder only when the primary pack lacks the needed role.
   - Runtime-ready Gallicus-specific assets belong under `assets/ui/official/` or an existing runtime UI asset family.
   - Third-party packs remain reference/candidate material until an explicit wiring patch adopts specific assets; StonePixel's tracked subset is the current exception and primary pack.
   - Do not reslice StonePixel by eye. If a new slice is needed, import the smallest source PNG and document the mapping.

5. Create runtime resources.
   - StyleBox resources use `assets/ui/official/styleboxes/`.
   - Theme-wide defaults stay in `assets/ui/theme/official_theme.tres`.
   - Scene-local overrides are allowed only for localized migration surfaces.

6. Bind one runtime surface.
   - Keep the change presentation-only.
   - Do not add GameEvents signals, payload fields, phase routes, or RunManager logic.
   - If a scene binding needs new data, stop and split into a gameplay/contract task.

7. Verify.
   - Run the relevant static checks for docs/contracts.
   - Run a mojibake scan before finalizing.
   - For scene/resource changes, run Godot import/headless smoke when available.
   - Capture or describe visual evidence for any material layout change.

8. Report.
   - Name the surface.
   - Name the lane.
   - List touched files.
   - Declare behavioral impact.
   - List verification commands and results.

## Naming Rules

Use names that expose material, surface, role, and state.

PNG/source examples:

- `registry_contract_tablet_pair.png`
- `registry_pipeline_stamp_verified.png`
- `registry_pressure_groove_fill.png`
- `registry_wax_seal_locked.png`

StyleBox/resource examples:

- `sb_registry_contract_panel.tres`
- `sb_registry_pipeline_stamp_verified.tres`
- `sb_registry_pressure_groove.tres`

Scene node examples:

- `Panel_CONTRACT_REGISTRY`
- `Stamp_PIPELINE_VERIFIED`
- `Groove_PRESSURE_RAIL`

## Definition Of Done

A UI-overhaul patch is done when:

- The changed surface follows `docs/contracts/ui_art_direction_contract_v1.md`.
- The patch is one coherent domain: docs, assets, resources, or one presentation scene surface.
- Runtime authority is unchanged.
- Active docs reference only existing docs paths.
- Mojibake scan is clean.
- Any touched Godot resources remain loadable by the project.

## Stop Conditions

Stop and split the task if the patch requires:

- New gameplay data in UI payloads.
- New GameEvents signals.
- RunManager or phase-routing changes.
- Replacing more than one major screen at once.
- Mixing incompatible visual languages to finish quickly.
