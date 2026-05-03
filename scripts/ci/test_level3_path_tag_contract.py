#!/usr/bin/env python3
"""Static guard for Level-3 path-tag taxonomy and authoritative derivation."""

from __future__ import annotations

from pathlib import Path

BET_CATALOG = Path("scripts/content/bet_catalog.gd")
FINALE_BUILDER = Path("scripts/systems/run/finale_builder.gd")
RUN_MANAGER = Path("scripts/systems/run_manager.gd")
ENDING_RULES = Path("data/ending_rules.gd")


def has_bet_catalog_call(source: str, method: str) -> bool:
    return f"BetCatalog.{method}(" in source or f"BetCatalogScript.{method}(" in source


def fail(message: str) -> int:
    print(f"[FAIL][L3_PATH_TAG_CONTRACT] {message}")
    return 1


def main() -> int:
    for path in [BET_CATALOG, FINALE_BUILDER, RUN_MANAGER, ENDING_RULES]:
        if not path.exists():
            return fail(f"missing file: {path}")

    catalog = BET_CATALOG.read_text(encoding="utf-8")
    finale_builder = FINALE_BUILDER.read_text(encoding="utf-8")
    run_manager = RUN_MANAGER.read_text(encoding="utf-8")
    ending_rules = ENDING_RULES.read_text(encoding="utf-8")

    required_constants = [
        "PATH_UNKNOWN",
        "PATH_PRUDENCE",
        "PATH_HUBRIS",
        "PATH_PENITENCE",
        "PATH_VIOLENCE",
    ]
    for token in required_constants:
        if f"const {token}: StringName" not in catalog:
            return fail(f"bet_catalog.gd missing taxonomy constant: {token}")

    if "static func get_path_tag_for_bet_id(bet_id: StringName) -> StringName:" not in catalog:
        return fail("bet_catalog.gd must define get_path_tag_for_bet_id()")
    if "return PATH_UNKNOWN" not in catalog:
        return fail("get_path_tag_for_bet_id() must provide PATH_UNKNOWN fallback")

    if "build_path_trace_from_bet_history" not in finale_builder:
        return fail("finale_builder.gd must define authoritative path trace builder")
    if not has_bet_catalog_call(finale_builder, "get_path_tag_for_bet_id"):
        return fail("finale_builder.gd must derive paths via BetCatalog.get_path_tag_for_bet_id()")
    for token in ["path_prudence_count", "path_hubris_count"]:
        if token not in finale_builder:
            return fail(f"finale_builder.gd missing explicit trace counter: {token}")

    if "_finale_builder.build_path_trace_from_bet_history(_run_state.bets_history)" not in run_manager:
        return fail("run_manager.gd must source path trace from bets_history only")

    if "min_path_prudence" not in ending_rules:
        return fail("ending_rules.gd must use standardized min_path_prudence key")
    if "min_path_hubris" not in ending_rules:
        return fail("ending_rules.gd must use standardized min_path_hubris key")

    print("[OK][L3_PATH_TAG_CONTRACT] taxonomy + derivation guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
