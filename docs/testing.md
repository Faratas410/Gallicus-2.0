# Gallicus Testing

## Principio

Giudizio e sigillo, 9 ottobre: `tools/counter_layout_capture.gd --
--judgment-only` produce 52 viste IT, 720p/1080p e motion normale/ridotto.
Include focus/hover/pressed, lock e recovery, colpi 1/2/3, arresto,
incrinato, Segno offerto e mostrato. Verifica target fermo, contenuto nel
pannello e un solo intent da Invio/ripetizione sui due Button. Nella matrice
si scollega solo il ricevitore del manager e si iniettano risposte di
presentazione; il percorso `--pact-crowd-flow-only` usa invece il manager
reale fino alla posta. Il campionario clona il pannello nativo fuori dal
runtime e riusa adapter e helper visivi degli incavi, senza aggiungere
la sorgente alla SceneTree. Evidenze:
`docs/support/manifesto_judgment_2026-10-09.md`.

Patto e Gradinata, 9 ottobre: `tools/counter_layout_capture.gd --
--pact-crowd-only --capture-dir=<directory>` copre 64 viste di presentazione
IT a 720p/1080p, entrambe le modalita' motion: focus, hover, pressed,
validated/selected/disabled, tre scambi, favore -4/0/+4 ed effetti lunghi.
Testi identici nei confronti; prezzi reali dal catalogo del manager.
Include inoltre un percorso via Button/Invio: firma, Patto, tre scambi,
giudizio e posta. La sola condizione di scenario imposta l'arena speciale
sulla prima arena nel profilo usa e getta; transizioni e conseguenze sono
risolte da RunManager. Il campionario ha una sezione Patto/Gradinata con
gli stessi adattatori e selettore degli stati. Report:
`docs/support/manifesto_pact_crowd_2026-10-09.md`.

Kit UI, 9 ottobre 2026: `tools/manifesto_kit_capture.gd` verifica il
campionario con renderer reale, IT di default e due risoluzioni.
`--all-languages` riattiva IT/EN/ES. Controlla
risorse di traduzione caricate, ingombri, idempotenza dell'adattatore,
passaggio mouse dalle note al Button, invio singolo da click/Invio e blocco.
`tools/counter_layout_capture.gd -- --all-languages` copre le schermate
integrate; il kit non cambia il default IT della fixture storica.
Report e comandi: `docs/support/ui_kit_2026-10-09.md`.

Pacchetto Registro del 9 ottobre: `tools/counter_layout_capture.gd --
--registry-only --capture-dir=<directory>` produce 64 viste IT a 720p/1080p
in entrambe le modalita' motion. Usa gli stessi dati di catalogo nei
prima/dopo; per la firma reale ripristina le offerte preparate dal manager.
Include banco -5/0/20, input mouse, selected/signed, offerta mancante,
testo lungo all'inizio/fine, riapertura, lock e firma tramite Invio fino
al Patto. Le viste signed sono fixture di presentazione, non prove di save.
Controlla contenimento di documenti e servizi, altezza del testo o scroll
attivo, skin dentro i target e focus dopo la chiusura. Il campionario ha
una sezione Registro/banco/firma con gli stessi adattatori del gioco.
Report: `docs/support/manifesto_registry_2026-10-09.md`.

Review temporanea richiesta dall'utente, 8 ottobre 2026: per il primo pass
materiale del Manifesto, catture e prove runtime soltanto in italiano.
`tools/counter_layout_capture.gd` usa IT di default; `--all-languages`
riattiva esplicitamente IT/EN/ES. EN/ES restano nel prodotto e nei contratti
statici di integrita' delle risorse, ma non sono validati visivamente da
questo pass. Il target di release trilingue resta invariato. Evidenze:
`docs/support/manifesto_material_2026-10-08.md`.

