# Architecture

Feature-first Clean Architecture with a shared `core/` and injectable `services/`.

```
presentation  →  domain  ←  data
   (Cubits)      (entities,     (data sources,
                  repo IfaceS)    DTOs, repo impls)
```

## Layers

- **domain** — Pure Dart. Entities (`Equatable`) and repository *interfaces* that
  return `Result<T>`. No Flutter or package imports.
- **data** — Implements the interfaces. `*_data_source.dart` talk to the outside world
  (mock, API, DB) and throw `AppException`s; `*_repository_impl.dart` wrap them in
  `guardAsync` to produce `Result`s; DTOs handle JSON by hand.
- **presentation** — Cubits hold sealed states; pages/widgets render them and call
  cubit methods. Pages obtain cubits from `get_it`.

## Cross-cutting (`core/`)

`config` (env + `AppConfig`), `di` (`get_it` locator), `error` (`Result`/`Failure`),
`network` (Dio + interceptors), `storage` (`KeyValueStore`, `SecureStore`), `theme`,
`l10n`, `router` (`go_router` + pure redirect guard), `observers` (BlocObserver),
`widgets`, `utils`.

## Services (`services/`)

`ads`, `purchases`, `notifications` — each an interface with a mock/no-op default and a
real impl. The impl is chosen in `injector.dart` from `AppConfig` flags, so the app runs
keyless and you opt into real SDKs explicitly.

## App startup

`main*.dart → bootstrap(env)`:
1. Install global error handlers (`runZonedGuarded`, `FlutterError.onError`,
   `PlatformDispatcher.onError`) + `Bloc.observer` + custom `ErrorWidget.builder`.
2. Build `AppConfig`, run `configureDependencies`.
3. Init services; load settings; `AuthCubit.bootstrap()`.
4. `runApp(App())` — `MaterialApp.router` rebuilds on settings changes; the router is
   built once and re-evaluates redirects via `AuthCubit`'s stream.

## Routing & guards

`redirectGuard` is a pure function (unit-tested, proven loop-free): splash while auth is
unresolved → onboarding gate → sign-in if unauthenticated → app. See the table in the
README.
