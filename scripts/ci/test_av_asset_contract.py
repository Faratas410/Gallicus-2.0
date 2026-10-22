"""Verify shipped score and cues, their provenance and presentation budgets without build dependencies."""
from pathlib import Path
import array
import hashlib
import json
import re
import sys
import wave
ROOT = Path(__file__).resolve().parents[2]
SCORE = ["atrium", "registry", "inscription", "threshold", "dossier", "gradinata_murmur", "gradinata_rhythm"]

def main():
    manifest=json.loads((ROOT/"assets/audio/manifest.json").read_text(encoding="utf-8"))
    entries=manifest["assets"]
    assert len(entries)==40, len(entries)
    assert (ROOT/manifest["credits"]).exists(), "audio credits missing"
    paths={entry["path"] for entry in entries}
    total=0
    for entry in entries:
        path=ROOT/entry["path"].removeprefix("res://")
        raw=path.read_bytes(); total+=len(raw)
        assert hashlib.sha256(raw).hexdigest()==entry["sha256"], path
        assert entry["peak_dbfs"] <= -1.0, path
        if path.suffix==".ogg":
            # Loops share one grid: 80 s, 72 BPM, so a section change keeps the bar.
            assert entry["loop"] and entry["bpm"]==72 and abs(entry["seconds"]-80.0)<1e-3, path
            assert -26.0 <= entry["lufs"] <= -16.0, path
            assert "loop=true" in (path.parent/(path.name+".import")).read_text(encoding="utf-8"), path
            continue
        with wave.open(str(path),"rb") as wav:
            assert wav.getsampwidth()==2 and wav.getnchannels()==entry["channels"], path
            assert wav.getframerate()==entry["sample_rate"]==44100, path
            assert abs(wav.getnframes()/wav.getframerate()-entry["seconds"])<1e-3, path
            data=array.array("h",wav.readframes(wav.getnframes()))
        if sys.byteorder!='little': data.byteswap()
        peak=max(abs(x) for x in data)/32768
        assert 0.01 < peak <= 10**(-2.9/20), path
        assert abs(sum(data)/len(data)/32768)<.003, path
        # Cues start and end on silence: no click at either edge.
        assert all(abs(x) < 64 for x in data[:entry["channels"]]+data[-entry["channels"]:]), path
    for name in SCORE:
        assert f"res://assets/audio/score/{name}.ogg" in paths, name
    assert total < 32*1024*1024, "audio source budget exceeded"
    # Conservative coincident peaks: six cues at their gain, two score voices and two gradinata beds.
    sfx=(ROOT/'scripts/audio/sfx_bus.gd').read_text(encoding='utf-8').split('const CUE_VOLUME_DB: Dictionary = {',1)[1].split('}',1)[0]
    highest_gain=max(float(x) for x in re.findall(r': (-[0-9.]+)',sfx))
    rms_sum=6*10**((-13.5+highest_gain)/10)+2*10**((-18-14)/10)+2*10**((-22-8)/10)
    assert rms_sum < 10**(-6/10), 'mix headroom exhausted'

    for file in ['scripts/audio/music_director.gd','scripts/audio/sfx_bus.gd','scripts/ui/registry_terminal_view.gd']:
        source=(ROOT/file).read_text(encoding='utf-8')
        for path in re.findall(r'res://assets/audio/[^"\s]+\.(?:wav|mp3|ogg)',source):
            assert path in paths, (file,path)
    sources=json.loads((ROOT/"tools/audio/sources.json").read_text(encoding="utf-8"))
    for item in sources["files"]:
        # Only licences that allow sale and redistribution inside a game.
        assert item["license"] in ("CC0-1.0","CC-BY-3.0"), item["key"]
    credits=(ROOT/manifest["credits"]).read_text(encoding="utf-8")
    for item in sources["files"]:
        if item["license"]=="CC-BY-3.0":
            assert item["author"] in credits and item["origin"] in credits, item["key"]
    assert 'assets/audio/*.mp3' in (ROOT/'export_presets.cfg').read_text(encoding='utf-8')
    texture_import=(ROOT/'assets/ui/generated/ritual_dust.png.import').read_text(encoding='utf-8')
    assert 'process/size_limit=256' in texture_import
    print('[OK][AV_ASSET_CONTRACT] 7 score loops and 33 cues; hashes, format, loudness, licences, credits and headroom')

if __name__=='__main__': main()
