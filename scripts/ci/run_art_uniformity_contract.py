"""Verify material continuity and motion cancellation with an isolated profile."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot-bin', required=True)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='gallicus_art_') as temp:
        env = os.environ.copy()
        env['APPDATA'] = str(Path(temp)/'appdata')
        env['XDG_DATA_HOME'] = str(Path(temp)/'xdg')
        result = subprocess.run([str(Path(args.godot_bin).resolve()), '--headless',
            '--audio-driver', 'Dummy', '--path', str(ROOT), '--script',
            'res://scripts/ci/art_uniformity_runtime_contract.gd'], cwd=ROOT,
            env=env, capture_output=True, text=True, timeout=90)
    output = result.stdout + result.stderr
    print(output, end='')
    return 0 if result.returncode == 0 and 'ART_UNIFORMITY_CONTRACT' in output and 'ERROR:' not in output and 'WARNING:' not in output else 1

if __name__ == '__main__':
    raise SystemExit(main())
