# Campagna di circa 10 ore: baseline e piano di indagine

## Mandato e stato

Avvertenza del 29 ottobre: la base locale e' stata allineata al merge `8a298b3`
della PR #541 e contiene ora il riequilibrio `d4d5225`. Le simulazioni e i
numeri economici riportati sotto, salvo diversa indicazione, descrivono la base
precedente e non sono validazione del nuovo bilanciamento. Ripeterli prima di
prendere decisioni economiche. Stato dell'allineamento e gate aperti in
`docs/support/sospensione_10_ore_2026-10-29.md`.

Il 28 ottobre l'utente ha richiesto circa 10 ore di contenuto, una revisione
dell'economia e delle meccaniche, del percorso e delle schermate, e una
successiva ottimizzazione del codice. L'espansione e' autorizzata da questa
richiesta, anche dove la roadmap precedente la congelava. Non costituisce
accettazione umana, checkpoint Linux o autorizzazione alla pubblicazione.
L'utente ha inoltre autorizzato a rivedere i cardini di design quando serve
al risultato, senza uscire dal perimetro del gioco. Nessuna meccanica va
considerata intoccabile soltanto perche' descritta nel piano precedente;
ogni revisione deve dichiarare conseguenze e aggiornare gli owner pertinenti.

Baseline storica delle indagini: `main`, HEAD `b81a4fc00797be0b0f0b7dd68639e309f3db061c`, con numerose
modifiche locali preesistenti; il commit da solo non identifica il candidato.
Preservarle. Il design precedente prevedeva 2-4 ore: non e' una misurazione
attuale. Le simulazioni storiche riportano 43-50 percorsi per alcuni stili,
non una durata osservata da giocatori. Vedi
`docs/support/motivazione_2026-10-07.md`.

## Economia effettiva

- Gloria e' la posta incassata in un percorso; i Denari persistono nel profilo.
- Quietanza: un Denaro ogni tre Gloria, arrotondato in difetto. La correzione
  del 28 ottobre valuta il debito prima del premio del bando e raddoppia il
  deposito se il conto e' allora negativo. Prima della correzione il premio
  poteva portare il saldo sopra zero e annullare il raddoppio della stessa
  quietanza: a parita' di Gloria un bando chiuso poteva lasciare meno Denari.
- Trionfo +3 Denari; rivolta -3; alcune chiusure avverse -5. Debito minimo -20;
  sotto zero il banco chiude e la Pressione iniziale aumenta, da -10 compare
  anche un Segno. Il limite del debito non dimostra da solo che sia facile
  recuperare in una campagna reale.
- Banco: favore e pressione costano 3, assicurazione 5; ogni Era aggiunge 1 al
  prezzo. Acquisti prima della firma, solo se disponibili e pagabili.
- Bandi: dodici quote da 10 a 42, scadenze da quattro a sette arene, sblocco
  di racconti e due pagine; raggiunto il dodicesimo resta una quota di 42.

Le vecchie simulazioni segnalavano accumulo per alcuni stili, ripetizione e
recupero dal debito da verificare. Sono ipotesi sul candidato attuale, non
risultati di una popolazione di giocatori. Non correggere i prezzi basandosi
su una singola campagna simulata: misurare saldo, flussi, utilizzo e utilita'
degli acquisti, durata dei periodi in debito, chiusura dei bandi e contenuti
visti su piu' seed e stili, incluso chi non spende.

La correzione del debito e' coperta su profilo isolato da
`scripts/ci/ledger_settlement_runtime_contract.gd`: con conto -3 e quietanza
di 30 Gloria il conto finale e' 17 senza bando, 22 con bando chiuso. Il runner
di campagna esegue questo controllo su un profilo separato prima del viaggio.
La campagna automatica aggiornata arriva all'Assenza e supera il riavvio
terminale: `artifacts/ledger_fix_2026-10-28/summary.json`. Rimane il warning
ObjectDB alla chiusura; il runner non segnala errori.
Le simulazioni riportate sotto precedono questa correzione e non misurano il
nuovo comportamento, salvo la ripetizione identificata come successiva;
servono ulteriori seed prima di prendere decisioni di bilanciamento.

Prima campagna automatica su Windows, profilo isolato e seed 1782373819:
42 percorsi fino all'Assenza, 12 bandi chiusi, saldo fra -5 e 50, 95 acquisti.
Questa prova precede la correzione seguente: non e' riproducibile dal solo
seed e non va usata per tarare prezzi o confrontare strategie. La versione
usata allora assegnava zero Gloria alle chiusure di Silenzio/Assenza anche
quando la quietanza precedente aveva versato Denari; il simulatore ora usa la
ragione effettiva del regolamento, conservando separatamente l'evento pubblico.
La prova automatica `prudent.log` registra, per esempio, un Silenzio con
regolamento `CASH_OUT` e 21 Gloria; un altro Silenzio registra invece il
fallimento `DOUBLE_OR_DIE` e zero Gloria. Log locale in
`artifacts/economia_2026-10-28/prudent.log`.

Il controllo ha rilevato che la folla usava l'orologio per scegliere gli
intenti anziche' il seed salvato della run, in contrasto con il canon. Corretto
in `RunManager`: il seed del percorso, l'arena, l'indice dello scambio e
l'intento precedente determinano la scelta, senza cambiare payload o save.
Il contratto `scripts/ci/crowd_seed_runtime_contract.gd` passa localmente;
comprende un round-trip dello stato. Due run ripetute su profili isolati
restituiscono gli stessi risultati. Una
prima esecuzione headless Windows e' terminata con crash nativo prima del
contratto; la ripetizione isolata e' riuscita. Linux e la ripresa integrata
restano da verificare.

Il playbook statico passa su Windows con cartella temporanea nel progetto;
senza questa configurazione il test di isolamento incontra un errore di
permessi. Il controllo artistico ora riconosce i due font Fondamento gia'
documentati, con verifica hash e licenza. Smoke `FULL_RUN` locale verde;
non e' un checkpoint Linux ne' una prova del ritmo umano.

