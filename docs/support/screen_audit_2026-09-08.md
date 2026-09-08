# Audit schermate, background e soundtrack - 8 settembre 2026

Correzioni successive autorizzate e verificate: `docs/support/consistency_fix_2026-09-08.md`.
Questo documento conserva il verdetto del candidato prima delle correzioni.

## Verdetto

Il tema ha una base comune, ma la verifica complessiva **non e superata**.
Tre difetti funzionali precedono il polish: ritorno dal Silenzio fuori schermo,
superfici cicatrici non raggiungibili e due stati musicali mai attivati nel
percorso provato. Crediti, Archivio, microcopy e alcuni dettagli grafici
richiedono una bonifica mirata. Il prologo e consigliato come apertura breve,
dopo questi interventi, con bozza in `docs/cinematic_direction.md`.

Audit sul commit `303039c`, runtime invariato durante questa verifica.
Godot 4.6.2 Windows, Vulkan Forward+, viewport 1280x720 e 1920x1080,
profili separati; IT/EN/ES nella matrice, percorso lineare IT.
327 catture accettate come evidenza, 2 tentativi di popup respinti:
non mostravano il target. La review visuale riguarda i campioni qui elencati e
alcune varianti linguistiche/stato, non ogni singolo PNG. La matrice registra
anche texture e stili effettivamente risolti sui controlli visibili.

Galleria con screenshot e note: `artifacts/screen_audit_2026-09-08/report.html`.
Inventari e hash: `artifacts/screen_audit_2026-09-08/audit_manifest.json`.
La cattura lineare evita i riposizionamenti della matrice. Usa gli handler del
gioco, seed e outcome stabilizzati dal tool esistente; non e un playtest umano.
Silenzio e Assenza sono attivati direttamente sulla superficie presentazionale.

## Schermata per schermata

| Passo | Schermata | Esito | Riscontro |
| --- | --- | --- | --- |
| 1 | Menu / soglia | Coerente | Titolo dominante, comandi secondari compatti, medesima pietra e bronzo. |
| 2 | Archivio condanne | Da correggere | La tab attiva usa disabled; testi bloccati molto attenuati. Titolo, descrizione e cornice annidati. |
| 3 | Museo | Da correggere | Titolo ancora Archivio delle condanne; Livello 3 e nomenclatura tecnica esposti. |
| 4 | Crediti | Da correggere | Colonna di circa 200 px in un pannello di circa 950 px. Corpo spezzato, denominazione precedente e testo italiano anche in EN/ES. |
| 5 | Opzioni | Coerenza parziale | Struttura leggibile. Slider con grabber standard e stile delle maiuscole non uniforme tra lingue; dropdown con selezione grigia standard, estranea alla finitura bronzo. |
| 6 | Registro chiuso | Coerente | Oggetto centrale, cera, bronzo e gesto leggibile. |
| 7 | Registro aperto / firma | Coerente, denso | Stessa famiglia materica. Due offerte confrontabili; la firma rossa e la tavola sono variazioni funzionali, non comandi utility. |
| 8 | Patto sigillato | Coerente | Centrato nella prova lineare. Lo spostamento dopo la matrice e un artefatto del tool, non un difetto dimostrato del gioco. |
| 9 | Gesto pubblico | Coerente | Due oggetti confrontabili, stessa geometria e materiale. La cattura lineare iniziale coglie il breve stato ancora disabilitato. |
| 10 | Rito di giudizio | Coerente | Sigillo, tre colpi e testo leggibili; musica non cambia rispetto al Registro. |
| 11 | Incasso / condanna / rilancio | Coerenza parziale | Carta, marchio rosso e incisione sono oggetti diversi per scelta canonica. Contorno e luminanza non risultano identici; spiegazione incasso bloccato visibile. |
| 12 | Fascicolo aperto | Coerente | Carta, inchiostro scuro e linguette coerenti con lo stato del documento. Testo secondario piu piccolo dei pannelli precedenti. |
| 13 | Fascicolo chiuso | Da rifinire | Passaggio alla pietra intenzionale. Il piccolo sigillo in alto conserva un quadrato nero visibile attorno all immagine. |
| 14 | Dettaglio cicatrici / notifica | Bloccato | Tentativi con contenuto di prova non mostrano le superfici. ScarsDetailText e Label nella scena ma viene cercato come RichTextLabel; scar_popup e scar_popup_panel rimangono null. |
| 15 | Silenzio | Bloccante | Torna al menu e visibile per Godot ma a (-160,-88), 320x52: interamente fuori viewport. Il nero non dimostra che il ritorno funzioni. |
| 16 | Assenza | Coerente visivamente | Nero senza HUD, sottrazione coerente. Stato terminale invocato nella fixture; questa prova non completa una campagna umana. |

## Difetti prioritari

1. **P1 - Ritorno dal Silenzio fuori viewport.**
   `scripts/ui/registry_terminal_view.gd`, impostazione della posizione di
   ReturnToMenu: dopo gli anchor centrali viene assegnata position=(-160,-88).
   L'inventario runtime conferma il rettangolo negativo in entrambe le prove.
   Correggere gli offset relativi agli anchor e provare click e tastiera dopo
   il ritardo, a entrambe le risoluzioni. Non modificare il finale Assenza.
2. **P1 - Musica collegata agli ID sbagliati.**
   `scripts/audio/music_director.gd` confronta BET_COMMITTED,
   INTERMEDIATE_CHOICE e PUSH_YOUR_LUCK; `RunManager._set_runtime_gate_phase`
   emette invece PREP/LIVE/GAME_OVER (0/1/2). Il ramo di default mantiene safe.
   Usare gli eventi semantici esistenti per il consumer musicale e aggiungere
   un test che percorra i gesti reali, senza chiamare direttamente il director.
