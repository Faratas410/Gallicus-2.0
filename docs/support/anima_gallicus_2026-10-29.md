# L'anima di Gallicus: lettura e direzione - 29 ottobre 2026

## La promessa

**L'arena dimentica. Il Registro no.** Il soggetto firma promesse e rischia
Gloria davanti a una gradinata; il corpo conserva i costi, gli abitanti
ricordano gesti e persone, il Registro conserva soltanto cio' che riesce a
classificare. La campagna mette in tensione queste memorie fino all'Assenza.
Il giocatore non impersona Felix e non parla al posto degli abitanti. L'identita'
di chi sedeva accanto a Dima rimane un'allusione, non una risposta certificata.

Questa e' una lettura di `docs/direction.md`, `docs/game_design.md`,
`docs/object_grammar.md` e `docs/canon/LORE_UNIFIED.md`, confrontata con il
runtime e le prove disponibili. Non e' una misurazione del coinvolgimento:
nessuna campagna umana completa ha ancora verificato la promessa.

## Cosa rende il gioco riconoscibile

1. **La firma impegna.** Un gesto semplice, fatto su un oggetto concreto,
   trasforma una promessa in rischio prima che il sigillo produca un responso.
2. **La folla e' presente.** Non e' un contatore generico: vuole sangue,
   trattiene il fiato o raccoglie sabbia; le risposte hanno prezzi leggibili.
3. **Le memorie non coincidono.** Il corpo porta Segni, Vessa tiene il conto,
   Dima ricorda il posto, Lauro canta una gesta, il Registro classifica. Le
   differenze fra queste tracce possono raccontare piu' di una spiegazione.
4. **Una persona eccede la copia.** Il precedente e il posto vuoto sono
   percepibili dai margini: non servono un detective onnisciente o una
   rivelazione che trasformi Felix in obiettivo da inseguire.
5. **Il rituale ha una fine.** Il Registro non diventa un antagonista morale;
   l'Assenza conclude una campagna finita senza dichiarare una vittoria.

## Dove il candidato sostiene o rischia questa promessa

- Il loop reale offre firma, risposta alla gradinata, colpi al sigillo e
  quietanza. `scripts/systems/run/registry_evolution.gd` conserva una lettura
  dei comportamenti; `scripts/content/cantastorie.gd` compone la gesta a partire
  da fatti forniti dal percorso. I contratti verificano proprieta' tecniche,
  non che una persona percepisca la relazione fra gesto e memoria.
- Il caso del posto lega il conto o la Pressione a un gesto che riguarda Dima;
  le due vie forniscono tracce diverse. Tuttavia il confronto attuale culmina
  in una domanda guidata. Due scene successive mostrano reazioni diverse di
  Dima e Nerio. Una scelta successiva offre la trascrizione a pagamento per
  Nerio o la custodia gratuita di Dima, con risposte e memoria distinte; il
  mondo puo' ricordare la destinazione anche durante uno scambio in arena.
  La copia diventa prova per una polizza temporaneamente scontata: offre un
  possibile recupero del costo, senza identificare l'assente o cambiare il rito.
  Il significato e il peso di questa scelta richiedono prova umana. Rischia di
  sembrare un quiz se la scena precedente suggerisce gia' la risposta: questa
  ripetizione e' stata rimossa dalle due vie.
- I resoconti economici mostrano accumulo quando il simulatore non spende;
  non dimostrano che servano prezzi piu' alti. Un costo ha senso quando compra
  un gesto o protegge qualcuno, con un'alternativa e un effetto comprensibili.
- Il playtest osservato del 26 ottobre ha percorso una sola run: nota un salto
  fra superfici pixel e dialoghi/portico illustrati e testi secondari piccoli.
  Le catture successive confermano lo scarto nel Fascicolo; non equivalgono a
  una valutazione umana del tono o della leggibilita'.
- I documenti precedenti prevedevano 2-4 ore. La richiesta attuale e' circa
  10 ore: il target e' stato aggiornato nella direzione e nello scheletro, ma
  il contenuto necessario e la durata non sono stati ancora verificati.

## Come fortificarla nelle prossime implementazioni

