# Manifesto del Verdetto - catture e prima patch circoscritta

8 ottobre 2026. Richiesta: prendere le catture e progettare il lavoro.
Questa consegna prepara la patch; non modifica UI, asset o gameplay.
Mandato generale: `docs/support/astra_manifesto_handoff_2026-10-08.md`.

## Candidato osservato

Branch main, HEAD `da99a64c7d90341ac57f3ad0e4cad7444f6bfa02`, 133 voci
nello status iniziale. Lavoro locale precedente conservato. Evidenze in
`artifacts/manifesto_scope_2026-10-08/`: status iniziale, manifest con hash,
runner, copia della fixture mantenuta, log e galleria `index.html`.

Nuova esecuzione Godot 4.6.2 Compatibility su Windows, audio Dummy,
finestra minimizzata, APPDATA/LOCALAPPDATA/TEMP/TMP/XDG isolati.
126 PNG IT/EN/ES, 1280x720 e 1920x1080; exit 0, nessun errore rilevato,
nessun fallimento dei controlli geometrici esistenti. Durata 107.61 secondi.
Le cinque righe "forcing new run while flow is active" corrispondono
ai riavvii della fixture tra lingua/risoluzione; non sono una prova del flow.
Nessun errore di teardown nel log.

Sono fixture di presentazione con nodi reali e stati predisposti, non una
partita completa. La galleria ordina le superfici per lettura; non certifica
ordine e tempi delle transizioni. Nessun nuovo PASS di smoke, Linux o umano.

## Sequenza osservata

Ogni filename qui sotto e' relativo alla sottocartella `layout/` delle evidenze.
Le prime sei immagini sono IT a 720p e sono state tutte aperte e ispezionate.

| Passo | Cattura | Riscontro visivo | Destinazione |
| --- | --- | --- | --- |
| 1. Registro/firma | `signature_it_1280x720.png` | Condizioni e firma nello stesso campo; grande superficie oliva uniforme, gerarchia tipografica distante dal Manifesto | Pass successivo |
| 2. Patto | `pact_it_1280x720.png` | Un comando riconoscibile; tavoletta metallica e banco molto dettagliato mantengono il vecchio linguaggio | Pass successivo |
| 3. Giudizio | `judgment_it_1280x720.png` | Sigillo e comando centrali; oggetto fotografico sopra arena dipinta, gradiente scuro esteso | Pass successivo |
| 4. Gradinata | `gesture_it_1280x720.png` | Prezzo delle due risposte esplicito; grandi rettangoli scuri con testo centrato occupano il campo del gesto | Pass successivo |
| 5. Posta | `receipt_it_1280x720.png` | Numero, due scelte e apertura sull'arena funzionano; bordi ripetitivi, rosso acceso e descrizioni non allineate indeboliscono il tono severo | Prima patch |
| 6. Fascicolo | `dossier_CASHOUT_it_1280x720.png` | Risultato e prosecuzione distinguibili; carta molto materica e titoli precedenti interrompono la continuita'; impronta gia' presente | Solo raccordo colore impronta nella prima patch |

Altre otto immagini ispezionate: `blocked_it_1280x720.png`,
`double_focus_it_1280x720.png`, `receipt_registered_it_1280x720.png`,
`incision_registered_it_1280x720.png`, `pressure_large_stake_it_1280x720.png`,
`receipt_it_1920x1080.png`, `blocked_es_1280x720.png`,
`receipt_en_1920x1080.png`. Totale ispezionato: 14, distinto dai 126 prodotti.
Menu e Archivio non sono catturati in questa diagnosi circoscritta.

## Diagnosi della decisione sulla posta

- La composizione scelta esiste e va conservata. A 1080p aumenta il campo
  dell'arena mentre font e comandi mantengono dimensioni logiche fisse.
- Il rosso `a51c12` occupa due aree ampie; il tono e' ancora piu' acceso
  della cera spenta richiesta. Questa e' una valutazione artistica,
  non un errore funzionale.
- La dentellatura continua ha una cadenza regolare e un contorno nero spesso.
  Ridurne frequenza e ampiezza darebbe piu' peso alle campiture.
- La quietanza ha tre righe che arrivano vicino al bordo inferiore;
  il rilancio ha una riga centrata verticalmente. Manca una base comune
  per leggere e confrontare le conseguenze.
