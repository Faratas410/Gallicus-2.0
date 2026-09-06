#!/usr/bin/env python3
"""Static unit checks for headless smoke log validator."""

from __future__ import annotations

from run_headless_smoke import (
    CANONICAL_SMOKE_SEED,
    SCENARIO_ROUTE_CASHOUT,
    SCENARIO_ROUTE_CONDANNA,
    SCENARIO_ROUTE_DOUBLE,
    SCENARIO_ROUTE_REGISTER_FINAL,
    SCENARIO_CORE_CONTINUITY,
    SCENARIO_BET_PRESENT,
    SCENARIO_FULL_RUN,
    SCENARIO_KEYBOARD_FULL_RUN,
    SMOKE_CLASS_NATIVE_CRASH_AFTER_BOOTSTRAP,
    SMOKE_CLASS_NATIVE_CRASH_AFTER_MILESTONE,
    SMOKE_CLASS_NATIVE_CRASH_BEFORE_BOOTSTRAP,
    SMOKE_CLASS_STALL_OR_WATCHDOG,
    _classify_runtime_failure,
    _build_runtime_command,
    _resolve_smoke_seed,
    SIGNOFF_SURFACE_CANONICAL_CI_LINUX,
    SIGNOFF_SURFACE_LOCAL_DIAGNOSTIC,
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
            f"SMOKE:RUN_SEED={CANONICAL_SMOKE_SEED}",
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
            f"SMOKE:RUN_SEED={CANONICAL_SMOKE_SEED}",
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


def _build_route_log(scenario: str, pyl_request: str, register_final: bool = False) -> str:
    lines = [
        "SMOKE:BOOT_OK",
        f"SMOKE:STEP=SCENARIO_{scenario}_START",
        f"SMOKE:RUN_SEED={CANONICAL_SMOKE_SEED}",
        "SMOKE:MILESTONE=BET_PRESENT",
        "SMOKE:MILESTONE=PACT_SEALED_OPENED",
        "SMOKE:MILESTONE=PACT_SEALED_CLOSED",
        "SMOKE:MILESTONE=INTERMEDIATE_CHOICE",
        "SMOKE:MILESTONE=RESOLVE_OPENED",
        "SMOKE:MILESTONE=RESOLVE_CLOSED",
        "SMOKE:MILESTONE=PUSH_YOUR_LUCK",
        "SMOKE:REQ=request_mid_choice_select index=0",
        f"SMOKE:REQ={pyl_request}",
        "SMOKE:MILESTONE=END_RUN",
    ]
    if register_final:
        lines.append("SMOKE:MILESTONE=END_RUN_FINAL ending_key=ending_glory")
    lines.append("SMOKE:QUIT_REQUESTED reason=smoke_gate_complete")
    return "\n".join(lines)


def _build_core_continuity_log() -> str:
    return "\n".join(
        [
            "SMOKE:BOOT_OK",
            "SMOKE:STEP=SCENARIO_CORE_CONTINUITY_START",
            f"SMOKE:RUN_SEED={CANONICAL_SMOKE_SEED}",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:REQ=request_pyl_condanna",
            "SMOKE:MILESTONE=END_RUN",
            "SMOKE:MILESTONE=CORE_RUN_1",
            "SMOKE:REQ=request_end_run_next_bet",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:REQ=request_pyl_condanna",
            "SMOKE:MILESTONE=END_RUN",
            "SMOKE:MILESTONE=CORE_RUN_2",
            "SMOKE:REQ=request_end_run_restart",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:REQ=request_pyl_condanna",
            "SMOKE:MILESTONE=END_RUN",
            "SMOKE:MILESTONE=CORE_RUN_3",
            "SMOKE:REQ=request_end_run_quit",
            "SMOKE:MILESTONE=CORE_RETURNED_TO_MENU",
            "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete",
        ]
    )


def _build_keyboard_full_run_log() -> str:
    return "\n".join(
        [
            "SMOKE:BOOT_OK",
            "SMOKE:STEP=SCENARIO_KEYBOARD_FULL_RUN_START",
            "SMOKE:KEYBOARD key=Enter focus=NewGameButton",
            "SMOKE:MILESTONE=BET_PRESENT",
            "SMOKE:MILESTONE=PACT_SEALED_OPENED",
            "SMOKE:KEYBOARD key=Enter focus=Btn_FIRST_REACTION_NEXT",
            "SMOKE:MILESTONE=INTERMEDIATE_CHOICE",
            "SMOKE:MILESTONE=RESOLVE_OPENED",
            "SMOKE:KEYBOARD key=Enter focus=Btn_RESOLUTION_STRIKE",
            "SMOKE:KEYBOARD key=Enter focus=Btn_RESOLUTION_STRIKE",
            "SMOKE:KEYBOARD key=Enter focus=Btn_RESOLUTION_STRIKE",
            "SMOKE:MILESTONE=PUSH_YOUR_LUCK",
            "SMOKE:MILESTONE=END_RUN",
            "SMOKE:MILESTONE=KEYBOARD_RETURNED_TO_MENU",
            "SMOKE:QUIT_REQUESTED reason=smoke_gate_complete",
        ]
    )


def main() -> int:
    if CANONICAL_SMOKE_SEED <= 0:
        return fail(f"expected a positive canonical smoke seed, got: {CANONICAL_SMOKE_SEED}")
    if _resolve_smoke_seed(SIGNOFF_SURFACE_CANONICAL_CI_LINUX, "999") != CANONICAL_SMOKE_SEED:
        return fail("canonical Linux CI must ignore diagnostic seed overrides")
    if _resolve_smoke_seed(SIGNOFF_SURFACE_LOCAL_DIAGNOSTIC, "999") != 999:
        return fail("local diagnostic surface must accept an explicit positive seed")

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

    route_cases = {
        SCENARIO_ROUTE_CASHOUT: ("request_pyl_cashout", False),
        SCENARIO_ROUTE_DOUBLE: ("request_pyl_double", False),
        SCENARIO_ROUTE_CONDANNA: ("request_pyl_condanna", False),
        SCENARIO_ROUTE_REGISTER_FINAL: ("request_pyl_cashout", True),
    }
    for route_scenario, route_spec in route_cases.items():
        route_request, register_final = route_spec
        route_failures = validate_log_text(
            _build_route_log(route_scenario, route_request, register_final),
            route_scenario,
        )
        if route_failures:
            return fail(f"expected {route_scenario} sample log to pass, got: {route_failures}")

    continuity_failures = validate_log_text(_build_core_continuity_log(), SCENARIO_CORE_CONTINUITY)
    if continuity_failures:
        return fail(f"expected CORE_CONTINUITY sample log to pass, got: {continuity_failures}")

    keyboard_log = _build_keyboard_full_run_log()
    keyboard_failures = validate_log_text(keyboard_log, SCENARIO_KEYBOARD_FULL_RUN)
    if keyboard_failures:
        return fail(f"expected KEYBOARD_FULL_RUN sample log to pass, got: {keyboard_failures}")

    keyboard_direct_request_failures = validate_log_text(
        keyboard_log + "\nSMOKE:REQ=request_pyl_condanna",
        SCENARIO_KEYBOARD_FULL_RUN,
    )
    if not any("must not use direct smoke intent requests" in failure for failure in keyboard_direct_request_failures):
        return fail(
            "expected KEYBOARD_FULL_RUN to reject direct smoke intent requests, "
            f"got: {keyboard_direct_request_failures}"
        )

    keyboard_wrong_strike_count_failures = validate_log_text(
        keyboard_log.replace(
            "SMOKE:KEYBOARD key=Enter focus=Btn_RESOLUTION_STRIKE\n",
            "",
            1,
        ),
        SCENARIO_KEYBOARD_FULL_RUN,
    )
    if not any("Btn_RESOLUTION_STRIKE" in failure for failure in keyboard_wrong_strike_count_failures):
        return fail(
            "expected KEYBOARD_FULL_RUN to enforce exactly three seal strikes, "
            f"got: {keyboard_wrong_strike_count_failures}"
        )

    command = _build_runtime_command("godot", ".", 60, False)
    if command[-2:] != ["--quit-after", "36000"]:
        return fail(f"expected --quit-after to use iteration budget 36000, got: {command[-2:]}")

    exported_command = _build_runtime_command("Gallicus.exe", "empty-directory", 60, False, True)
    if "--path" in exported_command or "empty-directory" in exported_command:
        return fail(f"exported game must boot its embedded project without path overrides: {exported_command}")

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

    class_timeout_after_native_crash, _, _ = _classify_runtime_failure(
        124,
        "\n".join(
            [
                "SMOKE:RUNNER_START scenario=BET_PRESENT",
                "CrashHandlerException: Program crashed with signal 11",
                "-- END OF C++ BACKTRACE --",
                "SMOKE:TIMEOUT_HARD_KILL",
            ]
        ),
    )
    if class_timeout_after_native_crash != SMOKE_CLASS_NATIVE_CRASH_BEFORE_BOOTSTRAP:
        return fail(
            "expected timeout-wrapped native crash before bootstrap classification, "
            f"got: {class_timeout_after_native_crash}"
        )

    print("[OK][HEADLESS_SMOKE_VALIDATOR] smoke validator checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
