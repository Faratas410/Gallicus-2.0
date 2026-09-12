"""Run the real UI campaign with an isolated, retained evidence profile."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot-bin", required=True)
    parser.add_argument("--output-dir", default="artifacts/campaign_pass/journey")
    parser.add_argument("--visual", action="store_true")
    args = parser.parse_args()
    output = (ROOT / args.output_dir).resolve()
    output.mkdir(parents=True, exist_ok=True)
    profile = Path(tempfile.mkdtemp(prefix="profile_", dir=output))
    env = os.environ.copy()
    env["APPDATA"] = str(profile)
    env["XDG_DATA_HOME"] = str(profile)
    command = [str(Path(args.godot_bin).resolve()), "--audio-driver", "Dummy",
               "--path", str(ROOT), "--script", "res://scripts/ci/campaign_runtime_contract.gd"]
    if args.visual:
        command.extend(["--max-fps", "60", "--", f"--capture-dir={output / 'screenshots'}"])
    else:
        command.append("--headless")
    result = subprocess.run(
        command,
        cwd=ROOT, env=env, capture_output=True, text=True, timeout=900,
    )
    log = result.stdout + result.stderr
    (output / "runtime.log").write_text(log, encoding="utf-8")
    ok = result.returncode == 0 and "CAMPAIGN_RUNTIME_CONTRACT_OK" in log and "ERROR:" not in log
    if ok:
        reboot = subprocess.run(
            [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy", "--path", str(ROOT),
             "--script", "res://scripts/ci/campaign_runtime_contract.gd", "--", "--verify-terminal"],
            cwd=ROOT, env=env, capture_output=True, text=True, timeout=30,
        )
        reboot_log = reboot.stdout + reboot.stderr
        (output / "terminal_reboot.log").write_text(reboot_log, encoding="utf-8")
        ok = reboot.returncode == 0 and "CAMPAIGN_TERMINAL_REBOOT_OK" in reboot_log and "ERROR:" not in reboot_log
    (output / "summary.json").write_text(json.dumps({"ok": ok, "exit": result.returncode, "profile": str(profile)}, indent=2), encoding="utf-8")
    print(log[-5000:])
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
