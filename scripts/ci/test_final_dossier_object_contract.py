#!/usr/bin/env python3
"""Static asset, runtime, localization, audio, and QA guard for OF-10."""

from __future__ import annotations

import csv
import re
import struct
import wave
import zlib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
OBJECT_DIR = ROOT / "assets/ui/official/objects/final_dossier"
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"
WORKFLOW = ROOT / ".github/workflows/godot_smoke_runtime.yml"

DOSSIERS = ("open", "updated", "closed")
TAB_STATES = ("normal", "focus", "pressed", "selected", "disabled")
ROUTES = {
    "NUOVO PERCORSO": {"it": "NUOVO PERCORSO", "en": "NEW PATH", "es": "NUEVO RECORRIDO"},
    "PROSSIMA SCOMMESSA": {"it": "PROSSIMA SCOMMESSA", "en": "NEXT BET", "es": "SIGUIENTE APUESTA"},
    "TORNA AL MENU": {"it": "TORNA AL MENU", "en": "Back to Menu", "es": "VOLVER AL MENU"},
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-10 file: {path.relative_to(ROOT)}")
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
    return min(choices, key=lambda choice: abs(estimate - choice))


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
            predictors = (0, left, up, (left + up) // 2, _paeth(left, up, upper_left))
            if not 0 <= filter_type <= 4:
                raise AssertionError(f"unsupported PNG filter {filter_type} in {path.name}")
            row[index] = (value + predictors[filter_type]) & 0xFF
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


def _assert_assets_and_styles() -> None:
    silhouette: bytes | None = None
    for state in DOSSIERS:
        width, height, alpha = _png_alpha(OBJECT_DIR / f"registry_final_dossier_{state}.png")
        if (width, height) != (1400, 800):
            raise AssertionError(f"{state} dossier must be RGBA 1400x800 (7:4)")
        if any(alpha[index] for index in (0, width - 1, len(alpha) - width, len(alpha) - 1)):
            raise AssertionError(f"{state} dossier must have transparent corners")
        coverage = sum(value > 0 for value in alpha) / len(alpha)
        if not 0.68 <= coverage <= 0.94:
            raise AssertionError(f"{state} dossier alpha coverage out of range: {coverage:.3f}")
        if silhouette is None:
            silhouette = alpha
        elif alpha != silhouette:
            raise AssertionError("open, updated, and closed dossiers must have identical alpha silhouettes")
        style = _read(OBJECT_DIR / f"sb_registry_final_dossier_{state}.tres")
        if f"registry_final_dossier_{state}.png" not in style:
            raise AssertionError(f"{state} dossier style uses the wrong texture")

    width, height, alpha = _png_alpha(OBJECT_DIR / "registry_final_dossier_tab.png")
    if (width, height) != (1000, 200):
        raise AssertionError("dossier tab must be RGBA 1000x200 (5:1)")
    if any(alpha[index] for index in (0, width - 1, len(alpha) - width, len(alpha) - 1)):
        raise AssertionError("dossier tab must have transparent corners")
    geometry: tuple[str, ...] | None = None
    for state in TAB_STATES:
        style = _read(OBJECT_DIR / f"sb_registry_final_dossier_tab_{state}.tres")
        if "registry_final_dossier_tab.png" not in style:
            raise AssertionError(f"{state} tab style uses the wrong texture")
        values = tuple(
            re.findall(
                r"^(?:texture_margin|content_margin)_(?:left|top|right|bottom) = (.+)$",
                style,
                re.MULTILINE,
            )
        )
        if len(values) != 8 or any(float(value) != 0.0 for value in values[:4]):
            raise AssertionError(f"{state} tab style must use zero texture margins")
        if geometry is None:
            geometry = values
        elif values != geometry:
            raise AssertionError("all dossier tab states must share identical geometry")


def _assert_scene_and_runtime() -> None:
    scene = _read(SCENE)
    ui = _read(UI_ROOT)
    panel = _node_block(scene, "Panel_END_RUN")
    if "custom_minimum_size = Vector2(1120, 640)" not in panel:
        raise AssertionError("Panel_END_RUN must be the fixed 1120x640 dossier")
    route_row = _node_block(scene, "EndRunRouteTabs")
    if "custom_minimum_size = Vector2(940, 64)" not in route_row or "alignment = 1" not in route_row:
        raise AssertionError("END_RUN route row must preserve the 940x64 geometry")
    for button_name in ("Btn_END_RUN_RESTART", "Btn_END_RUN_NEXT_BET", "Btn_END_RUN_QUIT"):
        block = _node_block(scene, button_name)
        for token in (
            "custom_minimum_size = Vector2(304, 64)",
            'theme_override_styles/normal = ExtResource("74_final_dossier_tab_normal")',
            'theme_override_styles/hover = ExtResource("75_final_dossier_tab_focus")',
            'theme_override_styles/pressed = ExtResource("76_final_dossier_tab_pressed")',
            'theme_override_styles/disabled = ExtResource("78_final_dossier_tab_disabled")',
        ):
            if token not in block:
                raise AssertionError(f"{button_name} missing dossier binding: {token}")
        if "size_flags_horizontal" in block:
            raise AssertionError(f"{button_name} must remain fixed at 304x64")

    if "END_RUN_BUTTON_READY_SCALE" in ui:
        raise AssertionError("END_RUN route tabs must not use hover/focus scale")
    state_mapping = _function_body(ui, "_apply_final_dossier_meta_state")
    for token in ("_last_register_final", "FINAL_DOSSIER_STATE_CLOSED", "FINAL_DOSSIER_STATE_UPDATED"):
        if token not in state_mapping:
            raise AssertionError(f"dossier meta mapping missing: {token}")
    button_availability = _function_body(ui, "_set_end_run_buttons_enabled")
    if "next_bet_button.visible = _last_next_bet_enabled" not in button_availability:
        raise AssertionError("next-bet visibility must depend exclusively on next_bet_enabled")

    activation = _function_body(ui, "_activate_final_dossier_route")
    ordered = (
        "if _final_dossier_route_locked",
        "_select_final_dossier_route(button)",
        "_final_dossier_route_locked = true",
        "_set_end_run_buttons_enabled(false)",
        '_play_sfx(&"registry_dossier_route")',
        "_emit_game_event_signal_if_available(signal_name)",
    )
    positions = [activation.find(token) for token in ordered]
    if -1 in positions or positions != sorted(positions):
        raise AssertionError("dossier route handler order must be guard -> selected -> lock -> cue -> emit")
    for forbidden in ("await ", "RunManager.", 'get_node_or_null("/root/RunManager")'):
        if forbidden in activation:
            raise AssertionError(f"dossier route handler contains forbidden runtime access: {forbidden}")
    for handler, signal_name in (
        ("_on_restart_pressed", "request_end_run_restart"),
        ("_on_retry_pressed", "request_end_run_next_bet"),
        ("_on_quit_pressed", "request_end_run_quit"),
    ):
        body = _function_body(ui, handler)
        if signal_name not in body or "_activate_final_dossier_route" not in body or "await " in body:
            raise AssertionError(f"{handler} must route the unchanged END_RUN intent without await")
    for reset_site in ("_on_run_started", "_on_run_finale_selected", "_set_game_over_modal", "_on_final_dossier_watchdog"):
        if "_reset_final_dossier_route_interaction" not in _function_body(ui, reset_site):
            raise AssertionError(f"dossier interaction must reset from {reset_site}")


def _assert_copy_audio_and_public_contracts() -> None:
    for key, translations in ROUTES.items():
        for locale, expected in translations.items():
            if _csv_value(locale, key) != expected:
                raise AssertionError(f"incorrect {locale} translation for {key}")
    for key in (
        "FASCICOLO CHIUSO - COMPROMISSIONE",
        "Il Registro chiude il fascicolo e classifica l'esito.",
        "I. APERTURA - CONSTATAZIONE",
        "Stato finale: %s.",
    ):
        for locale in ("it", "en", "es"):
            if not _csv_value(locale, key).strip():
                raise AssertionError(f"missing localized END_RUN copy for {key} ({locale})")

    sfx_bus = _read(SFX_BUS)
    for cue, duration_range in {
        "registry_dossier_update": (0.45, 0.70),
        "registry_dossier_close": (0.55, 0.80),
        "registry_dossier_route": (0.50, 0.75),
    }.items():
        path = ROOT / f"assets/audio/sfx/{cue}.wav"
        with wave.open(str(path), "rb") as wav_file:
            if (wav_file.getnchannels(), wav_file.getsampwidth(), wav_file.getframerate()) != (1, 2, 44100):
                raise AssertionError(f"{cue} must be mono PCM16 44.1 kHz")
            duration = wav_file.getnframes() / wav_file.getframerate()
            if not duration_range[0] <= duration <= duration_range[1]:
                raise AssertionError(f"{cue} duration out of range: {duration:.3f}s")
            frames = wav_file.readframes(wav_file.getnframes())
        peak = max(abs(sample[0]) for sample in struct.iter_unpack("<h", frames)) / 32767.0
        if peak > 10 ** (-3.0 / 20.0) + 1e-4:
            raise AssertionError(f"{cue} exceeds -3 dBFS")
        if cue not in sfx_bus or f"{cue}.wav" not in sfx_bus:
            raise AssertionError(f"SfxBus missing {cue}")

    events = _read(GAME_EVENTS)
    manager = _read(RUN_MANAGER)
    for signal_name in ("request_end_run_restart", "request_end_run_next_bet", "request_end_run_quit"):
        if f"signal {signal_name}" not in events:
            raise AssertionError(f"GameEvents END_RUN signal changed: {signal_name}")
        if signal_name not in manager:
            raise AssertionError(f"RunManager no longer owns END_RUN intent: {signal_name}")


def _assert_visual_qa() -> None:
    capture = _read(VISUAL_QA)
    workflow = _read(WORKFLOW)
    for token in (
        'const FINAL_DOSSIER_SECTION: String = "final_dossier"',
        "func _capture_final_dossier_matrix() -> void:",
        '"08_dossier_%s_%dx%d"',
        'ui_root.call("_set_final_dossier_state", &"open")',
        'ui_root.call("_set_final_dossier_state", &"updated")',
        'ui_root.call("_set_final_dossier_state", &"closed")',
        'await _capture("%s_focus" % prefix',
        'await _capture("%s_selected" % prefix',
        'await _capture("%s_disabled" % prefix',
    ):
        if token not in capture:
            raise AssertionError(f"final dossier visual QA missing: {token}")
    for token in (
        "--section=final_dossier",
        "timeout 240s",
        "timeout 480s",
        "DOSSIER_COUNT",
        'test "$DOSSIER_COUNT" -eq 36',
        "08_dossier_*.png",
    ):
        if token not in workflow:
            raise AssertionError(f"workflow missing lean/full dossier evidence: {token}")


def main() -> int:
    _assert_assets_and_styles()
    _assert_scene_and_runtime()
    _assert_copy_audio_and_public_contracts()
    _assert_visual_qa()
    print("OF-10 final dossier object contract: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