- Focus visibile come linea inferiore. Nei blocchi la causa e' leggibile,
  ma la disponibilita' si distingue graficamente con un piccolo trattino.
  Le impronte predisposte e riempite rimangono entrambe molto sottili:
  la conferma merita una differenza piu' netta senza spostare il target.
- In ES la didascalia della posta occupa tre righe e si avvicina al marchio
  laterale; mantenere un margine minimo esplicito tra testo e incisione.

Limite della fixture: nel caso a quattro cifre viene cambiato solo
`stake_glory` nel payload gia' costruito. Numero 1234, note e rail a 4 sono
quindi uno stato artificiale incoerente. Questo prova l'ingombro del numero,
non una divergenza del gioco. Anche lo stato registrato successivo eredita
quel payload. Correggere la preparazione dei dati prima del confronto dopo.

## Prima patch proposta: materia e stati della posta

Obiettivo: rendere piu' severa e leggibile la decisione gia' approvata,
fissando un campione da estendere in seguito. Nessuna nuova composizione.

1. Palette candidata: inchiostro `191917`, avorio `e7ddc5`, cera `792d26`.
   Sono valori iniziali da confrontare sul fondale reale a 720p, non colori
   gia' validati. Applicazione locale alla posta e al colore dell'impronta
   nel fascicolo, con un'unica fonte per evitare disallineamenti.
2. Margini incisi piu' asciutti: poche irregolarita' statiche, contorno meno
   spesso, centro delle superfici uniforme. Nessuna nuova texture o grana.
3. Stessa posizione e ingombro dei comandi; note allineate in alto nello
   spazio sotto i titoli, padding inferiore sufficiente per tre righe.
   Conservare display, assi reali del font, corpo e copy IT/EN/ES esistenti.
4. Stati: focus e hover riconoscibili senza scala; pressed breve variazione
   di superficie; disabled con causa e contrassegno visibile; registrato
   con tre incisioni piene chiaramente diverse dal predisposto. Nessuno
   stato registrato anticipato rispetto alla conferma autorevole esistente.
5. Correggere la fixture grande posta ricostruendo il payload dallo stato
   predisposto e aggiornando gli HUD tramite i consumer esistenti; azzerare
   lo scenario prima delle catture registrate. Aggiungere pressed, hover,
   verifica dei margini delle note e del ripristino HUD all'uscita.

Scheda object-first: incassare -> quietanza -> prendere -> conferma esistente
-> memoria nel fascicolo; rilanciare -> seconda incisione -> incidere
-> conferma esistente -> continuita' registrata; ricevere il marchio resta
la terza azione quando prevista. L'intera superficie resta cliccabile.

File runtime previsti: `scripts/ui/manifesto_verdict.gd` e
`scripts/ui/registry_imprint.gd`; eventuale piccola risorsa palette condivisa.
Fixture: `tools/counter_layout_capture.gd`. Nessuna necessita' attuale di
toccare RunManager, GameEvents, save, testi, font o fondali. `ui_root.gd`
e `UI.tscn` solo se l'ispezione degli stati dimostra un collegamento mancante.

Owner da aggiornare con l'implementazione: art direction, layout e UI_CANON
per gli stati effettivamente cambiati; direction per raccordare colore e
collocazione HUD gia' superati; roadmap e report del candidato.

Fuori da questa patch: restyling di firma, patto, giudizio, Gradinata,
fascicolo completo, menu e Archivio; nuovi ambienti, cast, audio e narrativa.
Le sei catture restano il confronto per i successivi pacchetti di coerenza.

## Chiusura richiesta alla futura implementazione

- Prima/dopo sullo stesso stato coerente, lingua e risoluzione; confronto
  con la reference approvata conservata nelle evidenze del primo Manifesto.
- IT/EN/ES a 720p/1080p, due e tre azioni, pressione 0/9, posta 4/1234,
  testi lunghi, focus/hover/pressed/disabled/registrato e dettaglio Segni.
- Ispezione delle immagini, target sotto le note, input tastiera, contrasto
  dei colori finali, motion normale/ridotto e ripristino HUD dopo l'uscita.
- Import, playbook statico completo, KEYBOARD_FULL_RUN e route cashout,
  double e condanna; log/teardown, riferimenti docs, mojibake e diff.
- Revisione umana del tono e della leggibilita' separata dai PASS automatici.

La presente consegna contiene soltanto diagnosi, prove e progetto della patch.
Core Playable Candidate e tutti i gate successivi rimangono invariati.
