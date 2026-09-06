"""Run audiovisual regressions in Godot with an isolated profile on Windows/Linux."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot-bin", required=True)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="gallicus_av_") as temp:
        base = Path(temp)
        env = os.environ.copy()
        env["APPDATA"] = str(base / "appdata")
        env["XDG_DATA_HOME"] = str(base / "xdg_data")
        (base / "appdata/Godot/app_userdata/Gallicus/logs").mkdir(parents=True)
        (base / "xdg_data").mkdir()
        result = subprocess.run([str(Path(args.godot_bin).resolve()), "--headless", "--path", str(ROOT), "--script", "res://scripts/ci/av_runtime_contract.gd"], cwd=ROOT, env=env, capture_output=True, text=True, timeout=90)
    output = result.stdout + result.stderr
    print(output, end="")
    return 0 if result.returncode == 0 and "AV_RUNTIME_CONTRACT_OK" in output and "ERROR:" not in output else 1

if __name__ == "__main__":
    raise SystemExit(main())
