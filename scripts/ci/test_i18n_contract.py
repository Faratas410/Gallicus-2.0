#!/usr/bin/env python3
"""Guard the small Gallicus i18n contract.

Every locale listed in assets/i18n/languages.gd must point at an existing CSV,
and every CSV must expose the same key set as the default Italian source.
"""

from __future__ import annotations

import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
LANGUAGES_PATH = ROOT / "assets/i18n/languages.gd"
DEFAULT_CSV = ROOT / "assets/i18n/it.csv"


def _registry_paths() -> dict[str, Path]:
    text = LANGUAGES_PATH.read_text(encoding="utf-8")
    entries: dict[str, Path] = {}
    for match in re.finditer(r'"locale":\s*"([^"]+)".*?"path":\s*"res://([^"]+)"', text, re.DOTALL):
        locale = match.group(1)
        path = ROOT / match.group(2)
        entries[locale] = path
    return entries


def _csv_keys(path: Path) -> list[str]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        rows = list(csv.reader(handle))
    if not rows:
        raise AssertionError(f"{path} is empty")
    header = rows[0]
    if len(header) != 2 or header[0] != "keys":
        raise AssertionError(f"{path} must start with 'keys,<locale>'")
    keys: list[str] = []
    for line_index, row in enumerate(rows[1:], start=2):
        if len(row) != 2:
            raise AssertionError(f"{path}:{line_index} must have exactly 2 columns")
        key = row[0].strip()
        if not key:
            raise AssertionError(f"{path}:{line_index} has empty key")
        keys.append(key)
    if len(keys) != len(set(keys)):
        raise AssertionError(f"{path} contains duplicate i18n keys")
    return keys


def main() -> int:
    registry = _registry_paths()
    if not registry:
        raise AssertionError("no languages registered")
    if "it" not in registry:
        raise AssertionError("default locale 'it' must be registered")
    for locale, path in registry.items():
        if not path.exists():
            raise AssertionError(f"registered locale {locale} points at missing CSV: {path}")

    default_keys = _csv_keys(DEFAULT_CSV)
    default_key_set = set(default_keys)
    for locale, path in registry.items():
        keys = _csv_keys(path)
        key_set = set(keys)
        missing = sorted(default_key_set - key_set)
        extra = sorted(key_set - default_key_set)
        if missing or extra:
            raise AssertionError(
                f"{locale} CSV key mismatch; missing={missing[:8]} extra={extra[:8]}"
            )

    print("[OK][I18N_CONTRACT] language registry and CSV keys are aligned")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
