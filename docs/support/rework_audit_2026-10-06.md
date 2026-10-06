# Audit del rework - 6 ottobre 2026

Confronto fra la build su `main` (`d3cd522`) e la direzione in
`docs/direction.md`. Prove raccolte con Godot 4.6.2 Linux sotto Xvfb:
partita reale a tempo normale attraverso i pulsanti della UI (IT, 1280x720,
profilo pulito), matrice visuale esistente e campagna UI completa del
contratto `scripts/ci/campaign_runtime_contract.gd`. Le catture restano
locali in `artifacts/` e non sono versionate.

## Sintesi

La base e' solida: materiali coerenti, flow stabile, lore originale e
personaggi riconoscibili. Mancano tre cose che rendono il gioco un prodotto:

1. **Uno scopo leggibile.** Il giocatore non vede mai la Gloria guadagnata,
   non sa perche' l'incasso e' bloccato fino all'arena 5 e non riceve alcun
   segnale del perche' sta ripetendo i percorsi. Il titolo GALLICUS non viene
   mai spiegato: Felix non compare nemmeno come precedente d'archivio.
2. **Un lessico unico.** La stessa parola indica cose diverse e il registro
   linguistico oscilla fra arena gladiatoria e ufficio rituale.
3. **Un ritmo senza attriti.** Ogni arena richiede otto input, tre dei quali
   senza informazione nuova, ripetuti centinaia di volte in una campagna.

## Difetti per priorita'

### P0 - Scopo e posta

- La Gloria accumulata non compare mai: solo la posta appare, dentro le note
  di Spingi la sorte. Il fascicolo riporta pressione massima e numero di condanne, non cio' che il
  percorso ha guadagnato o perso (`scripts/ui/ui_root.gd`,
  `_build_smart_register_summary`).
- `PRENDI LA QUIETANZA` resta spenta con la nota "Incasso disponibile dopo
  Arena 5" senza che il giocatore sappia mai in quale arena si trova.
- Il riquadro SEGNI mostra una sola riga con barra di scorrimento visibile.
- Felix Gallicus, previsto dal canon come precedente citato dopo la prima
  imperfezione del Registro, non e' mai citato: il nome del gioco resta muto.
  Il Silenzio, il momento piu' importante della campagna, e' uno schermo nero
  con il solo comando TORNA AL MENU. La campagna di riferimento (178 percorsi,
  ripetuta su questa build) ne attraversa tre prima dell'Assenza.

### P0 - Lessico e coerenza della copy

- `condanna` indica insieme il rischio della promessa, l'esito avverso del
  sigillo, la scelta di chiusura col marchio e gli sblocchi dell'Archivio. Dopo
  il primo percorso il fascicolo annuncia "10 condanne archiviate".
- Il patto `RADDOPPI O MUORI` dichiara "MORTE IMMEDIATA": linguaggio vietato
  dal content bible, contraddetto dal gioco (il percorso finisce, nessuno
  muore).
- Il rito annuncia "SECONDO COLPO - CONDANNA INCISA" anche quando l'esito sara'
  favorevole.
- Accenti resi con apostrofo nel testo player-facing (`E'`, `piu'`, `puo`,
  `e scritto`), grafia mista `HYBRIS`/`HUBRIS`, barre verticali nei valori.

### P1 - Tavola del Registro

- Ogni pagina e' un muro di testo con quattro intestazioni dello stesso peso
  (titolo, CONDANNA, CONDIZIONE, PATTO); titolo centrato e corpo allineato a
  sinistra; il grassetto non si distingue.
- L'enfasi dell'effetto riconosce solo la parola italiana `Effetto:`; in EN/ES
  la riga piu' importante perde rilievo.
- Rischio e ricompensa non sono confrontabili a colpo d'occhio fra le due
  pagine.

### P1 - Fascicolo

- I tre comandi si sovrappongono all'area testo e hanno lo stesso peso, benche'
  solo uno prosegua il percorso.
- Le colonne mostrano righe tecniche ("Atto registrato: accettato. Stato: 2
  condizioni registrate.") e la colonna sinistra tocca il dorso.
- Mancano le tre informazioni che il giocatore vuole: cosa ha guadagnato, cosa
  ha perso, cosa resta scritto.

### P1 - Ritmo

- `MOSTRA IL PATTO` richiede un input per rileggere cio' che e' appena stato
  firmato, a ogni arena.
- I tre colpi del sigillo non cambiano l'esito (corretto per canon) ma i
  segnali di avanzamento sotto il sigillo non si riempiono in modo leggibile.
- Una partita reale con un rilancio richiede circa 34 secondi e 18 input; la
  campagna automatica documentata il 12 settembre raggiunge l'Assenza in 178
  percorsi.

### P2 - Struttura e manutenzione

- `scripts/ui/ui_root.gd` (4357 righe) e `scripts/systems/run_manager.gd`
  (4551 righe) concentrano quasi tutta la logica; ogni rework UI tocca lo
  stesso file.
- Le chiavi di traduzione sono le stringhe italiane: correggere un accento
  significa aggiornare codice e tre cataloghi insieme.
- I documenti operativi crescono per sezioni datate aggiunte in coda; lo stato
  corrente va cercato in fondo a ogni file.

## Piano del rework

Ordinato per impatto sul giocatore. Ogni passo e' un insieme di modifiche
verificabili con i contratti esistenti, gli smoke e una cattura visuale.

1. **Direzione e audit** - questo documento e `docs/direction.md`.
2. **Lessico** - copy IT/EN/ES coerente col lessico unico: accenti nativi,
   nessuna morte o combattimento, `condanna` riservata al Registro, numeri con
   unita'.
3. **Posta visibile** - Gloria e posta nel rail, arena corrente e soglia della
   quietanza leggibili, Segni senza scrollbar superflua.
4. **Tavola del Registro** - pagina con gerarchia a tre livelli: titolo,
   promessa, rischio e ricompensa confrontabili.
5. **Fascicolo** - esito, Gloria guadagnata o persa, segni e un solo comando
   primario.
6. **Ritmo** - riconoscimento del patto e sigillo piu' rapidi dopo le prime
   arene, con feedback dei colpi.
7. **Precedente** - citazione di Felix Gallicus al primo Silenzio, nella forma
   prevista dal canon.

Fuori da questo rework, perche' richiedono sessioni umane: durata mediana
della campagna, bilanciamento di soglie e probabilita', anti-farming percepito.

## Stato del piano

| Passo | Stato | Dove |
| --- | --- | --- |
| Direzione e audit | fatto | `docs/direction.md` |
| Lessico | fatto per le superfici del loop | cataloghi `assets/i18n/*.csv`, `scripts/content/bet_catalog.gd`, `data/condanne.gd` |
| Posta visibile | fatto | rail: umore, Gloria e arena; motivi di blocco tradotti |
| Tavola del Registro | fatto | `scripts/ui/betting_circle_ui.gd` |
| Fascicolo | fatto | Gloria, segni, pressione, patti per titolo, nuove voci d'Archivio; area fuori dal dorso |
| Ritmo | parziale | rito con una sola riga di posta; riconoscimento del patto invariato |
| Precedente | fatto | riga di stato del terminale nei tre Silenzi |

