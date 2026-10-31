"""Aggregate run_economy_matrix.py outputs per Era and per percorso.

Reads one or more matrix summary.json files and writes report.json and
report.md next to the first one (or to --output-dir). Scripted policies are
not players: the tables describe simulated economy and content reach only.
"""
import argparse
import json
from pathlib import Path
from statistics import median

TALE_IDS = ("first_strophe", "ledger", "sand", "seat_kept", "call", "seats",
            "footstep", "open_strophe", "scraping", "slope")
SEAT_IDS = ("seat_reserved_followup", "seat_witness_followup", "seat_receipt_after_inquiry",
            "seat_voice_after_inquiry", "seat_copy_for_nerio", "seat_copy_for_dima")
ERA_IDS = ("entry", "middle", "departure")


def label(result: dict) -> str:
    extra = result.get("extra") or {}
    suffix = ",".join(f"{key}={value}" for key, value in sorted(extra.items()))
    return result["policy"] + (f"[{suffix}]" if suffix else "")


def per_era(rows: list) -> list:
    eras: dict = {}
    era = 0
    for row in rows:
        bucket = eras.setdefault(era, {"era": era, "percorsi": 0, "denari_start": row["denari_before"],
                                       "denari_min": row["denari"], "earned": 0, "lost": 0,
                                       "debt_percorsi": 0, "bought": 0, "insured": 0,
                                       "discounted": 0, "bandi": 0, "pressure_max": 0, "scars": 0})
        bucket["percorsi"] += 1
        bucket["denari_end"] = row["denari"]
        bucket["denari_min"] = min(bucket["denari_min"], row["denari"])
        bucket["earned"] += row["earned"]
        bucket["lost"] += row["lost"]
        bucket["debt_percorsi"] += int(row["denari"] < 0)
        bucket["bought"] += row["bought"]
        bucket["insured"] += row["insured"]
        bucket["discounted"] += row["discounted_policies"]
        bucket["bandi"] += int(bool(row["bando"]))
        bucket["pressure_max"] = max(bucket["pressure_max"], row["pressure_max"])
        bucket["scars"] += row["scars"]
        era = row["era"]
    return [eras[key] for key in sorted(eras)]


def busiest(dialogues: dict) -> tuple:
    counts: dict = {}
    for percorso in dialogues.values():
        counts[percorso] = counts.get(percorso, 0) + 1
    if not counts:
        return (0, 0)
    percorso = max(counts, key=lambda key: (counts[key], -key))
    return (percorso, counts[percorso])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("summaries", nargs="+", type=Path)
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    results = []
    for path in args.summaries:
        results += json.loads(path.read_text(encoding="utf-8"))
    output = (args.output_dir or args.summaries[0].parent).resolve()
    output.mkdir(parents=True, exist_ok=True)
    cases = []
    for result in sorted(results, key=lambda item: (label(item), item["seed"])):
        summary = result.get("summary", {})
        dialogues = result.get("dialogues", {})
        rows = result.get("rows", [])
        cases.append({
            "config": label(result), "seed": result["seed"], "ok": result.get("ok", False),
            "objectdb_warning": result.get("objectdb_warning"), "error": result.get("error", ""),
            "percorsi": summary.get("runs", 0), "absence": summary.get("absence", False),
            "denari_final": summary.get("denari_final"), "denari_min": summary.get("denari_min"),
            "denari_max": summary.get("denari_max"), "debt_runs": summary.get("debt_runs"),
            "bought": summary.get("totals", {}).get("bought", 0),
            "discounted": summary.get("totals", {}).get("discounted_policies", 0),
            "bandi": summary.get("bandi"), "step_final": summary.get("step_final"),
            "seat_case": (summary.get("seat_case") or {}).get("choice", ""),
            "seat_copy": summary.get("seat_copy", ""),
            "tales_seen": [tale for tale in TALE_IDS if tale in dialogues],
            "tales_missed": [tale for tale in TALE_IDS if tale not in dialogues],
            "seat_scenes": {key: dialogues[key] for key in SEAT_IDS if key in dialogues},
            "era_scenes": {key: dialogues[key] for key in ERA_IDS if key in dialogues},
            "busiest_percorso": busiest(dialogues), "dialogues": dialogues,
            "eras": per_era(rows)})
    (output / "report.json").write_text(json.dumps(cases, indent=2), encoding="utf-8")
    lines = ["| Config | Seed | Esito | Percorsi | Saldo finale | Min | Max | Percorsi in debito | Acquisti | Polizze scontate | Bandi | Racconti mancati | Percorso con piu' scene |",
             "| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |"]
    for case in cases:
        outcome = "OK" if case["ok"] else ("errore" if case["error"] else "non valido")
        if case["objectdb_warning"]:
            outcome += ", ObjectDB"
        where, count = case["busiest_percorso"]
        lines.append(f"| {case['config']} | {case['seed']} | {outcome} | {case['percorsi']} | {case['denari_final']} | "
                     f"{case['denari_min']} | {case['denari_max']} | {case['debt_runs']} | {case['bought']} | "
                     f"{case['discounted']} | {case['bandi']} | {', '.join(case['tales_missed']) or '-'} | {where} ({count}) |")
    lines += ["", "| Config | Seed | Era | Percorsi | Saldo inizio | Saldo fine | Min | Entrate | Uscite | In debito | Acquisti | Bandi |",
              "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
    for case in cases:
        for era in case["eras"]:
            lines.append(f"| {case['config']} | {case['seed']} | {era['era']} | {era['percorsi']} | {era['denari_start']} | "
                         f"{era['denari_end']} | {era['denari_min']} | {era['earned']} | {era['lost']} | "
                         f"{era['debt_percorsi']} | {era['bought']} | {era['bandi']} |")
    finals = [case["denari_final"] for case in cases if case["ok"]]
    if finals:
        lines += ["", f"Mediana del saldo finale sulle campagne valide: {median(finals)} ({len(finals)} campagne)."]
    (output / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(output / "report.md")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
