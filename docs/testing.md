# Gallicus Testing

## Principio

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
CP-02 con directory utente temporanea prima degli smoke.

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
.\tools\godot\Godot_v4.6.2-stable_win64_console.exe --headless --editor --path . --quit
```

Warning non fatali vanno classificati; parser error, missing resource e
`SANITY FAIL` bloccano la patch.

## Smoke runtime

Scenari:

- `BET_PRESENT`
- `FULL_RUN`
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
dal focus del menu, attraversa Registro, firma, patto, gesto, tre colpi,
Push Your Luck e fascicolo, quindi verifica il ritorno al menu senza chiamare
direttamente gli intenti di gameplay.

Il runner inietta un seed smoke canonico e lo registra come
`SMOKE:RUNNER_SEED` e `SMOKE:RUN_SEED`. La matrice di signoff non usa
l'orologio come seed. `GALLICUS_SMOKE_SEED` puo' essere sovrascritto solo per
riprodurre un caso diagnostico; il risultato con seed diverso non sostituisce
la matrice canonica.

## QA visuale

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
`08_end_run.png`; si controllano rapporto 7:4, linguette fisse 304x64,
wrapping, contrasto e assenza di fallback italiano nel copy dinamico.
CP-02 aggiunge 18 catture `09_settings_*`: IT/EN/ES, 1280x720 e 1920x1080,
stato standard, focus SFX e Reduced Motion attivo. Il lean CP-02 produce solo
queste 18; il profilo manuale `full` ne richiede 289 complessive.

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

Icona, signing e metadata commerciali restano al Release Lock.

Il Release Lock richiede:

- export Windows x64;
- avvio fuori dall'editor;
- clean install e profilo pulito;
- save migration;
- crediti/licenze;
- nessun path assoluto o asset mancante.

## Report finale

Ogni patch dichiara:

- test eseguiti e risultato;
- smoke eseguiti;
- visual/audio QA eseguita o motivo dell'omissione;
- export eseguito o non pertinente;
- rischi residui;
- stage della roadmap aggiornato o invariato.
