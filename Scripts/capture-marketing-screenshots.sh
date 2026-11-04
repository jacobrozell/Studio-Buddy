#!/usr/bin/env bash
# Capture App Store Connect screenshots for Studio Buddy (portrait, light).
#
# iPhone 6.9"  1320×2868   SIM_NAME="iPhone 17 Pro Max"
# iPad 13"     2064×2752   DEVICE_KIND=ipad SIM_NAME="iPad Pro 13-inch (M5)"
#
# Usage:
#   ./Scripts/capture-marketing-screenshots.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_KIND="${DEVICE_KIND:-iphone}"
APPEARANCE="${APPEARANCE:-light}"
BUNDLE_ID="com.jacobrozell.mixstack"
SCHEME="${SCHEME:-StudioBuddy}"
PROJECT="$ROOT/StudioBuddy.xcodeproj"
DERIVED_DATA="${DERIVED_DATA:-$ROOT/.derivedData/marketing-screenshots}"
LAUNCH_DELAY="${LAUNCH_DELAY:-8}"
MARKETING_BASE="${MARKETING_BASE:-$ROOT/marketing-screenshots}"
APP_STORE_RESIZE="${APP_STORE_RESIZE:-1}"

if [[ "$DEVICE_KIND" == "ipad" ]]; then
  SIM_NAME="${SIM_NAME:-iPad Pro 13-inch (M5)}"
  EXPECT_W="${EXPECT_W:-2064}"
  EXPECT_H="${EXPECT_H:-2752}"
else
  SIM_NAME="${SIM_NAME:-iPhone 17 Pro Max}"
  EXPECT_W="${EXPECT_W:-1320}"
  EXPECT_H="${EXPECT_H:-2868}"
fi

BASE_ARGS=(-ui_test_skip_onboarding -disable_analytics -seed_demo_tracks -seed_marketing)

if [[ ! -d "$PROJECT" ]]; then
  (cd "$ROOT" && cp GoogleService-Info.plist.example GoogleService-Info.plist && xcodegen generate)
fi

SIM_UDID="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
name = sys.argv[1]
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d.get('name') == name and d.get('isAvailable', True):
            print(d['udid'])
            sys.exit(0)
sys.exit(1)
" "$SIM_NAME")"

xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_UDID" -b
xcrun simctl ui "$SIM_UDID" appearance "$APPEARANCE"

flatten_and_size() {
  local path="$1"
  magick "$path" -alpha off -filter Lanczos -resize "${EXPECT_W}x${EXPECT_H}!" PNG24:"$path"
}

capture_one() {
  local slug="$1"
  shift
  local out_dir="$MARKETING_BASE/$DEVICE_KIND/$APPEARANCE/portrait"
  mkdir -p "$out_dir"
  local filename="${DEVICE_KIND}-${slug}.png"
  xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" 2>/dev/null || true
  sleep 0.4
  xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID" "$@" >/dev/null
  sleep "$LAUNCH_DELAY"
  local out="$out_dir/$filename"
  xcrun simctl io "$SIM_UDID" screenshot --mask=ignored "$out"
  if [[ "$APP_STORE_RESIZE" == 1 ]]; then
    flatten_and_size "$out"
  fi
}

xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "platform=iOS Simulator,id=$SIM_UDID" \
  -derivedDataPath "$DERIVED_DATA" build \
  | xcbeautify --quieter 2>/dev/null || true

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/StudioBuddy.app"
xcrun simctl install "$SIM_UDID" "$APP_PATH"

capture_one "01-library" "${BASE_ARGS[@]}"
capture_one "02-song-detail" "${BASE_ARGS[@]}" marketing_song_detail
capture_one "03-player" "${BASE_ARGS[@]}" marketing_song_detail marketing_player
capture_one "04-project" "${BASE_ARGS[@]}" marketing_project
capture_one "05-share-card" "${BASE_ARGS[@]}" marketing_song_detail marketing_share_card

echo "Done. Screenshots in $MARKETING_BASE/$DEVICE_KIND/$APPEARANCE/portrait"
