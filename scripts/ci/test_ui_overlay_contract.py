#!/usr/bin/env python3
"""Static contract guard for FIRST_REACTION + RESOLUTION overlays."""

from __future__ import annotations

import re
import sys
from pathlib import Path

UI_ROOT = Path("scripts/ui/ui_root.gd")
GAME_EVENTS = Path("scripts/systems/game_events.gd")


def fail(message: str) -> int:
    print(f"[FAIL][UI_OVERLAY_CONTRACT] {message}")
    return 1


def main() -> int:
    if not UI_ROOT.exists():
        return fail(f"missing file: {UI_ROOT}")
    if not GAME_EVENTS.exists():
        return fail(f"missing file: {GAME_EVENTS}")

    ui = UI_ROOT.read_text(encoding="utf-8")
    events = GAME_EVENTS.read_text(encoding="utf-8")

    # RESOLUTION overlay guard: require resolve ritual event wiring, or canonical handlers.
    resolve_wiring_tokens = [
        "GameEvents.resolve_ritual_opened.connect",
        "GameEvents.resolve_ritual_closed.connect",
    ]
    resolve_handler_tokens = [
        "func _on_resolve_ritual_opened",
        "func _on_resolve_ritual_closed",
    ]
    has_resolve_wiring = all(token in ui for token in resolve_wiring_tokens)
    has_resolve_handlers = all(token in ui for token in resolve_handler_tokens)
    if not (has_resolve_wiring or has_resolve_handlers):
        return fail(
            "ui_root.gd must reference resolve_ritual_opened/closed wiring or canonical resolve handler functions"
        )

    # FIRST_REACTION + RESOLUTION post-bet rendering path guard.
    post_bet_tokens = [
        "func enqueue_post_bet_message",
        "func _show_post_bet_payload",
        'kind == "pact_sealed"',
        'kind == "resolve_ritual"',
        'payload.get("title"',
        'payload.get("subtitle"',
    ]
    missing_post_bet = [token for token in post_bet_tokens if token not in ui]
    if missing_post_bet:
        return fail(
            "missing post-bet overlay contract token(s) in ui_root.gd: "
            + ", ".join(missing_post_bet)
        )

    # GameEvents declaration guard.
    opened_decl = re.search(r"^\s*signal\s+resolve_ritual_opened\s*\(\s*payload\s*:\s*Dictionary\s*\)", events, re.M)
    closed_decl = re.search(r"^\s*signal\s+resolve_ritual_closed\s*$", events, re.M)
    if opened_decl is None:
        return fail("missing GameEvents signal declaration: resolve_ritual_opened(payload: Dictionary)")
    if closed_decl is None:
        return fail("missing GameEvents signal declaration: resolve_ritual_closed")

    print("[OK][UI_OVERLAY_CONTRACT] static overlay contract guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
