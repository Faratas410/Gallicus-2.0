#!/usr/bin/env python3
"""Guard the three-feature CI checkpoint cadence and risk exceptions."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
WORKFLOW = ROOT / ".github/workflows/godot_smoke_runtime.yml"
MARKER = ROOT / ".github/ci/full_suite_checkpoint.txt"
TESTING_DOC = ROOT / "docs/testing.md"
ROADMAP = ROOT / "docs/development_plan.md"

CHECKPOINTS = ("OF-06", "OF-09", "OF-11")
RISK_PATHS = (
    ".github/ci/full_suite_checkpoint.txt",
    ".github/workflows/godot_smoke_runtime.yml",
    "project.godot",
    "scripts/systems/game_events.gd",
    "scripts/systems/run_manager.gd",
    "scripts/systems/save_manager.gd",
    "scripts/systems/run/**",
    "scripts/contracts/**",
)
STATIC_TESTS = (
    "test_headless_smoke_validator.py",
    "check_docs_active_refs.py",
    "verify_res_paths.py",
    "test_ritual_loop_contract.py",
    "test_era_visual_template_audit.py",
    "test_pressure_presentation_contract.py",
    "test_ui_motion_contract.py",
    "test_i18n_contract.py",
    "test_receipt_object_contract.py",
    "test_condemnation_mark_object_contract.py",
    "test_second_incision_object_contract.py",
    "test_arena_threshold_object_contract.py",
    "test_registry_table_object_contract.py",
    "test_promise_signature_object_contract.py",
    "test_pact_tablet_object_contract.py",
    "test_arena_gesture_object_contract.py",
    "test_judgment_seal_object_contract.py",
    "test_ci_checkpoint_contract.py",
    "test_release_content_contract.py",
    "test_no_mojibake.py",
)


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing CI checkpoint file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def _job_block(workflow: str, job_name: str) -> str:
    match = re.search(
        rf"(?ms)^  {re.escape(job_name)}:\n.*?(?=^  [a-zA-Z0-9_]+:\n|\Z)",
        workflow,
    )
    if match is None:
        raise AssertionError(f"workflow missing job: {job_name}")
    return match.group(0)


def _assert_marker() -> None:
    marker = _read(MARKER)
    active_line = next((line.strip() for line in marker.splitlines() if line.strip() and not line.lstrip().startswith("#")), "")
    if active_line not in CHECKPOINTS:
        raise AssertionError(f"active full-suite marker must be a scheduled checkpoint, got {active_line!r}")
    for checkpoint in CHECKPOINTS:
        if checkpoint not in marker:
            raise AssertionError(f"checkpoint marker must document {checkpoint}")


def _assert_workflow() -> None:
    workflow = _read(WORKFLOW)
    if "workflow_dispatch:" not in workflow:
        raise AssertionError("full CI must remain manually dispatchable")
    if "pull_request:" in workflow:
        raise AssertionError("direct-main workflow must not run automatically for pull requests")
    if "branches: [main]" not in workflow or "paths:" not in workflow:
        raise AssertionError("automatic full CI must be a path-filtered main push trigger")
    for risk_path in RISK_PATHS:
        if f'"{risk_path}"' not in workflow:
            raise AssertionError(f"workflow missing checkpoint/risk trigger path: {risk_path}")

    static_block = _job_block(workflow, "static_contracts")
    smoke_block = _job_block(workflow, "smoke_runtime")
    visual_block = _job_block(workflow, "visual_qa_object_first")
    for test_name in STATIC_TESTS:
        if static_block.count(test_name) != 1:
            raise AssertionError(f"static contract must run exactly once in static_contracts: {test_name}")
        if test_name in smoke_block or test_name in visual_block:
            raise AssertionError(f"static contract must not be repeated by downstream jobs: {test_name}")
    if "needs: static_contracts" not in smoke_block:
        raise AssertionError("six-scenario smoke matrix must depend on static_contracts")
    if "needs: static_contracts" not in visual_block:
        raise AssertionError("visual QA must depend on static_contracts")
    for scenario in (
        "BET_PRESENT",
        "FULL_RUN",
        "ROUTE_CASHOUT",
        "ROUTE_DOUBLE",
        "ROUTE_CONDANNA",
        "ROUTE_REGISTER_FINAL",
    ):
        if scenario not in smoke_block:
            raise AssertionError(f"smoke matrix missing canonical scenario: {scenario}")
    for token in (
        "PROMISE_COUNT",
        "03_promise_*.png",
        'test "$PROMISE_COUNT" -eq 30',
        "PACT_COUNT",
        "04_pact_??_*.png",
        'test "$PACT_COUNT" -eq 24',
        "GESTURE_COUNT",
        "05_gesture_*.png",
        'test "$GESTURE_COUNT" -eq 36',
        "JUDGMENT_COUNT",
        "06_judgment_*.png",
        'test "$JUDGMENT_COUNT" -eq 30',
    ):
        if token not in visual_block:
            raise AssertionError(f"checkpoint visual job missing Object-First token: {token}")


def _assert_documentation() -> None:
    testing = _read(TESTING_DOC)
    roadmap = _read(ROADMAP)
    combined = f"{testing}\n{roadmap}"
    for checkpoint in CHECKPOINTS:
        if checkpoint not in combined:
            raise AssertionError(f"testing/roadmap must document checkpoint {checkpoint}")
    for phrase in ("checkpoint", "signoff cumulativo", "workflow_dispatch"):
        if phrase not in combined:
            raise AssertionError(f"testing/roadmap missing CI cadence phrase: {phrase}")


def main() -> int:
    _assert_marker()
    _assert_workflow()
    _assert_documentation()
    print("[OK][CI_CHECKPOINT_CONTRACT] checkpoint cadence and risk exceptions passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
