"""Verify shipped original audio and presentation budgets without build dependencies."""
from pathlib import Path
import array
import hashlib
import json
import math
import re
import sys
import wave
ROOT = Path(__file__).resolve().parents[2]

def main():
    manifest=json.loads((ROOT/"assets/audio/original/manifest.json").read_text(encoding="utf-8"))
    entries=manifest["assets"]
    assert len(entries)==31
    paths={entry["path"] for entry in entries}
    total=0
    for entry in entries:
        path=ROOT/entry["path"].removeprefix("res://")
        raw=path.read_bytes(); total+=len(raw)
        assert hashlib.sha256(raw).hexdigest()==entry["sha256"], path
        with wave.open(str(path),"rb") as wav:
            assert wav.getsampwidth()==2 and wav.getnchannels()==entry["channels"], path
            assert wav.getframerate()==entry["sample_rate"], path
            assert abs(wav.getnframes()/wav.getframerate()-entry["seconds"])<1e-5, path
            data=array.array("h",wav.readframes(wav.getnframes()))
        if sys.byteorder!='little': data.byteswap()
        peak=max(abs(x) for x in data)/32768
        assert 0.01 < peak <= 10**(-7.9/20), path
        assert abs(sum(data)/len(data)/32768)<.003, path
        assert all(x==0 for x in data[:entry["channels"]]+data[-entry["channels"]:]), path
        if entry["role"]=="music":
            assert entry["channels"]==2 and entry["sample_rate"]==22050
            assert entry["seconds"]==48 and entry["rms_dbfs"]<=-18, path
    assert total < 24*1024*1024, "audio source budget exceeded"
    # Conservative coincident peaks: six SFX and both crossfade voices.
    sfx=(ROOT/'scripts/audio/sfx_bus.gd').read_text(encoding='utf-8').split('const CUE_VOLUME_DB: Dictionary = {',1)[1].split('}',1)[0]
    highest_gain=max(float(x) for x in re.findall(r': (-[0-9.]+)',sfx))
    assert 6*10**((-8+highest_gain)/20)+2*10**((-12-7)/20) < 1, 'mix headroom exhausted'

    for file in ['scripts/audio/music_director.gd','scripts/audio/sfx_bus.gd','scripts/ui/registry_terminal_view.gd']:
        source=(ROOT/file).read_text(encoding='utf-8')
        for path in re.findall(r'res://assets/audio/[^"\s]+\.(?:wav|mp3|ogg)',source):
            assert path in paths, (file,path)
    assert 'assets/audio/*.mp3' in (ROOT/'export_presets.cfg').read_text(encoding='utf-8')
    texture_import=(ROOT/'assets/ui/generated/ritual_dust.png.import').read_text(encoding='utf-8')
    assert 'process/size_limit=256' in texture_import
    print('[OK][AV_ASSET_CONTRACT] 31 original WAVs; hashes, format, headroom, endpoints and 24 MiB budget')

if __name__=='__main__': main()
