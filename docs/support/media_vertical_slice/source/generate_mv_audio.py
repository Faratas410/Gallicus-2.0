"""Generate deterministic review-only audio prototypes for the MV media slice."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
OUTPUT_DIR = Path(__file__).resolve().parents[1] / "audio_prototypes"
TARGET_PEAK = 10 ** (-3.0 / 20.0)


def _sine(frequency: float, time_s: float, phase: float = 0.0) -> float:
    return math.sin(math.tau * frequency * time_s + phase)


def _soft_clip(value: float) -> float:
    return math.tanh(value * 1.15) / math.tanh(1.15)


def _normalize(samples: list[float], target: float = TARGET_PEAK) -> list[float]:
    shaped = [_soft_clip(sample) for sample in samples]
    peak = max((abs(sample) for sample in shaped), default=0.0)
    if peak <= 1e-9:
        return shaped
    gain = target / peak
    return [sample * gain for sample in shaped]


def _write_mono(name: str, samples: list[float]) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    path = OUTPUT_DIR / name
    normalized = _normalize(samples)
    frames = bytearray()
    for sample in normalized:
        pcm = int(max(-1.0, min(1.0, sample)) * 32_767)
        frames.extend(struct.pack("<h", pcm))
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(frames)


def _render(duration_s: float, sample_fn) -> list[float]:
    count = round(duration_s * SAMPLE_RATE)
    return [sample_fn(index / SAMPLE_RATE) for index in range(count)]


def _periodic_air(duration_s: float, seed: int, amplitude: float) -> list[float]:
    randomizer = random.Random(seed)
    components: list[tuple[float, float, float]] = []
    for _ in range(22):
        cycles = randomizer.randint(120, 3_200)
        frequency = cycles / duration_s
        phase = randomizer.uniform(0.0, math.tau)
        weight = randomizer.uniform(0.25, 1.0) / math.sqrt(frequency)
        components.append((frequency, phase, weight))
    weight_sum = sum(weight for _, _, weight in components)

    def sample(time_s: float) -> float:
        air = sum(weight * _sine(frequency, time_s, phase) for frequency, phase, weight in components)
        slow = 0.55 + 0.25 * _sine(0.125, time_s, 0.7) + 0.12 * _sine(0.0625, time_s, 2.2)
        return amplitude * slow * air / weight_sum

    return _render(duration_s, sample)


def _stone_drone(duration_s: float) -> list[float]:
    def sample(time_s: float) -> float:
        breathing = 0.72 + 0.12 * _sine(0.125, time_s, 1.1)
        body = 0.62 * _sine(55.0, time_s)
        body += 0.24 * _sine(82.5, time_s, 0.4)
        body += 0.10 * _sine(110.0, time_s, 1.5)
        body += 0.05 * _sine(165.0, time_s, 2.1)
        return 0.55 * breathing * body

    return _render(duration_s, sample)


def _bronze_pulse(duration_s: float) -> list[float]:
    pulse_times = [3.0 + 6.0 * index for index in range(8)]

    def sample(time_s: float) -> float:
        value = 0.0
        for pulse_time in pulse_times:
            age = time_s - pulse_time
            if age < 0.0 or age > 3.2:
                continue
            attack = min(1.0, age / 0.018)
            decay = math.exp(-age * 1.65)
            ring = 0.63 * _sine(233.0, age)
            ring += 0.25 * _sine(311.0, age, 0.3)
            ring += 0.12 * _sine(466.0, age, 1.1)
            value += attack * decay * ring
        return 0.48 * value

    return _render(duration_s, sample)


def _mix(stems: list[tuple[list[float], float]]) -> list[float]:
    length = min(len(samples) for samples, _ in stems)
    return [sum(samples[index] * gain for samples, gain in stems) for index in range(length)]


def _impact(duration_s: float, reveal: bool) -> list[float]:
    randomizer = random.Random(410 if reveal else 205)
    noise = [randomizer.uniform(-1.0, 1.0) for _ in range(round(duration_s * SAMPLE_RATE))]
    smoothed = 0.0
    for index, value in enumerate(noise):
        smoothed = smoothed * 0.86 + value * 0.14
        noise[index] = smoothed

    def sample(index: int) -> float:
        time_s = index / SAMPLE_RATE
        hit = math.exp(-time_s * (4.4 if reveal else 6.2))
        low = 0.58 * _sine(64.0 if reveal else 72.0, time_s)
        metal = 0.20 * _sine(277.0 if reveal else 214.0, time_s, 0.3)
        metal += 0.12 * _sine(415.0 if reveal else 321.0, time_s, 1.0)
        grit = noise[index] * math.exp(-time_s * 11.0)
        swell = 0.0
        if reveal:
            reveal_age = max(0.0, time_s - 0.42)
            swell = min(1.0, reveal_age / 0.45) * math.exp(-reveal_age * 0.55) * _sine(92.0, reveal_age)
        return hit * (low + metal + 0.28 * grit) + 0.22 * swell

    return [sample(index) for index in range(len(noise))]


def main() -> None:
    score_duration = 48.0
    stone = _stone_drone(score_duration)
    bronze = _bronze_pulse(score_duration)
    air = _periodic_air(score_duration, seed=46_202, amplitude=0.72)
    preview = _mix([(stone, 0.72), (bronze, 0.62), (air, 0.78)])

    ambience_duration = 36.0
    ambience_air = _periodic_air(ambience_duration, seed=36_410, amplitude=0.86)
    ambience_low = _render(
        ambience_duration,
        lambda time_s: 0.18 * _sine(49.0, time_s) + 0.08 * _sine(73.5, time_s, 0.8),
    )
    ambience = _mix([(ambience_air, 0.88), (ambience_low, 0.62)])

    _write_mono("mv04_stone_drone_48s.wav", stone)
    _write_mono("mv04_bronze_pulse_48s.wav", bronze)
    _write_mono("mv04_breath_air_48s.wav", air)
    _write_mono("mv04_opening_mix_preview_48s.wav", preview)
    _write_mono("mv04_registry_ambience_loop_36s.wav", ambience)
    _write_mono("mv04_threshold_activation_1_5s.wav", _impact(1.5, reveal=False))
    _write_mono("mv04_registry_reveal_2_2s.wav", _impact(2.2, reveal=True))


if __name__ == "__main__":
    main()
