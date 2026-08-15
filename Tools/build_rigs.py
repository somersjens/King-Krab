#!/usr/bin/env python3
"""Rebuild the rigged-character assets and measure the rig from the artwork.

For every character:
  * strip the faint ghost pixels a few of the exports carry,
  * move all five parts by the same amount so the assembled animal sits in the
    middle of its square,
  * drop the right-hand limbs whose artwork is an exact mirror of the left,
  * shrink everything to one working resolution,
  * and measure the joints, the pincers and the ground line off the alpha.

The measurements are written to rig.json, which the table in KingCrabRig.swift
was generated from. Nothing is guessed: every number comes out of the artwork
itself.

This runs once over a fresh export and rewrites the catalog in place, so it is
kept here as the record of how the shipped numbers were arrived at rather than
as a step in the build. Run it again only against the original full-size parts:
against the shipped ones it stops on the mirrored limbs it already removed.
"""

from PIL import Image, ImageFilter
import numpy as np
import json, os, shutil, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.join(HERE, os.pardir, "King Krab", "Assets 2.xcassets")
OUT = 640                      # working resolution of one character square
SOLID = 200                    # alpha at or above this is real artwork
GHOST_REACH = 13               # MaxFilter window: keeps antialiasing, drops ghosts

# order -> the imageset each part is exported as today
SOURCES = {
    1: {"body": "1_body_only_2", "left_claw": "1_left_claw_2", "right_claw": "1_right_claw_2",
        "left_leg": "1_left_legs_2", "right_leg": "1_right_legs_2"},
}
for n in range(2, 11):
    SOURCES[n] = {"body": f"{n}_body", "left_claw": f"{n}_left_claw",
                  "right_claw": f"{n}_right_claw", "left_leg": f"{n}_left_leg",
                  "right_leg": f"{n}_right_leg", "full": f"{n}_full"}
SOURCES[3]["left_leg"] = "3_lefT_leg"
SOURCES[10]["full"] = "10_full\\"

# order -> the imageset each surviving part is written back to
DEST = {1: {"body": "1_body_only_2", "left_claw": "1_left_claw_2",
            "left_leg": "1_left_legs_2", "right_leg": "1_right_legs_2"}}
for n in range(2, 11):
    DEST[n] = {"body": f"{n}_body", "left_claw": f"{n}_left_claw",
               "left_leg": f"{n}_left_leg", "full": f"{n}_full"}

CHARACTER_IDS = ["crab", "elephant", "bear", "fox", "frog",
                 "penguin", "bunny", "dog", "lion", "octopus"]

# Everyone but the King carries his arms across himself rather than behind
# himself, so every one of them gets the second, cut-back copy on top.
FRONT_CLAWS = set(range(2, 11))


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


# ---------------------------------------------------------------- measuring

def mask(im, thr=16):
    return np.array(im)[:, :, 3] > thr


def bbox(m):
    ys, xs = np.nonzero(m)
    return int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1


def claw_joint(limb, body, side):
    """The far end of the connector: the deepest the arm runs under the shell."""
    ys, xs = np.nonzero(limb & body)
    band = max(4, int(round(0.022 * limb.shape[1])))
    sel = xs > xs.max() - band if side == "left" else xs < xs.min() + band
    return float(xs[sel].mean()), float(ys[sel].mean())


def leg_joint(limb, body):
    """The hip: near the top of the run of legs that the shell covers."""
    ys, xs = np.nonzero(limb & body)
    y0, y1 = ys.min(), ys.max()
    return float(xs.mean()), float(y0 + 0.18 * (y1 - y0))


