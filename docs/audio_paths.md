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
