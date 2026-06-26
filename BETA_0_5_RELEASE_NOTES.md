# Gallicus v0.5 Internal Beta Release Notes

## Status
This is an internal beta target, not a public demo target. The automated CI/Linux runtime gate is signed on run `27264909198` for commit `759c65bdd877251f6d9cf1d715c3dc54fad9cdb1`; local viewport visual QA is green on commit `2cacd70a465e065f2b448654a94c407222a7ad71`. Final v0.5 signoff remains blocked until interactive manual QA is completed.

## Implemented For Beta Track
- Expanded active Level 3 bet identities beyond the two-route prototype baseline.
- Added beta smoke scenario names for cashout, double, condanna, and register-final coverage.
- Added static beta content coverage checks.
- Added a repository text scan for forbidden mojibake markers.
- Added beta plan and playtest checklist artifacts.

## Included Content Targets
- At least 8 active bets.
- At least 4 path families.
- At least 4 arena themes.
- At least 6 ending keys in rules.

## Known Issues
- Local Windows headless runtime smoke remains diagnostic-only if it crashes before `SMOKE:BOOT_OK`.
- Local Windows smoke mode can crash natively before bootstrap even without `--headless`; use CI/Linux smoke as the runtime authority.
- Manual QA has not yet been completed from `BETA_PLAYTEST_CHECKLIST.md`; audio and 3-run interactive coverage remain unsigned.
- This beta does not include action combat or public-demo packaging.

## CI Evidence
- `BET_PRESENT`: passed.
- `FULL_RUN`: passed.
- `BETA_CASHOUT`: passed.
- `BETA_DOUBLE`: passed.
- `BETA_CONDANNA`: passed.
- `BETA_REGISTER_FINAL`: passed.

## Local Visual QA Evidence
- `VISUAL_QA:OK` from `tools/visual_qa_capture.tscn`.
- Screenshots generated in `artifacts/visual_qa/`.
- Expected harness warning accepted: `entry scene is res://tools/visual_qa_capture.tscn`, with no `SANITY FAIL`.

## Post-v0.5 Candidates
- Public demo polish.
- Better ending-specific visual cards.
- Dedicated playtest telemetry.
- Wider platform/export validation.
