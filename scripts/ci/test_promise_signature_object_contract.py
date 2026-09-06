#!/usr/bin/env python3
"""Static, asset, runtime, audio, and QA guard for OF-06."""

from __future__ import annotations

import csv
import math
import re
import struct
import wave
import zlib
from pathlib import Path
from generated_art_contract import validate_family


ROOT = Path(__file__).resolve().parents[2]
STYLE_DIR = ROOT / "assets/ui/official/objects/promise_signature"
BLANK_TEXTURE = STYLE_DIR / "registry_promise_signature_blank.png"
SIGNED_TEXTURE = STYLE_DIR / "registry_promise_signature_signed.png"
SCENE = ROOT / "scenes/ui/BettingCircle.tscn"
BETTING_UI = ROOT / "scripts/ui/betting_circle_ui.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
SFX_PATH = ROOT / "assets/audio/sfx/registry_promise_sign.wav"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

STYLE_NAMES = ("normal", "focus", "pressed", "selected", "signed", "disabled")
EXPECTED_COPY = {"it": "FIRMA", "en": "SIGN", "es": "FIRMAR"}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-06 file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def _function_body(source: str, name: str) -> str:
    match = re.search(rf"(?ms)^func {re.escape(name)}\(.*?(?=^func |\Z)", source)
    if match is None:
        raise AssertionError(f"missing function: {name}")
    return match.group(0)


def _node_block(scene: str, node_name: str) -> str:
    match = re.search(
        rf'^\[node name="{re.escape(node_name)}".*?(?=^\[node |\Z)',
        scene,
        re.MULTILINE | re.DOTALL,
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
    validate_family("promise_signature")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    for resource in (
        "sb_registry_promise_signature_normal.tres",
        "sb_registry_promise_signature_focus.tres",
        "sb_registry_promise_signature_pressed.tres",
        "sb_registry_promise_signature_disabled.tres",
    ):
        if resource not in scene:
            raise AssertionError(f"BettingCircle missing promise resource: {resource}")
    for button_name in ("Btn_Sign_Left", "Btn_Sign_Right"):
        block = _node_block(scene, button_name)
        for token in (
            "focus_mode = 2",
            'theme_override_styles/normal = ExtResource("19_promise_normal")',
            'theme_override_styles/hover = ExtResource("20_promise_focus")',
            'theme_override_styles/focus = ExtResource("20_promise_focus")',
            'theme_override_styles/pressed = ExtResource("21_promise_pressed")',
            'theme_override_styles/disabled = ExtResource("24_promise_disabled")',
        ):
            if token not in block:
                raise AssertionError(f"{button_name} missing promise binding: {token}")
    for label_name in ("Lbl_Sign_Left", "Lbl_Sign_Right"):
        if 'text = "FIRMA"' not in _node_block(scene, label_name):
            raise AssertionError(f"{label_name} must retain the canonical FIRMA CTA")


def _assert_runtime_contract() -> None:
    source = _read(BETTING_UI)
    submit = _function_body(source, "_submit_selected_offer")
    ordered = (
        "_set_promise_signature_state(button, PROMISE_SIGNATURE_STATE_SIGNED)",
        "_submit_locked = true",
        "_update_sigilla_state()",
        '_play_sfx(&"registry_promise_sign")',
        "GameEvents.request_place_bet.emit(String(selected_bet_id), 0)",
        "close()",
    )
    positions = [submit.find(token) for token in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        raise AssertionError("sign handler must sign, lock, cue, emit request_place_bet, then close")
    if "await " in submit:
        raise AssertionError("promise signing must not await presentation")
    executable = "\n".join(line.split("#", 1)[0] for line in submit.splitlines())
    for forbidden in ("RunManager.", 'get_node_or_null("/root/RunManager")', "_on_request_place_bet("):
        if forbidden in executable:
            raise AssertionError(f"BettingCircle must not call gameplay authority directly: {forbidden}")
    if "cursor_select" in submit or "_play_stamp_feedback" in source:
        raise AssertionError("promise signing must use its dedicated cue and stable geometry")

    reset = _function_body(source, "_reset_interaction_lock")
    for token in (
        "_submit_locked = false",
        "_set_promise_signature_state(left_sign_button, PROMISE_SIGNATURE_STATE_NORMAL)",
        "_set_promise_signature_state(right_sign_button, PROMISE_SIGNATURE_STATE_NORMAL)",
    ):
        if token not in reset:
            raise AssertionError(f"promise reset missing token: {token}")
    selection = _function_body(source, "_apply_selection_visual")
    if ".scale" in selection or "tween_property" in selection:
        raise AssertionError("promise selection must not move or resize the target")
    state_helper = _function_body(source, "_set_promise_signature_state")
    for token in (
        "PROMISE_SIGNATURE_STYLE_NORMAL",
        "PROMISE_SIGNATURE_STYLE_FOCUS",
        "PROMISE_SIGNATURE_STYLE_PRESSED",
        "PROMISE_SIGNATURE_STYLE_SELECTED",
        "PROMISE_SIGNATURE_STYLE_SIGNED",
        "PROMISE_SIGNATURE_STYLE_DISABLED",
        "set_meta(PROMISE_SIGNATURE_STATE_META, state)",
    ):
        if token not in state_helper:
            raise AssertionError(f"promise state helper missing token: {token}")

    if "signal request_place_bet(bet_id: String, stake: int)" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents request_place_bet contract changed")
    if "func _on_request_place_bet(bet_id: String, _stake: int) -> void:" not in _read(RUN_MANAGER):
        raise AssertionError("RunManager bet authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for token in (
        '&"registry_promise_sign": -11.0',
        '&"registry_promise_sign": "res://assets/audio/sfx/registry_promise_sign.wav"',
    ):
        if token not in sfx_bus:
            raise AssertionError(f"SfxBus missing promise cue token: {token}")
    if not SFX_PATH.exists():
        raise AssertionError("missing registry_promise_sign.wav")
    with wave.open(str(SFX_PATH), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
            raise AssertionError("promise signature WAV must be mono PCM16 at 44.1 kHz")
        frame_count = handle.getnframes()
        frames = handle.readframes(frame_count)
    duration = frame_count / 44100.0
    if not 0.45 <= duration <= 0.70:
        raise AssertionError(f"promise signature WAV duration out of range: {duration:.3f}s")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    peak = max(abs(sample) for sample in samples) / 32767.0
    peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
    if peak_dbfs > -2.9:
        raise AssertionError(f"promise signature WAV peak exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa_matrix() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        "func _capture_promise_signature_matrix() -> void:",
        'PROMISE_SIGNATURE_LOCALES: Array[String] = ["it", "en", "es"]',
        "PROMISE_SIGNATURE_VIEWPORT_SIZES",
        "PROMISE_SIGNATURE_LEFT_PATH",
        '"%s_normal"',
        '"%s_focus"',
        '"%s_selected"',
        '"%s_signed"',
        '"%s_disabled"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA promise matrix missing token: {token}")


def main() -> int:
    _assert_textures()
    _assert_scene_binding()
    _assert_runtime_contract()
    _assert_audio()
    _assert_visual_qa_matrix()
    for locale, expected in EXPECTED_COPY.items():
        actual = _csv_value(locale, "FIRMA")
        if actual != expected:
            raise AssertionError(f"{locale} promise CTA mismatch: {actual!r}")
    print("[OK][PROMISE_SIGNATURE_OBJECT_CONTRACT] OF-06 promise signature contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
