# Gallicus Testing

## Static suite base

Usare Python disponibile nell'ambiente. In Codex desktop puo' essere necessario il runtime bundled.

Comandi:

```powershell
python scripts/ci/test_headless_smoke_validator.py
python scripts/ci/check_docs_active_refs.py
python tools/ci/verify_res_paths.py
python scripts/ci/test_playable_slice_contract.py
python scripts/ci/test_era_visual_template_audit.py
python scripts/ci/test_pressure_presentation_contract.py
python scripts/ci/test_ui_motion_contract.py
python scripts/ci/test_beta_content_contract.py
python scripts/ci/test_no_mojibake.py
```

Se `python` non e' nel PATH, usare l'interprete bundled indicato dagli strumenti dell'ambiente.

## Mojibake scan

Obbligatorio prima di chiudere:

```powershell
rg -n -P "\x{00C3}|\x{00C2}|\x{FFFD}" .
```

Exit code 1 senza output significa nessun match.

## Godot import

Usare il Godot locale solo quando la patch tocca scene, asset, import, UI runtime o smoke.

Comando diagnostico Windows:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --editor --path . --quit
```

Windows local smoke e' diagnostico. La firma automatica valida resta CI/Linux.

## CI/Linux smoke

Workflow canonico: `.github/workflows/godot_smoke_runtime.yml`.

Scenari richiesti:
- `BET_PRESENT`
- `FULL_RUN`
- `BETA_CASHOUT`
- `BETA_DOUBLE`
- `BETA_CONDANNA`
- `BETA_REGISTER_FINAL`

La firma richiede summary `OK` per tutti gli scenari su Linux CI.

## Manual QA v0.5

Usare `docs/playtest_guide.md` e `BETA_PLAYTEST_CHECKLIST.md`.

Accettazione minima:
- launch, menu, new run, bet/sign, pact, mid choice, resolve, push-your-luck, finale;
- 3 run consecutive senza riavvio;
- cashout, double e condanna coperti;
- restart, next, menu, settings e audio verificati;
- nessun fatal error o blocco.

## Screenshot QA

Obbligatoria se cambia UI, asset visuale o copy in schermata critica.

Punti minimi:
- menu;
- registro chiuso;
- scelta bet;
- patto;
- scelta intermedia;
- rito di giudizio;
- push-your-luck;
- END_RUN.

Se l'utente chiede esplicitamente di non eseguire screenshot, registrare la mancata validazione nel final.
