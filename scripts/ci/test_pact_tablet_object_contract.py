#!/usr/bin/env python3
"""Static, asset, runtime, audio, and QA guard for OF-07."""

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
STYLE_DIR = ROOT / "assets/ui/official/objects/pact_tablet"
TEXTURE = STYLE_DIR / "registry_pact_tablet_sealed.png"
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
SFX_PATH = ROOT / "assets/audio/sfx/registry_pact_validate.wav"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

STYLE_NAMES = ("normal", "focus", "pressed", "validated", "disabled")
EXPECTED_COPY = {
    "MOSTRA IL PATTO": {
        "it": "MOSTRA IL PATTO",
        "en": "SHOW THE PACT",
        "es": "MUESTRA EL PACTO",
    },
    "PATTO SIGILLATO": {
        "it": "PATTO SIGILLATO",
        "en": "PACT SEALED",
        "es": "PACTO SELLADO",
    },
    "La pietra ha preso la firma.": {
        "it": "La pietra ha preso la firma.",
        "en": "The stone has taken the signature.",
        "es": "La piedra ha recibido la firma.",
    },
    "La gradinata attende il gesto.": {
        "it": "La gradinata attende il gesto.",
        "en": "The crowd awaits the gesture.",
        "es": "La grada espera el gesto.",
    },
    "SEGNI": {"it": "SEGNI", "en": "MARKS", "es": "MARCAS"},
    "Registro pulito: nessun segno inciso.": {
        "it": "Registro pulito: nessun segno inciso.",
        "en": "Clean Registry: no mark inscribed.",
        "es": "Registro limpio: ninguna marca inscrita.",
    },
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-07 file: {path.relative_to(ROOT)}")
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


def _assert_texture_and_styles() -> None:
    validate_family("pact_tablet")


def _assert_scene_and_copy() -> None:
    scene = _read(SCENE)
    for state in STYLE_NAMES:
        resource = f"sb_registry_pact_tablet_{state}.tres"
        if resource not in scene:
            raise AssertionError(f"UI scene missing pact tablet resource: {resource}")
    block = _node_block(scene, "Btn_FIRST_REACTION_NEXT")
    for token in (
        "focus_mode = 2",
        'theme_override_styles/normal = ExtResource("49_registry_pact_tablet_normal")',
        'theme_override_styles/hover = ExtResource("50_registry_pact_tablet_focus")',
        'theme_override_styles/focus = ExtResource("50_registry_pact_tablet_focus")',
        'theme_override_styles/pressed = ExtResource("51_registry_pact_tablet_pressed")',
        'theme_override_styles/disabled = ExtResource("53_registry_pact_tablet_disabled")',
        "theme_override_colors/font_disabled_color = Color(0.76, 0.72, 0.64, 1)",
        "theme_override_font_sizes/font_size = 20",
        "custom_minimum_size = Vector2(320, 128)",
        'text = "MOSTRA IL PATTO"',
    ):
        if token not in block:
            raise AssertionError(f"pact tablet scene binding missing: {token}")
    panel = _node_block(scene, "Panel_FIRST_REACTION")
    if "custom_minimum_size = Vector2(660, 390)" not in panel:
        raise AssertionError("pact panel must be 660x390")
    for key, translations in EXPECTED_COPY.items():
        for locale, expected in translations.items():
            actual = _csv_value(locale, key)
            if actual != expected:
                raise AssertionError(f"{locale} pact copy mismatch for {key!r}: {actual!r}")

    disabled_style = _read(STYLE_DIR / "sb_registry_pact_tablet_disabled.tres")
    normal_style = _read(STYLE_DIR / "sb_registry_pact_tablet_normal.tres")
    if "modulate_color = Color(0.48, 0.48, 0.46, 1)" not in disabled_style:
        raise AssertionError("pact disabled state must retain readable contrast")
    if "modulate_color = Color(1, 1, 1, 1)" not in normal_style:
        raise AssertionError("pact normal contrast baseline changed")


def _assert_runtime_contract() -> None:
    source = _read(UI_ROOT)
    handler = _function_body(source, "_on_pact_ritual_next_pressed")
    ordered = (
        "_set_pact_tablet_validated_state(true)",
        "_pact_tablet_locked = true",
        "_apply_decision_lock",
        '_play_sfx(&"registry_pact_validate")',
        '_emit_game_event_signal_if_available(&"request_ritual_advance", ["pact"])',
        "_start_pact_tablet_request_watchdog()",
    )
    positions = [handler.find(token) for token in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        raise AssertionError("pact handler must validate, lock, cue, emit, then watchdog")
    if "await " in handler or "cursor_select" in handler:
        raise AssertionError("pact validation must be immediate and use only its dedicated cue")
    executable = "\n".join(line.split("#", 1)[0] for line in handler.splitlines())
    for forbidden in ("RunManager.", 'get_node_or_null("/root/RunManager")', "_on_request_ritual_advance("):
        if forbidden in executable:
            raise AssertionError(f"UI must not call gameplay authority directly: {forbidden}")

    for function_name in (
        "show_phase",
        "_on_run_started",
        "_on_run_failed",
        "_on_pact_sealed_opened",
        "_on_pact_sealed_closed",
        "_show_post_bet_payload",
        "_recover_pact_tablet_request_lock",
    ):
        if "_reset_pact_tablet_state()" not in _function_body(source, function_name):
            raise AssertionError(f"pact tablet reset missing from {function_name}")
    reset = _function_body(source, "_reset_pact_tablet_state")
    for token in (
        "_pact_tablet_locked = false",
        "_set_pact_tablet_validated_state(false)",
        "_reset_decision_surface",
    ):
        if token not in reset:
            raise AssertionError(f"pact tablet reset missing token: {token}")
    watchdog = _function_body(source, "_start_pact_tablet_request_watchdog")
    if "PACT_TABLET_WATCHDOG_SECONDS" not in watchdog or "_recover_pact_tablet_request_if_still_open" not in watchdog:
        raise AssertionError("pact tablet watchdog is incomplete")
    state_helper = _function_body(source, "_set_pact_tablet_validated_state")
    for token in (
        "PACT_TABLET_STYLE_VALIDATED",
        "PACT_TABLET_STYLE_DISABLED",
        "set_meta(PACT_TABLET_VALIDATED_META, validated)",
    ):
        if token not in state_helper:
            raise AssertionError(f"pact tablet state helper missing token: {token}")

    if "signal request_ritual_advance(kind: String)" not in _read(GAME_EVENTS):
        raise AssertionError("GameEvents request_ritual_advance contract changed")
    run_manager = _read(RUN_MANAGER)
    for token in (
        "func _on_request_ritual_advance(kind: String) -> void:",
        'if normalized == "pact" and _phase == RunPhase.BET_COMMITTED:',
    ):
        if token not in run_manager:
            raise AssertionError("RunManager pact authority changed")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for token in (
        '&"registry_pact_validate": -10.5',
        '&"registry_pact_validate": "res://assets/audio/sfx/registry_pact_validate.wav"',
    ):
        if token not in sfx_bus:
            raise AssertionError(f"SfxBus missing pact cue token: {token}")
    with wave.open(str(SFX_PATH), "rb") as handle:
        if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
            raise AssertionError("pact validation WAV must be mono PCM16 at 44.1 kHz")
        frame_count = handle.getnframes()
        frames = handle.readframes(frame_count)
    duration = frame_count / 44100.0
    if not 0.55 <= duration <= 0.80:
        raise AssertionError(f"pact validation WAV duration out of range: {duration:.3f}s")
    samples = struct.unpack(f"<{len(frames) // 2}h", frames)
    peak = max(abs(sample) for sample in samples) / 32767.0
    peak_dbfs = 20.0 * math.log10(peak) if peak > 0.0 else -math.inf
    if peak_dbfs > -2.9:
        raise AssertionError(f"pact validation WAV peak exceeds -3 dBFS target: {peak_dbfs:.2f}")


def _assert_visual_qa_matrix() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        "func _capture_pact_tablet_matrix() -> void:",
        'PACT_TABLET_LOCALES: Array[String] = ["it", "en", "es"]',
        "PACT_TABLET_VIEWPORT_SIZES",
        "PACT_TABLET_BUTTON_PATH",
        'argument.begins_with("--section=")',
        'PACT_TABLET_SECTION: String = "pact_tablet"',
        '"04_pact_%s_%dx%d"',
        '"%s_normal"',
        '"%s_focus"',
        '"%s_validated"',
        '"%s_disabled"',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA pact matrix missing token: {token}")


def main() -> int:
    _assert_texture_and_styles()
    _assert_scene_and_copy()
    _assert_runtime_contract()
    _assert_audio()
    _assert_visual_qa_matrix()
    print("[OK][PACT_TABLET_OBJECT_CONTRACT] OF-07 pact tablet contract passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
