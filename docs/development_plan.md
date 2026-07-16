# Gallicus Development Plan

## Direzione

La roadmap porta direttamente a Gallicus 1.0. Le fasi sono gate produttivi,
non versioni distribuibili. Una fase e' chiusa solo quando i suoi criteri sono
verificati; il lavoro successivo non deve mascherare blocker precedenti.

## Stato corrente

- Stage completato: **Foundation Reset**.
- Stage attivo: **Object-First Interaction Pass**.
- Loop rituale: operativo e coperto da smoke.
- Campagna completa: non ancora implementata.
- Pacchetto attivo: **OF-08 - gesto davanti alla gradinata**.
- Vincoli invariati: `RunManager` flow authority, `GameEvents` bus, UI reattiva.
- Verifica locale: static suite e import Godot verdi.
- Runtime Windows headless: diagnostico bloccato da crash nativo prima del
  bootstrap; le matrici Linux canoniche sono verdi.

## Protocollo di consegna compatto

Il lavoro procede in pacchetti verticali da uno a tre giorni. I pacchetti non
sono versioni di prodotto e non sostituiscono i gate degli stage.

Regole:

- un solo pacchetto runtime puo' essere attivo;
- una CI rossa di checkpoint o attivata da un percorso ad alto rischio blocca
  il pacchetto successivo;
- ogni pacchetto dichiara stage, comportamento, owner, contratti, test ed
  evidenze;
- UI, copy IT/EN/ES, feedback, focus, reduced motion e documentazione entrano
  nello stesso pacchetto quando pertinenti;
- asset e contenuti possono essere preparati in parallelo solo senza cambiare
  flow, dati o superfici runtime non ancora aperte;
