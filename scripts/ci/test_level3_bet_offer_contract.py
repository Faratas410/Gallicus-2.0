#!/usr/bin/env python3
"""Static guard for active Level-3 two-offer contract."""

from __future__ import annotations

import re
import sys
from pathlib import Path

BET_CATALOG = Path("scripts/content/bet_catalog.gd")
BETS_DATA = Path("data/bets.gd")
RUN_MANAGER = Path("scripts/systems/run_manager.gd")
BETTING_UI = Path("scripts/ui/betting_circle_ui.gd")


def fail(message: str) -> int:
    print(f"[FAIL][L3_BET_OFFER_CONTRACT] {message}")
    return 1


def main() -> int:
    for path in [BET_CATALOG, BETS_DATA, RUN_MANAGER, BETTING_UI]:
        if not path.exists():
            return fail(f"missing file: {path}")

    catalog = BET_CATALOG.read_text(encoding="utf-8")
    bets_data = BETS_DATA.read_text(encoding="utf-8")
    run_manager = RUN_MANAGER.read_text(encoding="utf-8")
    betting_ui = BETTING_UI.read_text(encoding="utf-8")

    helper_decl = re.search(r"static\s+func\s+level3_active_bet_ids\s*\(\)\s*->\s*Array\[StringName\]", catalog)
    if helper_decl is None:
        return fail("BetCatalog must expose level3_active_bet_ids()")

    active_helper_body = re.search(
        r"(?ms)static\s+func\s+level3_active_bet_ids\s*\(\)\s*->\s*Array\[StringName\]\s*:\s*\n(.*?)(?=^\s*static\s+func\s+|\Z)",
        catalog,
    )
    if active_helper_body is None:
        return fail("cannot parse level3_active_bet_ids() body")
    body = active_helper_body.group(1)
    for token in ['BET_CASH_OUT', 'BET_DOUBLE_OR_DIE']:
        if token not in body:
            return fail(f"level3_active_bet_ids() missing {token}")

    if "BetCatalog.level3_active_bet_ids()" not in bets_data:
        return fail("data/bets.gd level3_bet_ids() must delegate to BetCatalog.level3_active_bet_ids()")

    if '"desired_count": 4' in run_manager:
        return fail("run_manager.gd must not hardcode desired_count=4 in level3 offer path")
    if "BetCatalog.level3_active_bets()" not in run_manager:
        return fail("run_manager.gd must build offers from BetCatalog.level3_active_bets()")

    ui_required_tokens = ['&"CASH_OUT"', '&"DOUBLE_OR_DIE"', "bet_option_3.visible = false"]
    missing_ui_tokens = [token for token in ui_required_tokens if token not in betting_ui]
    if missing_ui_tokens:
        return fail("betting_circle_ui.gd missing expected 2-option contract token(s): " + ", ".join(missing_ui_tokens))

    print("[OK][L3_BET_OFFER_CONTRACT] static two-offer contract guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