Il contratto AV comprende `scripts/ci/character_runtime_contract.gd`: tre
Gufi, un gallo, una gallina, uno storno e quaranta scambi, localizzazione, selezione deterministica senza mutazioni,
soppressione terminale/Silenzio e ingombri alle due risoluzioni. Con renderer
e `--capture-dir=<directory>` produce 240 viste di dialogo e 42 dell'Archivio
(sei iniziali e trentasei scorse sulle sei schede, incluso Lauro).
Le immagini devono essere ispezionate: la sola geometria non prova visibilita'.
`scripts/ci/illustrated_dialogue_contract.gd` attraversa anche i dieci racconti
(nelle tre lingue a 1280x720), ne verifica l'ordine per gradino del bando, che
nessuno compaia al gradino 0 prima dell'Era 1, che i racconti del posto vuoto
arrivino con la loro Era e prima del congedo, che non si ripetano e che nessuno
segua il congedo; il runner AV gli concede 150 secondi.
Una build esportata va guardata anche dal pacchetto: `--main-pack <Gallicus.exe>`
con il binario Linux carica le scene convertite come le vede Windows. Il 7
ottobre 2026 solo cosi' si e' riprodotto il libro del Registro in alto a
sinistra, invisibile nei test sul sorgente.

Ogni invocazione di `run_headless_smoke.py` usa un profilo temporaneo nuovo
tramite APPDATA/XDG_DATA_HOME, anche nell'export. Gli sblocchi dello scenario
precedente non devono cambiare le offerte di quello successivo; i salvataggi
personali non vengono usati. CORE_CONTINUITY conserva il proprio profilo
all'interno dello stesso processo. Il validator prova l'isolamento fra invocazioni.

La verifica cresce con il rischio della patch:

1. controlli statici e path;
2. import Godot;
3. smoke del ritual loop;
4. QA visuale/audio;
5. playtest di run;
6. playtest della campagna;
7. export e clean-install.

Un livello non sostituisce quello successivo.

## Classificazione patch

- **Docs:** refs, encoding, diff check.
- **Tooling:** unit/static test e workflow contract.
- **Data/content:** content contract, determinismo, localizzazione.
- **UI/asset/audio:** import, smoke, screenshot/ascolto.
- **Flow/save:** suite completa, tutti gli smoke, resume e CI Linux.
- **Campagna:** save pulito, Ere/Silenzi, durata e stato terminale.

## Cadenza automatica

La suite Linux automatica e' lean e non parte per ogni feature.

- **Per feature:** eseguire contratto specifico, import Godot quando cambiano
  runtime/scene/asset, QA visuale o audio rappresentativa, docs refs,
  mojibake e `git diff --check`.
- **Checkpoint:** dopo lo storico Object-First, i gate programmati sono
  `CP-03`, `CS-04`, Content Lock, Audiovisual Lock e Release Lock. Il marker
  resta `OF-11` fino a `CP-03`.
- **Eccezione ad alto rischio:** modifiche a `RunManager`, `GameEvents`, save,
  contratti/run systems, `project.godot` o workflow avviano subito il profilo
  lean senza spostare il checkpoint programmato. Il profilo `full` immediato
  resta obbligatorio soltanto se cambiano ownership, segnali, shape pubbliche o
  schema save.
- **Manuale:** `workflow_dispatch` espone `lean` e `full`. Il secondo conserva
  gli scenari storici e il visual QA cumulativo per i checkpoint programmati
  e le diagnosi straordinarie.

