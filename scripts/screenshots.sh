#!/usr/bin/env bash
#
# Automated App Store / Play screenshots — no Photoshop, no dragging files.
#
#   bash scripts/screenshots.sh                       # boot the default iOS sim + capture
#   bash scripts/screenshots.sh "iPhone 16 Pro"       # override the simulator by name
#
# Boots an iOS simulator, runs the on-device screenshot test via `flutter drive`
# (integration_test/screenshots_test.dart), then copies the PNGs into
# fastlane/screenshots/en/ where the ship pipeline (scripts/ship-review.sh, fastlane)
# reads them. Edit screenshots_test.dart to add more marketing screens per app.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Locate Flutter if it's installed but not exported (mirrors scripts/run.sh).
if ! command -v flutter >/dev/null 2>&1; then
  for cand in \
    "$HOME/development/flutter/bin" \
    "$HOME/flutter/bin" \
    "$HOME/fvm/default/bin" \
    "$PWD/.fvm/flutter_sdk/bin" \
    "$HOME/.puro/envs/default/flutter/bin" \
    /opt/homebrew/bin /usr/local/bin; do
    [[ -x "$cand/flutter" ]] && { export PATH="$cand:$PATH"; break; }
  done
fi
command -v flutter >/dev/null 2>&1 || {
  echo "flutter not found in PATH — run: bash scripts/doctor.sh"; exit 1; }

# Guard: be in the app root (same reasoning as scripts/run.sh — avoid scaffolding a
# default counter app and screenshotting THAT).
if [[ ! -f pubspec.yaml || ! -f lib/main.dart ]]; then
  echo "✗ This isn't your app's root (need pubspec.yaml + lib/main.dart here)."
  echo "  cd into your app's project folder, then re-run."
  exit 1
fi

# This flow drives an iOS Simulator (needs macOS + Xcode's xcrun). Android works the
# same way — boot an emulator and run the drive command yourself:
if [[ "$(uname)" != "Darwin" ]] || ! command -v xcrun >/dev/null 2>&1; then
  echo "▸ iOS Simulator screenshots need macOS + Xcode (xcrun) — not available here."
  echo "  Android: boot an emulator, then run:"
  echo "      flutter drive \\"
  echo "        --driver=integration_test/test_driver/integration_test.dart \\"
  echo "        --target=integration_test/screenshots_test.dart \\"
  echo "        -d <emulator-id>"
  echo "  then copy build/screenshots/*.png into fastlane/screenshots/en/"
  exit 0
fi

# App Store requires a 6.9\" (or 6.7\") iPhone screenshot set. Default to the largest
# current device; honor a $1 device-name override.
DEVICE_NAME="${1:-iPhone 16 Pro Max}"

# Find the simulator's udid by name (first available match).
udid="$(xcrun simctl list devices available 2>/dev/null \
          | grep -F "$DEVICE_NAME (" | head -1 \
          | grep -oE '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}')"
if [[ -z "$udid" ]]; then
  echo "✗ No available simulator named \"$DEVICE_NAME\"."
  echo "  See your simulators: xcrun simctl list devices available"
  echo "  Then: bash scripts/screenshots.sh \"<device name>\""
  exit 1
fi

echo "▸ Booting simulator: $DEVICE_NAME ($udid)"
xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true  # boots if needed, then waits
open -a Simulator >/dev/null 2>&1 || true

echo "▸ flutter pub get"; flutter pub get >/dev/null

echo "▸ Capturing screenshots (flutter drive)…"
if ! flutter drive \
  --driver=integration_test/test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart \
  -d "$udid"; then
  echo "✗ flutter drive failed. Common causes:"
  echo "    - the simulator wasn't fully booted (re-run; bootstatus should wait)"
  echo "    - bootstrap/DI threw at launch — check the test output above"
  exit 1
fi

# Collect the PNGs the driver wrote into the fastlane layout the ship pipeline reads.
LOCALE_DIR="fastlane/screenshots/en"
mkdir -p "$LOCALE_DIR"
if ! compgen -G "build/screenshots/*.png" >/dev/null 2>&1; then
  echo "✗ No PNGs in build/screenshots/ — did the test call takeScreenshot()?"
  exit 1
fi
cp build/screenshots/*.png "$LOCALE_DIR"/

# Optional: device frames + captions via fastlane frameit (non-fatal).
if command -v fastlane >/dev/null 2>&1; then
  echo "▸ fastlane detected — to add device frames + captions, run:"
  echo "      (cd fastlane/screenshots && fastlane frameit)"
fi

echo "✓ Screenshots written to $LOCALE_DIR/"
ls "$LOCALE_DIR"/*.png | sed 's/^/    /'
echo "  Review them with: bash scripts/ship-review.sh"
