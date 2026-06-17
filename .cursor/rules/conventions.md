---
description: Project conventions for this Flutter template
globs: ["**/*.dart"]
alwaysApply: true
---

Follow **AGENTS.md** at the repo root — it is the single source of truth.

Key rules:
- Layered architecture: `presentation → domain ← data`. No code generation.
- Repositories return `Result<T>` (`Ok`/`Err`) via `guardAsync`; never throw to the UI.
- State management is Cubit (`flutter_bloc`) with sealed `Equatable` states.
- Manual `get_it` DI registered in `lib/core/di/injector.dart`.
- Localize all strings across every ARB file in `lib/core/l10n/arb/`.
- No secrets in code — use `AppConfig` (`--dart-define`); tokens in `SecureStore`.
- Add a feature by copying `features/example_notes/` (see the recipe in AGENTS.md).
- After changes run `flutter analyze` and `flutter test`.
