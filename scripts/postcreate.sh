#!/usr/bin/env bash
#
# Make the generated native projects build-ready for the bundled plugins.
# Run ONCE after `flutter create .` (new-app.sh calls it for you). Idempotent —
# safe to re-run; it skips anything already applied.
#
#   bash scripts/postcreate.sh
#
# Applies:
#   - Android: core library desugaring (flutter_local_notifications) + minSdk 23
#     (google_mobile_ads / RevenueCat) in build.gradle.kts or build.gradle.
#   - iOS: Podfile platform :ios, '13.0' (RevenueCat).
#
# Non-fatal: if a future Flutter changes the generated files and a pattern does
# not match, it prints the manual fix instead of failing.
set -uo pipefail

if [[ -t 1 ]]; then G=$'\e[32m'; Y=$'\e[33m'; B=$'\e[1m'; X=$'\e[0m'; else G=''; Y=''; B=''; X=''; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
ok()   { printf "  ${G}✓${X} %s\n" "$1"; }
note() { printf "  ${Y}!${X} %s\n" "$1"; }
hd()   { printf "\n${B}%s${X}\n" "$1"; }

DESUGAR_LIB="com.android.tools:desugar_jdk_libs:2.1.4"
MIN_SDK=23
IOS_TARGET="13.0"

# Auto-generate platform folders if missing (so this is truly one-shot).
if [[ ! -d android && ! -d ios ]]; then
  if command -v flutter >/dev/null 2>&1; then
    hd "No platform folders — running flutter create ."
    flutter create . >/dev/null && ok "Platform folders generated"
  else
    note "No android/ios folders and flutter not found. Run 'flutter create .' first."
    exit 1
  fi
fi

# ---------------- Android ----------------
hd "Android"
KTS="android/app/build.gradle.kts"
GRADLE="android/app/build.gradle"

if [[ -f "$KTS" ]]; then
  f="$KTS"
  # minSdk
  if grep -q "minSdk = $MIN_SDK" "$f"; then ok "minSdk already $MIN_SDK"
  elif grep -q "minSdk = flutter.minSdkVersion" "$f"; then
    sed -i.bak "s/minSdk = flutter.minSdkVersion/minSdk = $MIN_SDK/" "$f" && ok "minSdk → $MIN_SDK"
  else note "minSdk: set it to $MIN_SDK manually in $f (defaultConfig)"; fi
  # desugaring flag inside compileOptions
  if grep -q "isCoreLibraryDesugaringEnabled" "$f"; then ok "desugaring flag present"
  elif grep -q "compileOptions {" "$f"; then
    tmp="$(mktemp)"
    awk '{ print }
         /compileOptions \{/ && !done { print "        isCoreLibraryDesugaringEnabled = true"; done=1 }' "$f" > "$tmp" \
      && mv "$tmp" "$f" && ok "desugaring flag added"
  else note "Add 'isCoreLibraryDesugaringEnabled = true' to compileOptions in $f"; fi
  # desugar dependency (append a top-level dependencies block once)
  if grep -q "coreLibraryDesugaring(" "$f"; then ok "desugar dependency present"
  else
    printf '\ndependencies {\n    coreLibraryDesugaring("%s")\n}\n' "$DESUGAR_LIB" >> "$f"
    ok "desugar dependency added"
  fi
  rm -f "$f.bak"
elif [[ -f "$GRADLE" ]]; then
  f="$GRADLE"
  if grep -q "minSdkVersion $MIN_SDK" "$f"; then ok "minSdk already $MIN_SDK"
  elif grep -q "minSdkVersion flutter.minSdkVersion" "$f"; then
    sed -i.bak "s/minSdkVersion flutter.minSdkVersion/minSdkVersion $MIN_SDK/" "$f" && ok "minSdk → $MIN_SDK"
  else note "minSdk: set it to $MIN_SDK manually in $f"; fi
  if grep -q "coreLibraryDesugaringEnabled" "$f"; then ok "desugaring flag present"
  elif grep -q "compileOptions {" "$f"; then
    tmp="$(mktemp)"
    awk '{ print }
         /compileOptions \{/ && !done { print "        coreLibraryDesugaringEnabled true"; done=1 }' "$f" > "$tmp" \
      && mv "$tmp" "$f" && ok "desugaring flag added"
  else note "Add 'coreLibraryDesugaringEnabled true' to compileOptions in $f"; fi
  if grep -q "coreLibraryDesugaring " "$f"; then ok "desugar dependency present"
  else
    printf "\ndependencies {\n    coreLibraryDesugaring '%s'\n}\n" "$DESUGAR_LIB" >> "$f"
    ok "desugar dependency added"
  fi
  rm -f "$f.bak"
else
  note "No Android gradle file found — skipped."
fi

# ---------------- iOS ----------------
hd "iOS"
POD="ios/Podfile"
if [[ -f "$POD" ]]; then
  if grep -qE "^platform :ios, '$IOS_TARGET'" "$POD"; then
    ok "Podfile platform already $IOS_TARGET"
  elif grep -qE "^#? *platform :ios" "$POD"; then
    sed -i.bak "s/^#* *platform :ios.*/platform :ios, '$IOS_TARGET'/" "$POD" && ok "Podfile platform → $IOS_TARGET"
    rm -f "$POD.bak"
  else
    note "Add \"platform :ios, '$IOS_TARGET'\" to the top of $POD"
  fi
else
  note "No ios/Podfile yet (created on first iOS build) — set platform :ios, '$IOS_TARGET' then."
fi

hd "Done"
ok "Native projects are plugin-ready. Next: flutter pub get && flutter gen-l10n"
