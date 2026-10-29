# Registro volumetrico in game - 26 ottobre 2026

## Mandato e candidato

L'utente autorizza in game il Registro pixel art frontale con volume,
apertura corretta sul bordo sinistro e firma a inchiostro. Candidato locale
su `main`, HEAD `b81a4fc`, con working tree gia' ampiamente modificato.
Nessun commit, push, export o pubblicazione in questa consegna.

## Scheda object-first

- Intento: leggere una promessa e sottoscriverla.
- Oggetto/materiale: libro, carta chiara, copertina in cuoio, stilo di bronzo.
- Gesto: APRI IL REGISTRO, consulta una pagina, FIRMA.
- Prima del gesto: contratto reale completo, conseguenze e costo; focus e
  selezione mostrano una regola, mai una firma anticipata.
- Dopo: l'accettazione di RunManager avvia il breve tratto a inchiostro.
- Audio: cue esistenti `registry_table_open` e `registry_promise_sign`.
- Owner: RunManager conserva offerta, validazione, fase, salvataggio e Patto.
- Bus: `request_place_bet(bet_id, 0)` immediato; `bet_placed` per feedback.
- Accessibilita': target Button nativi fermi, focus, scroll dei contratti,
  traduzioni IT/EN/ES e Movimento ridotto.

## Comportamento

Il libro e' un layer trasparente proiettato a strisce, sopra un'arena fissa.
Il bordo rotante usa soltanto cuoio entro la sagoma: nessun campione della
pagina viene stirato in un lembo pendente. Testo nativo rivelato a libro
aperto; i contratti lunghi scorrono, la firma resta esterna allo scroll.
Gli originali RichTextLabel e Button mantengono nomi, dati e callback.
Il banco e il bando restano disponibili accanto alla copertina chiusa.

Durate runtime: apertura 1,25 s; stilo/firma 0,65 s dopo accettazione.
La reference di 12 s includeva pause dimostrative. La UI non aggiunge una
nuova attesa al flow: l'intento e il salvataggio esistenti restano immediati.
L'eco visiva passa sopra la schermata successiva per meno dei 0,7 s del
rito gia' esistente. Una conferma successiva la salta e raggiunge il Patto
nello stesso frame. Menu, nuova run, fine run e chiusura del Patto la cancellano.
Con Movimento ridotto il libro e' subito aperto e la traccia completa resta
per 0,15 s senza rotazione o stilo in movimento.

Gli asset sono edit delle reference approvate tramite ImageGen integrato,
senza testo incorporato; prompt esatti, sorgenti, hash e dimensioni sono in
`assets/ui/generated/manifest.json`. PNG copiati senza manipolazioni raster;
alpha nativo, import lossless, nearest e nessun mipmap.

## File del pacchetto

- Runtime modificato: `scripts/ui/betting_circle_ui.gd`, `scripts/ui/ui_root.gd`.
- Runtime aggiunto: `scripts/ui/registry_volume.gd`,
  `scripts/ui/registry_ink_action.gd`, `scripts/ui/registry_signature_overlay.gd`
  e relativi `.uid`.
- Asset aggiunti: `assets/ui/generated/registry_volume_book.png`,
  `registry_volume_arena.png`, `registry_volume_sprites.png` e relativi `.import`.
  Aggiornato `assets/ui/generated/manifest.json`.
- Prove: `tools/registry_volume_capture.gd` e `.uid`;
  aggiornati `scripts/ci/test_registry_table_object_contract.py` e
  `scripts/ci/test_promise_signature_object_contract.py`.
- Documenti: `docs/README.md`, `docs/art_direction.md`,
  `docs/development_plan.md`, `docs/layout_rules.md`, `docs/object_grammar.md`,
  `docs/asset_pipeline.md`, `docs/testing.md`, `docs/canon/UI_CANON.md`
  e questo report.

Le altre modifiche gia' presenti, incluse quelle di RunManager, scene e
cataloghi, non appartengono a questo pacchetto. Rito, Incasso/Rilancio e
proposta del Patto non sono stati migrati automaticamente.

## Verifica locale

Godot ufficiale 4.6.2, Windows, renderer Compatibility/OpenGL su NVIDIA.
APPDATA e LOCALAPPDATA isolati sotto `artifacts/registry_volume/`; salvataggio
personale non usato. Le cartelle artifacts sono prove locali non esportate.

- Import completo senza errori di parser/risorse dopo isolamento delle
  directory editor e cache; log `artifacts/registry_volume_import.log`.
- Fixture reale Main -> Nuova partita -> dismiss del dialogo -> Registro:
  **154 verifiche, zero fallimenti**. IT/EN/ES a 1280x720 e 1920x1080,
  geometria banco e firme, blocco input durante apertura, selezione con
  freccia destra, scroll con PageDown, reset offerte a meta' apertura,
  close e Movimento ridotto, Enter fino all'accettazione reale del manager.
- PNG prodotte per libro chiuso, rotazione, libro aperto e focus destro in
  tutte le combinazioni; firma e Patto accettato. Ispezionate apertura IT,
  libro aperto IT/EN a 720p, ES a 1080p, banco ES a 720p e firma finale.
  Evidenze: `artifacts/registry_volume/`, inclusa `report.json`.
- Smoke **KEYBOARD_FULL_RUN OK**, ritorno al menu; log e summary in
  `artifacts/registry_volume_keyboard.log` e `.json`.
