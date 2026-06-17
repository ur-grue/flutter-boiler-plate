/// Centralized storage keys to avoid stringly-typed drift.
abstract final class StorageKeys {
  // KeyValueStore (non-sensitive).
  static const String onboardingDone = 'onboarding_done';
  static const String themeMode = 'theme_mode';
  static const String localeCode = 'locale_code';
  static const String seedColor = 'seed_color';
  static const String hapticsEnabled = 'haptics_enabled';

  // SecureStore (sensitive).
  static const String authToken = 'auth_token';
  static const String authUserId = 'auth_user_id';
}
