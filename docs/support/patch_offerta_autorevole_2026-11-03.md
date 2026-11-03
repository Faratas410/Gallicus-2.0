# Patch 2 Apertura unica e dispatch diretto della scommessa

## Consegna locale del 3 novembre 2026

Implementata su `main`, HEAD `83083b61ed45a60545bd97b245484c163709da7a`
piu' le modifiche locali delle due patch. Nessun commit, push o cambio branch.
La [patch 1](patch_test_semantici_2026-11-03.md) era gia' presente: preservata,
con un seguito circoscritto alla sua fixture di attraversamento descritto sotto.
Snapshot iniziale in `artifacts/patch2_offer/before.json`; hash del candidato
finale e verifiche in `artifacts/patch2_offer/final_checks.json`.

## Comportamento corretto

RunManager prepara gate, stato e offerta completa, inclusi `stake_gain` e
`seal_conditions`, prima di entrare in BET_PRESENT. L'ingresso di fase
conserva il marker senza emettere un array intermedio vuoto. L'operazione di
apertura pubblica una sola `bet_ui_opened`, anche quando la fase e' gia'
BET_PRESENT e durante Continue da BET_OFFER. Policy, seed di produzione,
filtri, prezzi e condizioni restano quelli correnti del catalogo.

E' stato rimosso anche l'ingresso UI su `betting_opened`, che apriva un altro
Registro vuoto. Il segnale resta emesso e consumato dall'audio; la UI apre
il libro dal solo payload `bet_ui_opened`. Il lifecycle osservato e'
`betting_opened -> bet_ui_opened -> bet_opened`, con offerta e gate gia'
pronti al primo evento. HUD, conto e bando restano nel percorso esistente.

`request_place_bet` e `request_intro_select_bet` chiamano direttamente
`select_bet` nel manager. Una sola guardia di fase, gate di attesa/run viva
e appartenenza all'offerta precedono il commit esistente. L'alias intro
conferma ancora il patto: non e' diventato una selezione di anteprima.
Rimossi BETP_PLACE_BET e INTRO_SELECT_BET, adapter e ramo di selezione ormai
inutilizzati; il resto di handler, router, catalogo ed executor resta attivo.

Il catalogo alimenta l'anteprima di boot finche' non arriva un payload
autorevole. Dopo `set_offers`, array vuoti, ID mancanti o sconosciuti non
inventano pagine firmabili. Open/reset non ripristinano il fallback; la
firma rimane bloccata e viene emessa una diagnostica. Apertura confermata,
scrittura, focus, lock, banco e disposizione delle due pagine sono invariati.

## Prove del difetto e regressioni

L'audit esteso sul codice precedente ha fallito su due emissioni per nuova
partita, offerta intermedia vuota, gate non pronto e ripresa BET_OFFER:
`before_audit.log`. Dopo il fix le stesse asserzioni passano. Il contratto
osserva gli eventi mentre il manager resta collegato; non conta stringhe
`.emit` nel sorgente.

L'audit finale (`final_audit.log`) copre:

- ingresso dal Button reale del menu, una pubblicazione completa uguale allo
  stato e una sola apertura del Registro;
- riapertura nella stessa fase e Continue da BET_OFFER con offerta coerente;
- firma mouse, tastiera e alias intro: un evento, una voce in cronologia e
  nel log patti, una sequenza di patto e checkpoint BET_SIGNED letto da disco;
- doppio invio e richieste fuori fase, con ID non offerto o run terminata:
  nessuna mutazione aggiuntiva;
- Continue da BET_SIGNED: rito ripreso senza nuova firma o voci duplicate;
- payload UI vuoto o malformato e reset: nessuna pagina firmabile inventata.

Il test sopprime le sole diagnostiche negative volute e ripristina il logging
prima degli assert. I primi tentativi di input non attraversavano correttamente
l'ingresso UI: corretti l'uso del Button del menu e l'attesa del dialogo
accodato, senza forzare il risultato del manager. I log intermedi sono conservati.

## Verifiche mirate

Tutte le prove sono locali Windows con Godot ufficiale
`4.7.2.stable.official.ed1daf0bf`, Python bundled desktop e profili isolati.
Risultati e comandi in `static_checks.json`, `boundary_checks.json`,
`routes_checks.json`, `presentation_checks.json` e `final_checks.json` sotto
`artifacts/patch2_offer/`.

