# Aduit — RunManager quick snapshot

## Scope
- File audited: `scripts/systems/run_manager.gd`

## Metrics
- Total lines: **5424**.
- Total functions (`^func`): **313**.

## Function inventory (compact)
- `request_*`: 7
- `start_*`: 4
- `end_*`: 1
- `set_*`: 1
- `get_*`: 16
- `is_*`: 4
- `_enter_*`: 12
- `_emit_*`: 14
- `_build_*`: 14
- `_apply_*`: 21
- `_try_*`: 7
- `_reset_*`: 7
- `_get_*`: 29
- other/internal mixed names: 176

## Notable legacy/suspicious blocks (already visible in code)
1. **Legacy phase setter compatibility entrypoint**
   - `set_phase(p: Variant)` routes with reason `"legacy_set_phase"`.
   - Lines: near `5080-5085`.
   - Risk note: keeps backward compatibility surface alive; can hide external callers still using deprecated path.

2. **Legacy scar payload parsing fallback**
   - `_parse_run_scars` builds a `legacy` Scar when non-dictionary item is found.
   - Lines: near `2589-2592`.
   - Risk note: mixed-format save compatibility path; can perpetuate old save schema silently.

3. **Embedded smoke-driver flow inside production manager**
   - `_is_smoke_mode`, `_smoke_*`, `_start_smoke_timeout_timer`.
   - Lines: around `1204-1314`.
   - Risk note: test orchestration logic inside central runtime authority increases complexity/branching in `_ready` and phase transitions.

## Commands used
- `wc -l scripts/systems/run_manager.gd`
- `rg -n '^func ' scripts/systems/run_manager.gd`
- `python` one-liners for totals and prefix grouping
- `rg -n 'legacy|deprecated|TODO|FIXME|smoke|fallback|compat|...` on RunManager
