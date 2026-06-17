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

## Quick start

```bash
# 1) Create your repo from this template, then clone it.
#    GitHub UI: "Use this template" → "Create a new repository", then:
git clone https://github.com/<you>/<your-app>.git
cd <your-app>
#    Or in one step with the GitHub CLI:
gh repo create <your-app> --template ur-grue/flutter-boiler-plate --private --clone
cd <your-app>

# 2) Generate native platform folders (keeps lib/):
flutter create .

# 3) Rebrand in one command (run after step 2):
bash scripts/rename.sh "My App" com.acme.myapp
# Windows: dart run tool/rename.dart "My App" com.acme.myapp

# 4) Configure + run (keyless by default):
cp dart_define.example.json dart_define.dev.json
flutter pub get
flutter gen-l10n
flutter run --dart-define-from-file=dart_define.dev.json
```

Sign in with **any valid email + password** (mock auth).

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
