#!/usr/bin/env bash
#
# Run the app on a simulator / emulator / device with one command.
#
#   bash scripts/run.sh                  # set up, then let Flutter pick a device
#   bash scripts/run.sh "iPhone 15"      # target a device by name or id (see `flutter devices`)
#   bash scripts/run.sh chrome           # web, macos, an emulator id, a UUID, …
#
# On first run it generates the native folders (`flutter create .` + plugin-ready
# patches), fetches deps, regenerates localizations, and passes
# `dart_define.dev.json` if present. Runs keyless (mock data) by default.
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
  echo "  cd into your generated app (e.g. mapp-schnitzl), then re-run."
  exit 1
fi

# 1. Native folders (first run only). Won't overwrite existing lib/ code.
if [[ ! -d ios && ! -d android ]]; then
  echo "▸ First run: generating native folders (flutter create .)"
  flutter create . >/dev/null
  [[ -f scripts/postcreate.sh ]] && bash scripts/postcreate.sh
fi

# 2. Deps + localizations.
echo "▸ flutter pub get";  flutter pub get >/dev/null
echo "▸ flutter gen-l10n"; flutter gen-l10n >/dev/null 2>&1 || true

# 3. Show what's connected so you can pick.
echo "▸ Available devices:"
flutter devices 2>/dev/null | sed 's/^/    /'

# 4. Build the argv safely (handles device names with spaces; works on bash 3.2):
#    `flutter run [-d <target>] [--dart-define-from-file=…]`
set --
[[ -n "${1:-}" ]] && set -- -d "$1"
[[ -f dart_define.dev.json ]] && set -- "$@" --dart-define-from-file=dart_define.dev.json

echo "▸ flutter run $*"
exec flutter run "$@"
