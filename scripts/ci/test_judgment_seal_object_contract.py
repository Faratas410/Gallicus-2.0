#!/usr/bin/env python3
"""Static, asset, runtime, audio, localization, and QA guard for OF-09."""

from __future__ import annotations

import csv
import re
import struct
import wave
import zlib
from pathlib import Path
from generated_art_contract import validate_family


ROOT = Path(__file__).resolve().parents[2]
OBJECT_DIR = ROOT / "assets/ui/official/objects/judgment_seal"
SCENE = ROOT / "scenes/UI.tscn"
UI_ROOT = ROOT / "scripts/ui/ui_root.gd"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
RUN_MANAGER = ROOT / "scripts/systems/run_manager.gd"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"
MARKER = ROOT / ".github/ci/full_suite_checkpoint.txt"

TEXTURE = OBJECT_DIR / "registry_judgment_seal.png"
STATES = ("normal", "focus", "pressed", "strike_1", "strike_2", "resolved", "disabled")
EXPECTED_COPY = {
    "RITO DI GIUDIZIO": {
        "it": "RITO DI GIUDIZIO",
        "en": "RITE OF JUDGMENT",
        "es": "RITO DE JUICIO",
    },
    "Il Registro pesa il patto.": {
        "it": "Il Registro pesa il patto.",
        "en": "The Registry weighs the pact.",
        "es": "El Registro pesa el pacto.",
    },
    "Imprimi tre colpi sul sigillo.": {
        "it": "Imprimi tre colpi sul sigillo.",
        "en": "Press the seal three times.",
        "es": "Imprime tres golpes en el sello.",
    },
    "Tre colpi chiudono il verbale.": {
        "it": "Tre colpi chiudono il verbale.",
        "en": "Three strikes close the record.",
        "es": "Tres golpes cierran el acta.",
    },
    "Il tuo gesto li irrita. Ora vogliono il prezzo.": {
        "it": "Il tuo gesto li irrita. Ora vogliono il prezzo.",
        "en": "Your gesture irritates them. Now they demand the price.",
        "es": "Tu gesto los irrita. Ahora exigen el precio.",
    },
    "Hai mostrato il fianco. Ti puniscono col silenzio.": {
        "it": "Hai mostrato il fianco. Ti puniscono col silenzio.",
        "en": "You showed your flank. They punish you with silence.",
        "es": "Has mostrado el flanco. Te castigan con el silencio.",
    },
    "Un gesto non basta. Vogliono vederti cedere.": {
        "it": "Un gesto non basta. Vogliono vederti cedere.",
        "en": "One gesture is not enough. They want to see you yield.",
        "es": "Un gesto no basta. Quieren verte ceder.",
    },
    "Ti sei esposto. Ti vogliono spezzare.": {
        "it": "Ti sei esposto. Ti vogliono spezzare.",
        "en": "You exposed yourself. They want to break you.",
        "es": "Te has expuesto. Quieren quebrarte.",
    },
    "Un gesto segnato, il debito resta.": {
        "it": "Un gesto segnato, il debito resta.",
        "en": "A gesture recorded; the debt remains.",
        "es": "Un gesto registrado; la deuda permanece.",
    },
    "Il gesto è registrato. La pressione è cambiata.": {
        "it": "Il gesto è registrato. La pressione è cambiata.",
        "en": "The gesture is recorded. The pressure has changed.",
        "es": "El gesto queda registrado. La presión ha cambiado.",
    },
    "Il gesto pesa poco. La folla resta ferma.": {
        "it": "Il gesto pesa poco. La folla resta ferma.",
        "en": "The gesture carries little weight. The crowd remains still.",
        "es": "El gesto pesa poco. La multitud permanece inmóvil.",
    },
    "Scelta fatta. Ti valutano senza voce.": {
        "it": "Scelta fatta. Ti valutano senza voce.",
        "en": "Choice made. They judge you without a word.",
        "es": "Elección hecha. Te evalúan sin decir palabra.",
    },
    "Hai scelto il gesto. Ora spingono di più.": {
        "it": "Hai scelto il gesto. Ora spingono di più.",
        "en": "You chose the gesture. Now they press harder.",
        "es": "Has elegido el gesto. Ahora presionan más.",
    },
    "La folla ti segue. Vogliono il prossimo strappo.": {
        "it": "La folla ti segue. Vogliono il prossimo strappo.",
        "en": "The crowd follows you. They want the next rupture.",
        "es": "La multitud te sigue. Quiere el próximo desgarro.",
    },
    "Il gesto accende l'arena. Ti vogliono oltre.": {
        "it": "Il gesto accende l'arena. Ti vogliono oltre.",
        "en": "The gesture ignites the arena. They want you to go further.",
        "es": "El gesto enciende la arena. Quieren verte ir más allá.",
    },
    "Hai mosso la folla. Non fermarti ora.": {
        "it": "Hai mosso la folla. Non fermarti ora.",
        "en": "You stirred the crowd. Do not stop now.",
        "es": "Has agitado a la multitud. No te detengas ahora.",
    },
    "Un gesto debole. Ora ti strappano il rispetto.": {
        "it": "Un gesto debole. Ora ti strappano il rispetto.",
        "en": "A weak gesture. Now they tear away your standing.",
        "es": "Un gesto débil. Ahora te arrancan el respeto.",
    },
    "Il gesto è sterile. Ti tengono in debito.": {
        "it": "Il gesto è sterile. Ti tengono in debito.",
        "en": "The gesture is barren. They keep you in debt.",
        "es": "El gesto es estéril. Te mantienen en deuda.",
    },
    "Il gesto li accende, ma chiedono il crollo.": {
        "it": "Il gesto li accende, ma chiedono il crollo.",
        "en": "The gesture ignites them, but they demand your collapse.",
        "es": "El gesto los enciende, pero exigen tu caída.",
    },
    "IMPRIMI IL SIGILLO: TRE COLPI": {
        "it": "IMPRIMI IL SIGILLO: TRE COLPI",
        "en": "IMPRINT THE SEAL: THREE STRIKES",
        "es": "IMPRIME EL SELLO: TRES GOLPES",
    },
    "COLPISCI": {"it": "COLPISCI", "en": "STRIKE", "es": "GOLPEA"},
    "COLPISCI ANCORA": {
        "it": "COLPISCI ANCORA",
        "en": "STRIKE AGAIN",
        "es": "GOLPEA DE NUEVO",
    },
    "SIGILLATO": {"it": "SIGILLATO", "en": "SEALED", "es": "SELLADO"},
    "PRIMO COLPO - VERDETTO INCISO": {
        "it": "PRIMO COLPO - VERDETTO INCISO",
        "en": "FIRST STRIKE - VERDICT CARVED",
        "es": "PRIMER GOLPE - VEREDICTO INCISO",
    },
    "SECONDO COLPO - CONDANNA INCISA": {
        "it": "SECONDO COLPO - CONDANNA INCISA",
        "en": "SECOND STRIKE - SENTENCE CARVED",
        "es": "SEGUNDO GOLPE - SENTENCIA INCISA",
    },
    "TERZO COLPO - SIGILLO CHIUSO": {
        "it": "TERZO COLPO - SIGILLO CHIUSO",
        "en": "THIRD STRIKE - SEAL CLOSED",
        "es": "TERCER GOLPE - SELLO CERRADO",
    },
    "VERBALE INCISO - IL REGISTRO PUO AVANZARE": {
        "it": "VERBALE INCISO - IL REGISTRO PUO AVANZARE",
        "en": "RECORD CARVED - THE REGISTRY MAY ADVANCE",
        "es": "ACTA INCISA - EL REGISTRO PUEDE AVANZAR",
    },
}


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing OF-09 file: {path.relative_to(ROOT)}")
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


