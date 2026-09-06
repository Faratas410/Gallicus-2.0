#!/usr/bin/env python3
"""Guard the small Gallicus i18n contract.

Every locale listed in assets/i18n/languages.gd must point at an existing CSV,
and every CSV must expose the same key set as the default Italian source.
"""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
LANGUAGES_PATH = ROOT / "assets/i18n/languages.gd"
DEFAULT_CSV = ROOT / "assets/i18n/it.csv"
MAIN_MENU_PATH = ROOT / "scripts/ui/main_menu.gd"
RUN_MANAGER_PATH = ROOT / "scripts/systems/run_manager.gd"


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
        key = row[0]
        if not key.strip():
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
        compiled_path = path.with_name(f"{path.stem}.{locale}.translation")
        if not compiled_path.exists():
            raise AssertionError(
                f"registered locale {locale} points at missing compiled Translation: "
                f"{compiled_path}"
            )

    default_keys = _csv_keys(DEFAULT_CSV)
    default_key_set = set(default_keys)
    # Check the keys the UI actually requests, not only agreement between CSVs.
    for source_path in (ROOT / "scripts").rglob("*.gd"):
        if "ci" in source_path.parts:
            continue
        source = source_path.read_text(encoding="utf-8")
        for match in re.finditer(r'\btr\(("(?:[^"\\]|\\.)*")\)', source):
            key = json.loads(match.group(1))
            if not key or key == "I    II    III":
                continue
            if key not in default_key_set:
                raise AssertionError(f"{source_path.relative_to(ROOT)}: uncatalogued tr key {key!r}")
    for locale, path in registry.items():
        keys = _csv_keys(path)
        key_set = set(keys)
        missing = sorted(default_key_set - key_set)
        extra = sorted(key_set - default_key_set)
        if missing or extra:
            raise AssertionError(
                f"{locale} CSV key mismatch; missing={missing[:8]} extra={extra[:8]}"
            )

    main_menu = MAIN_MENU_PATH.read_text(encoding="utf-8")
    for token in (
        "func _load_imported_translation",
        "func _compiled_translation_path",
        "func _translation_resource_exists",
        "ResourceLoader.exists(translation_path)",
        'ResourceLoader.load(translation_path, "Translation")',
    ):
        if token not in main_menu:
            raise AssertionError(f"missing exported translation bootstrap contract: {token}")

    run_manager = RUN_MANAGER_PATH.read_text(encoding="utf-8")
    for token in (
        "func _compiled_translation_path",
        "func _translation_resource_exists",
        "ResourceLoader.exists(",
        "_compiled_translation_path(csv_path, locale)",
    ):
        if token not in run_manager:
            raise AssertionError(
                f"missing RunManager exported translation contract: {token}"
            )
    resolver_match = re.search(
        r"(?ms)^func _resolve_available_locale\(target_locale: String\) -> String:\n"
        r"(.*?)(?=^func |\Z)",
        run_manager,
    )
    if resolver_match is None:
        raise AssertionError("RunManager locale resolver is missing")
    resolver = resolver_match.group(1)
    for token in (
        "_translation_resource_exists(requested_path, target_locale)",
        "_translation_resource_exists(fallback_path, fallback_locale)",
    ):
        if token not in resolver:
            raise AssertionError(
                f"RunManager locale resolver ignores compiled Translation: {token}"
            )
    for csv_only_check in (
        "FileAccess.file_exists(requested_path)",
        "FileAccess.file_exists(fallback_path)",
    ):
        if csv_only_check in resolver:
            raise AssertionError(
                f"RunManager locale resolver remains CSV-only: {csv_only_check}"
            )

    print("[OK][I18N_CONTRACT] source CSV and exported translation contracts are aligned")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
