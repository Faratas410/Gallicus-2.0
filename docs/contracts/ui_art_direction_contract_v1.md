# UI Art Direction Contract v1

Status: Active support contract  
Scope: Visual target and acceptance rules for the Gallicus UI overhaul.

## Authority Boundary

This contract is subordinate to `docs/canon/UI_CANON.md`.

It defines the art direction for new UI-overhaul work. It does not change:

- RunManager authority.
- GameEvents signals.
- payload schemas.
- phase routing.
- gameplay rules.

If this document conflicts with `docs/canon/UI_CANON.md`, `docs/canon/UI_CANON.md` wins until the canon owner is explicitly amended.

## North Star

The UI must feel like the Registry made physical: a severe ritual office where every bet is a signed legal act, every production step is a stamped procedure, and every outcome leaves a mark.

The target is not generic fantasy UI. It is a Roman infernal registry: basalt slabs, bronze rims, wax seals, carved grooves, official stamps, witness marks, pressure rails, and compact legal surfaces.

## Primary Pack Rule

StonePixel 1.2 is the primary UI pack for overhaul work. The tracked runtime-safe subset is `assets/ui/third_party/gowl_stonepixel/`.

Use the existing tracked slices as-is whenever possible. Do not hand-reslice the full source pack for routine UI work; bad slices create visual drift and can break the playable-slice readability baseline.

## Visual Promises

1. Contract surfaces are readable first.
   - New pact and bet-selection surfaces must prioritize dark ink on pale or warm stone, or light text on controlled dark slabs.
   - Text must be rendered by Godot. Do not bake labels into images.

2. The Registry is the organizing metaphor.
   - Use slabs, tablets, seals, dossiers, ledgers, grooves, and official marks.
   - A UI screen should read as a physical registry instrument, not a floating card layout.

3. Production pipeline UI is diegetic.
   - Pipeline status should look like stamped procedure: intake, draft, review, sealed, imported, verified.
   - Progress markers should be stamps, punched tabs, wax marks, carved ticks, or thin bronze rails.

4. Controls stay compact and deliberate.
   - Buttons are tablets or stamped strips.
   - Sliders and meters are grooves.
   - Icons are small legal/ritual marks, not decorative filler.

5. Asset language must stay coherent inside one screen.
   - Do not mix wooden planks, parchment scrolls, spellbook pages, and stone registry slabs in a finalized screen.
   - Existing book/wood UI may remain as migration residue until the matching registry asset exists, but new overhaul work targets the registry language.

6. Palette must have functional contrast.
   - Core materials: dark basalt, charred stone, aged bronze, hot wax red, bone ink, ash gray.
   - Accent materials: muted jade, tarnished gold, cold iron blue.
   - Avoid single-hue screens. Use accents to separate hierarchy and state.

## Forbidden Patterns

- Baked UI text inside generated images.
- Decorative panels that do not map to a readable UI role.
- Generic ornate RPG frames without registry purpose.
- Parchment, scroll, floating spellbook, or wooden plank language for new overhaul targets.
- Soft stock-art backgrounds that obscure actual UI readability.
- Mixed asset packs inside one finalized screen.
- Large ornamental symbols that compete with contract text.

## Runtime Asset Families

New UI-overhaul assets should fit one of these families:

- `registry_slab`: large modal/finale/panel surface.
- `contract_tablet`: pact, bet, and choice text surface.
- `pipeline_stamp`: production status marker.
- `wax_seal`: confirmation, locked, or sealed state.
- `pressure_groove`: risk/pressure meter surface.
- `dossier_tab`: compact navigation or grouped evidence marker.
- `witness_mark`: small icon for condition, payout, pact, sentence, or corruption.

## Acceptance Checklist

An overhaul asset or UI patch is acceptable only if:

- It keeps all gameplay authority outside UI.
- It has no baked text unless the asset is purely decorative and textless by contract.
- It is readable at the canonical 1280x720 viewport.
- It uses crisp import settings for pixel-art styled UI textures.
- It has a clear runtime destination or remains explicitly staged as source/reference.
- It does not introduce mojibake or malformed encoding in source/docs.
- It updates support documentation when a new asset family, naming rule, or production lane is introduced.

## Migration Priority

1. Pact/bet contract selection surface.
2. Pact sealed and resolve ritual modals.
3. Push-your-luck decision panel.
4. END_RUN register/finale surface.
5. HUD pressure and scars surfaces.
6. Main menu support surfaces after runtime contract screens are coherent.