Il primo contratto campagna ha raggiunto l'Assenza e stampato il marker di
completamento, ma il runner lo ha correttamente respinto: due errori in
chiusura chiamavano la viewport della copertina del Registro fuori dall'albero.
La copertina ora interrompe il layout quando e' staccata; il contratto UI
esercita la sincronizzazione dopo il distacco e passa con 254 controlli.
La ripetizione della campagna completa passa, compreso riavvio terminale;
permane un warning ObjectDB alla chiusura, non un errore del runner. Primo log:
`artifacts/crowd_seed_2026-10-28/runtime.log`; ripetizione:
`artifacts/crowd_seed_2026-10-28/retry/summary.json`. Evidenza Windows locale,
non signoff Linux o playtest umano.

Il simulatore ora puo' scegliere `--shop=never` e registra Denari guadagnati e
persi oltre agli acquisti, con conteggi separati per favore e pressione. Una
prova di quattro percorsi dello stile `bando2`, seed 424242, ha riprodotto i
valori della campagna precedente con lo stesso seed; e' una verifica parziale
del tool, non un bilanciamento della campagna. Le strategie di acquisto sono
predefinite dal simulatore e non descrivono il comportamento di giocatori.

### Confronto preliminare dopo la correzione del seed

Due campagne accelerate con profili isolati, seed iniziale 1782373819,
stile `bando`, folla `read`, stessa regola di colpi extra; entrambe arrivano
all'Assenza in 42 percorsi. Le scelte di acquisto possono alterare il percorso,
quindi i risultati non isolano l'effetto causale del banco.

| Banco | Entrate | Uscite | Saldo finale | Saldo minimo / massimo | Acquisti | Bando 12 al percorso |
| --- | ---: | ---: | ---: | --- | ---: | ---: |
| Selettivo | 563 | 548 | 15 | -1 / 81 | 95 | 26 |
| Mai | 453 | 25 | 428 | 0 / 428 | 0 | 33 |

Il secondo percorso mostra una possibile accumulazione senza sbocco: 428
Denari e nessun acquisto. Con acquisti, le uscite quasi compensano le entrate
e la scala si chiude prima, ma questo singolo confronto non basta a valutare
vantaggio, divertimento, varianza o sicurezza del recupero. I riepiloghi
utilizzavano ancora la vecchia contabilizzazione della Gloria ai Silenzi:
non usare le percentuali di Gloria zero o le mediane di quel confronto.
Ripetere con il simulatore corretto, altri seed e stili, e confrontare opzioni
con utilita' reale invece di introdurre spese obbligatorie per assorbire saldo.

Ripetizione successiva alla correzione, seed 424242 e strategia bando2:
42 percorsi, saldo 7, 69 acquisti (53 assicurazioni, 7 favori, 9 riduzioni
di pressione). Non ci sono percorsi in debito, quindi non e' una prova della
nuova regola di recupero. La policy automatica cerca espressamente
l'assicurazione da posta 6, favore sotto zero e pressione almeno 4: le
frequenze riflettono queste istruzioni, non preferenze osservate di persone.
Log: `artifacts/economia_2026-10-28/postfix.log`.

Con seed 424242, stile prudente, un colpo extra quando la posta e' bassa e
nessun acquisto: Assenza dopo 43 percorsi, 194 Denari finali, sette bandi e
12 dialoghi distinti. La scala non arriva al gradino 8 o 12: contenuto e
progressione non sono equivalenti per ogni stile. Il processo segnala inoltre
risorse ancora in uso all'uscita; il riepilogo e' utile come indizio, non come
test di assenza di perdite. Log: `artifacts/economia_2026-10-28/prudent.log`.
Con lo stesso seed ma stile bando, colpi extra frequenti e acquisti selettivi:
42 percorsi, scala completa al percorso 24, 69 acquisti, saldo finale 7 e
massimo 43; 99 colpi extra, 59 retti. Log:
`artifacts/economia_2026-10-28/bando2.log`. I comportamenti differiscono su
piu' assi e non sono un esperimento controllato; neppure due seed dimostrano
la distribuzione dei risultati. Il simulatore accelera e salta dialoghi.

Il codice attuale permette ai quattro racconti del posto vuoto di arrivare
per Era anche senza bando e li presenta prima del congedo. Gli altri racconti
dipendono dalla scala e dopo il congedo non sono piu' proposti. Nel prototipo
di campagna verificare esplicitamente quali contenuti essenziali devono essere
accessibili anche a chi non raggiunge tutti i gradini; non promettere che
ogni stile abbia visto tutti i racconti solo perche' raggiunge l'Assenza.

## Durata e contenuto

Dieci ore significano 600 minuti di gioco effettivo. Con 43-50 percorsi come
ordine di grandezza storico, occorrerebbero circa 12-14 minuti medi a percorso,
inclusi lettura e transizioni; e' soltanto un rapporto aritmetico, non una
previsione. Non allungare attese o moltiplicare percorsi identici per centrare
il numero. Misurare prima tempo attivo, abbandoni, ripetizioni percepite,
decisioni significative e contenuto nuovo per tratto di campagna.
Nel confronto preliminare con acquisti si contano 235 arene; applicando
puramente come ipotesi i 10-15 secondi per arena indicati in
`docs/direction.md`, esse occuperebbero circa 39-59 minuti, esclusi dialoghi,
scelte lente e transizioni. Ne' il conteggio simulato ne' quel ritmo storico
misurano una sessione umana; mostrano pero' perche' non si possa ottenere un
target di dieci ore cambiando una sola soglia di progressione.

### Direzione di lavoro: atti che rispondono alla stessa storia

Ipotesi da prototipare, non regole gia' integrate: mantenere il percorso in
arena come nucleo, ma alternarlo a fascicoli di persone e luoghi che cambiano
in risposta alle scelte. I quattro passaggi del Registro possono ordinare
quattro atti senza esporre al giocatore numeri di Era: ingresso e primi debiti;
pressione della gradinata e posto vuoto; contraddizioni tra testimonianze e
scritture; smontaggio dell'apparato fino all'Assenza. Ciascun atto deve
introdurre almeno un problema e una possibilita' di scelta nuovi, non solo
una modifica grafica o prezzi maggiori.

Un primo verticale dovrebbe intrecciare tre elementi gia' presenti:

