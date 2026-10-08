# Benchmark Astra: punti B, C, D, E (7 ottobre 2026)

Richiesta di Marco: "Falli tutti in fila", dopo il benchmark dell'analisi di
Astra (scarti di sezione 4 e racconti del posto vuoto, commit `7765b4c`).
Una leva per punto; ogni leva misurata con `tools/campaign_sim.gd` (campagna
intera nella UI vera, profilo pulito, seed fissi, tre seed per variante).

## Cosa e' cambiato

- **B. Colpi in piu'.** Finche' il bando di Orvo e' aperto, ogni colpo extra
  che regge vale due guadagni dell'arena (`SEAL_BANDO_STRIKE_GAINS`); il
  prompt del sigillo lo dice. Situazione per il secondo colpo: bando aperto e
  quota non raggiunta. Per il terzo: ultima arena utile del bando.
- **C. Scambi.** Uno scambio nelle arene ordinarie, tre in quelle esposte
  (ultima arena utile del bando aperto, arena speciale). Sotto il guadagno di
  ogni pagina del patto, una riga con le condizioni di oggi (Favore, Pressione,
  Segni).
- **D. Pagine dei patti.** Le vecchie regole di sblocco non aprono piu' le
  pagine sigillate: solo la scala (gradino 3 `CONDANNA_ANCORA`, gradino 6
  `CONDANNA_MI_SONO_FERMATO`). Il libro base (`CONDANNA_FIRMATO`) resta aperto
  dal primo percorso.
- **E. Debito.** In debito una quietanza versa il doppio dei Denari
  (`LEDGER_DEBT_DEPOSIT_MULTIPLIER`); il banco chiuso lo dice.

## Numeri (campagna fino all'Assenza)

Stili: `never` insegue il bando e non colpisce mai in piu'; `bando2` colpisce
in piu' solo per il bando; `thin` ama il rischio (Violenza e Hybris, incassa
alla terza arena); `bow` abbassa sempre lo sguardo (chi fatica).

| Variante | Stile | Percorsi a 0 Gloria | Gloria mediana | Scala completa al percorso | Denari max |
| --- | --- | ---: | ---: | --- | ---: |
| prima | never | 17-26% | 18-32 | 16-32 | 78-131 |
| prima | bando2 (senza leva B) | 17-29% | 16-21 | 15-32, una non completa | 75-139 |
| solo B | bando2 | 19-28% | 23-31 | 21-22 | 55-131 |
| B+C+D | never | 24% | 19-22 | 30-40, una al gradino 10 | 37-59 |
| B+C+D | bando2 | 12-24% | 21-24 | 24-29 | 38-61 |
| B+C+D | thin | 23-32% | 16-19 | non completa (8-9) | 40-53 |
| B+C, D solo dal bando con Prudenza e Hybris | thin | 52-82% | 11-35 | non completa | 27-35 |

Debito, stile `bow` (chi fatica), percorsi in debito sulla campagna e periodo
piu' lungo: senza E 15-25 percorsi, periodi fino a 9-16; con E 9-18,
periodi fino a 6 (piu' uno finale di 11).

Lettura:
- B rende il colpo per il bando conveniente quanto non colpire, e la scala
  si chiude prima di chi colpisce senza leva. Non lo rende obbligatorio.
- C dimezza circa le risposte richieste e toglie il surplus di Denari (da
  80-160 a 40-60): il banco torna a contare. La scala dura di piu' (24-40).
- D nella forma pura lasciava solo Prudenza e Hybris e puniva chi ama il
  rischio; con il libro base aperto il danno sparisce.
- E accorcia i periodi di debito senza toccare chi gioca bene.

Da verificare nella partita umana: se uno scambio per arena basta a sentire la
gradinata, e se il "vale doppio" del bando si legge nel momento del colpo.
