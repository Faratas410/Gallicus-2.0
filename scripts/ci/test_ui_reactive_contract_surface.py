#!/usr/bin/env python3
"""Static guard for reactive UI contract surface in ui_root."""

from __future__ import annotations

import re
from pathlib import Path


def fail(message: str) -> int:
    print(f"[FAIL][UI_REACTIVE_CONTRACT_SURFACE] {message}")
    return 1


def main() -> int:
    ui_root_path = Path("scripts/ui/ui_root.gd")
    if not ui_root_path.exists():
        return fail(f"missing required file: {ui_root_path}")

    ui_root = ui_root_path.read_text(encoding="utf-8")

    required_lifecycle_specs = (
        '{"signal": &"run_started", "handler": &"_on_run_started"}',
        '{"signal": &"run_failed", "handler": &"_on_run_failed"}',
    )
    for token in required_lifecycle_specs:
        if token not in ui_root:
            return fail(f"missing declarative lifecycle wiring spec: {token}")

    required_wiring_tokens = (
        "const _GAME_EVENT_WIRING_REQUIRED: Array[Dictionary]",
        "const _GAME_EVENT_WIRING_GUARDED: Array[Dictionary]",
        "func _wire_standard_game_event_signals() -> void:",
        "func _connect_game_event_signal(",
        "func _emit_game_event_signal_if_available(",
        "func _emit_modal_telemetry(",
    )
    for token in required_wiring_tokens:
        if token not in ui_root:
            return fail(f"missing declarative GameEvents wiring surface: {token}")

    ready_block = re.search(
        r"(?ms)^\s*func\s+_ready\s*\(\)\s*->\s*void\s*:\s*\n(.*?)(?=^\s*func\s+|\Z)",
        ui_root,
    )
    if ready_block is None:
        return fail("missing _ready() block in ui_root")
    if "_wire_standard_game_event_signals()" not in ready_block.group(1):
        return fail("_ready() must dispatch standard GameEvents wiring via _wire_standard_game_event_signals()")

    if re.search(r"GameEvents\.request_[a-z0-9_]+\.emit\(", ui_root):
        return fail("ui_root must not emit request_* signals through direct GameEvents.request_*.emit calls")
    if re.search(r'GameEvents\.has_signal\("request_[^"]+"\)', ui_root):
        return fail("ui_root must route request_* has_signal guards via _emit_game_event_signal_if_available/_has_game_event_signal")
    if re.search(r"GameEvents\.modal_(?:opened|closed)\.emit\(", ui_root):
        return fail("ui_root modal telemetry must emit through _emit_modal_telemetry helper")
    if re.search(r'GameEvents\.has_signal\("modal_(?:opened|closed)"\)', ui_root):
        return fail("ui_root must not gate modal_opened/modal_closed with ad-hoc has_signal branches")

    forbidden_duplicate_tokens = (
        'Callable(self, "_on_run_started_ui")',
        'Callable(self, "_on_run_started_controls")',
        'Callable(self, "_on_run_failed_controls")',
        "func _on_run_started_ui(",
        "func _on_run_started_controls(",
        "func _on_run_failed_controls(",
        "func _apply_run_ui_payload(",
        "GameEvents.run_started.connect(",
        "GameEvents.run_failed.connect(",
        "GameEvents.bet_placed.connect(",
    )
    for token in forbidden_duplicate_tokens:
        if token in ui_root:
            return fail(
                "duplicate/non-authoritative lifecycle or payload wrapper surface found in ui_root: "
                f"{token}"
            )

    push_luck_block = re.search(
        r"(?ms)^\s*func\s+_on_push_luck_opened\s*\([^)]*\)\s*->\s*void\s*:\s*\n(.*?)(?=^\s*func\s+|\Z)",
        ui_root,
    )
    if push_luck_block is None:
        return fail("missing _on_push_luck_opened handler in ui_root")
    if "apply_run_ui_payload(ui_payload)" not in push_luck_block.group(1):
        return fail("_on_push_luck_opened must dispatch through apply_run_ui_payload directly")

    print("[OK][UI_REACTIVE_CONTRACT_SURFACE] reactive UI lifecycle/payload surface guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
