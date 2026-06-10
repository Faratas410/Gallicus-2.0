#!/usr/bin/env python3
"""Static guard for Gallicus v0.5 internal-beta content coverage."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BET_CATALOG = ROOT / "scripts" / "content" / "bet_catalog.gd"
ARENA_THEMES = ROOT / "data" / "arena_themes.gd"
ENDING_RULES = ROOT / "data" / "ending_rules.gd"
SMOKE_WORKFLOW = ROOT / ".github" / "workflows" / "godot_smoke_runtime.yml"


REQUIRED_BETA_SCENARIOS = {
    "BETA_CASHOUT",
    "BETA_DOUBLE",
    "BETA_CONDANNA",
    "BETA_REGISTER_FINAL",
}


def fail(message: str) -> int:
    print(f"[FAIL][BETA_CONTENT_CONTRACT] {message}")
    return 1


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _extract_const_block(source: str, const_name: str) -> str:
    marker = f"const {const_name}"
    start = source.find(marker)
    if start < 0:
        raise AssertionError(f"missing const block {const_name}")
    next_static = source.find("\nstatic func ", start)
    next_const = source.find("\nconst ", start + len(marker))
    candidates = [value for value in [next_static, next_const] if value > start]
    end = min(candidates) if candidates else len(source)
    return source[start:end]


def _extract_active_bet_entries(block: str) -> dict[str, str]:
    entries: dict[str, str] = {}
    pattern = re.compile(r"\n\t(?P<id>BET_[A-Z0-9_]+):\s*\{(?P<body>.*?)\n\t\},", re.S)
    for match in pattern.finditer(block):
        entries[match.group("id")] = match.group("body")
    return entries


def _extract_level3_bet_ids(source: str) -> set[str]:
    block = _extract_const_block(source, "LEVEL3_BETS")
    return set(re.findall(r'"id":\s*"([^"]+)"', block))


def test_beta_content_contract() -> int:
    bet_catalog = _read(BET_CATALOG)
    arena_themes = _read(ARENA_THEMES)
    ending_rules = _read(ENDING_RULES)
    smoke_workflow = _read(SMOKE_WORKFLOW)

    active_block = _extract_const_block(bet_catalog, "L3_ACTIVE_BET_IDENTITIES")
    active_entries = _extract_active_bet_entries(active_block)
    if len(active_entries) < 8:
        return fail(f"expected at least 8 active beta bet identities, found {len(active_entries)}")

    level3_ids = _extract_level3_bet_ids(bet_catalog)
    path_tags: set[str] = set()
    behavior_tokens: set[str] = set()
    for const_id, body in active_entries.items():
        for token in ['"token"', '"display_title"', '"display_subtitle"', '"path_tag"', '"behavior"']:
            if token not in body:
                return fail(f"{const_id} missing active identity field {token}")
        behavior_match = re.search(r'"behavior":\s*(BET_[A-Z0-9_]+)', body)
        if behavior_match:
            behavior_tokens.add(behavior_match.group(1))
        path_match = re.search(r'"path_tag":\s*(PATH_[A-Z0-9_]+)', body)
        if path_match:
            path_tags.add(path_match.group(1))
        level3_id = const_id.removeprefix("BET_")
        if level3_id not in level3_ids:
            return fail(f"active identity {const_id} has no matching LEVEL3_BETS id {level3_id}")

    if len(path_tags - {"PATH_UNKNOWN"}) < 4:
        return fail(f"expected at least 4 active path tags, found {sorted(path_tags)}")
    if len(behavior_tokens) < 4:
        return fail(f"expected at least 4 mapped behaviors, found {sorted(behavior_tokens)}")

    theme_titles = re.findall(r'"title":\s*"([^"]+)"', arena_themes)
    theme_subtitles = re.findall(r'"subtitle":\s*"([^"]+)"', arena_themes)
    if len([value for value in theme_titles if value.strip()]) < 4:
        return fail("expected at least 4 arena theme titles")
    if len([value for value in theme_subtitles if value.strip()]) < 4:
        return fail("expected at least 4 arena theme subtitles")

    ending_keys = set(re.findall(r'"ending_key":\s*&"([^"]+)"', ending_rules))
    if len(ending_keys) < 6:
        return fail(f"expected at least 6 reachable ending keys, found {sorted(ending_keys)}")

    for scenario in REQUIRED_BETA_SCENARIOS:
        if scenario not in smoke_workflow:
            return fail(f"smoke workflow missing beta scenario {scenario}")

    for beta_doc in ["BETA_0_5_PLAN.md", "BETA_PLAYTEST_CHECKLIST.md", "BETA_0_5_RELEASE_NOTES.md"]:
        if not (ROOT / beta_doc).exists():
            return fail(f"missing beta document {beta_doc}")

    print("[OK][BETA_CONTENT_CONTRACT] beta content contract guard passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(test_beta_content_contract())
