#!/usr/bin/env python3
"""Run and validate Gallicus headless smoke scenarios."""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path

SCENARIO_BET_PRESENT = "BET_PRESENT"
SCENARIO_FULL_RUN = "FULL_RUN"
# Godot's --quit-after counts engine iterations, not wall-clock seconds.
# Headless Linux can iterate much faster than 60 FPS, so keep this as a
# generous safety cap and let subprocess hard-timeout enforce wall-clock limits.
GODOT_QUIT_AFTER_ITERATIONS_PER_SECOND_BUDGET = 600

SMOKE_CLASS_OK = "OK"
SMOKE_CLASS_NATIVE_CRASH_BEFORE_BOOTSTRAP = "NATIVE_CRASH_BEFORE_BOOTSTRAP"
SMOKE_CLASS_NATIVE_CRASH_AFTER_BOOTSTRAP = "NATIVE_CRASH_AFTER_BOOTSTRAP"
SMOKE_CLASS_NATIVE_CRASH_AFTER_MILESTONE = "NATIVE_CRASH_AFTER_MILESTONE"
SMOKE_CLASS_STALL_OR_WATCHDOG = "STALL_OR_WATCHDOG"
SMOKE_CLASS_VALIDATOR_CONTRACT_FAILURE = "VALIDATOR_CONTRACT_FAILURE"

SIGNOFF_SURFACE_CANONICAL_CI_LINUX = "canonical_ci_linux"
SIGNOFF_SURFACE_LOCAL_DIAGNOSTIC = "local_diagnostic_non_signoff"

KNOWN_WARNING_ALLOWLIST = (
    "ObjectDB instances leaked at exit",
    "core/object/object.cpp",
)

KNOWN_ERROR_ALLOWLIST = (
    "resources still in use at exit (run with --verbose for details).",
)


@dataclass(frozen=True)
class SmokeScenarioSpec:
    name: str
    required_substrings: tuple[str, ...]
    require_single_boot_marker: bool


SCENARIO_SPECS: dict[str, SmokeScenarioSpec] = {
    SCENARIO_BET_PRESENT: SmokeScenarioSpec(
        name=SCENARIO_BET_PRESENT,
        required_substrings=(
            "SMOKE:BOOT_OK",
            "SMOKE:PHASE=MAIN_MENU",
            "SMOKE:NEW_RUN_REQUESTED",
            "SMOKE:PHASE=RUN_INIT",
            "SMOKE:PHASE=BET_PRESENT",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete",
        ),
        require_single_boot_marker=False,
    ),
    SCENARIO_FULL_RUN: SmokeScenarioSpec(
        name=SCENARIO_FULL_RUN,
        required_substrings=(
            "SMOKE:BOOT_OK",
            "SMOKE:STEP=SCENARIO_FULL_RUN_START",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:MILESTONE=PACT_SEALED_OPENED",
            "SMOKE:MILESTONE=PACT_SEALED_CLOSED",
            "SMOKE:MILESTONE=INTERMEDIATE_CHOICE",
            "SMOKE:MILESTONE=RESOLVE_OPENED",
            "SMOKE:MILESTONE=RESOLVE_CLOSED",
            "SMOKE:MILESTONE=PUSH_YOUR_LUCK",
            "SMOKE:MILESTONE=END_RUN",
            "SMOKE:MILESTONE=END_RUN_FINAL ending_key=",
            "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete",
        ),
        require_single_boot_marker=True,
    ),
}


def _detect_signoff_surface() -> str:
    is_linux = platform.system().lower() == "linux"
    ci_raw = os.environ.get("CI", "").strip().lower()
    is_ci = ci_raw in {"1", "true", "yes"}
    if is_linux and is_ci:
        return SIGNOFF_SURFACE_CANONICAL_CI_LINUX
    return SIGNOFF_SURFACE_LOCAL_DIAGNOSTIC


