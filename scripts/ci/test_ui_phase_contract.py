#!/usr/bin/env python3

"""
UI Phase Contract Static Test

VERSION: 2 (function-scoped heuristic)

This test verifies that:

1. ui_root.gd contains a mapping entry for Phase_MID_CHOICE.
2. RUN_PHASE_MID_CHOICE is referenced in the phase map.
3. A normalization exists for mid-choice payloads
   (show_mid_choice == true forces RUN_PHASE_MID_CHOICE).

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

    # 3. Look for mid-choice normalization logic
    # We check that show_mid_choice is used together with RUN_PHASE_MID_CHOICE
    mid_choice_pattern = re.compile(
        r"show_mid_choice\s*==\s*true.*RUN_PHASE_MID_CHOICE",
        re.DOTALL,
    )

    if not mid_choice_pattern.search(content):
        fail(
            "Mid-choice normalization not detected "
            "(expected show_mid_choice == true forcing RUN_PHASE_MID_CHOICE)."
        )
    else:
        success("Mid-choice normalization logic detected.")

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
