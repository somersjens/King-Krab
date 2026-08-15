#!/usr/bin/env python3
"""Rebuild the answer crabs' artwork and measure their rig from it.

The two answer crabs — the red one that carries a wrong answer and the gold one
that carries the right one — are the same drawing in two colours, and each is
delivered as a body, one claw, one run of legs and two loose pupils. The other
side's claw and legs are in the export as well, but they are that same drawing
mirrored, pixel for pixel, so only one of each is kept and the sprite mirrors it
back at draw time.

The drawing is made for a crab standing on the left of the King. One on his
right is the whole sprite flipped, which is what puts its near claw on the side
nearest him.

As with the King's own rig, every number is measured off the alpha rather than
guessed: the shoulder each claw turns on, the mouth of the claw that the answer
shell is held in, the hips, the line the feet stand on, and the two eye whites
the pupils have to stay inside.
"""

import json
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from build_rigs import read, resize, write_imageset, mask, bbox  # noqa: E402

OUT = 512          # the sprite is drawn at about 430 device pixels at its largest
SMALL = 256        # working size for the shape operations below

SOURCES = {
    "gold": {"body": "gold body", "claw": "gold claw left", "claw_r": "gold claw right",
             "legs": "gold left left", "legs_r": "gold legs left"},
    "red": {"body": "red body", "claw": "red claw left", "claw_r": "red claw right",
            "legs": "red left legs", "legs_r": "red right lefs"},
}
PUPILS = {"left": "left eye", "right": "right_eye"}

DEST = {tint: {"body": f"answer_{tint}_body", "claw": f"answer_{tint}_claw",
               "legs": f"answer_{tint}_legs"} for tint in SOURCES}
PUPIL_DEST = {"left": "answer_eye_left", "right": "answer_eye_right"}


# ---------------------------------------------------------------- shape tools

def mirror_offset(left, right):
    """(dx, dy) with right(x, y) == left(W - 1 - x - dx, y - dy), or None."""
    flipped = right.transpose(Image.FLIP_LEFT_RIGHT)
    bl, bf = bbox(mask(left)), bbox(mask(flipped))
    dx, dy = bf[0] - bl[0], bf[1] - bl[1]
    shifted = np.roll(np.roll(np.array(flipped), -dx, axis=1), -dy, axis=0)
    l = np.array(left).astype(np.int16)
    both = (shifted[:, :, 3] > 16) | (l[:, :, 3] > 16)
    error = np.abs(shifted[:, :, 3].astype(np.int16) - l[:, :, 3])[both].mean()
    return (dx, dy) if error < 1.0 else None


def close(m, radius):
    """Binary closing, done small. Filling the mouth of a claw needs a kernel as
    wide as the gap, which is ruinous at full size and pointless at any."""
    im = Image.fromarray((m * 255).astype(np.uint8)).resize((SMALL, SMALL), Image.NEAREST)
    k = max(3, int(round(radius * 2 * SMALL / m.shape[0])) | 1)
    closed = im.filter(ImageFilter.MaxFilter(k)).filter(ImageFilter.MinFilter(k))
    return np.array(closed.resize(m.shape[::-1], Image.NEAREST)) > 127


