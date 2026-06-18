# fastlane — the one-command last mile

Turns "open App Store Connect / Play Console, create the app, type metadata in 12 fields × 4
locales, drag screenshots, submit" into **files + one command**. You never type into the store
web UI; the metadata and screenshots here are uploaded for you.

## Layout (the single source for both the upload and the review page)
- `fastlane/metadata/ios/<locale>/{name,subtitle,description,keywords,...}.txt` — written by `/aso`.
- `fastlane/metadata/android/<locale>/{title,short_description,full_description}.txt` — `/aso`.
- `fastlane/screenshots/<locale>/*.png` — written by `bash scripts/screenshots.sh`.
- `scripts/ship-review.sh` renders all of the above into one local HTML page to review first.

## One-time setup (the only manual data entry)
1. Apple Developer account ($99/yr) + Google Play Developer account.
2. Create an **App Store Connect API key** (.p8) and a **Play service-account JSON**.
3. Put their paths + ids in `~/.appfactory/secrets.env` (see `appfactory/secrets.env.example`):
   `APPLE_TEAM_ID`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH`, `PLAY_JSON_KEY_PATH`,
   and optionally `MATCH_GIT_URL` (a private repo for code-signing via `fastlane match`).
4. First run: `fastlane produce` creates the app record; `fastlane match appstore` provisions signing.

## Run (safe default — stops before public review)
```bash
bundle exec fastlane ios beta        # binary → TestFlight (you press "Submit" in ASC)
bundle exec fastlane ios metadata    # metadata + screenshots only
bundle exec fastlane android beta    # AAB → Play internal track (draft)
```
`./ship.sh` wraps these. The Fastfile **never auto-submits for review** — flip that on yourself
once your compliance answers (age rating, privacy labels) are set.

> This is a scaffold: verify action params on your Mac and adjust as the stores evolve.
> `fastlane/report.xml`, `*.p8`, and `*.json` keys are gitignored — never commit credentials.
