# /release — pre-flight + build + one-command store upload (safe default)
1. Verify loop: `flutter analyze` (clean) + `flutter test` (green) + the LAUNCH proof
   (`bash scripts/smoke-launch.sh` — the app must actually start).
2. Assets for the store (so the last mile needs no file-opening/copying):
   - `/aso` has written `fastlane/metadata/{ios,android}/<locale>/*.txt`.
   - `bash scripts/screenshots.sh` writes framed `fastlane/screenshots/<locale>/*.png`.
   - `bash scripts/ship-review.sh` renders icon + screenshots + metadata + research into one
     local HTML page — review it in the browser before uploading.
3. Build + upload via **fastlane** (reads credentials from the vault; see `fastlane/README.md`).
   SAFE DEFAULT — uploads to TestFlight / Play internal, does NOT auto-submit for public review:
   `bundle exec fastlane ios beta` · `bundle exec fastlane ios metadata` ·
   `bundle exec fastlane android beta`.
   If fastlane/store credentials are not configured, fall back to:
   `flutter build ipa --release` and `flutter build appbundle --release`, and print the
   manual checklist (create the app record, upload the binary, paste metadata).
4. The only manual step left is the final "Submit for Review" in App Store Connect / Play
   Console (intentional — you confirm compliance answers + price, then submit).
