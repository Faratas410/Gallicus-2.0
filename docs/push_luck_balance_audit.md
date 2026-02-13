# Push Your Luck Balance Audit

## Base Probabilities

### Authoritative runtime site
- **File:** `scripts/systems/run/outcome_system.gd`
- **Function:** `resolve_level3_arena(...)`
- **Core line:** `var base_win: float = 0.66`

This is the only runtime base success probability before dynamic modifiers.

### Pact 1 / Pact 2 / Pact 3
There is **no pact-specific base win table** in runtime code (no distinct numeric `pact1/pact2/pact3` success rates).

If “Pact 1/2/3” is interpreted as the first three escalation steps of a push chain, then the base win chance comes from:

- `win_chance = clampf(base_win - escalation_penalty, 0.2, 0.85)`
- `base_win = 0.66`
- `get_escalation_win_penalty(escalation_level)`:
  - level 0: `0.00`
  - level 1: `0.04`
  - level >=2: `0.04 + (level - 1) * 0.09`

Derived baseline (no scars/enemy/profile modifiers, no precedent):
- **Pact 1 (escalation 0):** `0.66`
- **Pact 2 (escalation 1):** `0.62`
- **Pact 3 (escalation 2):** `0.53`

> Note: these are derived values from escalation formula, not explicit pact constants.

## Risk Scaling

### Does probability change after each Double?
**Yes.**

- `run_manager.gd::_push_your_luck()` increments:
  - `_run_state.escalation_level = maxi(_run_state.escalation_level + 1, 1)`
- That value is consumed by:
  - `run_manager.gd::_resolve_level3_arena()`
  - `_outcome_system.resolve_level3_arena(..., effective_escalation, ...)`

### Where scaling is applied
- **Primary formula site:** `scripts/systems/run/outcome_system.gd`
  - `win_chance = clampf(base_win - escalation_penalty, 0.2, 0.85)`
  - `damage_chance = clampf(base_damage + escalation_damage, 0.2, 0.85)`

### Scaling type
- **Piecewise linear**, then clamped.
- Win penalty:
  - if `escalation_level >= 1` add `0.04`
  - if `escalation_level >= 2` add `(escalation_level - 1) * 0.09`
- Damage penalty:
  - if `escalation_level >= 1` add `0.03`
  - if `escalation_level >= 2` add `(escalation_level - 1) * 0.07`

So it is not exponential and not table-based.

### Extra global escalation modifier
- In `run_manager.gd::_resolve_level3_arena()`, if `_registry_has_precedent` is true:
  - `effective_escalation += 1`

This shifts the scaling curve by +1 level globally.

## Success Definition

A successful resolution (for push-your-luck flow) is determined in `run_manager.gd` during arena resolution:

- Start with RNG result:
  - `failed = not result.won`
- Then apply pact condition override:
  - if bet is `FLAWLESS_BLOOD` and `result.took_damage`, set `failed = true`

### What success triggers
On non-failed resolution branch:
- `_apply_glory_on_success()` (glory increment)
- push-your-luck continuation path is queued/opened:
  - via `_handle_level3_win(...)` or `_queue_push_luck_choice(...)` depending on resolution entry path.

### Is success purely RNG-based?
**Not purely.**

- Core win is RNG (`rng.randf() <= win_chance`)
- But final success can be invalidated by pact-specific condition (`FLAWLESS_BLOOD` requires no damage).

### Conditional modifiers already present
Yes, all already implemented:
- **Scars** modify win and/or damage probabilities.
- **Enemy profile** modifies win and damage probabilities.
- **Escalation level** modifies both (double-driven).
- **Registry precedent** adds +1 effective escalation.
- **Pact-specific post-check:** `FLAWLESS_BLOOD` can convert RNG win into failure if damage taken.

No direct probability modifier by coins.

## Failure Definition

### What counts as gameplay failure vs neutral resolution
- **Arena failure event:** `failed = true` branch in resolution.
  - Not always immediate run end.
  - Often applies penalties/scars and continues.
- **Immediate terminal failures:**
  - `DOUBLE_OR_DIE` failure path ends run.
  - `PROVOCA_FAIL` path ends run.
- **Neutral closure (non-failure):**
  - cashout / condanna closure path ends run without arena-loss failure semantics.

### Does failure probability increase after each resolution?
- It increases when player keeps doubling because escalation rises.
- If player does not keep escalating (or escalation is reset), failure pressure resets/reduces accordingly.

### Fail-safe / hard cap unrelated to corruption
Yes:
- Double action lock at target completion (`_get_double_lock_reason()` returns "Fine run: incassa ora" when `arena_index >= level3_target_arenas`).
- This is a structural cap independent of corruption.

## Theoretical Loop Shape

### Max theoretical consecutive successes
Under current active runtime path:
- `level3_target_arenas` is sampled as `randi_range(5, 8)`.
- Double is locked once `arena_index >= level3_target_arenas`.

Therefore, theoretical consecutive success chain within one run is capped by target arenas, max **8** (normal runtime path).

### Can probability reach <= 0?
No effective win probability can go <= 0 because:
- `win_chance` is clamped to minimum `0.2`.

### Can double scaling permit infinite loops?
Not in the active path:
- escalation can continue numerically, but continuation is hard-stopped by arena target + double lock, then run closure.
- finite horizon prevents infinite push-luck loop.

## Multiple Sites / Active vs Legacy Notes

### Multiple probability logic sites
- **Authoritative probability logic:** `scripts/systems/run/outcome_system.gd::resolve_level3_arena`
- **Callers:** two resolution entry paths in `run_manager.gd`
  - `_resolve_ritual_outcome(...)`
  - `_enter_resolution()`

Both call the same `_resolve_level3_arena()`; no alternate probability formula detected.

### Legacy coexistence / active path
- There is duplicated resolution flow entry (ritual and direct), but both are active flow variants and share the same outcome resolver.
- No separate legacy probability engine was found for Level 3 push-your-luck success chance.

### Recommendation (single authoritative site)
Keep `RunOutcomeSystem.resolve_level3_arena()` as the single authoritative probability source and avoid introducing formula fragments inside `RunManager`.
