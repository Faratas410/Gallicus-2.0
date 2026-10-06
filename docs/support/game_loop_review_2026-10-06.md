# Revisione del game loop - 6 ottobre 2026

Base: `main` a `023d12b` (dopo il rework, PR #537). Prove: lettura di
`RunManager`, `OutcomeSystem`, `BettingPolicy`, `RegistryEvolution` e tre
campagne simulate nel motore reale (Godot 4.6.2, pulsanti della UI, esiti veri,
solo il tempo accelerato) con tre stili di gioco:

| Stile | Percorsi simulati | Arene per percorso | Gloria media | Percorsi con 2 Gloria o meno | Silenzi |
| --- | --- | --- | --- | --- | --- |
| Marchio subito all'arena 1 | 164 | 1,0 | 0 | 164 su 164 | 3 (percorsi 91, 99, 164) |
| Quietanza appena possibile | 34 | 5,1 | 8,9 | 17 su 34 | 0 |
| Quietanza fra arena 5 e 7 | 31 | 5,6 | 8,4 | 17 su 31 | 0 |

## Il loop com'è oggi

Arena: apri il Registro, firma uno di due patti, `MOSTRA IL PATTO`, gesto
davanti alla gradinata, tre colpi al sigillo, responso, poi quietanza, marchio
o raddoppio. Otto input, circa 15 secondi.

Percorso: da 5 a 8 arene (numero estratto e nascosto). La quietanza si apre
solo dall'arena 5; all'ultima arena il raddoppio è bloccato.

Campagna: a fine percorso il Registro calcola una firma nascosta; il Silenzio
arriva quando la firma è coerente e stabile per più percorsi. Quattro Silenzi
portano all'Assenza.

## Problemi, in ordine di gravità

### 1. Chi gioca bene non finisce mai il gioco

La firma si fissa solo se la coerenza supera 0,72
(`scripts/systems/run/registry_evolution.gd`, `coherence`). Con un solo patto
per percorso la coerenza arriva a 0,75; con cinque patti scelti fra offerte
casuali resta quasi sempre sotto 0,3. Risultato: 0 percorsi su 65 giocati fino
alla quietanza hanno fissato la firma, nessun Silenzio. L'unica strada verso
l'Assenza è chiudere col marchio all'arena 1 per circa 170 volte, con Gloria
zero. È anche la strategia che usa il test di campagna di riferimento
(`scripts/ci/campaign_runtime_contract.gd`). Il gioco premia il non giocare.

### 2. La Gloria del percorso dipende solo dall'ultimo sigillo

Le vittorie delle arene 1-4 non mettono nulla in posta: all'incasso conta il
numero di raddoppi più il patto dell'ultima arena, e solo se quell'ultimo
sigillo ha retto. Se cede, incassi 1-2 Gloria dopo cinque arene. Metà dei
percorsi giocati finisce con 2 Gloria o meno. Andare oltre l'arena 5 non rende
di più (14-23 Gloria in entrambi gli stili) ma rischia di più.

### 3. Nelle arene 1-4 non c'è una vera scelta

Prima dell'arena 5 la quietanza è chiusa: restano `RADDOPPIA` (che in realtà
significa "prosegui") e il marchio (chiudi con zero). Un sigillo che cede non
chiude il percorso: lascia un segno e azzera il moltiplicatore. Il giocatore
non sa quante arene mancano perché il totale è nascosto.

### 4. I patti si distinguono poco

Tutti i patti hanno la stessa probabilità di reggere. Cambiano solo
moltiplicatore (1x o 2x) e segno in caso di fallimento; i 21 patti ricadono in
5 comportamenti e quasi tutti i nuovi hanno lo stesso segno (Ossa incrinate).
Uno dei patti si chiama ancora `CASH_OUT`, come la quietanza.

### 5. Il gesto è quasi sempre la stessa scelta

`ABBASSA LO SGUARDO` toglie Pressione senza costo. `SFIDA LA GRADINATA` alza la
Pressione e dà al massimo 1-2 Gloria all'incasso. Il fallimento previsto per
la sfida non si attiva mai (`provoke_armed` non viene mai acceso in
`run_manager.gd`).

### 6. Attrito ripetuto

`MOSTRA IL PATTO` fa rileggere ciò che hai appena firmato e i tre colpi del
sigillo non cambiano l'esito: tre input su otto, a ogni arena.

## Proposta: loop rivisto

Resta tutto ciò che `docs/direction.md` tiene fermo: RunManager unica
autorità, nessuna nuova economia (si usano Gloria, Pressione, Segni e posta
già esistenti), firma ed Ere nascoste, timing del sigillo senza effetto.

A. **Posta che cresce.** Ogni sigillo che regge aggiunge Gloria alla posta in
   base al patto firmato. Se cede, la posta si dimezza e resta un segno.
   `RADDOPPIA O MUORI` cede tutto e chiude il percorso.

