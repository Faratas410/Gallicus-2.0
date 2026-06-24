# Agent Rules (Repository-Local)

These rules apply to all coding agents working in this repository.

## Project Operating Contract

- Official project: Gallicus 2.0.
- Stack: Godot 4.6.2, GDScript, Python CI helpers.
- Active game target: internal beta of the ritual run loop, not an action-combat prototype.
- Current gameplay authority must not move: `RunManager` owns flow, `GameEvents` is the event bus, UI is reactive.
- Core gameplay, phase ownership, save flow, signal contracts, and canon rules may not be changed during documentation-only work.

## Documentation Operating System

- Start from `docs/README.md` before changing project docs.
- Use `docs/development_plan.md` for current roadmap and next operational step.
- Use `docs/testing.md` for local/CI/manual acceptance gates.
- Use `docs/code_quality.md` before touching runtime code.
- Use the domain document that matches the change: design, content, data, layout, asset, art direction, release, or playtest.
- Canon files remain authoritative. Operating docs guide work but must not redefine canon.
- Any feature patch must update the relevant operating doc or canon owner when it changes a rule, workflow, data shape, UI behavior, asset path, or release criterion.

## Documentation-Only Patch Rule

- Documentation-only work may edit `AGENTS.md`, `docs/**`, and root status/checklist markdown.
- It must not edit `scripts/**`, `scenes/**`, `assets/**`, `data/**`, `.github/**`, or `project.godot`.
- It must finish with docs reference validation and mojibake scan.

## Mojibake Policy (Non-Negotiable)

- Mojibake characters/sequences are forbidden in source and docs.
- Common forbidden patterns include (not exhaustive): U+00C3, U+00C2, U+FFFD, and malformed UTF-8 quote/dash sequences.
- Do not introduce malformed encoding in any patch.

## Mandatory Correction Rule

- If an agent introduces mojibake in a patch, it must be fixed in the same patch before completion.
- If mojibake is found in touched files during work, fix it before closing the task.
- Do not leave known mojibake as follow-up.

## Verification Before Finalizing

- Run a repository scan for mojibake markers on text files before final response.
- Suggested command:
  - `rg -n -P "\\x{00C3}|\\x{00C2}|\\x{FFFD}" .`
- If matches are real encoding errors, correct them and re-run the scan until clean.
