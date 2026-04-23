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
- `POST_BET_MESSAGES`
- `RUN_FLOW_POST_BET_MESSAGES`
- `PHASE_POST_BET_MESSAGES`
- `14`
- `18`

These values must never survive into live runtime dispatch.

## Migration Rules

- Legacy values above normalize to `INTERMEDIATE_CHOICE`.
- Legacy non-mainline phase ids from saved payload boundary fields (`run.phase` / `run_state.phase`) are normalized deterministically:
  - `POST_BET_MESSAGES` phase id `14` -> `INTERMEDIATE_CHOICE`
  - `RESOLUTION` phase id `18` -> `INTERMEDIATE_CHOICE`
- Empty flow-step normalizes to `BET_OFFER`.
- If a flow-step requiring bet id (`BET_SIGNED`, `INTERMEDIATE_CHOICE`, `PUSH_LUCK`) lacks bet id at boundary, normalize to `BET_OFFER`.

## Invalid-Value Policy

- If a value is not canonical and not mappable via boundary migration rules, continue/load is rejected with `invalid_run_save_flow_step:*`.
- Invalid values are not silently dispatched.
