# GALlicus — Patch Audit (Sprint Authority & Drift)

Date: 2026-02-25  
Mode: Audit-only (no core code edits)  
Result: **RED**

## Pre-flight
- Attempted `repo_map.md` at repository root: file missing.
- Read canonical docs from `docs/canon/*` and repo map from `docs/repo_map.md`.

---

## A) RunManager single authority

### A1 — request_* emitters
Command:
`rg -n "request_(new_run|continue_run|place_bet|mid_choice_select|pyl_|end_run_).emit\(" scripts -S`

Hits:
- `scripts/ui/ui_root.gd:1644`
- `scripts/ui/ui_root.gd:1649`
- `scripts/ui/ui_root.gd:1723`
- `scripts/ui/ui_root.gd:1737`
- `scripts/ui/ui_root.gd:2008`
- `scripts/ui/betting_circle_ui.gd:71`
- `scripts/ui/main_menu.gd:343`
- `scripts/ui/main_menu.gd:357`
- `scripts/systems/run_manager.gd:900`
- `scripts/systems/run_manager.gd:904`
- `scripts/systems/run_manager.gd:907`
- `scripts/systems/run_manager.gd:920`
- `scripts/systems/run_manager.gd:932`
- `scripts/systems/run_manager.gd:937`
- `scripts/systems/run_manager.gd:1124`

Status: **FAIL** (non-UI emits found in RunManager; all are smoke-driver pathways).

Excerpt:
```gdscript
if bool(smoke_step.get("request_new_run", false)):
    GameEvents.request_new_run.emit()
if bool(smoke_step.get("request_place_bet", false)):
    var bet_id: String = str(smoke_step.get("place_bet_id", ""))
    if bet_id != "":
        GameEvents.request_place_bet.emit(bet_id, 0)
```

### A2 — ending_key selector authority
Command:
`rg -n "(select_level3_ending_key|_select_run_finale|ending_key\s*=|register_ending_key)" scripts -S`

Relevant hits:
- Selector implementation: `scripts/systems/run/finale_builder.gd:46`
- Orchestrator selector callsite: `scripts/systems/run_manager.gd:3713`
- RunManager wrapper: `scripts/systems/run_manager.gd:3703`

Status: **PASS** (single effective selection authority: FinaleBuilder + RunManager callsite).

### A3 — phase mutation authority
Command:
`rg -n "(set_phase|RUN_PHASE_|run_phase_changed.emit)" scripts/systems -S`

Relevant hits:
- `scripts/systems/run_manager.gd` owns `_set_phase(...)` and emits `run_phase_changed`.
- `scripts/systems/run/run_flow_executor.gd:28` calls injected hook `_hooks.set_phase_fn.call(...)`.

Status: **PASS** (no independent non-RunManager phase setter found).

---

## B) GameEvents discipline in systems/run/*

### B1
Command:
`rg -n "GameEvents..*.emit\(|GameEvents.[a-zA-Z0-9_]+.emit\(" scripts/systems/run -S`

Result: **0 matches**.

### B2
Command:
`rg -n "GameEvents.[a-zA-Z0-9_]+\s*=\s*|has_signal\(" scripts/systems/run -S`

Result: **0 matches**.

Status: **PASS**.

---

## C) Bet identity resolver discipline

### C1
Command:
`rg -n "(L3_ACTIVE_BET_IDENTITIES|resolve_bet_identity|get_bet_debug_token)" scripts/content/bet_catalog.gd -S`

Hits:
- `scripts/content/bet_catalog.gd:77` (`L3_ACTIVE_BET_IDENTITIES`)
- `scripts/content/bet_catalog.gd:576` (`resolve_bet_identity`)
- `scripts/content/bet_catalog.gd:591` (`get_bet_debug_token`)

### C2
Command:
`rg -n "(CASH_OUT|DOUBLE_OR_DIE)" scripts/ui/betting_circle_ui.gd -S`

Result: **0 matches**.

### C3
Command:
`rg -n "(resolve_bet_identity|level3_active_bet_ids|level3_active_bets|get_bet_debug_token)" scripts/ui/betting_circle_ui.gd -S`

Hits:
- `scripts/ui/betting_circle_ui.gd:92`
- `scripts/ui/betting_circle_ui.gd:97`
- `scripts/ui/betting_circle_ui.gd:107`

### C4
Command:
`rg -n "(display_title\s*=|display_subtitle\s*=|path_tag\s*=)" scripts data -S`

Result: **0 matches**.

Status: **PASS**.

---

## D) Offer sizing + determinism alignment

### D1
Command:
`rg -n "desired_count\s*=\s*4" scripts/systems/run_manager.gd scripts/systems/run/betting_policy.gd -S`

Result: **0 matches** (strict assignment form).

