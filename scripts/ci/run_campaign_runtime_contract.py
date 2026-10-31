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
    parser.add_argument("--copy-paid", action="store_true")
    args = parser.parse_args()
    output = (ROOT / args.output_dir).resolve()
    output.mkdir(parents=True, exist_ok=True)
    profile = Path(tempfile.mkdtemp(prefix="profile_", dir=output))
    env = os.environ.copy()
    env["APPDATA"] = str(profile)
    env["LOCALAPPDATA"] = str(profile)
    env["XDG_DATA_HOME"] = str(profile)
    abrupt_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/audio_abrupt_shutdown_contract.gd"],
        cwd=ROOT, env=env, capture_output=True, text=True, timeout=30,
    )
    abrupt_log = abrupt_check.stdout + abrupt_check.stderr
    (output / "audio_abrupt_shutdown.log").write_text(abrupt_log, encoding="utf-8")
    if abrupt_check.returncode != 0 or "AUDIO_ABRUPT_SHUTDOWN_STARTED" not in abrupt_log or "ERROR:" in abrupt_log or "ObjectDB instances" in abrupt_log:
        print(abrupt_log)
        return 1
    audio_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/audio_shutdown_contract.gd"],
        cwd=ROOT, env=env, capture_output=True, text=True, timeout=30,
    )
    audio_log = audio_check.stdout + audio_check.stderr
    (output / "audio_shutdown.log").write_text(audio_log, encoding="utf-8")
    if audio_check.returncode != 0 or "AUDIO_SHUTDOWN_CONTRACT_OK" not in audio_log or "ERROR:" in audio_log or "ObjectDB instances" in audio_log:
        print(audio_log)
        return 1
    reset_profile = Path(tempfile.mkdtemp(prefix="reset_profile_", dir=output))
    reset_env = env.copy()
    reset_env["APPDATA"] = str(reset_profile)
    reset_env["LOCALAPPDATA"] = str(reset_profile)
    reset_env["XDG_DATA_HOME"] = str(reset_profile)
    reset_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_reset_alignment_contract.gd"],
        cwd=ROOT, env=reset_env, capture_output=True, text=True, timeout=30,
    )
    reset_log = reset_check.stdout + reset_check.stderr
    (output / "seat_reset.log").write_text(reset_log, encoding="utf-8")
    if reset_check.returncode != 0 or "SEAT_RESET_ALIGNMENT_OK" not in reset_log or "ERROR:" in reset_log:
        print(reset_log)
        return 1
    seed_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/crowd_seed_runtime_contract.gd"],
        cwd=ROOT, env=env, capture_output=True, text=True, timeout=30,
    )
    seed_log = seed_check.stdout + seed_check.stderr
    (output / "crowd_seed.log").write_text(seed_log, encoding="utf-8")
    if seed_check.returncode != 0 or "CROWD_SEED_CONTRACT_OK" not in seed_log or "ERROR:" in seed_log:
        print(seed_log)
        return 1
    ledger_profile = Path(tempfile.mkdtemp(prefix="ledger_profile_", dir=output))
    ledger_env = env.copy()
    ledger_env["APPDATA"] = str(ledger_profile)
    ledger_env["LOCALAPPDATA"] = str(ledger_profile)
    ledger_env["XDG_DATA_HOME"] = str(ledger_profile)
    ledger_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/ledger_settlement_runtime_contract.gd"],
        cwd=ROOT, env=ledger_env, capture_output=True, text=True, timeout=30,
    )
    ledger_log = ledger_check.stdout + ledger_check.stderr
    (output / "ledger_settlement.log").write_text(ledger_log, encoding="utf-8")
    if ledger_check.returncode != 0 or "LEDGER_SETTLEMENT_CONTRACT_OK" not in ledger_log or "ERROR:" in ledger_log:
        print(ledger_log)
        return 1
    case_profile = Path(tempfile.mkdtemp(prefix="seat_profile_", dir=output))
    case_env = env.copy()
    case_env["APPDATA"] = str(case_profile)
    case_env["LOCALAPPDATA"] = str(case_profile)
    case_env["XDG_DATA_HOME"] = str(case_profile)
    case_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_case_runtime_contract.gd"],
        cwd=ROOT, env=case_env, capture_output=True, text=True, timeout=60,
    )
    case_log = case_check.stdout + case_check.stderr
    (output / "seat_case.log").write_text(case_log, encoding="utf-8")
    if case_check.returncode != 0 or "SEAT_CASE_RUNTIME_CONTRACT_OK" not in case_log or "ERROR:" in case_log:
        print(case_log)
        return 1
    inquiry_profile = Path(tempfile.mkdtemp(prefix="inquiry_profile_", dir=output))
    inquiry_env = env.copy()
    inquiry_env["APPDATA"] = str(inquiry_profile)
    inquiry_env["LOCALAPPDATA"] = str(inquiry_profile)
    inquiry_env["XDG_DATA_HOME"] = str(inquiry_profile)
    inquiry_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_inquiry_runtime_contract.gd"],
        cwd=ROOT, env=inquiry_env, capture_output=True, text=True, timeout=60,
    )
    inquiry_log = inquiry_check.stdout + inquiry_check.stderr
    (output / "seat_inquiry.log").write_text(inquiry_log, encoding="utf-8")
    if inquiry_check.returncode != 0 or "SEAT_INQUIRY_RUNTIME_CONTRACT_OK" not in inquiry_log or "ERROR:" in inquiry_log:
        print(inquiry_log)
        return 1
    memory_profile = Path(tempfile.mkdtemp(prefix="memory_profile_", dir=output))
    memory_env = env.copy()
    memory_env["APPDATA"] = str(memory_profile)
    memory_env["LOCALAPPDATA"] = str(memory_profile)
    memory_env["XDG_DATA_HOME"] = str(memory_profile)
    memory_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_memory_runtime_contract.gd"],
        cwd=ROOT, env=memory_env, capture_output=True, text=True, timeout=60,
    )
    memory_log = memory_check.stdout + memory_check.stderr
    (output / "seat_memory.log").write_text(memory_log, encoding="utf-8")
    if memory_check.returncode != 0 or "SEAT_MEMORY_RUNTIME_CONTRACT_OK" not in memory_log or "ERROR:" in memory_log:
        print(memory_log)
        return 1
    copy_profile = Path(tempfile.mkdtemp(prefix="copy_profile_", dir=output))
    copy_env = env.copy()
    copy_env["APPDATA"] = str(copy_profile)
    copy_env["LOCALAPPDATA"] = str(copy_profile)
    copy_env["XDG_DATA_HOME"] = str(copy_profile)
    copy_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_copy_runtime_contract.gd"],
        cwd=ROOT, env=copy_env, capture_output=True, text=True, timeout=60,
    )
    copy_log = copy_check.stdout + copy_check.stderr
    (output / "seat_copy.log").write_text(copy_log, encoding="utf-8")
    if copy_check.returncode != 0 or "SEAT_COPY_RUNTIME_CONTRACT_OK" not in copy_log or "ERROR:" in copy_log:
        print(copy_log)
        return 1
    echo_profile = Path(tempfile.mkdtemp(prefix="echo_profile_", dir=output))
    echo_env = env.copy()
    echo_env["APPDATA"] = str(echo_profile)
    echo_env["LOCALAPPDATA"] = str(echo_profile)
    echo_env["XDG_DATA_HOME"] = str(echo_profile)
    echo_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_copy_echo_contract.gd"],
        cwd=ROOT, env=echo_env, capture_output=True, text=True, timeout=60,
    )
    echo_log = echo_check.stdout + echo_check.stderr
    (output / "seat_copy_echo.log").write_text(echo_log, encoding="utf-8")
    if echo_check.returncode != 0 or "SEAT_COPY_ECHO_CONTRACT_OK" not in echo_log or "ERROR:" in echo_log:
        print(echo_log)
        return 1
    steps_profile = Path(tempfile.mkdtemp(prefix="steps_profile_", dir=output))
    steps_env = env.copy()
    steps_env["APPDATA"] = str(steps_profile)
    steps_env["LOCALAPPDATA"] = str(steps_profile)
    steps_env["XDG_DATA_HOME"] = str(steps_profile)
    steps_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/seat_steps_era_contract.gd"],
        cwd=ROOT, env=steps_env, capture_output=True, text=True, timeout=90,
    )
    steps_log = steps_check.stdout + steps_check.stderr
    (output / "seat_steps_era.log").write_text(steps_log, encoding="utf-8")
    if steps_check.returncode != 0 or "SEAT_STEPS_ERA_CONTRACT_OK" not in steps_log or "ERROR:" in steps_log:
        print(steps_log)
        return 1
    final_profile = Path(tempfile.mkdtemp(prefix="final_era_profile_", dir=output))
    final_env = env.copy()
    final_env["APPDATA"] = str(final_profile)
    final_env["LOCALAPPDATA"] = str(final_profile)
    final_env["XDG_DATA_HOME"] = str(final_profile)
    final_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/final_era_runtime_contract.gd"],
        cwd=ROOT, env=final_env, capture_output=True, text=True, timeout=120,
    )
    final_log = final_check.stdout + final_check.stderr
    (output / "final_era.log").write_text(final_log, encoding="utf-8")
    if final_check.returncode != 0 or "FINAL_ERA_RUNTIME_CONTRACT_OK" not in final_log or "ERROR:" in final_log:
        print(final_log)
        return 1
    session_profile = Path(tempfile.mkdtemp(prefix="session_log_profile_", dir=output))
    session_env = env.copy()
    session_env["APPDATA"] = str(session_profile)
    session_env["LOCALAPPDATA"] = str(session_profile)
    session_env["XDG_DATA_HOME"] = str(session_profile)
    session_check = subprocess.run(
        [str(Path(args.godot_bin).resolve()), "--headless", "--audio-driver", "Dummy",
         "--path", str(ROOT), "--script", "res://scripts/ci/session_log_contract.gd"],
        cwd=ROOT, env=session_env, capture_output=True, text=True, timeout=60,
    )
    session_log = session_check.stdout + session_check.stderr
    (output / "session_log.log").write_text(session_log, encoding="utf-8")
    if session_check.returncode != 0 or "SESSION_LOG_CONTRACT_OK" not in session_log or "ERROR:" in session_log:
        print(session_log)
        return 1
    command = [str(Path(args.godot_bin).resolve()), "--audio-driver", "Dummy",
               "--path", str(ROOT), "--script", "res://scripts/ci/campaign_runtime_contract.gd"]
    user_args = []
    if args.visual:
        command.extend(["--max-fps", "60"])
        user_args.append(f"--capture-dir={output / 'screenshots'}")
    else:
        command.append("--headless")
    if args.copy_paid:
        user_args.append("--copy-paid")
    if user_args:
        command.extend(["--", *user_args])
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
