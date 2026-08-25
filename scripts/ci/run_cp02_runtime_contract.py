#!/usr/bin/env python3
"""Run the isolated CP-02 persistence/recovery contract with a temporary user dir."""

from __future__ import annotations

import argparse
import os
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SUCCESS_MARKER = "CP02_RUNTIME_CONTRACT_OK"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot-bin", required=True)
    args = parser.parse_args()

    with tempfile.TemporaryDirectory(prefix="gallicus_cp02_contract_") as temp_dir:
        isolated_root = Path(temp_dir)
        appdata = isolated_root / "appdata"
        xdg_data = isolated_root / "xdg_data"
        user_logs = appdata / "Godot" / "app_userdata" / "Gallicus" / "logs"
        user_logs.mkdir(parents=True, exist_ok=True)
        xdg_data.mkdir(parents=True, exist_ok=True)
        env = os.environ.copy()
        env["APPDATA"] = str(appdata)
        env["XDG_DATA_HOME"] = str(xdg_data)
        command = [
            str(Path(args.godot_bin).resolve()),
            "--headless",
            "--path",
            str(ROOT),
            "--script",
            "res://scripts/ci/cp02_runtime_contract.gd",
        ]
        proc = subprocess.run(
            command,
            cwd=ROOT,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=False,
            timeout=60,
        )

    print(proc.stdout, end="")
    if proc.returncode != 0 or SUCCESS_MARKER not in proc.stdout:
        print("[FAIL][CP02_RUNTIME_CONTRACT] isolated runtime contract failed")
        return 1
    print("[OK][CP02_RUNTIME_CONTRACT] migration, recovery, quarantine and flow normalization passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