1. Orvo emette un bando con obiettivo e scadenza comprensibili.
2. Vessa presenta un conto e una decisione con un costo e un'alternativa
   leggibili; la spesa deve cambiare un rischio o una conseguenza effettiva,
   e non essere un pedaggio obbligatorio per leggere la storia.
3. Il fascicolo collega l'esito a una testimonianza di Dima o Lauro; una
   decisione precedente deve cambiare il contenuto disponibile o il modo in
   cui viene interpretato, e l'Archivio deve ricordare quella differenza.

Per il percorso: intento conoscere una contraddizione -> fascicolo concreto
-> gesto di confrontare due tracce e scegliere cosa presentare -> risposta
di un personaggio e conseguenza leggibile -> registrazione nel fascicolo.
Questa e' la direzione generale, mentre il primo caso e' descritto sotto.
La stessa scena deve poter
procedere anche con saldo basso o negativo; non acquistare deve restare una
scelta significativa, non una condizione di blocco.

#### Primo caso da preparare: il posto misurato

Prima versione integrata: dopo `seat_kept`, un foglio presenta due tracce e
tre azioni. La riserva costa 6 Denari subito; la testimonianza e' gratuita e
aumenta di 1 la Pressione iniziale delle run successive fino al prossimo
Silenzio. Il rinvio ripresenta la scelta al prossimo percorso. La scelta e'
registrata nel profilo e ricordata nell'Archivio, con riscontri distinti.
Questo caso non costituisce da solo la campagna estesa.

Seguito del 28 ottobre: le scelte aprono rispettivamente `La ricevuta piegata`
o `La voce nella fila`, sei battute ciascuna. Entrambe rivelano una lacuna
nella copia; il ramo pagato lascia la ricevuta forata, il ramo pubblico una
voce da rintracciare. La scena si apre dopo il riscontro e si riprende se si
esce prima di leggerla. Le due tracce non sono ancora un'indagine giocabile
completa: devono alimentare le azioni successive della campagna estesa.

Il fixture `tools/seat_followup_capture.gd` controlla 72 battute localizzate e
produce 12 catture in `artifacts/seat_followup_2026-10-28/`. Il dialogo scala
ora con la risoluzione come il caso; il cast e il portico conservano tuttavia
la resa illustrata precedente, ancora incoerente con il Registro pixel art.
Non considerare questo pass una revisione visiva completa del cast.
Il contratto runtime verifica entrambi i seguiti e la ripresa dopo pagamento;
una campagna automatica completa rimanda una volta, sceglie testimonianza,
vede `seat_witness_followup` e raggiunge Assenza e riavvio terminale. Prova:
`artifacts/seat_followup_2026-10-28/campaign/summary.json`. Windows locale;
l'ObjectDB segnala ancora un warning in chiusura, non un'accettazione umana.
File del seguito: `scripts/content/campaign_dialogues.gd`,
`scripts/systems/run_manager.gd`, `scripts/ui/seat_case.gd`,
`scripts/ui/opening_prologue.gd`, `scripts/ci/seat_case_runtime_contract.gd`,
`scripts/ci/campaign_runtime_contract.gd`, `tools/seat_followup_capture.gd`
e il suo UID; traduzioni IT/EN/ES e compilati. Aggiornati anche bibbia dei
contenuti, canone architettura, schema dati, layout, testing e roadmap.

Prove locali: il contratto runtime percorre il caso dalla UI, verifica rinvio
e ripresa dallo stesso checkpoint, scelta gratuita in debito, Pressione nei
percorsi successivi, pagamento una sola volta, reload del profilo e Archivio.
Il fixture visuale produce undici catture in
`artifacts/seat_case_2026-10-28/`: scelte IT/EN/ES a 960x540, 1280x720 e
1920x1080, debito e riscontro in italiano a 720p. Ispezionate le nove scelte
e i due stati italiani; a 960x540 il testo e' piu' piccolo e richiede prova
umana di leggibilita'. Il percorso e' Windows locale; restano da valutare il
peso economico, la comprensione, il ritmo e l'accettazione visiva.
Il contratto di campagna raggiunge il caso dopo il racconto naturale e lo
rimanda 36 volte, fino all'Assenza e al riavvio terminale; questo esercita il
rinvio, non una campagna completa per entrambe le scelte. Log e summary:
`artifacts/seat_case_2026-10-28/reach_campaign/summary.json`.

File del caso: `scripts/systems/run_manager.gd`,
`scripts/systems/run/run_state.gd`, `scripts/systems/save_manager.gd`,
`scripts/systems/game_events.gd`, `scripts/ui/seat_case.gd`,
`scripts/ui/opening_prologue.gd`, `scripts/ui/run_manager_ui_port.gd`,
`scripts/ui/main_menu.gd`, le traduzioni IT/EN/ES e i relativi file compilati;
`scripts/ci/seat_case_runtime_contract.gd`,
`scripts/ci/campaign_runtime_contract.gd`,
`scripts/ci/run_campaign_runtime_contract.py`, `tools/campaign_sim.gd`,
`tools/seat_case_capture.gd` e UID generati. Aggiornati anche canoni
meccanica, architettura e UI, schema dati, contenuto, grammatica degli oggetti,
direzione artistica, layout, testing e roadmap. Molti di questi file avevano
gia' modifiche locali precedenti, conservate.

La scena dei posti in vendita offre un conflitto concreto gia' nel catalogo:
Vessa misura la fila, Dima difende il posto, Nerio ha una copia incompleta.
Il verticale puo' far confrontare il righello con la copia e chiedere come
opporsi alla vendita: impegnare una somma dal conto oppure presentare la
testimonianza della gradinata accettando un costo nei prossimi percorsi.
Entrambe le vie devono portare alla stessa informazione indispensabile; il
modo in cui la si ottiene e la risposta dei personaggi devono differire.
Rinviare deve restare possibile, con un effetto dichiarato e un ritorno
raggiungibile anche in debito. La resa e il peso delle alternative restano da
valutare in playtest umano; non concedere vantaggi permanenti incompatibili
con il finale senza verificare la migrazione di una campagna in corso.

Budget iniziale solo per impostare le prove: 4 atti x circa 150 minuti;
ogni atto comprende percorsi, scene e consultazione in proporzioni da misurare.
L'Assenza deve attendere contenuti e decisioni che le diano senso, ma aumentare
una soglia numerica senza aggiungere situazioni non realizza il mandato.
Per decidere la struttura definitiva servono tempi osservati e una prova
giocabile del primo verticale; l'obiettivo di 600 minuti non e' ancora stimato.

