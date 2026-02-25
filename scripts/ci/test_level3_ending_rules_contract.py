#!/usr/bin/env python3
"""Static guard for Level-3 dominant ending rules integration."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ENDING_RULES = Path("data/ending_rules.gd")
FINALE_BUILDER = Path("scripts/systems/run/finale_builder.gd")
RUN_MANAGER = Path("scripts/systems/run_manager.gd")
BET_CATALOG = Path("scripts/content/bet_catalog.gd")


def fail(message: str) -> int:
    print(f"[FAIL][L3_ENDING_RULES_CONTRACT] {message}")
    return 1


def _count_rules(source: str, func_name: str) -> int:
    match = re.search(
        rf"(?ms)static\s+func\s+{func_name}\s*\(\)\s*->\s*Array\[Dictionary\]\s*:\s*\n(.*?)(?=^\s*static\s+func\s+|\Z)",
        source,
    )
    if match is None:
        return -1
    body = match.group(1)
    return len(re.findall(r'"id"\s*:\s*"', body))


def main() -> int:
    for path in [ENDING_RULES, FINALE_BUILDER, RUN_MANAGER, BET_CATALOG]:
        if not path.exists():
            return fail(f"missing file: {path}")

    ending_rules = ENDING_RULES.read_text(encoding="utf-8")
    finale_builder = FINALE_BUILDER.read_text(encoding="utf-8")
    run_manager = RUN_MANAGER.read_text(encoding="utf-8")
    bet_catalog = BET_CATALOG.read_text(encoding="utf-8")

    if "func dominant_rules()" not in ending_rules:
        return fail("ending_rules.gd must define dominant_rules()")
    if "func morale_fallback_rules()" not in ending_rules:
        return fail("ending_rules.gd must define morale_fallback_rules()")

    dominant_count = _count_rules(ending_rules, "dominant_rules")
    fallback_count = _count_rules(ending_rules, "morale_fallback_rules")
    if dominant_count < 10:
        return fail(f"dominant_rules() must define >= 10 rules (found {dominant_count})")
    if fallback_count < 4:
        return fail(f"morale_fallback_rules() must define >= 4 rules (found {fallback_count})")

    if "func select_level3_ending_key(run_state: RunState, trace: Dictionary)" not in finale_builder:
        return fail("finale_builder.gd must expose select_level3_ending_key()")
    if "_finale_builder.select_level3_ending_key(_run_state, ending_trace)" not in run_manager:
        return fail("run_manager.gd must call finale_builder.select_level3_ending_key()")
    if 'condanna_registry_count' not in run_manager:
        return fail("run_manager.gd trace must define condanna_registry_count as unique condanna source")
    if "for idx: int in range(rules.size())" not in finale_builder:
        return fail("finale_builder.gd must keep deterministic tie-break on equal priority (rule order)")

    required_catalog_tokens = [
        '"id": "CASH_OUT"',
        '"id": "DOUBLE_OR_DIE"',
        '"display_title"',
        '"path_tag"',
    ]
    missing = [token for token in required_catalog_tokens if token not in bet_catalog]
    if missing:
        return fail("bet_catalog.gd missing bet display alias/path tag token(s): " + ", ".join(missing))

    print("[OK][L3_ENDING_RULES_CONTRACT] dominant + morale ending guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
