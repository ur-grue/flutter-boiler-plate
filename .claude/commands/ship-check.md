# /ship-check — pre-submit gate → PASS/FAIL
Run the verify loop first: `dart fix --apply`, `dart format --set-exit-if-changed .`,
`flutter analyze --fatal-warnings` (clean), `flutter test` (green).

LAUNCH gate (FAIL if it doesn't start): `bash scripts/smoke-launch.sh` — the app must boot on a
simulator (integration_test/app_boot_test.dart). Green unit tests do not prove it launches.

Branding gate (FAIL if generic — "outside generic" check):
- App icon is NOT the Flutter default: `assets/icon/app_icon.png` exists and a
  `dart run flutter_launcher_icons` run regenerated the native icons (the generated
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` must differ from
  Flutter's default-logo hash).
- Home-screen name is the app name, not "Flutter Boilerplate": iOS `CFBundleDisplayName` in
  `ios/Runner/Info.plist` and Android `android:label` in `AndroidManifest.xml`.

Run the aso-skills `aso-audit` (listing completeness/quality) and `app-rejection-recovery`
(pre-empt common App Store/Play rejection triggers) over the metadata + build.

Then check: account deletion present; legal links open; ATT prompt iff tracking;
privacy-label/data-safety answers ready; paywall shows price + restore.

Stale-identity gate (FAIL if any hit): `grep -rn "Flutter Boilerplate" lib/` returns
nothing, and `appName` is the real app name in ALL `lib/core/l10n/arb/app_*.arb`. Also
confirm there is no leftover `example_notes/` and no uncommitted MVP work (`git status`
clean or only intended changes).

Security gate: run `/security-review` on the diff (secrets, unsafe deps, network
hardening) — complements the compliance-auditor's store-policy checks.

Then run the design-critic subagent on the latest screenshots and list the top 5 fixes.
Output PASS or FAIL.
