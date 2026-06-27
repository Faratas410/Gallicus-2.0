#!/usr/bin/env python3
"""Static guard for the canonical ritual-loop contract surfaces."""

from __future__ import annotations

import re
from pathlib import Path


def fail(message: str) -> int:
    print(f"[FAIL][RITUAL_LOOP_CONTRACT] {message}")
    return 1


def main() -> int:
    game_events_path = Path("scripts/systems/game_events.gd")
    run_manager_path = Path("scripts/systems/run_manager.gd")
    smoke_runner_path = Path("scripts/ci/run_headless_smoke.py")
    smoke_workflow_path = Path(".github/workflows/godot_smoke_runtime.yml")
    contract_doc_path = Path("docs/contracts/ritual_loop_contract_v1.md")

    for required_path in (
        game_events_path,
        run_manager_path,
        smoke_runner_path,
        smoke_workflow_path,
        contract_doc_path,
    ):
        if not required_path.exists():
            return fail(f"missing required file: {required_path}")

    game_events = game_events_path.read_text(encoding="utf-8")
    run_manager = run_manager_path.read_text(encoding="utf-8")
    smoke_runner = smoke_runner_path.read_text(encoding="utf-8")
    smoke_workflow = smoke_workflow_path.read_text(encoding="utf-8")
    contract_doc = contract_doc_path.read_text(encoding="utf-8")

    required_gameevents_signals = (
        "signal request_new_run",
        "signal request_place_bet(bet_id: String, stake: int)",
        "signal request_mid_choice_select(index: int)",
        "signal request_pyl_cashout",
        "signal request_pyl_double",
        "signal run_finale_selected(payload: Dictionary)",
        "signal run_failed",
    )
    for token in required_gameevents_signals:
        if token not in game_events:
            return fail(f"missing ritual-loop GameEvents signal: {token}")

    required_run_manager_handlers = (
        "func _on_request_new_run() -> void:",
        "func _on_request_place_bet(bet_id: String, _stake: int) -> void:",
        "func _on_request_mid_choice_select(index: int) -> void:",
        "func _on_request_pyl_cashout() -> void:",
        "func _on_request_pyl_double() -> void:",
        "func _enter_bet_present() -> void:",
        "func _enter_push_your_luck() -> void:",
        "func _enter_game_over() -> void:",
    )
    for token in required_run_manager_handlers:
        if token not in run_manager:
            return fail(f"missing ritual-loop RunManager handler/phase entry: {token}")

    push_luck_entry = re.search(
        r"(?ms)^func _enter_push_your_luck\(\) -> void:\n(.*?)(?=^func |\Z)",
        run_manager,
    )
    if push_luck_entry is None:
        return fail("missing _enter_push_your_luck implementation")
    if "_build_push_luck_ui_payload" not in push_luck_entry.group(1):
        return fail("PUSH_YOUR_LUCK entry must emit canonical lock-aware UI payload")

    required_smoke_marks = (
        '_smoke_mark("BET_PRESENT")',
        '_smoke_mark("INTERMEDIATE_CHOICE")',
        '_smoke_mark("PUSH_YOUR_LUCK")',
        '_smoke_mark("END_RUN")',
        '_smoke_mark_kv("END_RUN_FINAL", "ending_key", register_ending_key)',
    )
    for token in required_smoke_marks:
        if token not in run_manager:
            return fail(f"missing required smoke milestone marker in RunManager: {token}")

    required_smoke_runner_tokens = (
        'SCENARIO_BET_PRESENT = "BET_PRESENT"',
        'SCENARIO_FULL_RUN = "FULL_RUN"',
        '"SMOKE:MILESTONE=BET_PRESENT"',
        '"SMOKE:MILESTONE=PACT_SEALED_OPENED"',
        '"SMOKE:MILESTONE=PACT_SEALED_CLOSED"',
        '"SMOKE:MILESTONE=INTERMEDIATE_CHOICE"',
        '"SMOKE:MILESTONE=RESOLVE_OPENED"',
        '"SMOKE:MILESTONE=RESOLVE_CLOSED"',
        '"SMOKE:MILESTONE=PUSH_YOUR_LUCK"',
        '"SMOKE:MILESTONE=END_RUN"',
        '"SMOKE:MILESTONE=END_RUN_FINAL ending_key="',
    )
    for token in required_smoke_runner_tokens:
        if token not in smoke_runner:
            return fail(f"missing smoke runner ritual-loop token: {token}")

    required_workflow_tokens = (
        "BET_PRESENT",
        "FULL_RUN",
        "python3 scripts/ci/run_headless_smoke.py",
    )
    for token in required_workflow_tokens:
        if token not in smoke_workflow:
            return fail(f"missing smoke workflow ritual-loop coverage token: {token}")

    required_contract_doc_tokens = (
        "# Ritual Loop Contract v1",
        "BET_PRESENT",
        "FULL_RUN",
        "RunManager remains sole authority",
    )
    for token in required_contract_doc_tokens:
        if token not in contract_doc:
            return fail(f"missing ritual-loop contract doc token: {token}")

    print("[OK][RITUAL_LOOP_CONTRACT] ritual loop contract guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
