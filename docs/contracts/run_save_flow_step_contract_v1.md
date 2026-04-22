# run_save_flow_step Contract (v1)

Status: ACTIVE  
Scope: Level 3 continue/load resume contract.

## Authoritative Source

- Runtime contract file: `res://scripts/contracts/run_save_flow_step_contract.gd`

No other file may define parallel canonical flow-step value sets.

## Canonical Live Values

After load-boundary normalization, live runtime may carry only:

- `BET_SIGNED`
- `INTERMEDIATE_CHOICE`
- `PUSH_LUCK`
- `BET_OFFER`

## Boundary-Only Legacy Values

The following legacy values are accepted **only** during load/continue normalization:

- `RESOLUTION`
- `RUN_FLOW_RESOLUTION`
- `PHASE_RESOLUTION`
- `18`

These values must never survive into live runtime dispatch.

## Migration Rules

- Legacy values above normalize to `INTERMEDIATE_CHOICE`.
- Empty flow-step normalizes to `BET_OFFER`.
- If a flow-step requiring bet id (`BET_SIGNED`, `INTERMEDIATE_CHOICE`, `PUSH_LUCK`) lacks bet id at boundary, normalize to `BET_OFFER`.

## Invalid-Value Policy

- If a value is not canonical and not mappable via boundary migration rules, continue/load is rejected with `invalid_run_save_flow_step:*`.
- Invalid values are not silently dispatched.
