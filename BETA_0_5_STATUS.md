# Gallicus v0.5 Status

## Current Classification
`v0.2 candidate`

## Signoff State
`NOT SIGNED OFF FOR v0.5`

## Reason
The beta plan and static coverage are implemented locally, but canonical CI/Linux smoke evidence is still required for `BET_PRESENT`, `FULL_RUN`, and the beta matrix scenarios.

## Required CI Artifacts
- `smoke_runtime_BET_PRESENT`
- `smoke_runtime_FULL_RUN`
- `smoke_runtime_BETA_CASHOUT`
- `smoke_runtime_BETA_DOUBLE`
- `smoke_runtime_BETA_CONDANNA`
- `smoke_runtime_BETA_REGISTER_FINAL`

## Local Acceptance Before CI
- Static suite passes locally.
- Godot import headless passes locally.
- Mojibake scan is clean locally.
- Timed non-headless launch exits without fatal error locally.
- Windows headless smoke remains diagnostic-only and currently fails before `SMOKE:BOOT_OK` with `NATIVE_CRASH_BEFORE_BOOTSTRAP`.
