# Flutter Boilerplate

A production-grade, **AI-agent-friendly** Flutter template for vibe-coding mobile apps.
Clean Architecture + Cubit + go_router, **no code generation**, and it runs with **zero
API keys** out of the box (mock/no-op service impls you swap for real backends later).

## Features

- 🧱 **Clean Architecture** (feature-first: `presentation → domain ← data`)
- 🧊 **Cubit** state management (`flutter_bloc`) with sealed states
- 🧭 **go_router** with a pure, loop-free auth/onboarding redirect guard
- 🎨 **Material 3 theming** — light/dark + selectable seed color, persisted
- 🌍 **Localization** — `en`, `de`, `es`, `ar` (incl. RTL) via built-in `gen-l10n`
- 🔐 **Auth** — mock sign-in/out + session in secure storage (swap for Firebase/Supabase)
- 🔔 **Local notifications** — immediate + scheduled, permission handling
- 💸 **Monetization** — RevenueCat paywall + AdMob banners/interstitials behind interfaces
- 🗒️ **Example CRUD feature** (`example_notes`) — the copy-me reference; delete to start clean
- 🛡️ **Robust** — global error capture, `Result`/`Failure` everywhere, BlocObserver
- 🧪 **Tests** — `bloc_test` cubits, pure redirect/result tests, widget test
- 🤖 **AI-native** — `AGENTS.md` / `CLAUDE.md` / `.cursor/rules` teach agents the conventions
- ⚙️ **CI** — format + analyze + test on every push/PR

## Prerequisites

- **Flutter** ≥ 3.44 (stable) — includes the Dart SDK. The exact minimum is
  enforced by `pubspec.yaml`'s `environment:` block (`flutter pub get` fails fast if too
  old), so a stale SDK is caught up front instead of breaking mid-build.
- A target toolchain + device for `flutter run`: **Android** (Android Studio/SDK + emulator
  or device), **iOS** (macOS + Xcode + simulator), or **web** (`-d chrome`).
- Unit/widget tests (`flutter test`) need **only** the Flutter SDK — no device.

Verify your machine first (reads the required versions from `pubspec.yaml`, runs
`flutter doctor`, and prints the exact fix for anything missing):

```bash
bash scripts/doctor.sh
```

## Quick start

```bash
# 1) Create your repo from this template, then clone it.
#    GitHub UI: "Use this template" → "Create a new repository", then:
git clone https://github.com/<you>/<your-app>.git
cd <your-app>
#    Or in one step with the GitHub CLI:
gh repo create <your-app> --template ur-grue/flutter-boiler-plate --private --clone
cd <your-app>

# 2) Check your environment (Flutter/Dart versions, toolchain):
bash scripts/doctor.sh

# 3) Generate native folders (iOS + Android — this is a mobile template) and make
#    them plugin-ready (desugaring, minSdk, iOS target):
flutter create --platforms=android,ios .
bash scripts/postcreate.sh

# 4) Rebrand in one command (run after step 3):
bash scripts/rename.sh "My App" com.acme.myapp
# Windows: dart run tool/rename.dart "My App" com.acme.myapp

# 5) Configure + run (keyless by default):
cp dart_define.example.json dart_define.dev.json
flutter pub get
flutter gen-l10n
flutter run --dart-define-from-file=dart_define.dev.json
```

Sign in with **any valid email + password** (mock auth).

### Native setup is automated

`bash scripts/postcreate.sh` (idempotent) makes the generated native projects build-ready
for the bundled plugins — Android **core library desugaring** + **minSdk 23**
(`flutter_local_notifications`, `google_mobile_ads`, RevenueCat) and iOS **`platform :ios,
'13.0'`**. `new-app.sh` runs it for you. `bash scripts/doctor.sh` re-checks anytime.

Extra native config is needed **only when you turn features on**: AdMob app id in
`AndroidManifest.xml`/`Info.plist`, Android 13+ notification permission — see
[docs/SECURITY.md](docs/SECURITY.md).

## Testing on a device or simulator

One command sets up native folders + deps and runs the app:

