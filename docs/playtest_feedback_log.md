# Gallicus Playtest Feedback Log

## Regola

Ogni feedback deve diventare una decisione: accettare, rimandare, respingere o richiedere riproduzione. Non lasciare note vaghe.

## Stato corrente

Nessuna sessione manual QA v0.5 completa registrata in questo log.

## Schema entry

Usare questo formato per nuove righe:

| Data | Build | Area | Severita' | Osservazione | Decisione | Stato |
| --- | --- | --- | --- | --- | --- | --- |

## Feedback registrati

| Data | Build | Area | Severita' | Osservazione | Decisione | Stato |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-06-24 | local visual QA | UI bet | Important | Una bet lunga puo' spezzare male il testo nella card Registro. | Accettare: accorciare copy o adattare label. | Fixed in local patch pending full visual QA. |
| 2026-06-24 | local visual QA | END_RUN | Important | I bottoni finali possono sembrare disabilitati durante o dopo il reveal. | Accettare: rendere lo stato attivo piu' chiaro. | Fixed in local patch pending full visual QA. |
| 2026-06-24 | local visual QA | Rito | Important | Il pannello centrale del rito puo' sembrare vuoto o poco istruttivo. | Accettare: copy istruttivo breve. | Fixed in local patch pending full visual QA. |

## Chiusura

Quando una voce diventa `Fixed`, verificare con il test indicato in `docs/testing.md` prima di marcarla non bloccante.
