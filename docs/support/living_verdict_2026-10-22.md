# Incasso/Rilancio: arena viva

## Perimetro e riferimento

Implementazione locale richiesta dall'utente il 22 ottobre 2026, a partire
dal mockup HTML "Dopo meno seria, piu' viva". ZIP originale nei Download,
estratto senza modifiche nella cartella visualizzazioni della chat.
Lo studio HTML precedente in `tools/prototypes/gallicus-hud/` resta distinto.
Il riferimento guida gerarchia, materia e gesti; i suoi valori dimostrativi
non diventano regole del gioco.

Base: `b81a4fc00797be0b0f0b7dd68639e309f3db061c`, main con modifiche
preesistenti. Nessun commit, push o cambio ramo. Il candidato resta dirty.

## Risultato

Correzione richiesta durante la revisione: la folla iniziale formava una
fascia troppo densa e il carattere Manifesto 900 condensato non si accordava
con le immagini. La versione armonizzata usa cinque piccoli gruppi aviani
distanziati nelle gradinate, senza figure in primo piano. La famiglia resta
Roboto Serif gia' nel progetto, ma con peso 400, larghezza normale e optical
size 32; titoli, numeri, voci e azioni condividono questa variante. Le azioni
visibili sono in minuscolo con iniziale maiuscola; i Button mantengono il
testo semantico originale. Nessuna sostituzione dei font nelle altre fasi.

- Gloria in posta e Pressione a dieci tacche sono parte della scena.
  Arena, bando, Favore, Denari e consultazione dei Segni restano piccoli in alto.
- La quietanza e' un oggetto inclinato con sollevamento passivo e timbro
  INCASSATA. Il sigillo del rilancio ha occhi di gufo e piume incise;
  l'attivazione aggiunge due tagli paralleli, mai una crepa di fallimento.
- Il Marchio resta disponibile quando il payload blocca l'incasso.
  Cause dei blocchi e conseguenze restano testuali e localizzate.
- Galli e gufi pittorici animano la gradinata. Torce e polvere seguono un
  tempo locale deterministico; nessun consumo di RNG gameplay.
- Conteggio della Gloria a destinazione esatta, breve impulso della Catena
  soltanto quando cambia, scossa ambientale contenuta sul rilancio.
  L'ultimo evento autorevole del sigillo permette approvazione o cedimento;
  il solo click RADDOPPIA non produce una vittoria.
- Vessa usa battute senza somme inventate e senza pressione temporale falsa.
  Movimento ridotto ferma tutte le nuove animazioni e mostra subito i valori.

Restano nativi i Button, gli intenti, i blocchi e il watchdog. RunManager,
economia, esiti, save e segnali non sono cambiati da questo pacchetto.
Se la fase si chiude nello stesso frame della scelta, un'impronta passiva
dell'oggetto registrato resta per 280 ms e sfuma: nessun target interattivo,
nessun rinvio o reinvio dell'intento. In movimento ridotto viene omessa.
Il layout e' circoscritto a Incasso/Rilancio; l'HUD delle altre fasi viene
ripristinato all'uscita.

## File del pacchetto

- `scripts/ui/manifesto_verdict.gd`: presenter della scena.
- `scripts/ui/verdict_object.gd`: superfici passive degli oggetti.
- `scripts/ui/verdict_atmosphere.gd`: arena, folla, torce, polvere, tacche.
- `assets/ui/fonts/font_verdict.tres`: variante serif regolare locale.
- `assets/ui/generated/verdict_owl_seal.png`,
  `assets/ui/generated/verdict_avian_crowd.png`: nuovi raster trasparenti
  prodotti con lo strumento ImageGen integrato.
- `assets/ui/generated/verdict_arena.png`: copia byte-identica della
  sorgente del progetto `assets/backgrounds/sfondo_arena_principale.png`.
  L'originale e' conservato. Non e' un'immagine nuova.
