# Handoff per Astra sulla scrittura di Gallicus

Richiesta dell'utente: «Dobbiamo fare un lavoro di scrittura molto forte,
lo facciamo con astra?» Questa consegna prepara il pass editoriale; la
riscrittura del gioco non e' stata ancora eseguita. Modello richiesto:
GPT-6 Astra. Effort consigliato: high, rispettando la selezione dell'utente.

## DIAGNOSIS

Gallicus deve acquistare una voce autoriale riconoscibile. Il pass riguarda
qualita' delle scene, rapporti fra personaggi, sottotesto, progressione e
testo delle superfici di gioco. Occorre leggere il contenuto effettivo e
diagnosticare con esempi: non assumere che tutto sia debole o da sostituire.
La revisione visuale precedente partiva dalla richiesta di migliorare una
UI troppo stock e geometrica; ora il lavoro richiesto e' sulla scrittura.

Direzione da conservare: «L'arena dimentica. Il Registro no.» Campagna
rituale finita, azzardo sulla propria definizione, amministrazione materiale
e memoria della gradinata. Il Registro e' un apparato impersonale: annota
atti ed evidenza, non vede intenzioni, non consola e non spiega la strategia.

Le cinque presenze hanno gia' gesti e rapporti specifici:

- Nerio cerca copie allineate e raschiature corrette; l'intenzione gli sfugge.
- Vessa vede margine vendibile anche dove gli altri vedono disagio.
- Orvo lavora sull'attenzione pubblica e prova i richiami prima di lanciarli.
- Rugo sceglie quando usare una voce che prima copriva gli annunci.
- Dima riconosce passi e occupanti dove l'amministrazione conta posti.

Usare queste differenze come motore delle battute, non come cinque tic
verbali. Cercare desideri locali, attriti e omissioni attraverso fatti e
gesti gia' canonici. Il posto vuoto e la riga che resta devono accumulare
significato senza ricevere una spiegazione finale.

## WORKFLOW

Repository: `C:/Users/dovig/Documents/GitHub/Gallicus-2.0`.
Stato rilevato prima di questo handoff: `main`, HEAD
`da99a64c7d90341ac57f3ad0e4cad7444f6bfa02`, 50 file locali modificati o
aggiunti, nessun commit/export nuovo. Ricontrollare il working tree e
preservarlo: contiene il pass UI/cast verificato, non materiale da scartare.

Leggere in ordine `AGENTS.md`, `docs/README.md`, `docs/direction.md`,
`docs/development_plan.md`, `docs/development_workflow.md`,
`docs/content_bible.md`, `docs/canon/LORE_UNIFIED.md` e
`docs/canon/GLOSSARY_ENTITIES.md`. Per copy interattiva usare
`docs/object_grammar.md`; prima degli edit runtime leggere
`docs/code_quality.md`, `docs/layout_rules.md` e `docs/testing.md`.
Il canon prevale sui report storici.

Sorgenti da inventariare prima della riscrittura:

- `scripts/content/campaign_dialogues.gd`: tre scene principali e otto
  racconti, speaker, testi, titoli e legame con i gradini del bando.
- `scripts/content/arena_characters.gd`: cinque schede e scambi brevi
  patto/gesto, nelle versioni distese e compresse.
- `data/` e `scripts/content/`: promesse, segni, condanne, voci e verdetti;
  distinguere campi narrativi da identificatori, condizioni ed effetti.
- `assets/i18n/it.csv`, `en.csv`, `es.csv`: testo realmente mostrato.
- `scripts/ui/opening_prologue.gd`, `main_menu.gd`, `betting_circle_ui.gd`
  e scene UI: composizione e consumer, senza trasferire autorita' alla UI.

La cast list delle conversazioni illustrate attualmente comprende Nerio,
Rugo, Dima e il terminale. Vessa e Orvo parlano negli scambi brevi e sono
citati nei racconti; hanno ora ritratti, ma questo non cambia da solo la
distribuzione delle battute prevista dal canon. Valutare il loro uso diretto
nelle scene come scelta editoriale esplicita, non come correzione automatica
di un path mancante. La prima tranche puo' essere forte dentro il cast attuale.

