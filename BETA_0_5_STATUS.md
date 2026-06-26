# Gallicus v0.5 Status

## Current Classification
`v0.5 internal beta candidate`

## Signoff State
`CI SIGNED / VISUAL QA GREEN / MANUAL QA BLOCKED`

## Reason
The canonical CI/Linux smoke matrix is green for the beta runtime gate, and local viewport visual QA passes. Full v0.5 signoff is blocked because an interactive manual QA session with a human tester has not been completed.

## Canonical CI/Linux Evidence
- Workflow: `Godot Smoke Runtime`
- Run: `27264909198`
- Run number: `77`
- Commit: `759c65bdd877251f6d9cf1d715c3dc54fad9cdb1`
- Result: `success`
- URL: `https://github.com/Faratas410/Gallicus-2.0/actions/runs/27264909198`

## Verified CI Artifacts
- `smoke_runtime_BET_PRESENT`
- `smoke_runtime_FULL_RUN`
- `smoke_runtime_BETA_CASHOUT`
- `smoke_runtime_BETA_DOUBLE`
- `smoke_runtime_BETA_CONDANNA`
- `smoke_runtime_BETA_REGISTER_FINAL`

## Blocker Removed
- Previous CI run `27264503302` failed because `BettingCircleUI` emitted warning lines when the beta catalog provided more than two offers.
- The UI now treats the expanded catalog as expected input and silently renders the first two page offers without warning.

## Local Acceptance
- Static suite passes locally.
- Godot import headless passes locally.
- Mojibake scan is clean locally.
- Timed non-headless launch exits without fatal error locally.
- Viewport visual QA passes locally with `VISUAL_QA:OK` on commit `2cacd70a465e065f2b448654a94c407222a7ad71`.
- Latest visual QA screenshots: `artifacts/visual_qa/01_menu.png` through `artifacts/visual_qa/08_end_run.png`.
- Windows headless smoke remains diagnostic-only and currently fails before `SMOKE:BOOT_OK` with `NATIVE_CRASH_BEFORE_BOOTSTRAP`.
- Windows non-headless smoke mode also fails before `SMOKE:BOOT_OK` with a native Godot `CrashHandlerException`; normal non-smoke launch still passes.

## Manual QA Blocker
- No interactive human tester session is recorded.
- Audio feedback cannot be signed from the current automated/agent-only pass.
- Three consecutive manual runs covering cashout, double, and condanna remain unverified interactively.

## Remaining Manual QA Gate
- Complete 3 consecutive runs in one executable session.
- Cover cashout, double, and condanna paths.
- Check restart, next run, quit, settings, and audio feedback interactively.