B. **Quietanza sempre possibile.** Dopo ogni responso scegli: incassa la posta
   o rilancia. Il percorso ha un limite visibile (per esempio 7 arene) al posto
   del numero nascosto. Il marchio compare solo quando la folla blocca la
   quietanza, come uscita a mani vuote.

C. **Patti con un profilo leggibile.** Le quattro famiglie cambiano davvero il
   rischio: Prudenza regge spesso e rende poco, Hybris regge di rado e rende
   molto, Violenza rende molto ma lascia sempre un segno se cede, Penitenza
   rende poco e abbassa la Pressione. Sulla pagina del Registro il rischio è
   scritto a parole (regge spesso, a volte, di rado), senza percentuali.

D. **Gesto come scambio.** Sfidare alza Pressione e posta; abbassare lo
   sguardo abbassa entrambe.

E. **Campagna che avanza giocando.** La firma si calcola sulle scelte del
   percorso (famiglia dei patti, gesto, incasso o rilancio) in proporzione,
   così uno stile coerente converge anche in percorsi lunghi. I percorsi chiusi
   all'arena 1 col marchio non contano come prova per il Silenzio. Obiettivo:
   circa 25-35 percorsi per l'Assenza, cioè 2-3 ore.

F. **Ritmo.** `MOSTRA IL PATTO` solo nel primo percorso, poi la tavoletta
   passa da sola. Tre colpi al sigillo nei primi percorsi, poi uno.
   Risultato atteso: circa 5 input e 10 secondi per arena.

Questa proposta chiude anche la scelta lasciata aperta dal rework su
`MOSTRA IL PATTO` (punto F).

## Cosa cambia nel canon

A, B, C e D cambiano `docs/canon/MECHANICS_UNIFIED.md` (posta, quietanza,
gesto, profilo dei patti). E cambia `docs/canon/REGISTRY_SYSTEM_SPEC.md` (regole
del Silenzio). F cambia `docs/canon/RUN_ARCHITECTURE_CANON.md` solo per il
salto della tavoletta; le fasi restano le stesse. Ogni passo si verifica con
smoke, contratto di campagna aggiornato e le stesse simulazioni di questa
revisione.

Restano umani: la durata reale della campagna, il bilanciamento fine delle
probabilità e la sensazione di rischio, da misurare in un playtest.

## Esito: proposta applicata per intero

Marco ha scelto tutti e sei i punti il 6 ottobre 2026. Regole e numeri vivono
nel canon: `docs/canon/MECHANICS_UNIFIED.md` ("Loop rivisto (ottobre 2026)"),
`docs/canon/REGISTRY_SYSTEM_SPEC.md` ("Evidenza e chiusura delle Ere"),
`docs/canon/RUN_ARCHITECTURE_CANON.md` ("Loop rivisto - 2026-10-06").

Differenze rispetto alla proposta, emerse dalle simulazioni:

- La posta cresce anche con la profondità: +1 Gloria per ogni arena già
  superata. Con guadagni fissi il valore atteso restava piatto dopo la terza
  arena e rilanciare non conveniva mai.
- La campagna chiude l'Era anche per esaurimento (12/11/10/9 percorsi di
  evidenza) quando la firma non si stabilizza: senza questo tetto uno stile
  misto non arrivava mai al Silenzio.
- Il marchio resta come uscita quando la quietanza è bloccata (folla in furia,
  arena del disprezzo, Decima di Sangue).

### Simulazioni sul loop rivisto

Stesso metodo della revisione: motore reale, pulsanti della UI, esiti veri,
solo il tempo accelerato. Le policy scelgono i patti come il contratto di
campagna (preferenza per Hybris e Violenza).

| Stile | Percorsi all'Assenza | Silenzi | Arene per percorso | Gloria media | Firma fissata |
| --- | --- | --- | --- | --- | --- |
| Quietanza alla terza arena, gesto alternato | 45 | 13, 24, 34, 45 | 3,7 | 6,9 | no (chiusura per esaurimento) |
| Quietanza fra quinta e settima | 45 | 13, 24, 34, 45 | 5,4 | 4,0 | no |
| Coerente: patti rischiosi e sfida | 38 | 12, 20, 27, 38 | 3,9 | 4,6 | sì, dal secondo percorso |
| Quietanza alla prima arena | mai (59 percorsi, Era 0) | nessuno | 1,4 | 2,9 | no |

Chiudere subito non porta più alla fine; giocare porta all'Assenza in 38-45
percorsi, e uno stile coerente ci arriva prima. Il contratto di campagna
(`scripts/ci/campaign_runtime_contract.gd`) percorre ora percorsi veri e
raggiunge l'Assenza in 45 percorsi.

Punto aperto per il playtest: con queste policy un terzo dei percorsi finisce
con `RADDOPPIA O MUORI` ceduto (percorso chiuso a zero). Le policy lo firmano
ogni volta che compare perché preferiscono l'Hybris; un giocatore che legge
"Regge di rado" probabilmente no. Durata reale, probabilità e frequenza di
questo patto vanno misurate con sessioni umane.