Una feature non checkpoint puo' essere marcata `implementata, in attesa di
signoff cumulativo` dopo i controlli locali mirati. La chiusura formale arriva
con il checkpoint che copre il blocco; una CI rossa di checkpoint o rischio
blocca il pacchetto successivo.

## Runner

Il runner locale e' la fonte unica dell'inventario statico: include ogni
`scripts/ci/test_*.py` esistente e i check canonici di docs, path, runtime,
GameEvents e formato scene. Il contratto CI fallisce se un test presente su
disco non compare esattamente una volta nel playbook.

```powershell
python scripts/ci/run_testing_playbook.py --godot-bin ".\tools\godot\Godot_v4.6.2-stable_win64_console.exe" --scenario FULL_RUN
```

Scrive log e summary in `artifacts/testing_playbook/`. Windows e' diagnostico;
la superficie automatica canonica resta CI Linux.
Quando e' fornito `--godot-bin`, il playbook esegue anche il contratto runtime
CP-02 e le regressioni semantiche della bonifica in directory utente
temporanee prima degli smoke.

## Static suite

Gate base:

```powershell
python scripts/ci/run_testing_playbook.py --skip-import
```

Per diagnosi si puo' eseguire anche il singolo test focalizzato. Il signoff
statico, pero', usa sempre il playbook completo e comprende:

- phase identity o save flow;
- GameEvents;
- UI overlay/payload;
- settings;
- i18n;
- ending, bet e path tag;
- pressione o push-your-luck.

## Encoding

Prima di chiudere:

```powershell
rg -n -P "\x{00C3}|\x{00C2}|\x{FFFD}" .
```

Exit code 1 senza output significa nessun match.

## Godot import

Per runtime, scene, asset o tooling smoke:

```powershell
python scripts/ci/run_godot_import.py --godot-bin ".\tools\godot\Godot_v4.6.2-stable_win64_console.exe"
```

Warning non fatali vanno classificati; parser error, missing resource e
`SANITY FAIL` bloccano la patch.

## Smoke runtime

Scenari:

- `BET_PRESENT`
- `FULL_RUN`
- `KEYBOARD_FULL_RUN`
- `ROUTE_CASHOUT`
- `ROUTE_DOUBLE`
- `ROUTE_CONDANNA`
- `ROUTE_REGISTER_FINAL`
- `CORE_CONTINUITY`

Esempio:

```powershell
python scripts/ci/run_headless_smoke.py --scenario ROUTE_CASHOUT --godot-bin ".\tools\godot\Godot_v4.6.2-stable_win64_console.exe"
```

`FULL_RUN` deve includere:

- bet present;
- pact open/close;
- intermediate choice;
- resolve open/close;
- push-your-luck;
- END_RUN;
- `END_RUN_FINAL ending_key=`.

Workflow canonico: `.github/workflows/godot_smoke_runtime.yml`.
Nei checkpoint il workflow espone esattamente tre job:

- `static_contracts` chiama una sola volta il playbook, fonte unica dei test;
- `runtime_routes` importa Godot una volta e percorre in sequenza cashout,
  double, condanna, register-final, `CORE_CONTINUITY` e `KEYBOARD_FULL_RUN`,
  conservando tutti i log anche se una route fallisce;
- `visual_stage` importa Godot una volta e cattura soltanto lo stage corrente.

Il profilo manuale `full` aggiunge `BET_PRESENT`, `FULL_RUN` e il visual QA
storico. Il bootstrap controlla prima i tool presenti e usa `apt` soltanto come
fallback con mirror ufficiale, retry e timeout limitati.

`CORE_CONTINUITY` completa tre run nello stesso processo e verifica le tre
linguette del fascicolo: next bet, new path e ritorno al menu. Le quattro route
push-your-luck restano coperte dagli scenari dedicati.

`KEYBOARD_FULL_RUN` inietta eventi `InputEventKey` press/release reali. Parte
dal focus del menu, attraversa Registro, firma, patto, gli scambi con la gradinata, da uno a tre colpi,
Push Your Luck e fascicolo, quindi verifica il ritorno al menu senza chiamare
direttamente gli intenti di gameplay.

Il runner inietta un seed smoke canonico e lo registra come
`SMOKE:RUNNER_SEED` e `SMOKE:RUN_SEED`. La matrice di signoff non usa
l'orologio come seed. `GALLICUS_SMOKE_SEED` puo' essere sovrascritto solo per
riprodurre un caso diagnostico; il risultato con seed diverso non sostituisce
la matrice canonica.

## QA visuale

Pass locale dell'8 ottobre 2026: `tools/claude_review_capture.gd` verifica
layout del banco con saldi fixture -5/0/20 e impostazioni, in IT/EN/ES a
720p/1080p. Non prova l'economia. `tools/claude_review_journey.gd` estende
la campagna UI reale con acquisti e obiettivo bando, mantenendo seed e
tempo controllati: verifica addebiti e presenza degli otto racconti.
`scripts/ci/character_runtime_contract.gd` verifica anche ritratti,
biografie localizzate e scroll. Report, prove interrotte e limiti in
`docs/support/claude_review_2026-10-08.md`. Queste prove locali non chiudono
CP-03 o il checkpoint Linux.

`tools/portrait_integration_capture.gd` rende Registro, cinque voci Archivio
e tre interlocutori dei dialoghi: 54 fixture IT/EN/ES a 720p/1080p.
Richiede driver grafico reale; non avanza campagna o modifica esiti.
Controllare sagome senza fondo nero, base sfumata, testo libero e biografie
interamente localizzate. I contratti headless del cast e dei dialoghi
proteggono scroll, focus, avanzamento, skip e separazione dalla run.

Richiesta per cambi UI, copy visibile, asset o motion.

```powershell
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn
```

Per OF-07 non checkpoint, la matrice locale mirata usa:

```powershell
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=pact_tablet
```

Per OF-08 non checkpoint, la matrice locale mirata usa:

```powershell
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=gesture_choice
```

Per OF-09 checkpoint, la matrice locale mirata usa:

```powershell
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=judgment_seal
```

Per OF-10/OF-11, la matrice locale mirata del fascicolo usa:

```powershell
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=final_dossier
```

Per CP-02, la matrice mirata delle impostazioni usa:

```powershell
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=accessibility_settings
```

La prova viene dalla viewport/finestra Godot, non dal desktop intero.
Se il runtime Windows non raggiunge il bootstrap, il job Linux `visual_stage`
produce l'evidenza canonica mirata. Per OF-11 sono richieste le 36 catture
`08_dossier_*` del fascicolo.
Le catture desktop intere non sostituiscono la viewport Godot.
Il job esegue lo stesso capture tool sotto Xvfb e pubblica l'artifact
`visual_qa_evidence`. Il profilo manuale `full` conserva la matrice storica:
al checkpoint OF-06 comprendeva 24 catture
soglia, 24 tavola del Registro, 30 promessa/firma, 18 quietanza, 18 marchio e
24 seconda incisione. Non sono ammesse catture desktop come sostituzione.
Dal pacchetto OF-07 la matrice cumulativa aggiunge 24 catture localizzate
`04_pact_<lingua>_*`:
IT/EN/ES, 1280x720 e 1920x1080, normal, focus, validated e disabled. Lo stato
pressed resta coperto dal contratto statico.
Dal pacchetto OF-08 aggiunge 36 catture `05_gesture_*`: IT/EN/ES, entrambe le
risoluzioni, normal, focus placa, focus provoca, selected placa, selected
provoca e disabled. Pressed resta coperto dal contratto statico. A ogni
ispezione si controllano rapporto 3:2, identita' delle silhouette, wrapping,
accenti e assenza di fallback italiano in EN/ES.
Dal pacchetto OF-09 aggiunge 30 catture `06_judgment_*`: IT/EN/ES, entrambe le
risoluzioni, normal, focus, strike_1, strike_2 e resolved. Pressed e disabled
restano coperti dal contratto statico. A ogni ispezione si controllano rapporto
5:2, leggibilita' della CTA, progressione dei tre colpi e assenza di fallback
italiano in EN/ES.
Dal pacchetto OF-10 aggiunge 36 catture `08_dossier_*`: IT/EN/ES, entrambe
le risoluzioni, open, updated, closed, focus, selected e disabled. Il
Il profilo `full` OF-11 richiede 271 catture complessive, inclusa
`08_end_run.png`; si controllano rapporto 7:4, linguette fisse 280x64,
wrapping, contrasto e assenza di fallback italiano nel copy dinamico.
CP-02 aggiunge 18 catture `09_settings_*`: IT/EN/ES, 1280x720 e 1920x1080,
stato standard, focus SFX e Reduced Motion attivo. Il lean CP-02 produce solo
queste 18; il profilo manuale `full` ne richiede 289 complessive. Il capture
cumulativo usa un timeout di 600 secondi: la run diagnostica `32892578364` ha
raggiunto il precedente limite di 480 secondi dopo 285 immagini, mentre
statici e tutti gli otto scenari runtime erano gia' verdi. Il timeout esteso
non riduce la matrice ne' sostituisce il requisito di 289/289 PNG.
Il contratto statico `scripts/ci/test_ledger_economy_contract.py` (gate
`ledger_economy`) controlla che il conto dei Denari resti autorita' di
RunManager e del profilo, che il banco apra solo a Registro chiuso e mai in
debito, e che la UI emetta soltanto `request_banco_purchase`.
Il contratto statico `scripts/ci/test_bando_ladder_contract.py` (gate
`bando_ladder`) controlla scala e costanti del bando, la chiusura prima della
quietanza intera, la catena che cresce e si spezza, i patti aperti dai gradini,
la UI solo reattiva a `bando_changed` e le chiavi IT/EN/ES.

Il contratto statico `scripts/ci/test_ci_checkpoint_contract.py` ricostruisce il
totale dai pattern della matrice e dalle catture letterali, quindi fallisce prima
di avviare Godot se un PNG resta fuori dall'artifact o se la somma diverge da 289.

Punti minimi:

- soglia/menu;
- Registro chiuso e aperto;
- firma e patto;
- gesto intermedio;
- rito;
- tre oggetti push-your-luck;
- fascicolo finale.

Controllare 1280x720, 1920x1080 e la lingua con stringhe piu' lunghe.

## QA audio

Per ogni gesto modificato verificare:

- focus e attivazione distinti;
- cue coerente con l'oggetto;
- volume rispetto a musica e ambience;
- persistenza slider;
- nessun path o import mancante;
- feedback visuale equivalente.

### Gate Media Vertical Slice nell'Audiovisual Lock

Prima dell'adozione runtime di `MV-03/MV-04` verificare inoltre:

- catture viewport-only a inizio, meta', fine, skip e reduced motion;
- trigger singolo per nuova run e restituzione del focus al Registro;
- nessuna variazione della fase autoritativa durante l'overlay;
- PNG review a 1920x1080 e layer RGBA ispezionati separatamente;
- stem allineati, picco massimo -3 dBFS e loop ascoltato al punto di wrap;
- provenienza e stato `REVIEW_ONLY` rimossi soltanto dopo il signoff umano.

## Playtest di run

Durata indicativa: 20-30 minuti.

- avvio senza guida;
- tre run consecutive;
- tre route push-your-luck;
- restart, next, menu e continue;
- settings, tastiera e audio;
- nessun stuck modal.

Usare `docs/playtest_guide.md`.

## Playtest campagna

Obbligatorio da Campaign Spine in avanti:

- profilo pulito;
- prima run fino all'Assenza;
- durata totale e numero run;
- almeno un resume da save;
- osservazione delle ramp senza mostrare nomi di Era;
- ending e Archivio;
- verifica del blocco terminale.

Target prima campagna: 2-4 ore.

## Localizzazione e accessibilita'

Per IT/EN/ES:

- nessuna chiave mancante;
- nessun fallback visibile;
- nessun overflow;
- focus mouse/tastiera;
- reduced motion;
- informazioni non solo colore/audio.

## Export

Il gate CP-02 usa il preset `Core Playable Candidate - Windows x86_64` e
produce `artifacts/exports/cp02/Gallicus_Core_Playable_Candidate.exe`. Dopo il
commit manuale:

- export release con template Windows Godot 4.6.2;
- avvio con `APPDATA` temporaneo;
- `KEYBOARD_FULL_RUN` sull'EXE;
- registrazione SHA-256, dimensione, log e commit sorgente;
- controllo manuale di persistenza, mute SFX, focus e Reduced Motion.

Per un EXE usare `scripts/ci/run_headless_smoke.py --exported-game`:
`--godot-bin` indica l'eseguibile, `--project-root` una cartella vuota usata
come working directory. Le build release non accettano il `--path` dell'editor.
Usare sempre APPDATA temporaneo, log e summary separati dai salvataggi personali.
`scripts/ci/inspect_export_assets.gd`, eseguito dal Godot editor con
`--main-pack` sull'EXE e `--script` assoluto, carica ogni immagine del manifest
e rifiuta raster importati estranei o vecchi file font nel pacchetto.

L'EXE non deve dipendere dai CSV sorgente: nell'export Godot il bootstrap i18n
carica le risorse importate `*.translation`. Qualsiasi warning per CSV mancanti
nel log dell'eseguibile rende rosso lo smoke di export.

Icona, signing e metadata commerciali restano al Release Lock.

Il Release Lock richiede:

- export Windows x64;
- avvio fuori dall'editor;
- clean install e profilo pulito;
- save migration;
- crediti/licenze;
- nessun path assoluto o asset mancante.

## Report finale

L'evidenza segue il candidato: registrare HEAD, modifiche locali incluse,
piattaforma, comandi, scenari realmente eseguiti e risultati. Per un export
conservare manifest e hash; per una build Steam anche BuildID e branch.
I signoff storici non si trasferiscono a un working tree modificato. Dopo
una correzione rivalutare e ripetere le prove influenzate dalla modifica.

Il ciclo di lavoro e' in `docs/development_workflow.md`. Una patch soltanto
documentale richiede docs refs, mojibake e diff check, senza suite Godot o
export. Il riferimento al "workflow" tra i percorsi ad alto rischio riguarda
il codice/configurazione CI, non la sola descrizione del metodo di sviluppo.

Per Steam il test dell'EXE standalone va integrato con installazione e avvio
dal client, secondo `docs/steam_release.md`. I PNG generati vanno distinti
da quelli effettivamente ispezionati; gli smoke non sostituiscono CP-03,
le campagne umane o la valutazione del mix.

Ogni patch dichiara:

- test eseguiti e risultato;
- smoke eseguiti;
- visual/audio QA eseguita o motivo dell'omissione;
- export eseguito o non pertinente;
- rischi residui;
- stage della roadmap aggiornato o invariato.

## Regressioni semantiche e cache fredda

`run_godot_import.py` attende --import fino al completamento e rifiuta ogni
ERROR anche con exit code zero. Il cold import usa una copia dei file correnti
senza .godot; archiviare HEAD non include le modifiche ancora locali.
`scripts/ci/run_audit_runtime_contract.py` esegue GDScript reale in profilo
temporaneo: 14 witness ending, path attivi, v4->v5, valori malformati,
isteresi, replay serializzato, ripetizione identica, campagna con patti reali,
commit idempotente, risorse immutate, settings in partita e boot terminale.
Non prova durata o non-farmabilita' percepita: serve il playtest umano.
I contratti grafici validano manifest, dimensioni, binding e geometria;
l'alpha dei vecchi asset non e' applicabile ai nuovi rettangoli RGB.

La regressione menu del 5 settembre verifica anche il pulsante di ripresa:
checkpoint scritto dal gioco, ripristino delle risorse e del seed, array scars
e pacts_log preservati in JSON, file rimosso dopo la visualizzazione del menu,
avviso persistente e azione di ripresa nascosta quando il file manca.

## Accettazione audiovisiva originale

Il playbook comprende `av_assets`: 31 WAV con hash, formati, headroom, assenza
DC rilevante, endpoint nulli e budget inferiore a 24 MiB. Il contratto Godot
`av_runtime_contract` verifica 28 condizioni: continuita' nello stesso stato,
crossfade e limite voci, loop, mute, wiring UI-VFX, geometria stabile, riuso
senza crescita di nodi, scadenza, Movimento ridotto e Silenzio.

Il runner usa profili temporanei; una chiusura del test lascia drenare
l'audio server prima di distruggere la scena. Errori di import e runtime
restano bloccanti. Su Windows la sandbox puo' impedire la lettura dello store
certificati: eseguire il test con i permessi necessari e profilo isolato;
non aggiungere quell'errore a un'allowlist del gioco.

La CI conserva tre job e i profili esistenti. Il nuovo contratto si esegue
nel job runtime gia' presente; run superate dello stesso ref/profilo sono
cancellate. Timeout esterni: 10 minuti statici, 15 runtime e 15 visuali.
Le prove locali non chiudono il checkpoint Linux sul futuro commit manuale.
I tempi frame headless sono diagnostica CPU/pacing, non una misura FPS GPU.
Ascolto del mix e fatigue in una campagna restano prove umane.

`tools/visual_qa_av_capture.tscn` estende la matrice canonica con 12 catture
del sigillo, polvere attiva e Movimento ridotto, per 301 PNG locali in
`artifacts/av_pass/screenshots`. Usare profilo isolato e driver grafico reale:
`godot --path . --scene res://tools/visual_qa_av_capture.tscn --audio-driver Dummy --max-fps 60`.
Il test sincronizza la lingua del profilo con quella della matrice prima di
emettere settings_changed. Gli stati sono iniettati: le catture non sono un
playtest e l'HUD di contesto puo' conservare il testo della fixture iniziale.
Il job visuale canonico conserva 289 PNG e il suo budget; il contratto AV
headless protegge separatamente wiring, durata e cancellazione degli effetti.

