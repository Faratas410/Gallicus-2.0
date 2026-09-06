#!/usr/bin/env python3
"""Static and asset guard for OF-04, the object-first arena threshold."""

from __future__ import annotations

import csv
import math
import re
import struct
import wave
from pathlib import Path
from generated_art_contract import validate_family


ROOT = Path(__file__).resolve().parents[2]
TEXTURE = ROOT / "assets/ui/official/objects/arena_threshold/arena_threshold_base.png"
STYLE_DIR = TEXTURE.parent
SCENE = ROOT / "scenes/Main.tscn"
MAIN_MENU = ROOT / "scripts/ui/main_menu.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
SFX_PATH = ROOT / "assets/audio/sfx/arena_threshold_cross.wav"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

STYLE_NAMES = (
    "normal",
    "focus",
    "pressed",
    "crossed",
    "disabled",
)
TEXTURE_RES_PATH = (
    "res://assets/ui/official/objects/arena_threshold/arena_threshold_base.png"
)
EXPECTED_COPY = {
    "it": "ENTRA NELL'ARENA",
    "en": "ENTER THE ARENA",
    "es": "ENTRA EN LA ARENA",
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-04 file: {path.relative_to(ROOT)}")
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


def _assert_texture() -> None:
    validate_family("arena_threshold")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    block = _node_block(scene, "NewGameButton")
    for token in (
        "focus_mode = 2",
        'theme_override_styles/normal = ExtResource("27_arena_threshold_normal")',
        'theme_override_styles/hover = ExtResource("28_arena_threshold_focus")',
        'theme_override_styles/focus = ExtResource("28_arena_threshold_focus")',
        'theme_override_styles/pressed = ExtResource("29_arena_threshold_pressed")',
        'theme_override_styles/disabled = ExtResource("31_arena_threshold_disabled")',
        "custom_minimum_size = Vector2(480, 72)",
        'text = "ENTRA NELL\'ARENA"',
    ):
        if token not in block:
            raise AssertionError(f"arena threshold node missing token: {token}")


def _assert_runtime_contract() -> None:
    main_menu = _read(MAIN_MENU)
    pressed = _function_body(main_menu, "_on_new_game_pressed")
    ordered = (
        '_play_sfx(&"arena_threshold_cross")',
        "_set_arena_threshold_crossed_state(true)",
        "GameEvents.request_new_run.emit()",
        "_hide_menu()",
    )
    positions = [pressed.find(token) for token in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        raise AssertionError(
            "new-run handler must cue, cross threshold, emit request_new_run, then hide menu"
        )
    if "await " in pressed:
        raise AssertionError("arena threshold intent must not await presentation")
    executable = "\n".join(line.split("#", 1)[0] for line in pressed.splitlines())
    for forbidden in (
        "RunManager.",
        'get_node_or_null("/root/RunManager")',
        "_start_new_run(",
        "request_new_game(",
    ):
        if forbidden in executable:
            raise AssertionError(f"main menu must not call RunManager directly: {forbidden}")

    reset = _function_body(main_menu, "_show_menu")
    if "_set_arena_threshold_crossed_state(false)" not in reset:
        raise AssertionError("arena threshold state must reset whenever the menu is shown")
    helper = _function_body(main_menu, "_set_arena_threshold_crossed_state")
    for token in (
        "set_meta(ARENA_THRESHOLD_CROSSED_META, crossed)",
        "new_game_button.disabled = crossed",
        "ARENA_THRESHOLD_STYLE_CROSSED",
        "ARENA_THRESHOLD_STYLE_DISABLED",
    ):
        if token not in helper:
            raise AssertionError(f"arena threshold helper missing token: {token}")

    if "signal request_new_run" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents request_new_run contract changed")
    if "func _on_request_new_run() -> void:" not in _read(RUN_MANAGER):
        raise AssertionError("RunManager new-run authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for token in (
        '&"arena_threshold_cross": -11.0',
        '&"arena_threshold_cross": "res://assets/audio/sfx/arena_threshold_cross.wav"',
    ):
        if token not in sfx_bus:
            raise AssertionError(f"SfxBus missing arena-threshold cue token: {token}")
    if not SFX_PATH.exists():
        raise AssertionError("missing arena_threshold_cross.wav")
    with wave.open(str(SFX_PATH), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
            raise AssertionError("arena threshold WAV must be mono PCM16 at 44.1 kHz")
        frame_count = handle.getnframes()
        frames = handle.readframes(frame_count)
    duration = frame_count / 44100.0
    if not 0.55 <= duration <= 0.85:
        raise AssertionError(f"arena threshold WAV duration out of range: {duration:.3f}s")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    peak = max(abs(sample) for sample in samples) / 32767.0
    peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
    if peak_dbfs > -2.9:
        raise AssertionError(f"arena threshold WAV peak exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa_matrix() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        "func _capture_arena_threshold_matrix() -> void:",
        'THRESHOLD_LOCALES: Array[String] = ["it", "en", "es"]',
        "THRESHOLD_VIEWPORT_SIZES",
        "THRESHOLD_BUTTON_PATH",
        "_set_arena_threshold_crossed_state",
        '"%s_normal"',
        '"%s_focus"',
        '"%s_disabled"',
        '"%s_crossed"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA arena threshold matrix missing token: {token}")


def main() -> int:
    _assert_texture()
    _assert_scene_binding()
    _assert_runtime_contract()
    _assert_audio()
    _assert_visual_qa_matrix()
    key = "ENTRA NELL'ARENA"
    for locale, expected in EXPECTED_COPY.items():
        actual = _csv_value(locale, key)
        if actual != expected:
            raise AssertionError(f"{locale} arena-threshold copy mismatch: {actual!r} != {expected!r}")
    print("[OK][ARENA_THRESHOLD_OBJECT_CONTRACT] OF-04 arena threshold contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