- `assets/ui/generated/manifest.json`: prompt integrali, origine, consumer,
  dimensioni e SHA-256; file `.import` e UID associati.
- `assets/i18n/it.csv`, `assets/i18n/en.csv`, `assets/i18n/es.csv` e
  relative risorse `.translation` rigenerate: nuova voce, caption e timbri.
- `tools/living_verdict_capture.gd`: matrice visuale e input dedicata.
- `tools/counter_layout_capture.gd`: le collisioni con l'HUD considerano
  solo elementi visibili; i controlli di contenimento e testo restano attivi.
- `docs/README.md`, `docs/art_direction.md`, `docs/layout_rules.md`,
  `docs/canon/UI_CANON.md`, `docs/testing.md` e questo report.

Quietanza, Marchio e ritratto Vessa riusano asset esistenti. I nuovi asset
sono stati ispezionati in output e nel render; il manifest conserva i prompt
effettivi, senza dichiarare una nuova licenza per sorgenti precedenti.

## Verifiche ed evidenze

Godot `4.6.2.stable.official.71f334935`, Windows, Vulkan/Forward+, GPU reale.
Ogni processo Godot e' stato avviato su desktop privato non attivato,
con profilo temporaneo e job chiuso automaticamente. Audio Dummy:
nessuna nuova accettazione audio.

Artefatti locali sotto `artifacts/living_verdict/`:

- `before/`: stato precedente nelle stesse fixture IT a 720p e 1080p.
- `delivery/`: 50 catture finali IT/EN/ES dopo il feedback su folla e caratteri.
- `delivery/result.json`: PASS, nessun clipping o errore di focus/input.
- `delivery_process/process.json`: isolamento PASS, exit 0.
- `review.html`: confronto prima/dopo a pari stato e risoluzione.
- `counter/summary.json`: 46 catture della fixture trasversale, PASS;
  include ripristino geometria HUD, note e contenimento degli altri pannelli.
- `static_final/testing_playbook_summary.json`: 45 verifiche statiche PASS.
- `delivery_ROUTE_CASHOUT/`, `delivery_ROUTE_DOUBLE/`,
  `delivery_ROUTE_CONDANNA/`, `delivery_KEYBOARD_FULL_RUN/`: log e summary
  del candidato finale, tutti OK.

Le quattro route reali risultano OK con seed 1782373819. La matrice controlla
stati disponibili, focus, quietanza impressa, seconda incisione, blocchi,
posta a sei cifre, avvio/fine conteggio, rischio, tenuta/cedimento,
movimento ridotto, apertura Segni e scadenza dell'impronta di transizione.
Il doppio click sul testo di conseguenza
deve emettere un solo intento; i target restano fermi.

I tentativi intermedi restano conservati: primo avvio negato dal sandbox
prima della creazione del processo, poi isolamento autorizzato riuscito;
prima iterazione con layout chiamato prima dei riferimenti UI, corretto;
prima verifica statica con dipendenza visuale ritirata, sostituita con
copia tracciata nel percorso attivo. Il test del validatore smoke ha
incontrato un errore dei permessi del TEMP sandbox: ripetuto con TEMP locale.

Le fixture visuali dedicate riportano a chiusura il warning ObjectDB
gia' presente nella cattura prima della patch (due risorse prima e nel
candidato finale). La fixture trasversale chiude senza stderr.
La prova nativa iniziale inoltrava l'intento a un manager ancora nella fase
BET_PRESENT e provocava correttamente il guard: la fixture ora scollega quel
solo consumer e osserva l'intento UI. Le quattro route separate mantengono
invece manager e segnali interamente reali.
Non si confonde il PASS di isolamento del launcher con il risultato della
fixture: si leggono sempre anche exit, stderr e result.json.

Gate distinti ancora aperti: CI canonica Linux, ascolto, playtest umano
e approvazione artistica dell'utente. Nessuna pubblicazione Steam.
