#!/usr/bin/env python3
"""Static OF-09 resources, public signals and localization integrity.

Input, locks, responses and motion run in judgment_runtime_contract.gd.
This file deliberately does not inspect private GDScript function bodies.
"""
from __future__ import annotations

import csv
import re
import struct
import wave
from collections import Counter
from pathlib import Path
from generated_art_contract import validate_family

ROOT = Path(__file__).resolve().parents[2]
SCENE = ROOT / "scenes/UI.tscn"
SFX_BUS = ROOT / "scripts/audio/sfx_bus.gd"
GAME_EVENTS = ROOT / "scripts/systems/game_events.gd"
STATES = ("normal", "focus", "pressed", "strike_1", "strike_2", "resolved", "disabled")
LOCALIZATION_KEYS = (
    'RITO DI GIUDIZIO',
    'Il Registro pesa il patto.',
    'Ogni colpo mette alla prova la cera.',
    'Tre colpi chiudono il verbale.',
    'Il tuo gesto li irrita. Ora vogliono il prezzo.',
    'Hai mostrato il fianco. Ti puniscono col silenzio.',
    'Un gesto non basta. Vogliono vederti cedere.',
    'Ti sei esposto. Ti vogliono spezzare.',
    'Un gesto segnato, il debito resta.',
    'Il gesto è registrato. La pressione è cambiata.',
    'Il gesto pesa poco. La folla resta ferma.',
    'Scelta fatta. Ti valutano senza voce.',
    'Hai scelto il gesto. Ora spingono di più.',
    'La folla ti segue. Vogliono il prossimo strappo.',
    "Il gesto accende l'arena. Ti vogliono oltre.",
    'Hai mosso la folla. Non fermarti ora.',
    'Un gesto debole. Ora ti strappano il rispetto.',
    'Il gesto è sterile. Ti tengono in debito.',
    'Il gesto li accende, ma chiedono il crollo.',
    'IMPRIMI IL SIGILLO',
    'ALZA LA MANO',
    'COLPISCI',
    'COLPISCI ANCORA',
    'SIGILLATO',
    'IL SIGILLO REGGE - COLPISCI ANCORA O ALZA LA MANO',
    'LA CERA SI INCRINA - IL SIGILLO CEDE',
    'VERBALE INCISO - IL REGISTRO PUÒ AVANZARE',
)


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _assert_assets_and_states() -> None:
    validate_family("judgment_seal")


def _assert_scene_binding() -> None:
    scene = _read(SCENE)
    resources = dict(re.findall(r'\[ext_resource[^\n]*path="([^"]+)"[^\n]*id="([^"]+)"\]', scene))
    by_id = {identity: path for path, identity in resources.items()}
    match = re.search(r'^\[node name="Btn_RESOLUTION_STRIKE"[^\n]*\]\n(.*?)(?=^\[node |\Z)', scene, re.M | re.S)
    if match is None:
        raise AssertionError("missing judgment input Control")
    for state in STATES:
        path = f"res://assets/ui/official/objects/judgment_seal/sb_registry_judgment_seal_{state}.tres"
        if path not in resources or not (ROOT / path.removeprefix("res://")).is_file():
            raise AssertionError(f"missing judgment skin: {state}")
    # Bind by the resource's path, allowing Godot to renumber its local IDs.
    for slot, state in {"normal": "normal", "hover": "focus", "pressed": "pressed", "disabled": "disabled"}.items():
        binding = re.search(rf'theme_override_styles/{slot} = ExtResource\("([^"]+)"\)', match.group(1))
        if binding is None or not by_id.get(binding[1], "").endswith(f"/sb_registry_judgment_seal_{state}.tres"):
            raise AssertionError(f"judgment skin not bound to {slot}")


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
    # Localized wording may evolve. Keys, nonempty values and formatting may not.
    placeholders = lambda text: Counter(re.findall(r"%(?:[0-9]+\$)?[-+0-9.]*[sdf]", text.replace("%%", "")))
    for locale in ("it", "en", "es"):
        with (ROOT / f"assets/i18n/{locale}.csv").open(encoding="utf-8", newline="") as handle:
            rows = list(csv.reader(handle))[1:]
        for key in LOCALIZATION_KEYS:
            values = [row[1] for row in rows if len(row) == 2 and row[0] == key]
            if len(values) != 1 or not values[0].strip():
                raise AssertionError(f"{locale}: missing, duplicate or empty judgment key {key!r}")
            if placeholders(values[0]) != placeholders(key):
                raise AssertionError(f"{locale}: judgment placeholders changed for {key!r}")
    # These three CTAs are explicitly specified in UI_CANON's seal contract.
    for locale, cta in {"it": "COLPISCI", "en": "STRIKE", "es": "GOLPEA"}.items():
        with (ROOT / f"assets/i18n/{locale}.csv").open(encoding="utf-8", newline="") as handle:
            if dict(csv.reader(handle)).get("COLPISCI") != cta:
                raise AssertionError(f"{locale}: canonical seal CTA changed")


def _assert_public_contracts() -> None:
    events = _read(GAME_EVENTS)
    for signature in ("signal seal_strike_resolved(payload: Dictionary)", "signal request_ritual_advance(kind: String)"):
        if signature not in events:
            raise AssertionError(f"public judgment contract changed: {signature}")


def main() -> None:
    _assert_assets_and_states()
    _assert_scene_binding()
    _assert_audio()
    _assert_localization()
    _assert_public_contracts()
    print("[OK][JUDGMENT_SEAL_OBJECT_CONTRACT] static resources and public contracts passed")


if __name__ == "__main__":
    main()
