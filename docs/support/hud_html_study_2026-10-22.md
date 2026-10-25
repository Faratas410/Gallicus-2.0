# Studio HTML: fascia di stato superiore

Proposta richiesta il 22 ottobre 2026, da valutare prima dell'integrazione in
Godot. Il prototipo riguarda soltanto la schermata Incasso/Rilancio.
Non sostituisce le regole di layout correnti o il kit Manifesto del runtime.

## Apertura e file

Aprire `tools/prototypes/gallicus-hud/index.html` nel browser: funziona anche
direttamente da disco, senza dipendenze di rete. Server locale facoltativo:
`node tools/prototypes/gallicus-hud/serve.cjs`, su `http://127.0.0.1:8767`.

- `index.html`: struttura, fascia, obiettivo, azioni e dialogo Segni.
- `style.css`: palette Manifesto, barre, stati e layout responsive.
- `app.js`: tre fixture e interazioni dimostrative, senza persistenza.
- `serve.cjs`: anteprima HTTP limitata alla cartella, solo loopback.
- `assets/arena.png`: copia di `assets/ui/generated/arena_illustrated_sample.png`.
- `assets/LibreBaskerville.ttf`: copia del font del progetto in
  `assets/ui/official/typography/LibreBaskerville.ttf`.
- `evidence/`: catture del browser del prototipo.

## Direzione proposta

Pressione e Favore diventano barre segmentate, con etichetta e valore.
Gloria in posta, Catena, Denari e Segni occupano posizioni stabili nella fascia
superiore. Una seconda riga contiene arena, Bando e stato della gradinata.
La superficie centrale conserva l'arena. Quietanza e seconda incisione
condividono geometria, gerarchia, bordi incisi e comportamento del focus;
carta/inchiostro e cera distinguono chiusura ed esposizione.

La barra del Bando rappresenta la posta rispetto alla quota, non certifica
che il Bando sia gia' chiuso: occorre incassare. Segni e valute non diventano
barre HP. Le soglie di campagna restano assenti.

## Interazioni e limiti

Il footer esterno alla composizione gameplay permette di selezionare
Equilibrio, Pressione alta e Incasso bloccato. I pulsanti mostrano un feedback
locale di quietanza o rilancio; il rilancio incrementa soltanto la barra
dimostrativa. Ripristina ritorna alla fixture iniziale. Il dialogo Segni si
apre dal contatore e si chiude con il pulsante o Escape.

Tutti i valori, inclusi i massimi delle barre, sono fixture illustrative.
Nessun collegamento a RunManager, GameEvents, salvataggi, RNG o economia.
Nessuna nuova regola o ricompensa. Il prototipo e' soltanto in italiano;
EN/ES, integrazione Godot, Linux e accettazione umana non sono verificati.
La composizione e la nuova microcopy rimangono proposte da approvare.

## Verifica locale

Candidato: HEAD `b81a4fc00797be0b0f0b7dd68639e309f3db061c`, working tree gia'
modificato prima dell'intervento. Nessun file runtime modificato in questo
studio. Font e sfondo copiati senza modificare gli originali.

- PASS: sintassi JavaScript con `node --check`.
- PASS: riferimenti documentali, scansione mojibake e `git diff --check`.
- PASS: rendering browser a 1280x720 e 1920x1080, pagina interamente contenuta
  senza scorrimento; catture `hud-1280x720.png` e `hud-1920x1080.png`.
- PASS: scenari alta pressione e blocco; quietanza disabilitata con causa.
- PASS: rilancio 9 -> 10, feedback di incasso da tastiera, ripristino.
- PASS: dialogo Segni, focus iniziale e chiusura con Escape.
- PASS: console browser senza errori o warning.
- Verifica aggiuntiva a larghezza 390: layout a colonna con scorrimento verticale.
- Il primo avvio HTTP in sandbox non era raggiungibile; il server loopback
  avviato con il permesso necessario ha reso disponibile l'anteprima.

Valutare questa singola schermata prima di propagare la fascia alle altre fasi.
