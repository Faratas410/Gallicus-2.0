#!/usr/bin/env python3
"""Static, asset, runtime, audio, localization, and QA guard for OF-08."""

from __future__ import annotations

import csv
import math
import re
import struct
import wave
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OBJECT_DIR = ROOT / "assets/ui/official/objects/arena_gesture"
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

GESTURES = ("placa", "provoca")
STATES = ("normal", "focus", "pressed", "selected", "disabled")
EXPECTED_COPY = {
    "ATTO DAVANTI ALLA GRADINATA": {
        "it": "ATTO DAVANTI ALLA GRADINATA",
        "en": "ACT BEFORE THE CROWD",
        "es": "ACTO ANTE LA GRADA",
    },
    "ABBASSA LO SGUARDO": {
        "it": "ABBASSA LO SGUARDO",
        "en": "LOWER YOUR GAZE",
        "es": "BAJA LA MIRADA",
    },
    "SFIDA LA GRADINATA": {
        "it": "SFIDA LA GRADINATA",
        "en": "CHALLENGE THE CROWD",
        "es": "DESAFÍA A LA GRADA",
    },
    "Il Registro annota misura.": {
        "it": "Il Registro annota misura.",
        "en": "The Registry records restraint.",
        "es": "El Registro anota mesura.",
    },
    "Il Registro annota esposizione.": {
        "it": "Il Registro annota esposizione.",
        "en": "The Registry records exposure.",
        "es": "El Registro anota exposición.",
    },
    "La gradinata si quieta: il Registro vede prudenza.": {
        "it": "La gradinata si quieta: il Registro vede prudenza.",
        "en": "The stands grow quiet: the Registry sees restraint.",
        "es": "La grada se aquieta: el Registro ve prudencia.",
    },
    "Trattieni il gesto. L'arena concede ancora margine.": {
        "it": "Trattieni il gesto. L'arena concede ancora margine.",
        "en": "Hold back the gesture. The arena still allows some margin.",
        "es": "Contén el gesto. La arena aún concede margen.",
    },
    "Non cercano vanto: aspettano se saprai durare.": {
        "it": "Non cercano vanto: aspettano se saprai durare.",
        "en": "They seek no boasting: they wait to see if you can endure.",
        "es": "No buscan alarde: esperan ver si sabrás resistir.",
    },
    "La folla resta sospesa tra misura e sfida.": {
        "it": "La folla resta sospesa tra misura e sfida.",
        "en": "The crowd hangs between restraint and defiance.",
        "es": "La multitud queda suspendida entre mesura y desafío.",
    },
    "Ogni sguardo chiede se terrai il passo.": {
        "it": "Ogni sguardo chiede se terrai il passo.",
        "en": "Every gaze asks whether you will hold your ground.",
        "es": "Cada mirada pregunta si mantendrás el paso.",
    },
    "La gradinata batte ferro: vuole vederti oltre.": {
        "it": "La gradinata batte ferro: vuole vederti oltre.",
        "en": "The stands strike iron: they want to see you go further.",
        "es": "La grada golpea hierro: quiere verte ir más allá.",
    },
    "Il rischio sale e il Registro non distoglie gli occhi.": {
        "it": "Il rischio sale e il Registro non distoglie gli occhi.",
        "en": "Risk rises, and the Registry does not look away.",
        "es": "El riesgo sube y el Registro no aparta la mirada.",
    },
    "Se cedi ora, il silenzio pesera piu della ferita.": {
        "it": "Se cedi ora, il silenzio peserà più della ferita.",
        "en": "If you yield now, the silence will weigh more than the wound.",
        "es": "Si cedes ahora, el silencio pesará más que la herida.",
    },
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-08 file: {path.relative_to(ROOT)}")
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
    choices = (left, up, upper_left)
    distances = tuple(abs(estimate - choice) for choice in choices)
    return choices[distances.index(min(distances))]


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
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(
                ">IIBBBBB", payload
            )
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


def _assert_assets_and_states() -> None:
    masks: dict[str, set[int]] = {}
    geometry: tuple[str, ...] | None = None
    for gesture in GESTURES:
        width, height, alpha = _png_alpha(OBJECT_DIR / f"arena_gesture_tile_{gesture}.png")
        if (width, height) != (768, 512):
            raise AssertionError(f"{gesture} tile must be 3:2 RGBA at 768x512")
        if any(alpha[index] != 0 for index in (0, width - 1, len(alpha) - width, len(alpha) - 1)):
            raise AssertionError(f"{gesture} tile must have transparent corners")
        masks[gesture] = {index for index, value in enumerate(alpha) if value > 0}
        xs = [index % width for index in masks[gesture]]
        ys = [index // width for index in masks[gesture]]
        width_coverage = (max(xs) - min(xs) + 1) / width
        height_coverage = (max(ys) - min(ys) + 1) / height
        if not 0.86 <= width_coverage <= 0.94 or not 0.86 <= height_coverage <= 0.94:
            raise AssertionError(
                f"{gesture} tile occupancy out of range: {width_coverage:.3f}x{height_coverage:.3f}"
            )
        for state in STATES:
            style = _read(OBJECT_DIR / f"sb_arena_gesture_{gesture}_{state}.tres")
            if f"arena_gesture_tile_{gesture}.png" not in style:
                raise AssertionError(f"{gesture}/{state} style uses the wrong texture")
            values = tuple(
                re.findall(
                    r"^(?:texture_margin|content_margin)_(?:left|top|right|bottom) = (.+)$",
                    style,
                    re.MULTILINE,
                )
            )
            if len(values) != 8 or any(float(value) != 0.0 for value in values[:4]):
                raise AssertionError(f"{gesture}/{state} must use uniform, stable geometry")
            if geometry is None:
                geometry = values
            elif values != geometry:
                raise AssertionError(f"{gesture}/{state} changes the shared tile geometry")
    intersection = len(masks["placa"] & masks["provoca"])
    union = len(masks["placa"] | masks["provoca"])
    if intersection / union < 0.995:
        raise AssertionError("placa/provoca silhouettes must coincide")


def _assert_scene_and_copy() -> None:
    scene = _read(SCENE)
    panel = _node_block(scene, "Panel_MID_CHOICE")
    if "custom_minimum_size = Vector2(764, 430)" not in panel:
        raise AssertionError("gesture panel must be 764x430")
    box = _node_block(scene, "Box_MID_CHOICE_CHOICES")
    if "theme_override_constants/separation = 14" not in box or "alignment = 1" not in box:
        raise AssertionError("gesture tiles must be centered with 14 px separation")
    for index, gesture in enumerate(GESTURES):
        block = _node_block(scene, f"Btn_MID_CHOICE_SELECT_{index}")
        resource_ids = (54, 55, 55, 56, 58) if gesture == "placa" else (59, 60, 60, 61, 63)
        for property_name, resource_id in zip(
            ("normal", "hover", "focus", "pressed", "disabled"), resource_ids
        ):
            token = f'theme_override_styles/{property_name} = ExtResource("{resource_id}_arena_gesture_{gesture}_'
            if token not in block:
                raise AssertionError(f"{gesture} scene binding missing {property_name}")
        for token in ("focus_mode = 2", "custom_minimum_size = Vector2(336, 224)", "size_flags_horizontal = 0"):
            if token not in block:
                raise AssertionError(f"{gesture} scene geometry missing: {token}")
    for key, translations in EXPECTED_COPY.items():
        for locale, expected in translations.items():
            actual = _csv_value(locale, key)
            if actual != expected:
                raise AssertionError(f"{locale} gesture copy mismatch for {key!r}: {actual!r}")


def _assert_runtime() -> None:
    source = _read(UI_ROOT)
    expected_handlers = (
        ("_on_intermediate_choice_placa_pressed", "0", "arena_gesture_placa"),
        ("_on_intermediate_choice_provoca_pressed", "1", "arena_gesture_provoca"),
    )
    for function_name, index, cue in expected_handlers:
        handler = _function_body(source, function_name)
        ordered = (
            "if _gesture_choice_locked:",
            f"_set_gesture_choice_selected_state({index})",
            "_gesture_choice_locked = true",
            "_apply_decision_lock",
            f'_play_sfx(&"{cue}")',
            f'_emit_game_event_signal_if_available(&"request_mid_choice_select", [{index}])',
            "_start_gesture_choice_request_watchdog()",
        )
        positions = [handler.find(token) for token in ordered]
        if any(position < 0 for position in positions) or positions != sorted(positions):
            raise AssertionError(f"{function_name} must select, lock, cue, emit, then watchdog")
        if "await " in handler or "cursor_select" in handler or "Vector2(1.025" in handler:
            raise AssertionError(f"{function_name} must be immediate, dedicated, and scale-free")
        if "false,\n\t\tfalse" not in handler:
            raise AssertionError(f"{function_name} must suppress generic cue and selected scaling")
        executable = "\n".join(line.split("#", 1)[0] for line in handler.splitlines())
        if "RunManager." in executable or '_on_request_mid_choice_select(' in executable:
            raise AssertionError("gesture UI must not call gameplay authority directly")

    wire = _function_body(source, "_wire_intermediate_choice_buttons")
    if "_wire_sign_preview" in wire or "_wire_mid_choice_emphasis" in wire:
        raise AssertionError("gesture tiles must not use inherited hover/sign scaling")
    apply_payload = _function_body(source, "_apply_intermediate_choice_payload")
    for token in ("_reset_gesture_choice_state()", "tr(audience_line)", "tr(title)", "_refresh_gesture_choice_copy()"):
        if token not in apply_payload:
            raise AssertionError(f"gesture payload localization/reset missing: {token}")
    for function_name in (
        "show_phase",
        "_on_run_started",
        "_on_run_failed",
        "_on_intermediate_choice_opened",
        "_apply_intermediate_choice_payload",
        "_recover_gesture_choice_request_lock",
        "_set_intermediate_choice_modal",
    ):
        if "_reset_gesture_choice_state()" not in _function_body(source, function_name):
            raise AssertionError(f"gesture reset missing from {function_name}")
    reset = _function_body(source, "_reset_gesture_choice_state")
    for token in ("_gesture_choice_locked = false", "_set_gesture_choice_selected_state(-1)", "_reset_decision_surface"):
        if token not in reset:
            raise AssertionError(f"gesture reset missing token: {token}")
    watchdog = _function_body(source, "_start_gesture_choice_request_watchdog")
    if "GESTURE_CHOICE_WATCHDOG_SECONDS" not in watchdog or "_recover_gesture_choice_request_if_still_open" not in watchdog:
        raise AssertionError("gesture watchdog is incomplete")
    if "signal request_mid_choice_select(index: int)" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents mid-choice signal changed")
    run_manager = _read(RUN_MANAGER)
    for token in (
        "func _on_request_mid_choice_select(index: int) -> void:",
        '[&"request_mid_choice_select", &"_on_request_mid_choice_select", true]',
    ):
        if token not in run_manager:
            raise AssertionError("RunManager mid-choice authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for gesture in GESTURES:
        for token in (
            f'&"arena_gesture_{gesture}":',
            f'&"arena_gesture_{gesture}": "res://assets/audio/sfx/arena_gesture_{gesture}.wav"',
        ):
            if token not in sfx_bus:
                raise AssertionError(f"SfxBus missing gesture cue: {token}")
        path = ROOT / f"assets/audio/sfx/arena_gesture_{gesture}.wav"
        with wave.open(str(path), "rb") as handle:
            if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
                raise AssertionError(f"{gesture} WAV must be mono PCM16 at 44.1 kHz")
            frames_count = handle.getnframes()
            frames = handle.readframes(frames_count)
        duration = frames_count / 44100.0
        if not 0.55 <= duration <= 0.85:
            raise AssertionError(f"{gesture} WAV duration out of range: {duration:.3f}s")
        samples = struct.unpack(f"<{len(frames) // 2}h", frames)
        peak = max(abs(sample) for sample in samples) / 32767.0
        peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
        if peak_dbfs > -2.9:
            raise AssertionError(f"{gesture} WAV exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        'GESTURE_CHOICE_SECTION: String = "gesture_choice"',
        'GESTURE_CHOICE_LOCALES: Array[String] = ["it", "en", "es"]',
        "GESTURE_CHOICE_VIEWPORT_SIZES",
        "func _capture_gesture_choice_matrix() -> void:",
        '"05_gesture_%s_%dx%d"',
        '"%s_normal"',
        '"%s_focus_placa"',
        '"%s_focus_provoca"',
        '"%s_selected_placa"',
        '"%s_selected_provoca"',
        '"%s_disabled"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA gesture matrix missing token: {token}")


def main() -> int:
    _assert_assets_and_states()
    _assert_scene_and_copy()
    _assert_runtime()
    _assert_audio()
    _assert_visual_qa()
    print("[OK][ARENA_GESTURE_OBJECT_CONTRACT] OF-08 arena gesture contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
