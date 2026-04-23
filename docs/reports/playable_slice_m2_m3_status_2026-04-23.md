# Playable Slice M2/M3 Status (2026-04-23)

## Scope
Execute Milestone 2 (runtime smoke proof) and Milestone 3 (bounded internal signoff packet) for the minimum playable slice.

## M2 Objective
Produce executable runtime evidence for both smoke scenarios on current code:
- `BET_PRESENT`
- `FULL_RUN`

## M2 Execution Summary

### Blocker fix applied before rerun
1. `scripts/systems/run/smoke_driver.gd`
- Replaced non-constant-expression phase-name constants with initialized vars.
- No flow logic change; only parser-valid initialization change.

2. `scripts/ui/ui_root.gd`
- Fixed undeclared identifier in scar popup by deriving `scar_name` from payload (`name`, then `id`, then fallback).
- No flow authority change.

### Runtime execution attempts
1. Godot runtime binary prepared locally:
- `tools/godot/Godot_v4.6-stable_win64_console.exe`

2. Import pass:
- Command: `Godot_v4.6-stable_win64_console.exe --headless --editor --path . --quit`
- Result: `EXIT:0`

3. BET_PRESENT smoke run:
- Command: `scripts/ci/run_headless_smoke.py --scenario BET_PRESENT ...`
- Result: failed, process crash `3221225477` (`-1073741819`)
- Log: `smoke_BET_PRESENT_local.log`

4. FULL_RUN smoke run:
- Command: `scripts/ci/run_headless_smoke.py --scenario FULL_RUN ...`
- Result: failed, process crash `3221225477` (`-1073741819`)
- Log: `smoke_FULL_RUN_local.log`

5. Re-check with user-provided desktop binary (`2026-04-23`):
- Binary: `C:\Users\dovig\Desktop\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe`
- Import pass (`--headless --editor --quit`): `EXIT:0`
- BET_PRESENT smoke: failed, process crash `3221225477` (`-1073741819`)
- FULL_RUN smoke: failed, process crash `3221225477` (`-1073741819`)
- Rendering-driver variants (`opengl3`, `vulkan`) still crash with the same exit code.

### Static/contract checks
- `scripts/ci/test_headless_smoke_validator.py` => PASS
- `scripts/ci/test_playable_slice_contract.py` => PASS
- `tools/ci/verify_res_paths.py --project-root .` => PASS

## M2 Verdict
`M2 BLOCKED (environment/runtime execution blocker)`

The code-level blockers detected during import were fixed, but executable non-editor headless runs still crash in this Windows environment before scenario milestones can be validated.
Windows local headless is explicitly treated as diagnostic-only and non-signoff for M2/M3.

## M3 Signoff Packet

### Signoff target
Internal signoff for minimum playable slice runtime confidence.

### Gate checklist
1. BET_PRESENT executable smoke proof on current code: FAIL (crash before milestones)
2. FULL_RUN executable smoke proof on current code: FAIL (crash before milestones)
3. Contract/static regression guards: PASS
4. Runtime parser/compile blockers from this wave: FIXED

### Signoff decision
`NOT SIGNED OFF FOR PLAYABILITY YET`

Reason: executable runtime proof for BET_PRESENT and FULL_RUN is still missing in this local environment due headless runtime crash.

## Required next action to clear signoff
Run canonical smoke on Linux CI (`.github/workflows/godot_smoke_runtime.yml`) or equivalent Linux headless environment and capture both scenario logs with required milestones.
