#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

RESOURCE_EXTENSIONS = {".tscn", ".tres", ".theme"}
RES_PATH_PATTERN = re.compile(r"['\"](res://[^'\"]+)['\"]")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Verify res:// references exist with exact-case paths.")
    parser.add_argument(
        "--project-root",
        default=".",
        help="Godot project root (folder containing project.godot). Defaults to current working directory.",
    )
    return parser.parse_args()


def build_path_indexes(project_root: Path) -> tuple[list[Path], dict[str, list[Path]]]:
    resource_files: list[Path] = []
    lowercase_index: dict[str, list[Path]] = {}

    for path in project_root.rglob("*"):
        rel_path = path.relative_to(project_root)
        rel_lower = str(rel_path).lower()
        if rel_lower not in lowercase_index:
            lowercase_index[rel_lower] = []
        lowercase_index[rel_lower].append(rel_path)

        if path.is_file() and path.suffix.lower() in RESOURCE_EXTENSIONS:
            resource_files.append(path)

    return resource_files, lowercase_index


def has_exact_case_path(project_root: Path, rel_path: Path) -> bool:
    current: Path = project_root
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


def find_lowercase_matches(lowercase_index: dict[str, list[Path]], rel_path: Path) -> list[Path]:
    target_lower: str = str(rel_path).lower()
    return lowercase_index.get(target_lower, [])


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    if not project_root.exists() or not project_root.is_dir():
        print(f"verify_res_paths: FAILED\n- invalid project root: {project_root}")
        return 1

    resource_files, lowercase_index = build_path_indexes(project_root)

    failures: list[tuple[Path, str, str]] = []
    seen: set[tuple[Path, str]] = set()

    for resource_file in resource_files:
        text: str = resource_file.read_text(encoding="utf-8", errors="ignore")
        for match in RES_PATH_PATTERN.finditer(text):
            res_path: str = match.group(1)
            key = (resource_file, res_path)
            if key in seen:
                continue
            seen.add(key)

            rel = Path(res_path.removeprefix("res://"))
            full = project_root / rel
            if not full.exists():
                matches = find_lowercase_matches(lowercase_index, rel)
                if len(matches) == 1:
                    detail = f"missing (closest: res://{matches[0].as_posix()})"
                elif len(matches) > 1:
                    options = ", ".join(f"res://{m.as_posix()}" for m in matches[:5])
                    detail = f"missing (ambiguous candidates: {options})"
                else:
                    detail = "missing"
                failures.append((resource_file.relative_to(project_root), res_path, detail))
                continue

            if not has_exact_case_path(project_root, rel):
                matches = find_lowercase_matches(lowercase_index, rel)
                if len(matches) == 1:
                    detail = f"case-mismatch (closest: res://{matches[0].as_posix()})"
                elif len(matches) > 1:
                    options = ", ".join(f"res://{m.as_posix()}" for m in matches[:5])
                    detail = f"case-mismatch (ambiguous candidates: {options})"
                else:
                    detail = "case-mismatch"
                failures.append((resource_file.relative_to(project_root), res_path, detail))

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
