#!/usr/bin/env python3
"""Build a simple QA contact sheet from captured promo JPEG frames."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow not installed; skipping contact sheet")
    sys.exit(0)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: make_contact_sheet.py <frames_dir> <output.jpg>")
        return 1
    frames_dir = Path(sys.argv[1])
    output = Path(sys.argv[2])
    frames = sorted(frames_dir.glob("*.jpg"))
    if not frames:
        print(f"no frames in {frames_dir}")
        return 0
    cols = 6
    rows = min(8, max(1, (len(frames) + cols - 1) // cols))
    thumb_w, thumb_h = 220, 476
    sheet = Image.new("RGB", (cols * thumb_w, rows * thumb_h), (16, 16, 16))
    for index, frame in enumerate(frames[: cols * rows]):
        img = Image.open(frame).convert("RGB")
        img.thumbnail((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        x = (index % cols) * thumb_w + (thumb_w - img.width) // 2
        y = (index // cols) * thumb_h + (thumb_h - img.height) // 2
        sheet.paste(img, (x, y))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, quality=88)
    print(f"wrote {output} from {len(frames[: cols * rows])} frames")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
