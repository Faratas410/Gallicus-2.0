# Manifesto - prima implementazione materiale

8 ottobre 2026. Patch circoscritta approvata dall'utente dopo le catture in
`docs/support/manifesto_scope_2026-10-08.md`. Prove visuali e runtime solo
in italiano, come richiesto; nessuna rimozione delle traduzioni EN/ES.

## Risultato e perimetro

La decisione sulla posta conserva numero dominante, arena aperta, posizione
e dimensioni dei comandi, font e copy. Cambiano pigmenti, margini e stati.

- Palette comune in `scripts/ui/manifesto_palette.gd`: inchiostro `191917`,
  avorio `e7ddc5`, cera `792d26`. Il fascicolo usa lo stesso pigmento per
  l'impronta gia' esistente; il resto del fascicolo resta invariato.
- Poche incisioni deterministiche sui margini sostituiscono la dentellatura
  continua. Contorno ridotto da 5 a 2 px, centro delle superfici calmo.
- Descrizioni allineate in alto, con inizio a 64 px dal bordo del comando.
  Il Label riempie verticalmente il contenitore: impostare il solo allineamento
  del testo non bastava, perche' il contenitore centrava il Label corto.
- Hover: linea interna; focus: linea inferiore; pressed: campitura variata
  e contorno interno. Nessun cambio di scala o posizione.
- Blocco: due barre nel margine dell'oggetto e motivo scritto. Conferma:
  tre tagli piu' larghi riempiti dal metadato autorevole gia' esistente.
  Il loro numero rimane indipendente dai Segni.

RunManager, GameEvents, gameplay, save, audio, fondali, font e cataloghi
non sono modificati da questo pass. Firma, patto, giudizio, Gradinata,
menu e Archivio conservano il lavoro preesistente.

## Fixture e perimetro linguistico

`tools/counter_layout_capture.gd` usa temporaneamente solo IT di default.
L'opzione `--all-languages` conserva la possibilita' di ripetere IT/EN/ES,
senza eseguirla in questo pass; `--capture-dir=` permette evidenze separate.
I controlli statici di integrita' dei file di traduzione rimangono nel
playbook, ma non costituiscono una prova visuale o di interazione EN/ES.
Il target di release trilingue resta invariato.

La posta a quattro cifre ora ricostruisce il payload dallo stato predisposto
e aggiorna il rail. L'importo incassabile proviene dalla factory esistente,
quindi puo' differire dalla posta per i modificatori attivi. Lo stato torna
a 4 e Pressione 0 prima delle immagini con impronta registrata.

La fixture aggiunge input mouse sul testo della nota: hover e pressione
raggiungono il Button sottostante, poi il rilascio all'esterno annulla il
gesto senza inviare un intento. Controlla anche padding inferiore e ripristino
esatto degli anchor/offset HUD all'uscita dalla decisione. La prova del flow
resta separata nelle route smoke.

Una prima esecuzione ha catturato il layout iniziale prima dell'assestamento
dei minimi nativi su un frame lento e ha segnalato overflow. La cattura ora
attende tre process frame oltre al timer; i controlli non sono stati rimossi.
Log del tentativo conservati con prefisso `layout_first_attempt`.
Non e' stata stabilita la causa del rallentamento del primo avvio.

## Evidenze e verifiche

Directory: `artifacts/manifesto_material_2026-10-08/`.
HEAD `da99a64c7d90341ac57f3ad0e4cad7444f6bfa02`, main locale dirty;
134 voci nello status iniziale. Snapshot dei tre file modificati preesistenti
in `before/`; hash e diff del nuovo pass in `candidate_manifest.json` e
file `.diff`. Galleria prima/dopo in `index.html`.

- Import Godot 4.6.2: PASS.
- Playbook statico completo: PASS.
- Matrice italiana 1280x720/1920x1080: 46 PNG, nessun errore geometrico,
  exit 0; esecuzione finale in 38.8 secondi.
- KEYBOARD_FULL_RUN, ROUTE_CASHOUT, ROUTE_DOUBLE, ROUTE_CONDANNA: PASS,
  profili isolati, diagnostica Windows. Log e summary distinti per route.
- Matrice visuale: teardown pulito. La riga "forcing new run while flow
  is active" corrisponde al riavvio della fixture da 720p a 1080p.
- Smoke: il validator funzionale passa e i processi escono con codice 0,
  ma i log runtime completi riportano ObjectDB leaked all'uscita in tutte
  le quattro route. Risorse ancora in uso: keyboard 1, cashout 6, condanna 7;
  double riporta il solo warning ObjectDB. Compaiono dopo
  `SMOKE:QUIT_REQUESTED reason=smoke_gate_complete`, senza script error
  durante le route. La stessa categoria e' gia' presente nel precedente
  `artifacts/manifesto_2026-10-08/keyboard.log` (3 risorse). La causa e la
  variazione dei conteggi non sono isolate: non dichiarare teardown smoke
  pulito, ne' attribuire tutti i casi alla patch. Nessun cambio del lifecycle
  per nascondere l'avviso; resta un limite diagnostico distinto dal PASS.
- Riferimenti docs, mojibake e diff controllati alla consegna.

Contrasto calcolato sui pigmenti sRGB uniformi: avorio/inchiostro 13.03:1,
avorio/cera 7.01:1, avorio/cera premuta 5.44:1, inchiostro/carta bloccata
9.48:1. Sono controlli delle coppie effettive, non una certificazione
complessiva di accessibilita' o leggibilita' del gioco.

Dieci immagini finali aperte e ispezionate, tutte in `layout/`:
`receipt_it_1280x720.png`, `blocked_it_1280x720.png`,
`receipt_registered_it_1280x720.png`, `double_pressed_it_1280x720.png`,
`double_hover_it_1280x720.png`, `incision_registered_it_1280x720.png`,
`pressure_large_stake_it_1280x720.png`, `dossier_CASHOUT_it_1280x720.png`,
`receipt_it_1920x1080.png`, `blocked_it_1920x1080.png`.
Il confronto prima/dopo usa la posta 4, IT e stessa risoluzione. Le fixture
di patto/fascicolo possono avere offerte diverse e non vanno presentate
come confronto dello stesso contenuto. La reference rimane quella approvata
in `artifacts/manifesto_2026-10-08/selected_reference.png`.

## File di questo pass

- `scripts/ui/manifesto_verdict.gd`: palette, margini, note e stati reattivi.
- `scripts/ui/manifesto_palette.gd` e UID: pigmenti condivisi.
- `scripts/ui/registry_imprint.gd`: colore comune nel fascicolo.
- `tools/counter_layout_capture.gd`: default IT, dati coerenti, input e verifiche.
- `docs/art_direction.md`, `docs/layout_rules.md`, `docs/canon/UI_CANON.md`:
  presentazione effettiva.
- `docs/direction.md`: raccordo delle regole precedenti di colore e HUD.
- `docs/testing.md`: ambito linguistico temporaneo delle prove.
- `docs/README.md`, `docs/development_plan.md` e questo report: stato e consegna.

Consegna locale senza commit, push o pubblicazione. EN/ES, revisione umana
del tono e della leggibilita', uniformazione delle altre fasi e checkpoint
Linux rimangono aperti. Core Playable Candidate invariato.