```bash
bash scripts/run.sh                  # then pick a device when prompted
bash scripts/run.sh "iPhone 16"      # or target one from `flutter devices` (name or id)
```

It refuses to run unless you're in the app's root (so it can't accidentally scaffold a
default counter app). Runs keyless (mock data); passes `dart_define.dev.json` if present.

- **iOS Simulator** — fastest, no signing. Run `open -a Simulator` and **wait for it to
  finish booting** before you run — `-d "iPhone 16"` only matches a simulator that's
  already up, otherwise Flutter reports "no supported devices".
- **Real iPhone** — one-time: open `ios/Runner.xcworkspace` → *Runner* → *Signing &
  Capabilities* → pick your Apple ID team. Then `bash scripts/run.sh "<your iPhone>"`.
- **Android** (set up later) — install Android Studio (`brew install --cask android-studio`),
  open it once to install the SDK, then `flutter doctor --android-licenses`; create an
  emulator in Device Manager. `bash scripts/doctor.sh` shows your live targets anytime.

> Tip: this template scaffolds **iOS + Android only** (`flutter create --platforms=android,ios .`).
> Desktop/web targets are intentionally absent — `google_mobile_ads`/`purchases_flutter` (and
> some auth plugins) don't support them, so those builds fail. Test on a mobile target.

## App Factory — from idea to the App Store (optional)

The **App Factory** is the hands-off path: you describe an app in plain language and the
boilerplate scaffolds, builds, tests, and gets it ready to ship — with you reviewing at
two checkpoints. One command runs the whole thing: **`./setup.zsh`** (macOS + zsh;
`./new-app.sh` still works and forwards to it).

### The whole journey at a glance

```
  ┌─ Stage 0 ─┐   ┌─ Stage 1 ─┐   ┌─ Stage 2 ──┐   ┌─ Stage 3 ─┐   ┌─ Stage 4 ─┐
   install &      describe your    Claude builds    you test &      you ship
   add keys       app (4 Qs)       the MVP          approve         to the stores
  └───────────┘   └───────────┘   └────────────┘   └───────────┘   └───────────┘
   ./setup.zsh     ./setup.zsh      (automatic       flutter run     ./ship.sh
   (once)          prompts          via /mvp)        + your eyes     → /release
```

### Step by step

**Stage 0 — Install once (a few minutes).**
```bash
git clone https://github.com/<you>/<your-app>.git && cd <your-app>
./setup.zsh
```
First run installs the toolchain (gum, Flutter, Claude CLI) and skills, then creates a
**secret vault** at `~/.appfactory/secrets.env` and stops. Open that file, paste your keys
(RevenueCat, Supabase, etc. — all optional; blanks just keep that feature mocked), and run
`./setup.zsh` again. You only ever do this once per machine.

**Stage 1 — Describe your app (30 seconds).** The script asks four questions: app name,
bundle id (e.g. `com.you.app`), your one-line idea, and the App Store category. It then
**isolates your app's git repo**: if `origin` still points at this factory template it's
detached (fresh history) so app code can never overwrite the template, an app-specific
`README` is written, and — when the GitHub CLI is signed in — a **private** repo named after
your app is created and set as `origin` (description = your idea). A `pre-push` hook is
installed that hard-blocks any push to the factory, as a backstop.

**Stage 2 — Claude builds the MVP (unattended).** `setup.zsh` hands off to **`/mvp`**, which
runs end-to-end and **stops for your review**:
`spec → theme → screens → Supabase backend → paywall → legal pages + ASO → ship-check`.
When it finishes it prints exactly what changed and how to run the app.

**Stage 3 — Test it, then approve (you, ~10 min).** This is the "what do I do after `/mvp`?"
step:
```bash
flutter run --dart-define-from-file=dart_define.dev.json
```
Click through the app: onboarding → sign in (any valid email + password in mock mode) →
your main flow → the paywall → settings. Anything wrong or missing? Just tell Claude in
plain language (e.g. *"the home screen needs a search bar"*) or run **`/feature`** to add a
screen — then re-run. Iterate here until you're happy. Verify it's still clean with
`flutter analyze && flutter test`.

