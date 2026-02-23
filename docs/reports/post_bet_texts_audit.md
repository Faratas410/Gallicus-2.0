# Audit — Post Bet Texts

## Scope
Audit statico dei testi mostrati nel segmento **post-bet** (chiusura patto + avvio rito) nel flow Level 3.

File analizzati:
- `scripts/content/bet_catalog.gd`
- `scripts/ui/ui_root.gd`
- `data/bets.gd`

## Runtime path verificato
1. Dopo la firma, `UIRoot._on_pact_sealed_opened()` costruisce il payload con titolo fisso `IL PATTO È SIGILLATO.` e sottotitolo da `_select_post_bet_text(_selected_bet_id)`.
2. In apertura rito, `UIRoot._on_resolve_ritual_opened()` usa titolo fisso `RITO DI GIUDIZIO` e sottotitolo `CONDANNA: ...` (doom short o fallback `giudizio imminente.`).
3. `_select_post_bet_text()` cerca la chiave nel dizionario `POST_BET_TEXTS`; se assente, usa fallback fisso: `La folla trattiene il fiato.`.

## Inventario testi post-bet
`BetCatalog.POST_BET_TEXTS` contiene frasi solo per 3 bet id storici:
- `CASH_OUT` (3 varianti)
- `FLAWLESS_BLOOD` (3 varianti)
- `DOUBLE_OR_DIE` (3 varianti)

## Findings

### 1) Copertura incompleta su catalogo Level 3 attivo
**Severità: HIGH**

Il catalogo Level 3 attivo è centrato su ID `P3_*` (es. `P3_WAX_SEAL`, `P3_BLOOD_LEDGER`, ecc.), mentre i testi post-bet sono definiti solo per ID legacy (`CASH_OUT`, `FLAWLESS_BLOOD`, `DOUBLE_OR_DIE`).

Conseguenza runtime: nella maggior parte dei casi reali il post-bet mostra la stessa frase fallback (`La folla trattiene il fiato.`), riducendo varietà e identità narrativa per patto.

### 2) Coerenza formale del blocco "RITO DI GIUDIZIO"
**Severità: LOW (OK)**

Il blocco rito usa template stabile:
- titolo costante (`RITO DI GIUDIZIO`)
- sottotitolo derivato dalla doom line corta (`CONDANNA: ...`) con fallback neutro

Questo mantiene coerenza semantica con il framing di condanna.

### 3) Rotazione anti-ripetizione locale
**Severità: LOW (OK)**

Per chiavi presenti, `_select_post_bet_text()` evita ripetizione immediata della stessa variante (tracking ultimo indice per `bet_id`).

## Valutazione sintetica
- **Pipeline post-bet**: integra e deterministicamente instradata.
- **Qualità testo percepita in produzione**: penalizzata da mismatch ID (legacy vs `P3_*`).
- **Rischio principale**: appiattimento del tono post-firma (fallback dominante), non rottura di flow.

## Raccomandazione minima (non applicata in questo audit)
Allineare la tabella `POST_BET_TEXTS` agli ID Level 3 attivi (`P3_*`) mantenendo l’attuale pipeline UI invariata.
