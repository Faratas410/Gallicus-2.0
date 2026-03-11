#!/usr/bin/env python3
"""Report suspicious duplicate/drift filenames.

Default behavior is report-only (exit code 0). Optional --strict can fail CI,
but only on *new* findings when a baseline is provided.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

SUSPECT_TOKEN_RE = re.compile(
    r"(?i)(?:^|[\s._-])(copy(?:\d+)?|final\d*|backup|bak|old|tmp|temp|draft)(?:$|[\s._-])"
)
SUFFIX_RE = re.compile(
    r"(?i)(?:[\s._-](?:copy(?:\d+)?|final\d*|backup|bak|old|tmp|temp|draft))+\Z"
)
SKIP_DIR_NAMES = {".git", ".godot", ".import"}
SKIP_RELATIVE_PREFIXES = ("tools/godot/",)


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Report suspicious duplicate/drift filenames")
    parser.add_argument("--root", default=".", help="Repository root to scan")
    parser.add_argument(
        "--baseline",
        default="scripts/ci/suspect_duplicate_baseline.txt",
        help="Optional baseline file with known findings (one item per line)",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return exit code 1 when new findings exist",
    )
    return parser.parse_args()


def _should_skip(path: Path) -> bool:
    if any(part in SKIP_DIR_NAMES for part in path.parts):
        return True
    posix = path.as_posix()
    return any(posix.startswith(prefix) for prefix in SKIP_RELATIVE_PREFIXES)


def _normalized_stem(path: Path) -> str:
    return SUFFIX_RE.sub("", path.stem)


def _load_baseline(path: Path) -> set[str]:
    if not path.exists():
        return set()
    items: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        items.add(line)
    return items


def main() -> int:
    args = _parse_args()
    root = Path(args.root).resolve()
    if not root.exists() or not root.is_dir():
        print(f"report_suspect_duplicate_files: FAILED (invalid root: {root})")
        return 1

    baseline = _load_baseline(Path(args.baseline))

    findings: set[str] = set()
    normalized_collisions: dict[tuple[str, str], list[str]] = {}

    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(root)
        if _should_skip(rel):
            continue

        rel_text = rel.as_posix()
        file_name = rel.name
        if SUSPECT_TOKEN_RE.search(file_name):
            findings.add(f"token:{rel_text}")

        normalized = _normalized_stem(rel)
        key = (str(rel.parent), f"{normalized}{rel.suffix.lower()}")
        normalized_collisions.setdefault(key, []).append(rel_text)

    for group in normalized_collisions.values():
        if len(group) > 1:
            for rel_text in sorted(group):
                findings.add(f"collision:{rel_text}")

    if not findings:
        print("report_suspect_duplicate_files: OK (no suspect duplicate/drift filenames)")
        return 0

    new_findings = sorted(item for item in findings if item not in baseline)
    known_findings = sorted(item for item in findings if item in baseline)

    print("report_suspect_duplicate_files: REPORT")
    print(f"- total findings: {len(findings)}")
    print(f"- known findings (baseline): {len(known_findings)}")
    print(f"- new findings: {len(new_findings)}")

    if new_findings:
        print("- new findings:")
        for item in new_findings:
            print(f"  - {item}")

    if known_findings:
        print("- known findings:")
        for item in known_findings:
            print(f"  - {item}")

    if args.strict and new_findings:
        print("report_suspect_duplicate_files: FAILED (--strict with new findings)")
        return 1

    print("report_suspect_duplicate_files: OK (report-only or no new findings)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
