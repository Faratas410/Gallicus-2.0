#!/usr/bin/env python3
"""Static and asset guard for OF-03, the object-first second incision."""

from __future__ import annotations

import csv
import math
import re
import struct
import wave
from pathlib import Path
from generated_art_contract import validate_family


ROOT = Path(__file__).resolve().parents[2]
TEXTURE = ROOT / "assets/ui/official/objects/second_incision/registry_second_incision_sealed.png"
STYLE_DIR = TEXTURE.parent
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
SFX_PATH = ROOT / "assets/audio/sfx/registry_second_incision.wav"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

STYLE_NAMES = (
    "normal",
    "focus",
    "pressed",
    "sealed",
    "disabled",
)
TEXTURE_RES_PATH = (
    "res://assets/ui/official/objects/second_incision/registry_second_incision_sealed.png"
)
EXPECTED_COPY = {
    "it": "RADDOPPIA",
    "en": "DOUBLE",
    "es": "DOBLA",
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-03 file: {path.relative_to(ROOT)}")
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


def _assert_shared_style_geometry() -> None:
    validate_family("second_incision")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    block = _node_block(scene, "Btn_PUSH_YOUR_LUCK_DOUBLE")
    for token in (
        "focus_mode = 2",
        'theme_override_styles/normal = ExtResource("44_registry_second_incision_normal")',
        'theme_override_styles/hover = ExtResource("45_registry_second_incision_focus")',
        'theme_override_styles/focus = ExtResource("45_registry_second_incision_focus")',
        'theme_override_styles/pressed = ExtResource("46_registry_second_incision_pressed")',
        'theme_override_styles/disabled = ExtResource("48_registry_second_incision_disabled")',
        'custom_minimum_size = Vector2(0, 104)',
        'text = "RADDOPPIA"',
    ):
        if token not in block:
            raise AssertionError(f"second incision node missing token: {token}")


def _assert_runtime_contract() -> None:
    ui_root = _read(UI_ROOT)
    pressed = _function_body(ui_root, "_on_push_luck_double_pressed")
    ordered = (
        '_play_sfx(&"registry_second_incision")',
        "_pyl_locked = true",
        "_set_second_incision_sealed_state(true)",
        "_apply_decision_lock(",
        '_emit_game_event_signal_if_available(&"request_pyl_double")',
    )
    positions = [pressed.find(token) for token in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        raise AssertionError(
            "double must cue, lock, seal second incision, decision-lock, then emit request_pyl_double"
        )
    if 'level_up' in pressed:
        raise AssertionError("second incision handler must not retain the generic level_up cue")
    if "await " in pressed:
        raise AssertionError("second incision intent must not await presentation")

    reset = _function_body(ui_root, "_reset_pyl_lock_state")
    if "_set_second_incision_sealed_state(false)" not in reset:
        raise AssertionError("second incision state must reset on recovery and new payload")
    helper = _function_body(ui_root, "_set_second_incision_sealed_state")
    for token in (
        "set_meta(SECOND_INCISION_SEALED_META, sealed)",
        '"disabled"',
        "SECOND_INCISION_STYLE_SEALED",
        "SECOND_INCISION_STYLE_DISABLED",
    ):
        if token not in helper:
            raise AssertionError(f"second incision helper missing token: {token}")

    if "signal request_pyl_double" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents request_pyl_double contract changed")
    if "func _on_request_pyl_double() -> void:" not in _read(RUN_MANAGER):
        raise AssertionError("RunManager double authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for token in (
        '&"registry_second_incision": -11.0',
        '&"registry_second_incision": "res://assets/audio/sfx/registry_second_incision.wav"',
    ):
        if token not in sfx_bus:
            raise AssertionError(f"SfxBus missing second incision cue token: {token}")
    if not SFX_PATH.exists():
        raise AssertionError("missing registry_second_incision.wav")
    with wave.open(str(SFX_PATH), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
            raise AssertionError("second incision WAV must be mono PCM16 at 44.1 kHz")
        frame_count = handle.getnframes()
        frames = handle.readframes(frame_count)
    duration = frame_count / 44100.0
    if not 0.45 <= duration <= 0.75:
        raise AssertionError(f"second incision WAV duration out of range: {duration:.3f}s")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    peak = max(abs(sample) for sample in samples) / 32767.0
    peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
    if peak_dbfs > -2.9:
        raise AssertionError(f"second incision WAV peak exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa_matrix() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        "func _capture_second_incision_matrix() -> void:",
        'INCISION_LOCALES: Array[String] = ["it", "en", "es"]',
        "INCISION_VIEWPORT_SIZES",
        "INCISION_BUTTON_PATH",
        "_set_second_incision_sealed_state",
        '"%s_normal"',
        '"%s_focus"',
        '"%s_disabled"',
        '"%s_sealed"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA second incision matrix missing token: {token}")


def main() -> int:
    _assert_shared_style_geometry()
    _assert_scene_binding()
    _assert_runtime_contract()
    _assert_audio()
    _assert_visual_qa_matrix()
    key = "RADDOPPIA"
    for locale, expected in EXPECTED_COPY.items():
        actual = _csv_value(locale, key)
        if actual != expected:
            raise AssertionError(f"{locale} second incision copy mismatch: {actual!r} != {expected!r}")
    print("[OK][SECOND_INCISION_OBJECT_CONTRACT] OF-03 second incision contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
