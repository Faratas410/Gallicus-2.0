#!/usr/bin/env python3
"""Static contract guard for legacy RESOLUTION normalization boundary."""

from __future__ import annotations

import re
from pathlib import Path


def fail(message: str) -> int:
    print(f"[FAIL][RESOLUTION_BOUNDARY_CONTRACT] {message}")
    return 1


def main() -> int:
    save_boundary_path = Path("scripts/systems/run/save_continue_boundary.gd")
    run_manager_path = Path("scripts/systems/run_manager.gd")
    ui_root_path = Path("scripts/ui/ui_root.gd")

    for required in (save_boundary_path, run_manager_path, ui_root_path):
        if not required.exists():
            return fail(f"missing required file: {required}")

    save_boundary = save_boundary_path.read_text(encoding="utf-8")
    run_manager = run_manager_path.read_text(encoding="utf-8")
    ui_root = ui_root_path.read_text(encoding="utf-8")

    if "func _normalize_flow_step_at_boundary" not in save_boundary:
        return fail("save boundary must declare _normalize_flow_step_at_boundary")
    if "_normalize_flow_step_at_boundary(run_state, payload, run_data)" not in save_boundary:
        return fail("save boundary must invoke boundary normalization during apply_payload_to_state")

    if "allowed_phases.append(RunPhase.RESOLUTION)" in run_manager:
        return fail("run_manager must not keep request-guard RESOLUTION append allowances")

    if re.search(r"_guard_request_phase\([^)]*RunPhase\.RESOLUTION", run_manager):
        return fail("run_manager request guards must not accept RunPhase.RESOLUTION")
    if re.search(r"_route_guarded_phase_request\([^)]*RunPhase\.RESOLUTION", run_manager):
        return fail("run_manager routed request guards must not accept RunPhase.RESOLUTION")

    if "RUN_PHASE_RESOLUTION_COMPAT" in ui_root:
        return fail("ui_root must not keep live resolution compat phase mapping constant")

    print("[OK][RESOLUTION_BOUNDARY_CONTRACT] legacy resolution boundary guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
