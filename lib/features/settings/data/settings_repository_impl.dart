import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/storage/key_value_store.dart';
import 'package:flutter_boilerplate/core/storage/storage_keys.dart';
import 'package:flutter_boilerplate/features/settings/data/settings_repository.dart';
import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._store);

  final KeyValueStore _store;

  @override
  AppSettings load() {
    return AppSettings(
      themeMode: _readThemeMode(),
      locale: _readLocale(),
      seedColor: _readSeedColor(),
      hapticsEnabled:
          _store.getBool(StorageKeys.hapticsEnabled) ?? true,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _store.setString(StorageKeys.themeMode, settings.themeMode.name);
    await _store.setInt(
      StorageKeys.seedColor,
      // ignore: deprecated_member_use
      settings.seedColor.value,
    );
    await _store.setBool(
      StorageKeys.hapticsEnabled,
      value: settings.hapticsEnabled,
    );
    final locale = settings.locale;
    if (locale == null) {
      await _store.remove(StorageKeys.localeCode);
    } else {
      await _store.setString(StorageKeys.localeCode, locale.languageCode);
    }
  }

  ThemeMode _readThemeMode() {
    final raw = _store.getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Locale? _readLocale() {
    final code = _store.getString(StorageKeys.localeCode);
    return code == null ? null : Locale(code);
  }

  Color _readSeedColor() {
    final value = _store.getInt(StorageKeys.seedColor);
    return value == null ? AppSettings.fallback.seedColor : Color(value);
  }
}
