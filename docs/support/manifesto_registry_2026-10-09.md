# Manifesto - Registro, banco e firma

9 ottobre 2026. Pacchetto 1 dell'ordine in
`docs/support/manifesto_remaining_screens_2026-10-09.md`, implementato sul
kit gia' presente. Consegna locale su main; Stage Core Playable Candidate.

## DIAGNOSIS

Candidato di partenza: HEAD `6f8088abb8227f4100416dd49ad7e14a606e0e85`,
21 voci locali preesistenti. Snapshot e status iniziali in
`artifacts/manifesto_registry_2026-10-09/before/files/` e
`artifacts/manifesto_registry_2026-10-09/before/status.txt`.
Il nuovo pass e' distinto dal kit e dal piano precedenti.

Le prime 46 viste della fixture corrente sono conservate in before/layout.
Il confronto finale usa 64 viste con dati identici del catalogo: la copia
isolata before/project ripristina i sorgenti iniziali, senza sostituire il
working tree; after/registry esegue il consumer nuovo. Il validator della
baseline segnala 20 problemi: quattro click sulla pagina assorbiti dal testo
e sedici controlli di testo lungo tagliato. Sono diagnosi del prima, non
fallimenti del candidato finale. Il confronto non usa catture di commit
storici o nuove offerte casuali come equivalenti.

## WORKFLOW - risultato implementato

Intento: leggere e confrontare una promessa, poi vincolarsi. Oggetto: due
documenti del Registro con cera di firma. Gesto: selezione/click o Invio.
Feedback: regola e tagli vuoti per selected, tagli pieni solo per signed,
due barre per disabled. Registrazione: feedback locale gia' esistente prima
di `request_place_bet`; RunManager mantiene la registrazione autorevole.

Il documento resta `900x540` nella composizione del banco, con due pagine
avorio, inchiostro e firma rossa. I titoli e le intestazioni usano Manifesto,
le condizioni corpo 17 px. I testi e la struttura BBCode restano quelli
esistenti. Il testo lungo scorre nel proprio RichTextLabel e torna all'inizio
al cambio offerta; la firma rimane fuori dallo scroll. Quando il testo non
scorre, ignora il mouse e rende raggiungibile il selettore di pagina sotto.
Il selettore nativo ha focus visibile; l'intera pagina non viene piu' tinta.

Orvo, Vessa, ambiente, bando e servizi restano nel Registro chiuso. Il banco
usa carta, font 15 px, wrapping e tre righe semantiche servizio/effetto/prezzo.
Il servizio lungo determina una riga uniforme di 148 px nel campione IT,
con 8 px di padding sopra/sotto. La firma resta circa `333x51`; apertura e
comandi non cambiano scala negli stati. I Label Lbl_Sign e Lbl_Open_Book
rimangono come binding nascosti; una sola CTA e' stampata dal Button nativo.

SpellbookBg diventa Panel: il precedente PanelContainer dilatava la sottile
divisione fra pagine fino a coprire il supporto. La divisione conserva ora
la sua geometria ancorata. Le vecchie risorse di scena restano fallback di
authoring; gli adattatori le sostituiscono nei soli consumer migrati.

Il kit aggiunge `apply_document`, `apply_rich_text`, `format_heading` e
`apply_page_selection`. `apply_action` mantiene compatibilita' e aggiunge
selected e body_text opzionali. Le azioni compatte condividono padding
verticale 8 px. Le superfici native ignorano input e non possiedono bus,
flow o disponibilita'. Nuova skin passiva:
`scripts/ui/manifesto_document_surface.gd`. Il campionario mostra la stessa
libreria nella sezione Registro/Banco/Firma, distinta da Posta/Fascicolo.

Contrasto calcolato sui pigmenti nominali: avorio/inchiostro 13,03:1;
avorio/cera 7,01:1. Stato, focus, selezione e blocco non dipendono dal colore.
Questa misura non sostituisce la lettura delle immagini nel contesto.

## Verifiche ed evidenze

Evidenze in `artifacts/manifesto_registry_2026-10-09/`. Manifest del working
tree, hash SHA-256 e inventario del solo pass in candidate_manifest.json;
nessun export e' stato prodotto. Profili APPDATA/LOCALAPPDATA/TEMP/TMP isolati.
Catture con renderer Compatibility, audio Dummy, processo nascosto e finestra
fuori schermo. Le prove visuali/runtime di questo pass sono soltanto IT;
EN/ES rimangono nei contratti statici e nel prodotto.

| Verifica | Risultato |
| --- | --- |
| Import Godot 4.6.2 | PASS, nessun errore script o caricamento risorsa |
| Playbook statico completo | 45/45 PASS |
| KEYBOARD_FULL_RUN | PASS, Registro/firma e ritorno al menu nel flow reale |
| CORE_CONTINUITY | PASS, continuita' e ripresa nel profilo isolato |
| Registro dedicato | 64 viste, zero errori finali di geometria/input |
| Sequenza adiacente | 46 viste, zero errori di ingombro |
| Campionario IT | 5 PNG, idempotenza/input/stati/contenimento PASS |
| Docs refs, mojibake e diff | verificati alla consegna |