1. **Dare seguito alle tracce con gesti, non risposte espositive.** La copia,
   la ricevuta e la voce devono essere oggetti o memorie che altri possono
   trattare diversamente. Una scelta deve cambiare almeno un fatto osservabile
   successivo e avere un prezzo dichiarato; il mistero non deve essere risolto
   da un punteggio o dall'Archivio onnisciente. Progettazione ancora aperta.
2. **Far rispondere il mondo a cio' che e' realmente accaduto.** Confrontare
   la stessa azione nei versi di Lauro, nei conti di Vessa e nella copia del
   Registro; mostrare differenze specifiche, senza inventare fatti non
   sostenuti dal percorso. Verificare anche casi in debito e rinvio.
3. **Dare alle dieci ore nuovi contesti, non inerzia.** Organizzare problemi,
   personaggi e conseguenze attraverso la campagna; alternare il rischio del
   sigillo alla consultazione e a scelte materiali. Una nuova scena deve
   cambiare la domanda o la lettura del rituale; non aggiungere attese e run
   identiche per raggiungere il numero.
4. **Unificare in sequenza l'esperienza visiva.** Partire dagli oggetti del
   flusso e dalla famiglia del Registro, raccordare entrata, dialoghi e
   Fascicolo, e verificare il percorso completo nelle tre lingue e dimensioni.
   I personaggi devono conservare silhouette e voce riconoscibili.
5. **Misurare la promessa con persone.** Chiedere senza suggerimenti cosa il
   Registro sa, cosa la folla ricorda, quale costo il soggetto ha accettato e
   perche' torna. Rilevare durata attiva, ripetizione percepita, scelte e
   abbandoni. Tastiera/controller, audio e accessibilita' richiedono prove
   separate; gli script non possono certificare interesse o dieci ore.

## Criteri per valutare ogni aggiunta

Una modifica rafforza l'anima se il giocatore puo' riconoscere l'oggetto, il
gesto e il prezzo prima di agire; poi vedere una conseguenza legata all'atto
e almeno una memoria che non sia una spiegazione totale. Una modifica che
aggiunge solo valuta, bonus, schermate o attesa senza cambiare una decisione
e' da ripensare. Questi criteri guidano la progettazione: l'effetto emotivo
resta da dimostrare in sessioni umane.

## Evidenze e limiti

- La battuta di Rugo nelle due scene successive alla scelta non anticipa piu'
  che la copia e' incompleta: chiede se quella copia permetta di riconoscere
  chi sedeva. Il confronto successivo resta invariato. La battuta e' stata
  tradotta in italiano, inglese e spagnolo e reimportata in Godot.
- Il contratto runtime del caso passa su profilo isolato. Il fixture grafico
  controlla 72 battute e produce 12 immagini IT/EN/ES a 720p e 1080p:
  `artifacts/seat_followup_2026-10-28/summary.json`. Questo controllo
  automatico del testo non e' un giudizio umano sulla scena o sul suo ritmo.
- Il seguito del confronto usa due scene dipendenti dalla via scelta: la
  ricevuta ripiegata e la prima fila che fa spazio. Il contratto runtime copre
  selezione, interruzione e ripresa; la risposta segue subito l'annotazione,
  evitando che l'Assenza la renda irraggiungibile. Il fixture controlla 72 battute localizzate
  e produce 12 immagini in `artifacts/seat_memory_2026-10-29/`. Solo due viste
  sono state ispezionate: il portico illustrato resta visivamente disallineato
  rispetto al Registro pixel art. Nessuna prova umana di coinvolgimento.
- `docs/support/campagna_economia_2026-10-28.md`: baseline economica,
  simulazioni, casi e verifiche locali del candidato sporco su `main`.
- `docs/support/playtest_computer_use_2026-10-26.md`: osservazione di una run,
  senza catture conservate ne' accettazione umana.
- `docs/canon/MECHANICS_UNIFIED.md` e `docs/canon/RUN_ARCHITECTURE_CANON.md`:
  regole e ownership; `docs/testing.md`: gate e limiti dei test.

Il report non dichiara completo il progetto, non sostituisce il canon e non
autorizza pubblicazione o release.