- Contratti statici OF-05, OF-06 e UI motion; manifest controllato contro
  hash/dimensioni/alpha degli asset; docs refs, mojibake e diff check.

Rimane il warning ObjectDB al teardown della fixture; nessun errore runtime
nelle prove finali. Il warning e' gia' incluso nell'allowlist del runner
smoke del progetto e non viene presentato come risolto da questa patch.
Linux resta il signoff automatico canonico. Controller fisico, ritmo, audio
e approvazione visiva del candidato richiedono prova umana. Nessun gate
Steam o di release e' chiuso dalla sola integrazione locale.

## Seguito: scrittura integrata nella carta

Richiesta: il testo sembrava appoggiato sopra al libro. Adottato Fondamento
Regular per corpo/titoli e Italic per la premessa; passaggio delle rubriche
e dei titoli in scrittura normale, colore seppia e grana fissa molto lieve.
Nessuna deformazione delle lettere. Rimossi gli spazi vuoti fra sezioni che,
con il nuovo carattere, anticipavano troppo lo scroll a 720p. Stessa resa
nella copia della pagina durante il gesto della firma.

File di questo seguito: `scripts/ui/registry_handwriting.gd` e `.uid`,
`scripts/ui/betting_circle_ui.gd`, `scripts/ui/registry_signature_overlay.gd`,
`assets/ui/official/registry_ink.gdshader` e `.uid`, cartella
`assets/ui/official/typography/fondamento/` (due TTF e import, OFL e provenance),
`export_presets.cfg` (inclusione licenza), `docs/art_direction.md`,
`docs/layout_rules.md`, `docs/asset_pipeline.md`, `docs/development_plan.md`,
`docs/canon/UI_CANON.md` e questo report. Nessun cambiamento al flow.

Provenienza: Google Fonts ufficiale, font originali sotto SIL OFL 1.1;
licenza conservata e inclusa nel preset. Verifica nativa `FontFile.has_char`:
nessun glifo mancante per alfabeto, accenti IT/ES, cifre e punteggiatura
richiesta. Import senza errori, fixture Registro rieseguita con renderer
reale su IT/EN/ES e 720p/1080p; 154 controlli superati. Restano il warning
ObjectDB gia' documentato e l'accettazione visiva umana. Evidenze dedicate
in `artifacts/registry_handwriting/`; screenshot della fixture in
`artifacts/registry_volume/`. Controllati anche OF-05/06, docs refs e mojibake.

## Seguito: pagina senza scroll e proposta HUD GDR

Richiesta: eliminare la barra del libro, compattare i testi e proporre una
fascia superiore meno simile a debug. Il libro e' modificato nel runtime;
la fascia e' solo una proposta visiva ImageGen. Candidato locale `main`,
HEAD `b81a4fc`, working tree gia' modificato: nessun commit o push.

Intento: confrontare le promesse sul libro; gesto e feedback della firma
restano quelli gia' autorizzati. Il testo conserva titolo, probabilita',
ricompensa, perdita, conseguenza meccanica completa e condizioni correnti.
Non ripete sottotitolo atmosferico o preambolo della condanna. Le note
"A favore" / "Contro" sono localizzate in IT/EN/ES. Corpo sempre 18 px,
lettura sull'85% superiore della pagina, firma separata e ferma. Niente
scroll, clipping, ellissi o riduzione automatica. La lettura non sottrae
focus alle firme. Nessuna modifica a payload, catalogo o autorita' di run.

File modificati in questo seguito:

- `scripts/ui/betting_circle_ui.gd`, `scripts/ui/registry_handwriting.gd`;
- `assets/i18n/it.csv`, `en.csv`, `es.csv` e relative risorse `.translation`;
- `tools/registry_volume_capture.gd`;
- `docs/layout_rules.md`, `docs/art_direction.md`, `docs/content_bible.md`,
  `docs/canon/UI_CANON.md`, `docs/testing.md`, `docs/development_plan.md`
  e questo report;
- nuova reference `docs/support/ui_reference_2026-10-25/hud-insegne-proposta-2026-10-26.png`
  e relativo `hud-insegne-prompt.txt` con prompt e screenshot sorgente.

La reference propone stemma Arena, Pressione a dieci tacche nel bronzo,
Catena in ferro, borsa Denari, Favore e tessera Segni; Bando su pergamena.
La scena generata illustra una direzione, non e' una cattura runtime e non
costituisce integrazione o approvazione della nuova fascia. Usa ImageGen
integrato, ancorato alla cattura reale del Registro del pass tipografico.

Verifiche locali: import Godot 4.6.2 senza errori; fixture con renderer
reale **760 controlli, zero fallimenti**. IT/EN/ES a 720p/1080p, tutte le
offerte attive con condizioni neutre, Favore +3/-3, Pressione 10 e Segni;
controllo di altezza, scrollbar assente e conseguenza completa presente.
La matrice usa anche un guadagno di due cifre. Apertura, focus da tastiera,
movimento ridotto, reset e firma reale continuano a passare. Catture IT e
pagina ES piu' lunga ispezionate. Prove in `artifacts/registry_compact/`,
matrice e altre PNG in `artifacts/registry_volume/`. Resta il noto warning
ObjectDB alla chiusura. Linux e accettazione umana non sono sostituiti dalle
prove locali; nessun gate di release cambia.
