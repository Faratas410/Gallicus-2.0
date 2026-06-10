# Prototype Release Notes v0.1

## Implemented
- Closed the prototype scope around the existing ritual run loop: menu, bet, pact ritual, intermediate choice, resolve ritual, push-your-luck, and finale.
- Added explicit first-launch objective text in the main menu.
- Added a small `SfxBus` autoload for pooled short SFX playback.
- Wired audio feedback across menu buttons, betting book actions, ritual advances, resolve strikes, intermediate choices, push-your-luck decisions, scar/failure feedback, finale, restart, and quit.
- Made the canonical Godot smoke workflow manually dispatchable.

## Assets Added
- No visual assets were generated because existing runtime visuals cover the playable loop.

## Audio Added
- Procedural placeholder WAV files were added under `assets/audio/sfx/`:
  `button_hover`, `button_click`, `cursor_move`, `cursor_select`, `player_damage`, `enemy_hit`, `enemy_death`, `pickup`, `level_up`, `stage_complete`, `game_over`.
- The placeholder set now uses a darker Gallicus palette: stone taps, parchment movement, low bells, wax-seal impacts, and register-like rumbles instead of neutral UI beeps.

## VFX Tuning
- Decision flashes and push-your-luck pulses were muted toward stone, bronze, ember, and dried-blood tones so feedback reads closer to the ritual UI mood.

## Blockers Removed
- Missing action SFX no longer blocks v0.1 feedback.
- Missing first-run objective copy no longer blocks player understanding.
- Missing manual dispatch on the smoke workflow no longer blocks CI/Linux validation from GitHub Actions.

## Known Issues
- Local Windows headless smoke can be diagnostic-only if it crashes before bootstrap; Linux CI remains the signoff target.
- Combat-oriented placeholder SFX are present for the required asset contract but currently map to ritual-loop events.

## Validation Status
- Static guards passed locally: smoke validator, docs refs, `res://` paths, playable slice, era visual anchors, pressure presentation, and UI motion.
- Godot headless editor import passed locally and imported all new WAV assets.
- Timed non-headless local launch passed with exit code 0 and no fatal error.
- Local Windows runtime smoke remains `BLOCKED` by `NATIVE_CRASH_BEFORE_BOOTSTRAP` before `SMOKE:BOOT_OK` for both `BET_PRESENT` and `FULL_RUN`.
- CI/Linux smoke was not executed from this workspace; the workflow now supports manual dispatch.

## Suggested Post-v0.1 Improvements
- Add bespoke ending-screen art and richer finale variants.
- Add an audio mix pass with category volume controls for SFX.
- Expand cinematic transitions only after the smoke-certified playable slice remains stable.