Nel pass del 6 settembre un cold import Windows e' terminato con
0xC0000005, senza diagnostica script; due copie nuove successive sono state
importate correttamente senza modifiche agli asset o bypass degli errori.
La causa resta aperta: conservare anche il log fallito, non presentare i
tentativi successivi come una correzione. Il checkpoint Linux resta richiesto.

## Audit di coerenza nel percorso - 8 settembre 2026

`tools/audit_screen_capture.tscn` salva screenshot, stili effettivi e stato
dei player in `artifacts/screen_audit_2026-09-08/`. Il flag utente `--linear`
salta le matrici e i loro riposizionamenti, registra il bus Music e prova
anche due superfici cicatrici con testo campione dichiarato. La riuscita
della cattura non equivale al superamento dell'audit: i target assenti sono
respinti nel manifest e il report conserva i difetti funzionali.

Usare APPDATA isolata prima del lancio, con risoluzione del path bloccante:

```powershell
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force artifacts/screen_audit_2026-09-08/profile | Out-Null
$env:APPDATA = (Resolve-Path artifacts/screen_audit_2026-09-08/profile).Path
./tools/godot/Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/audit_screen_capture.tscn --audio-driver Dummy --max-fps 60
# Usare un altro profilo vuoto per la prova lineare:
./tools/godot/Godot_v4.6.2-stable_win64_console.exe --path . --scene res://tools/audit_screen_capture.tscn --audio-driver Dummy --max-fps 60 -- --linear
```

