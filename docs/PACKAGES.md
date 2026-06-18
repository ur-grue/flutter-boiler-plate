# PACKAGES.md — package-selection guardrail

A curated "what package for what need" map for this template, distilled from the
[awesome-flutter](https://github.com/Solido/awesome-flutter) ecosystem and **filtered to
this repo's rules**. Consult this before adding any dependency.

## The hard rule: no codegen / no build_runner

This template forbids code generation (Golden Rule #3 in [AGENTS.md](../AGENTS.md)).
**Prefer runtime / manual approaches.** Write DTOs, `fromJson`/`toJson`, and `copyWith`
by hand. Never add a package that requires `build_runner`, `*.g.dart`, or `*.freezed.dart`
to function. The only allowed generator is the built-in `flutter gen-l10n` for localization.

Keep dependencies **lean**. Reuse what is already in `pubspec.yaml` before reaching for
anything new. Any capability that needs API keys or native setup goes **behind an
interface in `lib/services/`** with a mock/no-op default, mirroring `ads`, `purchases`,
and `notifications` — so the app always compiles and runs keyless.

## Need → package map

| Need | Recommended | Notes |
| --- | --- | --- |
| HTTP client | **`dio`** (in repo) | Reuse it. Interceptors for auth/logging; no codegen. Do not add `retrofit`. |
| State management | **`flutter_bloc`** (Cubit, in repo) | Reuse. Sealed `Equatable` states. Do **not** add riverpod/getx/mobx/provider. |
| Value equality | **`equatable`** (in repo) | Reuse for entities and states. |
| Dependency injection | **`get_it`** (in repo) | Manual registration in `injector.dart`. Do **not** add `injectable`. |
| Routing | **`go_router`** (in repo) | Reuse. Pure redirect guard. Do **not** add `auto_route`. |
| JSON / serialization | **Manual `fromJson`/`toJson`** | Hand-written DTOs only. No `json_serializable`, no `freezed`. |
| Local key-value | **`shared_preferences`** (in repo) | Non-secret prefs/flags via `KeyValueStore`. |
| Secure storage | **`flutter_secure_storage`** (in repo) | Tokens/secrets via `SecureStore`, never `KeyValueStore`. |
| Local database | **`sqflite`** or **`hive`** | No codegen. For Hive write `TypeAdapter`s by hand or store maps — do **not** use the old `hive_generator`/`build_runner` adapters. `hive_ce` is the maintained fork if you need Hive. |
| Charts | **`fl_chart`** | Popular, maintained, no codegen. |
| Cached/network images | **`cached_network_image`** | Disk + memory cache, no codegen. |
| Pick images/files | **`image_picker`** | Native pickers; needs platform permissions. |
| Date / number format | **`intl`** (in repo) | Reuse. Pairs with `flutter gen-l10n`. |
| Permissions | **`permission_handler`** (in repo) | Reuse. Request near point of use. |
| Local notifications | **`flutter_local_notifications`** + **`timezone`** (in repo) | Reuse, behind the `notifications` service. |
| Env / config | **`--dart-define` via `AppConfig`** | Compile-time config. Do **not** add `flutter_dotenv` for prod secrets. |
| Animations | **Built-in** (`AnimatedX`, `Tween`) + **`lottie`** if needed | `lottie` plays exported JSON; no codegen. |
| Forms / validation | **Built-in `Form`** + repo `validators.dart` | No third-party form/codegen package needed. |
| WebView | **`webview_flutter`** | Official plugin; native setup only. |
| Maps | **`google_maps_flutter`** | Keyed + native setup → put behind a `services/` interface with a mock default. |
| URL / external launch | **`url_launcher`** | Official, no codegen. |
| Connectivity | **`connectivity_plus`** | Maintained `*_plus` family, no codegen. |
| Device / package info | **`device_info_plus`**, **`package_info_plus`** | Maintained, no codegen. |
| Logging | **`logger`** or `dart:developer` | No codegen. Keep noise low. |
| Motion sensors (accel/gyro/magnetometer/**barometer**) | **`sensors_plus`** | `*_plus`, no codegen. **Streams**, often 50–200 Hz → see "Realtime & sensors" below; never emit a Cubit state per sample. |
| Location / GPS | **`geolocator`** | Native perms (Info.plist usage string + Android perms) added per app. Behind a `services/` interface with a mock default. |
| Camera viewfinder | **`camera`** (live preview) or **`image_picker`** (one-shot) | Native perms. Heavy; isolate decode if processing frames. |
| Bluetooth LE | **`flutter_blue_plus`** | Streams of scan results/notifications. Native perms. Behind a service. |
| NFC | **`nfc_manager`** | iOS entitlement + Android perm. Behind a service. |
| Audio playback / record | **`just_audio`** / **`record`** | No codegen. DSP-heavy work → isolate; don't block the UI isolate. |
| Realtime networking (multiplayer, live data) | **`web_socket_channel`** / **`socket_io_client`** | Streaming, **not** request/response — wrap as a `Stream<T>` repository (see below), not the `dio` + `Result<T>` pattern. |
| Heavy compute (ML, image/video, parsing) | **`dart:isolate`** / **`compute`**, **`dart:ffi`** for native | Offload off the UI isolate. Not scaffolded — add per app. |

## Realtime & sensors (streams, not request/response)

The repository pattern here returns `Future<Result<T>>` — perfect for request/response
(REST, RPC). High-frequency sources (sensors, sockets, BLE, audio levels) are **streams**,
and the same layering still applies — just with a stream signature:

- Expose `Stream<T>` from the repository/service interface, e.g.
  `Stream<MotionSample> motion()` or `Stream<GameSnapshot> snapshots()`. Keep a **mock
  default** (a synthetic `Stream`) so the app runs keyless and tests stay offline.
- **Do not emit a Cubit state per sample.** Pumping a 100 Hz gyro stream through
  `emit(ImmutableState(...))` + `Equatable` rebuilds the widget tree 100×/s. Instead:
  throttle/buffer in the Cubit (emit coarse, derived state), or for the hot visual path
  drive an `AnimatedBuilder`/`StreamBuilder`/`CustomPainter` off the raw stream and reserve
  the Cubit for coarse state (recording? permission granted? error?).
- **Native permissions are per-app.** Sensors/location/camera/BLE/NFC need Info.plist usage
  strings and AndroidManifest permissions that this template does **not** pre-declare (it
  can't know which you need). Add them when you wire the capability.

## Not the right base: real-time games

This is an **app** foundation (Cubit + immutable state + screen routing), not a **game
engine**. A 60 fps game loop wants mutable per-frame state and a render surface, which fights
the immutable-state model. For the gameplay layer use **`flame`** (+ `forge2d`) or the Flutter
Casual Games Toolkit. You can still use this template for the **shell** around a game — auth,
store/IAP, leaderboards UI, settings — and embed the game as a widget.

## DO NOT ADD (violates the no-codegen rule)

These are popular but require `build_runner` / generated files. **Never add them:**

- `freezed` / `freezed_annotation`
- `json_serializable` / `json_annotation`
- `retrofit` / `retrofit_generator`
- `riverpod_generator` (and `@riverpod` codegen) — also: do not add Riverpod at all
- `auto_route` (codegen router)
- `injectable` / `injectable_generator`
- `built_value` / `built_collection` (codegen)
- `hive_generator` (use hand-written `TypeAdapter`s or `hive_ce`)
- `drift` in codegen mode, `floor`, `objectbox` generator
- any `*_generator` package or anything whose README starts with "run build_runner"

## How to add a dependency

1. **Justify the need** against this map — can existing packages do it? Reuse first.
2. **Verify on pub.dev:** actively maintained (recent release), high popularity/likes,
   and a "Dart 3 / current Flutter" compatible constraint.
3. **No `build_runner`.** If it generates code, reject it and find a runtime alternative.
4. **Gate keyed/native capabilities:** if it needs API keys or platform config, wrap it
   behind a `lib/services/<x>/` interface with a **mock/no-op default**, real impl chosen
   in `injector.dart` from an `AppConfig` flag. The app must still compile keyless.
5. **Pin a version** (caret range like the existing entries) in `pubspec.yaml`.
6. **Verify:** `flutter analyze` (clean) + `flutter test`, and `dart format`.

---

*Curated from [github.com/Solido/awesome-flutter](https://github.com/Solido/awesome-flutter)
(CC0), filtered to this repo's no-codegen + layered conventions.*