3. **P1 - Dettaglio cicatrici non si apre.**
   In `scenes/UI.tscn` ScarsDetailText e Label, mentre `scripts/ui/ui_root.gd`
   lo converte a RichTextLabel: la reference e null e _show_scars_detail esce.
   Anche scar_popup e scar_popup_panel risultano dichiarati ma non collegati.
   La prova grafica con testo campione non ha mostrato nessuno dei due target.
   Ripristinare binding/tipi, poi verificare leggibilita, focus, chiusura e
   contenuto lungo. Il loro stile completo non e certificato da questo audit.
4. **P2 - Crediti.** Il VBox centrale non ha una larghezza adeguata; il corpo
   crea una colonna di righe cortissime. Anche selezionando EN/ES dalla UI il
   corpo resta italiano. Nomi e attribuzioni erano sospesi dall'utente: qui il
   difetto riguarda layout, localizzazione e intestazione precedente.
5. **P2 - Archivio.** Selected viene reso come disabled, mentre il focus puo
   illuminare l'altra scheda. Il titolo non cambia nel Museo. Rimuovere
   Livello 3 dal copy di prodotto e usare uno stato selected esplicito.
6. **P2 - Finitura comune.** Sigillo con fondo quadrato nel fascicolo chiuso,
   selezione grigia dei dropdown e cromatura standard degli slider, maiuscole variabili EN/ES e cornici
   annidate delle utility. Definire un'unica famiglia utility con stati
   condivisi, preservando gli oggetti rituali distinti prescritti dal canon.

## Background e componenti

Le superfici osservate risolvono lo stesso `registry_chamber.png` per menu,
Registro e fascicolo. La differenza di luce/crop fra soglia e gameplay e
coerente con la funzione della scena; non sono emersi vecchi fondali horror
nelle catture e nei binding runtime ispezionati. La continuita visiva delle
Ere lungo una campagna non e verificata da questo percorso breve.

Sono state inventariate 44 combinazioni di stile normal/panel, comprese
varianti degli oggetti e contenitori vuoti. Il numero non equivale a 44 temi:
i controlli utility condividono bronze_plaque, mentre firma, patto, gesto,
quietanza, marchio e fascicolo hanno materiali funzionali diversi. Uniformare
bordi, trattamento del testo e feedback non richiede di rendere tutti questi
oggetti lo stesso rettangolo. I due dropdown nativi sono stati catturati dai loro viewport: cornice
corretta, ma selezione grigia di Godot e radio standard (popup.log).
Tutti gli stati di hover e la conformita accessibile completa non sono
certificati; il fallback osservato va uniformato prima della firma visuale.

## Soundtrack osservata nel runtime

| Superficie | Stream effettivo | Valutazione |
| --- | --- | --- |
| Menu | atrium.wav | corretto |
| Registro chiuso/aperto | registry.wav | corretto |
| Patto, gesto, rito | registry.wav | stato tense non raggiunto |
| Push-your-luck | registry.wav | stato climax non raggiunto |
| Fascicolo | dossier.wav | corretto |
| Silenzio/Assenza nella fixture | player musicali fermi | corretto per la sottrazione musicale |

`runtime_inventory_linear.json` registra tempi, fase, nome stream, posizione
in riproduzione e gain. `runtime_music.wav` e una registrazione reale del bus
Music durante il percorso, con driver Dummy; non e un file sorgente rinominato.
Non include SFX o il battito sul bus SFX. Il contratto AV esistente passa 28
condizioni, ma non rileva il difetto: crossfade e mute verificati direttamente
non garantiscono che il flow raggiunga ogni stato sonoro.

Le ricette dei cinque brani condividono timbri e armonia D/A, in linea con la
palette prevista. La coerenza emotiva, il raccordo udibile dei loop da 48 s e
la fatigue su 2-4 ore richiedono ascolto umano: non sono certificati dai
livelli o dalla semplice presenza dei file. La priorita e far partire i
brani previsti; non servono altri WAV per risolvere il collegamento.

## Cutscene proposta

Prologo in-engine di circa 8 s: soglia (0-3), Registro (3-6), dissolvenza nel
primo gesto (6-8). Due frasi: **Ogni rischio accettato lascia un segno.** /
**Il Registro conserva le tue scelte.** Chiusura su APRI IL REGISTRO.
Skip dalla prima visione, nessuna ripetizione durante resume o ogni nuova run,
immagini ferme con tempo di lettura conservato in Movimento ridotto.
Riutilizzare gli asset approvati; niente personaggio narrante o anticipazione
del finale. Bozza multilingue e criteri sono in `docs/cinematic_direction.md`.
La cutscene non e stata implementata: questa e una valutazione della proposta.

## Prove, limiti e file cambiati

Cattura matrice e percorso lineare completati; diagnostica attesa sulla scena
helper diversa da Main. Contratto AV locale: 28 condizioni verdi; 43 contratti statici verdi. Import,
contratti asset/tema, riferimenti docs e scansione mojibake sono registrati
nei log finali della cartella audit. Nessuna nuova build, CI remota, firma
Steam o sessione umana dichiarata. Il prodotto resta DEVELOPMENT.

File di questo audit: `tools/audit_screen_capture.gd`, `tools/audit_screen_capture.gd.uid`, `tools/audit_screen_capture.tscn`, `docs/README.md`,
`docs/development_plan.md`, `docs/audio_direction.md`,
`docs/cinematic_direction.md`, questo report e `docs/testing.md`.
Gli artifact sono locali e ignorati da Git. Nessuna modifica a script runtime,
scene del gioco, asset, dati, save, GameEvents o RunManager; nessun commit/push.