## Sequenza di lavoro

1. Rendere ripetibile la baseline su piu' seed e strategie con profili isolati;
   verificare che il simulatore raggiunga davvero le scelte che dichiara.
2. Percorrere gioco e schermate reali, inclusi fallimento, incasso, rilancio,
   debito, ripresa e fine campagna; registrare evidenza e limiti. Il playtest
   del 26 ottobre copre una sola run: `docs/support/playtest_computer_use_2026-10-26.md`.
3. Disegnare progressione, contenuto e economia insieme: ogni nuova decisione
   deve avere costo, conseguenza e controgioco comprensibili. Distinguere
   proposta, implementazione e misura; mantenere la campagna finita.
4. Produrre schermate in sequenza dal medesimo sistema visivo e dagli oggetti
   del flusso, usando `docs/object_grammar.md`, `docs/art_direction.md` e
   `docs/layout_rules.md`; verificare lingue e risoluzioni nel runtime.
5. Implementare per pacchetti, aggiornare canon e contratti quando cambiano
   le regole, misurare regressioni e save. Ottimizzare dopo le scelte di
   meccanica, sulla base di profili e colli di bottiglia osservati.
6. Validare durata e coinvolgimento con campagne umane, senza attribuire a
   simulazioni accelerate o screenshot un'accettazione di ritmo e game feel.

Restano aperti checkpoint Linux sul candidato effettivo, sessioni umane,
accessibilita', audio, lingue e accettazione di durata e coinvolgimento.

## Prime osservazioni visive correnti

Fixture native del 28 ottobre, Godot 4.6.2 su Windows, italiano a 1280x720:
il Banco usa la famiglia pixel art del Registro, mentre il Fascicolo e' un
foglio piatto su un portico realistico. E' uno scarto evidente nella sequenza
e rafforza la priorita' gia' registrata nell'inventario di coerenza. La
progettazione del Fascicolo va fatta dopo aver definito quali tracce e scelte
deve contenere, preservando focus, lettura e route.

Le immagini sono fixture di presentazione, non un percorso giocato: nel banco
il fixture modifica il saldo del pannello senza aggiornare l'HUD, quindi il
contrasto fra `Conto 20` e HUD `0` non prova una discrepanza runtime.
Evidenze in `artifacts/playthrough_2026-10-28/counter/`.
Il runner ha completato 46 catture senza segnalare errori; sono state
ispezionate qui soltanto le viste Banco e Fascicolo citate sopra.
Il tentativo di osservazione interattiva del 28 ottobre non e' stato eseguito:
la richiesta di accesso alla finestra ha superato il tempo previsto.

## Confronto delle tracce del posto - 28 ottobre

Dopo la scena successiva alla scelta sul posto, il giocatore puo' esaminare
la copia di Nerio e, secondo la via scelta, la ricevuta o la voce della fila.
Le tracce si leggono in qualsiasi ordine; si possono rimandare al prossimo
percorso e rileggere prima di formulare una conclusione. Una supposizione
non sostenuta riceve un riscontro e non comporta penalita'. La conclusione
sostenuta viene conservata nel profilo e riportata nell'Archivio. Il rinvio
sopravvive alla ripresa del checkpoint; non modifica il saldo.

Verifica Windows locale su Godot 4.6.2: importazione e controlli statici del
playbook passati; contratti runtime del caso e del confronto passati su profili
isolati, inclusi entrambe le vie, salvataggio, ripresa, Archivio e navigazione
da tastiera simulata. Una campagna automatica precedente all'ultimo affinamento
visuale ha scelto la testimonianza, completato il confronto e raggiunto
l'Assenza e il riavvio terminale: `artifacts/seat_inquiry_2026-10-28/campaign/summary.json`.
Il runtime ha emesso un avviso ObjectDB alla chiusura; non e' una validazione
Linux ne' una sessione umana.

Il fixture `tools/seat_inquiry_capture.gd` ha prodotto 20 catture IT/EN/ES
in 720p e 1080p, con controllo automatico delle dimensioni e del testo delle
tracce: `artifacts/seat_inquiry_2026-10-28/summary.json`. Ispezionate a video
le viste della ricevuta in italiano, della voce in spagnolo e del riscontro in
inglese; le altre catture non costituiscono accettazione visiva completa. Sono
fixture: lo stato HUD sullo sfondo non e' prova di un percorso economico reale.

File del confronto: `scripts/systems/save_manager.gd`,
`scripts/systems/run/run_state.gd`, `scripts/systems/game_events.gd`,
`scripts/systems/run_manager.gd`, `scripts/ui/run_manager_ui_port.gd`,
`scripts/ui/seat_case.gd`, `scripts/ui/main_menu.gd`,
`scripts/content/campaign_dialogues.gd`, `assets/i18n/{it,en,es}.csv` e
relative traduzioni compilate, `scripts/ci/seat_inquiry_runtime_contract.gd`
e relativo UID, `scripts/ci/campaign_runtime_contract.gd`,
`scripts/ci/run_campaign_runtime_contract.py`, `tools/seat_inquiry_capture.gd`
e relativo UID. Aggiornati anche `docs/canon/MECHANICS_UNIFIED.md`,
`docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/canon/UI_CANON.md`,
`docs/data_schema.md`, `docs/object_grammar.md`, `docs/content_bible.md`,
`docs/development_plan.md`, `docs/testing.md` e questo rapporto. Le modifiche
locali preesistenti sono conservate.

Questo e' un piccolo episodio giocabile, non una dimostrazione di dieci ore.
Rimangono da progettare e realizzare le conseguenze successive, misurare la
campagna con persone e valutare coinvolgimento, ritmo, controller e audio.
L'ottimizzazione resta da guidare con profili dopo la definizione delle meccaniche.

## Handoff alla sospensione - 28 ottobre

L'utente ha chiesto di fermare l'obiettivo e documentare fatto e da fare.
L'obiettivo delle circa dieci ore e' sospeso, non completato. Tutto rimane nel
working tree locale su `main`; nessun commit, push o pubblicazione. Il tree
contiene anche numerose modifiche preesistenti: non ripristinarle in blocco.

