# Manifesto - Patto e Gradinata

9 ottobre 2026. Pacchetto 2 dell'ordine in
`manifesto_remaining_screens_2026-10-09.md`, sul kit gia' presente.
Baseline: main, HEAD `6f8088abb8227f4100416dd49ad7e14a606e0e85`, con kit e
pacchetto Registro preesistenti e non committati. Snapshot iniziale in
`artifacts/manifesto_pact_crowd_2026-10-09/before/files/`.

## Risultato e grammatica

- Patto: tavoletta avorio `660x390`, titolo 38 px, voci 17 px e un solo
  gesto inchiostro `320x88`. Il Button originale conserva CTA localizzata,
  focus, primo percorso, cue, intent e watchdog. Validated riempie i tagli;
  disabled conserva barre distinte. Hover/focus non scalano il target.
- Gradinata: pannello trasparente `764x444`, voci in alto, spazio elastico
  per l'arena, intenzione separata e due risposte al margine basso. Minimo
  `350x180`, distanza 16 px, titolo 22 px e prezzo/corpo 17 px allineati.
  Misura su carta; esposizione su cera. Selected mantiene impronta vuota
  e regola superiore, senza diventare registered.
- I prezzi e le conseguenze provengono dai payload esistenti. Il testo
  semantico del Button conserva verbo, prezzo e frase del Registro; title
  e consequence aggiunti ignorano mouse e focus. Tooltip e disponibilita'
  restano nativi. La traduzione ricompone il prezzo senza cancellare selected.

RunManager conserva scambi, attese, favore, Pressione, Segni, flow e save.
GameEvents conserva gli intenti. Nessuna modifica ad audio, traduzioni,
asset raster, manager o bus. Il Patto rimane sul banco; le risposte rimangono
nell'arena illustrata. La gerarchia del giudizio e del HUD e' ancora quella
precedente: appartiene ai pacchetti successivi.

## API condivise e campionario

`ManifestoKit.apply_response(button, material, selected)` adatta il Button
esistente; `layout_response(button)` allinea il corpo sotto il verbo e si
collega una sola volta a resized. Reapplicare il componente aggiorna gli
stessi due Label, senza duplicare nodi o connessioni. Il kit non imposta
disabled/visible e non emette richieste. I documenti in inchiostro estendono
la campitura nel padding, senza regole sovrapposte al testo; i documenti
avorio conservano le regole del Registro.

La sezione Patto/Gradinata in `tools/manifesto_kit_gallery.tscn` usa gli stessi
adattatori. Mostra validated e disabled del Patto; il selettore distingue
normal, selected misura/sfida e disabled delle risposte. Click e Invio
incrementano soltanto il contatore locale del campionario.

## File del pacchetto

Runtime:

- `scenes/UI.tscn`: spazi, dimensioni e rimozione dei vecchi binding oggetto.
- `scripts/ui/ui_root.gd`: adapter sui consumer e metadati esistenti;
  nessuna nuova connessione al bus o transizione.
- `scripts/ui/manifesto_kit.gd`: risposta composta e layout idempotente.
- `scripts/ui/manifesto_document_surface.gd`: campitura inchiostro leggibile.

Verifica e campionario:

- `scripts/ci/test_pact_tablet_object_contract.py`.
- `scripts/ci/test_arena_gesture_object_contract.py`.
- `scripts/ci/test_object_first_stage_contract.py`: consolidamento dei
  consumer Manifesto, con contratti di intenti e accessibilita' conservati.
- `tools/counter_layout_capture.gd`.
- `tools/manifesto_kit_gallery.gd`.
- `tools/manifesto_kit_capture.gd`.

Owner aggiornati: `docs/README.md`, `docs/development_plan.md`,
`docs/art_direction.md`, `docs/layout_rules.md`, `docs/testing.md`,
`docs/canon/UI_CANON.md`, `docs/support/ui_kit_2026-10-09.md` e questo report.
Il manifest del candidato include solo file con contenuto cambiato rispetto
allo snapshot, con hash delle altre modifiche locali preservate.

## Verifiche locali

Evidenze: `artifacts/manifesto_pact_crowd_2026-10-09/`.
Godot 4.6.2, renderer Compatibility, audio Dummy, finestre fuori schermo e
profili APPDATA/LOCALAPPDATA/TEMP separati. Nessuna impostazione personale
usata per le prove. Il campionario e il gioco restano apribili normalmente.

- Import: PASS. Playbook statico: 45/45 PASS. KEYBOARD_FULL_RUN e
  ROUTE_CASHOUT: PASS diagnostico, con i limiti di teardown sotto.
- Matrice IT a 1280x720 e 1920x1080, motion normale e ridotto: 64 viste
  prima/dopo, stessi testi, prezzi reali dal catalogo; focus/hover/pressed,
  validated/selected/disabled, recovery, tre scambi, favore -4/0/+4 ed
  effetti lunghi. La baseline e' un clone isolato del candidato iniziale.
- Sei ulteriori viste del percorso via Invio: firma -> Patto -> tre
  scambi -> giudizio -> posta. Lo scenario colloca l'arena speciale nella
  prima arena sullo stato usa e getta; transizioni, conseguenze e reset dei
  lock attraversano il manager reale. Non e' una campagna umana.
  Ripetizione isolata con `--pact-crowd-flow-only` in `after/flow/`, lasciando
  stabilizzare anche l'ingresso sulla posta dopo il cambio di fase. La
  fixture attende il risultato del sigillo e invia Invio solo al Button
  visibile, disponibile e realmente in focus; il primo tentativo isolato
  aveva assunto erroneamente la presenza fissa di ALZA LA MANO.
- Undici viste del campionario: geometria, idempotenza, selected distinto
  da registered, click/Invio singolo e nessun intent dai controlli bloccati.
- Continuita': 46 viste della fixture integrata di Registro, giudizio, posta,
  fascicolo e ripristino HUD. Ispezione delle viste significative, oltre
  alle verifiche automatiche; PNG prodotti non equivalgono a sessioni giocate.
- Riferimenti docs, mojibake e diff whitespace.

La prima esecuzione statica ha incontrato un TEMP del sandbox non scrivibile:
la ripetizione usa TEMP/TMP sotto artifacts. Il primo avvio del clone era
privo della cache delle classi globali; completata prima del confronto.
I renderer sono eseguiti in sequenza per evitare la sospensione delle
catture fuori schermo quando un'altra finestra Godot prende il focus.

## Limiti e prossimo passo

Queste prove Windows sono diagnostiche. EN/ES conservano i contratti statici
del prodotto; la revisione visuale di questo pass rimane IT. Accettazione
umana della composizione e checkpoint Linux sul candidato committato
restano aperti. Nessun gate release o Steam e' chiuso.

KEYBOARD_FULL_RUN riporta ObjectDB e tre risorse ancora in uso all'uscita;
ROUTE_CASHOUT riporta ObjectDB. Il diagnostico verbose non e' un ulteriore
PASS del validator: mostra due AudioStreamWAV e relativi playback trattenuti,
`registry_condemnation_mark.wav` e `registry_dossier_route.wav`, dopo il
ritorno al menu. Il conteggio dipende dal momento del quit; nessuna risorsa
UI e' elencata. Il runner conserva la propria classificazione diagnostica.
I log renderer della matrice, della sequenza e del campionario sono puliti,
controllati separatamente; il PASS headless non elimina i suoi warning.

Prossimo pacchetto: Giudizio e sigillo. Modifiche lasciate sul working tree
locale di main; revisione, commit e push spettano all'utente.
