#!/usr/bin/env python3
"""Derive the small character pictures from the shipped full-length ones.

The menus have two very different slots for the same animal: a hero, drawn at
a couple of hundred points, and a chip drawn at forty-odd. Handing the chip the
hero's picture makes the renderer decode a 640-pixel square to paint something
the size of a stamp — ten of those is most of what the shop pays to open.

So each character also ships at 192 pixels, which covers the largest chip on
the largest iPad — the shop's grid draws the animal at about 90 points there,
or 180 pixels at 2x — and the small slots ask for that one instead.

Idempotent: it reads the full-length assets that are already in the catalog and
writes the thumbnails beside them, so it can be re-run after any re-export.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_rigs import CHARACTER_IDS, read, resize, write_imageset  # noqa: E402

THUMB = 192


def full_name(order):
    """The whole-animal asset for a character, matching `fullImageName`."""
    return "1_main" if order == 1 else f"{order}_full"


def main():
    for order in range(1, len(CHARACTER_IDS) + 1):
        source = read(full_name(order))
        write_imageset(f"{order}_thumb", resize(source, THUMB))
        print(f"{order}_thumb  <- {full_name(order)} {source.size} -> {THUMB}")


if __name__ == "__main__":
    main()
