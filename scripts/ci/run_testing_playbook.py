#!/usr/bin/env python3
"""Run the Gallicus testing playbook in the HR-style sequence.

The runner keeps the order explicit:
1. static/data checks;
2. optional Godot import;
3. one or more runtime smoke scenarios through the existing smoke runner.

Local Windows runtime smoke is diagnostic only. Canonical signoff remains the
Linux CI workflow.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT_DIR = ROOT / "artifacts" / "testing_playbook"
DEFAULT_SCENARIOS = ("FULL_RUN",)


@dataclass(frozen=True)
class StepResult:
    label: str
    command: list[str]
    exit_code: int
    log_path: Path

    @property
    def ok(self) -> bool:
        return self.exit_code == 0

    def to_json(self) -> dict[str, object]:
        return {
            "label": self.label,
            "command": self.command,
            "exit_code": self.exit_code,
            "ok": self.ok,
            "log_path": str(self.log_path.relative_to(ROOT)),
        }


def _python_script(script_path: str) -> list[str]:
    return [sys.executable, script_path]


STATIC_STEPS: tuple[tuple[str, list[str]], ...] = (
    ("av_assets", _python_script("scripts/ci/test_av_asset_contract.py")),
    ("smoke_validator", _python_script("scripts/ci/test_headless_smoke_validator.py")),
    ("docs_refs", _python_script("scripts/ci/check_docs_active_refs.py")),
    ("no_legacy_references", _python_script("scripts/ci/check_no_legacy_references.py")),
    ("runtime_invariants", _python_script("scripts/ci/check_runtime_invariants.py")),
    ("end_run_summary", _python_script("scripts/ci/audit_end_run_summary.py")),
    ("tscn_format", _python_script("tools/ci/check_tscn_format.py")),
    ("gameevents_contract", _python_script("tools/ci/validate_gameevents_contract.py")),
    ("res_paths", _python_script("tools/ci/verify_res_paths.py")),
    ("identity_resolver", _python_script("scripts/ci/test_identity_resolver_contract.py")),
    ("level3_bet_offer", _python_script("scripts/ci/test_level3_bet_offer_contract.py")),
    ("level3_ending_rules", _python_script("scripts/ci/test_level3_ending_rules_contract.py")),
    ("level3_path_tag", _python_script("scripts/ci/test_level3_path_tag_contract.py")),
    ("post_bet_boundary", _python_script("scripts/ci/test_post_bet_boundary_contract.py")),
    ("push_luck_counter", _python_script("scripts/ci/test_push_luck_counter_contract.py")),
    ("resolution_boundary", _python_script("scripts/ci/test_resolution_boundary_contract.py")),
    ("ritual_loop_contract", _python_script("scripts/ci/test_ritual_loop_contract.py")),
    ("run_phase_ownership", _python_script("scripts/ci/test_run_phase_contract_ownership.py")),
    ("run_save_flow_step", _python_script("scripts/ci/test_run_save_flow_step_contract.py")),
    ("settings_contract", _python_script("scripts/ci/test_settings_contract.py")),
    ("textual_style", _python_script("scripts/ci/test_textual_style_contract.py")),
    ("era_visual_template", _python_script("scripts/ci/test_era_visual_template_audit.py")),
    ("pressure_presentation", _python_script("scripts/ci/test_pressure_presentation_contract.py")),
    ("ui_motion", _python_script("scripts/ci/test_ui_motion_contract.py")),
    ("ui_overlay", _python_script("scripts/ci/test_ui_overlay_contract.py")),
    ("ui_phase", _python_script("scripts/ci/test_ui_phase_contract.py")),
    ("ui_reactive_surface", _python_script("scripts/ci/test_ui_reactive_contract_surface.py")),
    ("ui_ritual_payload", _python_script("scripts/ci/test_ui_ritual_payload_contract.py")),
    ("i18n_contract", _python_script("scripts/ci/test_i18n_contract.py")),
    ("receipt_object", _python_script("scripts/ci/test_receipt_object_contract.py")),
    ("condemnation_mark_object", _python_script("scripts/ci/test_condemnation_mark_object_contract.py")),
    ("second_incision_object", _python_script("scripts/ci/test_second_incision_object_contract.py")),
    ("arena_threshold_object", _python_script("scripts/ci/test_arena_threshold_object_contract.py")),
    ("registry_table_object", _python_script("scripts/ci/test_registry_table_object_contract.py")),
    ("promise_signature_object", _python_script("scripts/ci/test_promise_signature_object_contract.py")),
    ("pact_tablet_object", _python_script("scripts/ci/test_pact_tablet_object_contract.py")),
    ("arena_gesture_object", _python_script("scripts/ci/test_arena_gesture_object_contract.py")),
    ("judgment_seal_object", _python_script("scripts/ci/test_judgment_seal_object_contract.py")),
    ("final_dossier_object", _python_script("scripts/ci/test_final_dossier_object_contract.py")),
    ("object_first_stage", _python_script("scripts/ci/test_object_first_stage_contract.py")),
    ("ci_checkpoint_contract", _python_script("scripts/ci/test_ci_checkpoint_contract.py")),
    ("release_content", _python_script("scripts/ci/test_release_content_contract.py")),
    ("no_mojibake", _python_script("scripts/ci/test_no_mojibake.py")),
)


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the Gallicus testing playbook.")
    parser.add_argument(
        "--godot-bin",
        default="",
        help="Optional Godot console binary. When omitted, runtime smoke is skipped.",
    )
    parser.add_argument(
        "--scenario",
        action="append",
        default=[],
        help="Smoke scenario to run. May be passed multiple times. Defaults to FULL_RUN.",
    )
    parser.add_argument(
        "--output-dir",
        default=str(DEFAULT_OUTPUT_DIR),
        help="Directory for logs and playbook summary.",
    )
    parser.add_argument(
        "--skip-static",
        action="store_true",
        help="Skip static/data checks.",
    )
    parser.add_argument(
        "--skip-import",
        action="store_true",
        help="Skip Godot headless editor import before smoke.",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=60,
        help="Scenario timeout passed to run_headless_smoke.py.",
    )
    parser.add_argument(
        "--hard-timeout-sec",
        type=int,
        default=80,
        help="Subprocess hard timeout passed to run_headless_smoke.py.",
    )
    return parser.parse_args()


def _run_step(label: str, command: list[str], output_dir: Path) -> StepResult:
    output_dir.mkdir(parents=True, exist_ok=True)
    log_path = output_dir / f"{label}.log"
    proc = subprocess.run(
        command,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    log_path.write_text(proc.stdout, encoding="utf-8")
    return StepResult(label=label, command=command, exit_code=proc.returncode, log_path=log_path)


def _godot_import_step(godot_bin: str) -> list[str]:
    return [sys.executable, "scripts/ci/run_godot_import.py", "--godot-bin", godot_bin]


def _cp02_runtime_contract_step(godot_bin: str) -> list[str]:
    return [
        sys.executable,
        "scripts/ci/run_cp02_runtime_contract.py",
        "--godot-bin",
        godot_bin,
    ]


def _smoke_step(godot_bin: str, scenario: str, output_dir: Path, timeout_sec: int, hard_timeout_sec: int) -> list[str]:
    scenario_dir = output_dir / scenario
    scenario_dir.mkdir(parents=True, exist_ok=True)
    return [
        sys.executable,
        "scripts/ci/run_headless_smoke.py",
        "--scenario",
        scenario,
        "--project-root",
        str(ROOT),
        "--godot-bin",
        godot_bin,
        "--timeout-sec",
        str(timeout_sec),
        "--hard-timeout-sec",
        str(hard_timeout_sec),
        "--log-file",
        str(scenario_dir / "smoke.log"),
        "--summary-file",
        str(scenario_dir / "smoke_summary.json"),
    ]


def _write_summary(output_dir: Path, results: list[StepResult], runtime_requested: bool) -> Path:
    failed = [result for result in results if not result.ok]
    payload: dict[str, object] = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "runtime_requested": runtime_requested,
        "canonical_signoff": False,
        "canonical_signoff_reason": "local playbook run is diagnostic; Linux CI remains canonical",
        "ok": not failed,
        "failed_steps": [result.label for result in failed],
        "steps": [result.to_json() for result in results],
    }
    summary_path = output_dir / "testing_playbook_summary.json"
    summary_path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")
    return summary_path


def main() -> int:
    args = _parse_args()
    output_dir = Path(args.output_dir).resolve()
    scenarios = tuple(args.scenario) if args.scenario else DEFAULT_SCENARIOS
    results: list[StepResult] = []

    if not args.skip_static:
        for label, command in STATIC_STEPS:
            results.append(_run_step(label, command, output_dir))

    runtime_requested = bool(args.godot_bin)
    if runtime_requested:
        godot_bin = str(Path(args.godot_bin).resolve())
        if not args.skip_import:
            results.append(_run_step("godot_import_headless", _godot_import_step(godot_bin), output_dir))
        results.append(_run_step("cp02_runtime_contract", _cp02_runtime_contract_step(godot_bin), output_dir))
        results.append(_run_step("audit_runtime_contract", [sys.executable, "scripts/ci/run_audit_runtime_contract.py", "--godot-bin", godot_bin], output_dir))
        results.append(_run_step("av_runtime_contract", [sys.executable, "scripts/ci/run_av_runtime_contract.py", "--godot-bin", godot_bin], output_dir))
        for scenario in scenarios:
            results.append(
                _run_step(
                    f"smoke_{scenario.lower()}",
                    _smoke_step(godot_bin, scenario, output_dir, args.timeout_sec, args.hard_timeout_sec),
                    output_dir,
                )
            )
    else:
        print("[PLAYBOOK] --godot-bin not provided; runtime smoke skipped")

    summary_path = _write_summary(output_dir, results, runtime_requested)
    for result in results:
        status = "OK" if result.ok else "FAIL"
        print(f"[{status}] {result.label} -> {result.log_path.relative_to(ROOT)}")
    print(f"[PLAYBOOK] summary -> {summary_path.relative_to(ROOT)}")

    return 0 if all(result.ok for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
