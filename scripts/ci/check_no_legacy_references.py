#!/usr/bin/env python3
"""Fail if active runtime files reference the legacy runtime namespace."""

from __future__ import annotations

from pathlib import Path

RES_SCHEME = "res://"
NAMESPACE_PARTS: tuple[str, str] = ("legacy", "runtime")
FORBIDDEN_PREFIXES: tuple[str, ...] = (
    RES_SCHEME + "_".join(NAMESPACE_PARTS) + "/",
)

SCAN_PATHS: tuple[str, ...] = (
    "scenes/Main.tscn",
    "scripts/systems/run_manager.gd",
    "scenes/ui",
    "scripts/ui",
)

SCAN_EXTS: tuple[str, ...] = (".gd", ".tscn", ".tres")


def iter_files() -> list[Path]:
    files: list[Path] = []
    for raw in SCAN_PATHS:
        path = Path(raw)
        if path.is_file():
            files.append(path)
            continue
        if path.is_dir():
            for candidate in sorted(path.rglob("*")):
                if candidate.is_file() and candidate.suffix in SCAN_EXTS:
                    files.append(candidate)
    return files


def main() -> int:
    violations: list[str] = []
    for file_path in iter_files():
        for line_no, line in enumerate(file_path.read_text(encoding="utf-8").splitlines(), start=1):
            if any(prefix in line for prefix in FORBIDDEN_PREFIXES):
                violations.append(f"{file_path}:{line_no}: {line.strip()}")

    if violations:
        print("check_no_legacy_references: FAILED")
        print(f" - found active runtime references to forbidden prefix(es): {', '.join(FORBIDDEN_PREFIXES)}")
        for item in violations:
            print(f"   {item}")
        return 1

    print("check_no_legacy_references: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
