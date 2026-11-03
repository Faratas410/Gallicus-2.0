# Gallicus Testing

## Chiusura audio nei contratti di campagna

`audio_abrupt_shutdown_contract.gd` chiude subito dopo aver avviato una voce;
il runner deve verificare sia il marker sia l'assenza di errori e leak. Anche
`audio_shutdown_contract.gd` avvia una voce, programma una risposta ritardata,
poi verifica lo stop del pool, l'annullamento del richiamo e la ripresa dei
richiami richiesti dopo lo stop. I contratti brevi
di campagna usano `audio_test_teardown.gd`: interrompe i suoni e lascia al
driver tempo reale per rilasciare i playback prima di terminare il processo.
Il runner verifica anche `seat_reset_alignment_contract.gd` su profilo isolato,
incluso il ricaricamento dopo il reset della campagna.
Questo non sostituisce una verifica della chiusura durante l'uso umano ne'
un ascolto dell'audio, e non attenua il rifiuto del runner in presenza di errori.

## Revisione Incasso/Rilancio: evidenze correnti

Il runner `tools/living_verdict_capture.gd` verifica anche che titolo ed
effetti restino entro il supporto fisico con margine interno, per IT/EN/ES
e 720p/1080p. Catture in artifacts/verdict_review/final; handoff e risultati
in `docs/support/verdict_review_2026-10-26.md`.

## Revisione Banco: evidenze correnti

`tools/pixel_banco_capture.gd` salva ora in artifacts/banco_review/final.
`tools/registry_volume_capture.gd` accetta --capture-dir per preservare
le evidenze precedenti. Confronto dei sette commenti e verifiche in
`docs/support/banco_review_2026-10-26.md`.

## Banco e posta pixel art - 26 ottobre 2026

Eseguire `tools/pixel_banco_capture.gd` e `tools/living_verdict_capture.gd`
(con `--all-languages`) nel renderer reale e con profilo isolato. Il primo
copre saldo/blocchi/acquisto nativo e testo sulle ricevute; il secondo focus,
doppio clic, tre azioni, importi lunghi e movimento ridotto. Proteggere libro
e firma con `tools/registry_volume_capture.gd`; il vecchio registry-only del
counter capture contiene asserzioni sulla precedente selezione dei fogli.
Aggiungere OF-01/02/03, ROUTE_CASHOUT/DOUBLE/CONDANNA, KEYBOARD_FULL_RUN e art
uniformity. Handoff: `docs/support/pixel_banco_verdict_2026-10-26.md`.

## Patto, Gradinata e Rito pixel art - 26 ottobre 2026

Eseguire `tools/pixel_ritual_capture.gd` con Godot 4.6.2, renderer reale e
APPDATA/LOCALAPPDATA isolati. Copre IT/EN/ES a 720p/1080p, stati densi,
scala sotto HUD, ritorno a 720p, testo entro carta e separazione dai comandi;
riusa anche il percorso nativo firma -> Patto -> folla -> Rito -> posta.
Affiancare OF-07/08/09, art uniformity e KEYBOARD_FULL_RUN. Screenshot e
summary in `artifacts/pixel_ritual/final/`, handoff in
`docs/support/pixel_rituals_2026-10-26.md`. Distinguere fixture di presentazione,
route col manager e accettazione umana.

## Fascia GDR Insegne - 26 ottobre 2026

`tools/hud_insegne_capture.gd` parte dalla Main reale con profilo isolato,
poi usa fixture UI esplicite per Pressione 0/5/10, Favore ostile/intermedio/
alto, conto positivo a cinque cifre e negativo, stati del Bando e Segni.
Dal 31 ottobre 2026 include anche bando chiuso a conto chiuso e ultimo bando
chiuso o mancato; l'insegna usa testi brevi (in spagnolo "Cerrado: ..."),
mentre il fascicolo conserva le frasi complete. Prima di questa modifica il
fixture falliva in spagnolo sul bando chiuso, anche sul commit `de88fbc`.
IT/EN/ES a 720p/1080p, anche resize inverso. Misura etichette nei rettangoli
della pelle, copia completa, Enter sul dettaglio e ritorno focus senza
intenti di firma; cattura Registro, consultazione e posta. Non e' una prova
economica. Il fixture del Registro protegge tutti i contratti senza scroll
con il nuovo inset. Affiancare art uniformity e KEYBOARD_FULL_RUN per il
percorso naturale; esiti locali in `docs/support/hud_insegne_2026-10-26.md`.

