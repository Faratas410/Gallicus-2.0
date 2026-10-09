# Manifesto - preparazione delle schermate rimanenti

9 ottobre 2026. Richiesta: preparare l'implementazione per le altre
schermate. Questa consegna definisce pacchetti, punti di integrazione e
prove; non modifica runtime o asset e non introduce un nuovo concept.

## DIAGNOSIS

Stato ricontrollato: main, HEAD
`6f8088abb8227f4100416dd49ad7e14a606e0e85`, 20 voci locali preesistenti
all'avvio di questa preparazione. Il precedente candidato `da99a64` e'
storico: non usare le sue catture come prova del working tree corrente.

Il kit del 9 ottobre e' gia' presente nel working tree e va preservato:
`docs/support/ui_kit_2026-10-09.md`. Posta e comandi del fascicolo usano
`scripts/ui/manifesto_kit.gd`, `manifesto_action_surface.gd` e
`manifesto_primitives.gd`. La palette rimane inchiostro `191917`, avorio
`e7ddc5`, cera `792d26`; font e misure hanno gia' un owner comune.

La lettura del codice conferma queste differenze ancora aperte:

- Registro: `betting_circle_ui.gd` applica ancora famiglie StyleBox proprie
  e modula intere pagine. Firma e selezione hanno stati distinti.
- Patto, Gradinata e giudizio: consumer in `ui_root.gd`, superfici e oggetti
  in `scenes/UI.tscn`; non sono migrati al kit dalla patch corrente.
- Fascicolo: comandi gia' migrati; corpo, carta e gerarchia editoriale no.
- Menu e Archivio: appartengono a `scenes/Main.tscn`, non a una scena
  MainMenu separata. `main_menu.gd` crea anche righe e schede dinamiche.
- Kit: adatta Button e Label, non ancora RichTextLabel, schede di lettura
  o linguette di consultazione con selezione distinta dalla registrazione.

Questa e' un'ispezione di sorgenti e documentazione, non un nuovo audit
visivo. Le catture prima/dopo vanno prodotte sul candidato di ogni pacchetto.
Il materiale dell'8 ottobre resta utile come riferimento di direzione.

## WORKFLOW

Procedere con patch separate, una alla volta. Ogni patch lascia una
schermata funzionante, aggiorna gli owner e include il confronto con le
fasi adiacenti. Il campionario mostra i componenti realmente usati nel
gioco; non diventa una seconda implementazione della UI.

Riutilizzare `Kit.apply_action`, `Kit.layout_action`, `Kit.apply_label` e
le primitive gia' presenti. Quando serve una superficie di lettura o un
ruolo per RichTextLabel, aggiungerlo al kit soltanto insieme al primo
consumer reale. Nessun tema globale sostitutivo o override ricorsivo su
tutte le scene. Il layout specifico resta nel consumer della fase.

La distinzione tra selected e registered e' obbligatoria: una pagina
consultata, una promessa selezionata o un tab attivo non sono una firma.
In Registro il metadato `registry_promise_signature_state` contiene gia'
normal/selected/signed/disabled. Mappare l'impronta piena solo a signed.
`_submit_selected_offer` imposta attualmente signed prima dell'emissione
dell'intento: conservare quel feedback locale e la sua tempistica, senza
presentarlo come nuova conferma di salvataggio o cambiare il protocollo.

RunManager mantiene flow, disponibilita' e risultati; GameEvents gli
intenti. Conservare nodi, focus, tooltip, testi semantici, lock e recuperi.
Nessuna nuova regola, riscrittura, soglia, ricompensa, schema save o audio.
Preservare anche Lauro, gesta e benchmark dell'integrazione recente.

## NEXT ACTION - ordine dei pacchetti

### 1. Registro, banco e firma - prima implementazione

Composizione: documento in primo piano, due promesse affiancate con stessa
struttura di titolo/condizioni/costo; cera concentrata nel punto di firma.
Superfici calme avorio/inchiostro, margini incisi. Il banco resta qui.
Nessuna fascia della posta o numero gigante.

File: `scenes/ui/BettingCircle.tscn`, `scripts/ui/betting_circle_ui.gd`,
kit solo per le estensioni necessarie. I Button e le label di firma
esistenti vanno adattati evitando titoli doppi fra Lbl_Sign e PrintedTitle.
Le condizioni RichTextLabel devono conservare formattazione e contenuto.

