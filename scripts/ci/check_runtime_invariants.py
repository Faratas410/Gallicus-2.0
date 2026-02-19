#!/usr/bin/env python3
"""Static runtime invariant checks for Level 3 governance."""

from __future__ import annotations

import re
from pathlib import Path

EXPECTED_MAIN_SCENE = "res://scenes/Main.tscn"
EXPECTED_GAMEEVENTS_AUTOLOAD = "*res://scripts/systems/game_events.gd"
EXPECTED_RUNMANAGER_SCRIPT = "res://scripts/systems/run_manager.gd"
EXPECTED_GROUP = "run_manager"

MAIN_SCENE_RE = re.compile(r'^run/main_scene="([^"]+)"$')
AUTOLOAD_GAMEEVENTS_RE = re.compile(r'^GameEvents="([^"]+)"$')
EXT_RESOURCE_RE = re.compile(
    r'^\[ext_resource\s+type="Script"\s+path="([^"]+)"\s+id="([^"]+)"\]$'
)
RUNMANAGER_NODE_RE = re.compile(
    r'^\[node\s+name="RunManager"\s+type="Node"\s+parent="\."\s+groups=\[([^\]]*)\]\]$'
)
SCRIPT_BIND_RE = re.compile(r'^script\s*=\s*ExtResource\("([^"]+)"\)$')


def fail(message: str) -> int:
    print("check_runtime_invariants: FAILED")
    print(f" - {message}")
    return 1


def parse_project_setting(lines: list[str], pattern: re.Pattern[str]) -> str | None:
    for line in lines:
        match = pattern.match(line.strip())
        if match:
            return match.group(1)
    return None


def main() -> int:
    project = Path("project.godot")
    main_scene = Path("scenes/Main.tscn")

    if not project.exists():
        return fail("missing project.godot")
    if not main_scene.exists():
        return fail("missing scenes/Main.tscn")

    project_lines = project.read_text(encoding="utf-8").splitlines()
    configured_main_scene = parse_project_setting(project_lines, MAIN_SCENE_RE)
    if configured_main_scene != EXPECTED_MAIN_SCENE:
        return fail(
            "entry scene mismatch: "
            f"expected={EXPECTED_MAIN_SCENE}, actual={configured_main_scene}"
        )

    gameevents_autoload = parse_project_setting(project_lines, AUTOLOAD_GAMEEVENTS_RE)
    if gameevents_autoload != EXPECTED_GAMEEVENTS_AUTOLOAD:
        return fail(
            "GameEvents autoload mismatch: "
            f"expected={EXPECTED_GAMEEVENTS_AUTOLOAD}, actual={gameevents_autoload}"
        )

    tscn_lines = main_scene.read_text(encoding="utf-8").splitlines()

    script_by_id: dict[str, str] = {}
    for line in tscn_lines:
        match = EXT_RESOURCE_RE.match(line.strip())
        if match:
            script_path, resource_id = match.group(1), match.group(2)
            script_by_id[resource_id] = script_path

    runmanager_node_indexes = [
        index for index, raw in enumerate(tscn_lines) if RUNMANAGER_NODE_RE.match(raw.strip())
    ]
    if len(runmanager_node_indexes) != 1:
        return fail(f"expected exactly 1 RunManager node in Main.tscn, found {len(runmanager_node_indexes)}")

    node_index = runmanager_node_indexes[0]
    node_line = tscn_lines[node_index].strip()
    group_match = RUNMANAGER_NODE_RE.match(node_line)
    assert group_match is not None
    groups_blob = group_match.group(1)
    groups = {item.strip().strip('"') for item in groups_blob.split(",") if item.strip()}
    if groups != {EXPECTED_GROUP}:
        return fail(f"RunManager groups mismatch: expected [{EXPECTED_GROUP}], actual={sorted(groups)}")

    bound_script_id: str | None = None
    for line in tscn_lines[node_index + 1 :]:
        stripped = line.strip()
        if stripped.startswith("[node "):
            break
        script_match = SCRIPT_BIND_RE.match(stripped)
        if script_match:
            bound_script_id = script_match.group(1)
            break

    if bound_script_id is None:
        return fail("RunManager node has no script binding")

    bound_script_path = script_by_id.get(bound_script_id)
    if bound_script_path != EXPECTED_RUNMANAGER_SCRIPT:
        return fail(
            "RunManager script mismatch: "
            f"expected={EXPECTED_RUNMANAGER_SCRIPT}, actual={bound_script_path}"
        )

    print("check_runtime_invariants: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
