"""Small offline DSP kit for tools/audio/compose.py (NumPy, SciPy, soundfile).

Everything works on float32 stereo arrays shaped (frames, 2) at SR.
"""
from fractions import Fraction
from pathlib import Path
import re

import numpy as np
import soundfile as sf
from scipy import signal

SR = 44100
NOTE_PC = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}

_cache_dir: Path | None = None
_loaded: dict = {}
_shifted: dict = {}


def set_cache(path: Path) -> None:
    global _cache_dir
    _cache_dir = path


def db(value: float) -> float:
    return 10.0 ** (value / 20.0)


def midi(name: str) -> int:
    match = re.fullmatch(r"([A-G]#?)(-?\d)", name)
    return 12 * (int(match.group(2)) + 1) + NOTE_PC[match.group(1)]


def silence(seconds: float) -> np.ndarray:
    return np.zeros((int(round(seconds * SR)), 2), dtype=np.float32)


def stereo(x: np.ndarray) -> np.ndarray:
    if x.ndim == 1:
        x = x[:, None]
    if x.shape[1] == 1:
        x = np.repeat(x, 2, axis=1)
    return x.astype(np.float32)


def load(key: str, trim: bool = True) -> np.ndarray:
    """A cached recording from the source cache, stereo at SR, head trimmed."""
    if (key, trim) in _loaded:
        return _loaded[(key, trim)]
    matches = [p for p in _cache_dir.iterdir() if p.stem == key]
    if len(matches) != 1:
        raise FileNotFoundError(key)
    data, rate = sf.read(str(matches[0]), always_2d=True, dtype="float32")
    data = stereo(data)
    if rate != SR:
        ratio = Fraction(SR, rate)
        data = signal.resample_poly(data, ratio.numerator, ratio.denominator, axis=0).astype(np.float32)
    data = data - data.mean(axis=0)
    if trim:
        data = trim_head(data)
    _loaded[(key, trim)] = data
    return data


def trim_head(x: np.ndarray, threshold_db: float = -42.0) -> np.ndarray:
    level = np.abs(x).max(axis=1)
    peak = level.max()
    if peak <= 0:
        return x
    start = int(np.argmax(level > peak * db(threshold_db)))
    start = max(0, start - int(0.002 * SR))
    out = x[start:].copy()
    return fade(out, 0.002, 0.0)


def fade(x: np.ndarray, fade_in: float, fade_out: float) -> np.ndarray:
    x = x.copy()
    n_in = min(len(x), int(fade_in * SR))
    n_out = min(len(x), int(fade_out * SR))
    if n_in > 0:
        x[:n_in] *= np.sin(np.linspace(0, np.pi / 2, n_in))[:, None] ** 2
    if n_out > 0:
        x[-n_out:] *= np.cos(np.linspace(0, np.pi / 2, n_out))[:, None] ** 2
    return x


def cut(x: np.ndarray, seconds: float, release: float = 0.08) -> np.ndarray:
    """Hold a note for `seconds`, then release it with a short fade."""
    n = min(len(x), int((seconds + release) * SR))
    return fade(x[:n], 0.0, min(release, n / SR))


def pitch(x: np.ndarray, semitones: float) -> np.ndarray:
    """Varispeed pitch shift (length changes, like a tape or a sampler)."""
    if abs(semitones) < 1e-4:
        return x
    factor = 2.0 ** (semitones / 12.0)
    if factor > 1.0:
        x = lowpass(x, min(0.45 * SR / factor, 20000), order=4)
    n = int(len(x) / factor)
    source = np.arange(n) * factor
    out = np.empty((n, 2), dtype=np.float32)
    for channel in range(2):
        out[:, channel] = np.interp(source, np.arange(len(x)), x[:, channel])
    return out


def shifted(key: str, semitones: float) -> np.ndarray:
    tag = (key, round(semitones, 3))
    if tag not in _shifted:
        _shifted[tag] = pitch(load(key), semitones)
    return _shifted[tag]


