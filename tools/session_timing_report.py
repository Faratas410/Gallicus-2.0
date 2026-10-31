"""Summarise a human session from the game's local log (user://session_log.jsonl).

The log has one line per closed percorso with its active playtime: time inside
a percorso with the window focused, without menu or dossier. Pauses, help
given and drop-outs are not in the log: write them in the playtest notes.
"""
import argparse
import json
from pathlib import Path
from statistics import median


def campaigns(lines: list) -> list:
    # A new campaign starts when the Era goes back after a reset.
    groups: list = [[]]
    for line in lines:
        if groups[-1] and line["era"] < groups[-1][-1]["era"]:
            groups.append([])
        groups[-1].append(line)
    return [group for group in groups if group]


def minutes(seconds: list) -> str:
    if not seconds:
        return "-"
    return f"{sum(seconds) / 60:.1f} min totali, mediana {median(seconds) / 60:.1f} min"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("log", type=Path, help="session_log.jsonl from the player's user data folder")
    args = parser.parse_args()
    lines = [json.loads(row) for row in args.log.read_text(encoding="utf-8").splitlines() if row.strip()]
    for index, group in enumerate(campaigns(lines), 1):
        active = [int(line["active_seconds"]) for line in group]
        print(f"Campagna {index}: {len(group)} percorsi, {sum(active) / 3600:.2f} ore attive, "
              f"Assenza {'raggiunta' if any(line['era'] == 3 and line['silence'] for line in group) else 'non raggiunta'}")
        for era in sorted({line["era"] for line in group}):
            era_lines = [line for line in group if line["era"] == era]
            print(f"  Era {era}: {len(era_lines)} percorsi, {minutes([int(line['active_seconds']) for line in era_lines])}")
        with_scene = [int(line["active_seconds"]) for line in group if line["scenes"]]
        without = [int(line["active_seconds"]) for line in group if not line["scenes"]]
        print(f"  Con scene: {len(with_scene)} percorsi, {minutes(with_scene)}")
        print(f"  Solo rito: {len(without)} percorsi, {minutes(without)}")
        print(f"  Denari: finale {group[-1]['denari']}, minimo {min(line['denari'] for line in group)}, "
              f"massimo {max(line['denari'] for line in group)}, entrate {sum(line['earned'] for line in group)}, "
              f"uscite {sum(line['lost'] for line in group)}")
        reasons: dict = {}
        for line in group:
            reasons[line["reason"]] = reasons.get(line["reason"], 0) + 1
        print(f"  Chiusure: {reasons}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
