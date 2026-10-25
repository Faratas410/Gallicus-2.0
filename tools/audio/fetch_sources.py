"""Download the pinned CC0 / CC-BY recordings listed in tools/audio/sources.json.

Usage: python tools/audio/fetch_sources.py [--cache DIR]

Files land in DIR/<key>.<ext> (default: .audio_cache/ at the repo root, ignored
by git). Each file is fetched from raw.githubusercontent.com at the pinned
commit, so the composition in tools/audio/compose.py is reproducible.
"""
import argparse
import concurrent.futures
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cache", default=str(ROOT / ".audio_cache"))
    args = parser.parse_args()
    cache = Path(args.cache)
    cache.mkdir(parents=True, exist_ok=True)
    # Keep Godot from importing the raw recordings.
    (cache / ".gdignore").write_text("", encoding="utf-8")
    sources = json.loads((ROOT / "tools/audio/sources.json").read_text(encoding="utf-8"))
    collections = sources["collections"]
    missing = []

    def fetch(entry: dict) -> None:
        collection = collections[entry["collection"]]
        target = cache / (entry["key"] + Path(entry["path"]).suffix)
        if target.exists() and target.stat().st_size > 0:
            return
        url = "https://raw.githubusercontent.com/%s/%s/%s" % (
            collection["repo"], collection["commit"], urllib.parse.quote(entry["path"]))
        for attempt in range(4):
            try:
                with urllib.request.urlopen(url, timeout=60) as response:
                    target.write_bytes(response.read())
                return
            except urllib.error.HTTPError as error:
                if error.code == 404 or attempt == 3:
                    missing.append((entry["key"], url, str(error)))
                    return
            except Exception as error:  # network hiccup
                if attempt == 3:
                    missing.append((entry["key"], url, str(error)))
                    return
            time.sleep(2 ** (attempt + 1))

    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        list(pool.map(fetch, sources["files"]))
    for key, url, error in missing:
        print("[MISSING]", key, url, error)
    print("[OK] %d files in %s" % (len(sources["files"]) - len(missing), cache))
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