def _sos(kind: str, freq, order: int):
    return signal.butter(order, freq, kind, fs=SR, output="sos")


def lowpass(x: np.ndarray, freq: float, order: int = 2) -> np.ndarray:
    return signal.sosfilt(_sos("lowpass", freq, order), x, axis=0).astype(np.float32)


def highpass(x: np.ndarray, freq: float, order: int = 2) -> np.ndarray:
    return signal.sosfilt(_sos("highpass", freq, order), x, axis=0).astype(np.float32)


def bandpass(x: np.ndarray, low: float, high: float, order: int = 2) -> np.ndarray:
    return signal.sosfilt(_sos("bandpass", [low, high], order), x, axis=0).astype(np.float32)


def peak_eq(x: np.ndarray, freq: float, gain_db: float, q: float = 1.0) -> np.ndarray:
    a = db(gain_db / 2)
    w0 = 2 * np.pi * freq / SR
    alpha = np.sin(w0) / (2 * q)
    b = [1 + alpha * a, -2 * np.cos(w0), 1 - alpha * a]
    den = [1 + alpha / a, -2 * np.cos(w0), 1 - alpha / a]
    return signal.lfilter(b, den, x, axis=0).astype(np.float32)


def balance(x: np.ndarray, pan: float) -> np.ndarray:
    """Pan a stereo source: -1 left, +1 right, constant power."""
    angle = (np.clip(pan, -1, 1) + 1) * np.pi / 4
    gains = np.array([np.cos(angle), np.sin(angle)], dtype=np.float32) * np.sqrt(2)
    return x * gains


def width(x: np.ndarray, amount: float) -> np.ndarray:
    mid = (x[:, 0] + x[:, 1]) * 0.5
    side = (x[:, 0] - x[:, 1]) * 0.5 * amount
    return np.stack([mid + side, mid - side], axis=1).astype(np.float32)


def room_ir(t60: float, seconds: float, damp_hz: float, seed: int, predelay: float = 0.012) -> np.ndarray:
    """A synthetic stone-hall impulse: early taps plus a darkening noise tail."""
    rng = np.random.default_rng(seed)
    n = int(seconds * SR)
    t = np.arange(n) / SR
    noise = rng.standard_normal((n, 2)).astype(np.float32)
    bright = noise
    dark = lowpass(noise, damp_hz, order=2)
    blend = (1 - np.exp(-t / 0.35))[:, None]
    tail = (bright * (1 - blend) + dark * blend) * np.exp(-6.91 * t / t60)[:, None]
    tail[: int(predelay * SR)] = 0
    for delay, gain in [(0.011, 0.5), (0.019, 0.35), (0.031, 0.3), (0.047, 0.22), (0.063, 0.18)]:
        index = int(delay * SR)
        tail[index, 0] += gain * rng.choice([-1, 1])
        tail[index + int(0.0017 * SR), 1] += gain * rng.choice([-1, 1])
    tail /= np.sqrt((tail ** 2).sum(axis=0)).max()
    return tail.astype(np.float32)


def convolve(x: np.ndarray, ir: np.ndarray) -> np.ndarray:
    out = np.stack([signal.fftconvolve(x[:, c], ir[:, c]) for c in range(2)], axis=1)
    return out.astype(np.float32)