### Fatto

- Indagine iniziale su loop, contenuti, economia e schermate; correzione della
  quietanza in debito e del seed degli intenti della folla, con contratti runtime.
- Caso del posto con due scelte, costo o Pressione, rinvio, ripresa, seguiti,
  confronto di tracce e memoria nell'Archivio; dettagli e verifiche sopra.
- Corretto il caso in cui il congedo precedeva un racconto gia' guadagnato dai
  bandi, rendendolo inaccessibile. Il contratto isolato
  `scripts/ci/campaign_story_order_contract.gd` era rosso prima della modifica
  ed e' verde dopo, passando dall'entrata della UI. Racconti non guadagnati non
  ritardano il congedo e le scene precedenti non si ripetono dopo. Questa ultima
  modifica non ha ancora una verifica integrata dell'intera campagna ne' una
  prova umana. Il nuovo script non ha ancora un UID generato dall'editor.
- Aggiunto `tools/run_economy_matrix.py`: tre seed, tre policy automatiche,
  profilo isolato per ogni campagna, log e risultati mantenuti. Le simulazioni
  saltano i dialoghi e rinviano il caso del posto; non misurano durata umana,
  interesse, preferenze o distribuzione reale dei giocatori. Il codice runtime
  misurato precede la correzione della priorita' del congedo. Manifest dei file
  sorgente e risultati: `artifacts/economy_matrix_2026-10-28/`.

| Seed | Policy | Percorsi | Saldo finale | Minimo | Run in debito | Acquisti | Bandi | Esito tecnico |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 424242 | bando, acquisti selettivi | 42 | 7 | 0 | 0 | 69 | 12 | OK |
| 424242 | bando, nessun acquisto | 42 | 333 | 0 | 0 | 0 | 12 | OK |
| 424242 | prudente, nessun acquisto | 43 | 194 | 0 | 0 | 0 | 7 | errore in chiusura |
| 1782373819 | bando, acquisti selettivi | 42 | 23 | -6 | 3 | 79 | 12 | OK |
| 1782373819 | bando, nessun acquisto | 42 | 357 | 0 | 0 | 0 | 12 | errore in chiusura |
| 1782373819 | prudente, nessun acquisto | 42 | 218 | 0 | 0 | 0 | 6 | OK |
| 777001 | bando, acquisti selettivi | 43 | 31 | -5 | 2 | 74 | 12 | OK |
| 777001 | bando, nessun acquisto | 43 | 392 | 0 | 0 | 0 | 12 | OK |
| 777001 | prudente, nessun acquisto | 42 | 231 | 0 | 0 | 0 | 7 | OK |

Tutte hanno raggiunto l'Assenza nei log; sette sono passate al runner. Le due
con errore hanno riportato otto risorse ancora in uso a fine processo: i loro
numeri sono indicativi, non prove tecniche riuscite. Una ripetizione dettagliata
isolata della campagna prudente seed 424242 e' arrivata all'Assenza senza
riprodurre l'errore: `artifacts/economy_matrix_2026-10-28/leak_full.log`.
La differenza di saldo tra policy suggerisce accumulo senza acquisti; non prova
quale prezzo o ricompensa sarebbe divertente o equilibrato. Nessuna campagna
esplora in modo sistematico il recupero dal debito prolungato.

### Da fare alla ripresa

1. Ripetere sul candidato aggiornato import Godot, contratto dei dialoghi e
   campagna integrata; generare l'UID dello script di test. Indagare l'errore
   intermittente di risorse e separare eventuali cause del driver da quelle del
   gioco. Non considerare chiuso il gate Linux.
2. Ampliare la matrice con strategie e profili esplicitamente in debito, prova
   dei due rami del posto e verifiche dei flussi economici. Progettare usi dei
   Denari che offrano scelte utili, non spese obbligatorie o semplice drenaggio.
3. Progettare e implementare contenuti e conseguenze successive al confronto
   delle tracce, con progressione di quattro atti e varieta' di scelte. Evitare
   di ottenere dieci ore moltiplicando run o attese identiche.
4. Percorrere le schermate reali in sequenza e uniformare il Fascicolo e le
   conversazioni alla famiglia visuale scelta, verificando lingue, dimensioni,
   focus, controller, accessibilita' e audio. Le catture automatiche non sono
   accettazione artistica o prova di game feel.
5. Misurare con campagne umane durata effettiva, ritmo, comprensione, rischio,
   scelte, abbandoni e coinvolgimento. Solo queste prove possono sostenere la
   pretesa di circa 600 minuti di contenuto significativo.
6. Dopo aver consolidato le meccaniche, profilare e ottimizzare i colli di
   bottiglia osservati. Eseguire checkpoint Linux e gate umani sul candidato
   effettivo; preparare la release secondo `docs/steam_release.md` senza
   interpretare questa richiesta come autorizzazione alla pubblicazione.

File dell'ultimo passaggio: `tools/run_economy_matrix.py`,
`scripts/ci/campaign_story_order_contract.gd`, `scripts/systems/run_manager.gd`,
`docs/canon/MECHANICS_UNIFIED.md`, `docs/canon/RUN_ARCHITECTURE_CANON.md`,
`docs/content_bible.md`, `docs/testing.md`, `docs/development_plan.md` e
questo rapporto. L'elenco dei file dei passaggi precedenti e' nei rispettivi
paragrafi sopra; i file gia' sporchi possono contenere anche lavoro preesistente.

## Ripresa: debito, caso e regressione - 29 ottobre

Il goal risulta nuovamente attivo. Import Godot 4.6.2 riuscito, generato
`campaign_story_order_contract.gd.uid`. Il runner della campagna integrata sul
candidato corrente raggiunge l'Assenza e supera il riavvio terminale:
`artifacts/resume_2026-10-29/campaign/summary.json`. Esegue anche i contratti
isolati del seed, della quietanza, del caso e del confronto. Resta un warning
ObjectDB all'uscita; la prova e' locale Windows, non gate Linux o accettazione
umana.

