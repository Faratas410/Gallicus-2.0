# Manifesto: verifica visiva locale e compatibilita' Godot 4.7.2

15 ottobre 2026. Stage: Core Playable Candidate, invariato.
Richiesta: verificare il pass integrato a 720p/1080p, correggere i difetti e
controllarne il funzionamento con Godot 4.7.2. Direzione Manifesto confermata.

## Candidato e superficie

- Branch `main`, HEAD iniziale `b81a4fc00797be0b0f0b7dd68639e309f3db061c`.
- Working tree iniziale pulito; consegna finale locale, non committata.
- Motore del Desktop: `4.7.2.stable.official.ed1daf0bf`, edizione standard.
  [Archivio ufficiale](https://godotengine.org/download/archive/4.7.2-stable/).
- Windows; Vulkan 1.4.351, Forward+, NVIDIA GeForce RTX 5070 Ti Laptop GPU.
- 1280x720 e 1920x1080; IT, EN, ES; profili usa e getta sotto artifacts.
- Nessun export o modifica alla versione del progetto/CI: baseline 4.6.2.
- RunManager conserva flow e decisioni; GameEvents, save, seed, economia e
  contratti dei segnali restano invariati.

## Difetti riprodotti e correzioni

| Difetto | Evidenza prima | Correzione e prova dopo |
| --- | --- | --- |
| Important: tab Archivio stretti e verticali, testo illeggibile e ritorno fuori dal viewport | `before/utility/06_archive_it_1280x720.png` e Museo | Minimo 240x52 per tab, espansione orizzontale; testi e ritorno contenuti nelle tre lingue e due risoluzioni |
| Important: incisioni della scheda Museo attraversano la prima/ultima riga | `before/utility/08_museum_it_1280x720.png` | La superficie passiva recupera i margini del PanelContainer; righe nel padding, testo libero |
| Important: nota ES di debito esce dal banco nelle due risoluzioni | `before/counter/banco_-5_es_1280x720.png`; due errori di contenimento | Font di servizio 15 px al posto del corpo 17; matrice successiva 138/138 senza errori |
| Minor: due checkbox visibili per una sola opzione | `before/utility/02_settings_it_1280x720.png` | Rimosso il prefisso testuale `[ ]`/`[X]`; restano icona e stato nativi |
| Verifica 4.7.2: lo smoke raggiunge il menu ma termina con tre stream/sei riferimenti audio vivi | `keyboard.log`, `keyboard_verbose.log` | Shutdown nel solo driver smoke: stop, stream null e attesa 0.2 s; validator originale da tastiera superato |
| Fixture CP-02: due SaveManager istanziati fuori dall'albero non liberati | `playbook/cp02_runtime_contract.log` | Liberazione dei due nodi; `cp02_final.log` conserva il test del JSON guasto e non ha warning di leak |

Il primo import sandbox aveva segnalato `Safe save failed`. L'import ripetuto
con permessi normali e profilo isolato e' pulito (`import_full.log`); nessuna
allowlist o modifica alle impostazioni del motore. I tentativi del capture
utility con `current_scene` mancante o dimensioni errate non sono prove PASS:
il capture finale corregge entrambi e termina senza ERROR.

## Percorso ispezionato

| Passo | Schermata e obiettivo | Esito locale |
| --- | --- | --- |
| 1 | Menu: ingresso e utility distinguibili | OK, soglia materiale preservata |
| 2 | Opzioni: campi, slider, checkbox, focus e popup | OK, testo nativo e un solo indicatore per toggle |
| 3 | Crediti: corpo e ritorno | OK nelle tre lingue |
| 4 | Archivio: tab, voci bloccate e ritorno | Corretto; selected distinto da registered |
| 5 | Tooltip e Museo: lettura, margini e scroll | Corretto; incisioni fuori dal testo |
| 6 | Dialogo: ritratto, corpo, avanzamento e salto | OK; prima battuta catturata, tutte le battute coperte dal contratto runtime |
| 7 | Registro, Patto, Gradinata, giudizio e posta | OK nella matrice; nota ES corretta, oggetti e target stabili |
| 8 | HUD, Segni e Fascicolo aperto/chiuso | OK nei campioni; nessun nuovo taglio riscontrato |
| 9 | Campionario e percorso da tastiera | Input del kit verificato; uscita smoke corretta |

Le viste derivano dai componenti e dalle scene reali, con stato di presentazione
iniettato dove dichiarato. Non rappresentano una partita umana. Le biografie
sono intenzionalmente scrollabili; il contratto cast ne verifica la raggiungibilita'.

### Confronto Archivio, 720p IT

Prima: tab senza testo leggibile e ritorno tagliato.

![Archivio prima](../../artifacts/manifesto_review_2026-10-15/before/utility/06_archive_it_1280x720.png)

Dopo: tab orizzontali, lista e ritorno nel viewport.

![Archivio dopo](../../artifacts/manifesto_review_2026-10-15/final/utility/06_archive_it_1280x720.png)

### Lettura e dettaglio

![Museo dopo](../../artifacts/manifesto_review_2026-10-15/final/utility/08_museum_it_1280x720.png)

![Segni dopo](../../artifacts/manifesto_review_2026-10-15/after/counter/scars_detail_it_1280x720.png)

## Evidenze e riproduzione

Radice locale: `artifacts/manifesto_review_2026-10-15/`.

Verifica finale: playbook **58/58 PASS** su Godot 4.7.2: 45 controlli
statici, import, CP-02, audit semantico, AV/cast/dialoghi, campagna fino
all'Assenza e gli otto smoke BET_PRESENT, FULL_RUN, ROUTE_CASHOUT,
ROUTE_DOUBLE, ROUTE_CONDANNA, ROUTE_REGISTER_FINAL, CORE_CONTINUITY e
KEYBOARD_FULL_RUN. La fixture CP-02 e' stata poi ripetuta dopo il proprio
cleanup, con esito positivo. L'errore di parsing JSON in quella prova e'
intenzionale: verifica il recupero del salvataggio guasto, non un errore
del candidato. L'audit verifica anche il rifiuto di una ripresa senza save.
Docs refs, mojibake e diff check verificati nuovamente dopo i documenti.

- `before/counter`: 138 PNG, due errori sulla nota ES.
- `before/utility`: diagnosi iniziale; le viste 1080p con dimensioni errate
  sono rifiutate e non entrano nel set finale.
- `after/counter`: 138 PNG, nessun errore; tutte le combinazioni IT/EN/ES
  alle due risoluzioni. Fixture reduced motion, con press/hover della posta.
- `final/utility`: 62 PNG, nessun errore; include 12 immagini dei PopupMenu
  alle dimensioni proprie del popup, non del viewport.
- `final/gallery`: 27 PNG, nessun errore; mouse sulle note, click/Invio
  singoli, disabled, selected, registered, target stabili e adapter idempotente.
- `inspection`: contact sheet di tutte le 62 utility, delle 46 viste gameplay
  IT, di 16 viste gameplay EN/ES (banco in debito, Segni, Fascicolo WIN/chiuso)
  e dei 27 campioni kit: 151 immagini ispezionate tramite contact sheet,
  con ingrandimenti dei difetti e campioni di lettura. I 227 PNG prodotti
  non equivalgono a 227 revisioni individuali a piena risoluzione.
- `candidate_manifest.json`: versione/hash motore, hash dei file candidati e
  inventario delle immagini finali. Le catture visuali precedono la sola
  cura successiva dello shutdown smoke e della fixture CP-02.
- `playbook/`: import, controlli statici, contratti e otto route sul candidato.
- `cp02_final.log`: ripetizione mirata dopo la liberazione dei nodi di fixture.

Comandi dei capture, con `$godot` impostato al console ufficiale 4.7.2 e
APPDATA/LOCALAPPDATA/TEMP/TMP in cartelle di prova distinte:

```powershell
& $godot --path . --audio-driver Dummy --max-fps 60 --script res://tools/counter_layout_capture.gd -- --all-languages --capture-dir=res://artifacts/manifesto_review_2026-10-15/after/counter
& $godot --path . --audio-driver Dummy --max-fps 60 --script res://tools/manifesto_review_capture.gd -- --capture-dir=res://artifacts/manifesto_review_2026-10-15/final/utility
& $godot --path . --audio-driver Dummy --max-fps 60 --script res://tools/manifesto_kit_capture.gd -- --all-languages --capture-dir=res://artifacts/manifesto_review_2026-10-15/final/gallery
```

Le impostazioni salvate possono indicare 1280x720 anche nella fixture 1080p:
la matrice cambia la finestra senza modificare la preferenza dell'utente.
Il nuovo capture controlla i pixel effettivi, non il solo nome del file.

## File della consegna

- `scenes/Main.tscn`: dimensioni dei tab Archivio.
- `scripts/ui/main_menu.gd`: label checkbox senza duplicazione.
- `scripts/ui/manifesto_document_surface.gd`: margini delle schede.
- `scripts/ui/betting_circle_ui.gd`: nota banco a 15 px.
- `scripts/systems/run/smoke_driver.gd`: shutdown audio del solo smoke.
- `scripts/systems/run_manager.gd`: inoltro del quit smoke al driver.
- `scripts/ci/cp02_runtime_contract.gd`: cleanup dei nodi di fixture.
- `tools/manifesto_review_capture.gd` e relativo UID: verifica utility ripetibile.
- `docs/README.md`, `docs/development_plan.md`, `docs/art_direction.md`,
  `docs/testing.md`, `docs/support/manifesto_atto_a_stampa_2026-10-10.md` e
  questo report: stato corrente, regole visuali e prove aggiornate.

## Limiti e prossimo passo

Compatibilita' verificata localmente con 4.7.2; nessuna promozione automatica
della baseline CI. Checkpoint Linux del candidato finale e accettazione umana
del carattere visivo, della lettura, del ritmo e del mix restano aperti.
Non e' un audit di accessibilita' assistiva o un signoff di hardware minimo.
Le catture usano audio Dummy e non certificano l'ascolto.

Il fallback tipografico storico del Fascicolo resta per compatibilita' con
4.6.2; non si rinominano risorse font o skin rituali durante questa verifica.
La revisione locale non ha rilevato altri difetti bloccanti nei campioni
ispezionati. Il prossimo passo e' la revisione dell'utente, il commit manuale
del candidato, il checkpoint Linux e le sessioni umane CP-03.
