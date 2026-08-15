#!/usr/bin/env python3
"""Rebuild the two helper crabs and measure their rigs off the artwork.

The 2x crab and the life crab are drawn the same way the ten characters are —
a body and four limbs registered to each other on one square — so this is the
same pipeline as `build_rigs.py`, with two differences the exports forced:

  * the 2x crab's "body" was exported as the *whole* animal, limbs and all. The
    limb PNGs are the exact pixels that were composited into it, so the body on
    its own is that picture with every pixel a limb can account for taken back
    out. Where the shell covers a buried connector the two disagree — the full
    picture has the shell's colour there — which is precisely what keeps the
    carapace whole while the arms come away from it.

  * both crabs hold their claws up over their heads, which is where the reward
    they carry rides. The two pincers are measured for it, so the token sits in
    the claws rather than floating over the animal.

Everything else matches the character pipeline: the parts are moved as a set
until the assembled crab sits in the middle of its square, the mirrored halves
are dropped, and the survivors are written back at one working resolution.

Run against the original full-size export; against the shipped assets it stops
on the mirrored limbs it has already removed.
"""

from PIL import Image, ImageFilter, ImageDraw
import numpy as np
import json, os, shutil, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, os.pardir, "King Krab", "Assets 2.xcassets")
OUT = 512                      # working resolution of one crab square
SOLID = 200                    # alpha at or above this is real artwork
GHOST_REACH = 13               # MaxFilter window: keeps antialiasing, drops ghosts
# How close a pixel of a limb has to be to the assembled picture to count as
# that limb showing through it rather than the shell lying over it.
COMPOSITE_TOLERANCE = 12
# Nothing thinner than this is part of the shell's own body: it is the window
# the carapace is found through, and every stray hairline is thinner than it.
CORE_REACH = 15
# How far either side of the bounding-box guess a mirrored limb is looked for.
MIRROR_SEARCH = 24

FAMILIES = ["2x", "life"]
# The 2x export is the whole animal; the life export is a body on its own.
BODY_IS_WHOLE = {"2x"}

PARTS = ["body", "left_claw", "right_claw", "left_leg", "right_leg"]
KEEP = ["body", "left_claw", "left_leg"]


# ---------------------------------------------------------------- loading

def imageset_path(name):
    return os.path.join(ASSETS, name + ".imageset")


def read(name):
    d = imageset_path(name)
    pngs = [f for f in os.listdir(d) if f.lower().endswith(".png")]
    return Image.open(os.path.join(d, pngs[0])).convert("RGBA")


def strip_ghosts(im):
    """Zero the faint detached specks some exports carry, keep antialiasing."""
    a = np.array(im)
    alpha = a[:, :, 3]
    solid = Image.fromarray(((alpha >= SOLID) * 255).astype(np.uint8))
    near = np.array(solid.filter(ImageFilter.MaxFilter(GHOST_REACH))) > 0
    a[:, :, 3] = np.where(near, alpha, 0)
    return Image.fromarray(a)


def resize(im, side):
    """Resize through premultiplied alpha, so edges keep their own colour."""
    a = np.array(im).astype(np.float32)
    al = a[:, :, 3:4] / 255.0
    pre = np.concatenate([a[:, :, :3] * al, a[:, :, 3:4]], axis=2).astype(np.uint8)
    r = np.array(Image.fromarray(pre).resize((side, side), Image.LANCZOS)).astype(np.float32)
    out_a = np.clip(r[:, :, 3:4], 0, 255)
    rgb = np.where(out_a > 0, r[:, :, :3] / np.maximum(out_a / 255.0, 1e-6), 0)
    return Image.fromarray(np.concatenate([np.clip(rgb, 0, 255), out_a], axis=2).astype(np.uint8))


# ------------------------------------------------------- pulling a body out

