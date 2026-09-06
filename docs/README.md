# Gallicus Documentation Operating System

Questo e' l'entrypoint operativo del progetto. Gallicus ha un solo target di
prodotto: **Gallicus 1.0**, una campagna rituale finita da pubblicare su Steam.

La documentazione attiva non usa versioni intermedie per descrivere il
progresso. Le fasi di lavoro hanno nomi operativi e gate verificabili.

## Ordine di lettura

1. `docs/design_skeleton.md` - promessa di prodotto, stato reale e Definition of Done.
2. `docs/development_plan.md` - roadmap sequenziale verso 1.0 e prossimo step.
3. `docs/development_workflow.md` - ciclo di sviluppo con Astra e consegna locale.
4. `docs/game_design.md` - esperienza, loop e campagna completa.
5. `docs/object_grammar.md` - grammatica obbligatoria per le azioni gameplay.
6. `docs/testing.md` - verifiche statiche, runtime, visuali e manuali.
7. `docs/code_quality.md` - ownership e disciplina prima di cambiare runtime.
8. Documento di dominio pertinente; `docs/steam_release.md` per la distribuzione.
9. Canon owner pertinente, se la patch cambia una regola o un contratto.

## Owner documentali

| Domanda | Owner |
| --- | --- |
| Che gioco stiamo finendo? | `docs/design_skeleton.md` |
| Qual e' il prossimo blocco implementabile? | `docs/development_plan.md` |
| Come lavora Astra e come consegna? | `docs/development_workflow.md` |
| Come funziona l'esperienza? | `docs/game_design.md` |
| Quale oggetto rende reale un'azione? | `docs/object_grammar.md` |
| Come appare? | `docs/art_direction.md` e `docs/layout_rules.md` |
| Come suona? | `docs/audio_direction.md` |
| Quando usa una sequenza cinematica? | `docs/cinematic_direction.md` |
| Come parla e quali contenuti contiene? | `docs/content_bible.md` |
| Come sono strutturati dati e save? | `docs/data_schema.md` |
| Come si producono asset runtime? | `docs/asset_pipeline.md` |
| Come si verifica? | `docs/testing.md` |
| Cosa blocca la release? | `docs/release_checklist.md` |
| Come arriviamo alla pubblicazione Steam? | `docs/steam_release.md` |
| Come si conduce un playtest? | `docs/playtest_guide.md` |
| Quali requisiti hanno accessibilita' e lingue? | `docs/accessibility_localization.md` |
| Quali rischi di tono vanno controllati? | `docs/ethics_and_representation.md` |

## Autorita'

Ultima evidenza locale: `docs/support/av_pass_2026-09-06.md`, con inventario
dei file, verifiche AV, build Windows e limiti ancora aperti verso Steam.

- `docs/canon/` contiene le regole canoniche e prevale sui documenti operativi.
- `docs/contracts/` contiene superfici tecniche controllate anche dalla CI.
- `docs/support/` contiene inventari e procedure subordinate agli owner.
- `docs/archive/` contiene sola lineage storica non operativa.
- `RunManager` resta l'unica autorita' del flow.
- `GameEvents` resta il bus eventi.
- La UI emette intenti e reagisce a payload; non decide outcome.

## Regole di aggiornamento

- Una feature player-facing parte da
  `intento -> oggetto -> gesto -> feedback -> registrazione`.
- Un cambio di flow aggiorna `docs/canon/RUN_ARCHITECTURE_CANON.md`.
- Un cambio di regola aggiorna `docs/canon/MECHANICS_UNIFIED.md`.
- Un cambio di contratto UI aggiorna `docs/canon/UI_CANON.md`.
- Un cambio a dati o save aggiorna `docs/data_schema.md` e i contratti.
- Un cambio visuale aggiorna art direction, layout o asset pipeline.
- Un cambio audio aggiorna `docs/audio_direction.md`.
- Un cambio di copy o contenuto aggiorna `docs/content_bible.md`.
- Un cambio di workflow aggiorna `docs/development_workflow.md` e le regole agent pertinenti.
- Un cambio di distribuzione aggiorna `docs/steam_release.md` e la release checklist.
- Ogni blocco concluso aggiorna `docs/development_plan.md`.

## Affidabilita'

- Audit trasversale del 4 settembre 2026: `docs/support/audit_2026-09-04.md`.
  Contiene prove locali, lacune e priorita'; non sostituisce i gate della roadmap.

- I path citati dalla documentazione attiva devono esistere.
- I documenti non possono dichiarare completato un gate senza prova.
- I nomi tecnici legacy non definiscono lo stato del prodotto.
- Nessun documento attivo puo' reintrodurre milestone di versione superate.
- Verifica riferimenti:

```powershell
python scripts/ci/check_docs_active_refs.py
```

- Verifica encoding:

```powershell
python scripts/ci/test_no_mojibake.py
rg -n -P "\x{00C3}|\x{00C2}|\x{FFFD}" .
```

## Bonifica successiva all'audit

`docs/support/bonifica_2026-09-04.md` raccoglie modifiche, prove locali,
inventario dei file e limiti ancora aperti del nuovo tema e della campagna.

La revisione del titolo, delle frasi e della ripresa del menu e' documentata
in `docs/support/menu_identity_2026-09-05.md`.