## Registro volumetrico - 26 ottobre 2026

`tools/registry_volume_capture.gd` attraversa Main -> Nuova partita ->
dialogo -> Registro, in profilo usa e getta. Eseguire con Godot 4.6.2,
`--script res://tools/registry_volume_capture.gd`; aggiungere `-- --capture`
con renderer reale per le PNG in `artifacts/registry_volume/`. Copre
IT/EN/ES a 720p/1080p, apertura, focus, assenza di scroll e clipping, interruzione,
Movimento ridotto e firma con Enter accettata dal manager. Non usa il
salvataggio personale: APPDATA e LOCALAPPDATA vanno in cartelle di test.
La matrice compatta misura anche ogni offerta attiva con condizioni neutre,
Favore positivo/negativo, Pressione 10 e Segni, verificando che l'effetto
completo della condanna rimanga leggibile. `longest_*` cattura la pagina
piu' alta; `page_layouts` nel report conserva altezze e spazio disponibile.
Contratti statici OF-05/06, motion e smoke KEYBOARD_FULL_RUN completano la
verifica; prova fisica del controller e ritmo restano accettazione umana.

## Uniformazione artistica - 24 ottobre 2026

`scripts/ci/run_art_uniformity_contract.py --godot-bin <Godot>` esegue il
contratto dedicato su profilo isolato; il playbook lo include nel percorso
runtime. Verifica trasformazioni canvas, cancellazione di effetti gia' avviati
attraverso l'opzione reale, conteggio/gauge, particelle, fascia persistente
e materiale comune nei tre stadi della ramp. La sonda non cambia l'economia.

Affiancare matrici counter/utility/posta in IT/EN/ES, 720p/1080p, ispezione
dei nuovi ritratti e prove naturali KEYBOARD_FULL_RUN/CASHOUT/DOUBLE/CONDANNA.
La notifica Segno deve restare separata da numero, voce e oggetti. Controllare
il focus anche con le trasformazioni canvas, non solo `get_global_rect()`.
Il fixture della posta ora libera audio/scena prima di quit. Catture e limiti:
`docs/support/art_unification_2026-10-24.md`.

Incasso/Rilancio, 22 ottobre 2026: fixture dedicata
`tools/living_verdict_capture.gd -- --all-languages`, con profilo usa e
getta, desktop privato non attivato e Godot 4.6.2. Produce stati disponibili,
focus, quietanza impressa, seconda incisione, blocchi, posta lunga e
movimento a 1280x720 e 1920x1080. Controlla testo entro i target,
doppio click, focus che salta azioni bloccate e movimento ridotto.
Affiancare le route CASHOUT, DOUBLE, CONDANNA e KEYBOARD_FULL_RUN.
Receipts, confronto e limiti: `docs/support/living_verdict_2026-10-22.md`.

## Principio

Compatibilita' locale del 15 ottobre 2026: Godot
`4.7.2.stable.official.ed1daf0bf`, Windows, renderer Vulkan/Forward+ reale,
IT/EN/ES a 1280x720 e 1920x1080. La baseline canonica CI resta 4.6.2.
Report: `docs/support/manifesto_visual_review_2026-10-15.md`.
`tools/manifesto_review_capture.gd -- --capture-dir=<directory>` aggiunge
62 fixture di menu, opzioni, focus slider, popup nativi, crediti, Archivio,
tooltip, Museo, prima battuta del dialogo e sezione utility del campionario.
Aprire le utility passa dai segnali dei Button reali; il dialogo e' una
fixture esplicita, distinta dal contratto che attraversa l'overlay reale.
Controlla dimensioni effettive delle immagini, contenimento dei target e
testo del dialogo. Le impostazioni riapplicano la risoluzione salvata: il
capture ripristina la dimensione della matrice prima di ogni screenshot.

