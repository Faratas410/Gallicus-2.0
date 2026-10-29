# Revisione prima del commit: lavoro sulle dieci ore

## Stato e perimetro

L'obiettivo resta in pausa e non e' completo. La base della revisione e' il
merge `8a298b3`. Il pacchetto contiene sia l'arco del posto e la sua economia,
sia il lavoro visivo locale del 25-26 ottobre da cui l'arco dipende: Registro,
firma, HUD, Banco, Patto, Rito e Incasso/Rilancio. Include asset, traduzioni,
contratti e documentazione. Non descriverlo come dieci ore gia' realizzate.
Usare `git status --short --untracked-files=all` per l'elenco attuale; i file
non tracciati, inclusi gli UID Godot e gli asset, fanno parte della revisione.

La fotografia precedente all'allineamento e i file eliminati dalla base
upstream sono conservati in `artifacts/pre_alignment_2026-10-29/`. Gli
`artifacts/` sono prove locali ignorate: il loro contenuto non e' nel commit.

## Correzioni durante la revisione

- Il sigillo torna alla tenuta di 0,8 secondi della base: l'aumento a 1,8 non
  aveva una valutazione umana del ritmo. Non cambia la regola del responso.
- `SfxBus` invalida i richiami differiti con una generazione invece di un
  timestamp: un richiamo successivo allo stop resta valido anche nello stesso
  millisecondo. Il contratto verifica sia l'annullamento sia la ripresa.
- Il runner della campagna esegue anche il controllo del reset del posto su
  profilo isolato, compresa la rilettura dal disco.
- Nel Museo la frase sulla riserva usa `e'` come chiave di traduzione stabile,
  ma mostra `e` accentata nel testo italiano, coerente con le altre voci.

## Verifiche locali

Import Godot 4.7.2 su Windows riuscito; il playbook sul candidato revisionato
passa 51/51, inclusi audio, reset, campagna fino all'Assenza e riavvio
terminale. I log del runner campagna non riportano errori o warning. Prove in
`artifacts/review_10h/final/`; il test di recupero CP-02 genera intenzionalmente
un errore JSON per esercitare il file corrotto. Sono verifiche automatiche
locali, non sostituiscono il checkpoint Linux o le valutazioni umane.

## Da decidere e verificare prima di dichiarare completa la direzione

- Il confronto delle tracce resta molto guidato; va valutato con persone come
  scelta narrativa, non approvato dal solo superamento dei contratti.
- Le scene del posto possono accumularsi prima della firma nello stesso
  percorso; la distribuzione lungo la campagna non e' stata riprogettata.
- Prezzo della copia, sconto variabile e frequenza del richiamo in gradinata
  richiedono bilanciamento e playtest. I vecchi risultati economici precedono
  il riequilibrio `d4d5225` e non validano il candidato corrente.
- Il target di circa dieci ore e' la richiesta dell'utente, non una durata
  dimostrata. I quattro atti sono ipotesi; il legame tra Felix e il posto
  segue l'allusione del canon. Qualsiasi modifica della direzione oltre questi
  confini va proposta e decisa esplicitamente.
- Il candidato non ha ancora accettazione umana di visuale, audio, controller,
  accessibilita' e coinvolgimento, ne' checkpoint Linux sul codice finale.
  Le schermate e le prove precedenti non dimostrano questi gate.

Il riepilogo delle prove e il seguito operativo sono in
`docs/support/sospensione_10_ore_2026-10-29.md`; lo stato dei rapporti non
autorizza release o pubblicazione Steam.
