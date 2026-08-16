#!/usr/bin/env python3
"""Measure how a run of legs is laid out: where each leg stands, and how long.

Every crab in the arena that is drawn rather than solved carries its legs as one
picture: three legs converging on a single hip. Take the furthest that picture
reaches at each angle out of the hip and it reads as three hills with a saddle
in each dip — one hill per leg, standing at the angle the leg points and as high
as the leg is long, and a saddle where a line out of the hip gets past the legs
on the least of their artwork.

Those are the numbers a run is rebuilt from: build_crab_leg.py cuts one whole
leg out of the drawing along the saddle beside it, and lays copies of it back
out on the hills. This module is the measuring half of that, kept apart because
it is also worth running on its own to see what a run is made of.

Unlike build_rigs.py and build_helper_crabs.py, this reads the shipped assets —
the run of legs ships whole — so it can be run at any time:

    python3 Tools/measure_leg_cuts.py
"""

import os

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, os.pardir, "King Krab", "Assets 2.xcassets")

# The runs of legs the arena walks on, with the hip each one turns around —
# the joints already measured into AnswerCrabRig.swift and KingCrabRig.swift.
RUNS = {
    "answer_gold_legs": (0.4085, 0.5764),
    "answer_red_legs": (0.4089, 0.5767),
    "2x_left_leg": (0.2904, 0.6109),
    "life_left_leg": (0.2870, 0.6105),
}

# How far apart two hills have to be to be two legs rather than one lumpy one.
APART = 9
# …and how much of the run's own reach a hill has to stand up out of.
PROMINENCE = 0.5


def read(name):
    path = os.path.join(ASSETS, f"{name}.imageset", f"{name}.png")
    return Image.open(path).convert("RGBA")


def reach_by_angle(name, hip):
    """How far the drawing reaches at each degree out of the hip, as a share of
    the square. Zero where the run has nothing at that angle at all."""
    alpha = np.array(read(name))[:, :, 3]
    height, width = alpha.shape
    ys, xs = np.nonzero(alpha > 16)
    dx, dy = xs - hip[0] * width, ys - hip[1] * height
    angle = np.floor(np.degrees(np.arctan2(dy, dx)) % 360).astype(int)
    radius = np.hypot(dx, dy) / width
    out = np.zeros(360)
    np.maximum.at(out, angle, radius)
    return out


def hills(curve):
    """The angles the legs themselves reach furthest at: one hill per leg."""
    tall = curve.max() * PROMINENCE
    peaks = [a for a in range(360)
             if curve[a] >= tall
             and curve[a] == curve[max(0, a - APART):a + APART + 1].max()]
    kept = []
    for a in peaks:                    # one hill can top out over several bins
        if kept and a - kept[-1] <= APART:
            if curve[a] > curve[kept[-1]]:
                kept[-1] = a
        else:
            kept.append(a)
    return kept


def measure(name, hip):
    """The angle and length of each leg, and the saddle between neighbours."""
    curve = reach_by_angle(name, hip)
    tops = hills(curve)
    saddles = []
    for left, right in zip(tops, tops[1:]):
        at = left + int(np.argmin(curve[left:right + 1]))
        saddles.append((at, curve[at]))
    return [(a, curve[a]) for a in tops], saddles


if __name__ == "__main__":
    for name, hip in RUNS.items():
        legs, saddles = measure(name, hip)
        print(f"{name}:  {len(legs)} legs")
        for angle, reach in legs:
            print(f"    leg at {angle}°, reaching {reach:.3f} of the square")
        for angle, over in saddles:
            print(f"    saddle at {angle}°, clearing the run past {over:.3f}")
