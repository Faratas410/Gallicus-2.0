#!/usr/bin/env python3
"""Guard the lean three-job checkpoint cadence and manual full profile."""

from __future__ import annotations

import fnmatch
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
WORKFLOW = ROOT / ".github/workflows/godot_smoke_runtime.yml"
MARKER = ROOT / ".github/ci/full_suite_checkpoint.txt"
PLAYBOOK = ROOT / "scripts/ci/run_testing_playbook.py"
BOOTSTRAP = ROOT / "scripts/ci/bootstrap_linux_godot.sh"
TESTING_DOC = ROOT / "docs/testing.md"
ROADMAP = ROOT / "docs/development_plan.md"
VISUAL_QA = ROOT / "tools/visual_qa_capture.gd"

CHECKPOINTS = (
    "OF-06",
    "OF-09",
    "OF-11",
    "CP-03",
    "CS-04",
    "CONTENT-LOCK",
    "AUDIOVISUAL-LOCK",
    "RELEASE-LOCK",
)
RISK_PATHS = (
    ".github/ci/full_suite_checkpoint.txt",
    ".github/workflows/godot_smoke_runtime.yml",
    "project.godot",
    "scripts/systems/game_events.gd",
    "scripts/systems/run_manager.gd",
    "scripts/systems/save_manager.gd",
    "scripts/systems/run/**",
    "scripts/contracts/**",
)
STATIC_TESTS = tuple(sorted(path.name for path in (ROOT / "scripts/ci").glob("test_*.py")))
STATIC_CHECKS = (
    "check_docs_active_refs.py",
    "check_no_legacy_references.py",
    "check_runtime_invariants.py",
    "audit_end_run_summary.py",
    "check_tscn_format.py",
    "validate_gameevents_contract.py",
    "verify_res_paths.py",
)


