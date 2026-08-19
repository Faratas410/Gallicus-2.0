# Media Vertical Slice - preparation package

## Status

This package prepares the `MV-01` and `MV-02` surfaces and the review assets
for `MV-04`. It does not activate the media slice in runtime.

Runtime work remains locked until:

1. the `OF-11` checkpoint is closed;
2. `CP-01` and `CP-02` produce a stable internal Windows build;
3. the `CP-03` playtest records an explicit go decision.

This preserves the single-active-runtime-package rule and the Core Playable
Candidate freeze. Nothing in this folder is imported by a Godot scene or
treated as release-ready. The folder-level `.gdignore` also prevents editor
import sidecars for these review-only files.

## Creative decision

The slice covers the opening and first contact with the Registry. Direction A
is the selected production reference because the threshold, destination and
Registry remain readable in one frame. Direction D is the preferred reference
for the final close reveal. Directions B and C remain comparison material.

All directions are text-free and use basalt, ash, oxidized bronze, controlled
limestone light and a minimal red-wax accent. No character, gore, fantasy
language or action camera is permitted.

## Storyboard and timing

| Time | Beat | Visual | Audio |
| --- | --- | --- | --- |
| `0.0-0.5 s` | Threshold acknowledged | Existing UI is covered by the local presentation overlay; threshold frame holds. | Low stone onset and threshold cue. |
| `0.5-2.2 s` | Entry | Slow 2D push through the threshold; light and dust separate the depth planes. Skip becomes available at `0.5 s`. | Air layer opens; no rhythmic accent. |
| `2.2-4.8 s` | Registry revealed | Registry table becomes the central object; vignette and background motion settle. | Bronze pulse and Registry reveal cue. |
| `4.8-6.8 s` | First contact | Presentation dissolves into the existing closed-Registry UI. | Music layers settle under the safe run state. |
| `6.8-7.2 s` | Handoff | Overlay releases input and focus moves to `APRI IL REGISTRO`. | No additional confirmation sound. |

Reduced motion replaces the push and pulses with one approximately one-second
dissolve. Skip is a visible localized button after `0.5 s`; Escape invokes the
same local action while the overlay owns input.

## Runtime integration contract for MV-03 to MV-05

- Add one scene-local opening controller under `Main`; it is not an autoload
  and it has no outcome authority.
- Observe existing `run_started`, `run_phase_changed` and `settings_changed`
  signals. Do not add signals to `GameEvents`.
- Expose local `sequence_started(kind)` and
  `sequence_finished(kind, skipped)` signals for tests and capture tooling.
- Never delay or replace the canonical `RunManager` transition. The sequence
  is an input-covering presentation above the already valid run phase.
- Add persisted `reduced_motion: bool`, default `false`, only when the runtime
  package is formally opened. That high-risk save/settings patch requires the
  full static and smoke suite.
- Do not persist cinematic progress. Save/quit/resume restores only the
  canonical phase and must not recreate an intermediate overlay state.
- The music extension uses synchronized layer players and existing phase
  events. Legacy MP3 files are not accepted as final music merely because they
  are currently wired.

## Audit summary

| Family | Decision | Reason |
| --- | --- | --- |
| Official arena threshold and Registry table objects | `KEEP` | Object-first, text-free, documented and already verified in Godot. |
| `bg_registry_ritual.png` | `REWORK` | Useful administrative framing, but it reads as a flat UI plate rather than a place. |
| `sfondo_arena_principale.png` | `REPLACE` | Blood-stained action-horror framing conflicts with the current art direction. |
| Main-menu base and atmospheric layers | `REWORK` | Functional depth layers exist, but style and symbols need reconciliation with the object-first runtime art. |
| Generated MV02 directions | `KEEP` as review source | Original project-specific visual exploration; not runtime assets. |
| Existing object-first WAV cues | `KEEP` | Gesture-specific, deterministic and aligned with stone, wax and bronze materiality. |
| Generic combat/action WAV cues still referenced by UI | `REWORK` | Runtime use must be migrated to object/gesture naming without changing unopened flow surfaces. |
| MP3 files used by `MusicDirector` | `REPLACE` before release | Provenance is not documented and tense/climax naming and mood are often action/horror-led. |
| Unreferenced action/horror MP3 files | `REMOVE` during the AV audit | They have no accepted Gallicus role and no release provenance. |
| MV04 procedural stems and cues | `KEEP` as review prototype | Deterministic local synthesis; requires human listening and mastering before runtime adoption. |

## Review and acceptance

- Compare the four directions at native resolution; Direction A is the
  current default, not an irreversible art lock.
- Review the selected 1920x1080 composite and each RGBA overlay independently.
- Listen to the 48-second mix, individual stems, 36-second ambience loop and
  both material cues on headphones and speakers.
- Before runtime adoption, confirm mood, loudness, loop seam, final rights and
  whether a human composer/mastering pass replaces the prototype.
- Regenerate derived files with the scripts in `source/`; generated binaries
  must stay reproducible and must never be edited by hand.

See `ASSET_MANIFEST.md` for role, provenance and adoption state, and
`PROMPTS.md` for the exact built-in image-generation prompts.
