#!/usr/bin/env python3
"""Static END_RUN audit report (scene + UI wiring).

No Godot runtime required: parses text files only.
Exit code:
- 0 when hard canonical END_RUN paths are present
- 1 when one or more hard canonical paths are missing
"""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path

def _repo_root_from_script() -> Path:
    # Expected layout: <repo>/scripts/ci/audit_end_run_summary.py
    # parents[0]=ci, parents[1]=scripts, parents[2]=<repo>
    script_path = Path(__file__).resolve()
    if script_path.parent.name != "ci" or script_path.parent.parent.name != "scripts":
        raise RuntimeError(
            f"Unsupported script layout: expected .../scripts/ci/, got {script_path.parent}"
        )
    return script_path.parents[2]


try:
    REPO_ROOT = _repo_root_from_script()
except RuntimeError as error:
    REPO_ROOT = None
    REPO_ROOT_ERROR = str(error)
else:
    REPO_ROOT_ERROR = None

SCENE_PATH = REPO_ROOT / "scenes" / "UI.tscn" if REPO_ROOT else Path("/__missing__/scenes/UI.tscn")
UI_ROOT_PATH = REPO_ROOT / "scripts" / "ui" / "ui_root.gd" if REPO_ROOT else Path("/__missing__/scripts/ui/ui_root.gd")

# Back-compat: allow running from repo root with relative paths if someone forks layout.
# (We still prefer absolute paths computed above.)
SCENE_PATH_FALLBACK = Path("scenes/UI.tscn")
UI_ROOT_PATH_FALLBACK = Path("scripts/ui/ui_root.gd")

END_RUN_ROOT = "UI_RunRoot/Phase_END_RUN"
CANON_HARD_PATHS = [
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN",
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN",
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Box_END_RUN_DETAILS",
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_TITLE",
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/Lbl_END_RUN_BODY",
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_RESTART",
    "UI_RunRoot/Phase_END_RUN/Panel_END_RUN/Box_END_RUN/EndRunRouteTabs/Btn_END_RUN_QUIT",
]
SUMMARY_KEYWORDS = [
    "SUMMARY",
    "SUMMARY_BOX",
    "RUN_SUMMARY",
    "DETAILS",
    "REPORT",
    "RECAP",
    "RIEPILOGO",
]

NODE_RE = re.compile(
    r'^\[node\s+name="(?P<name>[^"]+)"\s+type="(?P<type>[^"]+)"(?:\s+parent="(?P<parent>[^"]+)")?.*\]$'
)
ONREADY_END_RUN_RE = re.compile(
    r'^\s*@onready\s+var\s+(?P<var>[A-Za-z_][A-Za-z0-9_]*)\s*:[^=]*=\s*get_node(?:_or_null)?\("(?P<path>[^"]*END_RUN[^"]*)"\)',
)
GENERIC_END_RUN_GETNODE_RE = re.compile(
    r'get_node(?:_or_null)?\("([^"]*END_RUN[^"]*)"\)'
)
FUNC_RE = re.compile(r'^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(')
ASSIGN_RE = re.compile(r'\b([A-Za-z_][A-Za-z0-9_]*)\.(?:text|bbcode_text)\s*=')


def parse_scene_nodes(scene_text: str) -> list[dict[str, str]]:
    nodes: list[dict[str, str]] = []
    for raw_line in scene_text.splitlines():
        line = raw_line.strip()
        match = NODE_RE.match(line)
        if not match:
            continue
        name = match.group("name")
        node_type = match.group("type")
        parent = match.group("parent")

        if parent is None:
            path = name
        elif parent == ".":
            path = name
        else:
            path = f"{parent}/{name}"

        nodes.append({"name": name, "type": node_type, "path": path})
    return nodes


