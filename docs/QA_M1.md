# QA Checklist — M1 (Vertical Slice)

## Scenario 1 — Run senza cicatrici
- Completa 5+ arene senza subire condanne.
- Chiudi la run quando l'incasso è disponibile.

**Expected**
- 0 scars attive.
- Ending coerente con run “pulita” (es. **THE_SURVIVOR** o **THE_PRUDENT**).
- UI scars vuota ma visibile.

## Scenario 2 — Run con 3+ cicatrici
- Accumula almeno 3 cicatrici (fisiche o sociali).
- Verifica che ogni scar abbia tag visivo + descrizione.

**Expected**
- Ending coerente con run “segnata” (es. **THE_BROKEN** / **THE_BRUISED**).
- Lista cicatrici aggiornata e tooltip leggibile.

## Scenario 3 — Double-or-Die usato e fallito
- Seleziona **DOUBLE_OR_DIE** almeno una volta.
- Fallisci la scommessa.

**Expected**
- Ending dedicato **THE_FOOL**.
- Epilogo coerente con la condanna.

## Scenario 4 — Scar blocca una bet
- Applica una scar che blocca una bet (es. **OPEN_WOUND** → blocca **BLOOD_TAX**).
- Apri la schermata scommesse.

**Expected**
- Bet bloccata assente dall’offerta.
- Pool ruota senza ripetere sempre le stesse 3.

## Scenario 5 — Seed repeatability
- Imposta un seed fisso (debug) e ripeti 2 run.

**Expected**
- Stessa sequenza di bet/arena/profili nemici.
- Esiti coerenti a parità di scelte.
