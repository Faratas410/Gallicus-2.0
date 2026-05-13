#!/usr/bin/env python3
"""Static guard for Push Your Luck Posta/Gloria/Corruzione counter contract."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RUN_MANAGER = ROOT / "scripts" / "systems" / "run_manager.gd"
PAYLOAD_FACTORY = ROOT / "scripts" / "systems" / "run" / "betting_payload_factory.gd"
UI_ROOT = ROOT / "scripts" / "ui" / "ui_root.gd"
UI_CANON = ROOT / "docs" / "canon" / "UI_CANON.md"
MECHANICS = ROOT / "docs" / "canon" / "MECHANICS_UNIFIED.md"

PYL_COUNTER_KEYS = [
    "current_glory",
    "current_corruption",
    "stake_glory",
    "cashout_glory_delta",
    "cashout_corruption_delta",
    "double_next_stake_glory",
    "double_pressure_delta",
]


def fail(message: str) -> int:
    print(f"[FAIL][PYL_COUNTER_CONTRACT] {message}")
    return 1


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _function_body(source: str, name: str) -> str:
    match = re.search(rf"(?ms)^func {re.escape(name)}\(.*?(?=^func |\Z)", source)
    if match is None:
        raise AssertionError(f"missing function: {name}")
    return match.group(0)


def main() -> int:
    for path in [RUN_MANAGER, PAYLOAD_FACTORY, UI_ROOT, UI_CANON, MECHANICS]:
        if not path.exists():
            return fail(f"missing file: {path}")

    run_manager = _read(RUN_MANAGER)
    payload_factory = _read(PAYLOAD_FACTORY)
    ui_root = _read(UI_ROOT)
    ui_canon = _read(UI_CANON)
    mechanics = _read(MECHANICS)

    for key in PYL_COUNTER_KEYS:
        if key not in payload_factory:
            return fail(f"BettingPayloadFactory missing PYL counter key: {key}")
        if key not in run_manager:
            return fail(f"RunManager missing PYL counter key: {key}")

    for token in [
        "func _compute_pending_stake_glory",
        "func _compute_success_glory_preview_for_double_count",
        "func _format_push_luck_receipt_text",
        "POSTA VIVA: +%d Gloria",
        "GLORIA: %d",
        "CORRUZIONE: %d",
        "func _format_cashout_note",
        "func _format_double_note",
        "func _format_condanna_note",
    ]:
        if token not in run_manager and token not in ui_root:
            return fail(f"missing PYL counter implementation token: {token}")

    ui_payload_body = _function_body(ui_root, "_apply_push_luck_payload")
    forbidden_ui_calc_tokens = [
        "compute_level3_reward_glory",
        "level3_reward_tier",
        "GLORY_MULT_STEPS",
        "GLORY_PER_SUCCESS",
    ]
    for token in forbidden_ui_calc_tokens:
        if token in ui_payload_body:
            return fail(f"UI must consume PYL counter payload, not calculate reward: {token}")

    for token in [
        "Posta",
        "Gloria",
        "Corruzione",
        "UI resta reattiva",
    ]:
        if token not in ui_canon:
            return fail(f"UI_CANON.md missing PYL counter doc token: {token}")

    for token in [
        "Posta = Gloria incassabile dalla scommessa corrente",
        "Incassa converte la Posta in Gloria",
        "Raddoppia aumenta la Posta futura",
    ]:
        if token not in mechanics:
            return fail(f"MECHANICS_UNIFIED.md missing PYL counter mechanics token: {token}")

    print("[OK][PYL_COUNTER_CONTRACT] push-your-luck counter guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
