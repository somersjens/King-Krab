#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def probe_with_swift(path: Path) -> dict:
    script = f"""
import AVFoundation
import Foundation

let url = URL(fileURLWithPath: "{path}")
let asset = AVURLAsset(url: url)
guard let track = asset.tracks(withMediaType: .video).first else {{
    print("{{\\"ok\\": false}}")
    exit(0)
}}
let transformed = track.naturalSize.applying(track.preferredTransform)
let width = Int(abs(transformed.width))
let height = Int(abs(transformed.height))
let duration = CMTimeGetSeconds(asset.duration)
print("{{\\"ok\\": true, \\"width\\": \\(width), \\"height\\": \\(height), \\"duration\\": \\(duration)}}")
"""
    proc = subprocess.Popen(
        ["swift", "-"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    stdout, stderr = proc.communicate(script)
    if proc.returncode != 0:
        raise RuntimeError(stderr.strip())
    return json.loads(stdout.strip())


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_mp4.py <file.mp4>")
        return 1
    path = Path(sys.argv[1])
    meta = probe_with_swift(path)
    width = int(meta["width"])
    height = int(meta["height"])
    duration = float(meta["duration"])
    payload = {
        "ok": bool(meta["ok"]) and width > 0 and height > 0 and duration > 15,
        "width": width,
        "height": height,
        "duration": duration,
    }
    print(json.dumps(payload, indent=2))
    return 0 if payload["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
