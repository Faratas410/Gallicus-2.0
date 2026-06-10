# Prototype Completion Plan v0.1

## Current Gameplay Loop
- The playable prototype is the Level 3 ritual loop: main menu, new run, bet selection, pact sealed ritual, intermediate choice, resolve ritual, push-your-luck, END_RUN finale.
- `RunManager` owns run flow and emits `GameEvents`; UI scripts render state and emit request signals only.
- Visual presentation already includes menu ambience, betting book, ritual panels, pressure/scars HUD, push-your-luck panel, and finale panel.
- Music playback already exists through `MusicDirector`; short action SFX were missing before this pass.

## CRITICAL Items
- CRITICAL: Player objective was too implicit on first launch. Added explicit menu onboarding text that describes signing a pact, passing rituals, and choosing cashout/risk until the final dossier.
- CRITICAL: Runtime SFX feedback was missing for most player actions. Added procedural WAV placeholders and a small `SfxBus` autoload.
- CRITICAL: Menu, betting book, ritual advance, intermediate choice, push-your-luck, scar/failure, finale, restart, and quit actions needed audible feedback. Wired cues without moving gameplay authority out of `RunManager`.
- CRITICAL: CI smoke workflow was not manually dispatchable. Added `workflow_dispatch` to the canonical Godot smoke workflow.
- CRITICAL: Final documentation did not exist. Added this audit and `PROTOTYPE_RELEASE_NOTES.md`.

## IMPORTANT Items
- IMPORTANT: Windows local non-editor headless smoke may still crash before bootstrap on this machine; Linux CI remains the canonical automated signoff surface.
- IMPORTANT: Some required SFX names are action-game oriented. They are present as placeholder assets and mapped to equivalent ritual-loop events until combat exists.
- IMPORTANT: Manual desktop playthrough should still be performed in the visible Godot player/editor because headless Windows is diagnostic only.
- IMPORTANT: Additional polish could add bespoke ending screens, richer ritual hit timing feedback, and a dedicated audio mix pass.

## OPTIONAL Items
- OPTIONAL: Generate new visual assets for alternate ending screens, icons, and cinematic cards.
- OPTIONAL: Add cinematic transitions between ritual phases.
- OPTIONAL: Add post-v0.1 lore expansion, balancing, and new mechanics.

## Broken Systems / Blockers
- No active visual asset blocker was found. Existing menu, backgrounds, icons, and lapidary UI assets cover the v0.1 loop.
- No new game mechanics are required for v0.1. Physical player/enemy/combat systems are out of scope for this prototype.
- The known external validation risk is local Windows headless runtime stability; it is classified as diagnostic unless reproduced on CI/Linux.

## Validation Checklist
- Static contracts must pass.
- Godot headless import must complete.
- `BET_PRESENT` smoke must reach `SMOKE:MILESTONE=BET_PRESENT`.
- `FULL_RUN` smoke must reach the END_RUN finale markers, including `END_RUN_FINAL ending_key=`.
- Mojibake scan must be clean before closing.
