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

- [ ] Ogni azione gameplay compila la formula object-first.
- [ ] Soglia, Registro, firma, patto, gesto e rito hanno oggetti leggibili.
- [ ] Cashout, condanna e double sono quietanza, marchio e incisione.
- [ ] Il fascicolo rappresenta l'esito.
- [ ] Il fascicolo mantiene linguette, copy IT/EN/ES e stati accessibili senza
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

- [ ] Static suite completa verde.
- [ ] Godot import senza errori.
- [ ] Profilo CI `full` con i sei scenari storici verde su Linux.
- [ ] Nessun fatal error, missing resource o `SANITY FAIL`.
- [ ] Mojibake scan pulito.
- [ ] Save migration da schema supportato.
- [ ] Tre campagne candidate complete.

## Pacchetto

- [ ] Export Windows x64 avviabile fuori dall'editor.
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
