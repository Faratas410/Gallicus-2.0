# Gallicus — Game Design Status Report

## 1. Core Loop

Il loop Level 3 attuale è una sequenza chiusa e autoritativa orchestrata da `RunManager`:

1. **Pact selection**: apertura betting (`bet_ui_opened`) e selezione patto via `request_place_bet`.  
2. **Resolution**: doppio rituale (`pact_sealed`, `resolve_ritual`) e risoluzione arena.  
3. **Push Your Luck decision**: biforcazione tra `request_pyl_cashout` e `request_pyl_double`.  
4. **Escalation**: il `double` incrementa escalation; alcune scelte intermedie possono aumentarla/diminuirla.  
5. **Terminal classification**: chiusura con finale classificato (`THE_LIBERTY`, `THE_FALL`, o finali di profilo), con esclusione specifica dei casi infrastrutturali.

Questa struttura è coerente con il flow canonico Level 3 (ordine fisso e checkpoint autosave), senza autorità parallele di stato.

## 2. Risk Architecture

### Base win probability curve
La risoluzione arena parte da:
- `base_win = 0.66`
- `base_damage = 0.40`

Questi valori vengono modulati da scar attive e profilo nemico, poi clamped.

### Escalation scaling
La penalità escalation è progressiva:
- **Win penalty**: `+0.04` al livello 1, poi `+0.09` per ogni livello oltre il primo.
- **Damage penalty**: `+0.03` al livello 1, poi `+0.07` per ogni livello oltre il primo.

### Second Era difficulty shift
Quando `registry_has_precedent` è attivo (Second Era), la risoluzione usa **escalation effettiva +1** (`effective_escalation += 1`), introducendo pressione sistemica senza cambiare direttamente statistiche base del player.

### Clamp behavior
Le probabilità finali sono clampate in entrambi i sensi:
- `win_chance` in `[0.20, 0.85]`
- `damage_chance` in `[0.20, 0.85]`

Questo impedisce sia certezza di successo sia certezza di fallimento in condizioni normali.

## 3. Reward Architecture

### Coins (tactical resource)
Le coin reward sono calcolate per comportamento patto e reward tier (es. cashout `10*tier`, double-or-die `30*tier`, blood tax `26*tier`) e il cashout può essere moltiplicato da un modificatore penalizzante audience/precedent.

### Glory (run-scoped visible metric)
`glory` è metrica di run, incrementata solo a successo arena:
- `increment = GLORY_PER_SUCCESS * glory_multiplier`
- `GLORY_PER_SUCCESS = 1`

### Multiplier progression (1,2,4,7,11)
Il `glory_multiplier` segue tabella discreta autoritativa: `[1, 2, 4, 7, 11]`, aggiornata in funzione dei `double` accumulati (con saturazione all’ultimo step).

## 4. Hidden Pressure Systems

### Corruption increments
`corruption` è hidden per-run e viene alimentata da:
- tipo di patti selezionati (peso 1/2/3 in base al rischio),
- escalation corrente e massima,
- numero di doubles.

In aggiunta, il sistema registra incrementi puntuali su ingestione autorevole:
- `+1` su `double` (`CORRUPTION_DOUBLE`),
- `+1` su pacto high-risk (`CORRUPTION_PACT_HIGH`).

### FALL threshold (>=5)
La classificazione `THE_FALL` è assegnata quando `corruption >= FALL_THRESHOLD` con `FALL_THRESHOLD = 5`.

### Era shift mechanics
Il passaggio a stato con precedente è persistente (`registry_has_precedent` da unlock) e influenza:
- eleggibilità Liberty,
- pressione di generazione,
- difficoltà effettiva (escalation +1 in risoluzione),
- penalità cashout addizionale (`*0.95`) quando cashout resta consentito.

## 5. Endings Structure

### Liberty (Era 0 only)
`THE_LIBERTY` è possibile solo senza precedente (`not _registry_has_precedent`) e con vincoli runtime (`glory >= 8` e `corruption < 8`).

### The Fall
`THE_FALL` prevale quando la corruzione supera soglia (`>=5`) e la run non è di tipo infrastrutturale.

### Gameplay failures
I failure gameplay entrano nel normale path finale classificato (es. `THE_FOOL`, `THE_DEBTOR`, `THE_BROKEN`, ecc.) secondo reason/scar/escalation.

### INFRA exclusions
`INFRA_FAILURE` produce terminazione run ma viene escluso dalla classificazione `THE_FALL`.

## 6. Balance Assessment

### Streak probability
La combinazione di:
- base win 0.66,
- penalità escalation crescenti,
- clamp superiore 0.85,
- incremento difficoltà in Second Era,

mantiene le streak positive possibili ma non garantibili; il rischio cumulativo resta crescente lungo il loop.

### EV behavior
L’EV locale dei patti ad alto payout (es. double-or-die) è compensato da:
- incremento esposizione scars/damage,
- reset/penalità su loss,
- aumento corruzione e pressione su terminali.

La struttura attuale incentiva continuità aggressiva a breve, ma tende a deteriorare la qualità attesa della run sul medio periodo.

### Double viability
Il `double` resta una scelta realmente praticabile perché:
- aumenta glory multiplier in modo forte,
- mantiene spazio di agency,

ma attiva simultaneamente escalation + corruzione, quindi non è dominante in equilibrio globale.

### Risk/reward fairness
Il sistema risulta coerente con design intent “push your luck”: reward immediato visibile (coin/glory) contro costo differito hidden (corruption/escalation/ending pressure). Non emergono segnali di rottura matematica nei clamp o nelle soglie principali.

## 7. Current Loop Evaluation

### Is it mathematically stable?
**Sì, in stato attuale.** Clamp, scaling escalation e soglie terminali impediscono runaway lineare incontrollato e evitano deterministicità dura.

### Is it morally coherent?
**Sì, con il canone.** Il sistema premia il rifiuto della chiusura ma converte tale scelta in classificazione amministrativa più severa (coerenza con Registro/precedente).

### Is it psychologically tense?
**Sì.** Il contrasto tra reward immediato e pressione hidden cumulativa produce una tensione leggibile: il giocatore può “sentire” vantaggio nel breve mentre il sistema prepara un costo terminale crescente.
