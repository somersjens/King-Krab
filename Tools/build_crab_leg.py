#!/usr/bin/env python3
"""Cut one whole leg out of a run of legs, and lay the run back out of copies.

A crab's legs ship as one drawing: three of them converging on a single hip.
Splitting that drawing into three — a wedge per leg — cuts through the places
where one leg lies over the next, and every one of those cuts shows as a broken
edge the moment the legs swing apart.

So only *one* leg is taken out of the drawing: the one the artist drew last, at
the bottom of the fan, which nothing lies over and whose outline is therefore
whole. The run is then laid back out of copies of it, one where each of the
three legs stood. Every copy is a complete leg with its own outline all the way
round, so nothing can break however far it swings, and the copies overlap deep
in the middle of the fan the way the drawn legs do — three a side, six a crab.

The one leg is cut along two lines:

  * above it, the line the artist drew between it and the next leg along. That
    line is followed rather than guessed: at each radius out of the hip the
    darkest angle inside a small window is the ink of the outline, and stepping
    inwards from the tips — where the two legs stand clear of each other — walks
    the seam all the way down to the hip. The cut is biased a pixel past it, so
    the outline comes away with the leg it belongs to.
  * below it, a plain ray, which crosses nothing but the root the three legs
    share around the hip.

Near the hip the outline between legs vanishes into one mass, and the walker
starts to keep a lobe of that shared root. On the topmost copy nothing covers
it, so it sticks up as a streepje. The upper cut is therefore also capped at the
saddle between the bottom leg and the next — past that angle is the neighbour's
territory. A short pass then shaves any local peak still left on the silhouette.
The root itself is only trimmed a few pixels in from the hip, so each copy still
reaches under the shell and turns on a connector that is actually there.

Where each copy goes is measured off the run it came from: the angle the leg it
replaces stood at, and how much longer or shorter that leg was. The copies are
written out already turned and sized, so the artwork's own placement stays the
rest pose and the arena only ever adds the walk to it.

The 2x crab is not in here. Its run is three bands of a rainbow — the top leg
red, the middle green, the bottom purple — so one of its legs copied into the
other two places would repaint the animal. It keeps its run whole, and swings
it as one.

Run against the shipped assets at any time:

    python3 Tools/build_crab_leg.py            # writes the imagesets
    python3 Tools/build_crab_leg.py --dry-run  # measures only
"""

import math
import os
import shutil
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from measure_leg_cuts import reach_by_angle, hills, measure  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, os.pardir, "King Krab", "Assets 2.xcassets")

# Each run of legs: what its copies are called, the hip they turn on, the angle
# out of that hip where the leg at the bottom of the fan parts from the next one
# along at the tips, and the ray under it that keeps the shared root out. The
# angles are in the drawing's own frame: zero is straight out to the right of
# the hip, and they run downwards.
RUNS = {
    "answer_gold_legs": dict(out="answer_gold_leg", hip=(0.4085, 0.5764),
                             seam=129, floor=72),
    "answer_red_legs": dict(out="answer_red_leg", hip=(0.4089, 0.5767),
                            seam=129, floor=72),
    "life_left_leg": dict(out="life_leg", hip=(0.2870, 0.6105),
                          seam=121, floor=58),
}

# How wide a window the seam is looked for in, and how far past it the cut goes.
WINDOW = 6.0
STEP = 0.4
BIAS = 1.0

# How far in from the hip the absolute tip of the shared root is cut away, as a
# share of the square. Kept short: that buried connector is what a swinging leg
# turns on under the shell.
ROOT = 0.008

# Local silhouette peaks taller than this (in pixels) are shaved after the cut.
SHAVE_RISE = 3
SHAVE_WINDOW = 11

