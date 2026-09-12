# Voci dei Gufi

Richiesta: introdurre personaggi caratteristici, dialoghi e testi rispettando
il canon. Il pacchetto estende la campagna locale gia' modificata su main;
preserva tutti i cambiamenti precedenti. Nessun commit, push o pubblicazione.

## Personaggi e funzione

| Gufo | Carattere | Tratto osservabile |
| --- | --- | --- |
| Nerio, scrivano | preciso, concentrato sulla copia | allinea il foglio con l'ala e ricorda le raschiature |
| Vessa, quote | composta, commerciale | cerca spazio e margine anche quando si parla di ferite |
| Orvo, banditore | attento alla risposta del pubblico | prova i richiami e detesta annunci sprecati |

Sono personale dell'Arena. Il Registro conserva la propria natura impersonale;
Felix resta muto e assente dalla scena. Nessun umano entra nella trama.

Esempio dopo la firma:

> Nerio: La firma e' asciutta.
> Vessa: Il margine resta in vendita.

Esempio davanti alla gradinata:

> Vessa: La gradinata aspetta.
> Orvo: Le pause sono parte del richiamo.

## Integrazione

Dodici scambi di due battute: tre per contesto (patto, gesto), con tre varianti
compresse per ciascun contesto. La selezione usa seed salvato e arena; la
compressione segue il progresso ambientale gia' esistente. Nessun RNG o
contatore consumato, nessuna memoria aggiuntiva nel profilo. Continue ritrova
lo stesso scambio. Sono testi, senza doppiaggio o nuovi ritratti.

Il patto conserva titolo e gesto; le voci occupano il corpo secondario.
Il gesto pubblico conserva la riga della gradinata e aggiunge lo scambio.
L'Archivio espone tre schede con ruoli e abitudini. Non sono nuovi sblocchi.
I testi non spiegano formule, stati nascosti, Felix o la fine della campagna.
Non ci sono risposte selezionabili, tutorial strategici o nuove attese.
Silenzio e Assenza non producono dialoghi.

Scheda object-first: intento = riconoscere chi amministra il gesto;
oggetto = tavoletta gia' firmata, spazio davanti alla gradinata, note d'Archivio;
gesto = quelli esistenti; feedback = scambio attribuito ai Gufi;
registrazione = soltanto gli atti originali del percorso. La consultazione
non modifica lo stato. Le tre lingue usano 32 nuove chiavi complete.

## Verifica e consegna

Evidenze del pacchetto in `artifacts/characters/`. Il contratto dei personaggi
e' incluso nel runner AV esistente e quindi nel playbook e nella CI runtime.
Verifica anche testo realmente visibile, ingombro delle battute e contenimento
del pulsante nel pannello. Le fixture non sono una prova di durata umana.

Il bundle ha evidenziato contaminazione fra smoke: FULL_RUN lasciava sblocchi
nel profilo usato dalla Quietanza successiva, alterandone le offerte. Il runner
ora isola ogni invocazione. La Quietanza isolata passa senza cambiare seed,
offerte, esiti o validator; tutte le otto route vengono rieseguite. Una prova
unitaria controlla separazione dei profili e preservazione del save personale.

Risultati locali:

- 43 contratti statici verdi in `artifacts/characters/static_final`.
- CP-02, semantica, AV e campagna verdi nel bundle `playbook`; lo smoke
  Quietanza contaminato resta documentato come fallito, superato dalla
  serie `routes` con tutte le otto route verdi e profili isolati.
- `av_continue.log`: dialogo presente sul patto reale e identico dopo Continue.
- `capture_final.log`: 72 fixture di dialogo e sei dell'Archivio, IT/EN/ES
  a 720p e 1080p, controllate per visibilita', ingombro e pulsanti.
- `pack.log`: 18 immagini e 31 audio integri nell'export.
- `export_keyboard_summary.json`: percorso tastiera dall'EXE riuscito.
- Docs refs, mojibake e diff check puliti alla consegna.

Build locale in `artifacts/exports/character_voices_2026-09-12/`:
`Gallicus_Character_Voices.exe`, launcher `Start Playtest.cmd`, istruzioni e
manifest con hash dei sorgenti e delle prove. SHA-256 dell'EXE:
`b7f2db11c9a1c53f3573c5905c61a19bfa987d5bb5ba050dca223f2987fa5fdf`.
Il launcher usa un profilo dedicato; l'EXE diretto usa quello standard.
Il pacchetto e' implementato e verificato localmente, in attesa di signoff
cumulativo Linux e valutazione editoriale durante le sessioni con giocatori.

## File del pacchetto

- `scripts/content/arena_characters.gd` e relativo `.uid`
- `scripts/systems/run_manager.gd`
- `scripts/ui/run_manager_ui_port.gd`
- `scripts/ui/ui_root.gd`
- `scripts/ui/main_menu.gd`
- `assets/i18n/it.csv`, `assets/i18n/en.csv`, `assets/i18n/es.csv`
- `assets/i18n/it.it.translation`, `assets/i18n/en.en.translation`, `assets/i18n/es.es.translation`
- `scripts/ci/character_runtime_contract.gd` e relativo `.uid`
- `scripts/ci/run_av_runtime_contract.py`
- `scripts/ci/av_runtime_contract.gd`
- `scripts/ci/run_headless_smoke.py`, `scripts/ci/test_headless_smoke_validator.py`
- `docs/canon/LORE_UNIFIED.md`, `docs/canon/GLOSSARY_ENTITIES.md`
- `docs/canon/UI_CANON.md`, `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/content_bible.md`, `docs/testing.md`, `docs/development_plan.md`
- `docs/README.md` e questo report
