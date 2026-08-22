# Gallicus Development Plan

## Direzione

La roadmap porta direttamente a Gallicus 1.0. Le fasi sono gate produttivi,
non versioni distribuibili. Una fase e' chiusa solo quando i suoi criteri sono
verificati; il lavoro successivo non deve mascherare blocker precedenti.

## Stato corrente

- Stage completato: **Foundation Reset**.
- Stage completato: **Object-First Interaction Pass**.
- Stage attivo: **Core Playable Candidate**.
- Loop rituale: operativo e coperto da smoke.
- Campagna completa: non ancora implementata.
- Pacchetto chiuso: **CP-01 - stabilita' e leggibilita' del loop esistente**.
- Pacchetto attivo: **CP-02 - accessibilita', save ed export interno**.
- Signoff CP-01: run lean Linux `32594244882` verde sul commit `047ed67`.
- Vincoli invariati: `RunManager` flow authority, `GameEvents` bus, UI reattiva.
- Verifica canonica: OF-07, OF-08 e OF-09 chiusi dal checkpoint Linux
  `32152390171`; OF-10, OF-11 e lo stage Object-First chiusi dalla run lean
  `32238429965` sul commit `8449766`.
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

La suite automatica lean non viene eseguita per ogni singola feature. Il marker
resta su `OF-11` fino al prossimo checkpoint programmato, `CP-03`.

- per feature: contratto specifico, import Godot quando pertinente, controllo
  visuale/audio rappresentativo, docs refs, mojibake e diff check;
- per checkpoint: `static_contracts`, `runtime_routes` con le quattro route e
  `CORE_CONTINUITY` in un solo runner, e `visual_stage` limitato allo stage
  corrente;
- per eccezione ad alto rischio: la suite lean parte subito se
  cambiano `RunManager`, `GameEvents`, save, contratti/run systems,
  `project.godot` o il workflow;
- `workflow_dispatch` espone `lean` e `full`; il profilo completo resta
  manuale per `CP-03`, `CS-04`, Content Lock, Audiovisual Lock, Release Lock e
  per ogni modifica ad autorita' o save;
- un'eccezione ad alto rischio non sposta i checkpoint programmati.

Ordine dei pacchetti:

| ID | Stage | Deliverable |
| --- | --- | --- |
| `FR-01` | Foundation Reset | smoke deterministici e matrice Linux verde |
| `OF-01..03` | Object-First | quietanza, marchio, seconda incisione |
| `OF-04..11` | Object-First | soglia, Registro, promessa, firma, patto, gesto, sigillo, fascicolo |
| `CP-01..03` | Core Playable Candidate | stabilita', export interno e playtest go/no-go |
| `CS-01..04` | Campaign Spine | firma, Silenzi, Ere, Assenza e campagna accelerata |
| `CR-01..03` | Content & Readability | feedback, Archivio, matrice contenuti e Content Lock |
| `AV-01..05` | Audiovisual Lock | Media Vertical Slice, VFX, audio, musica e cinematiche |
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

### Pacchetto chiuso: OF-07

- Comportamento: trasformare `MOSTRA IL PATTO` in una tavoletta sigillata di
  basalto, bronzo e cera che rende leggibile la convalida del patto.
- Owner: `RunManager` conserva flow e avanzamento rituale; la UI presenta gli
  stati ed emette l'intento invariato `request_ritual_advance("pact")`.
- Contratti: object grammar, ritual loop, UI canon, localizzazione IT/EN/ES e
  contratto object-first OF-07.
- Vincoli: nessun nuovo segnale, payload, campo save, manager, transizione o
  calcolo gameplay; il marker checkpoint resta `OF-09` fino al prossimo
  checkpoint programmato.
- Implementazione locale: tavoletta RGBA 5:2 senza testo, stati
  normal/focus/pressed/validated/disabled a geometria stabile, CTA
  `MOSTRA IL PATTO`/`SHOW THE PACT`/`MUESTRA EL PACTO` e cue
  `registry_pact_validate`. Lo stato validated precede decision lock, cue ed
  emissione dell'intento; non esiste `await` nel gesto.
