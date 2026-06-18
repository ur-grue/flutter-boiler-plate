#!/usr/bin/env bash
#
# Make the generated native projects build-ready for the bundled plugins.
# Run ONCE after `flutter create .` (new-app.sh calls it for you). Idempotent —
# safe to re-run; it skips anything already applied.
#
#   bash scripts/postcreate.sh
#
# Applies:
#   - Swift Package Manager OFF (Flutter >= 3.44 enables it; google_mobile_ads is
#     CocoaPods-only and its transitive webview_flutter_wkwebview breaks pod install).
#   - Android: core library desugaring (flutter_local_notifications) + minSdk 23
#     (google_mobile_ads / RevenueCat) in build.gradle.kts or build.gradle.
#   - AdMob app id: GADApplicationIdentifier (iOS) + APPLICATION_ID (Android). The SDK
#     does a publisher check at LAUNCH even when ads are off (it's linked), so a missing
#     id is an instant SIGABRT. We inject Google's PUBLIC SAMPLE ids — safe until you
#     ship real ads, at which point you replace them with your real AdMob app ids.
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
# Google's PUBLIC sample AdMob app ids (safe placeholders; replace before shipping real ads).
ADMOB_APP_ID_IOS="ca-app-pub-3940256099942544~1458002511"
ADMOB_APP_ID_ANDROID="ca-app-pub-3940256099942544~3347511713"

# Swift Package Manager OFF (must happen before pod install). Flutter >= 3.44 enables SPM
# by default, but google_mobile_ads is CocoaPods-only → pod install fails on its transitive
# webview_flutter_wkwebview. Global, idempotent, non-fatal.
if command -v flutter >/dev/null 2>&1; then
  flutter config --no-enable-swift-package-manager >/dev/null 2>&1 \
    && ok "Swift Package Manager disabled (CocoaPods for google_mobile_ads)" \
    || note "Could not toggle SPM — run: flutter config --no-enable-swift-package-manager"
fi

# Auto-generate platform folders if missing (so this is truly one-shot).
# Mobile only — desktop/web targets pull in plugins this factory never uses.
if [[ ! -d android && ! -d ios ]]; then
  if command -v flutter >/dev/null 2>&1; then
    hd "No platform folders — running flutter create --platforms=android,ios ."
    flutter create --platforms=android,ios . >/dev/null && ok "Platform folders generated"
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

# AdMob APPLICATION_ID in AndroidManifest (else SIGABRT at launch even with ads off).
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST" ]]; then
  if grep -q "com.google.android.gms.ads.APPLICATION_ID" "$MANIFEST"; then
    ok "AdMob APPLICATION_ID present"
  elif grep -q "</application>" "$MANIFEST"; then
    tmp="$(mktemp)"
    awk -v id="$ADMOB_APP_ID_ANDROID" '
      /<\/application>/ && !done {
        print "        <meta-data"
        print "            android:name=\"com.google.android.gms.ads.APPLICATION_ID\""
        print "            android:value=\"" id "\"/>"
        done=1
      }
      { print }' "$MANIFEST" > "$tmp" && mv "$tmp" "$MANIFEST" && ok "AdMob APPLICATION_ID → sample id"
  else
    note "Add the AdMob APPLICATION_ID meta-data to $MANIFEST (inside <application>)"
  fi
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

# AdMob GADApplicationIdentifier in Info.plist (else GADApplicationVerifyPublisher… → SIGABRT
# at launch even with ads off). PlistBuddy on macOS; awk insert before the root </dict> elsewhere.
PLIST="ios/Runner/Info.plist"
if [[ -f "$PLIST" ]]; then
  if grep -q "GADApplicationIdentifier" "$PLIST"; then
    ok "GADApplicationIdentifier present"
  elif [[ -x /usr/libexec/PlistBuddy ]]; then
    /usr/libexec/PlistBuddy -c "Add :GADApplicationIdentifier string $ADMOB_APP_ID_IOS" "$PLIST" >/dev/null 2>&1 \
      || /usr/libexec/PlistBuddy -c "Set :GADApplicationIdentifier $ADMOB_APP_ID_IOS" "$PLIST" >/dev/null 2>&1
    ok "GADApplicationIdentifier → sample id"
  else
    tmp="$(mktemp)"
    # Insert before the ROOT </dict> (the LAST one — the first could be a nested dict).
    awk -v id="$ADMOB_APP_ID_IOS" '
      { lines[NR]=$0; if ($0 ~ /<\/dict>/) last=NR }
      END {
        for (i=1; i<=NR; i++) {
          if (i==last) {
            print "\t<key>GADApplicationIdentifier</key>"
            print "\t<string>" id "</string>"
          }
          print lines[i]
        }
      }' "$PLIST" > "$tmp" && mv "$tmp" "$PLIST" && ok "GADApplicationIdentifier → sample id"
  fi
else
  note "No ios/Runner/Info.plist yet — set GADApplicationIdentifier after flutter create."
fi

# ---------------- App launcher icon ----------------
# Replace the default Flutter logo with the app icon. Needs the platform folders (above) and
# the source asset (written by /theme; a placeholder ships in the template). Idempotent.
hd "App icon"
if [[ -f assets/icon/app_icon.png ]] && command -v flutter >/dev/null 2>&1; then
  if flutter pub run flutter_launcher_icons >/dev/null 2>&1 \
     || dart run flutter_launcher_icons >/dev/null 2>&1; then
    ok "Launcher icons generated from assets/icon/app_icon.png (no more Flutter default logo)"
  else
    note "flutter_launcher_icons failed — run: dart run flutter_launcher_icons"
  fi
else
  note "No assets/icon/app_icon.png (or flutter missing) — /theme writes it; then: dart run flutter_launcher_icons"
fi

hd "Done"
ok "Native projects are plugin-ready. Next: flutter pub get && flutter gen-l10n"