class Bus:
    """A timeline: place sounds at times, render with an optional reverb send."""

    def __init__(self, seconds: float, tail: float = 0.0):
        self.length = int(round(seconds * SR))
        self.tail = int(round(tail * SR))
        self.dry = np.zeros((self.length + self.tail + SR, 2), dtype=np.float32)
        self.send = np.zeros_like(self.dry)

    def add(self, x: np.ndarray, at: float, gain_db: float = 0.0, pan: float = 0.0, send_db: float | None = None) -> None:
        start = int(round(at * SR))
        if start < 0:
            # A note pushed before the downbeat belongs to the end of the loop.
            start += self.length
        end = min(len(self.dry), start + len(x))
        if end <= start:
            return
        piece = balance(x[: end - start], pan) * db(gain_db)
        self.dry[start:end] += piece
        if send_db is not None:
            self.send[start:end] += piece * db(send_db)

    def render(self, ir: np.ndarray | None = None, loop: bool = False) -> np.ndarray:
        out = self.dry.copy()
        if ir is not None and np.any(self.send):
            wet = convolve(self.send, ir)
            out = np.pad(out, ((0, max(0, len(wet) - len(out))), (0, 0)))
            out[: len(wet)] += wet
        if loop:
            # Fold everything past the loop point back onto the start, so
            # tails ring across the seam and the loop has no audible edit.
            body = out[: self.length].copy()
            rest = out[self.length:]
            for offset in range(0, len(rest), self.length):
                chunk = rest[offset: offset + self.length]
                body[: len(chunk)] += chunk
            return body
        return out


def lufs(x: np.ndarray) -> float:
    import pyloudnorm
    meter = pyloudnorm.Meter(SR)
    padded = x if len(x) >= SR else np.pad(x, ((0, SR - len(x)), (0, 0)))
    value = meter.integrated_loudness(padded.astype(np.float64))
    if not np.isfinite(value):
        # Very short or very quiet cues: fall back to K-free RMS.
        rms = np.sqrt(np.mean(padded ** 2)) + 1e-12
        value = 20 * np.log10(rms) - 0.691
    return float(value)


def to_lufs(x: np.ndarray, target: float) -> np.ndarray:
    return (x * db(target - lufs(x))).astype(np.float32)


def soft_limit(x: np.ndarray, ceiling_db: float = -1.0) -> np.ndarray:
    """Gentle tanh knee above the ceiling; leaves quieter material untouched."""
    ceiling = db(ceiling_db)
    knee = ceiling * 0.7
    out = x.copy()
    over = np.abs(out) > knee
    excess = (np.abs(out[over]) - knee) / (ceiling - knee)
    out[over] = np.sign(out[over]) * (knee + (ceiling - knee) * np.tanh(excess))
    return out.astype(np.float32)


def peak_to(x: np.ndarray, peak_db: float) -> np.ndarray:
    peak = np.abs(x).max()
    return x if peak <= 0 else (x * db(peak_db) / peak).astype(np.float32)


def sustain(x: np.ndarray, seconds: float, seed: int, grain: float = 0.6, start: float = 0.35, end_margin: float = 0.6) -> np.ndarray:
    """Stretch a held note into a long tone by overlapping grains of its body."""
    rng = np.random.default_rng(seed)
    body = x[int(start * SR): max(int(start * SR) + int(grain * SR) + 1, len(x) - int(end_margin * SR))]
    g = int(grain * SR)
    hop = g // 2
    window = np.hanning(g).astype(np.float32)[:, None]
    n = int(seconds * SR)
    out = np.zeros((n + g, 2), dtype=np.float32)
    for position in range(0, n, hop):
        offset = int(rng.integers(0, max(1, len(body) - g)))
        grain_audio = body[offset: offset + g]
        if len(grain_audio) < g:
            grain_audio = np.pad(grain_audio, ((0, g - len(grain_audio)), (0, 0)))
        out[position: position + g] += grain_audio * window
    return out[:n]


def write_wav(path: Path, x: np.ndarray, mono: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data = x.mean(axis=1) if mono else x
    data = np.clip(data, -1, 1)
    sf.write(str(path), data, SR, subtype="PCM_16")


def write_ogg(path: Path, x: np.ndarray, quality: int = 5) -> None:
    """Vorbis through ffmpeg (libsndfile's Vorbis writer is unreliable on long files)."""
    import subprocess
    import tempfile
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as temp:
        source = Path(temp) / "master.wav"
        sf.write(str(source), np.clip(x, -1, 1), SR, subtype="FLOAT")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(source), "-c:a", "libvorbis",
                        "-q:a", str(quality), "-map_metadata", "-1", "-fflags", "+bitexact", str(path)], check=True)
