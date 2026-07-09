#!/usr/bin/env python3
"""Static and asset guard for OF-02, the object-first condemnation mark."""

from __future__ import annotations

import csv
import math
import re
import struct
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TEXTURE = ROOT / "assets/ui/official/objects/condemnation_mark/registry_condemnation_mark_base.png"
STYLE_DIR = TEXTURE.parent
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
SFX_PATH = ROOT / "assets/audio/sfx/registry_condemnation_mark.wav"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

STYLE_NAMES = (
    "normal",
    "focus",
    "pressed",
    "registered",
    "disabled",
)
TEXTURE_RES_PATH = "res://assets/ui/official/objects/condemnation_mark/registry_condemnation_mark_base.png"
EXPECTED_COPY = {
    "it": "RICEVI IL MARCHIO",
    "en": "RECEIVE THE MARK",
    "es": "RECIBE LA MARCA",
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-02 file: {path.relative_to(ROOT)}")
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


def _png_header(path: Path) -> tuple[int, int, int]:
    raw = path.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n" or raw[12:16] != b"IHDR":
        raise AssertionError("condemnation mark texture must be a PNG with an IHDR header")
    width, height, bit_depth, color_type = struct.unpack(">IIBB", raw[16:26])
    if bit_depth != 8:
        raise AssertionError(f"condemnation mark PNG must use 8-bit channels, got {bit_depth}")
    return width, height, color_type


def _csv_value(locale: str, key: str) -> str:
    path = ROOT / f"assets/i18n/{locale}.csv"
    with path.open("r", encoding="utf-8", newline="") as handle:
        rows = list(csv.reader(handle))
    matches = [row[1] for row in rows[1:] if len(row) == 2 and row[0] == key]
    if len(matches) != 1:
        raise AssertionError(f"{locale} must contain exactly one {key!r} entry")
    return matches[0]


def _assert_shared_style_geometry() -> None:
    geometry: tuple[str, ...] | None = None
    for state in STYLE_NAMES:
        path = STYLE_DIR / f"sb_registry_condemnation_mark_{state}.tres"
        text = _read(path)
        if TEXTURE_RES_PATH not in text:
            raise AssertionError(f"{path.name} must share registry_condemnation_mark_base.png")
        values = tuple(
            re.findall(
                r"^(?:texture_margin|content_margin)_(?:left|top|right|bottom) = (.+)$",
                text,
                re.MULTILINE,
            )
        )
        if len(values) != 8:
            raise AssertionError(f"{path.name} must define all stable texture/content margins")
        if geometry is None:
            geometry = values
        elif values != geometry:
            raise AssertionError(f"{path.name} changes condemnation mark geometry between states")


def _assert_texture() -> None:
    if not TEXTURE.exists():
        raise AssertionError("missing registry_condemnation_mark_base.png")
    width, height, color_type = _png_header(TEXTURE)
    if color_type != 6:
        raise AssertionError(f"condemnation mark PNG must be RGBA, got PNG color type {color_type}")
    if height <= 0 or not math.isclose(width / height, 2.5, rel_tol=0.002):
        raise AssertionError(f"condemnation mark PNG must be 5:2, got {width}x{height}")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    block = _node_block(scene, "Btn_PUSH_YOUR_LUCK_CONDANNA")
    for token in (
        "focus_mode = 2",
        'theme_override_styles/normal = ExtResource("39_registry_condemnation_mark_normal")',
        'theme_override_styles/hover = ExtResource("40_registry_condemnation_mark_focus")',
        'theme_override_styles/focus = ExtResource("40_registry_condemnation_mark_focus")',
        'theme_override_styles/pressed = ExtResource("41_registry_condemnation_mark_pressed")',
        'theme_override_styles/disabled = ExtResource("43_registry_condemnation_mark_disabled")',
        'custom_minimum_size = Vector2(0, 64)',
        'text = "RICEVI IL MARCHIO"',
    ):
        if token not in block:
            raise AssertionError(f"condemnation mark node missing token: {token}")


def _assert_runtime_contract() -> None:
    ui_root = _read(UI_ROOT)
    pressed = _function_body(ui_root, "_on_push_luck_condanna_pressed")
    ordered = (
        '_play_sfx(&"registry_condemnation_mark")',
        "_pyl_locked = true",
        "_set_condemnation_mark_registered_state(true)",
        "_apply_decision_lock(",
        '_emit_game_event_signal_if_available(&"request_pyl_condanna")',
    )
    positions = [pressed.find(token) for token in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        raise AssertionError("condanna must cue, lock, register mark, decision-lock, then emit request_pyl_condanna")
    if "player_damage" in pressed:
        raise AssertionError("condanna PYL handler must not retain the combat player_damage cue")
    if "await " in pressed:
        raise AssertionError("condanna intent must not await presentation")

    reset = _function_body(ui_root, "_reset_pyl_lock_state")
    if "_set_condemnation_mark_registered_state(false)" not in reset:
        raise AssertionError("condemnation mark state must reset on recovery and new payload")
    helper = _function_body(ui_root, "_set_condemnation_mark_registered_state")
    for token in (
        "set_meta(CONDEMNATION_MARK_REGISTERED_META, registered)",
        '"disabled"',
        "CONDEMNATION_MARK_STYLE_REGISTERED",
        "CONDEMNATION_MARK_STYLE_DISABLED",
    ):
        if token not in helper:
            raise AssertionError(f"condemnation mark helper missing token: {token}")

    if "signal request_pyl_condanna" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents request_pyl_condanna contract changed")
    if "func _on_request_pyl_condanna() -> void:" not in _read(RUN_MANAGER):
        raise AssertionError("RunManager condanna authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for token in (
        '&"registry_condemnation_mark": -10.5',
        '&"registry_condemnation_mark": "res://assets/audio/sfx/registry_condemnation_mark.wav"',
    ):
        if token not in sfx_bus:
            raise AssertionError(f"SfxBus missing condemnation mark cue token: {token}")
    if not SFX_PATH.exists():
        raise AssertionError("missing registry_condemnation_mark.wav")
    with wave.open(str(SFX_PATH), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
            raise AssertionError("condemnation mark WAV must be mono PCM16 at 44.1 kHz")
        frame_count = handle.getnframes()
        frames = handle.readframes(frame_count)
    duration = frame_count / 44100.0
    if not 0.4 <= duration <= 0.8:
        raise AssertionError(f"condemnation mark WAV duration out of range: {duration:.3f}s")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    peak = max(abs(sample) for sample in samples) / 32767.0
    peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
    if peak_dbfs > -2.9:
        raise AssertionError(f"condemnation mark WAV peak exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa_matrix() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        "func _capture_condemnation_mark_matrix() -> void:",
        'MARK_LOCALES: Array[String] = ["it", "en", "es"]',
        "MARK_VIEWPORT_SIZES",
        "MARK_BUTTON_PATH",
        "_set_condemnation_mark_registered_state",
        '"%s_normal"',
        '"%s_focus"',
        '"%s_registered"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA condemnation mark matrix missing token: {token}")


def main() -> int:
    _assert_texture()
    _assert_shared_style_geometry()
    _assert_scene_binding()
    _assert_runtime_contract()
    _assert_audio()
    _assert_visual_qa_matrix()
    key = "RICEVI IL MARCHIO"
    for locale, expected in EXPECTED_COPY.items():
        actual = _csv_value(locale, key)
        if actual != expected:
            raise AssertionError(f"{locale} condemnation mark copy mismatch: {actual!r} != {expected!r}")
    print("[OK][CONDEMNATION_MARK_OBJECT_CONTRACT] OF-02 condemnation mark contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