- Correzione proporzioni e copy: controllo `320x128` nel pannello `660x390`,
  StyleBoxTexture senza margini nine-slice, soggetto all'89,1% della larghezza
  e all'82,8% dell'altezza del canvas. Titolo, corpo, CTA, `SEGNI` e stato del
  Registro sono localizzati integralmente in IT/EN/ES.
- Prove locali: contratto OF-07, import e runtime Godot 4.6.2, i18n, path,
  docs refs, mojibake e diff check verdi. Il WAV e' mono PCM16 44,1 kHz,
  dura 0,68 s e raggiunge al massimo -3 dBFS. Il selettore locale
  `--section=pact_tablet` produce 24 catture `04_pact_*` IT/EN/ES per normal,
  focus, validated e disabled a 1280x720 e 1920x1080; matrice ispezionata
  senza overflow o variazioni di geometria.
- Stato: chiuso dal checkpoint cumulativo OF-09 il 2026-08-18, run Linux
  `32152390171`, commit `3f1fd3b` e artifact ispezionato.

### Pacchetto chiuso: OF-08

- Comportamento: trasformare la scelta intermedia nel gesto pubblico davanti
  alla gradinata previsto dal rituale object-first.
- Owner: `RunManager` conserva flow, scelta e conseguenze; la UI resta
  presentazionale e invia soltanto gli intenti esistenti.
- Implementazione locale: tessere RGBA gemelle 3:2 `placa` e `provoca`, con
  silhouette coincidenti al 99,88%, controlli `336x224`, pannello `764x430` e
  stati normal/focus/pressed/selected/disabled senza scala. CTA, Pressione,
  registrazione e otto messaggi dinamici sono completi in IT/EN/ES.
- Runtime: selected precede il decision lock; i cue dedicati
  `arena_gesture_placa`/`arena_gesture_provoca` precedono gli intenti invariati
  `request_mid_choice_select(0/1)`. Doppia attivazione, emissione fallita e
  watchdog sono gestiti localmente senza `await` o calcolo gameplay.
- Prove locali: contratti OF-07/OF-08, import Godot 4.6.2, i18n, motion,
  ritual-loop, path, docs refs, mojibake e diff check verdi. I WAV durano 0,68
  s e 0,76 s, mono PCM16 44,1 kHz, con picco non superiore a -3 dBFS.
- Evidenza visuale: 24 catture `04_pact_*` e 36 catture `05_gesture_*`,
  IT/EN/ES a 1280x720 e 1920x1080, generate con i selettori locali e
  ispezionate senza overflow, fallback italiano, deformazioni o variazioni di
  geometria. Stato chiuso dal checkpoint cumulativo OF-09 il 2026-08-18, run
  Linux `32152390171`, commit `3f1fd3b` e artifact ispezionato.

### Pacchetto chiuso: OF-09

- Comportamento: trasformare il colpo sul sigillo nel gesto object-first della
  sequenza rituale: il sigillo su pietra riceve tre colpi e si chiude prima
  dell'avanzamento.
- Owner: `RunManager` conserva flow e giudizio; la UI mostra stati e invia
  soltanto l'intento invariato `request_ritual_advance("resolve")`.
- Implementazione locale: sigillo RGBA 5:2 in basalto, bronzo e cera rossa,
  stati normal/focus/pressed/strike_1/strike_2/resolved/disabled a geometria
  stabile, controllo `360x144`, CTA `COLPISCI` e cue
  `registry_judgment_seal_strike`/`registry_judgment_seal_resolve`.
- Checkpoint: OF-09 aggiorna il marker a `OF-09` e richiede job statico, sei
  smoke Linux e visual QA cumulativo prima di chiudere OF-07, OF-08 e OF-09.
- Nota correttiva: la run Linux `29571887908` su commit `5cc5f8d` ha lasciato
  verdi job statico e sei smoke; il solo rosso era `visual_qa_object_first`,
  causato dal capture cumulativo rimasto agganciato al vecchio
  `Btn_RESOLUTION_NEXT` dopo i tre colpi. La patch locale aggiorna soltanto il
  tool visuale e il contratto OF-09: dopo `Btn_RESOLUTION_STRIKE` attende
  direttamente `Phase_PUSH_YOUR_LUCK`.
