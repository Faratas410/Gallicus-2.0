"""Run repeatable, isolated UI-driven campaign simulations for economy research.

These scripted policies do not represent players or estimate real play time.
Raw logs and per-run profiles are retained for inspection.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SEEDS = (424242, 1782373819, 777001)
POLICIES = {
    "bando_selective": ("bando", "bando2", "selective"),
    "bando_never": ("bando", "bando2", "never"),
    "prudent_never": ("prudent", "thin", "never"),
}


def execute(godot: Path, output: Path, seed: int, name: str) -> dict:
    style, strike, shop = POLICIES[name]
    case = output / f"{name}_{seed}"
    case.mkdir(parents=True, exist_ok=True)
    profile = Path(tempfile.mkdtemp(prefix="profile_", dir=case))
    env = os.environ.copy()
    env.update(APPDATA=str(profile), LOCALAPPDATA=str(profile), XDG_DATA_HOME=str(profile))
    command = [str(godot), "--headless", "--audio-driver", "Dummy", "--path", str(ROOT),
               "--script", "res://tools/campaign_sim.gd", "--", f"--seed={seed}",
               f"--style={style}", f"--strike={strike}", "--crowd=read", f"--shop={shop}"]
    try:
        process = subprocess.run(command, cwd=ROOT, env=env, capture_output=True,
                                 text=True, encoding="utf-8", errors="replace", timeout=900)
        log = process.stdout + process.stderr
        (case / "runtime.log").write_text(log, encoding="utf-8")
        summaries = [line.removeprefix("SIM_SUMMARY ") for line in log.splitlines()
                     if line.startswith("SIM_SUMMARY ")]
        dialogues = [line.removeprefix("SIM_DIALOGUES ") for line in log.splitlines()
                     if line.startswith("SIM_DIALOGUES ")]
        rows = [line for line in log.splitlines() if line.startswith("SIM_RUN ")]
        summary = json.loads(summaries[0]) if len(summaries) == 1 else {}
        seen = json.loads(dialogues[0]) if len(dialogues) == 1 else {}
        ok = (process.returncode == 0 and "ERROR:" not in log and len(summaries) == 1
              and len(dialogues) == 1 and summary.get("absence") is True
              and summary.get("runs") == len(rows))
        return {"seed": seed, "policy": name, "ok": ok, "exit": process.returncode,
                "profile": str(profile), "summary": summary, "dialogues": seen,
                "objectdb_warning": "ObjectDB instances leaked" in log}
    except (subprocess.TimeoutExpired, ValueError) as exc:
        return {"seed": seed, "policy": name, "ok": False, "error": str(exc),
                "profile": str(profile)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot-bin", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--workers", type=int, default=2, choices=(1, 2))
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = [pool.submit(execute, args.godot_bin.resolve(), output, seed, name)
                   for seed in SEEDS for name in POLICIES]
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            (output / "summary.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
            print(f"{len(results)}/{len(futures)} {result['policy']} seed={result['seed']} ok={result['ok']}", flush=True)
    return 0 if all(result["ok"] for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
