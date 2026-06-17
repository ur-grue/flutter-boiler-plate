import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/settings/data/settings_repository.dart';
import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';

/// Global settings state. `app.dart` rebuilds `MaterialApp.router` from this,
/// so every change is applied instantly and persisted.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsLoading());

  final SettingsRepository _repository;

  void load() => emit(SettingsReady(_repository.load()));

  AppSettings get _current => switch (state) {
        SettingsReady(:final settings) => settings,
        SettingsLoading() => AppSettings.fallback,
      };

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(_current.copyWith(themeMode: mode));

  Future<void> setLocale(Locale? locale) =>
      _update(_current.copyWith(locale: () => locale));

  Future<void> setSeedColor(Color color) =>
      _update(_current.copyWith(seedColor: color));

  Future<void> setHaptics({required bool enabled}) =>
      _update(_current.copyWith(hapticsEnabled: enabled));

  Future<void> _update(AppSettings settings) async {
    emit(SettingsReady(settings));
    await _repository.save(settings);
  }
}
