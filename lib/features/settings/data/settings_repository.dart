import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';

/// Persists [AppSettings]. Backed by [KeyValueStore].
abstract interface class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
