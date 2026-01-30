🟡 GALlicus — GOLDEN CHECKLIST (Codex Edition · Level 3)

Questa checklist definisce i limiti di sicurezza entro cui Codex può operare.
Non è un elenco di divieti assoluti, ma di invarianti da rispettare.

Se una patch li viola, la patch va fermata e segnalata.

1. INVARIANTI TECNICI (NON NEGOZIABILI)

Engine: Godot 4.6

Linguaggio: strict typed GDScript

Zero warnings (warnings = errors)

Entry point: res://scenes/Main.tscn

Deve avviarsi senza errori

Un solo RunManager

path: res://scripts/systems/run_manager.gd

group: run_manager

❌ Nessun RunManager duplicato o alternativo

GameEvents

deve esistere

deve essere Autoload

nessun event bus alternativo

2. INVARIANTI DI ARCHITETTURA (LEVEL 3)

UI è reattiva, non decisionale

la UI mostra stato

non decide outcome

La logica di gioco:

NON vive nella UI

NON vive nell’arena

L’arena è solo rituale visivo

può animare

non governa il flow

Node groups ammessi:

run_manager

arena (visual only)

player (passive / visual)

enemies (passive / visual)

3. INVARIANTI DI FLOW

Nessuno stato deve lasciare lo schermo “vuoto”

Ogni azione dell’utente deve:

produrre feedback visivo o testuale

portare a uno stato successivo

❌ Dead-end vietati

Se qualcosa “non succede”:

è un problema di flow o di evento

non di layout

4. PATCH DISCIPLINE (FONDAMENTALE)

Una task = una patch

La patch deve essere:

minimale

localizzata

comprensibile

❌ No refactor “già che ci sono”

❌ No pulizie strutturali non richieste

❌ No rinomine arbitrarie

✅ Meglio una patch incompleta che una patch invasiva

5. COSA È CONSENTITO

Codex PUÒ:

sistemare errori runtime

correggere path, segnali, init order

ripristinare UI o flow mancanti

rimuovere riferimenti legacy solo se richiesto

aggiungere micro-feedback (testo, stato disabled)

Codex NON DEVE:

reinterpretare il design

“migliorare” il gioco di propria iniziativa

aggiungere feature non richieste

cambiare struttura delle scene senza richiesta esplicita

6. REGOLA DI PRUDENZA

Se una modifica:

tocca più sistemi

richiede refactor

rompe una invariante

non è chiaramente motivata dal sintomo

👉 STOP. REPORT. NON AGIRE.

7. PRINCIPIO GUIDA

Gallicus non deve diventare “più complesso”.
Deve diventare più coerente.
