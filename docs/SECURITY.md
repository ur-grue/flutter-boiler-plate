# Security

## Secrets & configuration

- All keys/flags come from `AppConfig` via `--dart-define`/`--dart-define-from-file`.
  **Never** hardcode secrets in Dart.
- `dart_define*.json` is gitignored (except `dart_define.example.json`). Copy it:
  `cp dart_define.example.json dart_define.dev.json` and fill in locally.
- Also gitignored: `*.jks`, `*.keystore`, `key.properties`, `google-services.json`,
  `GoogleService-Info.plist`, `firebase_options.dart`, `.env*`.

## Tokens & storage

- Auth tokens/secrets → `SecureStore` (Keychain/Keystore via `flutter_secure_storage`).
- Non-sensitive prefs → `KeyValueStore` (`shared_preferences`).
- **Web caveat:** `flutter_secure_storage` on web uses a WebCrypto fallback that is
  best-effort, not hardware-backed. Treat web tokens as low-assurance.

## Network

- `LoggingInterceptor` is **debug-only** and redacts `Authorization`/cookie headers.
- `AuthInterceptor` attaches the bearer token and, on `401`, calls `AuthCubit.signOut()`
  to drop the dead session.
- Dio has connect/send/receive timeouts. For high-security apps add certificate pinning
  in `buildDio` (e.g. via a `badCertificateCallback` or a pinning interceptor).

## Release hardening (Android/iOS — after `flutter create .`)

- **Android:** keep R8/shrinking enabled for release; set
  `android:usesCleartextTraffic="false"`; request only the permissions you use.
- **Ads:** add your AdMob app id to `AndroidManifest.xml`
  (`com.google.android.gms.ads.APPLICATION_ID`) and iOS `Info.plist`
  (`GADApplicationIdentifier`) only when enabling ads.
- **Notifications:** Android 13+ needs `POST_NOTIFICATIONS`; precise scheduling needs
  `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`. iOS needs notification capability.

## Input

- Validate user input with `Validators`. Treat route params and deep links as untrusted.
