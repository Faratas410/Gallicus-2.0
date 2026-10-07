#!/usr/bin/env python3
"""Static guard for the background economy: Vessa's ledger and banco."""

from __future__ import annotations

import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
SAVE_MANAGER = ROOT / "scripts/systems/save_manager.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
BETTING_CIRCLE = ROOT / "scripts/ui/betting_circle_ui.gd"
BETTING_SCENE = ROOT / "scenes/ui/BettingCircle.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _function_body(source: str, name: str) -> str:
    match = re.search(rf"(?ms)^func {re.escape(name)}\(.*?(?=^func |\Z)", source)
    if match is None:
        raise AssertionError(f"missing function: {name}")
    return match.group(0)


def _csv_keys(locale: str) -> set[str]:
    with (ROOT / f"assets/i18n/{locale}.csv").open("r", encoding="utf-8", newline="") as handle:
        return {row[0] for row in csv.reader(handle) if row}


def main() -> int:
    run_manager = _read(RUN_MANAGER)
    for token in (
        "const LEDGER_PERSISTS: bool = true",
        "func _ledger_change(delta: int, note: String) -> void:",
        "func _open_ledger_for_run() -> void:",
        "func _settle_ledger_at_run_end(reason: String) -> void:",
        "func get_banco_view() -> Dictionary:",
        "func _on_request_banco_purchase(item_id: String) -> void:",
        '[&"request_banco_purchase", &"_on_request_banco_purchase", true]',
        "_settle_ledger_at_run_end(reason)",
    ):
        if token not in run_manager:
            raise AssertionError(f"ledger authority missing: {token}")
    purchase = _function_body(run_manager, "get_banco_view")
    if "RunPhase.BET_PRESENT" not in purchase or "balance >= 0" not in purchase:
        raise AssertionError("banco must open only before signing and never in debt")
    save_manager = _read(SAVE_MANAGER)
    for token in ("func get_ledger_denari() -> int:", "func set_ledger_denari(value: int) -> void:", '"ledger_denari": 0'):
        if token not in save_manager:
            raise AssertionError(f"ledger persistence missing: {token}")
    events = _read(GAME_EVENTS)
    for token in ("signal ledger_changed(payload: Dictionary)", "signal request_banco_purchase(item_id: String)"):
        if token not in events:
            raise AssertionError(f"GameEvents missing: {token}")
    circle = _read(BETTING_CIRCLE)
    pressed = _function_body(circle, "_on_banco_pressed")
    if "request_banco_purchase.emit(item_id)" not in pressed or "SaveManager" in pressed:
        raise AssertionError("banco UI must only emit the purchase intent")
    scene = _read(BETTING_SCENE)
    for node in ("BancoPanel", "Btn_Banco_favor", "Btn_Banco_pressure", "Btn_Banco_insure", "BancoNote"):
        if f'[node name="{node}"' not in scene:
            raise AssertionError(f"banco scene node missing: {node}")
    if 'tr("Conto %d Denari") % _ledger_denari' not in _read(UI_ROOT):
        raise AssertionError("rail must show the ledger")
    for locale in ("it", "en", "es"):
        keys = _csv_keys(locale)
        for key in ("BANCO DI VESSA", "Conto %d Denari", "COMPRA IL FAVORE", "PAGA LA PRESSIONE", "ASSICURA LA POSTA", "Debito con Vessa"):
            if key not in keys:
                raise AssertionError(f"{locale} missing ledger copy: {key!r}")
    print("[OK][LEDGER_ECONOMY_CONTRACT] Vessa ledger and banco contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
