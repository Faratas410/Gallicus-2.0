# Playable Slice M2/M3 Status (2026-06-09)

## Scope
Re-run the minimum playable slice verification plan for the current repository state.

Required smoke scenarios:
- `BET_PRESENT`
- `FULL_RUN`

## Static/contract checks
All required local static guards passed with the bundled Python runtime:
- `scripts/ci/test_headless_smoke_validator.py` => PASS
- `scripts/ci/check_docs_active_refs.py` => PASS
- `tools/ci/verify_res_paths.py` => PASS
- `scripts/ci/test_playable_slice_contract.py` => PASS
- `scripts/ci/test_era_visual_template_audit.py` => PASS
- `scripts/ci/test_pressure_presentation_contract.py` => PASS
- `scripts/ci/test_ui_motion_contract.py` => PASS

## Local Godot diagnostic
Godot runtime prepared locally under ignored path:
- `tools/godot/Godot_v4.6.2-stable_win64_console.exe`

Import pass:
- Command: `Godot_v4.6.2-stable_win64_console.exe --headless --editor --path . --quit`
- Result: `EXIT:0`
- Notes: first sandboxed run produced AppData write errors; re-run with normal local Godot permissions completed cleanly.

## Runtime smoke diagnostics
Windows local smoke remains diagnostic-only and non-signoff.

### BET_PRESENT
- Command: `scripts/ci/run_headless_smoke.py --scenario BET_PRESENT ...`
- Result: FAIL
- Classification: `NATIVE_CRASH_BEFORE_BOOTSTRAP`
- Exit code: `3221225477`
- Bootstrap marker: missing `SMOKE:BOOT_OK`
- Last milestone: none
- Log: `artifacts/BET_PRESENT/smoke.log`
- Summary: `artifacts/BET_PRESENT/smoke_summary.json`

### FULL_RUN
- Command: `scripts/ci/run_headless_smoke.py --scenario FULL_RUN ...`
- Result: FAIL
- Classification: `NATIVE_CRASH_BEFORE_BOOTSTRAP`
- Exit code: `3221225477`
- Bootstrap marker: missing `SMOKE:BOOT_OK`
- Last milestone: none
- Log: `artifacts/FULL_RUN/smoke.log`
- Summary: `artifacts/FULL_RUN/smoke_summary.json`

## Tooling correction
`scripts/ci/run_headless_smoke.py` now detects native crash markers before timeout classification.
This prevents timeout-wrapped Godot crash logs from being misreported as `STALL_OR_WATCHDOG`.

## CI/Linux signoff status
No pull-request-triggered workflow runs were available for commit:
- `23efbc7e820dcd62263b1a53940ef6c0f30bb67c`

The GitHub connector available in this environment can inspect existing runs, jobs, logs, and artifacts, but does not expose workflow dispatch. The local shell also does not provide `git` or `gh`, so no canonical CI run was started from this environment.

## M2 Verdict
`M2 BLOCKED (canonical CI/Linux runtime proof missing)`

The active repository passes static and import checks, but executable smoke proof for `BET_PRESENT` and `FULL_RUN` is still unavailable on the required canonical Linux CI surface.

## M3 Signoff Packet

### Gate checklist
1. BET_PRESENT executable smoke proof on canonical CI/Linux: NOT AVAILABLE
2. FULL_RUN executable smoke proof on canonical CI/Linux: NOT AVAILABLE
3. Static/contract regression guards: PASS
4. Local Godot import: PASS
5. Windows local smoke diagnostics: FAIL before bootstrap due native Godot crash

### Signoff decision
`NOT SIGNED OFF FOR PLAYABILITY YET`

Reason: canonical Linux CI smoke evidence is missing. Local Windows smoke remains diagnostic-only and crashes before project bootstrap.

## Required next action to clear signoff
Start `.github/workflows/godot_smoke_runtime.yml` on GitHub for the current commit or open a PR that triggers it, then verify both scenario artifacts:
- `smoke_runtime_BET_PRESENT`
- `smoke_runtime_FULL_RUN`

Playable slice may be marked `SIGNED OFF` only if both summaries classify as `OK` on `canonical_ci_linux`.
