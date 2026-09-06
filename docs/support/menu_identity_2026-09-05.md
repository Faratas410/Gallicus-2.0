# Identita del menu - 5 settembre 2026

Richiesta: mantenere il tema approvato, dare personalita' al titolo e rivedere
layout e frasi. Modifiche locali su main, senza commit, push o PR.

## Risultato

- Marchio GALLICUS originale ImageGen, trasparente, pietra chiara e bronzo.
  File `assets/ui/generated/gallicus_wordmark.png`, prompt integrale e fonte
  nel manifest della stessa cartella; tool integrato, nessun ritocco raster.
- Titolo 740x247, frase "L'arena dimentica. Il Registro no.", ingresso
  480x72, ripresa quando disponibile, Archivio/Opzioni/Crediti su una riga.
- Paragrafo Obiettivo e comando di caricamento sempre disabilitato rimossi
  dalla presentazione. Testi nuovi localizzati in IT/EN/ES.
- Controlli fermi durante il moto ambientale; il marchio conserva la lieve
  variazione di luce, disattivata con Movimento ridotto.

## Difetti della ripresa individuati durante la verifica

Il menu interrogava Engine.has_singleton per un autoload: il pulsante poteva
mostrare In arrivo invece di caricare. Il checkpoint perdeva inoltre gli
array scars e pacts_log nel passaggio attraverso RunState.to_dict. Corretti
entrambi; schema e autorita' restano quelli esistenti.
La gestione del rigetto ora completa la quarantena, torna al menu e mostra
la causa senza nasconderla o sovrascriverla con il messaggio di rientro.
I file incompleti continuano a essere rifiutati dal contratto del lettore.

## Prove locali

- Tutti superati: 42 statici, import rigoroso, due contratti runtime e otto
  scenari smoke (53 passi distinti). Log in `artifacts/menu_identity/full/`
  e `artifacts/menu_identity/routes/`.
- Regressione della ripresa attraverso il pulsante, ripristino dati e file
  scomparso; round-trip degli array non vuoti: audit_runtime_contract.
- 14 screenshot: IT/EN/ES a 1280x720 e 1920x1080, focus, Movimento ridotto,
  ripresa di un patto firmato e avviso per save mancante.
- EXE Windows x64 verificato con KEYBOARD_FULL_RUN in cartella vuota;
  pacchetto con 16 raster originali caricabili. Hash e prove in
  `artifacts/exports/menu_identity/delivery_manifest.json`. Restano le
  segnalazioni di risorse alla chiusura gia' tollerate dal validator.

Il checkpoint Linux e i playtest umani della campagna restano aperti.
Questa revisione non modifica gli esiti o la progressione della campagna.

## File modificati in questa revisione

- `assets/i18n/en.csv`
- `assets/i18n/en.en.translation`
- `assets/i18n/es.csv`
- `assets/i18n/es.es.translation`
- `assets/i18n/it.csv`
- `assets/i18n/it.it.translation`
- `assets/ui/generated/gallicus_wordmark.png`
- `assets/ui/generated/gallicus_wordmark.png.import`
- `assets/ui/generated/manifest.json`
- `docs/README.md`
- `docs/art_direction.md`
- `docs/asset_pipeline.md`
- `docs/canon/UI_CANON.md`
- `docs/content_bible.md`
- `docs/data_schema.md`
- `docs/layout_rules.md`
- `docs/support/menu_identity_2026-09-05.md`
- `docs/testing.md`
- `scenes/Main.tscn`
- `scripts/ci/audit_runtime_contract.gd`
- `scripts/ci/test_arena_threshold_object_contract.py`
- `scripts/systems/run/save_continue_boundary.gd`
- `scripts/systems/run_manager.gd`
- `scripts/ui/main_menu.gd`
