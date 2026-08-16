#!/usr/bin/env python3
"""Write a CSV of translations back into the string catalogs.

    python3 Tools/import_strings_csv.py Tools/strings_export.csv --dry-run
    python3 Tools/import_strings_csv.py Tools/strings_export.csv
    python3 Tools/import_strings_csv.py translated.csv --languages de fr

Takes the CSV that `export_strings_csv.py` writes — the same columns, in any
order — and overwrites the `value` of every row that carries one. Only the
`file`, `key`, `language`, `path` and `value` columns are read; `source_value`
and `comment` are reference columns and are ignored, so a translator can rewrite
them without consequence.

Rules
    · A row with an empty `value` is skipped, so a half-finished file imports
      cleanly. Use `--delete-empty` to make an empty value remove the
      translation instead.
    · `state` defaults to `translated` when the column is missing or blank.
    · Format specifiers (`%@`, `%lld`, `%1$@`, `%#@name@`) are compared against
      the English text; a mismatch is reported and the row is skipped, because
      a wrong specifier is a crash rather than a typo. `--force` imports anyway.
    · Rows for a key or catalog that does not exist are reported and skipped —
      this tool edits translations, it does not invent keys.

Nothing is written until every row has been checked, so a failed run leaves the
catalogs untouched.
"""

from __future__ import annotations

import argparse
import csv
import os
import re
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import xcstrings_lib as xc

CATALOGS = {
    "Localizable": "King Krab/Localizable.xcstrings",
    "InfoPlist": "King Krab/InfoPlist.xcstrings",
}

VALID_STATES = {"translated", "new", "needs_review", "stale"}

# `%1$@`, `%lld`, `%.2f`, `%#@seconds@` and the `%arg` placeholder that stands
# for the number inside a substitution.
SPECIFIER = re.compile(
    r"%(?:\d+\$)?#@[A-Za-z_][A-Za-z0-9_]*@"
    r"|%arg"
    r"|%(?:\d+\$)?[-+ 0#]*[\d.*]*(?:hh|h|ll|l|q|L|z|t|j)?[@dioufFeEgGxXscpaA]"
    r"|%%"
)

INLINE_PLURAL = re.compile(r"%(?:\d+\$)?#@([A-Za-z_][A-Za-z0-9_]*)@")


def project_root() -> str:
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def specifiers(text: str, *nodes: dict) -> list[str]:
    """The arguments `text` consumes, as a sorted multiset of format types.

    Two normalisations make the comparison say what it should:

    · Position prefixes are dropped. `Hold the %1$@ for %2$lld` and
      `Houd %2$lld de %1$@` take the same arguments in a different order,
      which is exactly what a reordering language has to do.
    · An inline plural (`%#@seconds@`) is expanded to the argument it stands
      for, read from the substitution's own `formatSpecifier`. English may
      phrase an argument as an inline plural where a language that does not
      inflect there writes plain `%2$lld` — both consume the same argument, so
      both must compare equal. `nodes` are the localizations to read the
      substitution from, tried in order (the language's own first, then the
      source language's).
    """

    def expand(match: re.Match) -> str:
        name = match.group(1)
        for node in nodes:
            substitution = node.get("substitutions", {}).get(name)
            if substitution:
                return "%" + substitution.get("formatSpecifier", "@")
        return "%@"

    found = SPECIFIER.findall(INLINE_PLURAL.sub(expand, text))
    return sorted(re.sub(r"^%\d+\$", "%", token) for token in found)


def read_rows(path: str) -> list[dict]:
    with open(path, encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        missing = {"file", "key", "language", "path", "value"} - set(
            reader.fieldnames or []
        )
        if missing:
            raise SystemExit(
                f"{path}: missing required column(s): {', '.join(sorted(missing))}"
            )
        return [{k: (v or "") for k, v in row.items()} for row in reader]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("csv_path", help="the CSV to import")
    parser.add_argument(
        "--languages", nargs="+", help="only import these language codes"
    )
    parser.add_argument(
        "--delete-empty",
        action="store_true",
        help="an empty value removes the translation instead of skipping the row",
    )
    parser.add_argument(
        "--state",
        choices=sorted(VALID_STATES),
        help="the state to give every imported row, whatever the CSV says. A "
        "file produced by `export_strings_csv.py --missing` carries `new` on "
        "every row because that is what the empty slots were; once it comes "
        "back filled in, `--state translated` is what those rows now are.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="import rows whose format specifiers do not match English",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="report what would change, write nothing"
    )
    args = parser.parse_args()

    root = project_root()
    rows = read_rows(args.csv_path)

    catalogs: dict[str, dict] = {}
    counts: dict[str, int] = defaultdict(int)
    problems: list[str] = []
    touched: set[str] = set()

    for number, row in enumerate(rows, start=2):  # header is line 1
        name = row["file"].strip() or "Localizable"
        key, language, path = row["key"], row["language"].strip(), row["path"].strip()
        value = row["value"]

        if args.languages and language not in args.languages:
            continue
        if name not in CATALOGS:
            problems.append(f"line {number}: unknown catalog {name!r}")
            continue
        if name not in catalogs:
            catalogs[name] = xc.load(os.path.join(root, CATALOGS[name]))
        catalog = catalogs[name]

        entry = catalog.get("strings", {}).get(key)
        if entry is None:
            problems.append(f"line {number}: unknown key {key!r} in {name}")
            continue
        if not language:
            problems.append(f"line {number}: no language")
            continue

        localizations = entry.setdefault("localizations", {})
        source_language = catalog.get("sourceLanguage", "en")
        source = localizations.get(source_language, {})

        if not value.strip():
            if not args.delete_empty:
                counts["skipped (empty)"] += 1
                continue
            if language in localizations:
                xc.delete_unit(localizations[language], path)
                if not localizations[language]:
                    del localizations[language]
                counts["deleted"] += 1
                touched.add(name)
            continue

        source_value = dict(xc.flatten_localization(source)).get(path, {}).get("value")
        if source_value is not None and language != source_language:
            target = localizations.get(language, {})
            mine = specifiers(value, target, source)
            theirs = specifiers(source_value, source)
            if mine != theirs:
                message = (
                    f"line {number}: {key} [{language}] format specifiers "
                    f"{mine} do not match {source_language} {theirs}"
                )
                if not args.force:
                    problems.append(message)
                    continue
                print("warning: " + message)

        state = args.state or (row.get("state") or "").strip() or "translated"
        if state not in VALID_STATES:
            problems.append(f"line {number}: unknown state {state!r}")
            continue

        node = localizations.setdefault(language, {})
        before = dict(xc.flatten_localization(node)).get(path, {}).get("value")
        xc.set_unit(node, path, value, state, source)
        counts["added" if before is None else "changed" if before != value else "unchanged"] += 1
        if before != value:
            touched.add(name)

    for problem in problems:
        print("error: " + problem, file=sys.stderr)
    if problems:
        print(
            f"\n{len(problems)} problem(s); nothing written. Fix the rows"
            + ("." if args.force else ", or re-run with --force to import format-specifier mismatches anyway."),
            file=sys.stderr,
        )
        return 1

    summary = " · ".join(f"{count} {label}" for label, count in sorted(counts.items()))
    if args.dry_run:
        print(f"dry run: {summary or 'nothing to do'}")
        return 0

    for name in sorted(touched):
        xc.dump(catalogs[name], os.path.join(root, CATALOGS[name]))
    written = ", ".join(sorted(touched)) or "nothing"
    print(f"{summary or 'nothing to do'} → wrote {written}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
