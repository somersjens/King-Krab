#!/usr/bin/env python3
"""Drop translations for keys whose English text changed since a base revision.

    python3 Tools/clear_outdated_translations.py --list
    python3 Tools/clear_outdated_translations.py

This game was built on top of another app and inherited its whole string
catalog, translations included. Wherever the English was rewritten for this
game, the seventy-odd other languages still carry the other app's sentence —
they read fluently and say the wrong thing, which is worse than an empty slot,
because an empty slot falls back to English and shows up as work to do.

So: compare each key's English against the same key in the base revision, and
for every key that differs, remove the languages that are not authored by hand
(English and Dutch are; see `xcstrings_lib.SOURCE_LANGUAGES`). Keys whose
English is untouched keep their translations — those are still correct.

`--base` defaults to the commit that first brought the catalog into this repo.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import xcstrings_lib as xc

CATALOG = "King Krab/Localizable.xcstrings"
DEFAULT_BASE = "0a369ab"


def project_root() -> str:
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def catalog_at(revision: str, root: str) -> dict:
    blob = subprocess.run(
        ["git", "show", f"{revision}:{CATALOG}"],
        cwd=root,
        capture_output=True,
        check=True,
    ).stdout.decode("utf-8")
    return json.loads(blob)


def english(entry: dict, source_language: str) -> dict:
    node = entry.get("localizations", {}).get(source_language, {})
    return {
        path: unit.get("value") for path, unit in xc.flatten_localization(node)
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--base", default=DEFAULT_BASE, help="git revision to compare against")
    parser.add_argument(
        "--keep",
        nargs="+",
        default=list(xc.SOURCE_LANGUAGES),
        help="languages to leave alone (default: en nl)",
    )
    parser.add_argument("--list", action="store_true", help="report, write nothing")
    args = parser.parse_args()

    root = project_root()
    path = os.path.join(root, CATALOG)
    current = xc.load(path)
    base = catalog_at(args.base, root)
    source_language = current.get("sourceLanguage", "en")

    outdated = []
    for key, entry in current.get("strings", {}).items():
        old = base.get("strings", {}).get(key)
        if old is None:
            outdated.append((key, "new key"))
        elif english(entry, source_language) != english(old, source_language):
            outdated.append((key, "English rewritten"))

    cleared = 0
    for key, reason in outdated:
        localizations = current["strings"][key].get("localizations", {})
        for language in sorted(set(localizations) - set(args.keep)):
            del localizations[language]
            cleared += 1
        print(f"{key}  ({reason})")

    print(
        f"\n{len(outdated)} key(s), {cleared} translation(s) "
        f"{'to clear' if args.list else 'cleared'} — kept {', '.join(args.keep)}"
    )
    if not args.list:
        xc.dump(current, path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
