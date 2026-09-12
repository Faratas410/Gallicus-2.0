# Dialoghi illustrati - 12 settembre 2026

Richiesta: art originali e finestre con personaggio a sinistra, battute a
destra, per inizio, meta' e termine. Preferenza esplicita dell'utente:
Registro come terminale rituale impersonale. Nessuna personalita' IA.

## Oggetto e contenuto

Intento: ascoltare gli abitanti nei passaggi della campagna.
Oggetto: presenza ritratta accanto alla superficie di conversazione; per il
Registro, terminale di basalto, bronzo, vetro e tavoletta in ingresso.
Gesto: ascoltare la battuta successiva o tornare al rito.
Feedback: ritratto, nome, ruolo, testo localizzato e posizione nella scena.
Registrazione: solo presa visione; nessun esito, premio o scelta narrativa.
Owner: RunManager sceglie la scena; GameEvents riceve l'acknowledgment; la UI
blocca l'input coperto e restituisce il focus al Registro.

| Passaggio | Scena | Entrata autoritativa |
| --- | --- | --- |
| Inizio | La prima copia | Primo percorso, prima promessa, profilo senza prologo gia' visto |
| Meta' | La stessa riga | Primo ingresso disponibile dopo il secondo Silenzio |
| Termine | Il posto accanto | Primo ingresso disponibile nell'ultima Era, dopo il terzo Silenzio |

Il congedo accompagna l'ultimo tratto, prima del quarto Silenzio. Non predice
quale percorso chiudera' la campagna. L'Assenza conserva arena vuota, nero e
battito: nessun dialogo dopo la cessazione del Registro. Un profilo gia' avanti
riceve solo la scena pertinente, senza recuperare scene precedenti fuori tempo.

Tre sequenze di sei battute. Nerio osserva copie e margini; Rugo passa dal
richiamo alla presenza quieta; Dima lascia infine libero il posto che teneva.
Il Registro ha due inserti di stato, senza voce, intenzioni o consigli.
La tavola e i sigilli esistenti sono superfici di ingresso e attestazione del
terminale; la nuova forma non cambia rituali, offerte o autorita' delle fasi.

## Asset originali

Generati con lo strumento integrato image_gen, senza riferimenti esterni.
PNG opachi 1024x1536, nessun testo UI incorporato; stile pittorico, silhouette
aviane, basalto, bronzo, osso, cera rossa e vetro ambrato. Nessun umano.
Prompts completi, provenienza e hash sono conservati in
`assets/ui/generated/manifest.json`.

- `assets/ui/generated/dialogue_nerio.png`
- `assets/ui/generated/dialogue_rugo.png`
- `assets/ui/generated/dialogue_dima.png`
- `assets/ui/generated/dialogue_registry_terminal.png`

Consumer: `scripts/ui/opening_prologue.gd`, nodo storico OpeningPrologue.
Il vecchio prologo automatico a due didascalie viene sostituito.

## Lettura, input e persistenza

- Ritratto 400x600 a sinistra; testo 24 px a destra, nome 34 px, ruolo 18 px.
  Stage 1160x620 centrato nel viewport 16:9, senza scalare i font a 1080p.
- Nessuna scadenza delle battute, nessuna digitazione automatica. Anche il
  movimento ridotto conserva art, contenuto e lettura manuale.
- Invio o pulsante avanza; Esc o Salta dialogo completa la presa visione;
  Tab/frecce alternano i due controlli. Protezione ingresso 0,5 s e debounce
  tra battute 0,18 s. Input sottostante bloccato, anche mouse e rotella.
- Cambio lingua aggiorna la stessa battuta. Menu/uscita durante la lettura
  non segnano la scena come vista; Continua la riapre dalla prima battuta.
- Nuovo campo additivo `settings.campaign_dialogues_seen`: lista deduplicata
  degli id entry/middle/departure. Default vuoto, id ignoti scartati, profilo
  sempre v5. Il vecchio opening_prologue_seen=true vale come entry gia' vista.
- L'acknowledgment passa da GameEvents a RunManager, che accetta solo l'id
  attualmente eleggibile. Non introduce fasi o checkpoint intermedi.

## Verifica e consegna

Prove del candidato in `artifacts/illustrated_dialogues/`.
Il contratto `scripts/ci/illustrated_dialogue_contract.gd` verifica i tre
ingressi tramite menu, avanzamento mouse/tastiera, guardia input, completamento,
restart e Continue, traduzioni, geometria, Silenzio e Assenza. Matrice visuale:
18 battute x tre lingue x due risoluzioni, 108 catture. Il runner AV comprende
questo contratto con un profilo isolato; la campagna naturale verifica che le
tre scene appaiano una sola volta e siano attraversabili prima dell'Assenza.

Risultati sul candidato locale basato su
`7af8acd8c7f13264241bb8589b568186c11b3c13`, working tree modificato:

- 43 controlli statici verdi e 8 step runtime verdi: import,
  CP-02, audit, AV, campagna, FULL_RUN, CORE_CONTINUITY e KEYBOARD_FULL_RUN.
- Contratti AV, cast testuale e finestre illustrate verdi senza errori.
- Campagna naturale: scene ai percorsi 1, 100 e 165, una volta ciascuna;
  Assenza al percorso 178. Quattro checkpoint e reboot terminale verificati.
  Il test lungo conserva un avviso ObjectDB al cleanup, gia' presente nella
  prova precedente; nessun errore di contratto. I test dedicati sono puliti.
- 108 schermate generate; sei viste rappresentative ispezionate in IT/EN/ES
  e nelle due risoluzioni. Corpi, ritratti e controlli leggibili.
- Build Windows: sei avanzamenti iniziali con Invio e percorso completo
  da tastiera sull'EXE. Pack: 22 raster originali e 31 risorse audio validi.
- Docs refs, scansione mojibake del repository e diff whitespace puliti.

Build: `artifacts/exports/illustrated_dialogues_2026-09-12/Gallicus_Illustrated_Dialogues.exe`.
Launcher nella stessa cartella: `Start Playtest.cmd`, con profilo dedicato.
SHA256: `8e17b922c84a28292e77ae452d5f6f6e7e91cb9895befd0f46f52715ed04234b`.
Manifest export: hash sorgenti, asset, screenshot e log delle prove.
Prompts e path delle art: manifest degli asset sopra. Nessuna modifica
committata o pubblicata. Signoff Linux, accettazione umana e Steam restano aperti.

## File del pacchetto

- Catalogo: `scripts/content/campaign_dialogues.gd` e uid.
- Presentazione: `scripts/ui/opening_prologue.gd`, `scripts/ui/main_menu.gd`,
  `scripts/ui/run_manager_ui_port.gd`.
- Owner e save: `scripts/systems/run_manager.gd`, `scripts/systems/game_events.gd`,
  `scripts/systems/save_manager.gd`.
- Art: i quattro PNG sopra, sidecar import e manifest; traduzioni CSV e
  risorse `.translation` in `assets/i18n/`.
- Verifica: `scripts/ci/illustrated_dialogue_contract.gd` e uid,
  `scripts/ci/av_runtime_contract.gd`, `scripts/ci/campaign_runtime_contract.gd`,
  `scripts/ci/run_av_runtime_contract.py`.
- Owner documentali: lore, glossario, architettura, UI canon; content bible,
  cinematic direction, art direction, layout, data schema, asset pipeline,
  testing, signal contract, README, development plan e questo report.

La patch estende il cast gia' presente nel working tree, senza rimuovere le
modifiche del pacchetto `docs/support/arena_cast_2026-09-12.md`.
