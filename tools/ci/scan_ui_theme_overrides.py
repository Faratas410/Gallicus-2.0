#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

THEME_OVERRIDE_PATTERN = re.compile(r"theme_override_")
THEME_RESOURCE_PATTERN = re.compile(r"res://[^\"'\s]*theme[^\"'\s]*\.tres", re.IGNORECASE)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan runtime UI scenes for forbidden theme overrides and alternate theme resources."
    )
    parser.add_argument("--project-root", default=".", help="Project root path (default: current directory).")
    parser.add_argument(
        "--allowed-theme-overrides",
        default="",
        help="Comma-separated allowlist for theme_override_* keys (without prefix). Empty by default.",
    )
    parser.add_argument(
        "--official-theme",
        default="res://ui/theme/official_theme.tres",
        help="Only allowed theme resource path.",
    )
    return parser.parse_args()


def target_scene_paths(project_root: Path) -> list[Path]:
    scenes: list[Path] = []
    ui_root_scene = project_root / "scenes" / "UI.tscn"
    if ui_root_scene.exists():
        scenes.append(ui_root_scene)
    ui_subdir = project_root / "scenes" / "ui"
    if ui_subdir.exists():
        scenes.extend(sorted(p for p in ui_subdir.rglob("*.tscn") if p.is_file()))
    return scenes


def main() -> int:
    args = parse_args()
    project_root = Path(args.project_root).resolve()
    allowed_overrides = {
        f"theme_override_{item.strip()}"
        for item in args.allowed_theme_overrides.split(",")
        if item.strip() != ""
    }
    official_theme = args.official_theme

    scenes = target_scene_paths(project_root)
    if not scenes:
        print("scan_ui_theme_overrides: WARNING no runtime UI scenes found under scenes/UI.tscn or scenes/ui/")
        return 0

    violations: list[str] = []

    for scene_path in scenes:
        rel_path = scene_path.relative_to(project_root)
        lines = scene_path.read_text(encoding="utf-8", errors="ignore").splitlines()
        for idx, line in enumerate(lines, start=1):
            stripped = line.strip()

            if "theme_override_" in stripped:
                key = stripped.split("=", 1)[0].strip()
                if key not in allowed_overrides:
                    violations.append(
                        f"{rel_path}:{idx}: forbidden theme override key '{key}' | {stripped}"
                    )

            for match in THEME_RESOURCE_PATTERN.finditer(stripped):
                resource = match.group(0)
                if resource != official_theme:
                    violations.append(
                        f"{rel_path}:{idx}: alternate theme resource '{resource}' | {stripped}"
                    )

            if "gallicus_ui_theme.tres" in stripped:
                violations.append(
                    f"{rel_path}:{idx}: alternate theme string 'gallicus_ui_theme.tres' | {stripped}"
                )

    if violations:
        print("scan_ui_theme_overrides: FAILED")
        for violation in violations:
            print(f"- {violation}")
        return 1

    print("scan_ui_theme_overrides: OK")
    print(f"- scanned {len(scenes)} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
