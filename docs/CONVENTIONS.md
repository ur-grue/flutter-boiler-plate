# Conventions

(Agent-facing summary lives in `AGENTS.md`; this is the human version.)

## Code style

- `flutter_lints` + extra rules in `analysis_options.yaml`. CI runs
  `dart format --set-exit-if-changed`, `flutter analyze --fatal-warnings`, `flutter test`.
- Single quotes, trailing commas, `const` everywhere it's valid, explicit return types.
- No `print` — use `AppLogger`.

## Naming

- Files: `snake_case.dart`. Classes: `PascalCase`. Cubits: `XCubit`/`XState`.
- Data sources: `x_data_source.dart` (+ `mock_x_data_source.dart`). DTOs: `x_dto.dart`.

## State

- Sealed state hierarchies extending `Equatable`; list every field in `props`.
- Cubits expose intent methods (`load`, `save`, `delete`) and emit states; they never
  contain widget code.

## Errors

- Throw typed `AppException`s in data sources; map to `Failure` via `guardAsync`.
- UI handles `Failure` (e.g. `ErrorView`); it never catches raw exceptions.

## Localization

- `en` ARB is the template. Add every new key to `de`, `es`, `ar` too.
  CI/`flutter gen-l10n` writes `l10n_untranslated.json` listing gaps.

## Testing

- `bloc_test` for cubits, `mocktail` for fakes, pure functions tested directly
  (`redirect_test.dart`, `result_test.dart`). Keep tests fast and deterministic.
