#!/usr/bin/env bash
#
# Rebrand a fresh clone of this template.
#
# Usage:
#   bash scripts/rename.sh "My App" com.acme.myapp
#
# Rewrites:
#   - Dart package name (pubspec.yaml + every `package:flutter_boilerplate/` import)
#   - App display name + bundle id (lib/core/config/app_info.dart)
#   - Android applicationId / iOS bundle id (if platform folders exist)
#
# Run AFTER `flutter create .` so platform folders are present.
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: bash scripts/rename.sh \"App Display Name\" com.acme.myapp" >&2
  exit 1
fi

APP_NAME="$1"
BUNDLE_ID="$2"
OLD_PKG="flutter_boilerplate"
OLD_BUNDLE="com.example.flutter_boilerplate"

# Derive a valid Dart package name from the bundle id's last segment.
NEW_PKG="$(echo "${BUNDLE_ID##*.}" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')"
if [[ -z "$NEW_PKG" ]]; then
  echo "Could not derive a Dart package name from '$BUNDLE_ID'." >&2
  exit 1
fi

echo "→ App name:     $APP_NAME"
echo "→ Bundle id:    $BUNDLE_ID"
echo "→ Dart package: $NEW_PKG"

# Portable in-place sed (GNU vs BSD/macOS).
sedi() {
  if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi
}

# 1. Dart package references across source + configs.
grep -rl --include='*.dart' "package:${OLD_PKG}/" lib test 2>/dev/null | while read -r f; do
  sedi "s|package:${OLD_PKG}/|package:${NEW_PKG}/|g" "$f"
done

# 2. pubspec name.
sedi "s|^name: ${OLD_PKG}|name: ${NEW_PKG}|" pubspec.yaml

# 3. Centralized identity.
sedi "s|appName = '.*'|appName = '${APP_NAME}'|" lib/core/config/app_info.dart
sedi "s|bundleId = '.*'|bundleId = '${BUNDLE_ID}'|" lib/core/config/app_info.dart

# 4. Native ids (only if `flutter create .` has run).
if [[ -f android/app/build.gradle ]]; then
  sedi "s|applicationId \"${OLD_BUNDLE}\"|applicationId \"${BUNDLE_ID}\"|" android/app/build.gradle || true
  sedi "s|applicationId = \"${OLD_BUNDLE}\"|applicationId = \"${BUNDLE_ID}\"|" android/app/build.gradle || true
fi
if [[ -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  sedi "s|PRODUCT_BUNDLE_IDENTIFIER = [^;]*;|PRODUCT_BUNDLE_IDENTIFIER = ${BUNDLE_ID};|g" ios/Runner.xcodeproj/project.pbxproj || true
fi

echo "✓ Done. Now run: flutter pub get && flutter gen-l10n"