La chiusura riuscita del driver smoke ferma e scollega i player audio e
attende 0.2 s prima del quit: Godot 4.7.2 tratteneva i riferimenti di playback
se il processo terminava durante il crossfade del ritorno al menu. La cura
e' limitata al driver; validator, outcome, seed e comportamento normale non
cambiano. La fixture CP-02 libera esplicitamente i due SaveManager creati
fuori dalla SceneTree; conserva la prova intenzionale del JSON malformato.

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
`scripts/ci/campaign_story_order_contract.gd` verifica inoltre che un racconto
gia' guadagnato sia mostrato prima del congedo, a partire dalla UI reale.
Il contratto dei dialoghi controlla anche che, quando il caso del posto si
apre dopo una scena, il focus passi alla testimonianza e torni al Registro
dopo il rinvio. Per le prove di bilanciamento `tools/campaign_sim.gd` accetta
un saldo iniziale e una policy per il caso; richiede sempre un profilo isolato
e non rappresenta una sessione umana.
Una build esportata va guardata anche dal pacchetto: `--main-pack <Gallicus.exe>`
con il binario Linux carica le scene convertite come le vede Windows. Il 7
ottobre 2026 solo cosi' si e' riprodotto il libro del Registro in alto a
sinistra, invisibile nei test sul sorgente.

Ogni invocazione di `run_headless_smoke.py` usa un profilo temporaneo nuovo
tramite APPDATA/XDG_DATA_HOME, anche nell'export. Gli sblocchi dello scenario
precedente non devono cambiare le offerte di quello successivo; i salvataggi
personali non vengono usati. CORE_CONTINUITY conserva il proprio profilo
all'interno dello stesso processo. Il validator prova l'isolamento fra invocazioni.

La verifica locale segue il comportamento modificato e il rischio della patch:

1. controlli statici e path;
2. import Godot;
3. smoke del ritual loop;
4. QA visuale/audio;
5. playtest di run;
6. playtest della campagna;
7. export e clean-install.

Questi livelli non sono una sequenza obbligatoria per ogni intervento. Scegliere
quelli necessari al cambiamento e alle dipendenze; ai checkpoint i gate previsti
restano obbligatori. Un controllo eseguito non sostituisce un gate non eseguito.

## Selezione contestuale dei test locali

Prima di eseguire, annotare comportamento cambiato, punto di ingresso reale,
dipendenze, rischio e controllo minimo. Partire dalla riga pertinente e
combinare le righe se una patch attraversa piu' domini. Una modifica piccola
in un file condiviso non richiede automaticamente tutti i test delle sue altre
funzioni; seguire chiamanti, segnali, dati e superfici effettivamente coinvolti.
Se il perimetro non e' dimostrabile, usare il controllo di integrazione piu'
vicino che copre l'incertezza e motivarlo.