Sequenza tecnica: catture baseline -> ruolo testo ricco/superficie documento
nel kit -> apertura del Registro e servizi del banco -> due pagine e firme
-> applicazione del kit dopo gli aggiornamenti di stato esistenti -> prove.
L'apertura e i suoi lock mantengono durata e ordine; l'hover dei comandi
migrati non li scala. La selezione deve funzionare anche senza colore.

Chiusura: apertura/riapertura, due offerte e offerta mancante, descrizioni
lunghe, firma sinistra/destra, selected distinto da signed, disabled,
saldo insufficiente e servizi disponibili, ripresa esistente. Un solo
intento per attivazione e nessun testo coperto a 720p. Transizione fino al
patto senza doppie skin, tracce o focus rimasti sulla pagina chiusa.

### 2. Patto e Gradinata

Patto: tavoletta con titolo e vincolo, una sola azione. Gradinata: lasciare
aperto il campo centrale; risposte raccolte in basso con conseguenze
allineate e intenzione del pubblico chiaramente separata. Il rosso segnala
esposizione, non rende ogni risposta un rilancio.

File: `scenes/UI.tscn`, consumer pertinenti in `scripts/ui/ui_root.gd`.
Applicare il kit ai controlli esistenti; non modificare scambi, attese o
ordine delle fasi per adattarli al layout. Niente banco nell'arena.
Prove: patto validato, tre scambi della folla, favore positivo/negativo,
effetti lunghi, focus, blocco e passaggio al giudizio/posta nel flow reale.

### 3. Giudizio

Composizione: sigillo protagonista, titolo subordinato, gesto centrale;
comandi ausiliari compatti. La cera resta riconoscibile come oggetto.
La superficie generica del kit non deve sostituire il sigillo con una card
o convertire i suoi indicatori di colpo nel marchio a tre incisioni.

File: `scenes/UI.tscn`, sezioni del rito in `scripts/ui/ui_root.gd` e
risorse dell'oggetto solo se necessarie. Conservare rappresentazione dei
colpi, crepe, stati e feedback; nuovi raster solo con asset pipeline e
verifica nel gioco. Prima migrare tipografia, supporto e comandi ausiliari.
Prove: primo colpo, colpi successivi, sigillo retto/ceduto, arresto e scelta
del Segno quando prevista, input ripetuto, lock/recupero, motion ridotto.

### 4. Fascicolo, HUD e dettaglio Segni

Fascicolo: risultato impresso, corpo avorio ordinato e continuazione distinta;
riutilizzare i comandi gia' migrati. Uniformare titolo, sezioni e superficie
senza impoverire il resoconto. Il raccordo al portico riguarda il risultato,
non la decisione quietanza/raddoppio che resta nell'arena.

HUD: stessi ruoli tipografici e superfici, senza ridefinire informazioni o
duplicarle. Dettaglio Segni: nomi, effetti e racconto leggibili con scroll
prevedibile. Conservare gesta/Lauro e tutti i campi presenti nel candidato.

File: `scenes/UI.tscn`, `scripts/ui/ui_root.gd`; kit per superfici di lettura.
Prove: CASHOUT/LOSS/WIN, fascicolo aperto/aggiornato/chiuso, testi e liste
lunghe, zero/molti Segni, dettaglio/chiusura, scroll, route disponibili,
HUD ripristinato dopo la posta. Nessun nuovo contatore o stato persistente.

### 5. Menu, impostazioni e crediti

Menu: titolo pubblico e soglia d'ingresso dominante, ripresa distinta e
utility subordinate. Conservare il marchio esistente; nessun nuovo logo.
Impostazioni e crediti: stessa tipografia e materiali, controlli convenzionali
per slider, selettori e toggle; non convertirli in atti da firmare.

File: `scenes/Main.tscn`, `scripts/ui/main_menu.gd`. Raccordare le animazioni
legacy con gli stati fermi del kit solo sui comandi migrati. Prove: nessun
save/save valido/ripresa indisponibile, avvisi lunghi, Tab/Invio/Escape,
entrata/ritorno dalle utility, scroll e impostazioni nel profilo isolato.

### 6. Archivio

Composizione: consultazione, non decisione di rischio. Titolo, tab e schede
con gerarchia regolare; materiale comune alle pagine del Registro, nessun
marchio di conferma sulle voci soltanto lette. Distinguere voce bloccata,
disponibile e tab selezionato senza affidarsi al colore.