**Stage 4 — Ship (you, when ready).**
```bash
./ship.sh        # runs /release: pre-flight checks + release build, resumes the same session
```
`/release` produces the store-ready build and a checklist. The last mile is manual and
lives in **App Store Connect** / **Google Play Console**: signing, screenshots, the store
listing (use the `/aso` output), and pressing *Submit*. See
[docs/SECURITY.md](docs/SECURITY.md) for release hardening.

### Handy commands during Stage 3 (inside `claude`)

| Command | What it does |
|---|---|
| `/feature` | Add a screen/feature via the 11-step recipe |
| `/theme` | Regenerate the Material 3 theme |
| `/wire-paywall` | (Re)wire RevenueCat (entitlement `premium`) |
| `/swap-backend supabase` | Replace mocks with a real Supabase backend |
| `/aso` | Store keywords + metadata from **live** store data (mcp-appstore: real keyword difficulty/traffic + competitors), not model guesses |
| `/legal` | Privacy policy + terms pages |
| `/ship-check` | Pre-submit gate → PASS/FAIL + top fixes |

Secrets stay in `~/.appfactory/secrets.env` only (never committed); `setup.zsh` copies the
client-safe ones into `dart_define.dev.json`. Full details:
**[appfactory/README.md](appfactory/README.md)**.

## Configuration

All config is compile-time via `--dart-define-from-file` (see `dart_define.example.json`):

| Key | Default | Purpose |
|---|---|---|
| `APP_ENV` | `dev` | `dev`/`staging`/`prod` |
| `API_BASE_URL` | example | Base URL for the Dio client |
| `ADS_ENABLED` | `false` | Turn on real AdMob (else no-op) |
| `ADMOB_APP_ID_ANDROID` / `_IOS` | empty | AdMob app ids (also set natively) |
| `PURCHASES_ENABLED` | `false` | Turn on RevenueCat (else mock) |
| `REVENUECAT_API_KEY` | empty | RevenueCat public SDK key |

Gated integrations stay OFF until you provide the flag/key, so the default build never
touches a real SDK.

## Navigation flow

| Auth state | onboarding done | → destination |
|---|---|---|
| unresolved | any | `/splash` |
| resolved | no | `/onboarding` |
| unauthenticated | yes | `/signin` |
| authenticated | yes | `/notes` (home) |

## Project layout

```
lib/
  core/      config, di, error, network, storage, theme, l10n, router, observers, widgets, utils
  services/  ads, purchases, notifications  (interface + mock/no-op default + real impl)
  features/  auth, onboarding, settings, example_notes
docs/        ARCHITECTURE.md, CONVENTIONS.md, SECURITY.md
```

## Add a feature

Copy `features/example_notes/` and follow the 11-step recipe in **[AGENTS.md](AGENTS.md)**.

## Swap the mocks for real services

- **Auth → Firebase/Supabase:** implement `AuthDataSource`, register it in
  `injector.dart` instead of `MockAuthDataSource`. Cubits/router/UI unchanged.
- **Notes → real API/DB:** implement `NotesDataSource`, swap the registration.
- **Ads → AdMob:** set `ADS_ENABLED=true` + app ids, add native app id (see `docs/SECURITY.md`).
- **IAP → RevenueCat:** set `PURCHASES_ENABLED=true` + `REVENUECAT_API_KEY`, configure
  products + the `premium` entitlement in the RevenueCat dashboard.

## Quality

```bash
dart format .
flutter analyze
flutter test
```

## Docs

- [AGENTS.md](AGENTS.md) — conventions for AI agents (single source of truth)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [docs/CONVENTIONS.md](docs/CONVENTIONS.md)
- [docs/SECURITY.md](docs/SECURITY.md)

## Not included (documented hooks, build yourself)

Firebase/Supabase SDK wiring, analytics/crash (PostHog/Sentry), Shorebird OTA,
Widgetbook, federated Google/Apple sign-in, file uploads. All reachable from the existing
abstractions.

## License

MIT — see [LICENSE](LICENSE).
