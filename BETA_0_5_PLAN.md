# Gallicus v0.5 Internal Beta Plan

## Classification
Current state is `v0.2 candidate`, not v0.5. It becomes `v0.2 signed` only after canonical CI/Linux smoke passes for `BET_PRESENT` and `FULL_RUN`.

`v0.5 internal beta` means a controlled playtest build: stable enough for testers without live guidance, not a public demo.

## Milestones
- `v0.2 signed`: canonical smoke green, no fatal errors, no mojibake in active text.
- `v0.3 content expansion`: at least 8 active bets, 4 path families, 4 arena themes, 6 reachable ending keys.
- `v0.4 readability`: clear objective, next action, risk, consequence, finale, restart/next-run route.
- `v0.5 internal beta`: 20-30 minute internal playtest package with QA checklist, release notes, known issues, and green beta smoke matrix.

## Implementation Rules
- Keep the ritual loop canonical: menu, bet, pact ritual, intermediate choice, resolve ritual, push-your-luck, END_RUN.
- Do not add action combat, enemies, physical player movement, or a new progression architecture.
- Expand content through existing systems: `BetCatalog`, condanne, arena themes, ending rules.
- `RunManager` remains flow authority; UI remains reactive; `GameEvents` remains the bus.

## Beta Content Targets
- Active bets: 8 or more.
- Path families: prudence, hubris, penitence, violence.
- Arena themes: 4 readable themes.
- Ending keys: 6 or more reachable classifications.
- Smoke matrix: `BET_PRESENT`, `FULL_RUN`, `BETA_CASHOUT`, `BETA_DOUBLE`, `BETA_CONDANNA`, `BETA_REGISTER_FINAL`.

## Exit Criteria
- Static CI suite passes.
- Godot import headless passes.
- Canonical Linux smoke matrix passes.
- Manual QA covers 3 consecutive runs without restarting the executable.
- Known issues are documented and non-fatal for internal testers.