CONTENTS = """{
  "images" : [
    {
      "filename" : "%s.png",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""


def read(name):
    path = os.path.join(ASSETS, f"{name}.imageset", f"{name}.png")
    return Image.open(path).convert("RGBA")


def write_imageset(name, image):
    d = os.path.join(ASSETS, name + ".imageset")
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    image.save(os.path.join(d, name + ".png"), optimize=True)
    with open(os.path.join(d, "Contents.json"), "w") as f:
        f.write(CONTENTS % name)


def polar(pixels, hip):
    height, width = pixels.shape[:2]
    ys, xs = np.mgrid[0:height, 0:width]
    dx, dy = xs - hip[0] * width, ys - hip[1] * height
    return np.degrees(np.arctan2(dy, dx)) % 360, np.hypot(dx, dy)


# ------------------------------------------------------------------- the cut

def darkness(pixels, hip, degrees, radius):
    """How dark the drawing is at one point out of the hip. Background is as
    dark as it gets: past the tips the seam runs through open water."""
    height, width = pixels.shape[:2]
    x = hip[0] * width + radius * math.cos(math.radians(degrees))
    y = hip[1] * height + radius * math.sin(math.radians(degrees))
    xi, yi = int(round(x)), int(round(y))
    if not (0 <= xi < width and 0 <= yi < height):
        return 1.0
    if pixels[yi, xi, 3] < 40:
        return 1.0
    return 1 - pixels[yi, xi, :3].max() / 255 * 0.999


def follow_seam(pixels, hip, start, outer, inner):
    """The line between two legs, walked from the tips down to the hip."""
    radii, angles = [], []
    angle = start
    for radius in range(outer, inner - 1, -1):
        best, darkest = angle, -1.0
        steps = int(WINDOW / STEP)
        for k in range(-steps, steps + 1):
            trial = angle + k * STEP
            # A pull towards where the line already was, so the walk follows
            # one line instead of wandering off into the next shadow.
            here = darkness(pixels, hip, trial, radius) - abs(k * STEP) * 0.004
            if here > darkest:
                darkest, best = here, trial
        radii.append(radius)
        angles.append(best)
        angle = best
    return np.array(radii[::-1]), np.array(angles[::-1])


def shave_top_peaks(rgba):
    """Drop columns that stick above the median top-edge of their neighbours."""
    alpha = rgba[:, :, 3]
    opaque = alpha > 16
    height, width = opaque.shape
    tops = np.full(width, height, dtype=int)
    ys, xs = np.nonzero(opaque)
    for x, y in zip(xs, ys):
        if y < tops[x]:
            tops[x] = y
    half = SHAVE_WINDOW // 2
    out = rgba.copy()
    for x in range(width):
        if tops[x] >= height:
            continue
        vals = [tops[x2] for x2 in range(max(0, x - half), min(width, x + half + 1))
                if tops[x2] < height]
        if not vals:
            continue
        smooth = int(np.median(vals))
        if smooth - tops[x] >= SHAVE_RISE:
            out[tops[x]:smooth, x, 3] = 0
    return out


def cut(pixels, spec, reach, saddle):
    """The one leg, alone on the run's own square."""
    hip = spec["hip"]
    width = pixels.shape[1]
    angle, radius = polar(pixels, hip)
    radii, seam = follow_seam(pixels, hip, spec["seam"],
                              int(reach * 0.92), 4)
    seam = seam + np.degrees(BIAS / np.maximum(radii, 1))
    limit = np.interp(np.clip(radius, radii.min(), radii.max()), radii, seam)
    # Past the saddle between this leg and the next is the neighbour's root.
    upper = np.minimum(limit, float(saddle))
    keep = ((angle <= upper) & (angle >= spec["floor"])
            & (radius >= ROOT * width))
    out = pixels.copy()
    out[:, :, 3] = out[:, :, 3] * keep
    return Image.fromarray(shave_top_peaks(out))


# ------------------------------------------------------------------- placing

def place(im, hip, degrees, scale):
    """A copy turned to where its leg stood, and sized to how long it was."""
    width, height = im.size
    centre = (hip[0] * width, hip[1] * height)
    out = im.rotate(-degrees, resample=Image.BICUBIC, center=centre)
    if abs(scale - 1) > 1e-4:
        k = 1 / scale
        out = out.transform(out.size, Image.AFFINE,
                            (k, 0, centre[0] * (1 - k), 0, k, centre[1] * (1 - k)),
                            resample=Image.BICUBIC)
    return out


def build(name, spec, write=True):
    pixels = np.array(read(name))
    reach = polar(pixels, spec["hip"])[1][pixels[:, :, 3] > 16].max()
    curve = reach_by_angle(name, spec["hip"])
    stood = hills(curve)                       # where the three legs stand
    lengths = [float(curve[a]) for a in stood]
    _legs, saddles = measure(name, spec["hip"])
    saddle = saddles[0][0]

    leg = cut(pixels, spec, reach, saddle)
    made = []
    for index, angle in enumerate(stood):
        scale = lengths[index] / lengths[0]
        made.append((f"{spec['out']}{index + 1}", angle - stood[0], scale))
        if write:
            write_imageset(made[-1][0],
                           place(leg, spec["hip"], angle - stood[0], scale))
    return made


if __name__ == "__main__":
    dry = "--dry-run" in sys.argv
    for name, spec in RUNS.items():
        for asset, angle, scale in build(name, spec, write=not dry):
            print(f"{asset}: turned {angle:+.0f}°, sized {scale:.3f}"
                  + ("  (not written)" if dry else ""))
