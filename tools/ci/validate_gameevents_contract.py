#!/usr/bin/env python3
"""Validate required GameEvents signal declarations against a versioned contract doc."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

SIGNAL_RE = re.compile(r"^\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:\(([^)]*)\))?\s*$")
TABLE_RE = re.compile(r"^\|\s*`([A-Za-z_][A-Za-z0-9_]*)`\s*\|\s*([0-9]+)\s*\|")


def parse_gameevents_signals(path: Path) -> dict[str, int]:
    signals: dict[str, int] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        match = SIGNAL_RE.match(raw_line)
        if not match:
            continue
        name = match.group(1)
        args_blob = (match.group(2) or "").strip()
        if not args_blob:
            arity = 0
        else:
            arity = len([item for item in args_blob.split(",") if item.strip()])
        signals[name] = arity
    return signals


def parse_contract(path: Path) -> dict[str, int]:
    required: dict[str, int] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        match = TABLE_RE.match(raw_line.strip())
        if not match:
            continue
        required[match.group(1)] = int(match.group(2))
    return required


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--contract",
        default="docs/contracts/gameevents_signal_contract_v1.md",
        help="Path to signal contract markdown table.",
    )
    parser.add_argument(
        "--gameevents",
        default="scripts/systems/game_events.gd",
        help="Path to game_events.gd file.",
    )
    args = parser.parse_args()

    contract_path = Path(args.contract)
    gameevents_path = Path(args.gameevents)

    required = parse_contract(contract_path)
    declared = parse_gameevents_signals(gameevents_path)

    if not required:
        print(f"validate_gameevents_contract: FAILED (no contract entries parsed from {contract_path})")
        return 1

    failures: list[str] = []
    for name, required_arity in required.items():
        if name not in declared:
            failures.append(f"missing signal: {name}")
            continue
        declared_arity = declared[name]
        if declared_arity != required_arity:
            failures.append(
                f"arity mismatch for {name}: required={required_arity}, declared={declared_arity}"
            )

    if failures:
        print("validate_gameevents_contract: FAILED")
        for item in failures:
            print(f" - {item}")
        return 1

    print(
        "validate_gameevents_contract: OK "
        f"({len(required)} required signals validated against {gameevents_path})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
