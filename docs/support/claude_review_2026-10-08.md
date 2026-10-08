# Verifica Claude e pass UI/cast - 8 ottobre 2026

## DIAGNOSIS

Base: `da99a64`, main pulito all'ingresso. Ambito: rework e loop di ottobre,
arena attiva, conto di Vessa, racconti, bando, scala e catena; regressioni
sulla campagna esistente. Candidato finale: working tree locale non
committato, nessun export, push o pubblicazione.

Il menu e la prima copia hanno gia' luogo e materiali coerenti. Registro,
patto, gesto, sigillo e HUD ripetono cornici regolari e descrizioni fitte.
Il banco comprime servizio, effetto e prezzo. Vessa e Orvo sono centrali
nelle nuove regole ma privi di ritratti; il museo mostra solo biografie.

Il playtest diretto usa un profilo separato. Passi osservati:

1. Menu e ingresso: funzionanti, marchio e soglia leggibili.
2. Prima copia: ritratto, lettura manuale e salto funzionanti.
3. Bando e banco a conto zero: accessibili, servizi indisponibili.
4. Registro aperto e firma: due promesse confrontabili, costi leggibili.
5. Patto: passaggio funzionante; superficie troppo simile alle altre.
6. Tre scambi: risposte e variazioni di favore/Pressione osservate.
7. Sigillo: colpo, responso retto e alzata della mano funzionanti.
8. Quietanza: incasso di 3 Gloria; route al fascicolo funzionante.
9. Fascicolo: esito, bando mancato e prossimo premio presenti.

Schermate dirette in `artifacts/claude_review_2026-10-08/manual_before/`.
La prima cattura sbagliata, che mostrava un'altra app, e' stata scartata e
sostituita con il menu reale. L'utente ha interrotto la sessione e chiesto
di lavorare su quanto gia' visto: nessun ulteriore playtest visibile richiesto.
Queste osservazioni non provano divertimento, durata o accettazione umana.

## WORKFLOW

- Oggetto: Registro, banco, bando e schede consultabili esistenti.
- Intento/gesto: lettura, firma e acquisto tramite gli input gia' presenti.
- Costo e risposta della gradinata: payload esistenti di RunManager; la
  patch non introduce nuovi esiti, prezzi, probabilita' o progressione.
- Feedback: superfici materiche condivise e ritratti associati al ruolo.
- Registrazione: nessun nuovo stato o campo save.

Tre PNG originali, ispezionati e conservati senza ritocchi: Vessa, Orvo e
basalto lavorato. Prompt, sorgente, consumer e SHA256 nel manifest. Nerio e'
il riferimento di stile dei due ritratti. Le sette risorse generiche di
pannello condividono il nuovo basalto; gli oggetti rituali restano distinti.
I ritratti ignorano input. Nell'Archivio sono presenti tutti i cinque aviari.

Banco: tre righe (servizio, effetto, prezzo), wrapping, note almeno 15 px.
Le biografie assemblate sono gia' localizzate e disabilitano la traduzione
automatica aggiuntiva del Label. La prima matrice aveva testo misto in una
cattura ES: non viene adottata come prova visiva finale della lingua.

Lo smoke ROUTE_CASHOUT falliva anche sul lavoro precedente: l'attore
abbassava sempre lo sguardo, provocava una rivolta e arrivava al marchio
senza incassare. Corretto solo il criterio del driver smoke per quella
route: sfida su sangue/noia, si ripara su sabbia/fiato. Risposte, esiti e
soglie sono naturali; il validatore continua a richiedere l'intento incasso.

## Prove e limiti

- Candidato locale finale: 45/45 controlli statici PASS, incluse docs refs,
  res paths, i18n, ownership e mojibake; `git diff --check` e scan `rg` puliti.
- Regressione headless finale: quattro route canoniche e CORE_CONTINUITY,
  5/5 validatori PASS, piu' contratto cast/biografie localizzate PASS.
  Risultati in `artifacts/claude_review_2026-10-08/lean/` e
  `character_language_final.log`. Nessun nuovo playtest visibile.

- Campagna iniziale reale tramite controlli UI, seed e tempo controllati:
  48 percorsi, quattro riprese, Assenza e reboot terminale PASS. Questa
  strategia si ferma al gradino 5; non copre tutti gli otto racconti.
- Seconda strategia sul candidato: legge gli intenti, acquista al banco e
  persegue il bando. 46 percorsi, 207 acquisti con prezzo addebitato verificato,
  gradino 12 e tutti gli otto racconti prima del congedo, Assenza e ripresa
  interna PASS. Log: `artifacts/claude_review_2026-10-08/bando_journey.log`.
  E' una simulazione accelerata, non misura la durata umana.
- Matrice di layout banco/debito/disponibilita' e impostazioni: 24 catture
  IT/EN/ES a 720p/1080p, contenimento dei pulsanti, disponibilita', nota e
  assenza di sovrapposizione ritratto/banco PASS. Fixture di presentazione:
  non modifica il saldo del save.
- Contratto del cast e scroll: PASS; nuovo controllo della biografia
  localizzata PASS headless. La ricattura finale completa del cast e' stata
  interrotta e non viene dichiarata chiusa.
- Import Godot 4.6.2 PASS senza errori di parser/risorse dopo aver isolato
  APPDATA, LOCALAPPDATA e TEMP nel workspace. I tentativi iniziali fallivano
  per accesso ai profili/temp dell'ambiente, non vengono contati come PASS.
- ROUTE_CASHOUT corretto: exit 0 e validatore PASS. La suite cumulativa in
  corso e' stata interrotta; i suoi risultati parziali non sono signoff.

