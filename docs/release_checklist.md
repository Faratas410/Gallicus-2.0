# Gallicus 1.0 Release Checklist

## Stati ammessi

- `DEVELOPMENT`: almeno uno stage della roadmap e' aperto.
- `RELEASE CANDIDATE`: contenuto e feature lock, QA finale in corso.
- `SIGNED FOR GALLICUS 1.0`: tutti i gate sono verdi.

Non esistono firme intermedie di prodotto.

## Prodotto

- [ ] Campagna canonica completa da Era 0 ad Assenza.
- [ ] Prima campagna mediana tra 2 e 4 ore.
- [ ] Nessun action combat o sistema estraneo introdotto.
- [ ] Nessun postgame riattiva il Registro.
- [ ] Obiettivo e conseguenze comprensibili senza guida live.

## Object-First

- [x] Ogni azione gameplay compila la formula object-first.
- [x] Soglia, Registro, firma, patto, gesto e rito hanno oggetti leggibili.
- [x] Cashout, condanna e double sono quietanza, marchio e incisione.
- [x] Il fascicolo rappresenta l'esito.
- [x] Il fascicolo mantiene linguette, copy IT/EN/ES e stati accessibili senza
  overflow a 1280x720 e 1920x1080.
- [ ] Utility e accessibilita' restano convenzionali.

## Sistemi

- [ ] Firma comportamentale deterministica.
- [ ] Coerenza, fissazione e isteresi verificate.
- [ ] Ere monotone e causate solo dal Silenzio.
- [ ] Ramp di tre run verificata.
- [ ] Silence non farmabile.
- [ ] Save/continue e stato terminale affidabili.
- [ ] Archivio e ending coerenti con il profilo.

## Contenuto

- [ ] Matrice path x Era x route coperta.
- [ ] Tutti gli ending dichiarati raggiungibili.
- [ ] Nessun placeholder o fallback player-facing.
- [ ] Copy coerente con tono e oggetti.
- [ ] IT/EN/ES complete.

## Audiovisivo

- [ ] Ogni gesto critico ha VFX, SFX e feedback UI.
- [ ] Art direction coerente su tutte le schermate.
- [ ] Variazioni delle Ere graduali e non etichettate.
- [ ] Intro, Silenzi e finale in-engine completi.
- [ ] Nessun asset action/combat residuo nelle superfici finali.
- [ ] Mix verificato su speaker e cuffie.

## Accessibilita'

- [ ] Mouse e tastiera coprono tutto il percorso.
- [ ] Focus sempre visibile.
- [ ] Reduced motion completo.
- [ ] Master, Music e SFX regolabili.
- [ ] Nessuna informazione critica solo cromatica o sonora.
- [ ] Layout leggibile a 1280x720 e 1920x1080.

## Tecnica

- [x] Static suite completa verde: playbook 42/42 sul commit `51eba5b`.
- [x] Tre run consecutive e tre linguette END_RUN verificate dalla run lean
  Linux `32594244882` sul commit `047ed67`.
- [ ] Godot import senza errori su cache fredda Windows.
- [x] Profilo CI `full` con gli otto scenari verdi su Linux: `33250720906`.
- [ ] Nessun fatal error, missing resource o `SANITY FAIL` su cache fredda.
- [x] Mojibake scan pulito.
- [x] Save migration da schema supportato.
- [ ] Tre campagne candidate complete.

## Pacchetto

- [x] Export Windows x64 avviabile fuori dall'editor.

Nota CP-02: signoff tecnico chiuso sul commit `51eba5b`. La lean
`33250711786` e la full `33250720906` hanno i tre job verdi; la full copre otto
scenari e 289/289 PNG. L'EXE commit-specifico passa `KEYBOARD_FULL_RUN` da
`APPDATA` nuovo ed e' registrato nel manifest
`artifacts/exports/cp02/51eba5b/cp02_export_manifest_51eba5b.json`.

Il cold import Windows ha richiesto la generazione della cache: i primi due
pass conservano diagnostica pre-import, il terzo e' pulito. Per questo le due
checkbox generali su cold import e missing resource restano aperte fino al
clean-install gate. CP-03 resta non autorizzato e richiede tre sessioni umane
con decisione go/no-go.
- [ ] Clean-install test.
- [ ] Metadata, icona e versione corretti.
- [ ] Crediti e licenze completi.
- [ ] Release notes e known issues.
- [ ] Nessun file di sviluppo necessario all'avvio.

## Blocker

Impediscono la firma:

- crash, soft lock o save corrotto;
- campagna non completabile;
- Era o Silenzio in conflitto col canon;
- route finale non funzionante;
- testo mancante/corrotto in una lingua;
- asset o audio mancanti;
- requisito accessibile privo di alternativa;
- CI Linux o export Windows falliti;
- Critical o Important aperto.
