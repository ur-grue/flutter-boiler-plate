import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/features/settings/data/settings_repository.dart';
import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory fake; no codegen/mocks needed for a simple store.
class _FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings = AppSettings.fallback;

  @override
  AppSettings load() => _settings;

  @override
  Future<void> save(AppSettings settings) async => _settings = settings;
}

void main() {
  late _FakeSettingsRepository repo;
  setUp(() => repo = _FakeSettingsRepository());

  blocTest<SettingsCubit, SettingsState>(
    'load emits SettingsReady with fallback',
    build: () => SettingsCubit(repo),
    act: (cubit) => cubit.load(),
    expect: () => [const SettingsReady(AppSettings.fallback)],
  );

  blocTest<SettingsCubit, SettingsState>(
    'setThemeMode persists and emits dark',
    build: () => SettingsCubit(repo),
    act: (cubit) {
      cubit.load();
      return cubit.setThemeMode(ThemeMode.dark);
    },
    skip: 1,
    verify: (cubit) {
      final state = cubit.state as SettingsReady;
      expect(state.settings.themeMode, ThemeMode.dark);
      expect(repo.load().themeMode, ThemeMode.dark);
    },
  );
}
