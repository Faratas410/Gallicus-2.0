# Gallicus Release Checklist

## Classificazioni

- Internal beta candidate: CI smoke verde, ma manual QA non completa.
- v0.5 internal beta signed: CI/Linux smoke verde, static suite verde, manual QA verde.
- Release candidate pubblica: fuori scope corrente.

## Preflight statico

- Static suite da `docs/testing.md`.
- `python scripts/ci/check_docs_active_refs.py`.
- `python tools/ci/verify_res_paths.py`.
- `python scripts/ci/test_no_mojibake.py`.
- Scan `rg -n -P "\x{00C3}|\x{00C2}|\x{FFFD}" .`.

## Runtime signoff

- Godot import headless.
- CI/Linux workflow `Godot Smoke Runtime`.
- Scenari beta tutti verdi.
- Nessun fatal error nei log.

## Manual QA

- Usare `BETA_PLAYTEST_CHECKLIST.md`.
- 3 run consecutive.
- Copertura cashout, double, condanna.
- Restart, next bet, menu, settings, audio.
- Screenshot se cambia UI/asset.

## Documenti da aggiornare prima della firma

- `BETA_0_5_STATUS.md`.
- `BETA_0_5_RELEASE_NOTES.md`.
- `docs/development_plan.md`.
- `docs/playtest_feedback_log.md` se ci sono sessioni.

## Blocchi che impediscono v0.5 signed

- CI/Linux smoke fallita.
- Fatal error o modale bloccata.
- Testi corrotti o mojibake.
- Route di uscita finale non funzionante.
- Manual QA incompleta.
