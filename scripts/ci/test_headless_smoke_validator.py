#!/usr/bin/env python3
"""Static unit checks for headless smoke log validator."""

from __future__ import annotations

from run_headless_smoke import (
    SCENARIO_BET_PRESENT,
    SCENARIO_FULL_RUN,
    SMOKE_CLASS_NATIVE_CRASH_AFTER_BOOTSTRAP,
    SMOKE_CLASS_NATIVE_CRASH_AFTER_MILESTONE,
    SMOKE_CLASS_NATIVE_CRASH_BEFORE_BOOTSTRAP,
    SMOKE_CLASS_STALL_OR_WATCHDOG,
    _classify_runtime_failure,
    _build_runtime_command,
    validate_log_text,
)


def fail(message: str) -> int:
    print(f"[FAIL][HEADLESS_SMOKE_VALIDATOR] {message}")
    return 1


def _build_bet_present_log() -> str:
    return "\n".join(
        [
            "SMOKE:BOOT_OK",
            "SMOKE:PHASE=MAIN_MENU",
            "SMOKE:STEP=REQUEST_NEW_RUN",
            "SMOKE:NEW_RUN_REQUESTED",
            "SMOKE:REQ=request_new_run",
            "SMOKE:PHASE=RUN_INIT",
            "SMOKE:PHASE=BET_PRESENT",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete",
        ]
    )


def _build_full_run_log() -> str:
    return "\n".join(
        [
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
            "SMOKE:MILESTONE=END_RUN_FINAL ending_key=ending_glory",
            "SMOKE:REQ=request_mid_choice_select index=0",
            "SMOKE:REQ=request_pyl_cashout",
            "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete",
        ]
    )


def main() -> int:
    valid_bet_failures = validate_log_text(_build_bet_present_log(), SCENARIO_BET_PRESENT)
    if valid_bet_failures:
        return fail(f"expected BET_PRESENT sample log to pass, got: {valid_bet_failures}")

    allowed_engine_exit_noise_log = (
        _build_bet_present_log()
        + "\nERROR: ERROR: 2 resources still in use at exit (run with --verbose for details)."
    )
    allowed_engine_exit_noise_failures = validate_log_text(
        allowed_engine_exit_noise_log,
        SCENARIO_BET_PRESENT,
    )
    if allowed_engine_exit_noise_failures:
        return fail(
            "expected known engine-exit resources line to be allowlisted, "
            f"got: {allowed_engine_exit_noise_failures}"
        )

    valid_full_run_failures = validate_log_text(_build_full_run_log(), SCENARIO_FULL_RUN)
    if valid_full_run_failures:
        return fail(f"expected FULL_RUN sample log to pass, got: {valid_full_run_failures}")

    command = _build_runtime_command("godot", ".", 60, False)
    if command[-2:] != ["--quit-after", "36000"]:
        return fail(f"expected --quit-after to use iteration budget 36000, got: {command[-2:]}")

    invalid_full_run_log = _build_full_run_log().replace("SMOKE:MILESTONE=RESOLVE_CLOSED\n", "")
    invalid_failures = validate_log_text(invalid_full_run_log, SCENARIO_FULL_RUN)
    if not any("SMOKE:MILESTONE=RESOLVE_CLOSED" in failure for failure in invalid_failures):
        return fail(
            "expected FULL_RUN missing milestone failure for RESOLVE_CLOSED, "
            f"got: {invalid_failures}"
        )

    class_before_bootstrap, _, _ = _classify_runtime_failure(
        -1073741819,
        "SMOKE:RUNNER_START scenario=BET_PRESENT\n",
    )
    if class_before_bootstrap != SMOKE_CLASS_NATIVE_CRASH_BEFORE_BOOTSTRAP:
        return fail(
            "expected crash-before-bootstrap classification, "
            f"got: {class_before_bootstrap}"
        )

    class_after_bootstrap, _, _ = _classify_runtime_failure(
        -1073741819,
        "SMOKE:RUNNER_START scenario=BET_PRESENT\nSMOKE:BOOT_OK\n",
    )
    if class_after_bootstrap != SMOKE_CLASS_NATIVE_CRASH_AFTER_BOOTSTRAP:
        return fail(
            "expected crash-after-bootstrap classification, "
            f"got: {class_after_bootstrap}"
        )

    class_after_milestone, _, _ = _classify_runtime_failure(
        -1073741819,
        "SMOKE:BOOT_OK\nSMOKE:MILESTONE=BET_PRESENT\n",
    )
    if class_after_milestone != SMOKE_CLASS_NATIVE_CRASH_AFTER_MILESTONE:
        return fail(
            "expected crash-after-milestone classification, "
            f"got: {class_after_milestone}"
        )

    class_timeout, _, _ = _classify_runtime_failure(
        124,
        "SMOKE:RUNNER_START scenario=FULL_RUN\nSMOKE:TIMEOUT_HARD_KILL\n",
    )
    if class_timeout != SMOKE_CLASS_STALL_OR_WATCHDOG:
        return fail(
            "expected stall/watchdog classification for timeout marker, "
            f"got: {class_timeout}"
        )

    print("[OK][HEADLESS_SMOKE_VALIDATOR] smoke validator checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