| Cambia | Controlli locali da scegliere | Aggiungere quando pertinente |
| --- | --- | --- |
| Solo documentazione | `python scripts/ci/check_docs_active_refs.py`, `python scripts/ci/test_no_mojibake.py`, `git diff --check` | Contratto del dominio o workflow se il testo modifica un requisito operativo verificato da quel contratto. |
| Prezzi, quietanza o debito | `python scripts/ci/test_ledger_economy_contract.py` e contratto runtime mirato del percorso interessato | `python scripts/ci/test_bando_ladder_contract.py` se cambia l'interazione col bando; scenario di ripresa se il saldo o la scelta attraversano il save. |
| Bando, quote o ricompense | `python scripts/ci/test_bando_ladder_contract.py` e il percorso di chiusura o scadenza coinvolto | Quietanza/debito, sblocchi o contenuti solo se toccati; campagna completa solo se serve verificare progressione fino al termine. |
| Una scena o scelta del posto | Il contratto `seat_case`, `seat_inquiry`, `seat_memory`, `seat_copy`, `seat_copy_echo` o `seat_steps_era` coinvolto, piu' il suo ingresso reale | Profilo isolato e resume/reset quando cambia stato persistente; ordine e congedo quando cambia l'eleggibilita'; controlli IT/EN/ES e catture per testo o layout modificati. |
| UI, asset o animazione di una fase | Contratto statico dell'oggetto o fase e verifica renderizzata degli stati toccati | Import se cambiano risorse o binding; focus/input e localizzazione quando interessati; una route smoke che attraversa la fase se cambia il collegamento al flow. |
| Audio o cue | `python scripts/ci/test_av_asset_contract.py` per asset/manifest e contratto runtime del cue o lifecycle interessato | Ascolto umano per mix e qualita'; chiusura durante playback se cambia il pool; import per nuovi asset. |
| Testo o traduzione | `python scripts/ci/test_i18n_contract.py` e verifica della stringa o superficie modificata | Reimport delle risorse compilate e controllo di layout nelle lingue e dimensioni supportate quando cambia il testo visualizzato. |
| Flow, segnali o save | Contratto specifico del boundary e percorso reale che lo attraversa | Vecchi profili, scrittura/lettura, interruzione, resume e reset per dati persistenti; controlli delle route coinvolte se cambiano transizioni o payload. |
| Test runner, CI o preset di export | Test del runner/validator o contratto di configurazione interessato | `python scripts/ci/test_ci_checkpoint_contract.py` per workflow/cadenza; controlli packaging e piattaforme per modifiche che toccano l'export. |

Esempi di route mirate: `BET_PRESENT` per accesso alla promessa;
`ROUTE_CASHOUT`, `ROUTE_DOUBLE` o `ROUTE_CONDANNA` per la route cambiata;
`CORE_CONTINUITY` solo se serve attraversare piu' run o persistenza. Gli
scenari si avviano con `scripts/ci/run_headless_smoke.py --scenario <nome>
--godot-bin <Godot 4.7.2>`; ciascuno usa il proprio profilo temporaneo.
I contratti Godot `scripts/ci/*_contract.gd` si possono eseguire singolarmente
con `--headless --audio-driver Dummy --path . --script res://scripts/ci/<file>`
e profilo di test isolato: non riutilizzare i salvataggi personali. Un contratto
diretto non esegue automaticamente gli altri controlli del runner di campagna.

Ampliare la verifica se un test fallisce, se il cambiamento coinvolge realmente
altre route, ownership, segnali, schema/migrazione save, engine o workflow, o
se il rischio non e' coperto. Ripetere solo cio' la cui evidenza e' invalidata
dalle modifiche successive. Registrare PASS/FAIL/NOT_RUN/BLOCKED, comando,
candidato e motivo dei controlli omessi. La suite completa e' richiesta ai
checkpoint e per i gate sotto indicati, non come default di ogni patch.

