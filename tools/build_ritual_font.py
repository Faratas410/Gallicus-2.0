"""Build the fixed UI face from the project's OFL Roboto Serif source.

Requires fontTools 4.67.0 for regeneration only; the game ships the static TTF.
"""
from pathlib import Path
import argparse
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[1]

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--fonttools-path', type=Path)
    args = parser.parse_args()
    if args.fonttools_path:
        sys.path.insert(0, str(args.fonttools_path.resolve()))
    from fontTools.ttLib import TTFont
    from fontTools.varLib.instancer import instantiateVariableFont
    source = ROOT / 'assets/ui/official/typography/roboto_serif/RobotoSerif.ttf'
    target = source.with_name('GallicusSerif-Regular.ttf')
    original = TTFont(source, recalcTimestamp=False)
    axes = {axis.axisTag: axis.defaultValue for axis in original['fvar'].axes}
    axes.update({'wght': 400, 'wdth': 100, 'opsz': 32})
    static = instantiateVariableFont(original, axes, inplace=False)
    names = {1: 'Gallicus Serif', 2: 'Regular', 3: 'GallicusSerif-Regular-20261024',
             4: 'Gallicus Serif Regular', 6: 'GallicusSerif-Regular',
             16: 'Gallicus Serif', 17: 'Regular'}
    for record in list(static['name'].names):
        if record.nameID in names:
            static['name'].setName(names[record.nameID], record.nameID,
                                   record.platformID, record.platEncID, record.langID)
    static.recalcTimestamp = False
    static.save(target)
    loaded = TTFont(target, recalcTimestamp=False)
    assert 'fvar' not in loaded
    assert all(ord(char) in loaded.getBestCmap() for char in 'ÀÈÉÌÒÙàèéìòùñ¿¡')
    receipt = {'source': source.name, 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
               'output': target.name, 'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
               'axes': axes, 'tool': 'fontTools 4.67.0', 'license': 'SIL OFL 1.1 (OFL.txt)'}
    target.with_suffix('.json').write_text(json.dumps(receipt, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(receipt, indent=2))

if __name__ == '__main__':
    main()
