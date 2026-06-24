# Gallicus Development Plan

## Stato

Gallicus e' una v0.5 internal beta candidate. La CI/Linux beta smoke matrix risulta verde nella documentazione di stato corrente, ma la firma finale richiede manual QA completa.

## Storico breve

- v0.1 playable prototype: loop rituale end-to-end reso giocabile.
- v0.2 candidate: smoke canonici e beta matrix stabilizzati su CI/Linux.
- v0.5 candidate: contenuto beta, audio/feedback base e schermate principali presenti.

## Blocco attivo 1 - QA Lock v0.5

Obiettivo: chiudere i blocker che impediscono una sessione tester senza guida.

Criteri:
- 3 run consecutive nella stessa sessione.
- Almeno un ramo cashout, uno double e uno condanna verificati manualmente.
- Restart, prossima scommessa, menu, settings e audio verificati.
- Nessun fatal error, texture mancante, audio path mancante o modale bloccata.

## Blocco attivo 2 - Readability Pass

Obiettivo: rendere sempre chiari obiettivo, prossima azione, rischio e conseguenza.

Criteri:
- Bet leggibili a 1280x720 e 1920x1080.
- Push-your-luck spiega incassa, condanna e rilancia.
- END_RUN mostra esito e vie d'uscita senza ambiguita'.
- Pannello segni e pressione riflettono lo stato percepibile della run.

## Blocco attivo 3 - Release Package Interno

Obiettivo: produrre un pacchetto interno testabile e tracciabile.

Criteri:
- `docs/release_checklist.md` completata.
- `docs/playtest_feedback_log.md` aggiornato con eventuali sessioni.
- Stato v0.5 firmato solo dopo CI verde e manual QA verde.
- Known issues classificati come non bloccanti.

## Post v0.5

- Maggiore varieta' contenuti, solo se non rompe il loop.
- Polish UI/audio piu' ricco.
- Packaging pubblico, trailer, pagina store e build multi-platform.
- Eventuali cinematiche solo dopo playtest sul loop.

## Prossimo step operativo

Completare manual QA v0.5 usando `docs/playtest_guide.md` e `BETA_PLAYTEST_CHECKLIST.md`, poi aggiornare `BETA_0_5_STATUS.md`, `BETA_0_5_RELEASE_NOTES.md` e `docs/playtest_feedback_log.md`.
