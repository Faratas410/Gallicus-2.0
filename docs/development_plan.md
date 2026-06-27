# Gallicus Development Plan

## Direzione

La roadmap porta direttamente a Gallicus 1.0. Le fasi sono gate produttivi,
non versioni distribuibili. Una fase e' chiusa solo quando i suoi criteri sono
verificati; il lavoro successivo non deve mascherare blocker precedenti.

## Stato corrente

- Stage attivo: **Foundation Reset - CI verification**.
- Loop rituale: operativo e coperto da smoke.
- Campagna completa: non ancora implementata.
- Prossimo stage: **Object-First Interaction Pass**.
- Vincoli invariati: `RunManager` flow authority, `GameEvents` bus, UI reattiva.
- Verifica locale: static suite e import Godot verdi.
- Runtime Windows headless: diagnostico bloccato da crash nativo prima del
  bootstrap; la chiusura richiede la matrice CI Linux sul commit risultante.

## 1. Foundation Reset

Obiettivo: sostituire il framing di milestone intermedie con un sistema
documentale e tecnico orientato alla release finale.

Deliverable:

- documentation OS 1.0;
- roadmap unica e documenti di dominio coerenti;
- rimozione dei pacchetti milestone obsoleti;
- contratti e scenari CI con nomi semantici;
- stato reale del prodotto documentato.

Gate:

- riferimenti docs validi;
- static suite verde;
- Godot import verde;
- smoke `BET_PRESENT`, `FULL_RUN` e route principali verdi;
- nessun riferimento attivo alle milestone eliminate.

## 2. Object-First Interaction Pass

Dipendenza: Foundation Reset.

Obiettivo: rendere ogni azione gameplay un gesto su un oggetto leggibile.

Ordine:

1. soglia dell'arena;
2. apertura e consultazione del Registro;
3. scelta e firma della promessa;
4. tavoletta del patto;
5. gesto davanti alla gradinata;
6. colpo sul sigillo;
7. quietanza, marchio e seconda incisione;
8. chiusura del fascicolo.

Deliverable:

- scheda object-first compilata per ogni azione;
- presentazione, copy, VFX e SFX associati;
- stessi intenti e segnali esistenti;
- utility UI mantenuta convenzionale e accessibile.

Gate:

- ogni azione compila la formula object-first;
- screenshot delle schermate critiche a 1280x720 e 1920x1080;
- nessuna regressione ai contratti del ritual loop;
- un tester identifica oggetto, gesto e conseguenza senza spiegazione.

## 3. Run Readability And Feedback

Dipendenza: Object-First Interaction Pass.

Obiettivo: rendere una run comprensibile, reattiva e affidabile.

Deliverable:

- stato corrente, prossima azione, rischio e conseguenza sempre leggibili;
- feedback visivo, audio e UI per ogni gesto;
- route finali inequivocabili;
- save/continue, settings e piu' run consecutive verificati;
- focus, reduced motion e mix audio di base.

Gate:

- tre run consecutive senza riavvio;
- cashout, double e condanna coperti;
- nessun stuck modal o route ambigua;
- nessuna azione importante muta o priva di conferma.

## 4. Registry Memory And Convergence

Dipendenza: Run Readability And Feedback.

Obiettivo: implementare la memoria interpretativa che collega le run.

Deliverable:

- firma comportamentale a quattro assi;
- coerenza, smoothing, fissazione e isteresi;
- scars, condanne e path integrati come evidenza;
- Archivio e riconoscimenti coerenti;
- persistenza e migrazione save;
- metriche interne mai esposte come progress bar.

Gate:

- stessi seed producono la stessa evoluzione;
- fissazione richiede le condizioni canoniche;
- inversioni rapide non annullano la firma;
- save/continue conserva lo stato senza corruzione;
- test statici e runtime coprono soglie e fallback.

## 5. Eras And Silences

Dipendenza: Registry Memory And Convergence.

Obiettivo: trasformare le run in una campagna finita.

Deliverable:

- progressione monotona `registry_era` da 0 a 4;
- transizioni causate esclusivamente dal Silenzio;
- ramp di tre run dopo ogni transizione;
- mutazioni graduali di copy, offerte, art e audio;
- compressione terminale conforme al canon;
- Assenza del Registro e blocco definitivo della campagna.

Gate:

- nessuna UI nomina o numera le Ere;
- il Silenzio non e' farmabile;
- nessuna ricompensa o probabilita' outcome e' alterata dall'Era;
- il profilo terminale non reinizializza il Registro;
- campaign smoke copre transizioni, resume e finale.

## 6. Content Completion

Dipendenza: Eras And Silences.

Obiettivo: completare la varieta' necessaria a una campagna di 2-4 ore.

Deliverable:

- matrice path x Era x route finale coperta;
- bet, condanne, scars, verdetti e ending senza placeholder;
- variazioni linguistiche coerenti con convergenza ed Era;
- Archivio completo;
- IT/EN/ES allineate al contenuto sorgente.

Gate:

- tutti gli ending dichiarati sono raggiungibili;
- nessun ramo usa testo generico di fallback;
- tre run consecutive nella stessa Era non presentano una sequenza identica;
- playtest completi rientrano nel target di durata senza grind.

## 7. Audiovisual Completion

Dipendenza: Content Completion. La produzione preparatoria puo' iniziare prima,
ma il lock richiede contenuto stabile.

Obiettivo: dare alla campagna un'identita' audiovisiva coerente e finita.

Deliverable:

- kit di oggetti rituali runtime-ready;
- background e variazioni graduali per il Registro;
- VFX e motion associati a gesti e conseguenze;
- sound set di pietra, cera, bronzo, carta, folla e respiro;
- musica e mix per le condizioni del Registro;
- intro, Silenzi, transizioni e finale come sequenze in-engine;
- rimozione o sostituzione degli asset con semantica action/combat.

Gate:

- nessun asset mancante o fuori mood nelle superfici finali;
- ogni effetto comunica stato o gesto;
- audio leggibile su speaker e cuffie;
- reduced motion preserva informazioni e tempi di input;
- budget performance rispettato alle risoluzioni target.

## 8. Release Lock

Dipendenza: tutti gli stage precedenti.

Obiettivo: produrre una build Windows pubblicabile e verificata.

Deliverable:

- navigazione completa mouse e tastiera;
- IT/EN/ES complete;
- crediti, licenze e metadata;
- export Windows x64;
- test clean install, clean profile e save migration;
- release notes e known issues non bloccanti;
- CI Linux e campagna manuale complete.

Gate:

- `docs/release_checklist.md` interamente verde;
- almeno tre campagne complete su build candidate;
- nessun Critical o Important irrisolto;
- export avviabile fuori dall'editor;
- stato finale: `SIGNED FOR GALLICUS 1.0`.

## Prossimo step operativo

Eseguire la matrice CI Linux sul commit del reset. Se i sei scenari sono verdi,
marcare Foundation Reset completo e aprire una patch separata per il primo
blocco Object-First: le tre scelte push-your-luck come quietanza, marchio e
seconda incisione.
