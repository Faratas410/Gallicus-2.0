#!/usr/bin/env python3
"""Static and asset guard for OF-05, the object-first Registry table."""

from __future__ import annotations

import csv
import math
import re
import struct
import wave
from pathlib import Path
from generated_art_contract import validate_family


ROOT = Path(__file__).resolve().parents[2]
STYLE_DIR = ROOT / "assets/ui/official/objects/registry_table"
CLOSED_TEXTURE = STYLE_DIR / "registry_table_closed.png"
OPEN_TEXTURE = STYLE_DIR / "registry_table_open.png"
SCENE = ROOT / "scenes/ui/BettingCircle.tscn"
BETTING_UI = ROOT / "scripts/ui/betting_circle_ui.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
SFX_PATH = ROOT / "assets/audio/sfx/registry_table_open.wav"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

CLOSED_STYLES = ("normal", "focus", "pressed", "disabled")
EXPECTED_COPY = {
    "it": {
        "APRI IL REGISTRO": "APRI IL REGISTRO",
        "REGISTRO DELL'ARENA": "REGISTRO DELL'ARENA",
        "Apertura del verbale": "Apertura del verbale",
        "IL REGISTRO E' CHIUSO": "IL REGISTRO E' CHIUSO",
    },
    "en": {
        "APRI IL REGISTRO": "OPEN THE REGISTRY",
        "REGISTRO DELL'ARENA": "ARENA REGISTRY",
        "Apertura del verbale": "OPENING THE RECORD",
        "IL REGISTRO E' CHIUSO": "THE REGISTRY IS CLOSED",
    },
    "es": {
        "APRI IL REGISTRO": "ABRE EL REGISTRO",
        "REGISTRO DELL'ARENA": "REGISTRO DE LA ARENA",
        "Apertura del verbale": "APERTURA DEL ACTA",
        "IL REGISTRO E' CHIUSO": "EL REGISTRO ESTÁ CERRADO",
    },
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-05 file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def _function_body(source: str, name: str) -> str:
    match = re.search(rf"(?ms)^func {re.escape(name)}\(.*?(?=^func |\Z)", source)
    if match is None:
        raise AssertionError(f"missing function: {name}")
    return match.group(0)


def _node_block(scene: str, node_name: str) -> str:
    match = re.search(
        rf'(?ms)^\[node name="{re.escape(node_name)}".*?(?=^\[node |\Z)',
        scene,
    )
    if match is None:
        raise AssertionError(f"missing scene node: {node_name}")
    return match.group(0)


def _csv_value(locale: str, key: str) -> str:
    path = ROOT / f"assets/i18n/{locale}.csv"
    with path.open("r", encoding="utf-8", newline="") as handle:
        rows = list(csv.reader(handle))
    matches = [row[1] for row in rows[1:] if len(row) == 2 and row[0] == key]
    if len(matches) != 1:
        raise AssertionError(f"{locale} must contain exactly one {key!r} entry")
    return matches[0]


def _assert_textures() -> None:
    validate_family("registry_table")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    for token in (
        "sb_registry_table_open.tres",
        "sb_registry_table_closed_normal.tres",
    ):
        if token not in scene:
            raise AssertionError(f"BettingCircle missing Registry resource: {token}")
    if 'theme_override_styles/panel = ExtResource("12_registry_table_open")' not in _node_block(scene, "SpellbookBg"):
        raise AssertionError("SpellbookBg must bind the open Registry table")
    if 'theme_override_styles/panel = ExtResource("13_registry_table_closed")' not in _node_block(scene, "ClosedBookBg"):
        raise AssertionError("ClosedBookBg must bind the closed Registry table")
    open_button = _node_block(scene, "Btn_Open_Book")
    if "focus_mode = 2" not in open_button:
        raise AssertionError("Registry open control must accept keyboard focus")
    if 'text = "APRI IL REGISTRO"' not in _node_block(scene, "Lbl_Open_Book"):
        raise AssertionError("Registry CTA must remain APRI IL REGISTRO")
    for page_name in ("LeftPaper", "RightPaper"):
        if 'theme_override_styles/panel = SubResource("StyleBoxEmpty_1")' not in _node_block(scene, page_name):
            raise AssertionError(f"{page_name} must expose the generated stone writing surface")


def _assert_runtime_contract() -> None:
    source = _read(BETTING_UI)
    pressed = _function_body(source, "_on_open_book_pressed")
    ordered = (
        '_play_sfx(&"registry_table_open")',
        "_awaiting_open_request = false",
        "_play_open_animation()",
    )
    positions = [pressed.find(token) for token in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        raise AssertionError("Registry handler must cue, lock, then start presentational opening")
    if "await " in pressed:
        raise AssertionError("Registry opening must not await before continuing presentation")
    executable = "\n".join(line.split("#", 1)[0] for line in pressed.splitlines())
    for forbidden in ("GameEvents.", "RunManager.", 'get_node_or_null("/root/RunManager")'):
        if forbidden in executable:
            raise AssertionError(f"Registry opening must remain UI-only: {forbidden}")

    closed = _function_body(source, "_show_closed_intro")
    if "_set_registry_table_closed_state(REGISTRY_TABLE_STATE_NORMAL)" not in closed:
        raise AssertionError("closed Registry must reset to normal whenever shown")
    hidden = _function_body(source, "_hide_closed_intro")
    if "_set_registry_table_closed_state(REGISTRY_TABLE_STATE_DISABLED)" not in hidden:
        raise AssertionError("hidden Registry control must enter disabled state")
    helper = _function_body(source, "_set_registry_table_closed_state")
    for token in (
        "REGISTRY_TABLE_STYLE_NORMAL",
        "REGISTRY_TABLE_STYLE_FOCUS",
        "REGISTRY_TABLE_STYLE_PRESSED",
        "REGISTRY_TABLE_STYLE_DISABLED",
        'add_theme_stylebox_override("panel", style)',
        "set_meta(REGISTRY_TABLE_STATE_META, state)",
    ):
        if token not in helper:
            raise AssertionError(f"Registry state helper missing token: {token}")

    game_events = _read(GAME_EVENTS)
    run_manager = _read(RUN_MANAGER)
    if "signal request_place_bet(bet_id: String, stake: int)" not in game_events:
        raise AssertionError("GameEvents request_place_bet contract changed")
    if "func _on_request_place_bet(bet_id: String, _stake: int) -> void:" not in run_manager:
        raise AssertionError("RunManager bet authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for token in (
        '&"registry_table_open": -11.0',
        '&"registry_table_open": "res://assets/audio/sfx/registry_table_open.wav"',
    ):
        if token not in sfx_bus:
            raise AssertionError(f"SfxBus missing Registry-table cue token: {token}")
    if not SFX_PATH.exists():
        raise AssertionError("missing registry_table_open.wav")
    with wave.open(str(SFX_PATH), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
            raise AssertionError("Registry table WAV must be mono PCM16 at 44.1 kHz")
        frame_count = handle.getnframes()
        frames = handle.readframes(frame_count)
    duration = frame_count / 44100.0
    if not 0.65 <= duration <= 0.95:
        raise AssertionError(f"Registry table WAV duration out of range: {duration:.3f}s")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    peak = max(abs(sample) for sample in samples) / 32767.0
    peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
    if peak_dbfs > -2.9:
        raise AssertionError(f"Registry table WAV peak exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa_matrix() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        "func _capture_registry_table_matrix() -> void:",
        'REGISTRY_TABLE_LOCALES: Array[String] = ["it", "en", "es"]',
        "REGISTRY_TABLE_VIEWPORT_SIZES",
        "REGISTRY_TABLE_BUTTON_PATH",
        '"%s_closed_normal"',
        '"%s_closed_focus"',
        '"%s_closed_disabled"',
        '"%s_open"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA Registry matrix missing token: {token}")


def main() -> int:
    _assert_textures()
    _assert_scene_binding()
    _assert_runtime_contract()
    _assert_audio()
    _assert_visual_qa_matrix()
    for locale, expected_by_key in EXPECTED_COPY.items():
        for key, expected in expected_by_key.items():
            actual = _csv_value(locale, key)
            if actual != expected:
                raise AssertionError(f"{locale} Registry copy mismatch: {key!r} -> {actual!r}")
    print("[OK][REGISTRY_TABLE_OBJECT_CONTRACT] OF-05 Registry table contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
