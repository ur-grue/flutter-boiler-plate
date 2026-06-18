# /legal — legal pages + in-app links
Generate Privacy Policy, ToS, EULA from APP_SPEC.md, fill placeholders, and host them
automatically so the store "privacy URL" exists with zero manual hosting. Wire the links
(onboarding, signup, settings, paywall) and verify account deletion exists. List the Apple
privacy-label + Google data-safety answers to enter, and whether an ATT prompt is required.

## Host automatically (no manual web hosting)
1. WRITE self-contained, minimal HTML (no JS, no external CSS) to:
   - `docs/legal/privacy.html`
   - `docs/legal/terms.html`
   A localized intro paragraph is acceptable; embed app name + contact from APP_SPEC.md.
2. PUBLISH them: `bash scripts/publish-legal.sh`. It serves them from GitHub Pages (docs/
   folder source) and PRINTS the resulting URLs:
   `https://<owner>.github.io/<repo>/legal/{privacy,terms}.html`.
   (Private repo → Pages needs a paid plan; else host the two files anywhere — see
   `docs/legal/README.md`.) Remind the user to commit + push `docs/legal/`.
3. WRITE the resulting URLs into store metadata, one per locale:
   - iOS: `fastlane/metadata/ios/<locale>/privacy_url.txt` (+ `terms_url.txt`)
   - Android: `fastlane/metadata/android/<locale>/privacy_url.txt` (+ `terms_url.txt`)
4. WIRE the in-app links: set `PRIVACY_URL` and `TERMS_URL` in `dart_define.dev.json`
   (and document them in `dart_define.example.json`) to the published URLs — `AppConfig`
   already reads them via `String.fromEnvironment`.
