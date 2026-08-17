#!/usr/bin/env bash
# Build the Debug app, run the deterministic King Crab teaser twice and
# record smooth simulator video externally, then resize/mix it into the final
# App Store exports.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROMO="$ROOT/promo"
DERIVED="$PROMO/DerivedData"
BUNDLE_ID="Hakketjak.King-Krab"
SCHEME="King Krab"
PROJECT="$ROOT/King Krab.xcodeproj"
TIMEOUT_SECONDS="${PROMO_TIMEOUT:-90}"

mkdir -p "$PROMO/frames/iphone" "$PROMO/frames/ipad" "$PROMO/tmp"

log() { printf '\n==> %s\n' "$*"; }

for cmd in xcodebuild xcrun python3; do
  command -v "$cmd" >/dev/null || { echo "missing $cmd"; exit 1; }
done

log "Available simulators"
xcrun simctl list devices available | sed -n '1,80p'

pick_simulator() {
  local family="$1"
  xcrun simctl list devices available -j | python3 -c '
import json, sys
data = json.load(sys.stdin)
family = sys.argv[1]
if family == "ipad":
    wanted = ("iPad (A16)", "iPad Pro 11-inch (M5)", "iPad Air 11-inch (M3)", "iPad mini (A17 Pro)")
else:
    wanted = ("iPhone 17", "iPhone 17 Pro", "iPhone 16 Pro", "iPhone 16")
found = []
booted = []
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if not device.get("isAvailable"):
            continue
        if family == "ipad" and not device["name"].startswith("iPad"):
            continue
        if family != "ipad" and not device["name"].startswith("iPhone"):
            continue
        found.append((device["name"], device["udid"], device.get("state")))
        if device.get("state") == "Booted":
            booted.append((device["name"], device["udid"]))
if booted:
    print(booted[0][1])
    raise SystemExit
for name in wanted:
    for device_name, udid, _ in found:
        if device_name == name:
            print(udid)
            raise SystemExit
if found:
    print(found[0][1])
 ' "$family"
}

IPHONE_UDID="$(pick_simulator iphone)"
IPAD_UDID="$(pick_simulator ipad)"
log "Using iPhone simulator $IPHONE_UDID"
xcrun simctl boot "$IPHONE_UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$IPHONE_UDID" -b
log "Using iPad simulator $IPAD_UDID"
xcrun simctl boot "$IPAD_UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$IPAD_UDID" -b

log "Building Debug"
set +o pipefail
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$IPHONE_UDID" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  build
set -o pipefail

APP="$(find "$DERIVED/Build/Products/Debug-iphonesimulator" -name "King Krab.app" -maxdepth 1 | head -n 1)"
if [[ -z "$APP" ]]; then
  echo "Built app not found"
  exit 1
fi
log "Installing $APP"
xcrun simctl uninstall "$IPHONE_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl uninstall "$IPAD_UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$IPHONE_UDID" "$APP"
xcrun simctl install "$IPAD_UDID" "$APP"

data_container() {
  xcrun simctl get_app_container "$1" "$BUNDLE_ID" data
}