- Import completato senza errori di script o risorse (`import.log`).
- Contratti statici: offerta, identita', GameEvents, fase/ownership,
  save-flow, ritual loop, movimento, sigillo e invarianti runtime.
- Audit semantico esteso e CP-02: conferma, checkpoint, migrazioni, recupero
  e quarantena, senza modificare schema o boundary save.
- Smoke BET_PRESENT, KEYBOARD_FULL_RUN e ROUTE_DOUBLE: accesso, firma da
  input e ritorno all'offerta nell'arena successiva.
- Contratti `seat_steps_era` e `final_era`: ordine delle scene/overlay,
  persistenza e Banco chiuso nelle entrate interessate.
- Contratto AV reale: continuita' del lifecycle audio e del percorso rituale.
- Contratti della patch 1 rieseguiti sul candidato, inclusa la fixture
  stabilizzata descritta sotto; risultato finale in
  `patch1_regression_retry.log`.
- Capture `registry_volume_capture.gd` su GPU reale OpenGL Compatibility:
  report senza difetti, IT/EN/ES a 720p/1080p, apertura, testo lungo, focus,
  movimento normale/ridotto e firma accettata. Prodotte 32 PNG; sei viste
  ispezionate in `inspected_registry.png`, inventario in `inspected_images.txt`.
  I warning di offerta vuota sono attesi nella prova di sostituzione del
  payload durante l'apertura, non nel percorso di partita normale.

Il processo Godot del capture e' terminato con exit 0. Il collector locale
ha poi fallito la sola rimozione della cache shader temporanea su Windows
(WinError 145): profilo conservato sotto `tmp/registry_63jr6c3v`. Il report
`render_checks.json` distingue i due esiti; non e' un difetto corretto nel gioco.

## Seguito necessario alla fixture della patch 1

La riesecuzione aveva scelto casualmente Raddoppia o Muori e il primo sigillo
fallito aveva chiuso legittimamente la run prima della posta. La fixture
pretendeva la posta indipendentemente dal patto: difetto del driver, non
regressione del dispatch. Log fallito in `patch1_regression_runner.log`.

Il solo percorso nativo della fixture ora usa il seed di prova canonico e
sceglie, fra le due pagine realmente offerte, quella che non impone la morte
al fallimento. L'ambiente di seed e' ripristinato subito dopo Nuova partita,
prima di un tick del driver; nessun override dell'esito, del catalogo o delle
regole di produzione. La matrice e il percorso sono stati ripetuti con il
runner completo della patch 1. Le catture del Registro appartengono al
candidato con gli stessi sorgenti di produzione; questa correzione riguarda
un altro driver di prova.

## File modificati dalla patch 2

- `scripts/systems/run_manager.gd`
- `scripts/systems/run/phase_handlers/phase_bet_present_handler.gd`
- `scripts/systems/run/run_flow_catalog.gd`
- `scripts/ui/ui_root.gd`
- `scripts/ui/betting_circle_ui.gd`
- `scripts/ci/audit_runtime_contract.gd`
- `tools/counter_layout_capture.gd` (seguito alla fixture della patch 1)
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/UI_CANON.md`
- `docs/testing.md`, `docs/development_plan.md`, `docs/README.md` e questa scheda.

Gli altri file della patch 1 sono preservati. I documenti condivisi mantengono
sia la sua consegna sia questa. Il planner valuta il diff locale come full
(`ci_plan.json`); nessun ampliamento della whitelist per ridurre i gate.

## Limiti

Suite completa, campagna completa, export e checkpoint Linux NOT_RUN:
la verifica locale e' selezionata sul boundary modificato e sui consumer
attraversati. Il futuro push richiedera' full con la configurazione attuale.
Save, GameEvents, dati, probabilita', risorse grafiche e schema non sono
cambiati. Le prove automatiche non certificano focus OS, controller fisico,
ritmo, mix o accettazione artistica. Nessuna misura di durata o prestazioni
attribuita a questo refactor. Core Playable Candidate e gate umani/Steam
restano invariati.
