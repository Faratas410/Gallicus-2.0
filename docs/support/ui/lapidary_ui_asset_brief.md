# Lapidary UI Asset Brief

Status: supporting brief, not gameplay canon.

## Visual Direction

The UI should read as the arena's Registry made physical: dark stone, worn bronze, shallow carved grooves, warm torch highlights, and restrained ritual authority.

Do not make fantasy parchment, wooden planks, floating scrolls, decorative paper, or generic ornate RPG panels. Text is rendered by Godot, not baked into generated art.

## Runtime Kit

- Shared panels: dark stone slabs with narrow bronze rims.
- Primary buttons: small bronze-inlaid stone tablets, compact and readable.
- Betting surface: two carved register tablets inside one large slab.
- Final screen: the same register slab, used for a smart written verdict instead of a list.
- Pressure rail: an engraved groove at the foot of the register.

## Menu Assets To Generate

### `menu_base_lapidary_1280x720.png`

Use case: stylized-concept
Asset type: game main menu background
Primary request: a 1280x720 pixel-art inspired Roman arena district at dusk, rebuilt around a ritual stone registry theme.
Scene/backdrop: distant arena arches, torchlit stone street, tall owl banner, archival stonework, subdued crowdless atmosphere.
Style/medium: polished 2D game background, painterly pixel-art texture, dark readable composition.
Composition/framing: leave the center clear for UI buttons and title plaque; keep important landmarks to the side.
Lighting/mood: warm torchlight, violet-orange dusk, solemn and diegetic.
Text: no text.
Constraints: no UI panels, no labels, no watermark, no parchment, no wooden planks, no modern objects.

### `menu_title_lapidary_plaque.png`

Use case: stylized-concept
Asset type: transparent game UI title plaque source
Primary request: a horizontal carved stone title plaque for a game menu, dark basalt with worn bronze edge inlays.
Style/medium: 2D game UI asset, pixel-art inspired, clean silhouette.
Composition/framing: wide plaque, centered, generous inner space for Godot-rendered title text.
Lighting/mood: warm edge highlights, shallow engraved details, solemn Roman registry mood.
Text: no text.
Constraints: flat removable chroma-key background if transparency is needed; no baked letters, no parchment, no wood, no screws.

### `menu_button_lapidary_states.png`

Use case: stylized-concept
Asset type: game UI button state sheet
Primary request: three horizontal stone-and-bronze button states: normal, hover, pressed.
Style/medium: 2D game UI asset, pixel-art inspired, compact and readable.
Composition/framing: three equal-width buttons stacked vertically, no text.
Lighting/mood: normal is dark stone, hover has warmer bronze rim, pressed is slightly inset and darker.
Constraints: no labels, no wood grain, no parchment, no large decorative nails, no watermark.

### `register_slab_pair.png`

Use case: stylized-concept
Asset type: game UI betting/final register surface
Primary request: one large ritual registry slab with two carved tablet areas inside it.
Style/medium: 2D game UI asset, pixel-art inspired, readable dark-stone surface.
Composition/framing: two side-by-side carved areas for text, shallow central divider, lower engraved groove for pressure meter.
Lighting/mood: torchlit, official, severe, not ornate.
Text: no text.
Constraints: no book pages, no parchment texture, no wooden frame, no baked labels, no watermark.