Queste prove sono locali. Il collegamento musica-flow deve essere verificato
attraversando i gesti: chiamare direttamente MusicDirector non basta.
Il ritorno dal Silenzio richiede un rettangolo dentro il viewport, oltre
alla proprieta visible. Vedere `docs/support/screen_audit_2026-09-08.md`.

## Regressione di coerenza e prologo

Il contratto AV integra l'ingresso dal pulsante reale, skip e scadenza del
prologo, movimento ridotto con tempo di lettura, cambio lingua tramite
impostazioni, preferenza persistente, ripresa da checkpoint e sequenza dei
brani fino al fascicolo. Verifica rettangolo/focus/azione del ritorno dal
Silenzio a 720p e 1080p, dettaglio Cicatrici scrollabile e preservazione della
fase sottostante, scadenza notifica anche senza animazioni. La CI richiama
lo stesso contratto gia' presente nel job runtime; nessun job duplicato.

Il capture di audit accetta `--audit-dir=res://artifacts/<directory>` per
conservare il prima. La matrice estesa include utility e popup nativi nelle
tre lingue e due risoluzioni. Il percorso `--linear` asserisce lo score
attivo e la presenza dei target Cicatrici; registra il bus Music. Controllare
anche gli inventari e il contenuto delle immagini, non solo exit code.
Le nuove catture del prologo sono distinte dalla matrice canonica di 289
oggetti; quest'ultima mantiene conteggio e budget CI originali.