def blobs(m):
    """Connected components of a small boolean mask, largest first."""
    h, w = m.shape
    seen = np.zeros_like(m, dtype=bool)
    found = []
    for sy in range(h):
        for sx in range(w):
            if not m[sy, sx] or seen[sy, sx]:
                continue
            stack, pixels = [(sy, sx)], []
            seen[sy, sx] = True
            while stack:
                y, x = stack.pop()
                pixels.append((y, x))
                for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                    if 0 <= ny < h and 0 <= nx < w and m[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
            found.append(pixels)
    return sorted(found, key=len, reverse=True)


# ---------------------------------------------------------------- measuring

def shoulder(claw):
    """The buried end of the arm, which is what the claw turns around.

    The arm runs down and inward and stops under the shell, so its far end is
    the corner of the drawing furthest along that diagonal. Reading it off the
    claw's own outline rather than off its overlap with the body is what makes
    it come out the same for both colours: the overlap is a long thin sliver
    down the shell's flank, and its deepest point wanders."""
    ys, xs = np.nonzero(claw)
    score = xs + ys
    k = max(1, len(score) // 50)
    idx = np.argpartition(-score, k)[:k]
    return float(xs[idx].mean()), float(ys[idx].mean())


def pincer(claw_image, side):
    """The mouth of the claw: the hollow that closing the shape fills in."""
    m = mask(claw_image)
    notch = close(m, int(m.shape[0] * 0.035)) & ~m
    ys, xs = np.nonzero(notch)
    keep = ys < np.percentile(ys, 40)          # the mouth opens upward
    return float(xs[keep].mean()), float(ys[keep].mean())


def hip(legs, body):
    ys, xs = np.nonzero(legs & body)
    return float(xs.mean()), float(ys.min() + 0.18 * (ys.max() - ys.min()))


def eye_whites(body):
    """The two whites of the eyes: the largest white things on the animal. The
    teeth are the next one down and much smaller, so taking the two biggest
    blobs finds the eyes without having to say where a face is."""
    a = np.array(body)
    rgb = a[:, :, :3].astype(np.int16)
    white = (a[:, :, 3] > 200) & (rgb.min(axis=2) > 195) & \
            (rgb.max(axis=2) - rgb.min(axis=2) < 34)
    scale = a.shape[0] / SMALL
    small = np.array(Image.fromarray((white * 255).astype(np.uint8))
                     .resize((SMALL, SMALL), Image.BILINEAR)) > 140
    boxes = []
    for pixels in blobs(small)[:2]:
        ys = np.array([p[0] for p in pixels])
        xs = np.array([p[1] for p in pixels])
        boxes.append((xs.min() * scale, ys.min() * scale,
                      (xs.max() + 1) * scale, (ys.max() + 1) * scale))
    boxes.sort(key=lambda b: b[0])
    return {"left": boxes[0], "right": boxes[1]}


# ---------------------------------------------------------------- pipeline

def build(write=True):
    out = {}
    pupils = {k: read(v) for k, v in PUPILS.items()}
    for tint, names in SOURCES.items():
        ims = {k: read(v) for k, v in names.items()}
        side = ims["body"].size[0]
        M = {k: mask(v) for k, v in ims.items()}

        mirrors = {"claw": mirror_offset(ims["claw"], ims["claw_r"]),
                   "legs": mirror_offset(ims["legs"], ims["legs_r"])}
        assert all(mirrors.values()), f"{tint}: a side is not a mirror of the other"

        whole = np.zeros_like(M["body"])
        for m in M.values():
            whole |= m
        x0, y0, x1, y1 = bbox(whole)
        dx, dy = (side - (x0 + x1)) / 2.0, (side - (y0 + y1)) / 2.0

        def u(p):
            return [round((p[0] + dx) / side, 4), round((p[1] + dy) / side, 4)]

        def mirrored(p, shift):
            """Where a point on the left-hand drawing lands on the right one."""
            raw = (p[0] * side - dx, p[1] * side - dy)
            return u((side - 1 - shift[0] - raw[0], raw[1] + shift[1]))

        rec = {"centre_shift_px": [round(dx, 1), round(dy, 1)]}
        rec["claw_joint"] = u(shoulder(M["claw"]))
        rec["claw_pincer"] = u(pincer(ims["claw"], "left"))
        rec["leg_hip"] = u(hip(M["legs"], M["body"]))
        rec["claw_mirror"] = [round(-mirrors["claw"][0] / side, 4),
                              round(mirrors["claw"][1] / side, 4)]
        rec["leg_mirror"] = [round(-mirrors["legs"][0] / side, 4),
                             round(mirrors["legs"][1] / side, 4)]
        rec["claw_joint_r"] = mirrored(rec["claw_joint"], mirrors["claw"])
        rec["claw_pincer_r"] = mirrored(rec["claw_pincer"], mirrors["claw"])
        rec["leg_hip_r"] = mirrored(rec["leg_hip"], mirrors["legs"])
        rec["ground"] = round((max(bbox(M["legs"])[3], bbox(M["legs_r"])[3]) + dy) / side, 4)
        rec["body_width"] = round((bbox(M["body"])[2] - bbox(M["body"])[0]) / side, 4)
        rec["eye_white"] = {k: [round((v[0] + dx) / side, 4), round((v[1] + dy) / side, 4),
                                round((v[2] + dx) / side, 4), round((v[3] + dy) / side, 4)]
                            for k, v in eye_whites(ims["body"]).items()}
        rec["pupil"] = {}
        for k, im in pupils.items():
            b = bbox(mask(im))
            rec["pupil"][k] = [round((b[0] + dx) / side, 4), round((b[1] + dy) / side, 4),
                               round((b[2] + dx) / side, 4), round((b[3] + dy) / side, 4)]
        out[tint] = rec

        if not write:
            continue
        for part, name in DEST[tint].items():
            canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
            canvas.paste(ims[part], (int(round(dx)), int(round(dy))))
            write_imageset(name, resize(canvas, OUT))
        if tint == "gold":            # the pupils are shared; place them once
            for k, im in pupils.items():
                canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
                canvas.paste(im, (int(round(dx)), int(round(dy))))
                write_imageset(PUPIL_DEST[k], resize(canvas, OUT))

    json.dump(out, open(os.path.join(HERE, "answer_crabs.json"), "w"), indent=1)
    print(json.dumps(out, indent=1))
    return out


if __name__ == "__main__":
    build(write="--dry-run" not in sys.argv)
