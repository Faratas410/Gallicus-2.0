# Manifesto - Giudizio e sigillo

9 ottobre 2026. Pacchetto 3 del piano
`manifesto_remaining_screens_2026-10-09.md`, sul kit presente.
Baseline: main, HEAD `6f8088abb8227f4100416dd49ad7e14a606e0e85`, working tree
con i pacchetti precedenti non committati. Snapshot in
`artifacts/manifesto_judgment_2026-10-09/before/files/`.

## Risultato

Il giudizio usa un pannello trasparente `820x400`: verbale e titolo a
sinistra, prompt, sigillo e ausiliario a destra. Il testo lungo non sposta
il gesto. Il kit serve supporti inchiostro e tipografia 26/17/15/22 px;
il sigillo conserva texture native, basalto, bronzo, cera, incavi e
riempimenti dei tre colpi. Il comando ausiliario `300x60` resta sopra
la fascia della Pressione e mantiene scala uno in hover e focus.

La baseline mostra il sigillo spostato dai testi e l'ausiliario sotto il
footer nei risultati lunghi. Le catture prima conservano questi errori.
La verifica di Invio ha inoltre trovato che il comando rapido del sigillo
intercettava la tastiera sul Button ausiliario. Il controllo del focus ora
riconosce entrambi i Button prima del fallback: ALZA LA MANO invia resolve,
MOSTRA UN SEGNO invia show_scar. Lock e richieste sono quelli precedenti.

RunManager conserva risultati, probabilita', costi, Segni, catena, bando,
flow e save. GameEvents resta il bus. Nessun cambio ad audio, traduzioni,
asset raster o dati. Nessuna nuova connessione runtime al bus.

## Componenti e file

`ManifestoKit.apply_judgment(panel)` e' idempotente. Sul sigillo cambia
soltanto il font; non applica la superficie generica delle azioni.
Il campionario ha una quarta sezione, ricavata dal pannello reale.
La sorgente UI resta fuori dalla SceneTree, senza ready o binding; i
riempimenti degli incavi usano i suoi helper visivi. Click e Invio
incrementano soltanto il contatore della galleria.

Runtime:

- `scenes/UI.tscn`: due colonne fisse, prompt con wrapping, CTA native.
- `scripts/ui/ui_root.gd`: consumer del kit, focus dei due Button e ausiliario senza scala.
- `scripts/ui/manifesto_kit.gd`: adapter di supporto e tipografia.

Campionario e verifiche:

- `tools/manifesto_kit_gallery.gd`.
- `tools/manifesto_kit_capture.gd`.
- `tools/counter_layout_capture.gd`.
- `scripts/ci/test_judgment_seal_object_contract.py`: proprieta' degli input e texture native.
- `scripts/ci/test_pact_tablet_object_contract.py`: riconosce il Patto anche nell'elenco esteso dei target fissi.

Owner: `docs/README.md`, `docs/development_plan.md`, `docs/art_direction.md`,
`docs/layout_rules.md`, `docs/testing.md`, `docs/canon/UI_CANON.md`,
`docs/support/ui_kit_2026-10-09.md` e questo report.
Manifest del candidato e hash di preservazione:
`artifacts/manifesto_judgment_2026-10-09/candidate_manifest.json`.

## Evidenze locali

Godot 4.6.2, Compatibility, audio Dummy, finestre nascoste fuori schermo.
Profili APPDATA/LOCALAPPDATA/TEMP/TMP separati per le catture. Le prove
riguardano IT; EN/ES conservano i contratti statici del prodotto.

- Prima: 52 viste, testi e payload della stessa matrice, 56 failure; errori di overflow,
  spostamento e input registrati, non convertiti in PASS.
- Dopo: 52 viste in `after/render_final/`, 720p/1080p, motion normale/ridotto,
  zero failure. Normal/focus/hover/pressed, lock e recovery, colpi 1/2/3,
  arresto, cera incrinata, Segno offerto/mostrato. Invio e ripetizione
  producono un solo intento; recovery conserva la cera gia' riempita.
  Risposte sintetiche, nessuna prova di probabilita' o economia.
- Galleria finale in `after/gallery_final/`: 23 viste, sei stati del sigillo nelle due risoluzioni,
  idempotenza, preservazione delle texture, incavi passivi, click/Invio
  e nessuna attivazione da disabled. Zero failure.
- Import isolato: PASS. Playbook statico finale: 45/45 PASS, summary ok true.
- KEYBOARD_FULL_RUN e ROUTE_CASHOUT: PASS diagnostico Windows.
- Sei viste del percorso reale via Invio: firma -> Patto -> tre scambi ->
  giudizio -> posta, zero failure. La matrice sintetica e il percorso
  reale sono esplicitamente distinti.
- Continuita': 46 viste della fixture integrata, zero failure; ispezione
  delle viste del giudizio e delle fasi adiacenti oltre alla geometria.
- Riferimenti docs, mojibake repository e whitespace del diff: verificati
  nella chiusura del candidato.

Il primo import e' stato avviato senza profilazione APPDATA e ha fallito
per i permessi dell'editor; ripetuto nel profilo isolato, PASS senza errori
risorse/script. Il primo playbook ha trovato un guard del Patto troppo
letterale sull'elenco dei Button senza scala; corretto nello stesso pacchetto.
Il primo dopo visuale aveva geometria pulita ma otto errori di input
sull'ausiliario; corretti con il controllo del focus e ripetuta la matrice.
I tentativi precedenti restano conservati, distinti dalle evidenze finali.

## Teardown headless

Gli smoke standard sono validati dal runner, ma KEYBOARD_FULL_RUN riporta
ObjectDB e tre risorse in uso al termine; ROUTE_CASHOUT riporta ObjectDB.
La diagnosi separata con verbose identifica AudioStreamWAV/Playback dei cue
`registry_condemnation_mark.wav` e `registry_dossier_route.wav`, senza
risorse UI elencate. Il validator verbose fallisce per la diversa riga
ERROR: non e' un ulteriore PASS. L'audio non e' cambiato in questo pacchetto.
Le catture renderer finali, che fermano audio e attendono il teardown,
non riportano errori o warning. Il gate Linux resta aperto.

## Limiti e prossimo passo

Prove Windows diagnostiche; canonical Linux e revisione umana di leggibilita',
ritmo e continuita' restano aperti. Le PNG non sono sessioni umane e non
costituiscono accettazione creativa. Nessun commit, branch, push o export.
Prossimo pacchetto: Fascicolo, HUD e dettaglio Segni.

La vista reale di posta mostra ancora il titolo lungo vicino al numero
della Gloria: composizione preesistente, da considerare nel prossimo
pacchetto di Fascicolo/HUD. Le prove di geometria non chiudono questa
valutazione visiva.