La variante `--prologue-only` produce 24 fixture di layout (2 frasi x 3 lingue
x 2 risoluzioni x 2 preferenze di movimento) e un inventario separato. Nel
percorso lineare si attende anche un tempo reale di assestamento: il numero
di frame da solo dipende dalla frequenza del display e puo' catturare una
dissolvenza intermedia. I test AV provano inoltre larghezza delle scrollbar,
traduzione dinamica dell'Archivio e focus confinato anche con le frecce.

## Campaign completion pass - 12 settembre 2026

`scripts/ci/run_campaign_runtime_contract.py --godot-bin <Godot>` percorre
la UI reale da profilo isolato fino all'Assenza, senza inserire storie o esiti.
Controlla quattro checkpoint, risorse al resume, identita' campione/fascicolo,
quattro Silenzi e avvio terminale in un secondo processo. Il playbook e il job
runtime Linux eseguono lo stesso contratto; il budget dei tre job resta invariato.
`--visual` aggiunge catture della viewport sul renderer reale. Il tempo e'
accelerato: non e' una misura di durata umana. Dal loop rivisto (ottobre 2026)
la policy gioca percorsi veri: rilancia fino alla terza arena, poi prende la
quietanza; il marchio solo se la quietanza e' bloccata. Il controllo campione /
fascicolo vale per i percorsi che contano come evidenza. Lo smoke da tastiera
chiude con la quietanza. Le altre route restano nel bundle di otto smoke.
La campagna deve produrre anche eventi di cicatrice reali. Il contratto
semantico verifica che ogni costo dichiarato abbia un ID nel catalogo, che
RunManager lo inserisca e che ciascun tipo influenzi il rischio avverso.
Lo smoke ROUTE_CASHOUT preferisce, fra le offerte reali, un patto diverso da
Raddoppia o Muori: dopo il ripristino delle cicatrici la vecchia scelta cieca
poteva morire prima di esercitare la Quietanza. Seed, esiti, offerte e
validator restano invariati; questa preferenza appartiene solo al driver smoke.

