# Presenze dell'arena - 12 settembre 2026

Estensione richiesta dall'utente: aggiungere polli/galli ai personaggi gia'
integrati in `docs/support/character_voices_2026-09-12.md`.
Base locale: `7af8acd8c7f13264241bb8589b568186c11b3c13`, su main.

## Contenuto e canon

- Rugo, Gallo della soglia: tacca nella cresta, cura ripetuta di una penna,
  richiamo trattenuto. Scambia battute con Nerio, Orvo e Dima.
- Dima, Gallina della gradinata: riconosce i passi e ricorda chi occupava i
  posti. Il suo ricordo contrasta con il conteggio commerciale di Vessa.
- Restano i tre Gufi dell'amministrazione. Nessun umano; nessuna attribuzione
  di specie o voce a Felix o al giocatore. Le specie non impongono caste.
- Otto nuovi scambi di due battute: venti complessivi, cinque per ciascun
  contesto patto/gesto e relativo stato compresso. Ventidue nuove chiavi
  IT/EN/ES comprendono dialoghi, ruoli, schede e intestazioni generali.
- Presenze testuali, senza nuovi ritratti o doppiaggio. Silenzio e Assenza
  continuano a sopprimere ogni scambio.

Esempio: «Vessa: Quel posto è libero, Dima.» / «Dima: So chi ci sedeva.»
Nello stato compresso: «Vessa: Sempre quel posto?» / «Dima: Sempre quello.»

## Integrazione object-first

Intento: percepire gli abitanti durante il rito e ritrovarli nell'Archivio.
Oggetto: patto gia' firmato, superficie del gesto pubblico, schede consultabili.
Gesto: le azioni esistenti di avanzamento e consultazione; nessun nuovo input.
Feedback: due battute attribuite, intestazione «Voci dell’arena» e schede sotto
«PRESENZE DELL’ARENA». Registrazione: nessun nuovo campo save o collezionabile.

RunManager mantiene la query pura: seed salvato modulo dimensione del pool,
piu' indice arena. Nessun consumo RNG. Un contesto sconosciuto ritorna vuoto.
La nuova versione puo' mostrare uno scambio diverso da una build precedente
sullo stesso vecchio save; riaprire quel checkpoint nella stessa versione
mantiene lo scambio. Nessuna modifica a esiti, costi o progressione.

## Verifica e consegna

Evidenza del candidato corrente in `artifacts/arena_cast/`.

- Playbook locale: 51 controlli verdi, inclusi import, contratti AV,
  campagna fino all'Assenza e reboot terminale, FULL_RUN, CORE_CONTINUITY e
  KEYBOARD_FULL_RUN. Campagna completata in 178 percorsi.
- Ripresa reale del patto: lo scambio prima e dopo Continua coincide.
- Matrice del cast: 120 viste di dialogo e 18 dell'Archivio; geometria,
  raggiungibilita' dei cinque personaggi, traduzioni e scroll verificati.
  Ispezione visiva di sei catture rappresentative in IT/EN/ES a 720p/1080p.
- Il test dei personaggi inizialmente chiudeva con timer di lettura pendenti:
  ora li lascia scadere prima del teardown; rerun finale senza avvisi.
  Il test esteso di campagna mantiene un avviso ObjectDB al cleanup, senza
  errori di contratto; non viene presentato come un'esecuzione priva di avvisi.
- Export Windows: inventario asset valido e percorso completo da tastiera
  sull'EXE verde con profilo isolato.
- Build: `artifacts/exports/arena_cast_2026-09-12/Gallicus_Arena_Cast.exe`.
  Avvio di prova: `Start Playtest.cmd` nella stessa cartella, profilo dedicato.
  SHA256: `1d47c82dc09f6a32f6825b305a31a05ceaee178281f89bda42bf1ad9df82c2f6`.
- Manifest nella cartella export: hash sorgenti runtime, eseguibile e prove.
  Docs refs, scansione mojibake del repository e diff whitespace verificati.
  Modifiche locali non committate.

Il signoff Linux, le sessioni umane e la pubblicazione Steam restano distinti.

## File modificati

- `scripts/content/arena_characters.gd`: roster, battute e dimensione dei pool.
- `scripts/systems/run_manager.gd`: selezione sull'intero pool.
- `scripts/ui/main_menu.gd`, `scripts/ui/ui_root.gd`: intestazioni del cast.
- `assets/i18n/it.csv`, `assets/i18n/en.csv`, `assets/i18n/es.csv` e risorse
  `.translation` corrispondenti: contenuto localizzato.
- `scripts/ci/character_runtime_contract.gd`, `scripts/ci/av_runtime_contract.gd`:
  copertura del cast completo e ripresa dal patto reale.
- `docs/canon/LORE_UNIFIED.md`, `docs/canon/GLOSSARY_ENTITIES.md`,
  `docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/canon/UI_CANON.md`: owner.
- `docs/content_bible.md`, `docs/testing.md`, `docs/README.md`,
  `docs/development_plan.md` e questo report: contenuto, prove e consegna.
