#!/usr/bin/env python3
"""Static contract guard for legacy POST_BET_MESSAGES boundary normalization."""

from __future__ import annotations

import re
from pathlib import Path


def fail(message: str) -> int:
    print(f"[FAIL][POST_BET_BOUNDARY_CONTRACT] {message}")
    return 1


def main() -> int:
    contract_path = Path("scripts/contracts/run_save_flow_step_contract.gd")
    save_boundary_path = Path("scripts/systems/run/save_continue_boundary.gd")
    run_manager_path = Path("scripts/systems/run_manager.gd")
    ui_root_path = Path("scripts/ui/ui_root.gd")
    music_director_path = Path("scripts/audio/music_director.gd")

    for required in (
        contract_path,
        save_boundary_path,
        run_manager_path,
        ui_root_path,
        music_director_path,
    ):
        if not required.exists():
            return fail(f"missing required file: {required}")

    contract = contract_path.read_text(encoding="utf-8")
    save_boundary = save_boundary_path.read_text(encoding="utf-8")
    run_manager = run_manager_path.read_text(encoding="utf-8")
    ui_root = ui_root_path.read_text(encoding="utf-8")
    music_director = music_director_path.read_text(encoding="utf-8")

    for token in (
        '&"POST_BET_MESSAGES": INTERMEDIATE_CHOICE',
        '&"RUN_FLOW_POST_BET_MESSAGES": INTERMEDIATE_CHOICE',
        '&"PHASE_POST_BET_MESSAGES": INTERMEDIATE_CHOICE',
        '&"14": INTERMEDIATE_CHOICE',
    ):
        if token not in contract:
            return fail(f"missing POST_BET_MESSAGES legacy mapping in flow-step contract: {token}")

    if "const LEGACY_POST_BET_MESSAGES_PHASE_VALUE: int = 14" not in save_boundary:
        return fail("save boundary must define legacy POST_BET_MESSAGES phase value constant")
    if "run_phase == LEGACY_POST_BET_MESSAGES_PHASE_VALUE" not in save_boundary:
        return fail("save boundary must normalize run.phase POST_BET_MESSAGES value")
    if "run_state_phase == LEGACY_POST_BET_MESSAGES_PHASE_VALUE" not in save_boundary:
        return fail("save boundary must normalize run_state.phase POST_BET_MESSAGES value")
    if "legacy_non_mainline_phase_seen" not in contract and "legacy_non_mainline_phase_seen" not in save_boundary:
        return fail("boundary normalization path must be explicit for non-mainline legacy phases")

    if re.search(r"RunPhase\.POST_BET_MESSAGES\b", run_manager):
        return fail("run_manager must not accept/route POST_BET_MESSAGES as live phase")
    if "RunPhaseContract.POST_BET_MESSAGES" in ui_root:
        return fail("ui_root must not wire POST_BET_MESSAGES in live phase map")
    if "RunPhaseContractScript.POST_BET_MESSAGES" in music_director:
        return fail("music_director must not treat POST_BET_MESSAGES as active routing phase")

    print("[OK][POST_BET_BOUNDARY_CONTRACT] post-bet boundary normalization guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