Il contratto dei dialoghi preesistente falliva sul focus perche' assumeva che
ogni scena tornasse immediatamente al Registro, mentre il caso del posto puo'
aprirsi dopo la scena. Ora verifica il focus sulla testimonianza, rimanda il
caso e controlla il ritorno al Registro; la ripetizione IT/EN/ES passa in
headless (`artifacts/resume_dialogue_retry_2026-10-29.log`). Questo controllo
non sostituisce l'accettazione visiva o una prova fisica del controller.

Il simulatore supporta `--initial-denari=-20` e `--seat=reserve|witness|defer`;
attraversa la UI del caso, il seguito e il confronto, e registra saldo a inizio
e fine run, prima uscita dal debito e stato del caso. Si deve usare un profilo
isolato: il parametro imposta il saldo del profilo. Due prove parziali di 20
percorsi, seed 424242, stile prudente, senza acquisti, iniziano a -20:

| Scelta | Prima uscita dal debito | Saldo finale | Entrate | Uscite | Esito caso |
| --- | ---: | ---: | ---: | ---: | --- |
| Testimonianza | 2 | 61 | 91 | 10 | confronto completo |
| Riserva | 2 | 50 | 86 | 16 | confronto completo |

Log: `artifacts/debt_witness_2026-10-29.log` e
`artifacts/debt_reserve_2026-10-29.log`. Entrambi hanno segnalato cinque
risorse ancora in uso alla chiusura; i numeri sono risultati preliminari, non
prove tecniche riuscite. Una ripetizione dettagliata isolata della testimonianza
ha restituito gli stessi valori senza riprodurre l'errore:
`artifacts/debt_verbose_2026-10-29.log`. Nessuna delle tre prove dimostra che
il problema di risorse sia risolto o che il recupero sia affidabile per altri
seed e strategie. La differenza di saldo non isola il costo della scelta:
la Pressione modifica gli esiti successivi. La durata di questi processi non
misura tempo umano e nessuno dei due percorsi parziali ha raggiunto l'Assenza.

File modificati in questa ripresa: `tools/campaign_sim.gd`,
`scripts/ci/illustrated_dialogue_contract.gd`,
`scripts/ci/campaign_story_order_contract.gd.uid`, `docs/testing.md`,
`docs/development_plan.md` e questo rapporto. Restano aperti il seguito
sostanziale dell'indagine, altre strategie e seed in debito, i problemi di
chiusura intermittenti, la coerenza visiva, i playtest umani, le dieci ore e
l'ottimizzazione basata su profili.
Il comportamento predefinito del simulatore e' stato confrontato con il log
precedente per quattro percorsi, stesso seed e policy: tutti i campi gia'
presenti delle quattro righe coincidono (`artifacts/resume_default_probe_2026-10-29.log`).

## Due memorie dopo il confronto - 29 ottobre

La conclusione del confronto apre una scena coerente con la scelta del posto:
la ricevuta conservata porta una piega non riconosciuta, oppure Dima torna alla
prima fila e qualcuno le fa spazio. Nerio puo' registrare il margine, non
l'identita' di chi ha toccato la carta o parlato. Il seguito usa il dialogo
esistente e la lista dei dialoghi letti nel profilo, senza nuovi campi save o
costi; se interrotto prima della lettura viene riproposto al resume.

Import Godot e contratto runtime su profilo isolato passano per entrambe le vie,
con prerequisito, interruzione, ripresa e reload. Fixture grafico: 72 battute
controllate in IT/EN/ES, 12 catture 720p/1080p in
`artifacts/seat_memory_2026-10-29/`; ispezionate due viste. Il portico e il
cast illustrati restano visivamente disallineati al Registro pixel art. I
controlli statici del playbook, i riferimenti documentali, la scansione
mojibake e `git diff --check` passano su Windows. Non sono accettazione umana.

File: `scripts/content/campaign_dialogues.gd`, `scripts/systems/run_manager.gd`,
`assets/i18n/{it,en,es}.csv` e risorse tradotte, `scripts/ci/seat_memory_runtime_contract.gd`
e UID, `scripts/ci/campaign_runtime_contract.gd`,
`scripts/ci/run_campaign_runtime_contract.py`, `tools/seat_memory_capture.gd`
e UID; `docs/content_bible.md`, `docs/canon/LORE_UNIFIED.md`,
`docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/data_schema.md`, `docs/testing.md`,
`docs/development_plan.md`, `docs/support/anima_gallicus_2026-10-29.md` e questo
rapporto. Il seguito e' una reazione narrativa, non una nuova decisione
sostanziale: la campagna di dieci ore, l'economia e la valutazione umana restano
aperte.
La campagna automatica completa sceglie la testimonianza, conclude il
confronto, vede `seat_voice_after_inquiry` al percorso 17 e raggiunge l'Assenza
al 50, con riavvio terminale verificato:
`artifacts/seat_memory_2026-10-29/campaign/summary.json`. Il runner segnala
ancora un warning ObjectDB alla chiusura. La via della ricevuta e' coperta dal
contratto isolato, non da questa campagna completa.

## Risposta nello stesso percorso - 29 ottobre

Il seguito del confronto prima richiedeva un percorso successivo: nella parte
finale della campagna l'Assenza poteva arrivare prima che la reazione comparisse.
Dopo la conclusione, `ASCOLTA LA RISPOSTA` apre subito il dialogo della via
scelta, usando il checkpoint e la persistenza gia' esistenti. Se si interrompe
la scena, il resume la ripropone. La conclusione non cambia saldo o regole del
rito e non introduce una nuova decisione di campagna.

Import Godot e contratti isolati del confronto e dei seguiti passati; il
secondo verifica anche la risposta nello stesso percorso nell'ultima Era. Il
fixture controlla 20 viste e i testi a 720p/1080p nelle tre lingue; e' stata
ispezionata la sola schermata italiana di conclusione, non tutte le viste o
l'intera transizione visiva. I test non sostituiscono una campagna umana.

File: `scripts/ui/seat_case.gd`, `scripts/ci/seat_memory_runtime_contract.gd`,
`assets/i18n/{it,en,es}.csv` e rispettive traduzioni compilate,
`docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/content_bible.md`,
`docs/testing.md`, `docs/support/anima_gallicus_2026-10-29.md` e questo rapporto.
La campagna automatica completa ha visto il seguito della testimonianza nello
stesso percorso del primo seguito, poi ha raggiunto Assenza e riavvio terminale:
`artifacts/seat_immediate_2026-10-29/campaign/summary.json`. Il warning ObjectDB
alla chiusura rimane. La via della ricevuta e' verificata dal contratto isolato,
non da questa campagna completa.