- un helper condiviso nasce solo con almeno due consumer immediati;
- nessun gate e' chiuso senza prova Linux, visuale, audio o manuale richiesta;
- tra checkpoint una feature puo' diventare `implementata, in attesa di
  signoff cumulativo` dopo le verifiche locali mirate, liberando il pacchetto
  runtime successivo senza dichiarare una chiusura formale.

### Cadenza CI a checkpoint

La suite automatica completa non viene eseguita per ogni singola feature.
I checkpoint Object-First sono `OF-06`, `OF-09` e `OF-11`, registrati in
`.github/ci/full_suite_checkpoint.txt`.

- per feature: contratto specifico, import Godot quando pertinente, controllo
  visuale/audio rappresentativo, docs refs, mojibake e diff check;
- per checkpoint: un job statico, sei smoke Linux e visual QA cumulativo;
- per eccezione ad alto rischio: la stessa suite completa parte subito se
  cambiano `RunManager`, `GameEvents`, save, contratti/run systems,
  `project.godot` o il workflow;
- `workflow_dispatch` resta sempre disponibile e non sposta il checkpoint;
- un'eccezione ad alto rischio non modifica la sequenza OF-06/OF-09/OF-11.

Ordine dei pacchetti:

| ID | Stage | Deliverable |
| --- | --- | --- |
| `FR-01` | Foundation Reset | smoke deterministici e matrice Linux verde |
| `OF-01..03` | Object-First | quietanza, marchio, seconda incisione |
| `OF-04..11` | Object-First | soglia, Registro, promessa, firma, patto, gesto, sigillo, fascicolo |
| `RF-01..02` | Readability | leggibilita' della run e affidabilita' multi-run |
| `RM-01..04` | Registry Memory | contratto, evidenza, convergenza, persistenza |
| `ES-01..04` | Eras And Silences | Silenzio, ramp, mutazioni, Assenza |
| `CC-01..06` | Content | validatore matrice e completamento per Era |
| `AV-01..05` | Audiovisual | oggetti, VFX, SFX, musica, sequenze |
| `RL-01..03` | Release Lock | accessibilita', export, campagne candidate |

### Pacchetto chiuso: FR-01

- Comportamento: rendere ripetibili i sei smoke senza derivare il seed
  dall'orologio.
- Owner: tooling CI; `RunManager` conserva flow e outcome authority.
- Contratti: ritual loop e validatore smoke.
- Implementazione: seed canonico iniettato dal runner, consumato solo in smoke
  mode e registrato nel log.
- Prove locali: validator, ritual-loop contract, runtime invariants, phase
  ownership, import Godot e mojibake verdi.
- Evidenza Linux 1: commit `92b97a1`, sei scenari verdi nella
  [matrice main](https://github.com/Faratas410/Gallicus-2.0/actions/runs/28535038016).
- Evidenza Linux 2: commit `ea03757`, sei scenari verdi nella
  [matrice PR](https://github.com/Faratas410/Gallicus-2.0/actions/runs/28617462882).
- Gate chiuso: 2026-07-02, due matrici canoniche consecutive verdi.

### Pacchetto chiuso: OF-01

- Comportamento: rappresentare l'incasso con la quietanza object-first.
- Owner: `RunManager` per flow e outcome; UI reattiva per presentazione e
  invio dell'intento `request_pyl_cashout`.
- Contratti: ritual loop, object grammar e brief quietanza esistenti.
- Vincoli: nessun nuovo manager, phase enum, payload o calcolo UI.
- Implementazione: texture unica, quattro stati Godot, copy
  IT/EN/ES, stato taken immediato e cue `registry_receipt_take`.
- Prove locali: static suite e import Godot verdi; `ROUTE_CASHOUT` ha prodotto
  un pass verde e due retry diagnostici fermati dal crash nativo Windows prima
  di `SMOKE:BOOT_OK`.
- Evidenza Linux: commit `c0f8254`, sei scenari verdi nella
  [matrice PR #535](https://github.com/Faratas410/Gallicus-2.0/actions/runs/28846986069).
- Evidenza visuale: artifact `of_01_receipt_visual_qa`, 18 catture
  viewport-only IT/EN/ES per normal, focus e disabled a 1280x720 e 1920x1080,
  digest `sha256:30a8872ec6b005b460c0ca111365234b843a3a96a7855e6e555ea59e622d2704`.
- Gate chiuso: 2026-07-07, PR #535 verde prima del merge.

### Pacchetto chiuso: OF-02

- Comportamento: trasformare il marchio in oggetto gameplay leggibile.
- Owner: `RunManager` per flow e outcome; UI reattiva per presentazione e
  invio degli intenti esistenti.
- Contratti: ritual loop, object grammar e brief object-first.
- Vincoli: nessun nuovo manager, phase enum, payload o calcolo UI.
- Implementazione: ferro-timbro object-first, copy IT/EN/ES
  `RICEVI IL MARCHIO`, stato registered immediato, cue
  `registry_condemnation_mark`.
- Prove locali: static suite, i18n, contract OF-01/OF-02,
  path/import e import Godot verdi; `ROUTE_CONDANNA` diagnostico Windows
  fermato da crash nativo prima di `SMOKE:BOOT_OK`.
- Evidenza Linux: commit `58be872`, sei scenari verdi nella
  [matrice PR #536](https://github.com/Faratas410/Gallicus-2.0/actions/runs/29003421266).
- Evidenza visuale: artifact `object_first_pyl_visual_qa`, 36 catture
  viewport-only, 18 quietanza e 18 marchio, IT/EN/ES per normal, focus e
  disabled/registered a 1280x720 e 1920x1080, digest
  `sha256:08a211c831a5c42e314d5d38201d9f8ad9a657f38394c979138ce383280cec1d`.
- Gate chiuso: 2026-07-09, PR #536 verde prima del merge.

### Pacchetto chiuso: OF-03

- Comportamento: trasformare la seconda incisione in gesto object-first
  leggibile senza cambiare flow, payload, reward, save o autorita'.
- Owner: `RunManager` per flow e outcome; UI reattiva per presentazione e
  invio dell'intento esistente.
- Contratti: ritual loop, object grammar e naming object-first.
- Vincoli: nessun nuovo manager, phase enum, payload, campo save o calcolo UI.
- Implementazione locale: tavoletta di cera object-first con cinque stati
  Godot, CTA canonica `RADDOPPIA`, stato sealed sincrono e cue
  `registry_second_incision`; intento `request_pyl_double` invariato.
- Prove locali: playbook statico completo e import Godot 4.6.2 verdi.
  `ROUTE_DOUBLE` e visual QA Windows restano diagnostici e si fermano sul
  crash nativo noto prima di `SMOKE:BOOT_OK`, senza parser error o missing
  resource.
- Evidenza Linux: commit `66fbdfb`, sei scenari e visual QA verdi nella
  [matrice PR #536](https://github.com/Faratas410/Gallicus-2.0/actions/runs/29122736504).
- Evidenza visuale: artifact `object_first_pyl_visual_qa`, 61 catture
  viewport-only: 18 quietanze, 18 marchi, 24 incisioni e schermata generale
  Push Your Luck. La matrice OF-03 copre IT/EN/ES, normal, focus, disabled e
  sealed a 1280x720 e 1920x1080; digest
  `sha256:ee1193ef9802f650b4e8bc41dcf819ef6dd2079ce31e6f19623bf0a0969164ab`.
- Gate chiuso: 2026-07-11, PR #536 verde e mergiata in `main`.

### Pacchetto chiuso: OF-04

- Comportamento: trasformare l'ingresso della campagna nella soglia
  object-first dell'arena, mantenendo il CTA `ENTRA NELL'ARENA` e il flow
  esistente.
