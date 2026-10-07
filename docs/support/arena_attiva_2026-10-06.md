# Arena attiva - 6 ottobre 2026

Origine: Marco ha giocato la build Windows del 6 ottobre (loop rivisto, PR
#538) e l'ha trovata "troppo passiva". Base: `main` a `2dfee1a`.

## Diagnosi

Un'arena dopo il primo percorso:

| Momento | Cosa fa il giocatore | Cosa sa quando decide |
| --- | --- | --- |
| Registro: scegli uno di due patti | decide | solo il profilo della famiglia |
| Tavoletta del patto | guarda | - |
| Gesto | decide | niente di nuovo rispetto alla firma |
| Sigillo: un colpo | preme, ma non conta | - |
| Responso (un tiro nascosto) | guarda | - |
| Incassa o rilancia | decide | l'esito appena visto |

- Le decisioni prima dell'esito erano prese al buio: fra firma e responso non
  si scopriva nulla.
- Il momento piu' drammatico era vuoto: l'esito era un solo tiro dopo il
  sigillo (`resolve_level3_arena`) e il colpo non contava.
- La folla cambiava umore ma non chiedeva mai niente.

## Proposte e scelta

Proposte: A sigillo a colpi, B presagio prima del gesto, C la gradinata
chiede, D Segni da mostrare, E meno attesa. Consigliate A + C; Marco ha scelto
tutte e cinque. Regole in `docs/canon/MECHANICS_UNIFIED.md`, sezione "Arena
attiva (ottobre 2026)".

## Simulazioni

Motore reale (Godot 4.6.2), pulsanti della UI, esiti veri, solo il tempo
accelerato; stessa scelta dei patti del contratto di campagna (preferenza per
Hybris e Violenza), quietanza alla terza arena.

Prima tornata, solo A + C:

| Stile al sigillo | Richieste della folla | Percorsi all'Assenza | Gloria media | Percorsi con 2 Gloria o meno |
| --- | --- | --- | --- | --- |
| Alza sempre la mano dopo il primo colpo | ignorate | 45 | 4,7 | 23 su 45 |
| Colpisce ancora se la posta e' sotto 6 | ignorate | 45 | 5,0 | 27 su 45 |
| Colpisce sempre tre volte | ignorate | 45 | 3,2 | 35 su 45 |
| Colpisce ancora se la posta e' sotto 6 | accontentate | 46 | 7,5 | 22 su 46 |

Seconda tornata, A-E (presagio, Segno mostrato e attese corte inclusi; il
Segno si mostra quando la posta e' alta):

| Stile al sigillo | Richieste della folla | Percorsi all'Assenza | Gloria media | Percorsi con 2 Gloria o meno |
| --- | --- | --- | --- | --- |
| Alza sempre la mano dopo il primo colpo | ignorate | 45 | 5,4 | 16 su 45 |
| Colpisce ancora se la posta e' sotto 6 | ignorate | 45 | 9,4 | 12 su 45 |
| Colpisce sempre tre volte | ignorate | 46 | 2,0 | 40 su 46 |
| Colpisce ancora se la posta e' sotto 6 | accontentate | 46 | 8,0 | 16 su 46 |

Lettura:

- Colpire sempre tre volte e' la strategia peggiore; fermarsi sempre e'
  prudente ma rende poco; osare quando la posta e' bassa rende di piu'. Il
  sigillo e' una scelta di rischio vera, senza strategia dominante.
- L'effetto delle richieste della folla oscilla fra le due tornate (+50% e
  -15%): con una campagna per stile la varianza e' alta. Da misurare nel
  playtest e con piu' campagne.
- La durata della campagna non cambia (45-46 percorsi).
- La seconda tornata ha trovato un blocco: un sigillo incrinato al terzo colpo
  con un Segno disponibile non accettava `LASCIA CEDERE`. Corretto prima della
  build.

Da misurare nel playtest umano: se colpire ancora e' abbastanza tentante, se
la richiesta della folla si legge in tempo sulla pagina del Registro, se il
presagio cambia davvero il gesto, e se il ritmo dell'arena resta sotto i 15
secondi.

## Impatto (seconda richiesta)

Dopo la build A-E Marco ha scritto che il game feel resta passivo. Primo
passo, comune a tutte le direzioni proposte: impatto sui gesti (scossa,
lampo, schegge di cera e cenere) in `scripts/ui/impact_feedback.gd`, regole in
`docs/canon/UI_CANON.md`, sezione "Impact feedback". Solo presentazione:
esiti e simulazioni non cambiano.

## Scambi con la gradinata (terza richiesta)

Marco: "Qualcosa tipo il 3 misto al 2. Il player deve attivarsi, ora il gioco
sembra senza conseguenze" (3 = tenere la folla, 2 = duello a turni con mosse
annunciate). In arena non si combatte, quindi l'avversario e' la gradinata.
Il gesto diventa tre scambi; la folla annuncia cosa sta per fare e le due
risposte stampano il prezzo esatto. Il favore e' l'umore della folla che
esisteva gia' (`audience_score`), ora visibile. Sostituisce la richiesta della
gradinata (C) e il presagio della cera (B). Regole in
`docs/canon/MECHANICS_UNIFIED.md`, sezione "Arena attiva (ottobre 2026)".

