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


def _paeth(left: int, up: int, upper_left: int) -> int:
    estimate = left + up - upper_left
    left_distance = abs(estimate - left)
    up_distance = abs(estimate - up)
    upper_left_distance = abs(estimate - upper_left)
    if left_distance <= up_distance and left_distance <= upper_left_distance:
        return left
    if up_distance <= upper_left_distance:
        return up
    return upper_left


def _png_alpha(path: Path) -> tuple[int, int, bytes]:
    raw = path.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n":
        raise AssertionError(f"{path.name} must be a PNG")
    cursor = 8
    idat = bytearray()
    width = height = bit_depth = color_type = interlace = -1
    while cursor < len(raw):
        length = struct.unpack(">I", raw[cursor : cursor + 4])[0]
        chunk_type = raw[cursor + 4 : cursor + 8]
        payload = raw[cursor + 8 : cursor + 8 + length]
        cursor += 12 + length
        if chunk_type == b"IHDR":
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", payload)
        elif chunk_type == b"IDAT":
            idat.extend(payload)
        elif chunk_type == b"IEND":
            break
    if bit_depth != 8 or color_type != 6 or interlace != 0:
        raise AssertionError(f"{path.name} must be non-interlaced 8-bit RGBA")
    decoded = zlib.decompress(bytes(idat))
    stride = width * 4
    previous = bytearray(stride)
    alpha = bytearray()
    offset = 0
    for _ in range(height):
        filter_type = decoded[offset]
        offset += 1
        source = decoded[offset : offset + stride]
        offset += stride
        row = bytearray(stride)
        for index, value in enumerate(source):
            left = row[index - 4] if index >= 4 else 0
            up = previous[index]
            upper_left = previous[index - 4] if index >= 4 else 0
            if filter_type == 0:
                result = value
            elif filter_type == 1:
                result = value + left
            elif filter_type == 2:
                result = value + up
            elif filter_type == 3:
                result = value + ((left + up) // 2)
            elif filter_type == 4:
                result = value + _paeth(left, up, upper_left)
            else:
                raise AssertionError(f"unsupported PNG filter {filter_type} in {path.name}")
            row[index] = result & 0xFF
        alpha.extend(row[3::4])
        previous = row
    return width, height, bytes(alpha)


def _csv_value(locale: str, key: str) -> str:
    path = ROOT / f"assets/i18n/{locale}.csv"
    with path.open("r", encoding="utf-8", newline="") as handle:
        rows = list(csv.reader(handle))
    matches = [row[1] for row in rows[1:] if len(row) == 2 and row[0] == key]
    if len(matches) != 1:
        raise AssertionError(f"{locale} must contain exactly one {key!r} entry")
    return matches[0]


def _assert_textures() -> None:
    blank_width, blank_height, blank_alpha = _png_alpha(BLANK_TEXTURE)
    signed_width, signed_height, signed_alpha = _png_alpha(SIGNED_TEXTURE)
    if (blank_width, blank_height) != (1024, 256):
        raise AssertionError(f"promise signature textures must be 4:1 at 1024x256, got {blank_width}x{blank_height}")
    if (signed_width, signed_height) != (blank_width, blank_height):
        raise AssertionError("blank and signed promise textures must share dimensions")
    if blank_alpha != signed_alpha:
        raise AssertionError("blank and signed promise textures must share the exact alpha silhouette")
    if any(blank_alpha[index] != 0 for index in (0, blank_width - 1, len(blank_alpha) - blank_width, len(blank_alpha) - 1)):
        raise AssertionError("promise signature textures must have transparent corners")
    opaque_coverage = sum(alpha > 0 for alpha in blank_alpha) / len(blank_alpha)
    if not 0.55 <= opaque_coverage <= 0.95:
        raise AssertionError(f"unexpected promise signature subject coverage: {opaque_coverage:.3f}")


def _assert_style_geometry() -> None:
    geometry: tuple[str, ...] | None = None
    for state in STYLE_NAMES:
        path = STYLE_DIR / f"sb_registry_promise_signature_{state}.tres"
        text = _read(path)
        expected_texture = "registry_promise_signature_signed.png" if state == "signed" else "registry_promise_signature_blank.png"
        if expected_texture not in text:
            raise AssertionError(f"{path.name} must use {expected_texture}")
        values = tuple(
            re.findall(
                r"^(?:texture_margin|content_margin)_(?:left|top|right|bottom) = (.+)$",
                text,
                re.MULTILINE,
            )
        )
        if len(values) != 8:
            raise AssertionError(f"{path.name} must define stable texture/content margins")
        if geometry is None:
            geometry = values
        elif values != geometry:
            raise AssertionError(f"{path.name} changes promise signature geometry")


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
    _assert_style_geometry()
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
