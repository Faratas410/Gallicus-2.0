# Playtest delle schermate con computer use - 26 ottobre 2026

## Contesto e copertura

- Candidato: `main`, HEAD `b81a4fc00797be0b0f0b7dd68639e309f3db061c`, con le numerose modifiche locali preesistenti incluse. Il risultato vale per questo stato sporco, non per il solo commit.
- Windows, Godot 4.6.2 da sorgente, renderer Vulkan Forward+, finestra impostata a 1280x720, italiano, mouse e tastiera, movimento normale. Profilo APPDATA isolato; non e' un export.
- Osservazione diretta mediante computer use: menu, opzioni, apertura, dialogo iniziale parzialmente letto e saltato, Registro chiuso e aperto, firma, patto, gradinata, rito, esito negativo, quietanza, fascicolo e prossima scommessa. Eseguita una sola run, con via della prudenza e gesto di misura.
- La sessione e' una revisione dell'agente, non una sessione umana CP-03. Non copre campagna completa, tutte le route, esito positivo, resume, Archivio, controller, audio, EN/ES, altre risoluzioni o accessibilita' completa. Le schermate sono state osservate nella finestra; non sono state conservate catture della sessione.
- Log locale: `artifacts/computer_playtest_2026-10-26/godot.log`. Il log riporta l'esito negativo e `CRACKED_BONES`; non presenta errori durante il tratto percorso.

## Risultato del percorso

L'ingresso, la scelta e la firma funzionano con il mouse; il patto conduce alla gradinata, il gesto al rito e la quietanza al fascicolo. Dopo il colpo il sigillo cede, il contatore Segni passa a 1 e il fascicolo riporta un Segno; la prossima scommessa torna al Registro conservando quel contatore. Questo e' coerente con il percorso osservato, ma non dimostra tutti i rami o la persistenza dopo riavvio.

## Problemi e proposte

### 1. Notifica del Segno copre il dialogo del Banco

**Important - osservato.** Dopo il cedimento del sigillo, sulla schermata della quietanza appare una larga notifica nera `OSSA INCRINATE` che si sovrappone al cartiglio di Vessa e ne nasconde parte del testo. La scelta resta visibile, ma il giocatore perde temporaneamente il contesto proprio quando deve decidere. Verificare durata e comportamento con movimento ridotto; collocare la notifica in un'area riservata o consentire di leggerla senza coprire dialogo e conseguenze. Riprodurre dal Registro scegliendo la via della prudenza, facendo cedere il sigillo e attendendo la quietanza.

### 2. Leggibilita' dei testi secondari

**Important - osservazione visiva.** A 1280x720 le descrizioni del Banco, il bando nell'HUD, il testo del Registro e diversi valori nelle opzioni risultano piccoli rispetto a cornici e illustrazioni; i dettagli delle conseguenze richiedono attenzione maggiore dei titoli. Aumentare la dimensione minima dei testi informativi e il contrasto, recuperando spazio dalle decorazioni dove necessario. Controllare a dimensione effettiva e nelle tre lingue, evitando troncamenti.

### 3. Continuita' visiva tra ingresso e percorso

**Optional - osservato.** Menu e dialogo iniziale usano portico e ritratti realistici con pannelli scuri, mentre Registro, Patto, Gradinata e Rito adottano arena e oggetti pixel art. Il cambio e' netto nella stessa sequenza. Il fascicolo torna a un grande foglio piatto sul portico realistico. Proporre un raccordo graduale di ingresso, dialoghi e fascicolo alla famiglia del Registro, preservando la leggibilita' e la personalita' delle scene. Questo conferma sul percorso giocato lo scarto gia' inventariato in [coerenza UI](ui_coherence_2026-10-26.md), non costituisce approvazione di un redesign.

### 4. Esito del bando e azioni del fascicolo poco espliciti

**Needs Repro - comprensione.** Chiudendo alla prima arena con 0 Gloria il fascicolo mostra `Bando mancato: 10 Gloria entro l'arena 4` e subito dopo un prossimo bando con la stessa soglia; inoltre offre sia `Nuovo percorso` sia `Prossima scommessa`. Il percorso osservato non spiega chiaramente perche' il bando sia gia' mancato o quale differenza concreta esista fra le due azioni. Verificare prima la regola e i due effetti effettivi: se corretti, spiegare che la chiusura anticipata conclude il tentativo e descrivere le conseguenze dei due comandi. Non trattare questa osservazione come prova di un errore economico.

### 5. Gerarchia del risultato nel rito

**Optional - proposta.** Il rito rende riconoscibile l'oggetto e fornisce il messaggio `LA CERA SI INCRINA - IL SIGILLO CEDE`, ma la transizione alla quietanza e' rapida. Valutare se concedere tempo sufficiente a leggere risultato e cicatrice, mantenendo un avanzamento esplicito o una durata accessibile. La durata e l'effettiva comprensione richiedono prova umana; non e' stato misurato un tempo.

## Priorita' e prossime verifiche

1. Riprodurre e correggere la sovrapposizione della notifica, poi controllare l'intero testo del Banco nelle tre lingue e a 720p/1080p.
2. Verificare dimensioni e wrapping dei testi di bando, Registro, Banco e opzioni, inclusi focus tastiera e movimento ridotto.
3. Chiarire bando e comandi del fascicolo dopo confronto con la regola effettiva; provare entrambe le azioni e il resume.
4. Programmare una sessione umana e completare le tre route, gli esiti positivi, Archivio, lingue e campagna. Il checkpoint Linux, l'accettazione umana e la pubblicazione Steam restano invariati.
