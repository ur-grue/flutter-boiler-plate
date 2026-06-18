#!/usr/bin/env bash
#
# Launch proof: build the app, run it on a REAL iOS simulator, and prove it actually
# starts. Green `flutter test` runs on the host VM with no native binary, so it cannot
# catch native plugin crashes (e.g. a missing AdMob app id → SIGABRT at launch) or
# DI/bootstrap failures. This step does — it's part of the /mvp definition-of-done.
#
#   bash scripts/smoke-launch.sh                 # boots a simulator, then proves boot
#   bash scripts/smoke-launch.sh "iPhone 16"     # target a specific simulator
#
# How: runs integration_test/app_boot_test.dart on the simulator (which builds + installs +
# launches the real binary and asserts the first screen renders), then saves a screenshot
# artifact to build/smoke/. Exits non-zero if the app fails to launch.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Locate Flutter (mirrors run.sh/doctor.sh).
if ! command -v flutter >/dev/null 2>&1; then
  for cand in "$HOME/development/flutter/bin" "$HOME/flutter/bin" "$HOME/fvm/default/bin" \
              "$PWD/.fvm/flutter_sdk/bin" "$HOME/.puro/envs/default/flutter/bin" \
              /opt/homebrew/bin /usr/local/bin; do
    [[ -x "$cand/flutter" ]] && { export PATH="$cand:$PATH"; break; }
  done
fi
command -v flutter >/dev/null 2>&1 || { echo "✗ flutter not found — run: bash scripts/doctor.sh"; exit 1; }

if [[ ! -f pubspec.yaml || ! -f integration_test/app_boot_test.dart ]]; then
  echo "✗ Run from the app root (need pubspec.yaml + integration_test/app_boot_test.dart)."; exit 1
fi

if [[ "$(uname)" != "Darwin" ]] || ! command -v xcrun >/dev/null 2>&1; then
  echo "! Simulator launch proof needs macOS + Xcode. On Android, run on an emulator:"
  echo "    flutter test integration_test/app_boot_test.dart -d <emulator-id>"
  exit 0
fi

# Make sure the native projects exist + are plugin-ready (AdMob id, SPM off, desugaring).
[[ -d ios ]] || flutter create --platforms=android,ios . >/dev/null
bash scripts/postcreate.sh >/dev/null 2>&1 || true

# Pick / boot a simulator. Honor an explicit name/udid arg, else the first booted one,
# else boot the first available iPhone.
udid=""
if [[ -n "${1:-}" ]]; then
  udid="$(xcrun simctl list devices 2>/dev/null | grep -F "$1" | grep -oE '[0-9A-Fa-f-]{36}' | head -1)"
fi
[[ -z "$udid" ]] && udid="$(xcrun simctl list devices booted 2>/dev/null | grep -oE '[0-9A-Fa-f-]{36}' | head -1)"
if [[ -z "$udid" ]]; then
  udid="$(xcrun simctl list devices available 2>/dev/null | grep -E 'iPhone' | head -1 | grep -oE '[0-9A-Fa-f-]{36}')"
fi
[[ -z "$udid" ]] && { echo "✗ No iOS simulator found. Create one in Xcode ▸ Settings ▸ Platforms."; exit 1; }

echo "▸ Booting simulator $udid…"
xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true
open -a Simulator >/dev/null 2>&1 || true

# THE PROOF: build + install + launch the real binary on the sim and assert it renders.
echo "▸ flutter test integration_test (real launch on the simulator)…"
if flutter test integration_test/app_boot_test.dart -d "$udid"; then
  mkdir -p build/smoke
  xcrun simctl io "$udid" screenshot build/smoke/launch.png >/dev/null 2>&1 || true
  echo "✓ App launched and rendered on the simulator (screenshot: build/smoke/launch.png)"
  exit 0
else
  echo "✗ App FAILED to launch on the simulator. This is a real native/bootstrap crash that"
  echo "  unit tests can't see (e.g. missing AdMob app id, pod install/SPM, DI). Fix before shipping."
  exit 1
fi
