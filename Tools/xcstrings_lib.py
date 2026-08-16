"""Read and write Xcode string catalogs (.xcstrings) without churning the file.

Xcode writes its catalogs as JSON with two-space indent, a space on both sides
of the colon, and its keys in Finder order — case-insensitive, with digit runs
compared as numbers, so `tutorial.step.2` sorts before `tutorial.step.10`.
`dump` reproduces that byte for byte, so a catalog that is only read and
written back produces an empty diff and a catalog that is edited produces a
diff containing nothing but the edit.

The other half of this module flattens a catalog into rows. A localization is a
small tree: a plain string sits in `stringUnit`, a pluralised one hangs under
`variations`, and a string with an inline plural (`%#@seconds@`) hangs under
`substitutions`. `flatten_localization` walks that tree and names every leaf
with a path, `set_unit` puts a value back at a named path, and the two are
exact inverses — which is what lets the CSV round-trip.

Path grammar, dot-separated:

    (empty)                 the localization's own stringUnit
    plural.one              the `one` case of the plural variation
    device.ipad.plural.one  nested variations, outermost first
    @seconds.plural.one     the `one` case inside the `seconds` substitution
"""

from __future__ import annotations

import json
import re
from collections import OrderedDict
from typing import Any, Iterator

# Languages the app ships as authored source rather than as translations.
SOURCE_LANGUAGES = ("en", "nl")


# MARK: - File I/O


def _natural_key(text: str) -> list:
    """Sort key matching Xcode's ordering: case-insensitive, digits numeric."""
    parts = [p for p in re.split(r"(\d+)", text) if p != ""]
    key = [(1, int(p), "") if p.isdigit() else (0, 0, p.lower()) for p in parts]
    # Tie-break on the raw string so the order is total for keys that differ
    # only in case.
    key.append((2, 0, text))
    return key


def _sorted_tree(node: Any) -> Any:
    if isinstance(node, dict):
        return OrderedDict(
            (k, _sorted_tree(node[k])) for k in sorted(node, key=_natural_key)
        )
    if isinstance(node, list):
        return [_sorted_tree(item) for item in node]
    return node


def load(path: str) -> dict:
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def dumps(catalog: dict) -> str:
    """Serialize exactly the way Xcode does — no trailing newline."""
    return json.dumps(
        _sorted_tree(catalog),
        indent=2,
        separators=(",", " : "),
        ensure_ascii=False,
    )


def dump(catalog: dict, path: str) -> None:
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(dumps(catalog))


# MARK: - Flattening


def flatten_localization(node: dict, prefix: str = "") -> Iterator[tuple[str, dict]]:
    """Yield `(path, stringUnit)` for every leaf under one localization."""
    unit = node.get("stringUnit")
    if unit is not None:
        yield prefix, unit
    for kind, cases in node.get("variations", {}).items():
        for case, child in cases.items():
            yield from flatten_localization(child, _join(prefix, kind, case))
    for name, substitution in node.get("substitutions", {}).items():
        for kind, cases in substitution.get("variations", {}).items():
            for case, child in cases.items():
                yield from flatten_localization(
                    child, _join(prefix, "@" + name, kind, case)
                )


def _join(prefix: str, *segments: str) -> str:
    return ".".join(filter(None, (prefix, *segments)))


def _parse(path: str) -> list[tuple[str, ...]]:
    """Split a path into ('sub', name) and ('var', kind, case) steps."""
    if not path:
        return []
    tokens = path.split(".")
    steps: list[tuple[str, ...]] = []
    index = 0
    while index < len(tokens):
        token = tokens[index]
        if token.startswith("@"):
            steps.append(("sub", token[1:]))
            index += 1
            continue
        if index + 1 >= len(tokens):
            raise ValueError(f"variation {token!r} in path {path!r} has no case")
        steps.append(("var", token, tokens[index + 1]))
        index += 2
    return steps


def set_unit(node: dict, path: str, value: str, state: str, template: dict | None) -> None:
    """Write `value` at `path`, creating the branches the path needs.

    A substitution carries an `argNum` and a `formatSpecifier` that belong to
    the string, not to the translation. When a language has no substitution
    node yet, those two are copied from `template` — the same localization in
    the source language — so a freshly translated language ends up structurally
    identical to English instead of subtly malformed.
    """
    for step in _parse(path):
        if step[0] == "sub":
            name = step[1]
            substitutions = node.setdefault("substitutions", {})
            if name not in substitutions:
                source = (template or {}).get("substitutions", {}).get(name, {})
                substitutions[name] = {
                    key: source[key]
                    for key in ("argNum", "formatSpecifier")
                    if key in source
                }
            node = substitutions[name]
            template = (template or {}).get("substitutions", {}).get(name)
        else:
            _, kind, case = step
            node = node.setdefault("variations", {}).setdefault(kind, {}).setdefault(case, {})
            template = (
                (template or {}).get("variations", {}).get(kind, {}).get(case)
            )
    node["stringUnit"] = {"state": state, "value": value}


def delete_unit(node: dict, path: str) -> None:
    """Remove the leaf at `path`, then every branch it leaves without text.

    A substitution keeps its `argNum` and `formatSpecifier` even once its cases
    are gone, so "is this dict empty" is not the test — `prune` asks whether a
    branch still carries any text, which is what decides whether Xcode would
    still show it.
    """
    current = node
    for step in _parse(path):
        if step[0] == "sub":
            current = current.get("substitutions", {}).get(step[1])
        else:
            _, kind, case = step
            current = current.get("variations", {}).get(kind, {}).get(case)
        if current is None:
            return
    current.pop("stringUnit", None)
    prune(node)


def prune(node: dict) -> bool:
    """Drop every empty branch under `node`; report whether text is left."""
    variations = node.get("variations", {})
    for kind in list(variations):
        cases = variations[kind]
        for case in [c for c in cases if not prune(cases[c])]:
            del cases[case]
        if not cases:
            del variations[kind]
    if not variations:
        node.pop("variations", None)

    substitutions = node.get("substitutions", {})
    for name in list(substitutions):
        if not prune(substitutions[name]):
            del substitutions[name]
    if not substitutions:
        node.pop("substitutions", None)

    return bool(
        "stringUnit" in node or node.get("variations") or node.get("substitutions")
    )


# MARK: - Rows


def rows(catalog: dict, languages: list[str] | None = None) -> Iterator[dict]:
    """Yield one flat record per translated leaf, in catalog order."""
    for key in sorted(catalog.get("strings", {}), key=_natural_key):
        entry = catalog["strings"][key]
        localizations = entry.get("localizations", {})
        source = localizations.get(catalog.get("sourceLanguage", "en"), {})
        source_values = dict(flatten_localization(source))
        for language in sorted(localizations, key=_natural_key):
            if languages is not None and language not in languages:
                continue
            for path, unit in flatten_localization(localizations[language]):
                yield {
                    "key": key,
                    "language": language,
                    "path": path,
                    "state": unit.get("state", "translated"),
                    "value": unit.get("value", ""),
                    "source_value": source_values.get(path, {}).get("value", ""),
                    "comment": entry.get("comment", ""),
                }