def _read(path: Path) -> str:
    if not path.exists():
        raise AssertionError(f"missing CI checkpoint file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def _job_block(workflow: str, job_name: str) -> str:
    match = re.search(
        rf"(?ms)^  {re.escape(job_name)}:\n.*?(?=^  [a-zA-Z0-9_]+:\n|\Z)",
        workflow,
    )
    if match is None:
        raise AssertionError(f"workflow missing job: {job_name}")
    return match.group(0)


def _glob_sample(pattern: str) -> str:
    """Return a deterministic filename accepted by the workflow's simple globs."""
    return pattern.replace("??", "it").replace("?", "x").replace("*", "sample")


def _assert_visual_artifact_contract(visual_block: str) -> None:
    full_match = re.search(
        r'(?ms)if \[ "\$PROFILE" = "full" \]; then\n(.*?)(?=^          else$)',
        visual_block,
    )
    if full_match is None:
        raise AssertionError("visual stage missing an isolated full-profile branch")
    full_branch = full_match.group(1)

    count_patterns = dict(
        re.findall(
            r"(?m)^\s*([A-Z_]+)_COUNT=\$\(find artifacts/visual_qa "
            r"-maxdepth 1 -type f -name '([^']+)' \| wc -l\)$",
            full_branch,
        )
    )
    expected_counts = {
        name: int(value)
        for name, value in re.findall(
            r'(?m)^\s*test "\$([A-Z_]+)_COUNT" -eq ([0-9]+)$',
            full_branch,
        )
    }
    if count_patterns.get("TOTAL") != "*.png":
        raise AssertionError("full visual profile must count every PNG before signoff")
    if "TOTAL" not in expected_counts:
        raise AssertionError("full visual profile missing its total PNG assertion")

    matrix_patterns = {
        name: pattern for name, pattern in count_patterns.items() if name != "TOTAL"
    }
    missing_expectations = sorted(set(matrix_patterns) - set(expected_counts))
    if missing_expectations:
        raise AssertionError(
            f"visual matrix patterns missing expected counts: {missing_expectations}"
        )

    upload_match = re.search(
        r"(?ms)name: visual_qa_evidence\n\s*path: \|\n(.*?)\n\s*if-no-files-found:",
        visual_block,
    )
    if upload_match is None:
        raise AssertionError("visual stage missing the visual_qa_evidence upload contract")
    upload_patterns = tuple(
        line.strip().rsplit("/", 1)[-1]
        for line in upload_match.group(1).splitlines()
        if line.strip()
    )
    if not upload_patterns:
        raise AssertionError("visual_qa_evidence upload contract is empty")

    visual_qa = _read(VISUAL_QA)
    run_match = re.search(r"(?ms)^func _run\(\) -> void:\n(.*?)(?=^func |\Z)", visual_qa)
    if run_match is None:
        raise AssertionError("visual QA tool missing _run")
    literal_captures = tuple(
        f"{name}.png"
        for name in re.findall(r'await _capture\("([^"%]+)"\)', run_match.group(1))
    )
    if len(literal_captures) != len(set(literal_captures)):
        raise AssertionError("full visual profile contains duplicate literal captures")

    unuploaded = sorted(
        filename
        for filename in literal_captures
        if not any(fnmatch.fnmatchcase(filename, pattern) for pattern in upload_patterns)
    )
    if unuploaded:
        raise AssertionError(
            f"full visual capture emits files outside visual_qa_evidence: {unuploaded}"
        )

    uncovered_matrices = sorted(
        pattern
        for pattern in matrix_patterns.values()
        if not any(
            fnmatch.fnmatchcase(_glob_sample(pattern), upload_pattern)
            for upload_pattern in upload_patterns
        )
    )
    if uncovered_matrices:
        raise AssertionError(
            f"visual matrix patterns are not uploaded: {uncovered_matrices}"
        )

    fixed_captures = {
        filename
        for filename in literal_captures
        if not any(
            fnmatch.fnmatchcase(filename, pattern)
            for pattern in matrix_patterns.values()
        )
    }
    calculated_total = (
        sum(expected_counts[name] for name in matrix_patterns) + len(fixed_captures)
    )
    if calculated_total != expected_counts["TOTAL"]:
        raise AssertionError(
            "full visual artifact total is inconsistent: "
            f"matrix={calculated_total - len(fixed_captures)}, "
            f"fixed={len(fixed_captures)}, calculated={calculated_total}, "
            f"asserted={expected_counts['TOTAL']}"
        )


def _assert_marker() -> None:
    marker = _read(MARKER)
    active_line = next((line.strip() for line in marker.splitlines() if line.strip() and not line.lstrip().startswith("#")), "")
    if active_line not in CHECKPOINTS:
        raise AssertionError(f"active full-suite marker must be a scheduled checkpoint, got {active_line!r}")
    for checkpoint in ("OF-06", "OF-09", "OF-11"):
        if checkpoint not in marker:
            raise AssertionError(f"checkpoint marker must document historical checkpoint {checkpoint}")


def _assert_workflow() -> None:
    workflow = _read(WORKFLOW)
    playbook = _read(PLAYBOOK)
    bootstrap = _read(BOOTSTRAP)

    if "workflow_dispatch:" not in workflow or "profile:" not in workflow:
        raise AssertionError("CI must expose a manual lean/full profile")
    for token in ("default: lean", "- lean", "- full"):
        if token not in workflow:
            raise AssertionError(f"workflow profile is incomplete: {token}")
    if "pull_request:" in workflow:
        raise AssertionError("direct-main workflow must not run automatically for pull requests")
    if "branches: [main]" not in workflow or "paths:" not in workflow:
        raise AssertionError("automatic CI must remain a path-filtered main push trigger")
    for risk_path in RISK_PATHS:
        if f'"{risk_path}"' not in workflow:
            raise AssertionError(f"workflow missing checkpoint/risk trigger path: {risk_path}")

    job_names = re.findall(r"(?m)^  ([a-zA-Z0-9_]+):\n", workflow.split("jobs:\n", 1)[1])
    if job_names != ["static_contracts", "runtime_routes", "visual_stage"]:
        raise AssertionError(f"lean checkpoint must expose exactly three jobs, got {job_names}")

    static_block = _job_block(workflow, "static_contracts")
    runtime_block = _job_block(workflow, "runtime_routes")
    visual_block = _job_block(workflow, "visual_stage")
    _assert_visual_artifact_contract(visual_block)
    if static_block.count("python3 scripts/ci/run_testing_playbook.py") != 1:
        raise AssertionError("static_contracts must call the canonical playbook exactly once")
    for test_name in STATIC_TESTS + STATIC_CHECKS:
        if playbook.count(test_name) != 1:
            raise AssertionError(f"canonical playbook must contain static contract exactly once: {test_name}")
        if test_name in static_block:
            raise AssertionError(f"workflow must not duplicate playbook contract: {test_name}")

    for downstream in (runtime_block, visual_block):
        if "needs: static_contracts" not in downstream:
            raise AssertionError("runtime and visual jobs must depend on static_contracts")
        if downstream.count("bash scripts/ci/bootstrap_linux_godot.sh") != 1:
            raise AssertionError("each Godot job must use the shared bounded bootstrap")
    if workflow.count("Import project assets once") != 2:
        raise AssertionError("lean checkpoint must perform exactly two Godot imports")
    if "apt-get update" in workflow:
        raise AssertionError("workflow must not run apt-get update unconditionally")

    for scenario in ("ROUTE_CASHOUT", "ROUTE_DOUBLE", "ROUTE_CONDANNA", "ROUTE_REGISTER_FINAL"):
        if scenario not in runtime_block:
            raise AssertionError(f"lean route bundle missing scenario: {scenario}")
    if "CORE_CONTINUITY" not in runtime_block:
        raise AssertionError("lean route bundle must cover three runs and all dossier routes")
    if "KEYBOARD_FULL_RUN" not in runtime_block:
        raise AssertionError("lean route bundle must cover the full keyboard-only run")
    for full_only in ("BET_PRESENT", "FULL_RUN"):
        if full_only not in runtime_block:
            raise AssertionError(f"manual full profile missing historical scenario: {full_only}")
    for token in ("overall=0", "for scenario in", "runtime_routes_logs"):
        if token not in runtime_block:
            raise AssertionError(f"route bundle must retain all results and logs: {token}")

    for token in (
        "--section=accessibility_settings",
        "timeout 240s",
        "timeout 600s",
        'test "$DOSSIER_COUNT" -eq 36',
        'test "$SETTINGS_COUNT" -eq 18',
        'test "$TOTAL_COUNT" -eq 18',
        'test "$TOTAL_COUNT" -eq 289',
        "visual_qa_evidence",
    ):
        if token not in visual_block:
            raise AssertionError(f"stage/full visual profile missing token: {token}")

    apt_guard = 'if [ "${#missing_packages[@]}" -gt 0 ]; then'
    if apt_guard not in bootstrap or bootstrap.index(apt_guard) > bootstrap.index("apt-get"):
        raise AssertionError("apt fallback must be guarded by missing tool detection")
    for token in ("archive.ubuntu.com", "Acquire::Retries=3", "Acquire::http::Timeout=20", "timeout 180s"):
        if token not in bootstrap:
            raise AssertionError(f"Linux bootstrap is not bounded: {token}")


def _assert_documentation() -> None:
    combined = f"{_read(TESTING_DOC)}\n{_read(ROADMAP)}"
    for checkpoint in ("OF-06", "OF-09", "OF-11", "CP-03", "CS-04"):
        if checkpoint not in combined:
            raise AssertionError(f"testing/roadmap must document checkpoint {checkpoint}")
    for checkpoint_name in ("Content Lock", "Audiovisual Lock", "Release Lock"):
        if checkpoint_name not in combined:
            raise AssertionError(f"testing/roadmap must document checkpoint {checkpoint_name}")
    for phrase in ("checkpoint", "workflow_dispatch", "Core Playable Candidate", "runtime_routes", "visual_stage"):
        if phrase not in combined:
            raise AssertionError(f"testing/roadmap missing lean CI phrase: {phrase}")


def main() -> int:
    _assert_marker()
    _assert_workflow()
    _assert_documentation()
    print("[OK][CI_CHECKPOINT_CONTRACT] lean three-job cadence and full profile passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
