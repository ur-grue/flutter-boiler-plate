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
# This is a MOBILE factory: it scaffolds iOS + Android only. On macOS, if no device
# is connected it boots an iOS simulator for you. Otherwise (or for Android) boot one
# first (Xcode ▸ Open Simulator, or Android Studio ▸ Device Manager).
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

# Phantom-project guard: a stray `flutter create .` in a subfolder leaves a nested
# pubspec.yaml that hijacks the IDE/run (launches a default counter app). Refuse until
# it's removed so you never run the wrong app.
nested_pubspecs="$(find . -name pubspec.yaml -not -path './pubspec.yaml' \
  -not -path './build/*' -not -path './.dart_tool/*' -not -path './.fvm/*' \
  -not -path './ios/*' -not -path './macos/*' -not -path './android/*' \
  -not -path './linux/*' -not -path './windows/*' -not -path '*/ephemeral/*' 2>/dev/null)"
if [[ -n "$nested_pubspecs" ]]; then
  echo "✗ Stray nested Flutter project(s) found — they hijack which app runs:"
  echo "$nested_pubspecs" | sed 's/^/      /'
  echo "  A 'flutter create .' was run in a subfolder. Delete that nested app (keep only"
  echo "  the repo-root pubspec.yaml), then re-run. See: bash scripts/doctor.sh"
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

# 3. Make sure SOMETHING mobile is running. The #1 "no supported devices" cause is
#    simply not having booted a simulator. On macOS we boot one for you (the first
#    available iPhone). Everything here is non-fatal: worst case it does nothing and
#    we fall through to the manual hint below — it can never make things worse.
has_mobile() { flutter devices 2>/dev/null | grep -qiE '(ios|android)'; }

if ! has_mobile && [[ "$(uname)" == "Darwin" ]] && command -v xcrun >/dev/null 2>&1; then
  udid="$(xcrun simctl list devices available 2>/dev/null \
            | grep -E 'iPhone' | head -1 \
            | grep -oE '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}')"
  if [[ -n "$udid" ]]; then
    echo "▸ No device connected — booting an iOS simulator…"
    xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true  # boots if needed, then waits
    open -a Simulator >/dev/null 2>&1 || true
  fi
fi

# Show what's connected so you can pick.
echo "▸ Available devices:"
flutter devices 2>/dev/null | sed 's/^/    /'

# If still nothing mobile (no macOS auto-boot, or an Android-only setup), a bare
# `flutter run` has no valid target — we don't scaffold desktop/web. Point the way.
if ! has_mobile; then
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
