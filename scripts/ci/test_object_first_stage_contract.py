#!/usr/bin/env python3
"""Checkpoint contract for the complete Object-First Interaction Pass (OF-11)."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PLAYBOOK = ROOT / "scripts/ci/run_testing_playbook.py"
WORKFLOW = ROOT / ".github/workflows/godot_smoke_runtime.yml"
MARKER = ROOT / ".github/ci/full_suite_checkpoint.txt"
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

OBJECT_CONTRACTS = (
    "test_receipt_object_contract.py",
    "test_condemnation_mark_object_contract.py",
    "test_second_incision_object_contract.py",
    "test_arena_threshold_object_contract.py",
    "test_registry_table_object_contract.py",
    "test_promise_signature_object_contract.py",
    "test_pact_tablet_object_contract.py",
    "test_arena_gesture_object_contract.py",
    "test_judgment_seal_object_contract.py",
    "test_final_dossier_object_contract.py",
)

OBJECT_STYLE_PREFIXES = (
    "receipt/sb_registry_receipt_",
    "condemnation_mark/sb_registry_condemnation_mark_",
    "second_incision/sb_registry_second_incision_",
    "arena_threshold/sb_arena_threshold_",
    "registry_table/sb_registry_table_",
    "promise_signature/sb_registry_promise_signature_",
    "pact_tablet/sb_registry_pact_tablet_",
    "arena_gesture/sb_arena_gesture_",
    "judgment_seal/sb_registry_judgment_seal_",
    "final_dossier/sb_registry_final_dossier_",
)

INTENT_SIGNALS = (
    "request_new_run",
    "request_place_bet",
    "request_ritual_advance",
    "request_mid_choice_select",
    "request_pyl_cashout",
    "request_pyl_condanna",
    "request_pyl_double",
    "request_end_run_restart",
    "request_end_run_next_bet",
    "request_end_run_quit",
)


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-11 file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def _assert_contract_coverage() -> None:
    playbook = _read(PLAYBOOK)
    for contract in OBJECT_CONTRACTS:
        path = ROOT / "scripts/ci" / contract
        if not path.exists():
            raise AssertionError(f"missing object contract: {contract}")
        if contract not in playbook:
            raise AssertionError(f"testing playbook omits object contract: {contract}")
    if "test_object_first_stage_contract.py" not in playbook:
        raise AssertionError("testing playbook must include the OF-11 consolidation contract")


def _assert_stable_visual_grammar() -> None:
    scene = _read(SCENE)
    scene_corpus = "\n".join(path.read_text(encoding="utf-8") for path in (ROOT / "scenes").rglob("*.tscn"))
    ui = _read(UI_ROOT)
    for prefix in OBJECT_STYLE_PREFIXES:
        if prefix not in scene_corpus:
            raise AssertionError(f"UI scene is missing Object-First binding family: {prefix}")
    if "END_RUN_BUTTON_READY_SCALE" in ui:
        raise AssertionError("Object-First route focus must not use scale")
    visual_match = re.search(r"(?ms)^func _apply_end_run_button_visual\(.*?(?=^func |\Z)", ui)
    if visual_match is None or any(
        "button.scale" in line and "button.scale = Vector2.ONE" not in line
        for line in visual_match.group(0).splitlines()
    ):
        raise AssertionError("final dossier route states must preserve geometry")
    for token in (
        'theme_override_styles/focus = ExtResource("75_final_dossier_tab_focus")',
        'theme_override_styles/disabled = ExtResource("78_final_dossier_tab_disabled")',
        "MOTION_KIND_RITUAL",
        "FINAL_DOSSIER_TAB_STYLE_SELECTED",
        "FINAL_DOSSIER_STATE_CLOSED",
    ):
        if token not in scene and token not in ui:
            raise AssertionError(f"Object-First accessibility contract missing: {token}")


def _assert_ownership_and_intents() -> None:
    events = _read(GAME_EVENTS)
    ui = _read(UI_ROOT)
    for signal_name in INTENT_SIGNALS:
        if f"signal {signal_name}" not in events:
            raise AssertionError(f"GameEvents intent contract changed: {signal_name}")
        if f'&"{signal_name}"' not in ui:
            raise AssertionError(f"UI no longer emits Object-First intent: {signal_name}")
    runtime_access = re.sub(r"(?m)^\s*#.*$", "", ui)
    for forbidden in ("RunManager.", 'get_node_or_null("/root/RunManager")'):
        if forbidden in runtime_access:
            raise AssertionError(f"UI bypasses RunManager authority: {forbidden}")


def _assert_lean_and_full_checkpoint() -> None:
    marker_value = next((line.strip() for line in _read(MARKER).splitlines() if line.strip() and not line.lstrip().startswith("#")), "")
    if marker_value != "OF-11":
        raise AssertionError("full-suite checkpoint marker must be OF-11")
    workflow = _read(WORKFLOW)
    capture = _read(VISUAL_QA)
    for lean_token in (
        "visual_stage:",
        "--section=final_dossier",
        "timeout 240s",
        'test "$DOSSIER_COUNT" -eq 36',
        'test "$TOTAL_COUNT" -eq 36',
    ):
        if lean_token not in workflow:
            raise AssertionError(f"lean Object-First checkpoint missing: {lean_token}")
    for count_token in (
        'test "$THRESHOLD_COUNT" -eq 24',
        'test "$REGISTRY_TABLE_COUNT" -eq 24',
        'test "$PROMISE_COUNT" -eq 30',
        'test "$PACT_COUNT" -eq 24',
        'test "$GESTURE_COUNT" -eq 36',
        'test "$JUDGMENT_COUNT" -eq 30',
        'test "$RECEIPT_COUNT" -eq 18',
        'test "$MARK_COUNT" -eq 18',
        'test "$INCISION_COUNT" -eq 24',
        'test "$DOSSIER_COUNT" -eq 36',
        'test "$END_RUN_COUNT" -eq 1',
        "timeout 480s",
    ):
        if count_token not in workflow:
            raise AssertionError(f"manual full visual profile missing: {count_token}")
    for matrix in (
        "_capture_arena_threshold_matrix",
        "_capture_registry_table_matrix",
        "_capture_promise_signature_matrix",
        "_capture_pact_tablet_matrix",
        "_capture_gesture_choice_matrix",
        "_capture_judgment_seal_matrix",
        "_capture_receipt_matrix",
        "_capture_condemnation_mark_matrix",
        "_capture_second_incision_matrix",
        "_capture_final_dossier_matrix",
    ):
        if matrix not in capture:
            raise AssertionError(f"cumulative capture omits matrix: {matrix}")


def main() -> int:
    _assert_contract_coverage()
    _assert_stable_visual_grammar()
    _assert_ownership_and_intents()
    _assert_lean_and_full_checkpoint()
    print("OF-11 Object-First stage contract: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