def _assert_assets_and_states() -> None:
    validate_family("judgment_seal")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    for state in STATES:
        token = f"sb_registry_judgment_seal_{state}.tres"
        if token not in scene:
            raise AssertionError(f"scene missing judgment seal state: {state}")
    block = _node_block(scene, "Btn_RESOLUTION_STRIKE")
    for token in (
        'custom_minimum_size = Vector2(360, 144)',
        'text = "COLPISCI"',
        'theme_override_styles/normal = ExtResource("64_registry_judgment_seal_normal")',
        'theme_override_styles/hover = ExtResource("65_registry_judgment_seal_focus")',
        'theme_override_styles/pressed = ExtResource("66_registry_judgment_seal_pressed")',
        'theme_override_styles/disabled = ExtResource("70_registry_judgment_seal_disabled")',
    ):
        if token not in block:
            raise AssertionError(f"Btn_RESOLUTION_STRIKE missing binding token: {token}")


def _assert_runtime() -> None:
    ui = _read(UI_ROOT)
    strike = _function_body(ui, "_on_resolve_ritual_strike_pressed")
    complete = _function_body(ui, "_complete_resolution_ritual_interaction")
    reset = _function_body(ui, "_reset_resolution_ritual_interaction")
    audience_context = _function_body(ui, "_on_audience_context_line_emitted")
    resolution_body = _function_body(ui, "_build_resolution_body")
    if "_pending_resolution_context_line = text.strip_edges()" not in audience_context:
        raise AssertionError("judgment audience context must retain its source localization key")
    if "tr(_pending_resolution_context_line.strip_edges())" not in resolution_body:
        raise AssertionError("judgment audience context must be localized when the ritual body is rendered")
    for forbidden in ("await ", "RunManager.", 'get_node_or_null("/root/RunManager")', "_on_request_ritual_advance("):
        if forbidden in strike or forbidden in complete:
            raise AssertionError(f"resolve ritual UI handler contains forbidden runtime token: {forbidden}")
    ordered = (
        "_apply_resolution_ritual_strike_feedback(on_beat)",
        "_complete_resolution_ritual_interaction()",
    )
    if not all(token in strike for token in ordered) or strike.index(ordered[0]) > strike.index(ordered[1]):
        raise AssertionError("strike handler must apply object state before completion")
    for token in (
        "_set_judgment_seal_state(RESOLUTION_RITUAL_STRIKES_REQUIRED)",
        "_judgment_seal_locked = true",
        '_play_sfx(&"registry_judgment_seal_resolve")',
        '_emit_game_event_signal_if_available(&"request_ritual_advance", ["resolve"])',
        "_start_judgment_seal_request_watchdog()",
    ):
        if token not in complete:
            raise AssertionError(f"complete handler missing token: {token}")
    if complete.index('_play_sfx(&"registry_judgment_seal_resolve")') > complete.index('_emit_game_event_signal_if_available(&"request_ritual_advance", ["resolve"])'):
        raise AssertionError("resolve cue must happen before emitting request_ritual_advance")
    for token in (
        "_reset_judgment_seal_state()",
        'resolve_ritual_strike_button.text = tr("COLPISCI")',
        "resolve_ritual_advance_button.visible = false",
    ):
        if token not in reset:
            raise AssertionError(f"reset handler missing token: {token}")
    for helper in (
        "_set_judgment_seal_state",
        "_reset_judgment_seal_state",
        "_recover_judgment_seal_request_lock",
        "_recover_judgment_seal_request_if_still_open",
    ):
        if f"func {helper}" not in ui:
            raise AssertionError(f"missing judgment seal helper: {helper}")