- Verifica del fix: la run Linux `29900307187` su commit `1449506` ha lasciato
  verdi job statico e sei smoke e ha completato tutte le catture fino a
  `VISUAL_QA:OK`. Il conteggio CI della matrice patto includeva pero' anche
  `04_pact_signed.png`, ottenendo 25 file invece delle 24 varianti localizzate.
  La patch locale restringe `PACT_COUNT` a `04_pact_??_*.png` e aggiorna il
  contratto checkpoint senza cambiare capture, runtime o criteri del gate.
- Ispezione artifact: le catture EN/ES del sigillo mostravano in italiano la
  riga contestuale deterministica `Il gesto pesa poco. La folla resta ferma.`.
  Un capture locale con seed diverso ha confermato lo stesso fallback su una
  seconda variante. La patch locale traduce le righe al confine UI, completa
  nelle tre lingue l'intero pool `GESTURE_CHOSEN` (12 righe base e tre harsh)
  e lo rende obbligatorio nel contratto OF-09; flow e payload restano invariati.
- Vincoli: preservare flow, segnali, payload, save e autorita' di `RunManager`;
  nessun `await` o calcolo gameplay nel gesto.
- Gate chiuso: run Linux `32152390171` sul commit `3f1fd3b`, con
  `static_contracts`, sei smoke e `visual_qa_object_first` verdi. L'artifact
  `object_first_visual_qa` contiene 235 file, incluse 30 catture
  `06_judgment_*`, `06_resolve_ritual.png`, `07_push_your_luck.png`, 18
  quietanze, 18 marchi, 24 incisioni e `08_end_run.png`; digest
  `sha256:208f8b14eeb855df405455e0e8e7ab925db1b0b45e02aa8b950a9489a872ca03`.
- Cleanup dell'evidenza: l'ispezione ha rilevato un recentring tardivo del solo
  capture headless nel passaggio 1920x1080 -> 1280x720. Il tool e il contratto
  OF-09 sono corretti localmente; la matrice mirata IT/EN/ES e' centrata e
  leggibile e verra' riassorbita dal checkpoint cumulativo OF-11.

### Pacchetto chiuso: OF-10

- Comportamento: `END_RUN` e' un fascicolo fisico `1120x640` con stati open,
  updated e closed; le route sono linguette fisse `304x64`.
- Mapping: `meta.register_final` sceglie esclusivamente updated/closed;
  `meta.next_bet_enabled` resta l'unico owner della route successiva.
- Runtime: guardia, selected, lock, cue, intento invariato e watchdog, senza
  `await`, calcolo gameplay o accesso diretto a `RunManager`.
- Asset: tre dossier RGBA 7:4 e una linguetta RGBA 5:1, generati built-in e
  validati con silhouette stabile; cue procedurali update/close/route.
- Localizzazione: report finale, messaggi del Registro, titoli condanna,
  ultima voce e route sono tradotti al confine UI in IT/EN/ES.
- Prove locali: contratto OF-10 verde, import Godot 4.6.2 verde e 36 catture
  mirate `08_dossier_*` verdi; proporzioni, safe area, contrasto, wrapping e
  CTA verificati a 1280x720 e 1920x1080.
- Gate chiuso: run lean Linux `32238429965` sul commit `8449766`, con
  `static_contracts`, `runtime_routes` e `visual_stage` verdi. L'artifact
  `visual_qa_evidence` contiene esattamente 36 catture dossier IT/EN/ES alle
  due risoluzioni; digest
  `sha256:839f8d3e20e302037a78d432f1a007ecf634d69233869db2333cbc8786cc5adb`.

### Checkpoint chiuso: OF-11

- Il marker full-suite e' `OF-11`; il playbook include tutti i contratti
  Object-First e il consolidamento dello stage.
- La run `32158939715` ha prodotto e superato il QA cumulativo da 271 catture,
  digest `sha256:f44f7922cd1389d6c71ec48e382413423c6bde31f3d04107c7230260de6b2156`,
  ma quattro runner sono stati cancellati durante `apt-get update` prima di
  raggiungere Godot; non costituisce quindi signoff complessivo.
