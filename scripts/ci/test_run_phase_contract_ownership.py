#!/usr/bin/env python3
"""Static contract guard for RunPhase identity ownership."""

from __future__ import annotations

import re
from pathlib import Path


def fail(message: str) -> int:
    print(f"[FAIL][RUN_PHASE_CONTRACT_OWNERSHIP] {message}")
    return 1


def _extract_runphase_enum_block(run_manager: str) -> str | None:
    marker = "enum RunPhase {"
    start = run_manager.find(marker)
    if start < 0:
        return None
    end = run_manager.find("\n}", start)
    if end < 0:
        return None
    return run_manager[start : end + 2]


def main() -> int:
    contract_path = Path("scripts/contracts/run_phase_contract.gd")
    run_manager_path = Path("scripts/systems/run_manager.gd")
    smoke_driver_path = Path("scripts/systems/run/smoke_driver.gd")
    flow_diagnostics_path = Path("scripts/systems/run/flow_diagnostics.gd")
    music_director_path = Path("scripts/audio/music_director.gd")
    ui_root_path = Path("scripts/ui/ui_root.gd")
    ui_main_menu_path = Path("scripts/ui/main_menu.gd")
    ui_scripts_root = Path("scripts/ui")
    audit_tool_path = Path("tools/audit_phase_contract.gd")

    for required in (
        contract_path,
        run_manager_path,
        smoke_driver_path,
        flow_diagnostics_path,
        music_director_path,
        ui_root_path,
        ui_main_menu_path,
        ui_scripts_root,
        audit_tool_path,
    ):
        if not required.exists():
            return fail(f"missing required file: {required}")

    contract = contract_path.read_text(encoding="utf-8")
    run_manager = run_manager_path.read_text(encoding="utf-8")
    smoke_driver = smoke_driver_path.read_text(encoding="utf-8")
    flow_diagnostics = flow_diagnostics_path.read_text(encoding="utf-8")
    music_director = music_director_path.read_text(encoding="utf-8")
    ui_root = ui_root_path.read_text(encoding="utf-8")
    ui_main_menu = ui_main_menu_path.read_text(encoding="utf-8")
    audit_tool = audit_tool_path.read_text(encoding="utf-8")

    required_contract_constants = (
        "const MAIN_MENU: int = 10",
        "const RUN_INIT: int = 11",
        "const BET_PRESENT: int = 12",
        "const BET_COMMITTED: int = 13",
        "const INTERMEDIATE_CHOICE: int = 15",
        "const PUSH_YOUR_LUCK: int = 16",
        "const NEXT_BET: int = 17",
        "const RESOLUTION: int = 18",
    )
    for token in required_contract_constants:
        if token not in contract:
            return fail(f"missing phase constant in RunPhaseContract: {token}")

    if "const NAME_BY_ID: Dictionary" not in contract:
        return fail("RunPhaseContract must expose NAME_BY_ID mapping")
    if "const CANONICAL_LIVE_PHASE_IDS: Array[int]" not in contract:
        return fail("RunPhaseContract must expose CANONICAL_LIVE_PHASE_IDS")
    if "static func get_name(phase_id: int) -> String" not in contract:
        return fail("RunPhaseContract must expose get_name(phase_id)")
    if "const POST_BET_MESSAGES: int = 14" not in contract:
        return fail("RunPhaseContract must keep POST_BET_MESSAGES compat slot id")

    enum_block = _extract_runphase_enum_block(run_manager)
    if enum_block is None:
        return fail("RunManager must define enum RunPhase mirror block")

    if re.search(r"=\s*-?\d+\s*,?", enum_block):
        return fail("RunManager enum RunPhase must not hardcode numeric ids")

    mirror_names = (
        "NONE",
        "PREP",
        "LIVE",
        "GAME_OVER",
        "MAIN_MENU",
        "RUN_INIT",
        "BET_PRESENT",
        "BET_COMMITTED",
        "POST_BET_MESSAGES",
        "INTERMEDIATE_CHOICE",
        "PUSH_YOUR_LUCK",
        "NEXT_BET",
        "RESOLUTION",
    )
    for name in mirror_names:
        expected = f"{name} = RunPhaseContractScript.{name}"
        if expected not in enum_block:
            return fail(f"RunManager enum must mirror RunPhaseContract identity: missing '{expected}'")

    if "return RunPhaseContractScript.get_name(int(phase))" not in run_manager:
        return fail("RunManager phase-to-name path must use RunPhaseContractScript.get_name")
    if "str(_phase)" in run_manager:
        return fail("run_manager diagnostics must not stringify raw phase ids with str(_phase)")
    if "str(payload.phase)" in run_manager:
        return fail("run_manager diagnostics must not stringify raw payload.phase")
    if 'log_phase(str(' in run_manager:
        return fail("run_manager phase logging must not use ad-hoc str(...) phase naming")
    if "format_phase_debug_line(_phase_to_name(next), reason)" not in run_manager:
        return fail("run_manager debug phase line must use contract-driven phase name")
    if "phase=%s\" % RunPhaseContractScript.get_name(int(payload.phase))" not in run_manager:
        return fail("run_manager UI flow logs must render phase names via RunPhaseContractScript.get_name")

    if "func format_phase_debug_line(phase_name: String, reason: String) -> String" not in flow_diagnostics:
        return fail("flow_diagnostics phase debug formatter must accept contract-driven phase names")

    if "RunPhaseContract.INTERMEDIATE_CHOICE" not in ui_root:
        return fail("ui_root must reference RunPhaseContract constants directly")
    if "RunPhaseContract.POST_BET_MESSAGES" in ui_root:
        return fail("ui_root must not keep POST_BET_MESSAGES in live phase map/wiring")
    if "RunPhaseContractScript.POST_BET_MESSAGES" in music_director:
        return fail("music_director must not treat POST_BET_MESSAGES as active track-routing phase")
    if "RunPhaseContractScript.MAIN_MENU" not in ui_main_menu:
        return fail("main_menu must use RunPhaseContractScript constants directly")
    if "RunPhaseContract.get_name(" not in ui_root:
        return fail("ui_root phase mapping diagnostics must use RunPhaseContract.get_name")
    if re.search(r"RunPhase\.POST_BET_MESSAGES\b", run_manager):
        return fail("run_manager must not accept/route live RunPhase.POST_BET_MESSAGES surfaces")

    # UI phase aliases are forbidden unless explicitly marked as compatibility-only.
    alias_pattern = re.compile(r"(?m)^\s*const\s+RUN_PHASE_[A-Z0-9_]+\s*:")
    for ui_script_path in sorted(ui_scripts_root.rglob("*.gd")):
        script_text = ui_script_path.read_text(encoding="utf-8")
        for index, line in enumerate(script_text.splitlines(), start=1):
            if not alias_pattern.search(line):
                continue
            if "COMPAT_ONLY_PHASE_ALIAS" in line:
                continue
            return fail(
                "ui phase alias constant forbidden unless compatibility-only: "
                f"{ui_script_path}:{index}"
            )

    # SmokeDriver may compare phase-name tokens, but names must be derived from RunPhaseContract.get_name.
    required_smoke_phase_name_consts = (
        "const PHASE_NAME_MAIN_MENU: String = RunPhaseContractScript.get_name(RunPhaseContractScript.MAIN_MENU)",
        "const PHASE_NAME_RUN_INIT: String = RunPhaseContractScript.get_name(RunPhaseContractScript.RUN_INIT)",
        "const PHASE_NAME_BET_PRESENT: String = RunPhaseContractScript.get_name(RunPhaseContractScript.BET_PRESENT)",
    )
    for token in required_smoke_phase_name_consts:
        if token not in smoke_driver:
            return fail(f"smoke_driver must derive phase name from contract: missing '{token}'")
    if re.search(r'phase_name\s*==\s*"[^"]+"', smoke_driver):
        return fail("smoke_driver must not compare phase_name against raw string literals")

    # Phase name map duplication is forbidden outside RunPhaseContract.
    for gd_path in sorted(Path("scripts").rglob("*.gd")) + sorted(Path("tools").rglob("*.gd")):
        if gd_path == contract_path:
            continue
        gd_text = gd_path.read_text(encoding="utf-8")
        if "const NAME_BY_ID: Dictionary" in gd_text:
            return fail(f"duplicate NAME_BY_ID phase-name map outside RunPhaseContract: {gd_path}")

    if "_RUN_PHASE_CONTRACT_PATH: String = \"res://scripts/contracts/run_phase_contract.gd\"" not in audit_tool:
        return fail("audit_phase_contract tool must read RunPhaseContract as phase identity source")

    print("[OK][RUN_PHASE_CONTRACT_OWNERSHIP] run phase identity ownership guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
