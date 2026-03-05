#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys


UTF8_BOM = b"\xef\xbb\xbf"


def main() -> int:
    root = Path(".").resolve()
    failures: list[str] = []

    for path in root.rglob("*.tscn"):
        rel = path.relative_to(root)
        raw = path.read_bytes()

        if raw.startswith(UTF8_BOM):
            failures.append(f"{rel}: has UTF-8 BOM (not allowed for .tscn)")
            continue

        if not raw:
            failures.append(f"{rel}: empty file")
            continue

        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            failures.append(f"{rel}: not valid UTF-8")
            continue

        stripped = text.lstrip()
        if not stripped.startswith("[gd_scene"):
            preview = stripped[:32].replace("\n", "\\n")
            failures.append(f"{rel}: invalid header, expected '[gd_scene' (got: {preview!r})")

    if failures:
        print("check_tscn_format: FAILED")
        for item in failures:
            print(f"- {item}")
        return 1

    print("check_tscn_format: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())