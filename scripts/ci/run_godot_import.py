"""Import to completion and reject resource/parser errors even with exit code 0."""
import argparse
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot-bin", required=True)
    parser.add_argument("--project-root", default=str(ROOT))
    args = parser.parse_args()
    result = subprocess.run([str(Path(args.godot_bin).resolve()), "--headless", "--editor", "--path", str(Path(args.project_root).resolve()), "--import"], capture_output=True, text=True, timeout=180)
    output = result.stdout + result.stderr
    print(output, end="")
    errors = re.findall(r"(?m)^.*(?:ERROR:|SCRIPT ERROR:|Parse Error:).*$", output)
    if result.returncode or errors:
        print(f"[FAIL][GODOT_IMPORT] exit={result.returncode}, error lines={len(errors)}")
        return 1
    print("[OK][GODOT_IMPORT] completed with no resource or script errors")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
