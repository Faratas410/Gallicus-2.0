from __future__ import annotations

import math
import random
import wave
from pathlib import Path


RATE = 44_100
PEAK = 10 ** (-3.0 / 20.0)
ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "audio" / "sfx"


def _noise(rng: random.Random) -> float:
    return rng.uniform(-1.0, 1.0)


def _envelope(time: float, attack: float, decay: float) -> float:
    if time < 0.0 or time >= decay:
        return 0.0
    return min(1.0, time / max(attack, 0.0001)) * math.exp(-4.2 * time / decay)


def _write(name: str, duration: float, samples: list[float]) -> None:
    maximum = max(abs(sample) for sample in samples) or 1.0
    scale = min(PEAK / maximum, 1.0)
    pcm = bytearray()
    for sample in samples:
        value = int(max(-1.0, min(1.0, sample * scale)) * 32767.0)
        pcm.extend(value.to_bytes(2, byteorder="little", signed=True))
    path = OUTPUT / name
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes(bytes(pcm))
    print(f"{path}: {duration:.3f}s peak={20.0 * math.log10(max(abs(sample * scale) for sample in samples)):.2f}dBFS")


def build_placa() -> None:
    duration = 0.68
    rng = random.Random(70601)
    samples: list[float] = []
    lowpass = 0.0
    breath = 0.0
    for index in range(round(duration * RATE)):
        time = index / RATE
        settle = _envelope(time, 0.006, 0.34) * (
            0.62 * math.sin(2.0 * math.pi * 92.0 * time)
            + 0.26 * math.sin(2.0 * math.pi * 143.0 * time)
        )
        lowpass += 0.16 * (_noise(rng) - lowpass)
        sand_time = time - 0.035
        sand = 0.24 * _envelope(sand_time, 0.018, 0.48) * lowpass
        breath += 0.025 * (_noise(rng) - breath)
        crowd_time = time - 0.18
        crowd = 0.18 * _envelope(crowd_time, 0.08, 0.48) * breath
        samples.append(settle + sand + crowd)
    _write("arena_gesture_placa.wav", duration, samples)


def build_provoca() -> None:
    duration = 0.76
    rng = random.Random(70802)
    samples: list[float] = []
    scrape = 0.0
    crowd = 0.0
    for index in range(round(duration * RATE)):
        time = index / RATE
        scrape += 0.31 * (_noise(rng) - scrape)
        dry_scrape = 0.46 * _envelope(time, 0.012, 0.30) * scrape * (0.7 + 0.3 * math.sin(2.0 * math.pi * 39.0 * time))
        strike_time = time - 0.20
        strike = _envelope(strike_time, 0.003, 0.25) * (
            0.66 * math.sin(2.0 * math.pi * 118.0 * strike_time)
            + 0.34 * math.sin(2.0 * math.pi * 236.0 * strike_time)
        )
        ring_time = time - 0.215
        ring = 0.28 * _envelope(ring_time, 0.004, 0.49) * math.sin(2.0 * math.pi * 734.0 * ring_time)
        crowd += 0.035 * (_noise(rng) - crowd)
        crowd_time = time - 0.36
        reaction = 0.22 * _envelope(crowd_time, 0.05, 0.36) * crowd
        samples.append(dry_scrape + strike + ring + reaction)
    _write("arena_gesture_provoca.wav", duration, samples)


if __name__ == "__main__":
    OUTPUT.mkdir(parents=True, exist_ok=True)
    build_placa()
    build_provoca()
