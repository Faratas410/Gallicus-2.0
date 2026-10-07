#!/usr/bin/env python3
"""Static guard for Orvo's bando, the ladder of steps and the seal chain."""

from __future__ import annotations

import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
RUN_STATE = ROOT / "scripts/systems/run/run_state.gd"
SAVE_MANAGER = ROOT / "scripts/systems/save_manager.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
CONTRACT = ROOT / "docs/contracts/gameevents_signal_contract_v1.md"
DIALOGUES = ROOT / "scripts/content/campaign_dialogues.gd"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
UI_SCENE = ROOT / "scenes/UI.tscn"
BETTING_CIRCLE = ROOT / "scripts/ui/betting_circle_ui.gd"


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
        "const BANDO_LADDER: Array[int] = [10, 12, 14, 17, 20, 23, 26, 29, 32, 35, 38, 42]",
        "const BANDO_DENARI: int = 5",
        "const SEAL_CHAIN_MULTIPLIERS: Array[float] = [1.0, 1.0, 1.5, 2.0, 3.0]",
        "func get_bando_view() -> Dictionary:",
        "func get_seal_chain_multiplier() -> float:",
    ):
        if token not in run_manager:
            raise AssertionError(f"run_manager.gd missing bando token: {token}")

    settle = _function_body(run_manager, "_settle_bando_at_run_end")
    for token in ('reason == "CASH_OUT"', "bando_deadline", "bando_quota", "set_bando_step", "set_bando_acclaim(true)", "_ledger_change(BANDO_DENARI"):
        if token not in settle:
            raise AssertionError(f"_settle_bando_at_run_end missing: {token}")
    ledger = _function_body(run_manager, "_settle_ledger_at_run_end")
    if "_settle_bando_at_run_end(reason)" not in ledger or "Quietanza versata: Denari +%d." not in ledger:
        raise AssertionError("the bando settles before the full quietanza deposit")
    if "metà quietanza" in ledger:
        raise AssertionError("an unmet bando must not cut the quietanza: the debt spiral returns")
    if "_open_bando_for_run()" not in run_manager or "_refresh_bando_deadline()" not in _function_body(run_manager, "start_arena"):
        raise AssertionError("each percorso opens a bando and each arena checks its deadline")
    stake = _function_body(run_manager, "_add_held_seal_to_stake")
    if "get_seal_chain_multiplier()" not in stake or "_run_state.seal_chain += 1" not in stake:
        raise AssertionError("held seals must be multiplied by the chain and join it")
    strike = _function_body(run_manager, "_strike_seal")
    if "if not held:\n\t\t_run_state.seal_chain = 0" not in strike:
        raise AssertionError("a broken strike resets the chain")
    if "_run_state.seal_chain += 1" in strike:
        raise AssertionError("extra strikes of one arena are a single link of the chain")
    unlock = _function_body(run_manager, "_is_level3_bet_unlocked")
    if "BANDO_PACT_STEPS" not in unlock:
        raise AssertionError("ladder steps must open the sealed pacts")
    dialogue = _function_body(run_manager, "get_campaign_dialogue")
    if "bando_step >= int(tale.step)" not in dialogue:
        raise AssertionError("racconti are the prize of the ladder")

    run_state = _read(RUN_STATE)
    for key in ("bando_quota", "bando_deadline", "bando_status", "seal_chain"):
        if f'"{key}": {key}' not in run_state:
            raise AssertionError(f"RunState must save {key}")
    save = _read(SAVE_MANAGER)
    for token in ("func get_bando_step() -> int:", "func set_bando_step(value: int) -> void:", '"bando_step": 0', '"bando_acclaim": false'):
        if token not in save:
            raise AssertionError(f"save_manager.gd missing: {token}")
    if "signal bando_changed(payload: Dictionary)" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents must declare bando_changed")
    if "| `bando_changed` | 1 | RunManager -> UI |" not in _read(CONTRACT):
        raise AssertionError("signal contract must list bando_changed")

    dialogues = _read(DIALOGUES)
    steps = [int(value) for value in re.findall(r'\{"id": "[a-z_]+", "step": (\d+)\}', dialogues)]
    if steps != sorted(steps) or len(steps) < 8 or steps[0] != 1:
        raise AssertionError(f"TALES must climb the ladder from step 1: {steps}")

    ui_scene = _read(UI_SCENE)
    for node in ("BandoPanel", "BandoBar", "BandoBody", "BandoNote"):
        if f'[node name="{node}"' not in ui_scene:
            raise AssertionError(f"UI.tscn missing {node}")
    ui_root = _read(UI_ROOT)
    for token in ('{"signal": &"bando_changed", "handler": &"_on_bando_changed"}', "func _dossier_bando_line() -> String:", "Catena %d: posta %s."):
        if token not in ui_root:
            raise AssertionError(f"ui_root.gd missing: {token}")
    if "func _render_bando_intro() -> void:" not in _read(BETTING_CIRCLE):
        raise AssertionError("the closed Registry must announce the bando")

    keys = {locale: _csv_keys(locale) for locale in ("it", "en", "es")}
    sources = run_manager + ui_root + _read(BETTING_CIRCLE)
    for key in (
        "BANDO DI ORVO", "IL BANDO DI ORVO", "%d di %d Gloria entro l'arena %d.",
        "Bando chiuso: Denari +%d e un gradino.", "Incassa %d Gloria entro l'arena %d.",
        "Prossimo bando: %d Gloria entro l'arena %d.", "In palio il racconto «%s».",
        "Catena %d: posta %s.", "Catena %s", "Bando scaduto: nessun gradino.", "Bando mancato: nessun gradino.",
    ):
        if key not in sources and key != "BANDO DI ORVO":
            raise AssertionError(f"copy not used in source: {key}")
        for locale, catalog in keys.items():
            if key not in catalog:
                raise AssertionError(f"{locale}.csv missing: {key}")
    print("[OK][BANDO_LADDER_CONTRACT] bando, ladder and chain contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