def dilate(m, window):
    return np.array(
        Image.fromarray((m * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(window))
    ) > 0


def open_mask(m, window):
    """Drop everything thinner than the window, keep everything thicker."""
    im = Image.fromarray((m * 255).astype(np.uint8))
    return np.array(im.filter(ImageFilter.MinFilter(window))
                      .filter(ImageFilter.MaxFilter(window))) > 0


def body_from_whole(whole, limbs):
    """The shell on its own, taken out of a picture of the whole animal.

    A pixel belongs to a limb when the limb's own drawing explains it exactly;
    where the shell was composited over a limb the two differ, and the pixel
    stays. That leaves the whole shell — and, around every arm, a hairline of
    the outline the assembled picture carries and the limb export does not.

    Those hairlines are cleared by taking out the limbs' whole footprint,
    grown a little, and putting back only what falls inside the shell's own
    solid core: the arms leave nothing of themselves behind, while the piece
    of carapace that was drawn over a buried connector stays exactly as drawn.
    Whatever is left over and no longer joined to the shell goes with them.
    """
    full = np.array(whole).astype(np.int16)
    same = np.zeros(full.shape[:2], bool)
    covered = np.zeros(full.shape[:2], bool)
    for limb in limbs:
        l = np.array(limb).astype(np.int16)
        drawn = l[:, :, 3] > 0
        covered |= drawn
        matches = np.abs(l[:, :, :3] - full[:, :, :3]).max(axis=2) <= COMPOSITE_TOLERANCE
        alike = np.abs(l[:, :, 3] - full[:, :, 3]) <= COMPOSITE_TOLERANCE
        same |= drawn & matches & alike

    core = piece(open_mask((full[:, :, 3] >= 64) & ~same, CORE_REACH),
                 seed(full[:, :, 3] >= SOLID))
    out = full.copy()
    out[:, :, 3] = np.where(same | (dilate(covered, 9) & ~dilate(core, 5)),
                            0, out[:, :, 3])
    return Image.fromarray(largest_piece(out).astype(np.uint8))


def seed(m):
    ys, xs = np.nonzero(m)
    return int(round(xs.mean())), int(round(ys.mean()))


def piece(m, at):
    """The one run of set pixels that the given point is part of."""
    canvas = Image.fromarray((m * 255).astype(np.uint8)).copy()
    ImageDraw.floodfill(canvas, at, 128)
    return np.array(canvas) == 128


def largest_piece(rgba):
    """Only the connected run of artwork the middle of the picture is part of."""
    alpha = rgba[:, :, 3]
    kept = dilate(piece(alpha >= 64, seed(alpha >= SOLID)), 5)
    out = rgba.copy()
    out[:, :, 3] = np.where(kept, alpha, 0)
    return out


# ---------------------------------------------------------------- measuring

def mask(im, thr=16):
    return np.array(im)[:, :, 3] > thr


def bbox(m):
    ys, xs = np.nonzero(m)
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def centroid(m):
    ys, xs = np.nonzero(m)
    return float(xs.mean()), float(ys.mean())


def claw_tip(limb, at):
    """The claw's business end: the part of it that reaches furthest out of the
    middle of the animal. Both of these crabs hold their claws up over their
    heads, so this is the hand the reward they carry rides in."""
    return furthest(limb, at)


def claw_joint(limb, body, tip):
    """The far end of the connector: the deepest the arm runs under the shell.

    Measured as the buried point furthest from the claw's own hand, which is
    the length of the arm however the arm is posed. Taking the deepest point
    across the picture instead would find the shoulder of a claw held up beside
    the head, where the arm brushes past the brow on its way up.
    """
    return furthest(limb & body, tip)


def furthest(m, at):
    """The far end of a run of pixels, as seen from a point."""
    ys, xs = np.nonzero(m)
    d = (xs - at[0]) ** 2 + (ys - at[1]) ** 2
    k = max(1, len(d) // 200)
    idx = np.argpartition(-d, k)[:k]
    return float(xs[idx].mean()), float(ys[idx].mean())


def leg_joint(limb, body):
    """The hip: near the top of the run of legs that the shell covers."""
    ys, xs = np.nonzero(limb & body)
    y0, y1 = ys.min(), ys.max()
    return float(xs.mean()), float(y0 + 0.18 * (y1 - y0))


def mirror_offset(left, right):
    """How the right-hand export sits relative to the mirrored left one.

    Returns (dx, dy) with  right(x, y) == left(W - 1 - x - dx, y - dy), or None
    when the two are not the same drawing. The bounding boxes give the shift to
    within a few pixels — a speck of stray artwork on one side is enough to move
    one — so the neighbourhood around that guess is searched for the placement
    the two actually agree on.
    """
    flipped = np.array(right.transpose(Image.FLIP_LEFT_RIGHT)).astype(np.int16)
    l = np.array(left).astype(np.int16)
    bl, bf = bbox(mask(left)), bbox(bbox_mask(flipped))
    guess = (bf[0] - bl[0], bf[1] - bl[1])

    best = None
    for dy in range(guess[1] - MIRROR_SEARCH, guess[1] + MIRROR_SEARCH + 1):
        for dx in range(guess[0] - MIRROR_SEARCH, guess[0] + MIRROR_SEARCH + 1):
            shifted = np.roll(np.roll(flipped, -dx, axis=1), -dy, axis=0)
            both = (shifted[:, :, 3] > 16) | (l[:, :, 3] > 16)
            if not both.any():
                continue
            error = np.abs(shifted[:, :, 3] - l[:, :, 3])[both].mean()
            if best is None or error < best[0]:
                best = (error, dx, dy)
    if best is None or best[0] >= 1.0:
        return None
    return best[1], best[2]


def bbox_mask(a):
    return a[:, :, 3] > 16


def inscribed_radius(body, cx, cy):
    """The biggest circle around a point that still fits inside the shell."""
    ys, xs = np.nonzero(~body)
    return float(np.sqrt(((xs - cx) ** 2 + (ys - cy) ** 2).min()))


# ---------------------------------------------------------------- pipeline

def build(write=True):
    rigs = {}
    for family in FAMILIES:
        raw = {p: strip_ghosts(read(f"{family}_{p}")) for p in PARTS}
        if family in BODY_IS_WHOLE:
            raw["body"] = body_from_whole(
                raw["body"], [raw[p] for p in PARTS if p != "body"])
        side = max(raw["body"].size)

        mirrors = {limb: mirror_offset(raw[f"left_{limb}"], raw[f"right_{limb}"])
                   for limb in ["claw", "leg"]}

        # One square canvas, with the whole animal centred on it.
        masks = {k: mask(v) for k, v in raw.items()}
        whole = np.zeros_like(masks["body"])
        for m in masks.values():
            whole |= m
        x0, y0, x1, y1 = bbox(whole)
        dx = (side - (x0 + x1)) / 2.0
        dy = (side - (y0 + y1)) / 2.0

        placed = {}
        for k, im in raw.items():
            canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
            canvas.paste(im, (int(round(dx)), int(round(dy))))
            placed[k] = canvas
        pm = {k: mask(v) for k, v in placed.items()}

        middle = centroid(pm["body"])
        joints, tips = {}, {}
        for s in ["left", "right"]:
            tips[s] = claw_tip(pm[f"{s}_claw"], middle)
            joints[f"{s}_claw"] = claw_joint(pm[f"{s}_claw"], pm["body"], tips[s])
            joints[f"{s}_leg"] = leg_joint(pm[f"{s}_leg"], pm["body"])
        ground = max(bbox(pm["left_leg"])[3], bbox(pm["right_leg"])[3])
        bx0, _, bx1, _ = bbox(pm["body"])

        u = lambda v: round(v / side, 4)
        rec = {
            "id": family,
            "source_square": side,
            "centre_shift_px": [round(dx, 1), round(dy, 1)],
            "joints": {k: [u(v[0]), u(v[1])] for k, v in joints.items()},
            "tips": {k: [u(v[0]), u(v[1])] for k, v in tips.items()},
            "ground": u(ground),
            "body_width": u(bx1 - bx0),
            "mirror": {k: ([u(v[0]), u(v[1])] if v else None) for k, v in mirrors.items()},
            "claw_room": u(inscribed_radius(pm["body"], *joints["left_claw"])),
        }
        rigs[family] = rec
        print(json.dumps(rec))

        if not write:
            continue
        for part in KEEP:
            write_imageset(f"{family}_{part}", resize(placed[part], OUT))
        for part in PARTS:
            if part not in KEEP:
                shutil.rmtree(imageset_path(f"{family}_{part}"), ignore_errors=True)

    json.dump(rigs, open(os.path.join(HERE, "helper_crabs.json"), "w"), indent=1)
    return rigs


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


def write_imageset(name, image):
    d = imageset_path(name)
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    image.save(os.path.join(d, name + ".png"), optimize=True)
    with open(os.path.join(d, "Contents.json"), "w") as f:
        f.write(CONTENTS % name)


if __name__ == "__main__":
    build(write="--dry-run" not in sys.argv)
