# Gallicus Documentation Operating System

Questo e' l'entrypoint operativo per lavorare su Gallicus senza ricostruire il progetto dalla chat.

I documenti in `docs/canon/` restano autoritativi. I documenti operativi qui sotto spiegano come lavorare, verificare e preparare playtest/release senza cambiare il core di gioco.

## Ordine di lettura

1. `docs/design_skeleton.md` - stato sintetico del progetto e confini.
2. `docs/development_plan.md` - roadmap corrente e prossimo passo.
3. `docs/testing.md` - comandi e criteri di chiusura.
4. `docs/code_quality.md` - regole prima di toccare codice.
5. Documento di dominio pertinente: UI, asset, contenuto, schema dati, release o playtest.
6. Canon owner pertinente in `docs/canon/` se la patch cambia una regola o un contratto.

## Documenti operativi

| File | Uso |
| --- | --- |
| `docs/design_skeleton.md` | Sintesi verificabile del progetto, loop, stato e limiti. |
| `docs/development_plan.md` | Roadmap viva verso v0.5 internal beta e oltre. |
| `docs/code_quality.md` | Regole di modifica, ownership, refactor ammessi e vietati. |
| `docs/testing.md` | Static suite, Godot, CI smoke, manual QA e criteri di accettazione. |
| `docs/game_design.md` | Loop rituale, sistemi attivi, progressione e fuori scope. |
| `docs/content_bible.md` | Tono, grammatica di copy, lore runtime e contenuti vietati. |
| `docs/data_schema.md` | Cataloghi, payload, save/runtime fields e validazione. |
| `docs/layout_rules.md` | Regole UI, leggibilita', motion e screenshot QA. |
| `docs/asset_pipeline.md` | Naming, path, import, audio, fallback e verifica asset. |
| `docs/art_direction.md` | Mood visivo, palette, materiali e divieti di stile. |
| `docs/ethics_and_representation.md` | Rischi di tema, pubblico, rappresentazione e copy. |
| `docs/release_checklist.md` | Checklist per beta, release candidate e signoff. |
| `docs/playtest_guide.md` | Istruzioni tester e sessione target. |
| `docs/playtest_feedback_log.md` | Log normalizzato feedback -> decisione -> stato. |

## Canon e supporto

- `docs/canon/` - owner canonici e governance.
- `docs/contracts/` - contratti tecnici usati anche da tooling/CI.
- `docs/support/` - mappe, indici e riferimenti operativi non canonici.
- `docs/reports/` - report correnti.
- `docs/archive/` - materiale storico non operativo.

## Regole di aggiornamento

- Ogni feature che cambia runtime authority aggiorna `docs/canon/RUN_ARCHITECTURE_CANON.md`.
- Ogni feature che cambia regole di gioco aggiorna `docs/canon/MECHANICS_UNIFIED.md` e `docs/game_design.md`.
- Ogni feature che cambia UI aggiorna `docs/canon/UI_CANON.md` se cambia contratto, altrimenti `docs/layout_rules.md`.
- Ogni feature che cambia asset aggiorna `docs/asset_pipeline.md` e, se cambia mood, `docs/art_direction.md`.
- Ogni feature che cambia copy, lore o contenuti aggiorna `docs/content_bible.md`.
- Ogni modifica a dati runtime aggiorna `docs/data_schema.md`.
- Ogni patch che avvicina una build aggiorna `docs/development_plan.md`, `docs/release_checklist.md` o il log playtest.

## Regola di affidabilita'

- I path sotto `docs/` citati dalla documentazione attiva devono esistere.
- Le fonti storiche assorbite nei canon sono indicate come `legacy:<slug>`.
- `docs/archive/` e i marker `legacy:<slug>` non sono source operative.
- La verifica e' `python scripts/ci/check_docs_active_refs.py`.