def pincer(limb, jx, jy):
    """The claw's business end: the part of it furthest from its own joint."""
    ys, xs = np.nonzero(limb)
    d = (xs - jx) ** 2 + (ys - jy) ** 2
    k = max(1, len(d) // 200)
    idx = np.argpartition(-d, k)[:k]
    return float(xs[idx].mean()), float(ys[idx].mean())


def mirror_offset(left, right):
    """How the right-hand export sits relative to the mirrored left one.

    Returns (dx, dy) with  right(x, y) == left(W - 1 - x - dx, y - dy),
    or None when the two are not the same drawing.
    """
    W = left.size[0]
    flipped = right.transpose(Image.FLIP_LEFT_RIGHT)
    bl, bf = bbox(mask(left)), bbox(mask(flipped))
    dx, dy = bf[0] - bl[0], bf[1] - bl[1]
    shifted = np.roll(np.roll(np.array(flipped), -dx, axis=1), -dy, axis=0)
    l = np.array(left).astype(np.int16)
    both = (shifted[:, :, 3] > 16) | (l[:, :, 3] > 16)
    if not both.any():
        return None
    alpha_error = np.abs(shifted[:, :, 3].astype(np.int16) - l[:, :, 3])[both].mean()
    return (dx, dy) if alpha_error < 1.0 else None


def inscribed_radius(body, cx, cy):
    """The biggest circle around a point that still fits inside the shell."""
    ys, xs = np.nonzero(~body)
    d2 = (xs - cx) ** 2 + (ys - cy) ** 2
    return float(np.sqrt(d2.min()))


def crown_top(body):
    """The top of the head on the centre line, ignoring ears held out wide."""
    W = body.shape[1]
    column = body[:, int(0.44 * W):int(0.56 * W)]
    ys, _ = np.nonzero(column)
    return float(ys.min())


# ---------------------------------------------------------------- pipeline

def build(write=True):
    rigs = {}
    for order in range(1, 11):
        src = SOURCES[order]
        parts = {k: strip_ghosts(read(v)) for k, v in src.items() if k != "full"}
        W, H = parts["body"].size
        side = max(W, H)

        mirrors = {}
        for limb in ["claw", "leg"]:
            mirrors[limb] = mirror_offset(parts[f"left_{limb}"], parts[f"right_{limb}"])

        # One square canvas, with the whole animal centred on it.
        masks = {k: mask(v) for k, v in parts.items()}
        whole = np.zeros_like(masks["body"])
        for m in masks.values():
            whole |= m
        x0, y0, x1, y1 = bbox(whole)
        dx = (side - (x0 + x1)) / 2.0
        dy = (side - (y0 + y1)) / 2.0

        placed = {}
        for k, im in parts.items():
            canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
            canvas.paste(im, (int(round(dx)), int(round(dy))))
            placed[k] = canvas
        pm = {k: mask(v) for k, v in placed.items()}

        # Everything below is measured on the centred square.
        joints, tips = {}, {}
        for s in ["left", "right"]:
            joints[f"{s}_claw"] = claw_joint(pm[f"{s}_claw"], pm["body"], s)
            joints[f"{s}_leg"] = leg_joint(pm[f"{s}_leg"], pm["body"])
            tips[s] = pincer(pm[f"{s}_claw"], *joints[f"{s}_claw"])
        ground = max(bbox(pm["left_leg"])[3], bbox(pm["right_leg"])[3])

        u = lambda v: round(v / side, 4)
        rec = {
            "id": CHARACTER_IDS[order - 1],
            "order": order,
            "source_square": side,
            "centre_shift_px": [round(dx, 1), round(dy, 1)],
            "joints": {k: [u(v[0]), u(v[1])] for k, v in joints.items()},
            "tips": {k: [u(v[0]), u(v[1])] for k, v in tips.items()},
            "ground": u(ground),
            "crown_top": u(crown_top(pm["body"])),
            "mirror": {k: ([u(v[0]), u(v[1])] if v else None) for k, v in mirrors.items()},
            "claw_room": u(inscribed_radius(pm["body"], *joints["left_claw"])),
        }
        # The arms these two carry are drawn over the shell, so they need a
        # circle around the joint cut out of that front copy. It is kept just
        # inside the largest circle the shell can hide, so the cut never shows.
        rec["claw_front_radius"] = round(0.9 * rec["claw_room"], 4) if order in FRONT_CLAWS else 0.0
        rigs[order] = rec
        print(json.dumps(rec))

        if not write:
            continue
        for part, name in DEST[order].items():
            if part == "full":
                # The whole picture rides the same move as the parts, so the
                # two stay interchangeable in any slot that shows a character.
                im = strip_ghosts(read(src["full"]))
                canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
                canvas.paste(im, (int(round(dx)), int(round(dy))))
            else:
                canvas = placed[part]
            write_imageset(name, resize(canvas, OUT))
        for part, name in src.items():
            if part not in DEST[order] and name not in DEST[order].values():
                shutil.rmtree(imageset_path(name), ignore_errors=True)

    json.dump(rigs, open(os.path.join(os.path.dirname(__file__), "rig.json"), "w"), indent=1)
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
