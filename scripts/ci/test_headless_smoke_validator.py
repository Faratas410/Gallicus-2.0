#!/usr/bin/env python3
"""Static unit checks for headless smoke log validator."""

from __future__ import annotations

from run_headless_smoke import SCENARIO_BET_PRESENT, SCENARIO_FULL_RUN, validate_log_text


def fail(message: str) -> int:
    print(f"[FAIL][HEADLESS_SMOKE_VALIDATOR] {message}")
    return 1


def _build_bet_present_log() -> str:
    return "\n".join(
        [
            "RunManager ready",
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
            "RunManager ready",
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

    valid_full_run_failures = validate_log_text(_build_full_run_log(), SCENARIO_FULL_RUN)
    if valid_full_run_failures:
        return fail(f"expected FULL_RUN sample log to pass, got: {valid_full_run_failures}")

    invalid_full_run_log = _build_full_run_log().replace("SMOKE:MILESTONE=RESOLVE_CLOSED\n", "")
    invalid_failures = validate_log_text(invalid_full_run_log, SCENARIO_FULL_RUN)
    if not any("SMOKE:MILESTONE=RESOLVE_CLOSED" in failure for failure in invalid_failures):
        return fail(
            "expected FULL_RUN missing milestone failure for RESOLVE_CLOSED, "
            f"got: {invalid_failures}"
        )

    print("[OK][HEADLESS_SMOKE_VALIDATOR] smoke validator checks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