La matrice Registro comprende 720p/1080p, motion normale/ridotto, apertura
hover/pressed, lock durante il reveal, banco -5/0/20, firme left/right,
selected distinto da signed, offerta mancante, testo lungo all'inizio/fine,
riapertura e transizione al Patto. Click annullato e comando disabled non
emettono intenti; il banco disponibile e la firma emettono un solo intento.
L'attivazione del banco prova il confine UI/bus: i fondi reali non vengono
aumentati dalla fixture e RunManager puo' rifiutare il servizio. La firma
tramite Invio usa le offerte reali ripristinate, chiude il Registro e libera
il focus. Le catture signed sono fixture di presentazione, non prova di save.

Ispezionate direttamente le viste a entrambe le risoluzioni: banco normale
e in debito, pagine comparabili, offerta mancante, inizio/fine dello scroll,
selected/signed, campionario e raccordo con il Patto. Le immagini della
sequenza includono anche posta/fascicolo e il ripristino HUD, per verificare
il padding comune dei comandi compatti.

Diagnostica: la matrice che termina subito dopo il Patto conserva un singolo
SceneTreeTimer al teardown, sia prima sia dopo; nessuna risorsa UI viene
segnalata in quel log verbose. La fixture completa e il campionario chiudono
senza avvisi. I due smoke hanno superato il validator, ma i log locali
segnalano ObjectDB e rispettivamente 5/7 risorse ancora in uso al termine.
Il confronto CORE_CONTINUITY iniziale ne segnalava 6; KEYBOARD iniziale non
aveva avvisi. Un probe verbose riproduce la variabilita' (4 risorse) e le
identifica come AudioStreamWAV/PlaybackWAV di condanna, route del fascicolo,
atrio e fascicolo, ancora attivi al quit immediato. Il probe verbose non e'
un PASS aggiuntivo: il validator rifiuta le righe dettagliate del teardown.
Questo pass non corregge il lifecycle audio e non chiude quel limite.

Riproduzione, dopo avere impostato i quattro profili isolati:

```powershell
python scripts/ci/run_godot_import.py --godot-bin tools/godot/Godot_v4.6.2-stable_win64_console.exe
python scripts/ci/run_testing_playbook.py --skip-import --output-dir artifacts/manifesto_registry_2026-10-09/checks/static
python scripts/ci/run_headless_smoke.py --scenario KEYBOARD_FULL_RUN --godot-bin tools/godot/Godot_v4.6.2-stable_win64_console.exe
python scripts/ci/run_headless_smoke.py --scenario CORE_CONTINUITY --godot-bin tools/godot/Godot_v4.6.2-stable_win64_console.exe
tools/godot/Godot_v4.6.2-stable_win64_console.exe --path . --rendering-method gl_compatibility --audio-driver Dummy --script tools/counter_layout_capture.gd -- --registry-only --capture-dir=res://artifacts/manifesto_registry_2026-10-09/after/registry
```

## EXPECTED HANDOFF - file del solo pass

- Runtime: `scripts/ui/betting_circle_ui.gd`, `scenes/ui/BettingCircle.tscn`,
  `scripts/ui/manifesto_kit.gd`, `scripts/ui/manifesto_action_surface.gd`,
  `scripts/ui/manifesto_document_surface.gd` e relativo `.gd.uid`.
- Fixture/campionario: `tools/counter_layout_capture.gd`,
  `tools/manifesto_kit_capture.gd`, `tools/manifesto_kit_gallery.gd`.
- Contratti statici adattati al consumer nuovo:
  `scripts/ci/test_registry_table_object_contract.py`,
  `scripts/ci/test_promise_signature_object_contract.py`.
- Owner e report: `docs/README.md`, `docs/development_plan.md`,
  `docs/art_direction.md`, `docs/layout_rules.md`, `docs/testing.md`,
  `docs/canon/UI_CANON.md`, `docs/support/ui_kit_2026-10-09.md` e questo file.

Gli altri file del kit e le modifiche locali a ui_root/manifesto_verdict
sono quelli preesistenti. Sono preservati e distinti nel manifest.

## NEXT ACTION

Prossimo pacchetto: Patto e Gradinata. Rimangono precedenti giudizio/sigillo,
corpo del fascicolo, HUD, dettaglio Segni, menu/utility, Archivio, dialoghi
e raccordo finale; i comandi del fascicolo e la posta erano gia' migrati.

Revisione umana del tono, leggibilita' e comfort del Registro e checkpoint
Linux rimangono aperti. Nessuna accettazione artistica globale o gate di
release deriva da queste fixture. Il lavoro resta locale su main per la
review e il commit manuali dell'utente.