`tools/campaign_review_capture.gd`, eseguito con `--script` e driver grafico
reale, produce fixture IT/EN/ES a 720p e 1080p: Archivio, Silenzio, congedo,
Movimento ridotto, nero terminale e crediti. Le fixture sono distinte dal
percorso reale e dalla matrice canonica di 289 PNG. Usare APPDATA isolata.

`scripts/ci/check_cold_import.py --godot-bin <Godot>` importa tre copie dei
file correnti senza cache, conservando hash e log di ogni tentativo. Su Windows
Godot richiede accesso allo store certificati: una prova che fallisce per i
permessi della sandbox non si sana con retry o allowlist. Ripetere su copie
indipendenti con i permessi necessari e riportare entrambe le serie.

## Dialoghi illustrati - 12 settembre 2026

Il runner AV esegue anche illustrated_dialogue_contract.gd in un profilo
isolato. Verifica menu -> scena, blocco input iniziale, Enter/mouse, skip,
chiusura, disk reload e Continue, id sanitizzati, tre stadi, IT/EN/ES, 720p/1080p,
geometria e soppressione Silenzio/Assenza. Con renderer produce 108 catture.
La campagna naturale deve incontrare entry/middle/departure una volta ciascuna
e attraversarne le battute; lo smoke tastiera deve avanzare la nuova finestra.
Le prove storiche del prologo automatico sono sostituite da lettura manuale.

