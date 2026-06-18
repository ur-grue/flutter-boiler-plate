#!/usr/bin/env bash
#
# Preflight check: can this machine build & run the app?
#
#   bash scripts/doctor.sh
#
# Reads the required Flutter/Dart versions straight from pubspec.yaml, verifies
# your toolchain, checks project setup, and prints `flutter doctor`. Every
# problem comes with the exact command to fix it. Exits non-zero only on
# blocking issues (missing/too-old Flutter), zero for "ready" (with hints).
set -uo pipefail

if [[ -t 1 ]]; then
  R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; B=$'\e[1m'; X=$'\e[0m'
else
  R=''; G=''; Y=''; B=''; X=''
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
warn=0
ok()   { printf "  ${G}✓${X} %s\n" "$1"; }
bad()  { printf "  ${R}✗${X} %s\n" "$1"; fail=$((fail + 1)); }
note() { printf "  ${Y}!${X} %s\n" "$1"; warn=$((warn + 1)); }
hd()   { printf "\n${B}%s${X}\n" "$1"; }

# version_ge A B  → exit 0 if A >= B  (portable; no `sort -V`, works on macOS)
version_ge() {
  local a b ai bi i
  IFS=. read -ra a <<<"$1"
  IFS=. read -ra b <<<"$2"
  for i in 0 1 2; do
    ai=${a[i]:-0}; bi=${b[i]:-0}
    if ((10#$ai > 10#$bi)); then return 0; fi
    if ((10#$ai < 10#$bi)); then return 1; fi
  done
  return 0
}

# Locate a present-but-unexported Flutter SDK and add it to PATH for this run
# (mirrors setup.zsh, so doctor.sh agrees with the bootstrap script).
if ! command -v flutter >/dev/null 2>&1; then
  for cand in \
    "$HOME/development/flutter/bin" \
    "$HOME/flutter/bin" \
    "$HOME/fvm/default/bin" \
    "$PWD/.fvm/flutter_sdk/bin" \
    "$HOME/.puro/envs/default/flutter/bin" \
    "/opt/homebrew/bin" \
    "/usr/local/bin"; do
    if [[ -x "$cand/flutter" ]]; then
      export PATH="$cand:$PATH"
      break
    fi
  done
fi

# Required versions, read from pubspec.yaml so this never drifts.
req_flutter="$(grep -E '^\s*flutter:\s*">=' pubspec.yaml | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
req_dart="$(grep -E '^\s*sdk:\s*">=' pubspec.yaml | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
req_flutter="${req_flutter:-3.24.0}"
req_dart="${req_dart:-3.4.0}"

hd "Toolchain (required: Flutter >= $req_flutter, Dart >= $req_dart)"
if command -v flutter >/dev/null 2>&1; then
  machine="$(flutter --version --machine 2>/dev/null || true)"
  fv="$(printf '%s' "$machine" | grep -oE '"frameworkVersion" *: *"[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  dv="$(printf '%s' "$machine" | grep -oE '"dartSdkVersion" *: *"[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  # Fallback for older Flutter without --machine.
  [[ -z "$fv" ]] && fv="$(flutter --version 2>/dev/null | grep -oE 'Flutter [0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"

  if [[ -n "$fv" ]] && version_ge "$fv" "$req_flutter"; then
    ok "Flutter $fv"
  else
    bad "Flutter ${fv:-unknown} < $req_flutter  →  run: flutter upgrade"
  fi

  if [[ -n "$dv" ]]; then
    if version_ge "$dv" "$req_dart"; then ok "Dart $dv"
    else bad "Dart $dv < $req_dart  →  run: flutter upgrade"; fi
  else
    note "Could not read Dart version (bundled with Flutter — usually fine)"
  fi
else
  if [[ "$(uname -s)" == "Darwin" ]]; then
    bad "flutter not found  →  macOS: brew install --cask flutter  (or https://docs.flutter.dev/get-started/install/macos), then reopen the terminal. Or run ./setup.zsh to auto-install."
  else
    bad "flutter not found in PATH  →  install: https://docs.flutter.dev/get-started/install"
  fi
fi

hd "Project setup"
if [[ -d android || -d ios ]]; then
  ok "Native platform folders present"
  if grep -rqs "CoreLibraryDesugaringEnabled" android/app/build.gradle android/app/build.gradle.kts; then
    ok "Android native config plugin-ready (desugaring)"
  else
    note "Android not plugin-ready  →  run: bash scripts/postcreate.sh"
  fi
else
  note "No android/ios yet  →  run: flutter create .  (then: bash scripts/postcreate.sh)"
fi
if [[ -f dart_define.dev.json ]]; then
  ok "dart_define.dev.json present"
else
  note "No dart_define.dev.json  →  run: cp dart_define.example.json dart_define.dev.json"
fi
if [[ -d .dart_tool ]]; then
  ok "Dependencies fetched"
else
  note "Dependencies not fetched  →  run: flutter pub get"
fi
if [[ -d lib/core/l10n/gen ]]; then
  ok "Localizations generated"
else
  note "Localizations not generated  →  run: flutter gen-l10n"
fi

hd "Skills (Claude Code automation, optional)"
skills_dir="$HOME/.claude/skills"
if [[ -d "$skills_dir/gstack" ]]; then
  ok "gstack present"
else
  note "gstack not found  →  run: ./setup.zsh (Phase 3), or git clone --depth 1 https://github.com/garrytan/gstack.git $skills_dir/gstack && (cd $skills_dir/gstack && ./setup)"
fi
if [[ -d "$skills_dir/impeccable" ]]; then
  ok "impeccable present"
else
  note "impeccable not found  →  run: npx -y skills add pbakaus/impeccable --agent claude-code"
fi

hd "flutter doctor"
if command -v flutter >/dev/null 2>&1; then
  flutter doctor || true
else
  note "skipped (flutter missing)"
fi

hd "Summary"
if ((fail > 0)); then
  printf "${R}%d blocking issue(s)${X}, %d setup hint(s). Fix the ✗ items above.\n" "$fail" "$warn"
  exit 1
elif ((warn > 0)); then
  printf "${Y}Toolchain OK — %d setup step(s) above before you run the app.${X}\n" "$warn"
  exit 0
else
  printf "${G}All good — ready to build and run.${X}\n"
  exit 0
fi
