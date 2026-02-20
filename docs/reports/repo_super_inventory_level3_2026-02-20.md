# SUPER INVENTARIO REPO — Level 3

Data: 2026-02-20  
Scope: repository completo (runtime, legacy, assets, docs, report, CI)  
Metodo: inventory statico + allineamento ai canon Level 3.

---

## 0) Premessa di governance (vincolante)

Pre-flight canon eseguito su:
- `docs/repo_map.md`
- `docs/canon/PROCESS_AND_FREEZE.md`
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/MECHANICS_UNIFIED.md`
- `docs/canon/GLOSSARY_ENTITIES.md`
- `docs/canon/LORE_UNIFIED.md`

Regola applicata nell’audit: se un contenuto confligge col canon, è da considerarsi deprecato/non autorevole.

---

## 1) Snapshot quantitativo (superficiale ma completo)

### Volumetria per macro-cartella
- `.git`: ~113 MB (metadati VCS)
- `Music`: ~67.65 MB (30 file)
- `assets`: ~42.81 MB (55 file)
- `UI Official`: ~0.59 MB (634 file)
- `scripts`: ~53 file
- `docs`: ~57 file
- `legacy-runtime`: 8 file

### Invarianti runtime L3 (check automatici)
- `check_runtime_invariants`: **OK**
- `check_no_legacy_references`: **OK**

Esito: runtime attivo conforme al perimetro L3; il tema principale di ottimizzazione non è la stabilità runtime, ma la riduzione del rumore repository (asset/documentazione duplicata o storica).

---

## 2) CORE (Intoccabile)

Contenuti che vanno preservati per coerenza L3 e authority canonica.

### 2.1 Runtime authority e bootstrap
- `project.godot`
- `scenes/Main.tscn` (entry scene)
- `scripts/systems/run_manager.gd` (single flow authority)
- `scripts/systems/game_events.gd` (single global event authority)
- `scripts/systems/run/*` (kernel operativo RunManager split)
- `scripts/ui/*` e `scenes/UI.tscn` / `scenes/ui/BettingCircle.tscn` (UI reattiva)

**Perché intoccabile:** è il nucleo che realizza gli invarianti non negoziabili Level 3 (single RunManager, single GameEvents, flusso unico).

### 2.2 Canon documentale
- `docs/canon/*`
- `docs/repo_map.md`
- `docs/README.md`

**Perché intoccabile:** sono la fonte normativa. Ogni altro documento è subordinato.

### 2.3 Guardrail CI tecnici
- `scripts/ci/check_runtime_invariants.py`
- `scripts/ci/check_no_legacy_references.py`
- `tools/ci/validate_gameevents_contract.py`
- `tools/ci/verify_res_paths.py`
- `.github/workflows/godot_smoke.yml`

**Perché intoccabile:** prevengono regressioni contro gli invarianti L3.

---

## 3) OPZIONALE (Da valutare)

Contenuti utili ma candidati a razionalizzazione/compattazione.

### 3.1 `Music/` (30 MP3, ~67.65 MB)
- Canon UI documenta la directory e i file, ma nel runtime attivo l’uso diretto è limitato/non capillare.
- **Valutazione:** mantenere solo la shortlist realmente usata nel flow L3; archiviare il resto in branch/release asset separata.

### 3.2 `assets/` ad ampia copertura visiva
- Molti sprite/powerup/weapon non sembrano centrali al gameplay action dismesso.
- **Valutazione:** creare matrice “referenced at runtime vs repository-only” prima di eliminare.

### 3.3 `UI Official/` (634 file)
- È parzialmente richiamata dalla catena `ui/official/*` (atlas/styleboxes), ma il corpus è molto più ampio del necessario.
- **Valutazione:** conservare solo i frame/sheet effettivamente mappati in `ui/official/atlas/*.tres`.

### 3.4 `docs/Foundations/*`
- Materiale sorgente storico importante, ma sovrapposto al canon unificato.
- **Valutazione:** spostamento in `docs/archive/foundations/` con index di tracciabilità, lasciando chiaro che non è autorevole.

---

## 4) INUTILE (Da eliminare)

Contenuti ad alto rapporto rumore/valore, coerenti con eliminazione senza impatto L3.

### 4.1 `readme`
- Contenuto: solo stringa `redme`.
- **Perché eliminabile:** nessun valore tecnico/documentale.

### 4.2 `gui_review.txt`
- Elenco asset “OK GUI / NO GUI” con riferimenti a cartelle non presenti (`OK GUI`, `NO GUI`).
- **Perché eliminabile:** inventario obsoleto e non allineato allo stato reale del repo.

### 4.3 Doppioni report tra root `docs/` e `docs/reports/`
Coppie con stesso topic in due posizioni:
- `codex_report_1_0_gap.md`
- `level3_integrity_audit_report.md`
- `level3_open_questions_log.md`
- `technical_resume_level3_canonical_it.md`
- `technical_review_resume_it.md`

**Perché eliminabile/riducibile:** doppia fonte su contenuti non canonici aumenta drift e costi di manutenzione. Target consigliato: tenere solo una posizione (`docs/reports/`).

---

## 5) QUARTA SEZIONE — LEGACY QUARANTENA (Priorità strategica)

### 5.1 `legacy-runtime/*`
- Stato attuale: isolato correttamente (nessun reference dal runtime attivo; check automatico OK).
- Nel contesto decisionale fornito (“nessun reverse sul gameplay action”), questi file non hanno più traiettoria di rientro.

**Raccomandazione:**
1. Congelare in tag/branch di archival.
2. Rimuovere dal branch di sviluppo principale per ridurre rumore cognitivo.
3. Mantenere solo nota canonica di quarantena storica.

---

## 6) Piano operativo suggerito (minimal risk)

1. **Pulizia immediata (safe):** eliminare `readme` e `gui_review.txt`.
2. **Consolidamento docs:** deduplicare report root `docs/` vs `docs/reports/`.
3. **Legacy final cut:** rimozione `legacy-runtime/*` dopo snapshot archival.
4. **Asset diet controllata:** pruning `Music/`, `UI Official/`, `assets/` con tabella di referenze runtime.

---

## 7) Comandi usati per l’audit

- `find . -type f | sed 's#^./##' > /tmp/all_files.txt`
- `find docs -type f | sort`
- `find legacy-runtime -type f | sort`
- `du -sh * .* 2>/dev/null | sort -h`
- `python3 scripts/ci/check_runtime_invariants.py`
- `python3 scripts/ci/check_no_legacy_references.py`
- `rg -n "UI Official|OK GUI|legacy-runtime|res://ui/official|res://legacy-runtime" ...`
- script Python locale per conteggi file/dimensioni e rilevazione duplicati documentali.