La selezione automatica GitHub usa `scripts/ci/contextual_ci.py` sull'intero
intervallo del push, non solo sull'ultimo commit. Attualmente riconosce:
documentazione, pool SFX, `scripts/ui/seat_case.gd`, `_pick_crowd_intent` e
`_settle_ledger_at_run_end` in `RunManager`, `_format_contract_body` in
`scripts/ui/betting_circle_ui.gd` e i file CSV, import e Translation delle tre
lingue esistenti. Combina i controlli dei domini
coinvolti e non avvia route o campagne estranee. Il piano e' visibile nei log;
ogni contratto Godot usa un profilo isolato e controlla anche gli errori di
chiusura. Il mapping CI e' deliberatamente piu' ristretto della tabella locale.
Per i documenti canonici e i contratti documentali che sono letti da test
automatici, il planner aggiunge i rispettivi controlli: per esempio UI canon
attiva i contratti di pressione, contatore, stile e motion; il contratto
GameEvents attiva il validatore dei segnali e il controllo del bando.
Per il testo del Registro e le lingue, i controlli includono i contratti statici
che leggono quei dati e l'audit runtime del testo dei patti in IT/EN/ES. Le
lingue attivano anche i contratti runtime che il profilo lean eseguiva e che
leggono testo tradotto: AV (stringhe esatte), personaggi, dialoghi illustrati,
ultima Era, eco della copia e passi del posto per Era. Lo
stesso audit viene eseguito una sola volta se i due gruppi sono combinati. Le
altre funzioni della schermata e il registro delle lingue restano nel profilo
lean; modifiche ai contratti della schermata richiedono full. L'audit non prova
che tutte le schermate siano tradotte correttamente o prive di clipping: restano
necessarie le verifiche visuali e linguistiche appropriate.
Un push successivo non cancella la verifica del push precedente: ogni run ha un
gruppo di concorrenza distinto, cosi' nessun intervallo resta senza controlli.

File non riconosciuti ricadono nel profilo lean. Range non disponibile, checkout
diverso dalla testa, nuovo branch o push non fast-forward richiedono full.
Modifiche non riconosciute a
`RunManager`, save, `GameEvents`, contratti/run systems o `project.godot`
richiedono il profilo full. In un push misto prevale il rischio piu' alto,
indipendentemente dall'ordine dei file. La modifica del marker di checkpoint o
del workflow mantiene il gate cumulativo; `workflow_dispatch` continua a
eseguire esplicitamente lean o full. Non interpretare un successo contestuale
come checkpoint Linux cumulativo, accettazione umana o release.
Per le funzioni mappate, cambi a chiamate di save, segnali, serializzazione o
alle firme richiedono comunque full; lo stesso vale per i file audio e posto
mappati. Per questi ultimi anche modifiche alle dichiarazioni al livello del
file o chiamate dinamiche richiedono full. Il riconoscimento non sostituisce
la review: la selezione non dimostra l'assenza di effetti indiretti.

## Classificazione patch

- **Docs:** refs, encoding, diff check.
- **Tooling:** unit/static test e workflow contract.
- **Data/content:** content contract, determinismo, localizzazione.
- **UI/asset/audio:** import, smoke, screenshot/ascolto.
- **Flow/save:** contratto e route interessati; resume/reset e migrazione se
  coinvolti. CI e suite cumulativa secondo rischio e checkpoint qui sotto.
- **Campagna:** save pulito, Ere/Silenzi, durata e stato terminale.

## Cadenza automatica

Ogni push su `main` avvia il planner Linux; esegue solo la selezione riconosciuta
o, in caso di perimetro non mappato, il profilo cumulativo prudente.

- **Per feature:** eseguire contratto specifico, import Godot quando cambiano
  runtime/scene/asset, QA visuale o audio rappresentativa, docs refs,
  mojibake e `git diff --check`.
- **Checkpoint:** dopo lo storico Object-First, i gate programmati sono
  `CP-03`, `CS-04`, Content Lock, Audiovisual Lock e Release Lock. Il marker
  resta `OF-11` fino a `CP-03`.
- **Rischio alto:** i boundary di `RunManager` non esplicitamente mappati,
  `GameEvents`, save, contratti/run systems e `project.godot` avviano il
  profilo full; modifiche al workflow e al marker attivano almeno lean. Nessuno
  di questi sposta il checkpoint programmato.
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
python scripts/ci/run_testing_playbook.py --godot-bin ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe" --scenario FULL_RUN
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
statico di checkpoint, pero', usa sempre il playbook completo e comprende:

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
python scripts/ci/run_godot_import.py --godot-bin ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
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
python scripts/ci/run_headless_smoke.py --scenario ROUTE_CASHOUT --godot-bin ".\tools\godot\Godot_v4.7.2-stable_win64_console.exe"
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
Il job `plan` seleziona i controlli; nei checkpoint seguono tre job:

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

