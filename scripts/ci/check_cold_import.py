"""Import independent copies of the current candidate, never the user's cache."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot-bin", required=True)
    parser.add_argument("--attempts", type=int, default=3)
    parser.add_argument("--output-dir", default="artifacts/campaign_pass/cold")
    parser.add_argument("--single-threaded", action="store_true")
    args = parser.parse_args()
    output = (ROOT / args.output_dir).resolve()
    output.mkdir(parents=True, exist_ok=True)
    files = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=ROOT).decode().split("\0")
    files = sorted({name for name in files if name and Path(name).parts[0] in {"assets", "data", "scenes", "scripts"} or name in {"project.godot", "export_presets.cfg"}})
    manifest = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in files if (ROOT / name).is_file()}
    (output / "source_files.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    results = []
    for attempt in range(args.attempts):
        base = Path(tempfile.mkdtemp(prefix=f"attempt_{attempt + 1}_", dir=output))
        project = base / "project"
        for name in manifest:
            target = project / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, target)
        env = os.environ.copy()
        env["APPDATA"] = str(base / "profile")
        env["XDG_DATA_HOME"] = str(base / "profile")
        command = [str(Path(args.godot_bin).resolve()), "--headless", "--editor", "--path", str(project), "--import"]
        if args.single_threaded:
            command.append("--single-threaded-scene")
        proc = subprocess.run(command, env=env, capture_output=True, text=True, timeout=240)
        log = proc.stdout + proc.stderr
        (base / "import.log").write_text(log, encoding="utf-8")
        ok = proc.returncode == 0 and "ERROR:" not in log
        results.append({"attempt": attempt + 1, "ok": ok, "exit": proc.returncode, "directory": str(base)})
        print(json.dumps(results[-1]), flush=True)
        (output / "summary.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    return 0 if all(row["ok"] for row in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
