"""Validate non-runtime MV review images, layers and audio prototypes."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

from PIL import Image


SLICE_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = Path(__file__).resolve().parents[4]


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def _verify_concepts() -> None:
    concepts = sorted((SLICE_DIR / "concepts").glob("mv02_direction_*.png"))
    _require(len(concepts) == 4, "MV02 must keep exactly four review directions")
    for path in concepts:
        with Image.open(path) as image:
            width, height = image.size
            _require(width >= 1280 and height >= 720, f"undersized concept: {path.name}")
            _require(abs(width / height - 16 / 9) < 0.02, f"non-16:9 concept: {path.name}")


def _verify_selected_visuals() -> None:
    selected_dir = SLICE_DIR / "selected_preview"
    required = {
        "mv02_selected_hero_1920x1080.png": "RGB",
        "mv02_selected_composite_1920x1080.png": "RGB",
        "mv02_light_overlay_1920x1080.png": "RGBA",
        "mv02_fog_overlay_1920x1080.png": "RGBA",
        "mv02_dust_overlay_1920x1080.png": "RGBA",
        "mv02_vignette_overlay_1920x1080.png": "RGBA",
    }
    for name, expected_mode in required.items():
        path = selected_dir / name
        _require(path.is_file(), f"missing selected visual: {name}")
        with Image.open(path) as image:
            _require(image.size == (1920, 1080), f"wrong dimensions: {name}")
            _require(image.mode == expected_mode, f"wrong image mode: {name}")
            if expected_mode == "RGBA":
                alpha = image.getchannel("A")
                minimum, maximum = alpha.getextrema()
                _require(minimum < maximum, f"flat alpha channel: {name}")


def _read_peak(path: Path) -> tuple[wave.Wave_read, float]:
    wav = wave.open(str(path), "rb")
    raw = wav.readframes(wav.getnframes())
    values = struct.unpack("<" + "h" * (len(raw) // 2), raw)
    peak = max(abs(value) for value in values) / 32_767
    return wav, peak


def _verify_audio() -> None:
    expected_durations = {
        "mv04_stone_drone_48s.wav": 48.0,
        "mv04_bronze_pulse_48s.wav": 48.0,
        "mv04_breath_air_48s.wav": 48.0,
        "mv04_opening_mix_preview_48s.wav": 48.0,
        "mv04_registry_ambience_loop_36s.wav": 36.0,
        "mv04_threshold_activation_1_5s.wav": 1.5,
        "mv04_registry_reveal_2_2s.wav": 2.2,
    }
    audio_dir = SLICE_DIR / "audio_prototypes"
    for name, expected_duration in expected_durations.items():
        path = audio_dir / name
        _require(path.is_file(), f"missing audio prototype: {name}")
        wav, peak = _read_peak(path)
        with wav:
            duration = wav.getnframes() / wav.getframerate()
            _require(wav.getnchannels() == 1, f"audio must be mono: {name}")
            _require(wav.getsampwidth() == 2, f"audio must be PCM16: {name}")
            _require(wav.getframerate() == 44_100, f"audio must be 44.1 kHz: {name}")
            _require(abs(duration - expected_duration) < 0.001, f"wrong duration: {name}")
        peak_db = 20.0 * math.log10(peak)
        _require(-3.05 <= peak_db <= -2.95, f"audio peak is not -3 dBFS: {name}")


def _verify_not_runtime_referenced() -> None:
    needles = ("docs/support/media_vertical_slice", "docs\\support\\media_vertical_slice")
    suffixes = {".gd", ".tscn", ".tres", ".godot"}
    offenders: list[str] = []
    for path in REPO_ROOT.rglob("*"):
        if not path.is_file() or path.suffix not in suffixes:
            continue
        if ".godot" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if any(needle in text for needle in needles):
            offenders.append(path.relative_to(REPO_ROOT).as_posix())
    _require(not offenders, "review assets referenced by runtime: " + ", ".join(offenders))


def main() -> None:
    _verify_concepts()
    _verify_selected_visuals()
    _verify_audio()
    _verify_not_runtime_referenced()
    print("MEDIA_VERTICAL_SLICE_PREP:OK")


if __name__ == "__main__":
    main()
