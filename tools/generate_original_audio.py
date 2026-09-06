"""Original Gallicus score and material foley. Offline build tool; requires NumPy.

No recordings, sample packs or external melodies. Stable seeds and authored
modal synthesis produce the checked-in WAV files. Runtime never runs this tool.
"""
from pathlib import Path
import hashlib
import json
import math
import re
import wave
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets/audio/original"
SFX = ROOT / "assets/audio/sfx"


def write_audio(path, samples, rate, peak_db, role, recipe):
    samples = samples - np.mean(samples, axis=0)
    ramp = min(int(rate * .008), len(samples) // 4)
    envelope = np.ones(len(samples))
    envelope[:ramp] = np.linspace(0, 1, ramp)
    envelope[-ramp:] = np.linspace(1, 0, ramp)
    samples *= envelope[:, None] if samples.ndim == 2 else envelope
    samples *= 10 ** (peak_db / 20) / max(float(np.max(np.abs(samples))), 1e-10)
    pcm = np.round(samples * 32767).astype("<i2")
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as wav:
        wav.setparams((2 if pcm.ndim == 2 else 1, 2, rate, len(pcm), "NONE", "not compressed"))
        wav.writeframes(pcm.tobytes())
    return {"path": "res://" + path.relative_to(ROOT).as_posix(), "role": role,
            "recipe": recipe, "seconds": len(pcm) / rate, "sample_rate": rate,
            "channels": 2 if pcm.ndim == 2 else 1,
            "peak_dbfs": round(20 * math.log10(max(np.max(np.abs(pcm.astype(float))) / 32768, 1e-10)), 3),
            "rms_dbfs": round(20 * math.log10(max(np.sqrt(np.mean((pcm.astype(float)/32768)**2)), 1e-10)), 3),
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def colored_noise(count, rate, rng, low, high):
    frequencies = np.fft.rfftfreq(count, 1 / rate)
    spectrum = np.fft.rfft(rng.normal(size=count))
    gain = np.minimum(1, (frequencies / low)**2) / (1 + (frequencies / high)**4)
    signal = np.fft.irfft(spectrum * gain, n=count)
    return signal / max(np.std(signal), 1e-10)


def score(index):
    rate, seconds = 22050, 48
    rng = np.random.default_rng(61000 + index)
    mix = np.zeros((rate * seconds, 2))
    # Open D/A sonority, airy middle register, no bass drone or dissonant riser.
    phrases = [
        [62, 69, 74, 76, 69, 67, 74, 69],
        [62, 67, 69, 74, 69, 64, 67, 69],
        [69, 74, 64, 67, 74, 69, 62, 67],
        [62, 69, 76, 74, 67, 69, 64, 62],
        [74, 69, 67, 62, 69, 64, 62, 69],
    ]
    for step, midi in enumerate(phrases[index]):
        start = int((1.5 + step * 5.3) * rate)
        t = np.arange(int(5.0 * rate)) / rate
        hz = 440 * 2**((midi-69)/12)
        body = sum(np.sin(2*np.pi*hz*h*t + .08*np.sin(2*np.pi*.23*t)) * a * np.exp(-t/(2.3/h))
                   for h,a in [(1,1), (2,.22), (3,.07), (4,.02)])
        body *= (1-np.exp(-t*32)) * np.minimum(1, (5-t)*2)
        pan = .24 * math.sin(step * 1.7)
        add = body[:,None] * np.array([math.sqrt((1-pan)/2), math.sqrt((1+pan)/2)]) * .13
        # Sparse paired resonance; each phrase has room to decay.
        stop = min(start+len(add),len(mix)); mix[start:stop] += add[:stop-start]
    t = np.arange(len(mix)) / rate
    for hz,amp in [(146.832,.028),(220.0,.018),(293.665,.012)]:
        breath = np.sin(np.pi*t/seconds)**2 * (.55+.45*np.sin(2*np.pi*t/16)**2)
        for ch,detune in enumerate([-.08,.08]):
            mix[:,ch] += amp*np.sin(2*np.pi*(hz+detune)*t)*breath
    for ch in range(2):
        mix[:,ch] += colored_noise(len(t),rate,rng,300,1700)*.002*np.sin(np.pi*t/seconds)**2
    # A short, quiet room, not a large ominous hall.
    dry=mix.copy()
    for delay,gain in [(.113,.17),(.237,.10),(.389,.045)]:
        shift=int(delay*rate); mix[shift:] += dry[:-shift,::-1]*gain
    mix *= np.minimum(1,t/1.2)[:,None]*np.minimum(1,(seconds-t)/2.4)[:,None]
    return mix,rate


def foley(name, index):
    rate=44100
    seconds = .64
    if name in ("button_hover", "cursor_move"): seconds=.10
    if name in ("button_click", "cursor_select"): seconds=.18
    if name == "registry_dossier_route": seconds=.54
    if name == "registry_dossier_update": seconds=.54
    if name == "registry_promise_sign": seconds=.58
    if name == "registry_pact_validate": seconds=.66
    if name == "registry_table_open": seconds=.72
    if name == "registry_receipt_take": seconds=.54
    rng=np.random.default_rng(62000+index)
    t=np.arange(int(rate*seconds))/rate
    paper=any(word in name for word in ("dossier", "receipt", "hover", "move"))
    scratch=any(word in name for word in ("incision", "promise", "provoca"))
    base=310 if paper else 190 if scratch else 130
    signal=np.zeros(len(t))
    # Inharmonic modes imitate a small stone/bronze object, with damped highs.
    for ratio,amp in [(1,1),(1.47,.28),(2.09,.13),(3.31,.04)]:
        signal += amp*np.sin(2*np.pi*(base+index*2.1)*ratio*t)*np.exp(-t*(12+ratio*5))
    noise=colored_noise(len(t),rate,rng,400,2300 if paper else 1500)
    envelope=np.sin(np.pi*np.minimum(t/(seconds*.72),1))**2
    if scratch:
        envelope*=.55+.45*np.sin(t*79)**2
    signal=signal*(.11 if paper else .32)+noise*envelope*(.11 if paper or scratch else .035)
    if "second_incision" in name:
        shift=int(rate*.16); signal[shift:]+=signal[:-shift].copy()*.48
    signal *= (1-np.exp(-t*700)) * np.minimum(1,(seconds-t)*12)
    return signal,rate,"fiber" if paper else "stylus and wax" if scratch else "damped stone and bronze"


def main():
    entries=[]
    for i,name in enumerate(["atrium","registry","inscription","threshold","dossier"]):
        data,rate=score(i)
        entries.append(write_audio(OUTPUT/(name+".wav"),data,rate,-12,"music","authored open D/A modal phrase, lyre-like resonances and filtered air; seed "+str(61000+i)))
    source=(ROOT/"scripts/audio/sfx_bus.gd").read_text(encoding="utf-8")
    names=sorted(set(re.findall(r'res://assets/audio/sfx/([a-z_]+)\.wav',source)))
    assert len(names)==25, names
    for i,name in enumerate(names):
        data,rate,material=foley(name,i)
        entries.append(write_audio(SFX/(name+".wav"),data,rate,-12 if name in ("button_hover","cursor_move") else -8,"sfx",material+"; seed "+str(62000+i)))
    rate=24000; t=np.arange(rate*3)/rate
    def pulse(offset):
        local=t-offset; clipped=np.clip(local,0,.2)
        return np.sin(np.pi*clipped/.2)*np.exp(-clipped*16)*(local>=0)*(local<=.2)
    heart=np.sin(2*np.pi*48*t)*(pulse(0)+.55*pulse(.24))
    entries.append(write_audio(OUTPUT/'terminal_heartbeat.wav',heart,rate,-8,"terminal","original double pulse, 3-second period; replaces runtime synthesis"))
    manifest={"collection":"Gallicus - Pietra e Aria", "date":"2026-09-06", "method":"original offline procedural synthesis; no AI music model, recordings or sample packs", "authoring_assistance":"Astra authored the synthesis recipes and phrases; no neural audio generation service.", "generator":"tools/generate_original_audio.py", "assets":entries}
    OUTPUT.mkdir(parents=True,exist_ok=True)
    (OUTPUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Generated',len(entries),'original assets; bytes',sum((ROOT/e['path'][6:]).stat().st_size for e in entries))

if __name__ == '__main__':
    main()