Il warning ObjectDB al teardown resta visibile nelle campagne automatiche.
La fixture CP02 provoca intenzionalmente un errore JSON corrotto per
verificare recupero/quarantena; il marker di contratto non significa log
privo di diagnostica. Nessun checkpoint Linux o gate CP-03 chiuso.

## NEXT ACTION

Revisione umana del candidato locale quando desiderata. Avvio con profilo
dedicato: `tools/Playtest Visual Review.cmd`, audio attivo e campagna fresca.
La patch non dipende dall'EXE storico. Dopo il commit manuale dell'utente,
checkpoint Linux del candidato; messa in scena completa delle Ere, ritmo,
comfort e accettazione del cast rimangono gate umani.

## EXPECTED HANDOFF

File modificati:

- `scripts/ui/main_menu.gd`, `scripts/ui/betting_circle_ui.gd`:
  cast nell'Archivio e righe del banco.
- `scripts/content/arena_characters.gd`: path dei cinque ritratti.
- `scenes/UI.tscn`, `scenes/ui/BettingCircle.tscn`: note HUD, ritratti e banco.
- `scripts/systems/run_manager.gd`: sola scelta del driver ROUTE_CASHOUT.
- `scripts/ci/character_runtime_contract.gd`: ritratti, biografie e scroll.
- `assets/ui/generated/basalt_worked.png`, `dialogue_vessa.png`,
  `dialogue_orvo.png`, relativi sidecar `.import` e `manifest.json`.
- `assets/ui/official/styleboxes/sb_panel_main.tres`,
  `sb_mid_choice_panel.tres`, `sb_pressure_rail.tres`, `sb_register_slab.tres`,
  `sb_register_slab_closed.tres`, `sb_scars_dossier.tres`,
  `sb_settings_header.tres`: materiale condiviso.
- `tools/claude_review_capture.gd` e `.uid`,
  `tools/claude_review_journey.gd` e `.uid`, `tools/Playtest Visual Review.cmd`:
  prove e launcher locale.
- `docs/README.md`, `docs/development_plan.md`, `docs/art_direction.md`,
  `docs/layout_rules.md`, `docs/testing.md`, `docs/canon/UI_CANON.md` e questo report.

Evidenza completa in `artifacts/claude_review_2026-10-08/`; le sottocartelle
`baseline_isolated` e `final` contengono tentativi intermedi/interrotti,
non prove cumulative adottate. Nessun commit o branch creato.

`candidate.json` nella cartella evidenza lega HEAD, dirty state e SHA256
di tutti i file della patch alle verifiche, senza inventare un export.

## Integrazione dei ritratti - richiesta successiva

Il fondo nero dei ritratti rendeva evidente un rettangolo separato dalla UI.
Nerio, Rugo, Dima, Vessa e Orvo ora usano varianti ImageGen RGBA 1024x1536
`dialogue_*_cutout.png`, con alpha reale e sorgenti opache preservate.
Il manifest include prompt, riferimento, sorgente e SHA256 per ogni variante.
Le identita', il piumaggio, gli abiti e gli oggetti seguono i ritratti esistenti.

Il materiale statico condiviso sfuma l'ultimo 10 percento del busto sulla
pietra. Nei dialoghi la sagoma avanza di 20 px, copre 28 px del bordo sinistro
del pannello e lascia 12 px prima dell'inizio del testo. Archivio e Registro
mantengono geometria e input; niente pannelli propri del personaggio.
Il terminale del Registro conserva la sua rappresentazione di macchina.

Prova aggiunta: import Godot pulito, cinque alpha verificati (28-37 percento
dei pixel completamente trasparenti, corpo sostanzialmente opaco), 54 catture
con GPU reale in IT/EN/ES a 720p/1080p. Campionamento visuale: tutte le cinque
sagome, tre superfici e due risoluzioni; nessun fondo nero o testo coperto.
La cattura finale ES mostra biografie spagnole, correggendo la precedente
evidenza mista. Le catture Archivio rendono una voce interamente visibile;
le voci adiacenti possono essere tagliate dal normale scroll.

Verifiche sul candidato con cutout: 45/45 controlli statici PASS, contratto
cast/biografie/scroll PASS e contratto conversazioni PASS (input iniziale,
mouse/Enter, skip, focus restituito, ripresa e indipendenza dalla run).
Tutti con exit 0; import, cattura e due contratti non contengono errori
parser/risorse o warning. Docs refs, mojibake e `git diff --check` puliti.

Evidenza: `artifacts/claude_review_2026-10-08/portrait_integration/`,
`alpha_validation.json`, `import_portraits.log`. Le catture sono fixture di
presentazione, con saldo banco 20; HUD iniziale e dati non rappresentano
una run reale. Non sostituiscono accettazione umana o checkpoint Linux.

File aggiunti/modificati per questa integrazione:

- Cinque `assets/ui/generated/dialogue_*_cutout.png` e relativi `.import`;
  `assets/ui/generated/manifest.json`.
- `assets/ui/official/portrait_grounding.gdshader`, relativo `.uid` e
  `portrait_grounding.tres`.
- `scripts/content/arena_characters.gd`, `campaign_dialogues.gd`:
  binding dei ritratti; `scripts/ui/main_menu.gd`, `opening_prologue.gd`:
  materiale e composizione; `scenes/ui/BettingCircle.tscn`: sagome sul Registro.
- `tools/portrait_integration_capture.gd` e `.uid`: cattura mirata.
- `docs/art_direction.md`, `layout_rules.md`, `canon/UI_CANON.md`,
  `development_plan.md`, `testing.md` e questo report.

Il fingerprint aggiornato e' `candidate_portraits.json`; il precedente
`candidate.json` descrive la patch prima delle sagome trasparenti.
