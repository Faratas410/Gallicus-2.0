# Insegne dell'arena - fascia GDR in game

## Mandato e candidato

L'utente approva con "Top cosi'" la singola proposta GDR mostrata dopo la
compattazione del Registro. Questa consegna porta la fascia nel runtime,
usando lo stesso stemma, bronzo, ferro, cuoio e pergamena. Candidato locale
`main`, HEAD `b81a4fc`, working tree gia' modificato; nessun commit o push.

Intento: leggere stato e rischio, consultare i Segni. Oggetti: insegne e
tessera; gesto: leggere o aprire il dettaglio. Feedback: valori aggiornati,
incavi della Pressione riempiti, regola di focus sulla tessera. Registrazione:
nessuna nuova, la consultazione mostra dati gia' prodotti dalla run.

## Implementazione

Pelle ImageGen senza lettere/numeri, alpha e filtro nearest. Text Label
localizzati e Button Segni sono nativi. Pressione riempie dieci incavi;
Denari conserva anche il segno negativo. L'header legge i consumer UI e il
port esistenti, non calcola esiti. Conteggio Segni passato come metadata
numerico della vista, non estratto dal testo. Tessera vuota disabilitata;
con Segni apre il dettaglio e recupera il focus dopo la chiusura.

Registro ed eco della firma condividono inset 128 px. Incasso/Rilancio
sposta titolo/importo/voce sotto la fascia e nasconde il titolo ambientale
duplicato durante la propria vista. Contratti del libro, font, input e
autorita' RunManager restano quelli del pacchetto precedente.

## File di questa consegna

- `scripts/ui/ritual_status_header.gd`;
- `scripts/ui/ui_root.gd` (metadata del conteggio Segni);
- `scripts/ui/betting_circle_ui.gd`, `scripts/ui/registry_signature_overlay.gd`
  (inset condiviso);
- `scripts/ui/manifesto_verdict.gd` (spazio della fascia);
- `assets/ui/generated/ritual_hud_insegne.png` e `.import`, `manifest.json`;
- `assets/i18n/it.csv`, `en.csv`, `es.csv` e relative `.translation`;
- `tools/hud_insegne_capture.gd` e `.uid`;
- `docs/README.md`, `docs/art_direction.md`, `docs/layout_rules.md`,
  `docs/asset_pipeline.md`, `docs/content_bible.md`, `docs/testing.md`,
  `docs/development_plan.md`, `docs/canon/UI_CANON.md` e questo report.

## Verifiche

Prove e screenshot in `artifacts/hud_insegne/`; import/editor e renderer
reale Godot 4.6.2 su Windows, profilo APPDATA/LOCALAPPDATA isolato. La
reference approvata e' in `docs/support/ui_reference_2026-10-25/`.
Confronto con il runtime: stessa disposizione degli oggetti e materiali;
tipografia nativa per le traduzioni e nota del Favore compatta. Il libro
resta il componente runtime approvato, senza introdurre il mockup come UI.

Esiti finali sul candidato:

- Import 4.6.2 senza errori di parser/risorse; PNG originale verificato
  RGBA, hash nel manifest, regione runtime senza testo.
- HUD: **1.984 controlli, zero fallimenti**, IT/EN/ES a 720p/1080p.
  Risolti prima della consegna i minimi dei Label rimasti dalla risoluzione
  precedente e la nota del Favore troppo lunga. Valori negativi e a cinque
  cifre restano completi; focus, Enter e ritorno Segni non firmano un patto.
- Registro con nuovo inset: **760 controlli, zero fallimenti**, comprese
  tutte le offerte attive e condizioni avverse, nessuno scroll/clipping.
- Art uniformity: **241 controlli, zero fallimenti**, movimento ridotto e
  continuita' della fascia fra fasi.
- **KEYBOARD_FULL_RUN OK**, attraverso gli intenti reali e fino al menu.
  Runner con binario assoluto e TEMP nel workspace dopo un errore iniziale
  di cleanup nella directory temporanea della sandbox.
- OF-05, OF-06, i18n, riferimenti documentali, mojibake e diff check.
- Ispezione catture reali: Registro IT 720p, ES 1080p, Pressione 10 e
  conto negativo ES 720p, dettaglio Segni EN, posta e Rito IT 720p.
  Nessun incavo sconfinato, sovrapposizione dei titoli o parola tagliata
  nelle viste controllate. Runtime e reference mantengono gli stessi
  oggetti/materiali, con scritte native leggibili invece di dati raster.

Log: `visual.log`, `registry.log`, `art_uniformity.log`, `keyboard.log`,
`keyboard.json` e `ritual.log` sotto `artifacts/hud_insegne/`; report delle
760 verifiche in `artifacts/registry_volume/report.json`. Rimane il noto
warning ObjectDB al teardown del fixture Registro, non risolto da questa
patch; nessun errore runtime nei log finali.

Linux canonico, controller fisico, audio e accettazione visiva del candidato
restano distinti dalle prove locali. Nessun gate Steam chiuso.