Confini: nessun essere umano; giocatore e Felix non parlano; Felix resta
allusione e precedente, senza biografia o comparsa. Gli abitanti non
spiegano cosmologia, Ere o come ottenere il Silenzio. Silenzio e Assenza
non producono dialoghi. Conservare fatti, ID, sblocchi, priorita', ordine
dei racconti, flow, RNG, economia, save e segnali. RunManager resta owner,
GameEvents bus, UI reattiva. Nuovi misteri, finali, risposte selezionabili
o ricompense non fanno parte di questo pass.

Lavorare direttamente su `main`, con un solo agente. Nessun branch,
commit, push, PR o pubblicazione. Ritratti trasparenti, base sfumata,
materiali condivisi e composizione gia' verificata vanno preservati.

## NEXT ACTION

1. Fare un audit editoriale dell'intera sequenza attuale: per ogni scena
   chiarire cosa accade, chi vuole cosa, cosa cambia e quale traccia resta.
   Identificare con citazioni brevi esposizione artificiale, voci
   intercambiabili, ripetizioni senza sviluppo e frasi astratte. Conservare
   le battute che funzionano e motivare le sostituzioni importanti.
2. Riscrivere una sequenza completa in italiano, iniziando da «La prima
   copia», e uno scambio patto/gesto come campione della stessa voce.
   Integrarli nei cataloghi e renderizzarli nel gioco: consegnare un esempio
   leggibile, non soltanto una dichiarazione di stile. Non dilatare il
   numero di battute per ottenere profondita'.
3. Consolidare il criterio nel content owner e applicarlo alle altre scene,
   agli otto racconti, alle schede e agli scambi; poi alla copy di rito,
   banco, bando, quietanza e fascicolo. Mantenere chiari gesto, costo e
   conseguenza; non rendere enigmatiche le informazioni necessarie a giocare.
4. Adattare EN/ES con la stessa funzione drammatica e voci distinguibili,
   conservando glossario, nomi, unita' e significato. Aggiornare insieme
   chiavi sorgente e consumer: nessuna UI con testo misto o fallback.

La sequenza campione serve a fissare il criterio, non a sostituire il pass
completo con un piano. Se emerge una scelta che cambia fatti o contratti
canonici, separare quella decisione dal lavoro editoriale gia' eseguibile
e presentare un'alternativa concreta. Evitare aforismi intercambiabili,
metafore oscure, spiegazioni in bocca ai personaggi e solemnita' uniforme.

## EXPECTED HANDOFF

Lasciare una patch locale integrata, con confronto prima/dopo del campione,
matrice delle scene riviste, criteri delle cinque voci, localizzazione e
file modificati. Aggiornare `docs/content_bible.md`; aggiornare il canon
owner soltanto per una scelta narrativa realmente cambiata e autorizzata.
Segnalare eventuali testi o decisioni rimasti fuori dal pacchetto.

Verifica proporzionata: import Godot, controlli statici pertinenti,
contratto delle conversazioni illustrate e del cast, schermate in IT/EN/ES
a 1280x720 e 1920x1080, focus/Enter/skip e scroll dell'Archivio. Verificare
testo lungo, line break, corrispondenza speaker/ritratto, ordine degli
sblocchi e assenza di anticipazioni. Chiudere con docs refs, scan mojibake
e `git diff --check`. Usare profili isolati sotto `artifacts/`; per import
e test su questa macchina anche APPDATA, LOCALAPPDATA e TEMP/TMP devono
stare nel workspace. Il Python utilizzabile e' quello bundled Codex.

Base di evidenza: `docs/support/claude_review_2026-10-08.md` e
`artifacts/claude_review_2026-10-08/candidate_portraits.json`.
Il candidato visivo precedente ha import pulito, 45/45 statici PASS,
contratti cast e conversazioni PASS e 54 catture prodotte, con un campione
ispezionato delle cinque sagome e delle tre superfici. Le campagne
accelerate precedenti coprono bando e racconti, non qualita' della scrittura.
Il playtest diretto era stato interrotto dall'utente: non riprendere una
lunga sessione visibile senza una nuova richiesta. Usare verifiche mirate.

Queste prove vanno riferite al candidato effettivo dopo la riscrittura.
Non trasformare una suite PASS in approvazione narrativa. La revisione
umana riguarda voce, coinvolgimento, comprensione, mistero e ritmo;
checkpoint Linux, CP-03 e pubblicazione Steam rimangono gate distinti.