### D2
Command:
`rg -n "desired_count\s*=\s*(BetCatalog.level3_active_bet_ids().size()|.*active_bet_ids.*size()|2)" scripts/systems/run_manager.gd -S`

Result: **0 matches** (regex form mismatch).

Manual corroboration hit:
- `scripts/systems/run_manager.gd:1711` `var desired_count: int = BetCatalog.level3_active_bet_ids().size()`

### D3
Command:
`rg -n "min\(\s*desired_count\s*,\s*available_bets.size\(\)\s*\)" scripts/systems/run/betting_policy.gd -S`

Result: **0 matches** (implementation uses `mini(...)` equivalent).

Manual corroboration hit:
- `scripts/systems/run/betting_policy.gd:15` `desired_count = mini(desired_count, available_bets.size())`

### D4
Command:
`rg -n "(RandomNumberGenerator|randf(|randi(|shuffle()" scripts/systems/run/betting_policy.gd -S`

Hits:
- `scripts/systems/run/betting_policy.gd:20` RNG init
- `scripts/systems/run/betting_policy.gd:21` `rng.seed = rng_seed`
- `scripts/systems/run/betting_policy.gd:164` RNG init (context line helper)
- `scripts/systems/run/betting_policy.gd:165` deterministic seed expression

Status: **FAIL (drift risk)** due default fallback count:
- `scripts/systems/run/betting_policy.gd:14` uses `config.get("desired_count", 4)`.

Excerpt:
```gdscript
var available_bets: Array[Dictionary] = config.get("available_bets", []) as Array[Dictionary]
var desired_count: int = int(config.get("desired_count", 4))
desired_count = mini(desired_count, available_bets.size())
```

---

## E) Ending rules dominance + deterministic tie-break + trace source

### E1
Command:
`rg -n "(dominant_rules\s*=\s*\[|morale_fallback_rules\s*=\s*\[)" data/ending_rules.gd -S`

Result: **0 matches** (rules defined as static funcs, not assigned arrays).

Manual corroboration:
- `data/ending_rules.gd:16` `static func dominant_rules()`
- `data/ending_rules.gd:30` `static func morale_fallback_rules()`

### E2
Command:
`rg -n "(_pick_best_rule|priority|index|declaration order|stable)" scripts/systems/run/finale_builder.gd -S`

Hits include deterministic tie-break:
- `_pick_best_rule` function
- `priority` compare and `idx < best_index` fallback

### E3
Command:
`rg -n "(condanna_registry_count|condanne_this_run)" scripts/systems/run/finale_builder.gd scripts/systems/run_manager.gd -S`

Hits include:
- Source-of-truth count from `_run_state.condanne_this_run.size()` in RunManager
- Trace carries `condanna_registry_count`
- FinaleBuilder reads trace key

### E4
Command:
`rg -n "(condanna_registry_count|condanna_count)" data/ending_rules.gd scripts/systems/run/finale_builder.gd -S`

Hits:
- `scripts/systems/run/finale_builder.gd:106` `trace.get("condanna_registry_count", trace.get("condanna_count", 0))`

Status: **PASS** (dominant-first + deterministic tie-break + explicit legacy fallback).

---

## F) No schema drift into saves

### F1
Command:
`rg -n "(to_dict(|from_dict(|serialize|deserialize|save_payload|load_run_payload|apply_run_payload)" scripts -S`

Result: multiple expected serialization method hits in `run_state.gd`, `save_system.gd`, `run_manager.gd`.

### F2
Command:
`rg -n "(display_title|display_subtitle|path_tag|matched_rule_id|BET_|condanna_registry_count)" scripts/systems/run scripts/systems/run_manager.gd -S`

Result: many semantic hits, but audit of save boundary write paths shows runtime payload schema limited to:
- `level3_schema`, `arena_index`, `coins`, `corruption`, `upgrades`.

Status: **PASS** (no banned debug/alias/trace keys observed in save payload construction).

---

## G) CI guard coverage

Commands:
- `python3 scripts/ci/test_level3_bet_offer_contract.py` → exit 0
- `python3 scripts/ci/test_level3_ending_rules_contract.py` → exit 0
- `python3 scripts/ci/test_identity_resolver_contract.py` → exit 0

Status: **PASS**.

---

## Audit conclusion

- **AUDIT RED**
- Failing sections:
  - **A1**: non-UI `request_*` emitters in `scripts/systems/run_manager.gd` (smoke driver pathway).
  - **D**: offer sizing drift risk from fallback `desired_count` default `4` in `scripts/systems/run/betting_policy.gd`.

Immediate stop-condition checks:
- Parallel ending selector authority: **not detected**.
- GameEvents emission in `systems/run/*`: **not detected**.
- Serialization of alias/trace/debug fields: **not detected**.
