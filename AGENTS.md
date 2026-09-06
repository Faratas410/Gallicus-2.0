# Agent Rules (Repository-Local)

These rules apply to all coding agents working in this repository.

## Project Operating Contract

- Official project: Gallicus 2.0.
- Stack: Godot 4.6.2, GDScript, Python CI helpers.
- Active game target: Gallicus 1.0, a finite ritual campaign ending in the Absence of Register.
- Release surface: Windows x64 in Italian, English, and Spanish; Linux is the canonical CI surface.
- Distribution target: Steam publication; follow `docs/steam_release.md` without treating local export or product signoff as publication.
- Development progress is tracked through named roadmap stages, not intermediate product versions.
- Current gameplay authority must not move: `RunManager` owns flow, `GameEvents` is the event bus, UI is reactive.
- Core gameplay, phase ownership, save flow, signal contracts, and canon rules may not be changed during documentation-only work.

## Local Delivery Workflow

- Agents must leave completed and verified changes in the local working tree by default.
- Agents work directly on the local `main` branch by default and must not create or switch to feature branches unless the user explicitly requests it.
- Agents must not create commits, push any ref, open pull requests, mark pull requests ready, or merge them unless the user explicitly requests that specific action.
- The user reviews, commits, and pushes local changes manually from `main` with GitHub Desktop.
- Final handoff must list the changed files and the verification performed.

## Documentation Operating System

- Start from `docs/README.md` before changing project docs.
- Use `docs/development_plan.md` for current roadmap and next operational step.
- Use `docs/development_workflow.md` for the Astra development cycle and evidence handoff.
- Use `docs/testing.md` for local/CI/manual acceptance gates.
- Use `docs/code_quality.md` before touching runtime code.
- Use the domain document that matches the change: design, content, data, layout, asset, art direction, release, or playtest.
- Canon files remain authoritative. Operating docs guide work but must not redefine canon.
- Player-facing gameplay features must use `docs/object_grammar.md` before layout or CTA design.
- Any feature patch must update the relevant operating doc or canon owner when it changes a rule, workflow, data shape, UI behavior, asset path, or release criterion.

## Astra Development Workflow

- Reference development model: GPT-6 Astra (`gpt-6-astra`). Respect the user's explicit model and effort selection; do not silently substitute models or alter app settings.
- Complete bounded, authorized packages through diagnosis, implementation, relevant checks, and local handoff. Use one responsible agent; delegate only when explicitly requested.
- Preserve pre-existing local changes. Tie evidence to the actual candidate: commit, dirty state, and export manifest/hash where relevant.
- Distinguish local verification, canonical Linux signoff, human playtest acceptance, and Steam publication. Model output and automated smoke cannot substitute for required human sessions.
- Prepare reviewable Steam deliverables within scope; payments, uploads, submissions, public changes, and release require authorization for that action. The roadmap itself grants none.

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
