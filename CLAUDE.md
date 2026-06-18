# CLAUDE.md

Read **[AGENTS.md](AGENTS.md)** — it is the single source of truth for architecture,
conventions, and the add-a-feature recipe in this repo.

Quick reminders for Claude Code:

- Layered: `presentation → domain ← data`. No code generation.
- Repositories return `Result<T>` via `guardAsync`; the UI never sees a thrown exception.
- State = Cubit (`flutter_bloc`) with sealed `Equatable` states.
- DI is manual `get_it` in `lib/core/di/injector.dart`.
- Localize every string across all ARB files in `lib/core/l10n/arb/`.
- Never commit secrets; config comes from `AppConfig` (`--dart-define`).
- After changes: `flutter analyze` (clean) + `flutter test`.

Design skills inform intent and critique only. All UI is Flutter + Material 3 per
AGENTS.md. Ignore web/CSS advice (hover, HTML, gradients); use the boilerplate theme.

## Clean Code
Apply the project's Clean Code rules at all times: @docs/clean-code.md
