# Coerenza delle schermate rispetto al Registro approvato

Seguito dell'inventario: Patto, Gradinata e Rito sono stati implementati nel
[primo pacchetto pixel art](pixel_rituals_2026-10-26.md). Le osservazioni e
le immagini sotto conservano la situazione prima del pass, non lo stato
successivo delle tre schermate. Il [secondo pacchetto](pixel_banco_verdict_2026-10-26.md)
porta anche Banco e Incasso/Rilancio nella stessa famiglia. Restano aperti
gli altri otto elementi; la tabella sotto documenta lo stato iniziale.

## Esito

Il Registro aperto e la fascia Insegne dell'arena sono il riferimento corrente.
Le altre schermate non sono ancora uniformate a questa direzione: restano
13 viste o famiglie con scarti visibili, di intensita diversa. Il Banco e
Incasso/Rilancio sono parzialmente allineati; Patto, Gradinata e Rito sono
il primo blocco da rivedere. Non basta sostituire i font: cambiano resa degli
ambienti, materiali, personaggi e rapporto fra azione e oggetto.

La richiesta dell'utente e uniformare tutte le schermate e mostrare quelle
incoerenti. Questa consegna rende visibile l'inventario e l'ordine di lavoro;
non implementa ancora il redesign. Nessun gate produttivo cambia.

## Candidato ed evidenze

- Data: 26 ottobre 2026.
- Branch: main; HEAD b81a4fc00797be0b0f0b7dd68639e309f3db061c con modifiche locali.
- Godot 4.6.2, renderer gl_compatibility, audio Dummy; italiano, 1280 x 720.
- Catture nuove da scene native del candidato locale, con fixture di
  presentazione e profili APPDATA/LOCALAPPDATA isolati negli artefatti.
- 56 PNG acquisiti; 16 viste rappresentative ispezionate e incluse nella
  [galleria locale](../../artifacts/ui_coherence_2026-10-26/index.html).
- Candidato e stato iniziale: `artifacts/ui_coherence_2026-10-26/candidate.json`
  e `status-before.txt`; dimensioni e SHA-256 in `screenshots.json`.
- Script e log riproducibili nella stessa cartella: counter_capture.gd,
  utility_capture.gd, deep_capture.gd e rispettivi log. Copie isolate dei
  capture tool esistenti; nessuna modifica ai tool runtime tracciati.
- Counter: 23 catture, uscita 0. Utility: 11 catture, zero fallimenti,
  uscita 0. Deep: 22 catture, uscita 0.

Gli artefatti sono locali e ignorati da Git. Le catture documentano la resa
effettiva; i suggerimenti sotto non sono mockup approvati. Non si tratta di
un playtest completo della campagna, di un controllo delle animazioni o di
una certificazione di accessibilita, controller, EN/ES o Linux.

## Inventario e direzione

I percorsi immagine sono relativi ad `artifacts/ui_coherence_2026-10-26/`.

| Ordine | Schermata | Scarto osservato | Direzione del raccordo | Evidenza |
| --- | --- | --- | --- | --- |
| Base | Registro aperto + HUD | Coerente con la scelta corrente | Conservare libro volumetrico, scrittura, folla e materiali | counter/signature_it_1280x720.png |
| 1 | Patto sigillato | Pannello piatto chiaro e CTA scura su ambiente realistico, sotto HUD pixel art | Documento fisico nella stessa arena del libro | counter/pact_it_1280x720.png |
| 1 | Gradinata | Blocchi neri e due schede rettangolari; folla non visibile nella vista | Pubblico e gesto al centro; conseguenze su supporti leggibili | counter/gesture_it_1280x720.png |
| 1 | Rito di giudizio | Blocco nero dominante, pulsante metallico rettangolare, vecchia arena | Sigillo e gesto volumetrici, stessa pixel art e materiali del Registro | counter/judgment_it_1280x720.png |
| 2 | Banco / Registro chiuso | Libro e scena coerenti, ma bando nero e tre schede acquisto piatte | Intervenire sul lato del banco, con oggetti e cartigli | counter/banco_20_it_1280x720.png |
| 2 | Incasso / Rilancio | Oggetti gia riconoscibili, ma Vessa, arena e materiali realistici | Conservare quietanza e sigillo, uniformarne la resa | counter/receipt_it_1280x720.png |
| 2 | Dettaglio Segni | Modal nero, pannello chiaro, scrollbar e simbolo generico | Pagina del taccuino Segni, simboli dedicati e testi ordinati | counter/scars_detail_it_1280x720.png |
| 2 | Fascicolo / fine percorso | Grande foglio piatto e impaginazione da report | Fascicolo fisico, gerarchia compatta, esiti completi | counter/dossier_CASHOUT_it_1280x720.png |
| 3 | Menu principale | Portico realistico, logo e comandi di famiglie diverse | Ingresso coerente con pixel art, materiali e insegne del gioco | utility/01_menu_it_1280x720.png |
| 3 | Dialoghi | Ritratto dipinto accanto a grande pannello nero | Cast coerente e supporto per il dialogo leggibile; mantenere Ascolta/Salta | utility/09_dialogue_it_1280x720.png |
| 3 | Archivio | Lista e schede in pannello nero da applicazione | Fascicoli, indici e pagine; preservare consultazione e stati bloccati | utility/06_archive_it_1280x720.png |
| 3 | Museo | Lista con ritratti realistici e superfici piatte | Album con cast coerente e biografie leggibili | utility/08_museum_it_1280x720.png |
| 4 | Opzioni | Dropdown, checkbox, slider e pannello di aspetto generico | Materiali e tipografia comuni, controlli convenzionali e accessibili | utility/02_settings_it_1280x720.png |
| 4 | Crediti | Grande rettangolo nero e comando standard sul portico | Cartiglio sobrio della stessa famiglia visiva | utility/05_credits_it_1280x720.png |

Le priorita sono di coerenza artistica e frequenza nel percorso, non classi
di gravita funzionale. Gli esempi rappresentativi non provano che ogni
variante di esito o ogni ritratto abbia gia ricevuto una revisione individuale.

## Eccezioni da preservare

- Congedo: uniformare la resa del portico, mantenendo la sottrazione di UI.
  Evidenza: `deep/departure.png`.
- Assenza del Registro: mantenere il vuoto, senza aggiungere libro o HUD.
  Raccordare soltanto i comandi finali. Evidenza: `deep/absence.png`.

Uniformare significa condividere linguaggio e materiali, non trasformare
ogni fase nella stessa pagina del libro. Fondamento serve alla scrittura sui
documenti; etichette, numeri e impostazioni devono restare immediati da leggere.
La rimozione dello scroll dal Registro non autorizza a tagliare testi lunghi
in Archivio o Segni: valutare paginazione o navigazione appropriata.

## Prossimo pacchetto

Patto, Gradinata e Rito sono il primo gruppo coerente da ridisegnare,
usando il Registro e l'HUD gia approvati come campione. Segue il raccordo
del Banco e di Incasso/Rilancio, poi superfici di consultazione e ingresso.
Per il runtime restano obbligatori object grammar, ownership di RunManager,
testi nativi IT/EN/ES e verifica di focus, termini completi e movimento ridotto.
Questo inventario non cambia meccaniche, canon o release criteria.

## Verifica della consegna

- Catture native e ispezione delle 16 viste nella galleria.
- Link locali della galleria risolti; dimensioni e hash dei 56 PNG registrati.
- Validazione riferimenti documentali, scansione mojibake e diff check.
- Runtime, dati, asset e traduzioni non modificati in questa consegna.