- Il gate lean usa tre job: playbook statico unico, quattro route nello
  stesso runner e 36 catture dossier stage-only. Il profilo `full` conserva
  la matrice storica da 271 immagini per uso manuale.
- Signoff: run Linux `32238429965` sul commit `8449766`; i tre job sono verdi,
  le quattro route riportano `status: ok` e l'artifact visuale e' stato
  contato e ispezionato in IT/EN/ES a 1280x720 e 1920x1080. Il digest dei log
  route e' `sha256:0da51ab069e3cee7a5be9e3a4ac499dcd167b0566c1c9dc3003bc010dbab7d0b`.
- OF-10, OF-11 e lo stage Object-First Interaction Pass sono formalmente
  chiusi; il pacchetto attivo diventa `CP-01`.

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

Status: **COMPLETE**.

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

## 3. Core Playable Candidate

Dipendenza: checkpoint Object-First `OF-11` chiuso.

Status: **ACTIVE - CP-02**.

Obiettivo: produrre una build interna completa, leggibile ed esportabile del
loop attuale prima di riaprire nuovi sistemi della campagna. Non e' una release
intermedia e non modifica la Definition of Done di Gallicus 1.0.

Ordine:

1. `CP-01` playbook completo, tre run consecutive, quattro route
   push-your-luck e tre linguette del fascicolo; correggere soltanto problemi
   Critical o Important di stabilita' e leggibilita';
2. `CP-02` save/continue, settings, IT/EN/ES, input, reduced motion ed export
   Windows x64 da profilo pulito, con volume SFX persistente e migrazione;
3. `CP-03` build interna e tre sessioni da 20-30 minuti con mouse, tastiera,
   due risoluzioni e audit IT/EN/ES; decisione go/no-go sulla campagna.

Vincoli:

- fino a CP-03 sono congelati nuovi sistemi di memoria, convergenza, Ere,
  Silenzi, cinematiche ed espansione contenuti;
- sono ammessi soltanto fix necessari a completare e rendere affidabile il
  loop gia' esistente;
- cambi di ownership, `GameEvents`, shape payload o schema save sono ammessi
  solo per blocker provati e richiedono il profilo CI `full` manuale; fix
  interni a `RunManager` che preservano questi contratti usano il gate lean.

Blocker noti all'apertura:

- nessun `export_presets.cfg` Windows x64;
- reduced motion assente;
- volume SFX non regolabile;
- nessun playtest corrente registrato.

Gate:

- menu, nuova run, continue e rituale completo fino al fascicolo;
- quattro route push-your-luck e tre route del fascicolo affidabili;
- settings, mouse, tastiera e reduced motion verificati;
- IT/EN/ES leggibili a 1280x720 e 1920x1080;
- export Windows avviabile fuori dall'editor da profilo pulito;
- nessun fatal error, soft lock, save corrotto, asset mancante o fallback.
- zero issue Critical e nessuna issue Important irrisolta al gate `CP-03`.

### Pacchetto chiuso: CP-01

- Comportamento: stabilizzare il loop esistente e verificare nello stesso
  processo tre run consecutive, le quattro route push-your-luck e le tre
  linguette finali.
- Owner: `RunManager` conserva flow e outcome; `GameEvents` resta il bus; la
  UI resta reattiva.
- Implementazione: il playbook canonico include tutti i contratti statici;
  `CORE_CONTINUITY` percorre tre run e usa `PROSSIMA SCOMMESSA`,
  `NUOVO PERCORSO` e `TORNA AL MENU`. La route next-bet raggiunge l'handler
  esistente senza introdurre un nuovo sistema di campagna.
- Signoff Linux: run lean `32594244882` sul commit `047ed67`, con
  `static_contracts`, `runtime_routes` e `visual_stage` verdi.
- Evidenza runtime: artifact `runtime_routes_logs`, digest
  `sha256:fffc177002b0e8d6e1a764a8f5cdec1aa5259f3e72eaafad340da1a58e8cfb86`.
