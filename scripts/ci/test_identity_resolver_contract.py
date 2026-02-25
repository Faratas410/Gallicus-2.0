#!/usr/bin/env python3
"""Static guard for single-source Level-3 bet identity resolver."""

from __future__ import annotations

from pathlib import Path

BET_CATALOG = Path("scripts/content/bet_catalog.gd")
BETTING_UI = Path("scripts/ui/betting_circle_ui.gd")
RUN_MANAGER = Path("scripts/systems/run_manager.gd")


def fail(message: str) -> int:
    print(f"[FAIL][IDENTITY_RESOLVER_CONTRACT] {message}")
    return 1


def main() -> int:
    for path in [BET_CATALOG, BETTING_UI, RUN_MANAGER]:
        if not path.exists():
            return fail(f"missing file: {path}")

    catalog = BET_CATALOG.read_text(encoding="utf-8")
    betting_ui = BETTING_UI.read_text(encoding="utf-8")
    run_manager = RUN_MANAGER.read_text(encoding="utf-8")

    if "const L3_ACTIVE_BET_IDENTITIES" not in catalog:
        return fail("bet_catalog.gd must define L3_ACTIVE_BET_IDENTITIES")
    if "static func resolve_bet_identity(bet_id: StringName) -> Dictionary:" not in catalog:
        return fail("bet_catalog.gd must expose resolve_bet_identity()")
    for token in ["BET_CASH_OUT", "BET_DOUBLE_OR_DIE"]:
        if token not in catalog:
            return fail(f"bet_catalog.gd missing identity token entry: {token}")

    if "BetCatalog.resolve_bet_identity" not in betting_ui:
        return fail("betting_circle_ui.gd must source labels via resolve_bet_identity()")
    if '&"CASH_OUT"' in betting_ui or '&"DOUBLE_OR_DIE"' in betting_ui:
        return fail("betting_circle_ui.gd must not hardcode active bet ids")

    if "BetCatalog.get_bet_debug_token" not in run_manager:
        return fail("run_manager.gd logs must use stable identity token")

    print("[OK][IDENTITY_RESOLVER_CONTRACT] identity resolver contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
