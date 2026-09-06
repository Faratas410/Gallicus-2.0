# Sviluppo con Astra

## Mandato

Il modello di riferimento per sviluppare Gallicus e' **GPT-6 Astra**
(`gpt-6-astra`). Il traguardo e' Gallicus 1.0 pubblicato su Steam, Windows x64,
in IT/EN/ES. Roadmap e gate restano in `docs/development_plan.md`;
la distribuzione e' governata da `docs/steam_release.md`.

OpenAI documenta Astra per lavoro complesso, coding e documenti. La scelta
del progetto e' usarlo per seguire un pacchetto dalla diagnosi alla verifica,
conservando contesto e vincoli tra le iterazioni.
Fonte verificata il 6 settembre 2026:
[GPT-6 Astra](https://developers.openai.com/api/docs/models/gpt-6-astra).

Questo documento definisce il metodo di lavoro. Non configura il selettore
del modello nell'app, non aggiunge servizi AI al gioco e non richiede API key.
Non sostituire silenziosamente il modello richiesto se non disponibile.

## Impostazione del lavoro

L'effort segue la complessita'. Questi sono criteri di progetto, non default
OpenAI; una scelta esplicita dell'utente resta prioritaria.

| Lavoro | Effort consigliato | Risultato atteso |
| --- | --- | --- |
| Docs, copy, correzione circoscritta | `medium` | modifica coerente e controlli pertinenti |
| Pacchetto runtime o UI con integrazione | `high` | percorso reale implementato e verificato |
| Audit trasversale, save, flow o gate release | `xhigh` | contratti tracciati, regressioni e limiti espliciti |

Lavorare con un agente responsabile del pacchetto. Subagenti e delega solo
su richiesta esplicita; non sono necessari per chiudere uno stage. Le letture
e le verifiche indipendenti possono essere eseguite insieme. Evitare writer
concorrenti sui medesimi file e piu' pacchetti runtime aperti.

## Ciclo di un pacchetto

1. **Ricostruire lo stato.** Leggere `AGENTS.md`, `docs/README.md`, prossimo
   passo della roadmap e owner del dominio. Controllare branch, HEAD, diff
   e modifiche locali preesistenti. Un report storico non descrive da solo
   il working tree corrente.
2. **Definire la chiusura.** Collegare la richiesta a un gate, descrivere il
   comportamento osservabile, il difetto riproducibile o il documento da
   ottenere. Indicare owner, contratti coinvolti e prova proporzionata al
   rischio. Per gameplay usare prima `docs/object_grammar.md`.
3. **Completare il lavoro autorizzato.** Implementare il pacchetto fino alla
   consegna verificabile, includendo le correzioni necessarie emerse durante
   le prove. Conservare `RunManager`, `GameEvents` e UI nei rispettivi ruoli.
   Non aprire refactor o nuove feature solo perche' un audit li suggerisce.
4. **Verificare il risultato reale.** Applicare `docs/testing.md`. Per UI
   controllare schermate renderizzate e input; per save attraversare anche
   scrittura, chiusura e ripresa dal gioco. I test dei soli helper non
   dimostrano l'integrazione. Per asset seguire `docs/asset_pipeline.md`.
5. **Rileggere la patch.** Cercare regressioni, contratti alterati, copie
   IT/EN/ES divergenti, perdita di dati e dipendenze fuori scope. Un test
   fallito va risolto o riportato come blocker, mai coperto abbassando il gate.
6. **Consegnare localmente.** Aggiornare owner e roadmap, elencare file,
   verifiche, prove e limiti residui. Distinguere implementato, verificato
   localmente e formalmente approvato. Il lavoro resta su `main`: revisione,
   commit e push spettano all'utente in GitHub Desktop salvo richiesta diversa.

Per una piccola correzione bastano poche righe di contesto e handoff. Non
creare documenti, test speculari o cicli di audit aggiuntivi senza utilita'.
Una volta soddisfatto il criterio di chiusura, consegnare; le nuove idee
entrano nel backlog con priorita', senza estendere da sole il pacchetto.

## Evidenza e decisioni

- Registrare commit e presenza di modifiche locali; per un export, manifest
  e hash dell'eseguibile. Un checkpoint Linux deve riferirsi al codice
  candidato effettivamente testato. Una patch successiva richiede la
  valutazione dei controlli da ripetere.
- Riportare scenari realmente eseguiti, piattaforma, profilo e risultato.
  Non sommare conteggi duplicati tra suite, ne' equiparare PNG prodotti a
  schermate ispezionate. La CI Linux resta la prova automatica canonica.
- Un agente puo' diagnosticare e verificare il software; tre sessioni CP-03,
  durata della prima campagna, ritmo, mix e comprensione richiedono persone.
  Nessun modello, effort o smoke sostituisce quel go/no-go.
- Per problemi usare severita' e decisioni di `docs/playtest_guide.md`, con
  riproduzione, impatto e prova attesa. Gli Optional non bloccano la release
  senza una ragione esplicita; Critical e Important seguono la checklist.
- Le istruzioni dell'utente delimitano il lavoro autorizzato. Una correzione
  durante il task aggiorna il pacchetto; non cancella automaticamente il
  resto della richiesta. Chiedere solo informazioni davvero necessarie e
  proseguire il lavoro indipendente disponibile.
- Preparare materiali e build revisionabili prima di chiedere una decisione
  esterna. Commit, push e azioni Steam seguono le autorizzazioni di
  `AGENTS.md`; la generica direzione "road to Steam" non invia o pubblica nulla.

## Ripresa tra sessioni

Usare un breve handoff quando cambia il contesto o si interrompe un pacchetto:

```text
Richiesta e gate:
Stato locale: branch, HEAD, modifiche gia' presenti
Completato: comportamento e file
Verificato: comandi/scenari, risultati, manifest o report
Aperto: blocker reali, prove umane, decisioni necessarie
Prossima azione concreta:
Autorizzazioni e vincoli da conservare:
```

Riprendere dalle prove disponibili, verificando se i file sono cambiati.
Non ripetere il lavoro concluso e non marcare completo un gate per mancanza
di tempo o contesto.

## Percorso documentation-only

Limitare gli edit a `AGENTS.md`, documenti in `docs/` e markdown di stato
alla radice. Conservare runtime, asset, dati, CI e canon gameplay invariati.
Verificare riferimenti docs, mojibake e diff; runtime ed export non sono
richiesti quando cambia soltanto il metodo documentato. Un cambiamento alla
documentazione del workflow non equivale a una modifica al workflow CI.