def _extract_milestones(log_text: str) -> list[str]:
    milestones: list[str] = []
    for line in log_text.splitlines():
        match = re.search(r"SMOKE:MILESTONE=([A-Z0-9_]+)", line)
        if match:
            milestones.append(match.group(1))
    return milestones


def _classify_runtime_failure(exit_code: int, log_text: str) -> tuple[str, str, str]:
    milestones = _extract_milestones(log_text)
    last_milestone = milestones[-1] if milestones else ""

    if exit_code == 124 or "SMOKE:TIMEOUT_HARD_KILL" in log_text:
        return (
            SMOKE_CLASS_STALL_OR_WATCHDOG,
            "runtime timed out or watchdog-equivalent timeout marker reached",
            last_milestone,
        )

    if "watchdog" in log_text.lower():
        return (
            SMOKE_CLASS_STALL_OR_WATCHDOG,
            "watchdog marker detected in runtime output",
            last_milestone,
        )

    has_bootstrap = "SMOKE:BOOT_OK" in log_text
    if not has_bootstrap:
        return (
            SMOKE_CLASS_NATIVE_CRASH_BEFORE_BOOTSTRAP,
            "runtime exited non-zero before SMOKE:BOOT_OK",
            last_milestone,
        )

    if not milestones:
        return (
            SMOKE_CLASS_NATIVE_CRASH_AFTER_BOOTSTRAP,
            "runtime exited non-zero after bootstrap but before first milestone",
            last_milestone,
        )

    return (
        SMOKE_CLASS_NATIVE_CRASH_AFTER_MILESTONE,
        f"runtime exited non-zero after last milestone {last_milestone}",
        last_milestone,
    )


