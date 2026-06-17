# /release — pre-flight + build
Run `flutter analyze` (clean) + `flutter test` (green). Then build:
flutter build ipa --release  and  flutter build appbundle --release.
Output the manual store checklist (App Store Connect app + TestFlight internal,
Play internal track). If fastlane is configured, run deliver/supply instead.
