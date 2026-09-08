# Coerenza UI, audio e prologo - 8 settembre 2026

Pacchetto autorizzato dall'utente dopo `docs/support/screen_audit_2026-09-08.md`.
Candidato locale su main, base 303039c, working tree modificato; nessun commit,
push o pubblicazione. Evidenze in `artifacts/consistency_fix_2026-09-08/`.

## Cambiamenti

- Silenzio: bottone visibile dentro viewport, focus e ritorno funzionanti.
- Cicatrici: binding corretti, testo scrollabile, notifica con scadenza,
  overlay che preserva il rito, blocker e navigazione da tastiera.
- Ripresa: BET_SIGNED ripristina BET_COMMITTED nel RunManager prima del
  patto; MOSTRA IL PATTO non viene piu' ignorato nello stato MAIN_MENU.
- Score: stessi payload UI e veri eventi rituali; niente reset su PREP/LIVE.
  Atrium -> Registry -> Inscription -> Threshold -> Dossier -> Atrium.
- Utility: superfici, tab attiva, crediti, traduzioni, ritorni e controlli
  nativi coerenti; traduzione dinamica di patti, arene e condanne. Emblema duplicato del fascicolo rimosso.
- Prologo: otto secondi, due ambienti approvati e frasi localizzate, skip,
  reduced motion, preferenza persistente, nessuna nuova fase gameplay.

## Verifiche

- Playbook: 55/55 passaggi locali, inclusi 43 statici, import, tre contratti
  runtime e otto scenari. Ultima verifica mirata AV: 65/66 condizioni.
- Matrice principale: 323 screenshot; percorso lineare: 14; prologo: 24;
  popup nativi: 12; sei descrizioni Archivio aggiunte nella verifica finale.
  Totale 379 immagini correnti, nessun target respinto.
  Gli inventari distinguono fixture e percorso reale. La cattura
  utility_delivery sostituisce le utility precedenti dopo il completamento
  di 70 chiavi localizzate per patti, arene e testi delle condanne.
- Export Windows da directory vuota: KEYBOARD_FULL_RUN superato.
  Pack: 17 immagini e 31 audio originali caricabili; risorse precedenti escluse.
- Dopo il playbook completo, i ritocchi a focus con frecce e cataloghi
  localizzati sono ricontrollati con 43 statici, import, AV da 66 condizioni,
  catture utility ed export; il playbook completo precedente conteneva 64.
- La prova grafica usa Vulkan Forward+ su RTX 5070 Ti Laptop; il percorso
  lineare finale usa cap 60 fps. Nessuna misura headless viene chiamata FPS.

Le prove finali e gli hash sono in
`artifacts/exports/consistency_fix_2026-09-08/delivery_manifest.json`.
La galleria `artifacts/consistency_fix_2026-09-08/report.html` contiene immagini,
ricerca per schermata/lingua, registrazione del bus Music e inventari.

Il contratto AV finale comprende 66 condizioni, incluse azioni reali dopo
Continue e sequenza degli stream. Le sorgenti e gli export sono identificati
nel manifest, senza attribuire ai test headless una misura FPS GPU.

## Limiti e gate

Verifica Windows locale, non signoff Linux del futuro commit. CP-03 richiede
tre sessioni umane, comprensione del prologo e ascolto prolungato del mix.
L'anomalia di cold import Windows del pass AV resta storica con causa non
isolata. Lo smoke dell'EXE termina con la diagnostica di shutdown gia'
nota e allowlisted (ObjectDB e tre risorse ancora in uso); i test AV fermano
e drenano l'audio prima di uscire senza questa diagnostica. Il report non
la dichiara risolta nel motore o nella chiusura automatica dello smoke.
Crediti definitivi, diritti, AppID, store e gate di pubblicazione
Steam restano aperti. Il pacchetto non dichiara pubblicato il gioco.

## Copertura visuale

| Superficie | Evidenza corrente |
| --- | --- |
| Menu | `live_00_menu_it_1280x720.png` |
| Registro chiuso | `live_02_register_closed.png` |
| Offerte e firma | `live_03_register_open.png` |
| Patto | `live_04_pact_signed.png` |
| Gesto | `live_05_intermediate_choice.png` |
| Rito | `live_06_resolve_ritual.png` |
| Incasso, condanna, rilancio | `live_07_push_your_luck.png` |
| Fascicolo aperto | `live_08_end_run.png` |
| Fascicolo chiuso | `08_dossier_it_1280x720_closed.png` |
| Descrizione Archivio al bordo | `22_archive_tooltip_en_1280x720.png` |
| Archivio condanne | `10_archive_condanne_en_1280x720.png` |
| Museo | `11_archive_museum_es_1280x720.png` |
| Crediti | `12_credits_es_1280x720.png` |
| Opzioni | `19_settings_en_1280x720.png` |
| Popup nativo | `20_popup_language_option_en_1280x720.png` |
| Cicatrici: dettaglio | `live_15_scars_detail_sample.png` |
| Cicatrici: notifica | `live_16_scar_notice_sample.png` |
| Silenzio | `live_13_silence_it_1280x720.png` |
| Assenza | `live_14_absence_it_1280x720.png` |
| Prologo: soglia | `live_17_prologue_threshold.png` |
| Prologo: Registro | `21_prologue_es_1280x720_reduced_1.png` |

Le varianti degli oggetti restano distinte per materiale e gesto, con lo stesso
linguaggio di pietra, bronzo e cera. La verifica visiva ha esaminato le
superfici rappresentative; 379 e' il numero delle catture, non dei test umani.

Il bus Music registrato dura 35.11 s, stereo 44100 Hz;
picco -20.91 dBFS, RMS -34.03 dBFS. Il file contiene
le tracce effettivamente mixate; ascolto prolungato e fatigue restano CP-03.

## File modificati nella consegna locale

L'elenco comprende i documenti e il capture tool dell'audit precedente,
conservati e aggiornati. Arte e audio sorgenti non sono stati rigenerati.

- `assets/i18n/en.csv`
- `assets/i18n/en.en.translation`
- `assets/i18n/es.csv`
- `assets/i18n/es.es.translation`
- `assets/i18n/it.csv`
- `assets/i18n/it.it.translation`
- `assets/ui/theme/official_theme.tres`
- `docs/README.md`
- `docs/audio_direction.md`
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/UI_CANON.md`
- `docs/cinematic_direction.md`
- `docs/content_bible.md`
- `docs/data_schema.md`
- `docs/development_plan.md`
- `docs/layout_rules.md`
- `docs/support/consistency_fix_2026-09-08.md`
- `docs/support/screen_audit_2026-09-08.md`
- `docs/testing.md`
- `scenes/Main.tscn`
- `scenes/UI.tscn`
- `scripts/audio/music_director.gd`
- `scripts/ci/av_runtime_contract.gd`
- `scripts/ci/test_final_dossier_object_contract.py`
- `scripts/systems/run_manager.gd`
- `scripts/systems/save_manager.gd`
- `scripts/ui/main_menu.gd`
- `scripts/ui/opening_prologue.gd`
- `scripts/ui/opening_prologue.gd.uid`
- `scripts/ui/registry_terminal_view.gd`
- `scripts/ui/ui_root.gd`
- `tools/audit_screen_capture.gd`
- `tools/audit_screen_capture.gd.uid`
- `tools/audit_screen_capture.tscn`

Chiusura: riferimenti docs validi, scansione mojibake senza occorrenze reali e
`git diff --check` pulito. La build e' lasciata nel working tree locale.