def _write_summary(path_arg: str, payload: dict[str, object]) -> None:
    summary_path = path_arg.strip()
    if summary_path == "":
        return
    path = Path(summary_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def _collect_disallowed_errors(lines: list[str]) -> list[str]:
    findings: list[str] = []
    for line in lines:
        if re.search(r"\bERROR\b|\bError\b", line):
            if any(allowed in line for allowed in KNOWN_ERROR_ALLOWLIST):
                continue
            findings.append(line.rstrip("\n"))
    return findings


def _collect_disallowed_warnings(lines: list[str]) -> list[str]:
    findings: list[str] = []
    for line in lines:
        if not re.search(r"\bWARNING\b|\bWarning\b", line):
            continue
        if any(allowed in line for allowed in KNOWN_WARNING_ALLOWLIST):
            continue
        findings.append(line.rstrip("\n"))
    return findings


def validate_log_text(log_text: str, scenario: str) -> list[str]:
    if scenario not in SCENARIO_SPECS:
        return [f"unknown scenario '{scenario}'"]
    spec = SCENARIO_SPECS[scenario]
    failures: list[str] = []
    lines = log_text.splitlines()

    error_lines = _collect_disallowed_errors(lines)
    if error_lines:
        failures.append("disallowed ERROR lines detected")
        failures.extend(f"  ERROR: {line}" for line in error_lines[:20])

    warning_lines = _collect_disallowed_warnings(lines)
    if warning_lines:
        failures.append("disallowed WARNING lines detected")
        failures.extend(f"  WARNING: {line}" for line in warning_lines[:20])

    for token in spec.required_substrings:
        if token not in log_text:
            failures.append(f"missing required token: {token}")

    # Ensure full-run touched intent path segments beyond BET_PRESENT.
    if scenario == SCENARIO_FULL_RUN:
        if "SMOKE:REQ=request_mid_choice_select index=0" not in log_text:
            failures.append("missing full-run request token: request_mid_choice_select index=0")
        if (
            "SMOKE:REQ=request_pyl_double" not in log_text
            and "SMOKE:REQ=request_pyl_cashout" not in log_text
        ):
            failures.append("missing full-run request token: request_pyl_double/request_pyl_cashout")

    if spec.require_single_boot_marker:
        boot_marker_count = log_text.count("SMOKE:BOOT_OK")
        if boot_marker_count != 1:
            failures.append(
                f"expected exactly 1 'SMOKE:BOOT_OK' marker, found {boot_marker_count}"
            )

    return failures


def _build_runtime_command(
    godot_bin: str,
    project_root: str,
    timeout_sec: int,
    use_xvfb: bool,
) -> list[str]:
    quit_after_frames = max(timeout_sec * GODOT_QUIT_AFTER_ITERATIONS_PER_SECOND_BUDGET, 1)
    command: list[str] = [
        godot_bin,
        "--headless",
        "--path",
        project_root,
        "--quit-after",
        str(quit_after_frames),
    ]
    if use_xvfb:
        command = ["xvfb-run", "-a"] + command
    return command


def run_smoke_runtime(
    scenario: str,
    godot_bin: str,
    project_root: str,
    timeout_sec: int,
    hard_timeout_sec: int,
    log_path: Path,
    use_xvfb: bool,
    signoff_surface: str,
) -> tuple[int, str]:
    env = os.environ.copy()
    env["GALLICUS_SMOKE"] = "1"
    env["GALLICUS_SMOKE_SCENARIO"] = scenario
    env["GALLICUS_SMOKE_TIMEOUT_SEC"] = str(timeout_sec)

    command = _build_runtime_command(
        godot_bin=godot_bin,
        project_root=project_root,
        timeout_sec=timeout_sec,
        use_xvfb=use_xvfb,
    )
    command_text = " ".join(command)
    print("[SMOKE] Running:", command_text)

    prefix_lines = [
        f"SMOKE:RUNNER_START scenario={scenario}",
        f"SMOKE:SIGNOFF_SURFACE={signoff_surface}",
        f"SMOKE:HOST_OS={platform.system()}",
        f"SMOKE:RUNTIME_CMD={command_text}",
    ]

    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
    )
    try:
        output, _ = process.communicate(timeout=hard_timeout_sec)
        exit_code = process.returncode
    except subprocess.TimeoutExpired:
        process.kill()
        runtime_output, _ = process.communicate()
        exit_code = 124
        runtime_output += "\nSMOKE:TIMEOUT_HARD_KILL\n"
    else:
        runtime_output = output

    output = "\n".join(prefix_lines) + "\n" + runtime_output
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(output, encoding="utf-8")
    return exit_code, output


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run/validate Gallicus headless smoke scenarios.")
    parser.add_argument(
        "--scenario",
        required=True,
        choices=sorted(SCENARIO_SPECS.keys()),
        help="Smoke scenario to validate.",
    )
    parser.add_argument(
        "--project-root",
        default=".",
        help="Godot project root (path containing project.godot).",
    )
    parser.add_argument(
        "--godot-bin",
        default="",
        help="Path to Godot binary. Required unless --validate-log-only is used.",
    )
    parser.add_argument(
        "--timeout-sec",
        type=int,
        default=60,
        help=(
            "Runtime smoke timeout in seconds. This is exported as "
            "GALLICUS_SMOKE_TIMEOUT_SEC and converted to a frame budget for Godot --quit-after."
        ),
    )
    parser.add_argument(
        "--hard-timeout-sec",
        type=int,
        default=75,
        help="External hard timeout for process execution.",
    )
    parser.add_argument(
        "--log-file",
        default="",
        help="Path to smoke log file (written on runtime run, read on validate-log-only).",
    )
    parser.add_argument(
        "--summary-file",
        default="",
        help="Optional JSON summary output path with explicit failure classification.",
    )
    parser.add_argument(
        "--use-xvfb",
        action="store_true",
        help="Wrap Godot command with xvfb-run -a.",
    )
    parser.add_argument(
        "--validate-log-only",
        action="store_true",
        help="Skip runtime execution and validate existing --log-file only.",
    )
    return parser


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()
    scenario: str = args.scenario
    signoff_surface = _detect_signoff_surface()

    print(f"[SMOKE][SIGNOFF_SURFACE] {signoff_surface}")
    if signoff_surface != SIGNOFF_SURFACE_CANONICAL_CI_LINUX:
        print(
            "[SMOKE][NOTE] non-canonical signoff surface detected; "
            "this run is diagnostic-only"
        )

    log_file_arg: str = args.log_file.strip()
    if log_file_arg == "":
        log_file_arg = f"smoke_{scenario.lower()}.log"
    log_path = Path(log_file_arg)

    runtime_exit_code = 0
    if args.validate_log_only:
        if not log_path.exists():
            print(f"[FAIL][SMOKE] log file not found for validate-only mode: {log_path}")
            return 1
        log_text = log_path.read_text(encoding="utf-8", errors="replace")
    else:
        godot_bin = args.godot_bin.strip()
        if godot_bin == "":
            print("[FAIL][SMOKE] --godot-bin is required unless --validate-log-only is used")
            return 1
        runtime_exit_code, log_text = run_smoke_runtime(
            scenario=scenario,
            godot_bin=godot_bin,
            project_root=args.project_root,
            timeout_sec=max(int(args.timeout_sec), 1),
            hard_timeout_sec=max(int(args.hard_timeout_sec), 1),
            log_path=log_path,
            use_xvfb=bool(args.use_xvfb),
            signoff_surface=signoff_surface,
        )
        if runtime_exit_code != 0:
            fail_class, fail_reason, last_milestone = _classify_runtime_failure(
                runtime_exit_code,
                log_text,
            )
            summary_payload: dict[str, object] = {
                "scenario": scenario,
                "status": "runtime_failure",
                "classification": fail_class,
                "reason": fail_reason,
                "exit_code": runtime_exit_code,
                "signoff_surface": signoff_surface,
                "last_milestone": last_milestone,
                "has_boot_ok": "SMOKE:BOOT_OK" in log_text,
                "log_file": str(log_path),
            }
            _write_summary(args.summary_file, summary_payload)
            print(f"[FAIL][SMOKE][CLASS={fail_class}] scenario={scenario}")
            print(f"[SMOKE] reason: {fail_reason}")
            if last_milestone != "":
                print(f"[SMOKE] last_milestone: {last_milestone}")
            print(f"[SMOKE] runtime_exit_code: {runtime_exit_code}")
            print(f"[SMOKE] log: {log_path}")
            return 1

    milestones = _extract_milestones(log_text)
    last_milestone = milestones[-1] if milestones else ""
    failures = validate_log_text(log_text, scenario)
    if failures:
        summary_payload = {
            "scenario": scenario,
            "status": "validator_failure",
            "classification": SMOKE_CLASS_VALIDATOR_CONTRACT_FAILURE,
            "reason": "smoke output did not satisfy required contract markers",
            "exit_code": runtime_exit_code,
            "signoff_surface": signoff_surface,
            "last_milestone": last_milestone,
            "has_boot_ok": "SMOKE:BOOT_OK" in log_text,
            "log_file": str(log_path),
            "validator_failures": failures,
        }
        _write_summary(args.summary_file, summary_payload)
        print(f"[FAIL][SMOKE][CLASS={SMOKE_CLASS_VALIDATOR_CONTRACT_FAILURE}] scenario={scenario}")
        print(f"[SMOKE] log: {log_path}")
        for failure in failures:
            print(f"- {failure}")
        return 1

    summary_payload = {
        "scenario": scenario,
        "status": "ok",
        "classification": SMOKE_CLASS_OK,
        "reason": "scenario validated",
        "exit_code": runtime_exit_code,
        "signoff_surface": signoff_surface,
        "last_milestone": last_milestone,
        "has_boot_ok": "SMOKE:BOOT_OK" in log_text,
        "log_file": str(log_path),
    }
    _write_summary(args.summary_file, summary_payload)

    print(f"[OK][SMOKE] scenario={scenario} validated")
    print(f"[SMOKE] log: {log_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
