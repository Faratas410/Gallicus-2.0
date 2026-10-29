# Banco e Incasso/Rilancio nella famiglia del Registro

Seguito autorizzato del pass Patto/Gradinata/Rito. Candidato locale su main,
HEAD b81a4fc00797be0b0f0b7dd68639e309f3db061c, con modifiche precedenti
preservate e senza commit. Questo pass chiude due famiglie dell'inventario
visivo; le otto famiglie di consultazione e ingresso restano aperte.

## Presentazione

- Banco: bando su carta, servizi in tre ricevute verticali. Titolo e prezzo
  condividono una riga; gli effetti restano completi, compresa l'esclusione
  della Via dell'Hybris. L'assicurazione ha una ricevuta piu alta. Blocco e
  focus sono segni sulla superficie. Apri il Registro e inciso sulla copertina.
- Incasso/Rilancio: arena pixel art comune sotto l'HUD, nuova Vessa aviana,
  importo e battuta su carta. Quietanza, medaglione di cera e marchio su ferro
  conservano target nativi, stati, testi e conseguenze del payload.
- Fondamento e pigmento seppia sono riservati alla carta; iscrizioni su cera,
  ferro e insegne mantengono il carattere di display. Le superfici delle azioni
  restano frontali e ferme, cosi la scrittura non scorre rispetto al supporto.
- Restano conteggio della posta, impronta di registrazione attraverso la
  transizione, doppia incisione, focus da tastiera e movimento ridotto.
  Il pubblico pixel art e parte del fondale; moti e reazioni della precedente
  folla dipinta non vengono sovrapposti. Restano particelle ambientali discrete.

RunManager conserva acquisti, disponibilita, importi, esiti e flusso. Non
sono cambiati dati, salvataggi, segnali, testi di traduzione o regole economiche.
Registro aperto e animazione di firma restano quelli approvati.

## Asset e file

Due originali ImageGen con alpha conservato: `banco_verdict_pixel.png` e
`vessa_pixel.png`, in `assets/ui/generated/`, con import Godot. Prompt,
reference, sorgente e SHA-256 sono in `assets/ui/generated/manifest.json`.
L'atlas non ha quadranti regolari: `banco_pixel_art.gd` definisce regioni
esplicite. Il ritratto usa un file separato per evitare frammenti degli
oggetti adiacenti. Nessun testo e incorporato nei bitmap.

- Nuovi: `scripts/ui/banco_pixel_art.gd`, `banco_receipt.gd` e relativi uid;
  `tools/pixel_banco_capture.gd` e uid; i due asset con import; questo report.
- Runtime aggiornato: `scripts/ui/betting_circle_ui.gd`,
  `manifesto_verdict.gd`, `verdict_object.gd`, `verdict_atmosphere.gd`;
  `scenes/ui/BettingCircle.tscn`.
- Capture condiviso: `tools/counter_layout_capture.gd` accetta BoxContainer
  per i servizi. Il vecchio percorso registry-only verifica ancora la vecchia
  regola di selezione dei fogli: per il Registro corrente usare invece
  `registry_volume_capture.gd`; per il Banco `pixel_banco_capture.gd`.
- Documenti aggiornati: README, art_direction, layout_rules, testing,
  development_plan e inventario ui_coherence_2026-10-26.

## Verifiche locali

Godot 4.6.2 su Windows, renderer Forward+, profili APPDATA/LOCALAPPDATA
isolati sotto `artifacts/pixel_banco/`. Nessun profilo personale utilizzato.

- Banco: 18 catture IT/EN/ES, 720p/1080p, saldo negativo/zero/disponibile;
  zero fallimenti. Verificati testo entro carta, target fermi e singolo
  intento di acquisto tramite clic nativo; gli stati sintetici non sono
  prove del saldo economico.
- Incasso/Rilancio: 50 catture IT/EN/ES, 720p/1080p, zero fallimenti;
  focus, blocchi, Condanna, importo lungo, doppio clic, impronta transitoria
  e cancellazione del movimento. Verifica visiva delle viste italiane,
  della Condanna inglese e dei testi spagnoli lunghi.
- Registro: 760 controlli, zero fallimenti. Il runner segnala ancora
  ObjectDB instances leaked at exit; non e una chiusura del gate teardown.
- Percorsi reali: ROUTE_CASHOUT, ROUTE_DOUBLE, ROUTE_CONDANNA e
  KEYBOARD_FULL_RUN superati. Contratti OF-01/02/03 superati.
- Art uniformity: 253 controlli, zero fallimenti.
- Riferimenti documentali, scansione mojibake e diff check puliti.

[Galleria prima/dopo](../../artifacts/pixel_banco/index.html), summary nelle
sottocartelle `final_banco/` e `final_verdict/`, log e impronte del candidato
nella radice. Le immagini sono evidenze locali ignorate da Git.
Queste verifiche non sostituiscono Linux canonico, accettazione visiva umana,
controller fisico, audio o playtest. Nessun gate Steam viene chiuso.
