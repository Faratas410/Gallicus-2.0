# Motivazione: bando, scala, posto vuoto e catena (7 ottobre 2026)

Richiesta di Marco: "Voglio che troviamo un motivo che spinge il giocatore a
continuare. Perche' scommettere? Perche' continuare? [...] Semplice ed
addicting". Proposta in quattro pezzi, scelta "Tutti e quattro".

## Cosa e' stato costruito

- **Bando di Orvo.** Ogni percorso ha una quota di Gloria da incassare entro
  un'arena. E' la ragione per rilanciare: il patto prudente da solo non basta.
- **Scala dei bandi.** Dodici gradini nel profilo. Ogni bando chiuso paga
  Denari +5, un gradino e l'acclamazione al percorso dopo (Favore +2).
- **Il posto vuoto.** Gli otto racconti diventano i premi dei gradini 1-8; tre
  nuovi (`seat_kept`, `footstep`, `slope`) seguono chi sedeva accanto a Dima.
  I gradini 3, 6 e 9 aprono le pagine sigillate dei patti (dal benchmark del 7
  ottobre: gradini 3 e 6, libro base aperto; vedi `docs/canon/MECHANICS_UNIFIED.md`).
- **Catena.** I sigilli d'arena retti di fila valgono x1,5, x2, x3.

Regole: `docs/canon/MECHANICS_UNIFIED.md` ("Bando, scala e catena"). Lore:
`docs/canon/LORE_UNIFIED.md` e `docs/content_bible.md` ("Racconti"). UI:
`docs/canon/UI_CANON.md` ("Orvo's bando and the chain"). Gate:
`scripts/ci/test_bando_ladder_contract.py`.

## Simulazioni

Campagna intera nella UI vera (`campaign_sim.gd`, seed fissi, profilo pulito),
fino all'Assenza. Stili: `prudente` incassa alla terza arena; `bando` rilancia
finche' non raggiunge la quota, ricolpisce il sigillo se la posta e' sotto 6;
`bando senza colpi` come il precedente senza colpi in piu'; `inchino` come
`bando` ma abbassa sempre lo sguardo con la gradinata. Tutti comprano al banco.

| Stile | Percorsi all'Assenza | Percorsi a 0 Gloria | Gloria mediana alla quietanza | Bandi chiusi | Gradino 8 al percorso | Scala completa al percorso | Conto minimo / massimo |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Prima del bando (leggi la folla) | 49 | 27% | 13,5 | - | - | - | -12 / 20 |
| Prudente | 45 | 16% | 20 | 11 | 27 | no (11 su 12) | 5 / 70 |
| Bando | 45 | 42% | 21 | 12 | 18 | 32 | -9 / 59 |
| Bando senza colpi | 43 | 21% | 25,5 | 16 | 10 | 24 | -5 / 103 |
| Inchino | 50 | 46% | 21 | 10 | 37 | no (10 su 12) | -20 / 17 |

Tutti gli stili arrivano agli otto racconti prima del congedo; la campagna
resta fra 43 e 50 percorsi.

## Tarature fatte durante le prove

1. **Meta' quietanza sotto bando, tolta.** La prima versione versava solo meta'
   quietanza a chi mancava il bando: il conto restava fermo a -20 per decine
   di percorsi. Mancare il bando ora costa solo il gradino.
2. **Catena per sigillo, non per colpo.** Contando ogni colpo retto, dalla
   seconda arena la posta valeva x3: Gloria mediana 28 contro 7 e scala chiusa
   in 17 percorsi. Ora un'arena e' un anello; i colpi in piu' ne condividono il
   moltiplicatore.
3. **Scala piu' ripida.** Quote da 10 a 42 (prima 8-24) e scadenza che si
   allunga ogni tre gradini, fino alla settima arena.

## Punti aperti per il playtest

- Chi ricolpisce spesso il sigillo chiude meno bandi di chi si ferma: la
  catena premia la costanza piu' dell'azzardo sul singolo sigillo.
- Chi si inchina sempre alla gradinata finisce in debito (rivolte): era cosi'
  anche prima del bando, il bando non lo aggrava.
- I giocatori bravi accumulano Denari (fino a 70-100): il banco ha poco da
  vendere a quel punto.
- Le simulazioni non sostituiscono il playtest umano.