File: `scenes/Main.tscn`, `scripts/ui/main_menu.gd`; adattare le factory locali
`_create_condanna_entry_panel` e `_create_museo_entry_panel`. Evitare di
cambiare globalmente `ui_factory.gd` senza censire tutti i consumer.
Prove: Archivio vuoto e popolato, entrambi i tab, tooltip ai bordi, schede
lunghe, scroll fino all'ultima voce e ritorno. Includere i sei personaggi
attuali, Lauro compreso; nessuna modifica a sblocchi o dati.

### 7. Superfici narrative e verifica della sequenza

Censire e raccordare i supporti ancora estranei: dialoghi e racconti di
`scripts/ui/opening_prologue.gd`, tooltip/notifiche e terminale del Registro
in `scripts/ui/registry_terminal_view.gd`. Migrare solo supporti, caratteri
e comandi pertinenti; mantenere ritratti, testi, timing e contenuti.

Rileggere poi la sequenza completa dal menu al resoconto e all'Archivio.
Ere e Silenzi conservano le loro variazioni e sottrazioni; l'Assenza non
riceve nuove cornici, titoli, marchi o CTA. Prove dedicate su transizioni,
overlay, menu di ritorno e chiusura terminale. La continuita' viene da
materiali, tipografia e stati, non da una composizione unica.

## Prove e dipendenze comuni

- Per richiesta ancora attiva: catture e prove runtime **solo IT**, 1280x720
  e 1920x1080. Conservare EN/ES nel prodotto e nei contratti statici.
  `counter_layout_capture.gd` ha gia' default IT. Il nuovo
  `manifesto_kit_capture.gd` itera invece tre lingue: nel primo pacchetto
  aggiungere un filtro/default IT prima di usarlo; nessuna modifica oggi.
- Prima di ogni edit runtime: code_quality, object_grammar e canon owner;
  fotografia del candidato corrente e snapshot dei file gia' dirty.
- Ogni nuovo componente entra nel campionario con normal, hover, focus,
  pressed, disabled e selected/registered pertinenti; poi si verifica nel
  consumer reale. Non applicare registered automaticamente alla selezione.
- Estendere la fixture mantenuta alle superfici toccate. Per menu e Archivio
  aggiungere scenari con save isolati vuoti/popolati e scroll; non fingere
  copertura attraverso il campionario. Usare stessi dati nei prima/dopo.
- Import e playbook statico completo; KEYBOARD_FULL_RUN per ogni patch;
  route degli oggetti toccati. Per menu/ripresa verificare ingresso e ritorno;
  per la sequenza terminale includere ROUTE_REGISTER_FINAL.
- Misurare contenimento, padding, target e contrasto; ispezionare screenshot
  e input reale, entrambe le modalita' motion. Aspettare l'assestamento dei
  container prima delle catture, senza disattivare controlli geometrici.
- Audio Dummy, profili separati sotto artifacts, APPDATA/LOCALAPPDATA/TEMP/TMP
  isolati; nessun playtest visibile o modifica delle impostazioni personali.
- Leggere log runtime e teardown oltre al PASS del validator. Gli avvisi
  storici ObjectDB/resource restano da classificare sul nuovo candidato.

Il rifacimento integrale degli ambienti e dei ritratti resta distinto.
Le reference fotografiche fissano geografia, non sono asset runtime approvati.
Il raccordo dei supporti non autorizza nuovi personaggi, lore o meccaniche.

## EXPECTED HANDOFF

Per ogni pacchetto: elenco dei consumer migrati e di quelli ancora precedenti,
file del solo nuovo pass, API aggiunte al kit, catture prima/dopo ispezionate,
log e hash del candidato, verifiche e limiti. Aggiornare art/layout/testing,
UI_CANON solo per il comportamento realmente cambiato, e roadmap.

La revisione umana del tono e della leggibilita' resta distinta dalle prove
locali e dal checkpoint Linux. Nessuna approvazione artistica totale ricavata
dalla scelta del concept. Stage Core Playable Candidate invariato.
Lavoro su main, un agente, nessun branch/commit/push/PR/export/pubblicazione.

Prima azione operativa pronta: catturare Registro chiuso/aperto, due firme
e stati limite del candidato corrente, poi implementare il pacchetto 1.