Simulazioni nel motore reale, stesso contratto di campagna, colpisce ancora se
la posta e' sotto 6:

| Risposte agli scambi | Percorsi all'Assenza | Gloria media | Percorsi con 2 Gloria o meno | Trionfi | Rivolte | Segni a fine percorso |
| --- | --- | --- | --- | --- | --- | --- |
| Abbassa sempre lo sguardo | 45 | 7,5 | 16 | 1 | 63 | 2,2 |
| Sfida sempre (prima del ritocco) | 37 | 9,8 | 16 | 46 | 0 | 2,3 |
| Legge la folla (prima del ritocco) | 43 | 9,6 | 14 | 42 | 0 | 1,6 |
| Sfida sempre | 35 | 9,4 | 14 | 22 | 9 | 2,7 |
| Legge la folla | 45 | 9,4 | 17 | 47 | 0 | 1,7 |

Lettura:

- Abbassare sempre lo sguardo fa rivoltare la folla quasi a ogni percorso e
  rende meno: la prudenza ha un prezzo visibile.
- Sfidare sempre rendeva quanto leggere la folla. Ritocco: sfidare la folla
  che trattiene il fiato costa Favore -2 e Pressione +1 (prima Favore -1).
  Ora sfidare sempre rende uguale ma porta rivolte e un Segno in piu' a
  percorso: lo stile si paga sul corpo.
- Il trionfo arriva circa una volta a percorso a chi legge la folla.
- La campagna resta fra 35 e 46 percorsi.

Da misurare nel playtest umano: se gli scambi si leggono in fretta, se tre
scambi per arena sono troppi, e se il favore si sente sul sigillo.

## Economia di fondo (7 ottobre 2026)

Marco: "Crea un'economia di fondo nel gioco, in modo che ci sia un sistema che
premi o punisca il giocatore". Scelta sulla scheda: "Entrambi", cioe' un conto
che passa da un percorso all'altro e si spende dentro il percorso. Regole in
`docs/canon/MECHANICS_UNIFIED.md`, sezione "Economia di fondo (ottobre 2026)".

Simulazioni nel motore reale, folla letta, colpisce ancora se la posta e' sotto
6; con acquisti: assicura la posta quando e' almeno 6, compra favore sotto +2,
paga la Pressione da 3 in su.

| Stile | Percorsi all'Assenza | Gloria media | Percorsi con 2 Gloria o meno | Denari guadagnati / persi | Conto finale | Percorsi chiusi in debito |
| --- | --- | --- | --- | --- | --- | --- |
| Folla letta, non compra mai | 45 | 7,0 | 24 | 204 / 40 | +164 | 3 |
| Folla letta, compra al banco | 49 | 9,3 | 18 | 319 / 317 | +2 | 13 |
| Abbassa sempre lo sguardo, compra | 47 | 7,7 | 18 | 119 / 374 | -255 | 46 |

Lettura:

- Spendere al banco rende circa un terzo di Gloria in piu' e tiene il conto
  vicino allo zero: il denaro e' una scelta, non un tesoro.
- Chi non spende accumula senza vantaggio: e' una scelta possibile ma vuota.
- Chi abbassa sempre lo sguardo scivola in un debito senza fondo. Correzione
  dopo la simulazione: il debito si ferma a -20 Denari, cosi' la campagna puo'
  sempre risalire.
- La durata della campagna resta fra 45 e 49 percorsi.

Da misurare nel playtest umano: se il banco si nota prima di aprire il
Registro, se i prezzi sono giusti e se il debito si sente come punizione e non
come blocco.
