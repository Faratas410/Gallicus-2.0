#!/usr/bin/env python3
"""Repository text scan for forbidden mojibake marker codepoints."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FORBIDDEN = {
    "\u00c3": "U+00C3",
    "\u00c2": "U+00C2",
    "\ufffd": "U+FFFD",
}
TEXT_SUFFIXES = {
    ".gd",
    ".py",
    ".md",
    ".txt",
    ".tscn",
    ".tres",
    ".csv",
    ".yml",
    ".yaml",
    ".json",
}
SKIP_DIRS = {".git", ".godot", ".import", "__pycache__", "tools", "artifacts", ".tmp_smoke", ".tmp_ci_logs"}


def fail(message: str) -> int:
    print(f"[FAIL][NO_MOJIBAKE] {message}")
    return 1


def _iter_text_files() -> list[Path]:
    result: list[Path] = []
    for path in ROOT.rglob("*"):
        if any(part in SKIP_DIRS for part in path.relative_to(ROOT).parts):
            continue
        if path.is_file() and path.suffix.lower() in TEXT_SUFFIXES:
            result.append(path)
    return result


def main() -> int:
    findings: list[str] = []
    for path in _iter_text_files():
        text = path.read_text(encoding="utf-8", errors="replace")
        for line_number, line in enumerate(text.splitlines(), start=1):
            for marker, label in FORBIDDEN.items():
                if marker in line:
                    rel = path.relative_to(ROOT)
                    findings.append(f"{rel}:{line_number}: forbidden {label}")
    if findings:
        for finding in findings[:50]:
            print(finding)
        return fail(f"found {len(findings)} forbidden mojibake markers")
    print("[OK][NO_MOJIBAKE] no forbidden mojibake markers found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
