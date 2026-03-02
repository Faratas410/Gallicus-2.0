#!/usr/bin/env python3
"""Static audit guard for era visual template anchors.

Audit-only: validates current wiring/anchors without changing runtime behavior.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Iterable

UI_ROOT = Path("scripts/ui/ui_root.gd")
UI_SCENE = Path("scenes/UI.tscn")
ARENA_SCENE = Path("scenes/Arena.tscn")
ARENA_SCRIPT = Path("scripts/Arena.gd")
SCENES_DIR = Path("scenes")

UI_SCAN_PATHS = [
    Path("scripts/ui"),
    Path("scenes"),
]
FORBIDDEN_ERA_RE = re.compile(r"\bera\s*[0-4]\b", re.IGNORECASE)


def fail(message: str) -> int:
    print(f"[FAIL][ERA_VISUAL_TEMPLATE_AUDIT] {message}")
    return 1


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _extract_onready_paths(ui_text: str) -> dict[str, str]:
    pattern = re.compile(
        r"@onready\s+var\s+(?P<var>[A-Za-z0-9_]+)\s*:[^=]*=\s*get_node_or_null\(\"(?P<path>[^\"]+)\"\)"
    )
    out: dict[str, str] = {}
    for match in pattern.finditer(ui_text):
        out[match.group("var")] = match.group("path")
    return out


def _node_exists_in_tscn(tscn_text: str, node_path: str) -> bool:
    node_name = node_path.split("/")[-1]
    return re.search(rf'^\[node\s+name="{re.escape(node_name)}"', tscn_text, re.M) is not None


def _iter_text_files(paths: Iterable[Path]) -> Iterable[Path]:
    for base in paths:
        if not base.exists():
            continue
        for p in base.rglob("*"):
            if not p.is_file():
                continue
            if p.suffix.lower() in {".gd", ".tscn", ".tres", ".cfg", ".txt", ".md"}:
                yield p


def main() -> int:
    required = [UI_ROOT, UI_SCENE, ARENA_SCENE, ARENA_SCRIPT]
    for path in required:
        if not path.exists():
            return fail(f"missing file: {path}")

    ui_root_text = _read_text(UI_ROOT)
    ui_scene_text = _read_text(UI_SCENE)

    if "[gd_scene" not in ui_scene_text:
        return fail("scenes/UI.tscn is not parseable as text gd_scene")

    onready_paths = _extract_onready_paths(ui_root_text)

    arena_theme_vars = ["arena_theme_title_label", "arena_theme_subtitle_label"]
    end_run_vars = ["verdict_header", "verdict_sentence_label", "verdict_outcome"]

    missing_vars = [v for v in arena_theme_vars + end_run_vars if v not in onready_paths]
    if missing_vars:
        return fail("missing expected ui_root onready anchors: " + ", ".join(missing_vars))

    for var_name in arena_theme_vars + end_run_vars:
        node_path = onready_paths[var_name]
        if not _node_exists_in_tscn(ui_scene_text, node_path):
            return fail(f"ui_root anchor path not found in UI.tscn for {var_name}: {node_path}")

    has_arena_theme_signal = bool(
        re.search(r"GameEvents\.arena_theme_changed\.connect\(", ui_root_text)
        or re.search(r"func\s+_on_arena_theme_changed\s*\(", ui_root_text)
    )
    if not has_arena_theme_signal:
        return fail("ui_root.gd missing arena_theme_changed wiring/handler")

    forbidden_hits: list[str] = []
    for path in _iter_text_files(UI_SCAN_PATHS):
        text = _read_text(path)
        for idx, line in enumerate(text.splitlines(), start=1):
            if FORBIDDEN_ERA_RE.search(line):
                forbidden_hits.append(f"{path}:{idx}:{line.strip()}")
    if forbidden_hits:
        preview = "\n".join(forbidden_hits[:20])
        return fail(f"forbidden explicit Era naming found:\n{preview}")

    era_scene_variants = sorted(
        str(p) for p in SCENES_DIR.rglob("*Era*.tscn") if p.is_file()
    )
    if era_scene_variants:
        return fail(
            "duplicate era-scene variants are forbidden; found:\n"
            + "\n".join(era_scene_variants)
        )

    overlay_candidates = sorted(
        {
            path
            for _, path in onready_paths.items()
            if re.search(r"silence|overlay", path, re.IGNORECASE)
        }
    )
    silence_candidates = [p for p in overlay_candidates if re.search(r"silence", p, re.IGNORECASE)]

    print("[OK][ERA_VISUAL_TEMPLATE_AUDIT] static era visual template audit passed")
    print("ANCHOR_MAP_BEGIN")
    print(f"ANCHOR_UI_ROOT_ARENA_THEME_TITLE={onready_paths['arena_theme_title_label']}")
    print(f"ANCHOR_UI_ROOT_ARENA_THEME_SUBTITLE={onready_paths['arena_theme_subtitle_label']}")
    print(f"ANCHOR_UI_ROOT_END_RUN_HEADER={onready_paths['verdict_header']}")
    print(f"ANCHOR_UI_ROOT_END_RUN_BODY={onready_paths['verdict_sentence_label']}")
    print(f"ANCHOR_UI_ROOT_END_RUN_REGISTER_MESSAGE={onready_paths['verdict_outcome']}")
    if overlay_candidates:
        for candidate in overlay_candidates:
            print(f"ANCHOR_UI_OVERLAY_CANDIDATE={candidate}")
    if silence_candidates:
        for candidate in silence_candidates:
            print(f"ANCHOR_UI_SILENCE_OVERLAY_CANDIDATE={candidate}")
    else:
        print("ANCHOR_UI_SILENCE_OVERLAY_CANDIDATE=MISSING")
    print("ANCHOR_MAP_END")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