Lastra d'avvio (21 ottobre 2026): gli strumenti che istanziano `Main.tscn` e
le esecuzioni headless non la mostrano; per un avvio reale senza lastra si
passa `-- --skip-intro`. La verifica a occhio (battute, skip, movimento
ridotto) resta locale: `docs/support/intro_menu_2026-10-21.md`.

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
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn
```

Per OF-07 non checkpoint, la matrice locale mirata usa:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=pact_tablet
```

Per OF-08 non checkpoint, la matrice locale mirata usa:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=gesture_choice
```

Per OF-09 checkpoint, la matrice locale mirata usa:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=judgment_seal
```

Per OF-10/OF-11, la matrice locale mirata del fascicolo usa:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=final_dossier
```

Per CP-02, la matrice mirata delle impostazioni usa:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/visual_qa_capture.tscn -- --section=accessibility_settings
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

- export release con template Windows Godot 4.7.2;
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
./tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/audit_screen_capture.tscn --audio-driver Dummy --max-fps 60
# Usare un altro profilo vuoto per la prova lineare:
./tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --scene res://tools/audit_screen_capture.tscn --audio-driver Dummy --max-fps 60 -- --linear
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

Il contratto `scripts/ci/seat_case_runtime_contract.gd`, eseguito su profilo
isolato dal runner campagna, verifica presentazione, rinvio, debito,
testimonianza, durata della Pressione, riserva pagata, doppio invio e reload.
Verifica anche i due seguiti, l'assenza di ripetizioni e il resume dopo il
pagamento ma prima della conferma. Il percorso completo rimanda una volta e
poi sceglie la testimonianza, verificando che il seguito compaia naturalmente.
`tools/seat_case_capture.gd` produce fixture IT/EN/ES a 960x540, 720p e 1080p;
`tools/seat_followup_capture.gd` controlla tutte le battute IT/EN/ES e produce
fixture dei seguiti alle due risoluzioni maggiori.
`scripts/ci/seat_inquiry_runtime_contract.gd` verifica ordine libero delle
letture, rinvio e resume, ipotesi non sostenuta, rilettura, conclusione e
Archivio su entrambe le vie. `tools/seat_inquiry_capture.gd` produce fixture
IT/EN/ES del confronto a 720p e 1080p.
`scripts/ci/seat_memory_runtime_contract.gd` verifica che il seguito della
copia richieda l'indagine, rispecchi la via scelta, si ripresenti se interrotto
e non si ripeta dopo lettura e reload; esercita inoltre la risposta nello stesso
percorso dopo l'annotazione. `tools/seat_memory_capture.gd` controlla
le battute tradotte e produce fixture IT/EN/ES a 720p e 1080p.
`scripts/ci/seat_copy_runtime_contract.gd` verifica il prerequisito della
trascrizione, il rinvio con resume, la via gratuita in debito, il pagamento
una sola volta, i due riscontri e l'Archivio. Verifica anche il prezzo effettivo
e l'acquisto della polizza scontata, la scadenza, la migrazione del profilo
pagato precedente, i dati invalidi, l'Assenza e la rimozione dello sconto scaduto
dall'Archivio. `tools/seat_copy_capture.gd` e
`tools/seat_copy_followup_capture.gd` producono fixture nelle tre lingue.
`tools/seat_policy_bank_capture.gd` mostra prezzo e sconto nel Banco IT/EN/ES;
il simulatore conta le polizze effettivamente acquistate con sconto.
`scripts/ci/seat_copy_echo_contract.gd` verifica entrambi gli scambi reattivi,
determinismo, silenzio e leggibilita' della superficie IT/EN/ES; dal 31
ottobre anche l'eco unica nel primo percorso dopo la scelta, la conservazione
nel checkpoint e il silenzio dopo il congedo.
`scripts/ci/seat_steps_era_contract.gd` (30 ottobre 2026, nel runner campagna)
verifica un passo dell'arco per Era: nessun caso prima dell'Era 1, richiamo
come prima scena dell'entrata, precedenza di scene d'Era e congedo, nessun
richiamo accodato dopo un'altra scena anche dopo il resume, conseguenze nella
stessa entrata, chiusura dell'arco, persistenza e traduzioni EN/ES dei
richiami. I contratti di confronto e copia usano le Ere 2 e 3.
`scripts/ci/final_era_runtime_contract.gd` (30 ottobre 2026, nel runner
campagna) verifica lo smontaggio dell'ultima Era: dati del profilo e default,
una scena per percorso secondo `era_runs`, foglio dell'ultima cifra in attivo,
a zero e in debito, Banco chiuso e conto fermo, gradinata e voce ai percorsi
successivi, ultimo bando a un gradino in meno su tutte le arene (anche dopo il
checkpoint) con i testi del pannello e del fascicolo, ultima strofa, nessun
bando dopo, ultima copia con
le sole memorie presenti, congedo al quinto percorso, resume, Archivio, reset,
copia del posto non piu' pagabile, traduzioni EN/ES e testo delle scene senza
tagli a 720p e 1080p. Il contratto di campagna verifica l'ordine dello
smontaggio fino all'Assenza. `scripts/ci/session_log_contract.gd` (31 ottobre
2026, nel runner campagna) verifica che il tempo attivo cresca solo dentro un
percorso, resti nel checkpoint e produca una riga completa per percorso nel
registro locale. `tools/final_era_capture.gd` (non headless)
produce le catture dei due fogli IT/EN/ES a 720p e 1080p.
le fixture non sostituiscono l'osservazione umana del percorso.

`scripts/ci/run_campaign_runtime_contract.py --godot-bin <Godot>` percorre
la UI reale da profilo isolato fino all'Assenza, senza inserire storie o esiti.
Prima esegue `scripts/ci/crowd_seed_runtime_contract.gd`: verifica che gli
intenti della folla dipendano dal seed salvato, anche dopo serializzazione e
ricostruzione dello stato, non dall'orologio o dall'ambiente smoke.
Esegue anche `scripts/ci/ledger_settlement_runtime_contract.gd` su un profilo
separato: a parita' di quietanza un bando che porta il conto sopra zero non
deve eliminare il beneficio previsto per un debito preesistente.
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

`tools/run_economy_matrix.py` esegue il simulatore su seed e policy con un
profilo isolato per campagna e conserva log e righe `SIM_RUN`. Per i confronti
a un solo fattore accetta `--seeds`, `--policies`, `--seat`, `--copy` e
`--initial-denari`, inoltrati senza modifiche al simulatore.
`tools/economy_baseline_report.py` legge uno o piu' `summary.json` e produce
tabelle per campagna e per Era, racconti mancati e percorso con piu' scene.
Baseline del 29 ottobre 2026: `docs/support/baseline_economia_ritmo_2026-10-29.md`.
Una campagna marcata `ObjectDB` o non valida resta nel resoconto come tale.
Dal 31 ottobre il simulatore chiude come i contratti: tempo normale, stop
dell'audio e 250 ms reali al driver (`scripts/ci/audio_test_teardown.gd`);
prima chiudeva con un timer a velocita' 12x e circa meta' delle campagne
parallele finiva con risorse ancora in uso. Ogni riga `SIM_RUN` riporta
anche `samples` e `choices` dell'evoluzione del Registro.

## Pass UI Atto a stampa - 10 ottobre 2026

Verifica headless del branch `claude/ui-pass`: import, playbook statico,
runtime contract e smoke `KEYBOARD_FULL_RUN` verdi; `test_ui_motion_contract`
ora vieta la scala hover del menu e richiede la guardia del tween d'accento.
La revisione visiva a 720p/1080p (catture kit/counter, campionario sezione 5)
resta da eseguire in locale: il pass non e' validato finche' non e' fatta.