- Owner: `RunManager` per avvio e transizione; menu reattivo per
  presentazione e invio dell'intento `request_new_run`.
- Contratti: object grammar, menu canonico, art direction e layout.
- Vincoli: nessun nuovo segnale, payload, campo save, manager o calcolo UI.
- Implementazione locale: soglia 5:2 in basalto, bronzo e sabbia con stati
  stabili normal, focus, pressed, crossed e disabled; CTA IT/EN/ES e brand
  Gallicus preservati; cue `arena_threshold_cross` e intento
  `request_new_run` invariato.
- Prove locali: playbook statico e import Godot 4.6.2 verdi; visual QA verde
  con 24 catture viewport-only IT/EN/ES a 1280x720 e 1920x1080. Lo smoke
  `BET_PRESENT` Windows resta diagnostico e ha riprodotto il crash nativo
  noto prima di `SMOKE:BOOT_OK` (`NATIVE_CRASH_BEFORE_BOOTSTRAP`).
- Evidenza Linux: commit `d14013f`, sei smoke e visual QA verdi nella
  [run 29211497525](https://github.com/Faratas410/Gallicus-2.0/actions/runs/29211497525).
- Evidenza visuale: artifact `object_first_visual_qa`, 85 catture viewport-only:
  24 soglie, 18 quietanze, 18 marchi, 24 incisioni e schermata generale Push
  Your Luck. La matrice OF-04 copre IT/EN/ES, normal, focus, disabled e crossed
  a 1280x720 e 1920x1080; digest
  `sha256:8ebb1d87621a2fa8a5513ef258a77cc09c9f3c7573c7e0ad5fd184abf1bfddab`.
- Gate chiuso: 2026-07-13, sette job verdi su `main` e artifact ispezionato.

### Pacchetto chiuso: OF-05

- Comportamento: trasformare apertura e consultazione delle offerte nella
  tavola object-first del Registro, mantenendo flow e selezione esistenti.
- Owner: `RunManager` per flow e dati delle offerte; UI reattiva per apertura,
  presentazione e invio degli intenti gia' esistenti.
- Contratti: object grammar, ritual loop, UI canon e localizzazione IT/EN/ES.
- Vincoli: nessun nuovo segnale, payload, campo save, manager o calcolo UI.
- Implementazione locale: tavola 3:2 chiusa/aperta in basalto, bronzo,
  calcare e cera, stati closed normal/focus/pressed/disabled e open, CTA
  `APRI IL REGISTRO` localizzata e cue `registry_table_open`. L'apertura resta
  presentazione UI-only; `request_place_bet` e le offerte sono invariati.
- Prove locali: playbook statico completo, i18n, motion, contratti object-first
  e import Godot 4.6.2 verdi. La matrice visuale locale produce 24 catture
  Registro IT/EN/ES, closed normal/focus/disabled e open a 1280x720 e
  1920x1080, tutte con dimensioni e layout verificati. `BET_PRESENT` Windows
  resta diagnostico e riproduce il crash nativo noto prima di
  `SMOKE:BOOT_OK` (`NATIVE_CRASH_BEFORE_BOOTSTRAP`, exit `0xC0000005`).
- Evidenza Linux: commit `b7d9e4b`, sei smoke e visual QA verdi nella
  [run 29291362204](https://github.com/Faratas410/Gallicus-2.0/actions/runs/29291362204).
- Evidenza visuale: artifact `object_first_visual_qa`, 111 catture
  viewport-only: 24 soglie, 24 tavole del Registro, 18 quietanze, 18 marchi,
  24 incisioni e tre schermate generali. Le 24 catture Registro coprono
  IT/EN/ES, closed normal/focus/disabled e open a 1280x720 e 1920x1080;
  artifact ispezionato e senza overflow distruttivi. Digest
  `sha256:142fffe8e158032b5d57e0702e964c2a3350a5cefc7ea36d280593e28d38443c`.
- Gate chiuso: 2026-07-15, sette job verdi su `main` e artifact ispezionato.

### Pacchetto chiuso: OF-06

- Comportamento: trasformare scelta e firma della promessa in un gesto su un
  cartiglio di cera integrato nelle due foglie del Registro.
- Owner: `RunManager` conserva selezione, flow e registrazione del patto; la UI
  mostra gli stati e invia l'intento esistente `request_place_bet`.
- Contratti: object grammar, ritual loop, UI canon, localizzazione IT/EN/ES e
  cadenza CI a checkpoint.
- Vincoli: nessun nuovo segnale, payload, campo save, manager, transizione o
  calcolo gameplay.
- Implementazione locale: coppia RGBA 4:1 blank/signed a silhouette identica,
  stati normal/focus/pressed/selected/signed/disabled a geometria stabile,
  CTA `FIRMA`/`SIGN`/`FIRMAR` e cue `registry_promise_sign`. Lo stato signed
  precede decision lock, cue ed emissione invariata di `request_place_bet`;
  non esiste `await` nel gesto.
- Prove locali: playbook statico completo, contratto checkpoint, import Godot
  4.6.2 e visual QA verdi. La matrice produce 30 catture OF-06 IT/EN/ES per
  normal, focus, selected, signed e disabled a 1280x720 e 1920x1080,
  ispezionate senza overflow o variazioni di geometria. `BET_PRESENT` Windows
  resta diagnostico e riproduce il crash nativo noto prima di
  `SMOKE:BOOT_OK` (`NATIVE_CRASH_BEFORE_BOOTSTRAP`, exit `124`).
- Evidenza Linux: commit `d115c60`, job `static_contracts`, sei smoke e visual
  QA verdi nella
  [run 29531241698](https://github.com/Faratas410/Gallicus-2.0/actions/runs/29531241698).
- Evidenza visuale: artifact `object_first_visual_qa`, 141 catture
  viewport-only: 24 soglie, 24 tavole del Registro, 30 promesse/firme,
  18 quietanze, 18 marchi, 24 incisioni e tre schermate generali. Le 30
  catture `03_promise_*` coprono IT/EN/ES, normal, focus, selected, signed e
  disabled a 1280x720 e 1920x1080; artifact ispezionato senza overflow
  distruttivi o variazioni di geometria. Digest
  `sha256:01e5b2be8d15b73831fd6f42a0d01b4fd4bd6a93cdfd267b83c6ef6554999f01`.
- Gate chiuso: 2026-07-16, otto job verdi su `main` e artifact ispezionato.

### Pacchetto implementato, in attesa di signoff cumulativo: OF-07

- Comportamento: trasformare `MOSTRA IL PATTO` in una tavoletta sigillata di
  basalto, bronzo e cera che rende leggibile la convalida del patto.
- Owner: `RunManager` conserva flow e avanzamento rituale; la UI presenta gli
  stati ed emette l'intento invariato `request_ritual_advance("pact")`.
- Contratti: object grammar, ritual loop, UI canon, localizzazione IT/EN/ES e
  contratto object-first OF-07.
- Vincoli: nessun nuovo segnale, payload, campo save, manager, transizione o
  calcolo gameplay; il marker checkpoint resta `OF-06` fino a OF-09.
- Implementazione locale: tavoletta RGBA 5:2 senza testo, stati
  normal/focus/pressed/validated/disabled a geometria stabile, CTA
  `MOSTRA IL PATTO`/`SHOW THE PACT`/`MUESTRA EL PACTO` e cue
  `registry_pact_validate`. Lo stato validated precede decision lock, cue ed
  emissione dell'intento; non esiste `await` nel gesto.
- Prove locali: contratto OF-07, import e runtime Godot 4.6.2, i18n, path,
  docs refs, mojibake e diff check verdi. Il WAV e' mono PCM16 44,1 kHz,
  dura 0,68 s e raggiunge al massimo -3 dBFS. Il selettore locale
  `--section=pact_tablet` produce 24 catture `04_pact_*` IT/EN/ES per normal,
  focus, validated e disabled a 1280x720 e 1920x1080; matrice ispezionata
  senza overflow o variazioni di geometria.
- Stato: implementato il 2026-07-16. OF-07 non e' un checkpoint e resta in
  attesa del signoff cumulativo OF-09; il marker resta `OF-06`.

### Pacchetto attivo: OF-08

- Comportamento: trasformare la scelta intermedia nel gesto pubblico davanti
  alla gradinata previsto dal rituale object-first.
- Owner: `RunManager` conserva flow, scelta e conseguenze; la UI resta
  presentazionale e invia soltanto gli intenti esistenti.
- Apertura: definire oggetto, gesto, stati, cue, copy e contratto locale senza
  modificare segnali, payload, save o marker checkpoint.
- Signoff: OF-08 non e' un checkpoint; dopo le verifiche locali mirate restera'
  in attesa della convalida cumulativa OF-09.

## 1. Foundation Reset

Status: **COMPLETE**.

Obiettivo: sostituire il framing di milestone intermedie con un sistema
documentale e tecnico orientato alla release finale.

Deliverable:

- documentation OS 1.0;
- roadmap unica e documenti di dominio coerenti;
- rimozione dei pacchetti milestone obsoleti;
- contratti e scenari CI con nomi semantici;
- stato reale del prodotto documentato.

Gate:

- riferimenti docs validi;
- static suite verde;
- Godot import verde;
- smoke `BET_PRESENT`, `FULL_RUN` e route principali verdi;
- nessun riferimento attivo alle milestone eliminate.

## 2. Object-First Interaction Pass

Dipendenza: Foundation Reset.

Obiettivo: rendere ogni azione gameplay un gesto su un oggetto leggibile.

Ordine:

1. soglia dell'arena;
2. apertura e consultazione del Registro;
3. scelta e firma della promessa;
4. tavoletta del patto;
5. gesto davanti alla gradinata;
6. colpo sul sigillo;
7. quietanza, marchio e seconda incisione;
8. chiusura del fascicolo.

Deliverable:

- scheda object-first compilata per ogni azione;
- presentazione, copy, VFX e SFX associati;
- stessi intenti e segnali esistenti;
- utility UI mantenuta convenzionale e accessibile.

Gate:

- ogni azione compila la formula object-first;
- screenshot delle schermate critiche a 1280x720 e 1920x1080;
- nessuna regressione ai contratti del ritual loop;
- un tester identifica oggetto, gesto e conseguenza senza spiegazione.

## 3. Run Readability And Feedback

Dipendenza: Object-First Interaction Pass.

Obiettivo: rendere una run comprensibile, reattiva e affidabile.

Deliverable:

- stato corrente, prossima azione, rischio e conseguenza sempre leggibili;
- feedback visivo, audio e UI per ogni gesto;
- route finali inequivocabili;
- save/continue, settings e piu' run consecutive verificati;
- focus, reduced motion e mix audio di base.

Gate:

- tre run consecutive senza riavvio;
- cashout, double e condanna coperti;
- nessun stuck modal o route ambigua;
- nessuna azione importante muta o priva di conferma.

## 4. Registry Memory And Convergence

Dipendenza: Run Readability And Feedback.

Obiettivo: implementare la memoria interpretativa che collega le run.

Deliverable:

- firma comportamentale a quattro assi;
- coerenza, smoothing, fissazione e isteresi;
- scars, condanne e path integrati come evidenza;
- Archivio e riconoscimenti coerenti;
- persistenza e migrazione save;
- metriche interne mai esposte come progress bar.

Gate:

- stessi seed producono la stessa evoluzione;
- fissazione richiede le condizioni canoniche;
- inversioni rapide non annullano la firma;
- save/continue conserva lo stato senza corruzione;
- test statici e runtime coprono soglie e fallback.

## 5. Eras And Silences

Dipendenza: Registry Memory And Convergence.

Obiettivo: trasformare le run in una campagna finita.

Deliverable:

- progressione monotona `registry_era` da 0 a 4;
- transizioni causate esclusivamente dal Silenzio;
- ramp di tre run dopo ogni transizione;
- mutazioni graduali di copy, offerte, art e audio;
- compressione terminale conforme al canon;
- Assenza del Registro e blocco definitivo della campagna.

Gate:

- nessuna UI nomina o numera le Ere;
- il Silenzio non e' farmabile;
- nessuna ricompensa o probabilita' outcome e' alterata dall'Era;
- il profilo terminale non reinizializza il Registro;
- campaign smoke copre transizioni, resume e finale.

## 6. Content Completion

Dipendenza: Eras And Silences.

Obiettivo: completare la varieta' necessaria a una campagna di 2-4 ore.

Deliverable:

- matrice path x Era x route finale coperta;
- bet, condanne, scars, verdetti e ending senza placeholder;
- variazioni linguistiche coerenti con convergenza ed Era;
- Archivio completo;
- IT/EN/ES allineate al contenuto sorgente.

Gate:

- tutti gli ending dichiarati sono raggiungibili;
- nessun ramo usa testo generico di fallback;
- tre run consecutive nella stessa Era non presentano una sequenza identica;
- playtest completi rientrano nel target di durata senza grind.

## 7. Audiovisual Completion

Dipendenza: Content Completion. La produzione preparatoria puo' iniziare prima,
ma il lock richiede contenuto stabile.

Obiettivo: dare alla campagna un'identita' audiovisiva coerente e finita.

Deliverable:

- kit di oggetti rituali runtime-ready;
- background e variazioni graduali per il Registro;
- VFX e motion associati a gesti e conseguenze;
- sound set di pietra, cera, bronzo, carta, folla e respiro;
- musica e mix per le condizioni del Registro;
- intro, Silenzi, transizioni e finale come sequenze in-engine;
- rimozione o sostituzione degli asset con semantica action/combat.

Gate:

- nessun asset mancante o fuori mood nelle superfici finali;
- ogni effetto comunica stato o gesto;
- audio leggibile su speaker e cuffie;
- reduced motion preserva informazioni e tempi di input;
- budget performance rispettato alle risoluzioni target.

## 8. Release Lock

Dipendenza: tutti gli stage precedenti.

Obiettivo: produrre una build Windows pubblicabile e verificata.

Deliverable:

- navigazione completa mouse e tastiera;
- IT/EN/ES complete;
- crediti, licenze e metadata;
- export Windows x64;
- test clean install, clean profile e save migration;
- release notes e known issues non bloccanti;
- CI Linux e campagna manuale complete.

Gate:

- `docs/release_checklist.md` interamente verde;
- almeno tre campagne complete su build candidate;
- nessun Critical o Important irrisolto;
- export avviabile fuori dall'editor;
- stato finale: `SIGNED FOR GALLICUS 1.0`.

## Prossimo step operativo

`OF-06` e' chiuso sul commit `d115c60` con otto job Linux verdi e artifact
visuale ispezionato. `OF-07 - tavoletta del patto` e' implementato su `main`
e attende il signoff cumulativo OF-09; il marker resta `OF-06`. Il prossimo
step operativo e' pianificare e implementare `OF-08 - gesto davanti alla
gradinata` con sole verifiche locali mirate.