## Dove resta il margine - 29 ottobre

Dopo la risposta degli abitanti il soggetto puo' lasciare a Dima l'annotazione
sulla lacuna senza spendere, oppure pagare 5 Denari a Vessa per trascriverla
anche nella copia di Nerio. La prima via resta disponibile in debito; la seconda
non e' disponibile se il conto non basta. Si puo' rimandare: il rinvio vale per
il percorso corrente e sopravvive al resume. La scelta e l'eventuale addebito
sono scritti insieme nel profilo, hanno un riscontro diverso e sono ricordati
nell'Archivio. Non danno un bonus di combattimento e non identificano l'assente.

Il contratto runtime attraversa le due vie, verifica prerequisiti, debito,
rinvio e resume, addebito una sola volta, lettura dell'Archivio, riscontri,
vecchio profilo e sanificazione; verifica Tab sugli stati principali. Import
Godot e controlli statici passati su Windows. La campagna automatica sceglie la
via gratuita, vede la relativa risposta e raggiunge l'Assenza con riavvio
terminale: `artifacts/seat_copy_2026-10-29/campaign/summary.json`. La campagna
integrata e' stata eseguita prima dell'ultimo affinamento delle vicinanze di
focus del riscontro, verificato separatamente dal contratto aggiornato. Resta
un warning ObjectDB in chiusura; la via a pagamento e' coperta dal contratto
isolato, non da una campagna completa.

Fixture del foglio: nove catture, IT/EN/ES a 720p/1080p piu' debito e due
riscontri italiani: `artifacts/seat_copy_2026-10-29/summary.json`. Ispezionate
le scelte italiana e spagnola e il riscontro italiano a pagamento. I due dialoghi
sono controllati nelle tre lingue con 12 catture e 48 battute:
`artifacts/seat_copy_followup_2026-10-29/summary.json`; ispezionata una vista
italiana. Le altre immagini, il controller, l'audio e la leggibilita' soggettiva
richiedono verifica umana. Il portico illustrato resta disallineato alla
famiglia pixel art del Registro. Il fixture forza lo stato del profilo, quindi
l'HUD sullo sfondo non e' una prova dei flussi economici.

File: `scripts/systems/run_manager.gd`, `scripts/systems/run/run_state.gd`,
`scripts/systems/save_manager.gd`, `scripts/systems/game_events.gd`,
`scripts/ui/run_manager_ui_port.gd`, `scripts/ui/seat_case.gd`,
`scripts/ui/main_menu.gd`, `scripts/content/campaign_dialogues.gd`,
`assets/i18n/{it,en,es}.csv` e traduzioni compilate,
`scripts/ci/seat_copy_runtime_contract.gd` e UID,
`scripts/ci/campaign_runtime_contract.gd`,
`scripts/ci/run_campaign_runtime_contract.py`, `tools/campaign_sim.gd`,
`tools/seat_copy_capture.gd` e UID, `tools/seat_copy_followup_capture.gd` e UID,
`docs/object_grammar.md`, `docs/data_schema.md`, `docs/canon/MECHANICS_UNIFIED.md`,
`docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/canon/UI_CANON.md`,
`docs/canon/LORE_UNIFIED.md`, `docs/content_bible.md`, `docs/testing.md`,
`docs/development_plan.md`, `docs/support/anima_gallicus_2026-10-29.md` e
questo rapporto. Il valore percepito dei 5 Denari e la differenza tra le vie
restano da valutare con persone: due brevi riscontri e una voce d'Archivio non
provano da soli un arco di campagna o dieci ore di contenuto.

## Custodia ricordata in arena e confronto economico - 29 ottobre

Quando la destinazione della nota e' stata scelta, uno scambio della prima
arena puo' ricordare la copia di Nerio o la custodia di Dima. La selezione
usa il seed gia' salvato (un quarto dei valori), non modifica RNG, scelte o
risultati ed e' muta durante il Silenzio. Il contenuto differisce tra le due
vie; al momento delle prove sotto la trascrizione non aveva ancora lo sconto
sulla polizza introdotto nella sezione successiva.

Il contratto `scripts/ci/seat_copy_echo_contract.gd` controlla entrambi i rami,
la stabilita' della query, il Silenzio e le superfici IT/EN/ES a 720p/1080p.
La versione con renderer ha prodotto 12 fixture in
`artifacts/seat_echo_2026-10-29_final/`; ispezionate la copia italiana e la
custodia spagnola a 720p. Il fixture mostra dati HUD artificiali e non e' un
percorso giocato. Il contratto generale dei personaggi passa in headless.
Restano da verificare audio, controller, leggibilita' umana e quanto spesso la
memoria sia notata senza diventare ripetitiva.

Due coppie di campagne simulate parziali hanno confrontato `--copy=copy` e
`--copy=keep`: testimonianza, saldo iniziale -20, acquisti selettivi, stile
prudente, 24 percorsi. Il codice 424242 precede le nuove battute; il 777001 le
include. I confronti sono validi solo all'interno della stessa coppia.

| Seed | Via | Saldo finale | Acquisti | Assicurazioni | Entrate / uscite | Esito tecnico |
| --- | --- | ---: | ---: | ---: | --- | --- |
| 424242 | copia pagata | 11 | 22 | 14 | 144 / 113 | OK |
| 424242 | custodia gratuita | 11 | 23 | 15 | 144 / 113 | errore risorse all'uscita |
| 777001 | copia pagata | 11 | 35 | 19 | 195 / 164 | OK |
| 777001 | custodia gratuita | 11 | 38 | 18 | 198 / 167 | errore risorse all'uscita |

