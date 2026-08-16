#!/usr/bin/env python3
"""Export the string catalogs to one CSV — every key, language and value.

    python3 Tools/export_strings_csv.py                       # everything
    python3 Tools/export_strings_csv.py -o strings.csv
    python3 Tools/export_strings_csv.py --languages de fr es
    python3 Tools/export_strings_csv.py --missing               # gaps only
    python3 Tools/export_strings_csv.py --keys 'notif.*' 'premium.*'

The CSV is the input format of `import_strings_csv.py`, so the normal round
trip is: export, edit the `value` column, import.

Columns
    file            Localizable | InfoPlist — which catalog the row came from
    key             the string key
    language        language code
    path            which plural/substitution case (empty for a plain string)
    state           translated | new | needs_review
    value           the text; this is the column to edit
    source_value    the English text for the same path — reference, not imported
    comment         the note for translators — reference, not imported

`--missing` writes a row per language that has no translation for a key, with
an empty `value`, so the file doubles as a work list. Rows left empty are
skipped on import, so a partly filled file is safe to import.
"""

from __future__ import annotations

import argparse
import csv
import fnmatch
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import xcstrings_lib as xc

CATALOGS = {
    "Localizable": "King Krab/Localizable.xcstrings",
    "InfoPlist": "King Krab/InfoPlist.xcstrings",
}

COLUMNS = [
    "file",
    "key",
    "language",
    "path",
    "state",
    "value",
    "source_value",
    "comment",
]


def project_root() -> str:
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def all_languages(catalog: dict) -> list[str]:
    found: set[str] = set()
    for entry in catalog.get("strings", {}).values():
        found.update(entry.get("localizations", {}))
    return sorted(found)


def matches(key: str, patterns: list[str] | None) -> bool:
    return patterns is None or any(fnmatch.fnmatch(key, p) for p in patterns)


def missing_rows(catalog: dict, name: str, languages: list[str], patterns) -> list[dict]:
    """An empty row per key a language has no translation for at all.

    The test is "does this language say anything for this key", not "does it
    have the same plural cases as English". A language may legitimately carry a
    plural where English has none, or write `%2$lld` where English writes an
    inline `%#@seconds@` — comparing shapes would report those as gaps and bury
    the real ones. Each gap gets one row per English leaf, so the translator has
    a slot for every case to fill.
    """
    source_language = catalog.get("sourceLanguage", "en")
    out = []
    for key, entry in catalog.get("strings", {}).items():
        if not matches(key, patterns):
            continue
        localizations = entry.get("localizations", {})
        source_leaves = list(xc.flatten_localization(localizations.get(source_language, {})))
        for language in languages:
            if language == source_language:
                continue
            if any(xc.flatten_localization(localizations.get(language, {}))):
                continue
            for path, unit in source_leaves:
                out.append(
                    {
                        "file": name,
                        "key": key,
                        "language": language,
                        "path": path,
                        "state": "new",
                        "value": "",
                        "source_value": unit.get("value", ""),
                        "comment": entry.get("comment", ""),
                    }
                )
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("-o", "--output", default="Tools/strings_export.csv")
    parser.add_argument(
        "--languages",
        nargs="+",
        help="only these language codes (default: all in the catalog)",
    )
    parser.add_argument(
        "--keys", nargs="+", help="only keys matching these glob patterns"
    )
    parser.add_argument(
        "--catalog",
        choices=sorted(CATALOGS),
        help="only one catalog (default: both)",
    )
    parser.add_argument(
        "--missing",
        action="store_true",
        help="export the untranslated gaps instead of the current values",
    )
    args = parser.parse_args()

    root = project_root()
    names = [args.catalog] if args.catalog else list(CATALOGS)

    rows: list[dict] = []
    for name in names:
        catalog = xc.load(os.path.join(root, CATALOGS[name]))
        languages = args.languages or all_languages(catalog)
        if args.missing:
            rows.extend(missing_rows(catalog, name, languages, args.keys))
            continue
        for row in xc.rows(catalog, languages):
            if not matches(row["key"], args.keys):
                continue
            rows.append({"file": name, **row})

    out_path = args.output
    if not os.path.isabs(out_path):
        out_path = os.path.join(root, out_path)
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(out_path, "w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=COLUMNS)
        writer.writeheader()
        writer.writerows(rows)

    languages_seen = {row["language"] for row in rows}
    keys_seen = {(row["file"], row["key"]) for row in rows}
    print(
        f"{len(rows)} rows · {len(keys_seen)} keys · "
        f"{len(languages_seen)} languages → {os.path.relpath(out_path, root)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
