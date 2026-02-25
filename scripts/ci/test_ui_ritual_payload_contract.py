#!/usr/bin/env python3
"""Static guardrail for ritual-only outcome keys in ui_root.gd."""

from __future__ import annotations

import re
import sys
from pathlib import Path

UI_ROOT = Path("scripts/ui/ui_root.gd")

# Legacy/combat-oriented keys must never appear in ui_root ritual rendering paths.
LEGACY_KEYS = [
    "enemy_profile",
    "damage_mod",
    "damage_chance",
    "took_damage",
    "hp_loss",
    "enemy_hp",
    "player_hp",
    "damage",
]

# Canonical ritual-only outcome keys that UI must reference for clarity rendering.
RITUAL_KEYS = [
    "risk_profile",
    "pressure_mod",
    "failure_chance",
    "outcome_tier",
    "condemnation_flag",
]


def fail(message: str) -> int:
    print(f"[FAIL][UI_RITUAL_PAYLOAD_CONTRACT] {message}")
    return 1


def main() -> int:
    if not UI_ROOT.exists():
        return fail(f"missing file: {UI_ROOT}")

    ui = UI_ROOT.read_text(encoding="utf-8")

    # Hard fail if legacy keys are referenced directly as payload keys in ui_root.gd.
    legacy_hits: list[str] = []
    for key in LEGACY_KEYS:
        if (
            f'"{key}"' in ui
            or f"'{key}'" in ui
            or re.search(rf"\b{re.escape(key)}\b", ui)
        ):
            legacy_hits.append(key)
    if legacy_hits:
        return fail(
            "legacy outcome key(s) referenced in ui_root.gd: "
            + ", ".join(sorted(set(legacy_hits)))
        )

    # Require ritual-only keys to be referenced as payload keys by ui_root.gd.
    missing_ritual: list[str] = []
    for key in RITUAL_KEYS:
        has_key = (
            f'payload.get("{key}"' in ui
            or f"payload.get('{key}'" in ui
            or f'payload.has("{key}"' in ui
            or f"payload.has('{key}'" in ui
            or f'meta.get("{key}"' in ui
            or f"meta.get('{key}'" in ui
            or f'meta.has("{key}"' in ui
            or f"meta.has('{key}'" in ui
        )
        if not has_key:
            missing_ritual.append(key)
    if missing_ritual:
        return fail(
            "missing ritual-only key reference(s) in ui_root.gd: "
            + ", ".join(missing_ritual)
        )

    print("[OK][UI_RITUAL_PAYLOAD_CONTRACT] ritual-only payload guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