Nel primo seed la spesa della copia sostituisce un'assicurazione al percorso
13; nel secondo la policy effettua scelte diverse e le entrate cambiano. I
risultati non isolano un effetto causale generale, descrivono soltanto due
strategie automatiche predefinite; entrambe le vie gratuite terminano con
errori di risorse alla chiusura e sono indizi, non prove tecniche riuscite.
Le sessioni sono parziali, non raggiungono l'Assenza e non misurano tempo o
preferenze umane. Log `artifacts/copy_compare_{424242,777001}_{paid,free}.log`.
Non e' ancora dimostrato che spendere 5 Denari per la copia abbia valore
sufficiente o che il sacrificio sia compreso: serve una scelta con conseguenze
successive piu' sostanziali e una prova con persone prima di fissare il prezzo.

File: `scripts/content/arena_characters.gd`, `scripts/systems/run_manager.gd`,
`assets/i18n/{it,en,es}.csv` e traduzioni compilate,
`scripts/ci/seat_copy_echo_contract.gd` e UID,
`scripts/ci/run_campaign_runtime_contract.py`, `docs/content_bible.md`,
`docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/testing.md`,
`docs/development_plan.md`, `docs/support/anima_gallicus_2026-10-29.md` e
questo rapporto. Le modifiche precedenti del working tree rimangono conservate.
Il runner di campagna aggiornato include anche il contratto degli scambi,
attraversa la via gratuita e raggiunge l'Assenza con riavvio terminale:
`artifacts/seat_echo_2026-10-29_final/campaign/summary.json`. Persiste il
warning ObjectDB alla chiusura. Il contratto isolato aggiornato verifica anche
che lo scambio non compaia con seed non eleggibile o dopo la prima arena.
Una terza coppia con seed 1782373819, stessa policy e 24 percorsi, termina con
8 Denari in entrambe le vie: 27 acquisti e 14 assicurazioni con la copia,
28 e 15 con la custodia gratuita. Entrambe le esecuzioni segnalano cinque
risorse in uso alla chiusura: anche questa coppia resta indiziaria. Log:
`artifacts/copy_compare_1782373819_paid.log` e
`artifacts/copy_compare_1782373819_free.log`.

## Copia come prova per la polizza - 29 ottobre

La trascrizione per Nerio costa ancora 5 Denari. Vessa riconosce la copia
come prova e riduce di 1 Denaro il prezzo di ogni polizza fino al prossimo
Silenzio; la via gratuita conserva i 5 Denari ma non riceve lo sconto. La
superficie dichiara costo, sconto e durata non fissata prima della scelta.
Il Banco mostra il prezzo effettivo e la dicitura di sconto; l'Archivio lo
ricorda solo finche' attivo. Cinque polizze scontate equivalgono aritmeticamente
al costo di trascrizione, se sarebbero state acquistate comunque: non e' una
promessa di recupero, ne' una stima del vantaggio nella partita.

La scelta salva l'Era nello stesso profilo; il prezzo e' derivato e non viene
riapplicato come addebito al resume. I profili precedenti che avevano gia'
pagato ricevono lo sconto nell'Era corrente ancora aperta; l'Assenza non lo
riattiva. Il contratto isolato verifica entrambe le vie, acquisto effettivo,
prezzo mostrato, scadenza, Archivio, vecchi profili e dati invalidi. Una
campagna automatica completa con trascrizione pagata ha verificato il prezzo,
raggiunto l'Assenza e superato il riavvio terminale:
`artifacts/seat_policy_2026-10-29/campaign_paid/summary.json`. E' stata eseguita
prima dell'aggiunta della nota sulla durata e del richiamo in Archivio, poi
verificati separatamente. Persiste il warning ObjectDB alla chiusura.

La scelta e' stata catturata IT/EN/ES a 720p e 1080p, con verifica automatica
su nove fixture; e' stata ispezionata la vista italiana a 720p. Il Banco e'
stato catturato nelle tre lingue e due risoluzioni:
`artifacts/seat_policy_2026-10-29/summary.json`; ispezionate le viste italiane
e spagnole a 720p. Sono fixture, non sessioni umane o accettazione controller
ed audio.

Due confronti parziali, profilo iniziale -20, 16 percorsi, testimonianza e
acquisti selettivi, contano le polizze effettivamente scontate:

| Seed | Copia | Polizze scontate | Acquisti al Banco | Saldo finale | Esito tecnico |
| --- | --- | ---: | ---: | ---: | --- |
| 424242 | pagata | 1 | 18 | 11 | OK |
| 424242 | gratuita | 0 | 19 | 10 | errore risorse all'uscita |
| 777001 | pagata | 6 | 27 | 18 | errore risorse all'uscita |
| 777001 | gratuita | 0 | 26 | 23 | OK |

La policy cambia acquisti e i risultati non isolano un vantaggio causale; i
casi con errori sono indicativi, non verifiche tecniche riuscite. Le prove non
misurano interesse o durata umana. Log `artifacts/policy_count_{paid,free}_{424242,777001}.log`.
La durata variabile dello sconto puo' ridurre molto il recupero del costo: va
valutata in piu' scenari e con giocatori, senza fissare il bilanciamento sulla
base di questi due seed. Dieci ore, contenuto successivo, coerenza audiovisiva,
Linux e accettazione umana restano aperti.

File: `scripts/systems/save_manager.gd`, `scripts/systems/run_manager.gd`,
`scripts/ui/seat_case.gd`, `scripts/ui/run_manager_ui_port.gd`,
`scripts/ui/main_menu.gd`, `scripts/ci/seat_copy_runtime_contract.gd`,
`scripts/ci/campaign_runtime_contract.gd`, `scripts/ci/run_campaign_runtime_contract.py`,
`tools/campaign_sim.gd`, `tools/seat_policy_bank_capture.gd` e UID,
`assets/i18n/{it,en,es}.csv` e traduzioni compilate,
`docs/object_grammar.md`, `docs/data_schema.md`, `docs/canon/MECHANICS_UNIFIED.md`,
`docs/canon/RUN_ARCHITECTURE_CANON.md`, `docs/canon/UI_CANON.md`,
`docs/canon/LORE_UNIFIED.md`, `docs/content_bible.md`, `docs/testing.md`,
`docs/development_plan.md`, `docs/support/anima_gallicus_2026-10-29.md` e
questo rapporto. Le modifiche preesistenti del working tree sono conservate.
Il contratto aggiornato verifica anche l'uscita e la ripresa dopo il pagamento,
prima di leggere il seguito: saldo e prezzo scontato restano invariati.
