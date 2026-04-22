#!/usr/bin/env python3
"""Static contract guard for strict run_save_flow_step governance."""

from __future__ import annotations

import re
from pathlib import Path


def fail(message: str) -> int:
    print(f"[FAIL][RUN_SAVE_FLOW_STEP_CONTRACT] {message}")
    return 1


def main() -> int:
    contract_path = Path("scripts/contracts/run_save_flow_step_contract.gd")
    run_manager_path = Path("scripts/systems/run_manager.gd")
    save_boundary_path = Path("scripts/systems/run/save_continue_boundary.gd")
    save_system_path = Path("scripts/systems/run/save_system.gd")

    for required in (contract_path, run_manager_path, save_boundary_path, save_system_path):
        if not required.exists():
            return fail(f"missing required file: {required}")

    contract = contract_path.read_text(encoding="utf-8")
    run_manager = run_manager_path.read_text(encoding="utf-8")
    save_boundary = save_boundary_path.read_text(encoding="utf-8")
    save_system = save_system_path.read_text(encoding="utf-8")

    for token in (
        "const BET_SIGNED: StringName = &\"BET_SIGNED\"",
        "const INTERMEDIATE_CHOICE: StringName = &\"INTERMEDIATE_CHOICE\"",
        "const PUSH_LUCK: StringName = &\"PUSH_LUCK\"",
        "const BET_OFFER: StringName = &\"BET_OFFER\"",
    ):
        if token not in contract:
            return fail(f"missing canonical constant in contract: {token}")

    if "const RUN_FLOW_BET_SIGNED" in run_manager or "const RUN_FLOW_BET_OFFER" in run_manager:
        return fail("run_manager must not define local RUN_FLOW_* string constants")

    if "RunSaveFlowStepContractScript.normalize_boundary_value(" not in save_boundary:
        return fail("save_continue_boundary must normalize flow_step via centralized contract helper")

    if "RunSaveFlowStepContractScript.BET_OFFER" not in save_system:
        return fail("save_system default flow_step must use contract canonical BET_OFFER constant")

    if re.search(r'flow_step\s*==\s*&"', run_manager):
        return fail("run_manager must not compare run_save_flow_step against ad-hoc string literals")

    if "RunSaveFlowStepContractScript.is_canonical_live_value(_run_state.run_save_flow_step)" not in run_manager:
        return fail("run_manager must validate canonical run_save_flow_step before resume dispatch")

    print("[OK][RUN_SAVE_FLOW_STEP_CONTRACT] strict flow-step contract guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
