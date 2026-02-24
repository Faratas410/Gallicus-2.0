#!/usr/bin/env python3

"""
UI Phase Contract Static Test

VERSION: 2 (function-scoped heuristic)

This test verifies that:

1. ui_root.gd references Phase_MID_CHOICE.
2. RUN_PHASE_MID_CHOICE is referenced in ui_root.gd.
3. A mid-choice normalization exists inside apply_run_ui_payload(...):

* show_mid_choice is referenced (payload.show_mid_choice or local show_mid_choice)
* RUN_PHASE_MID_CHOICE is referenced
* there is an assignment forcing target_phase/phase to RUN_PHASE_MID_CHOICE

This test does NOT require Godot.
It validates structural contract consistency only.
"""

import re
import sys
from pathlib import Path


UI_ROOT_PATH = Path("scripts/ui/ui_root.gd")


def fail(message: str):
    print(f"[FAIL][UI_PHASE_CONTRACT_TEST_V2] {message}")
    sys.exit(1)


def success(message: str):
    print(f"[OK] {message}")


def main():
    if not UI_ROOT_PATH.exists():
        fail("ui_root.gd not found at expected path.")

    content = UI_ROOT_PATH.read_text(encoding="utf-8")

    # 1. Phase_MID_CHOICE must exist in file
    if "Phase_MID_CHOICE" not in content:
        fail("Phase_MID_CHOICE node not referenced in ui_root.gd.")
    else:
        success("Phase_MID_CHOICE reference found.")

    # 2. RUN_PHASE_MID_CHOICE must be used in mapping or logic
    if "RUN_PHASE_MID_CHOICE" not in content:
        fail("RUN_PHASE_MID_CHOICE constant not found in ui_root.gd.")
    else:
        success("RUN_PHASE_MID_CHOICE reference found.")

    # 3. Look for mid-choice normalization logic (robust heuristic)
    #
    # We do NOT enforce a specific syntax (== true, variable names, single-line).
    # We verify that within apply_run_ui_payload(...) there is:
    # - a reference to show_mid_choice (either payload.show_mid_choice or local show_mid_choice)
    # - a reference to RUN_PHASE_MID_CHOICE
    # - an assignment that can force/route to RUN_PHASE_MID_CHOICE (target_phase or phase)
    #
    # This keeps the test stable across minor refactors while still enforcing the contract.
    #
    # Support signatures with optional return annotation, e.g.:
    # func apply_run_ui_payload(payload: Dictionary) -> void:
    func_block = re.search(
        r"(?ms)^\s*func\s+apply_run_ui_payload\s*\([^)]*\)\s*(?:->\s*[\w\.]+\s*)?:\s*\n(.*?)(?=^\s*func\s+|\Z)",
        content,
    )
    if not func_block:
        fail("apply_run_ui_payload(...) function block not found in ui_root.gd.")

    block = func_block.group(1)

    # show_mid_choice may appear as:
    # - show_mid_choice
    # - payload.show_mid_choice
    # - ui_payload.show_mid_choice
    show_mid_choice_ref = re.search(r"\bshow_mid_choice\b", block) or re.search(
        r"\b\w+\.show_mid_choice\b", block
    )
    if not show_mid_choice_ref:
        fail("No reference to show_mid_choice found inside apply_run_ui_payload(...).")

    if "RUN_PHASE_MID_CHOICE" not in block:
        fail("RUN_PHASE_MID_CHOICE not referenced inside apply_run_ui_payload(...).")

    # Force-to-mid-choice assignment heuristics:
    # Accept either:
    # - target_phase = RUN_PHASE_MID_CHOICE
    # - phase = RUN_PHASE_MID_CHOICE
    assign_pattern = re.compile(
        r"(?m)^\s*(target_phase|phase)\s*=\s*RUN_PHASE_MID_CHOICE\b"
    )
    if not assign_pattern.search(block):
        fail(
            "Mid-choice normalization assignment not detected in apply_run_ui_payload(...). "
            "Expected an assignment like 'target_phase = RUN_PHASE_MID_CHOICE' or 'phase = RUN_PHASE_MID_CHOICE'."
        )

    # Optional: ensure assignment is gated by a mid-choice condition (best-effort)
    gated_ok = re.search(r"(?is)\bif\b[^\n]*show_mid_choice", block) is not None
    if not gated_ok:
        print(
            "[WARN] RUN_PHASE_MID_CHOICE assignment found, but no nearby 'if ... show_mid_choice' gate detected. "
            "Contract likely OK, but consider making the condition explicit."
        )
    else:
        success("Mid-choice normalization logic detected (gated by show_mid_choice).")

    # 4. Optional safety: warn if numeric match cases exist
    numeric_case_pattern = re.compile(r"^\s*\d+\s*:", re.MULTILINE)

    if numeric_case_pattern.search(content):
        print("[WARN] Numeric match cases detected in ui_root.gd (enum drift risk).")
    else:
        success("No numeric match cases detected.")

    print("\nUI phase contract static test PASSED.")
    sys.exit(0)


if __name__ == "__main__":
    main()
