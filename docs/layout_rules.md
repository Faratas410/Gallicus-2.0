# Gallicus Layout Rules

## Baseline

La UI deve essere leggibile almeno a:
- 1280x720;
- 1920x1080.

La priorita' e' playtest, non polish pubblico.

## Regole generali

- Nessun testo importante deve uscire dal contenitore.
- Nessuna parola deve spezzarsi in modo antiestetico su card o bottoni.
- I bottoni attivi devono distinguersi dai disabilitati.
- Ogni modale deve avere titolo, stato e prossima azione.
- Le CTA devono essere cliccabili nel corpo del bottone, non solo su label.
- Le CTA player-facing devono essere progettate come interazione con un oggetto diegetico quando possibile; il bottone resta input tecnico, non concept primario.

## Schermate critiche

- Menu: obiettivo leggibile.
- Registro: due offerte leggibili.
- Patto: conferma e avanzamento chiari.
- Scelta intermedia: due opzioni confrontabili.
- Rito: istruzione e feedback colpi.
- Push-your-luck: incassa, condanna, rilancia leggibili.
- END_RUN: esito e route restart/next/menu.

## Object-first layout

Per le patch UI successive, usare `docs/object_grammar.md` prima del layout:

- ogni comando importante deve avere un oggetto visivo o testuale riconoscibile;
- ogni oggetto deve mostrare stato, rischio o conseguenza;
- le label non devono essere l'unica fonte di comprensione;
- se la metafora riduce leggibilita', semplificare la metafora e mantenere il testo chiaro.

## Motion

- Motion ammessa se aiuta feedback o mood.
- Motion vietata se sposta target cliccabili in modo frustrante.
- Pulse e flash devono essere brevi e non coprire testo.

## Screenshot QA

Se una patch cambia UI o copy visibile, catturare le schermate critiche indicate in `docs/testing.md`, salvo richiesta contraria dell'utente.

## Verifica

Eseguire:

```powershell
python scripts/ci/test_ui_motion_contract.py
python scripts/ci/test_pressure_presentation_contract.py
```