- Evidenza visuale: artifact `visual_qa_evidence`, 36 catture del fascicolo
  IT/EN/ES a 1280x720 e 1920x1080, digest
  `sha256:f4242b4f6181ae8d5499f17d5ce5f74b8cec862a7f2586ffb53cb8059a3d1090`.
- Gate chiuso: 2026-08-22. Il runtime Windows headless resta diagnostico per
  il crash nativo noto prima di `SMOKE:BOOT_OK`; non invalida il signoff Linux.

## 4. Campaign Spine

Dipendenza: `CP-03` chiuso con decisione go.

Status: **LOCKED UNTIL CP-03**.

Obiettivo: rendere completabile la campagna canonica da Era 0 ad Assenza senza
spostare autorita', alterare reward o mostrare al giocatore metriche interne.

Ordine:

1. `CS-01` firma comportamentale, coerenza, fissazione e isteresi come helper
   deterministici sotto l'autorita' di `RunManager`;
2. `CS-02` Silenzi, incremento monotono delle Ere e ramp invisibile di tre run;
3. `CS-03` Era 4, Assenza, persistenza terminale, resume e blocco definitivo
   della nuova run, senza New Game+;
4. `CS-04` smoke campagna accelerato, simulazione deterministica e playtest
   grezzo end-to-end.

Contratti:

- una versione save successiva a CP-02 persiste firma, contatore di stabilita'
  e stato della ramp, con default, migrazione e round-trip;
- `run_ended` conserva la shape e aggiunge `REGISTRY_SILENCE` e
  `REGISTRY_ABSENCE`, senza verdetto classificatorio;
- il port UI espone soltanto `can_start`/terminale, mai Era, firma o soglie;
- il Silenzio di Era 3 imposta `registry_era=4`, elimina il run save attivo e
  impedisce ogni nuova inizializzazione del Registro.

Gate:

- transizione deterministica Era 0 -> 4 e resume intermedio;
- Silenzio non farmabile, fissazione stabile e ramp di tre run verificata;
- nessuna ricompensa o probabilita' outcome alterata dall'Era;
- nuova run rifiutata dopo l'Assenza;
- campagna completabile con durata proiettata nel target 2-4 ore.

## 5. Content & Readability

Dipendenza: `CS-04` verde.

Obiettivo: completare contenuto e comprensione della campagna funzionante prima
del lock audiovisivo.

Deliverable:

- feedback di stato, rischio e conseguenza per ogni gesto;
- Archivio, copy e matrice `path x Era x route` completi;
- ending dichiarati raggiungibili;
- IT/EN/ES allineate per ogni riga player-facing, comprese le righe dinamiche;
- rimozione di placeholder, fallback e semantica action/combat;
- varieta' sufficiente a evitare la stessa sequenza per tre run consecutive
  nella stessa Era.

Gate:

- campagne complete sui path rappresentativi;
- nessun overflow o fallback alle due risoluzioni;
- nessuna route ambigua o azione importante priva di conferma;
- checkpoint Content Lock `full` verde prima del congelamento del contenuto.

## 6. Audiovisual Lock

Dipendenza: Content Lock. La preparazione Media Vertical Slice resta disponibile
ma l'integrazione runtime inizia soltanto dopo la campagna funzionante.

Obiettivo: dare alla campagna un'identita' audiovisiva coerente e finita.

Deliverable:

- Media Vertical Slice integrata e validata come primo segmento;
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

Il checkpoint Audiovisual Lock usa il profilo `full`; include performance,
mix, provenienza asset e verifica delle alternative reduced-motion.

## 7. Release Lock

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

`CP-01` e' chiuso dalla run lean Linux `32594244882` sul commit `047ed67`.
I tre job canonici sono verdi; `CORE_CONTINUITY` verifica tre run consecutive e
le tre linguette finali. I digest degli artifact runtime e visuali sono
registrati nella scheda CP-01.

Il pacchetto attivo e' `CP-02`: reduced motion, volume SFX persistente,
save recovery/migration, percorso completo da tastiera e primo export Windows
x64 da profilo pulito. La patch deve preservare ownership, segnali gameplay,
wrapper run schema `1` e Level 3 schema `2`. Media Vertical Slice, sistemi
campagna ed espansione contenuti restano congelati fino al go/no-go di CP-03.