def parse_wiring(ui_text: str) -> tuple[list[tuple[str, str]], dict[str, set[str]]]:
    node_refs: list[tuple[str, str]] = []
    var_to_label_name: dict[str, str] = {}

    for line in ui_text.splitlines():
        match = ONREADY_END_RUN_RE.match(line)
        if not match:
            continue
        var_name = match.group("var")
        path = match.group("path")
        node_refs.append((var_name, path))

        label_candidate = path.split("/")[-1]
        if label_candidate.startswith("Lbl_END_RUN_"):
            var_to_label_name[var_name] = label_candidate

    # Additional non-@onready inline references
    for path in sorted(set(GENERIC_END_RUN_GETNODE_RE.findall(ui_text))):
        if not any(existing_path == path for _, existing_path in node_refs):
            node_refs.append(("(inline)", path))

    label_to_functions: dict[str, set[str]] = defaultdict(set)
    current_func = "<global>"
    for line in ui_text.splitlines():
        func_match = FUNC_RE.match(line)
        if func_match:
            current_func = func_match.group(1)

        for assign_match in ASSIGN_RE.finditer(line):
            var_name = assign_match.group(1)
            label_name = var_to_label_name.get(var_name)
            if label_name:
                label_to_functions[label_name].add(current_func)

    return node_refs, label_to_functions


def main() -> int:
    if REPO_ROOT_ERROR:
        print(f"ERROR: {REPO_ROOT_ERROR}")
        return 1

    scene_path = SCENE_PATH if SCENE_PATH.exists() else SCENE_PATH_FALLBACK
    ui_root_path = UI_ROOT_PATH if UI_ROOT_PATH.exists() else UI_ROOT_PATH_FALLBACK

    if not scene_path.exists():
        print("ERROR: missing scenes/UI.tscn")
        print(f"- Tried: {SCENE_PATH}")
        print(f"- Fallback: {SCENE_PATH_FALLBACK.resolve()}")
        return 1
    if not ui_root_path.exists():
        print("ERROR: missing scripts/ui/ui_root.gd")
        print(f"- Tried: {UI_ROOT_PATH}")
        print(f"- Fallback: {UI_ROOT_PATH_FALLBACK.resolve()}")
        return 1

    scene_text = scene_path.read_text(encoding="utf-8")
    ui_text = ui_root_path.read_text(encoding="utf-8")

    nodes = parse_scene_nodes(scene_text)
    path_set = {node["path"] for node in nodes}

    end_run_nodes = [
        node for node in nodes if node["path"] == END_RUN_ROOT or node["path"].startswith(f"{END_RUN_ROOT}/")
    ]
    end_run_nodes.sort(key=lambda item: item["path"])

    missing = [path for path in CANON_HARD_PATHS if path not in path_set]
    canon_pass = len(missing) == 0

    summary_candidates = []
    for node in end_run_nodes:
        upper_name = node["name"].upper()
        if any(keyword in upper_name for keyword in SUMMARY_KEYWORDS):
            summary_candidates.append(node)

    node_refs, label_to_functions = parse_wiring(ui_text)

    print("[END_RUN AUDIT]")
    print(f"* Scene nodes found: {len(end_run_nodes)}")
    print(f"* Canon guard: {'PASS' if canon_pass else 'FAIL'}")
    if missing:
        print("* Canon missing nodes:")
        for path in missing:
            print(f"  * {path}")
    else:
        print("* Canon missing nodes: []")

    print("\n[END_RUN SUBTREE]")
    if not end_run_nodes:
        print("* <none>")
    else:
        for node in end_run_nodes:
            print(f"* {node['path']} ({node['type']})")

    print("\n[SUMMARY CANDIDATES]")
    if not summary_candidates:
        print("* <none>")
    else:
        for node in summary_candidates:
            print(f"* {node['path']}")

    print("\n[UI ROOT WIRING]")
    print("* Node refs:")
    if not node_refs:
        print("  * <none>")
    else:
        for var_name, path in sorted(node_refs, key=lambda item: (item[0], item[1])):
            print(f"  * {var_name} -> {path}")

    print("* Assignments:")
    if not label_to_functions:
        print("  * <none>")
    else:
        for label_name in sorted(label_to_functions):
            functions = ", ".join(sorted(label_to_functions[label_name]))
            print(f"  * {label_name} set in: {functions}")

    return 0 if canon_pass else 1


if __name__ == "__main__":
    raise SystemExit(main())