Dettaglio e prove: `docs/support/illustrated_dialogues_2026-09-12.md`.

## Matrice visuale del banco - 8 ottobre 2026

`tools/counter_layout_capture.gd` produce 126 catture viewport in IT/EN/ES a
720p e 1080p: banco con/senza fondi, firma e firma registrata, patto, giudizio,
gesto e focus, quietanza, notifica Segno, rilancio in focus, scelte bloccate,
dettaglio Segni, tre esiti, utility in focus e fascicolo chiuso. Controlla ingombri, sovrapposizioni
con colonna e rail e altezza del testo. Usare APPDATA temporaneo: il fixture
modifica stato di prova e non rappresenta una run giocata.
Il fixture usa reduced motion; KEYBOARD_FULL_RUN attraversa il flow reale
con impostazioni predefinite. Le immagini vanno ispezionate: scroll e
contrasto non sono provati da una sola asserzione geometrica.
Evidenze e limiti: `docs/support/counter_ui_2026-10-08.md`.

La revisione Manifesto aggiunge pressione 9, posta a quattro cifre e impronte
confermate, con output in `artifacts/manifesto_2026-10-08/layout/`. Il pannello
di fase ora copre il viewport: verificare i rettangoli delle singole azioni
contro superficie stampata, HUD e footer. Le note devono stare nella stessa
superficie dei comandi. Il test controlla anche che pressione e hover con
motion attivo non cambino i target. Fixture e playtest umano restano distinti.
Risultati: `docs/support/manifesto_verdict_2026-10-08.md`.

Il campione di arena illustrata ripete la stessa matrice con la scena corrente
in `artifacts/arena_stilizzata_2026-10-08/layout_capture.gd`, mantenendo separate
le catture dal precedente banco. Controllare anche contrasto della didascalia
alta, posta, focus e note sul nuovo fondale. Confrontare Registro e fascicolo
adiacenti per rendere esplicite le differenze artistiche ancora da uniformare.
Prova e perimetro: `docs/support/illustrated_arena_2026-10-08.md`.

## Simulatore di campagna (tuning, non gate)

`tools/campaign_sim.gd` gioca una campagna intera nella UI vera con uno stile
scelto da argomenti (`--style`, `--strike`, `--crowd`, `--runs`, `--seed`) e
stampa una riga `SIM_RUN` per percorso e un `SIM_SUMMARY`. Usare un profilo
isolato (`APPDATA`/`XDG_DATA_HOME`). Confrontare sempre con `--crowd=read`:
`--crowd=bow` porta a rivolte e debito. Risultati del 7 ottobre 2026 in
`docs/support/benchmark_bcde_2026-10-07.md`.