run_format() {
  local format_arg="$1"
  local label="$2"
  local dest_mp4="$3"
  local frames_dir="$4"
  local raw_video="$PROMO/tmp/${label}-simulator.mov"
  local width height
  local udid
  if [[ "$label" == "iphone" ]]; then
    udid="$IPHONE_UDID"
    width=886
    height=1920
  else
    udid="$IPAD_UDID"
    width=1200
    height=1600
  fi

  log "Launching $label trailer"
  xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
  local docs
  docs="$(data_container "$udid")/Documents"
  mkdir -p "$docs"
  rm -rf "$docs/promo-frames"
  rm -f "$docs/king-crab-promo-done.json" \
        "$docs/king-crab-promo-ready.json" \
        "$docs/king-crab-promo-cues.json"
  rm -f "$raw_video"

  if [[ -n "$format_arg" ]]; then
    xcrun simctl launch "$udid" "$BUNDLE_ID" -KingCrabPromo "$format_arg"
  else
    xcrun simctl launch "$udid" "$BUNDLE_ID" -KingCrabPromo
  fi

  local waited=0
  while [[ $waited -lt 20 ]]; do
    docs="$(data_container "$udid")/Documents"
    if [[ -f "$docs/king-crab-promo-ready.json" ]]; then
      break
    fi
    sleep 1
    waited=$((waited + 1))
  done
  docs="$(data_container "$udid")/Documents"
  if [[ ! -f "$docs/king-crab-promo-ready.json" ]]; then
    echo "Timed out waiting for $label gameplay to become ready"
    exit 1
  fi
  log "$label gameplay ready after ${waited}s"

  xcrun simctl io "$udid" recordVideo --codec=h264 --force "$raw_video" >/dev/null 2>&1 &
  local recorder_pid=$!
  sleep 0.4

  waited=0
  while [[ $waited -lt $TIMEOUT_SECONDS ]]; do
    docs="$(data_container "$udid")/Documents"
    if [[ -f "$docs/king-crab-promo-done.json" ]]; then
      break
    fi
    sleep 1
    waited=$((waited + 1))
  done

  docs="$(data_container "$udid")/Documents"
  if [[ ! -f "$docs/king-crab-promo-done.json" ]]; then
    echo "Timed out waiting for $label trailer"
    kill -INT "$recorder_pid" >/dev/null 2>&1 || true
    wait "$recorder_pid" 2>/dev/null || true
    exit 1
  fi
  log "Capture finished in ${waited}s"
  python3 -m json.tool "$docs/king-crab-promo-done.json" || true
  sleep 1
  kill -INT "$recorder_pid" >/dev/null 2>&1 || true
  wait "$recorder_pid" 2>/dev/null || true
  cp "$docs/king-crab-promo-cues.json" "$PROMO/tmp/${label}-cues.json" 2>/dev/null || echo "[]" > "$PROMO/tmp/${label}-cues.json"
  cp "$docs/king-crab-promo-ready.json" "$PROMO/tmp/${label}-ready.json" 2>/dev/null || echo "{}" > "$PROMO/tmp/${label}-ready.json"
  cp "$docs/king-crab-promo-done.json" "$PROMO/tmp/${label}-done.json" 2>/dev/null || echo "{}" > "$PROMO/tmp/${label}-done.json"

  local crop_top crop_bottom content_seconds
  crop_bottom=0
  crop_top="$(python3 -c 'import json,sys; print(float(json.load(open(sys.argv[1])).get("cropTop", 0)))' "$PROMO/tmp/${label}-ready.json")"
  content_seconds="$(python3 -c 'import json,sys; e=float(json.load(open(sys.argv[1])).get("elapsed", 36)); print(min(36.0, max(1.0, e - 1.0 + 0.08)))' "$PROMO/tmp/${label}-done.json")"
  if [[ "$label" != "iphone" ]]; then
    crop_top=0
  fi

  swift "$PROMO/finalize_video.swift" \
    --input "$raw_video" \
    --cues "$PROMO/tmp/${label}-cues.json" \
    --audio-dir "$ROOT/King Krab" \
    --width "$width" \
    --height "$height" \
    --trim-seconds 1 \
    --max-seconds "$content_seconds" \
    --crop-top "$crop_top" \
    --crop-bottom "$crop_bottom" \
    --output "$dest_mp4"

  rm -rf "$frames_dir"
  mkdir -p "$frames_dir"
  swift "$PROMO/extract_frames.swift" "$dest_mp4" "$frames_dir"
  python3 "$PROMO/make_contact_sheet.py" "$frames_dir" "$PROMO/frames/${label}-contact.jpg" || true
  python3 "$PROMO/validate_mp4.py" "$dest_mp4"
}

run_format "" "iphone" "$PROMO/king-crab-app-store-teaser-886x1920.mp4" "$PROMO/frames/iphone"
run_format "-KingCrabPromoFormat-ipad" "ipad" "$PROMO/king-crab-app-store-teaser-1200x1600.mp4" "$PROMO/frames/ipad"

log "All trailer exports are in $PROMO"
ls -lh "$PROMO"/king-crab-app-store-teaser-*.mp4