def _assert_audio() -> None:
    sfx_bus = _read(SFX_BUS)
    for cue in ("registry_judgment_seal_strike", "registry_judgment_seal_resolve"):
        if cue not in sfx_bus:
            raise AssertionError(f"SfxBus missing cue: {cue}")
        path = ROOT / f"assets/audio/sfx/{cue}.wav"
        with wave.open(str(path), "rb") as handle:
            if handle.getnchannels() != 1 or handle.getsampwidth() != 2 or handle.getframerate() != 44100:
                raise AssertionError(f"{cue}.wav must be mono PCM16 44.1 kHz")
            frames = handle.readframes(handle.getnframes())
            duration = handle.getnframes() / handle.getframerate()
        if cue.endswith("strike") and not 0.50 <= duration <= 0.75:
            raise AssertionError(f"{cue}.wav duration out of range: {duration:.3f}")
        if cue.endswith("resolve") and not 0.55 <= duration <= 0.85:
            raise AssertionError(f"{cue}.wav duration out of range: {duration:.3f}")
        samples = struct.unpack("<" + "h" * (len(frames) // 2), frames)
        peak = max(abs(value) for value in samples) / 32767.0
        if peak > 10 ** (-3.0 / 20):
            raise AssertionError(f"{cue}.wav peak exceeds -3 dBFS")


def _assert_localization() -> None:
    for key, translations in EXPECTED_COPY.items():
        for locale, expected in translations.items():
            actual = _csv_value(locale, key)
            if actual != expected:
                raise AssertionError(f"{locale} translation for {key!r}: expected {expected!r}, got {actual!r}")


def _assert_public_contracts() -> None:
    events = _read(GAME_EVENTS)
    run_manager = _read(RUN_MANAGER)
    marker = _read(MARKER)
    if "signal request_ritual_advance(kind: String)" not in events:
        raise AssertionError("GameEvents request_ritual_advance contract changed")
    if "func _on_request_ritual_advance(kind: String) -> void:" not in run_manager:
        raise AssertionError("RunManager resolve authority handler changed")
    if "_ritual_advance_resolve_requested = true" not in run_manager:
        raise AssertionError("RunManager resolve request authority changed")
    marker_value = next((line.strip() for line in marker.splitlines() if line.strip() and not line.lstrip().startswith("#")), "")
    if marker_value not in {"OF-09", "OF-11"}:
        raise AssertionError("judgment seal must remain covered by checkpoint OF-09 or its OF-11 successor")


def _assert_visual_qa() -> None:
    visual_qa = _read(VISUAL_QA)
    for token in (
        'const JUDGMENT_SEAL_SECTION: String = "judgment_seal"',
        '"06_judgment_%s_%dx%d"',
        "%s_normal",
        "%s_focus",
        "%s_strike_1",
        "%s_strike_2",
        "%s_resolved",
        "_capture_judgment_seal_matrix",
        "func _cleanup_capture_scene() -> void:",
        "_main.queue_free()",
        "ResourceLoader.CACHE_MODE_IGNORE",
        "_main_scene = null",
        'const CANONICAL_VISUAL_QA_SEED: String = "1782373819"',
        "_snapshot_and_neutralize_capture_environment()",
        "_enable_deterministic_run_seed()",
        "_enable_favorable_capture_outcome()",
        "_disable_capture_overrides()",
        "_center_judgment_panel_for_capture(viewport_size)",
        'OS.set_environment("GALLICUS_SMOKE_SCENARIO", "FULL_RUN")',
        "_restore_capture_environment()",
        'await _capture("08_end_run")',
    ):
        if token not in visual_qa:
            raise AssertionError(f"visual QA missing token: {token}")
    run_match = re.search(r"(?ms)^func _run\(\) -> void:.*?(?=^func |\Z)", visual_qa)
    if run_match is None:
        raise AssertionError("visual QA missing _run")
    run_body = run_match.group(0)
    strike_token = 'Btn_RESOLUTION_STRIKE", 4.0)'
    next_token = 'Btn_RESOLUTION_NEXT", 4.0)'
    push_luck_token = 'Phase_PUSH_YOUR_LUCK", true, 4.0)'
    if strike_token not in run_body or push_luck_token not in run_body:
        raise AssertionError("visual QA cumulative route must still strike the judgment seal and reach Push Your Luck")
    if next_token in run_body:
        raise AssertionError("visual QA cumulative route must not press Btn_RESOLUTION_NEXT after OF-09")
    if run_body.index(strike_token) > run_body.index(push_luck_token):
        raise AssertionError("visual QA cumulative route must strike the seal before waiting for Push Your Luck")
    seed_token = "_enable_deterministic_run_seed()"
    favorable_token = "_enable_favorable_capture_outcome()"
    if run_body.index(seed_token) > run_body.index('NewGameButton", 4.0)'):
        raise AssertionError("visual QA must fix the run seed before requesting a new run")
    if run_body.index(favorable_token) < run_body.index('Phase_RESOLUTION", true, 4.0)'):
        raise AssertionError("visual QA must not enable smoke outcome overrides before the resolve ritual opens")
    if run_body.index(favorable_token) > run_body.index(push_luck_token):
        raise AssertionError("visual QA must stabilize the outcome before waiting for Push Your Luck")
    cleanup_match = re.search(r"(?ms)^func _cleanup_capture_scene\(\) -> void:.*?(?=^func |\Z)", visual_qa)
    if cleanup_match is None or "_restore_capture_environment()" not in cleanup_match.group(0):
        raise AssertionError("visual QA cleanup must always restore the caller environment")


def main() -> None:
    _assert_assets_and_states()
    _assert_scene_binding()
    _assert_runtime()
    _assert_audio()
    _assert_localization()
    _assert_public_contracts()
    _assert_visual_qa()
    print("[OK][JUDGMENT_SEAL_OBJECT_CONTRACT] OF-09 judgment seal contract passed")


if __name__ == "__main__":
    main()
