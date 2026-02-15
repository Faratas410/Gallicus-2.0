#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RESOURCE_EXTENSIONS = {".tscn", ".tres", ".theme"}
RES_PATH_PATTERN = re.compile(r"['\"](res://[^'\"]+)['\"]")


def iter_resource_files() -> list[Path]:
    files: list[Path] = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() in RESOURCE_EXTENSIONS:
            files.append(path)
    return files


def has_exact_case_path(rel_path: Path) -> bool:
    current: Path = ROOT
    for segment in rel_path.parts:
        if not current.is_dir():
            return False
        matched: bool = False
        for entry in current.iterdir():
            if entry.name == segment:
                current = entry
                matched = True
                break
        if not matched:
            return False
    return current.exists()


def find_lowercase_matches(rel_path: Path) -> list[Path]:
    target_lower: str = str(rel_path).lower()
    matches: list[Path] = []
    for path in ROOT.rglob("*"):
        if not path.exists():
            continue
        rel = path.relative_to(ROOT)
        if str(rel).lower() == target_lower:
            matches.append(rel)
    return matches


def main() -> int:
    failures: list[tuple[Path, str, str]] = []
    seen: set[tuple[Path, str]] = set()

    for resource_file in iter_resource_files():
        text: str = resource_file.read_text(encoding="utf-8", errors="ignore")
        for match in RES_PATH_PATTERN.finditer(text):
            res_path: str = match.group(1)
            key = (resource_file, res_path)
            if key in seen:
                continue
            seen.add(key)

            rel = Path(res_path.removeprefix("res://"))
            full = ROOT / rel
            if not full.exists():
                matches = find_lowercase_matches(rel)
                if len(matches) == 1:
                    detail = f"missing (closest: res://{matches[0].as_posix()})"
                elif len(matches) > 1:
                    options = ", ".join(f"res://{m.as_posix()}" for m in matches[:5])
                    detail = f"missing (ambiguous candidates: {options})"
                else:
                    detail = "missing"
                failures.append((resource_file.relative_to(ROOT), res_path, detail))
                continue

            if not has_exact_case_path(rel):
                matches = find_lowercase_matches(rel)
                if len(matches) == 1:
                    detail = f"case-mismatch (closest: res://{matches[0].as_posix()})"
                elif len(matches) > 1:
                    options = ", ".join(f"res://{m.as_posix()}" for m in matches[:5])
                    detail = f"case-mismatch (ambiguous candidates: {options})"
                else:
                    detail = "case-mismatch"
                failures.append((resource_file.relative_to(ROOT), res_path, detail))

    if failures:
        print("verify_res_paths: FAILED")
        for resource_file, res_path, detail in failures:
            print(f"- file: {resource_file}")
            print(f"  ref : {res_path}")
            print(f"  err : {detail}")
        return 1

    print("verify_res_paths: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
