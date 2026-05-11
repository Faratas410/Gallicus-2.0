#!/usr/bin/env python3
"""Guard player-facing terminology for the clear-ritual copy pass.

This intentionally checks only visible/copy-bearing surfaces and exact stale
phrases. Runtime identifiers such as RunManager, cashout signals, or escalation
fields remain technical and are not part of this player-facing contract.
"""

from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
I18N_DIR = ROOT / "assets" / "i18n"
GLOSSARY = ROOT / "docs" / "canon" / "GLOSSARY_ENTITIES.md"
UI_CANON = ROOT / "docs" / "canon" / "UI_CANON.md"

COPY_SURFACES = [
    ROOT / "scenes" / "UI.tscn",
    ROOT / "scenes" / "Main.tscn",
    ROOT / "scripts" / "ui" / "ui_root.gd",
    ROOT / "scripts" / "ui" / "main_menu.gd",
    ROOT / "scripts" / "content" / "bet_catalog.gd",
    ROOT / "scripts" / "content" / "scar_catalog.gd",
    ROOT / "scripts" / "systems" / "run" / "phase_handlers" / "phase_push_your_luck_handler.gd",
    ROOT / "scripts" / "systems" / "run" / "run_arena_theme_policy.gd",
    ROOT / "scripts" / "systems" / "run" / "run_register_annotation_policy.gd",
    ROOT / "scripts" / "systems" / "run" / "run_ui_payload_factory.gd",
    ROOT / "scripts" / "systems" / "run_manager.gd",
]

STALE_COPY_TOKENS = [
    "PUSH YOUR LUCK",
    "NUOVA RUN",
    "RUN FAILED",
    "BET FAILED",
    "Stato run",
    "Chiudi la run",
    "run registrata",
    "run terminata",
    "La pressione e rimasta",
    "Il registro e aperto",
    "Il Registro e aperto",
    "La firma e irrevocabile",
    "Come e stata ottenuta",
    "Incassa ora o raddoppia il rischio",
    "L'escalation",
    "l'escalation",
    "Le escalation",
    "Riduci escalation",
    "Aumenta escalation",
    'text = "ESCALATION"',
]

REQUIRED_COPY_TOKENS = {
    I18N_DIR / "it.csv": [
        "SPINGI LA SORTE",
        "NUOVO PERCORSO",
        "Stato del percorso",
        "La pressione è rimasta sotto controllo.",
    ],
    ROOT / "scripts" / "ui" / "ui_root.gd": [
        'tr("SPINGI LA SORTE")',
        "Chiudi il percorso e registra il risultato finale.",
        "PERCORSO FALLITO",
        "PATTO FALLITO",
    ],
    ROOT / "scripts" / "systems" / "run" / "run_ui_payload_factory.gd": [
        '"title": "SPINGI LA SORTE"',
    ],
}


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _assert_no_stale_tokens(source: str, text: str) -> None:
    offenders = [token for token in STALE_COPY_TOKENS if token in text]
    if offenders:
        raise AssertionError(f"{source} contains stale player-facing copy: {offenders}")


def _csv_key_and_italian_value_text(path: Path) -> str:
    with path.open("r", encoding="utf-8", newline="") as handle:
        rows = list(csv.reader(handle))
    pieces: list[str] = []
    is_italian = path.name == "it.csv"
    for row in rows[1:]:
        if len(row) != 2:
            continue
        pieces.append(row[0])
        if is_italian:
            pieces.append(row[1])
    return "\n".join(pieces)


def test_i18n_player_facing_copy_uses_clear_ritual_terms() -> None:
    for path in sorted(I18N_DIR.glob("*.csv")):
        _assert_no_stale_tokens(str(path.relative_to(ROOT)), _csv_key_and_italian_value_text(path))


def test_copy_surfaces_use_clear_ritual_terms() -> None:
    for path in COPY_SURFACES:
        _assert_no_stale_tokens(str(path.relative_to(ROOT)), _read(path))


def test_required_textual_contract_tokens_are_present() -> None:
    for path, tokens in REQUIRED_COPY_TOKENS.items():
        text = _read(path)
        missing = [token for token in tokens if token not in text]
        if missing:
            raise AssertionError(f"{path.relative_to(ROOT)} missing textual contract tokens: {missing}")


def test_active_docs_reference_glossary_contract() -> None:
    glossary = _read(GLOSSARY)
    ui_canon = _read(UI_CANON)
    required_glossary = [
        "Player-Facing Language Contract",
        "`run`",
        "`escalation`",
        "`cashout`",
        "`double`",
        "`condanna`",
    ]
    missing_glossary = [token for token in required_glossary if token not in glossary]
    if missing_glossary:
        raise AssertionError(f"GLOSSARY_ENTITIES.md missing language contract tokens: {missing_glossary}")
    if "GLOSSARY_ENTITIES.md" not in ui_canon:
        raise AssertionError("UI_CANON.md must reference the glossary language contract")


if __name__ == "__main__":
    test_i18n_player_facing_copy_uses_clear_ritual_terms()
    test_copy_surfaces_use_clear_ritual_terms()
    test_required_textual_contract_tokens_are_present()
    test_active_docs_reference_glossary_contract()
    print("[OK][TEXTUAL_STYLE_CONTRACT] player-facing terminology is aligned")
