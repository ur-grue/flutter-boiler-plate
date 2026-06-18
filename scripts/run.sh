#!/usr/bin/env bash
#
# Run the app on a simulator / emulator / device with one command.
#
#   bash scripts/run.sh                  # set up, then let Flutter pick a device
#   bash scripts/run.sh "iPhone 15"      # target a device by name or id (see `flutter devices`)
#   bash scripts/run.sh emulator-5554    # an Android emulator id, a UUID, …
#
# On first run it generates the native folders (`flutter create --platforms=android,ios .`
# + plugin-ready patches), fetches deps, regenerates localizations, and passes
# `dart_define.dev.json` if present. Runs keyless (mock data) by default.
#
# This is a MOBILE factory: it scaffolds iOS + Android only. A simulator/emulator
# must be BOOTED first (Xcode ▸ Open Simulator, or Android Studio ▸ Device Manager),
# otherwise Flutter has nothing to run on.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Locate Flutter if it's installed but not exported (mirrors scripts/doctor.sh).
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

# Guard: be in the app root. Otherwise `flutter create .` below would scaffold a
# brand-new DEFAULT counter app (and run that instead of yours).
if [[ ! -f pubspec.yaml || ! -f lib/main.dart ]]; then
  echo "✗ This isn't your app's root (need pubspec.yaml + lib/main.dart here)."
  echo "  cd into your app's project folder, then re-run."
  exit 1
fi

# 1. Native folders (first run only). iOS + Android only — this is a mobile
#    factory, and scaffolding desktop/web adds plugins (and build failures) you
#    don't want. Won't overwrite existing lib/ code.
if [[ ! -d ios && ! -d android ]]; then
  echo "▸ First run: generating native folders (flutter create --platforms=android,ios .)"
  flutter create --platforms=android,ios . >/dev/null
  [[ -f scripts/postcreate.sh ]] && bash scripts/postcreate.sh
fi

# 2. Deps + localizations.
echo "▸ flutter pub get";  flutter pub get >/dev/null
echo "▸ flutter gen-l10n"; flutter gen-l10n >/dev/null 2>&1 || true

# 3. Show what's connected so you can pick.
echo "▸ Available devices:"
flutter devices 2>/dev/null | sed 's/^/    /'

# Nudge: if nothing mobile is connected, a bare `flutter run` has no valid target
# (we don't scaffold desktop/web). Point at booting a simulator/emulator.
if ! flutter devices 2>/dev/null | grep -qiE '(ios|android)'; then
  echo "  ! No iOS/Android device detected. Boot one first:"
  echo "      iOS:     open -a Simulator        (then wait for it to finish booting)"
  echo "      Android: start an emulator in Android Studio ▸ Device Manager"
fi

# 4. Build the argv safely (handles device names with spaces; works on bash 3.2):
#    `flutter run [-d <target>] [--dart-define-from-file=…]`
set --
[[ -n "${1:-}" ]] && set -- -d "$1"
[[ -f dart_define.dev.json ]] && set -- "$@" --dart-define-from-file=dart_define.dev.json

echo "▸ flutter run $*"
exec flutter run "$@"
