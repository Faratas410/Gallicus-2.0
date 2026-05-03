#!/usr/bin/env python3
"""Fail when active docs point at missing active repository docs.

Canon files may mention historical lineage with `legacy:<slug>`, but active
`docs/...` references should resolve to real files. This keeps the documentation
surface small and auditable after consolidation passes.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DOCS_ROOT = ROOT / "docs"

DOC_REF_PATTERN = re.compile(
    r"`([^`]+)`|\(([^)]+)\)|(?:^|\s)(docs/[A-Za-z0-9_./-]+\.(?:md|tsv|txt|csv))",
    re.MULTILINE,
)


def _iter_active_markdown_files() -> list[Path]:
    return [
        path
        for path in DOCS_ROOT.rglob("*.md")
        if "archive" not in path.relative_to(DOCS_ROOT).parts
    ]


def _extract_doc_refs(text: str) -> list[str]:
    refs: list[str] = []
    for match in DOC_REF_PATTERN.finditer(text):
        raw = next((group for group in match.groups() if group), "")
        candidate = raw.split("#", 1)[0].strip()
        if candidate.startswith("docs/") or candidate == "repo_map.md":
            refs.append(candidate)
    return refs


def main() -> int:
    missing: list[tuple[str, str]] = []
    for path in _iter_active_markdown_files():
        rel_doc = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8", errors="ignore")
        for ref in _extract_doc_refs(text):
            if not (ROOT / ref).exists():
                missing.append((rel_doc, ref))

    if missing:
        print("[FAIL][DOCS_ACTIVE_REFS] missing active documentation references")
        for rel_doc, ref in missing:
            print(f"- {rel_doc}: {ref}")
        print("Use an existing docs path, or mark retired lineage as legacy:<slug>.")
        return 1

    print("[OK][DOCS_ACTIVE_REFS] active docs reference only existing docs paths")
    return 0


if __name__ == "__main__":
    sys.exit(main())
