import 'package:flutter_boilerplate/core/config/app_env.dart';

/// Immutable runtime configuration.
///
/// Values come from `--dart-define`(`-from-file`). Every gated integration
/// defaults to OFF / empty so a fresh clone compiles and runs with zero keys.
class AppConfig {
  const AppConfig({
    required this.env,
    required this.apiBaseUrl,
    required this.adsEnabled,
    required this.purchasesEnabled,
    required this.admobAppIdAndroid,
    required this.admobAppIdIos,
    required this.revenueCatApiKey,
  });

  /// Builds config from compile-time environment values for the given [env].
  factory AppConfig.fromEnvironment(AppEnv env) {
    return AppConfig(
      env: env,
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.com',
      ),
      adsEnabled:
          const bool.fromEnvironment('ADS_ENABLED', defaultValue: false),
      purchasesEnabled:
          const bool.fromEnvironment('PURCHASES_ENABLED', defaultValue: false),
      admobAppIdAndroid: const String.fromEnvironment('ADMOB_APP_ID_ANDROID'),
      admobAppIdIos: const String.fromEnvironment('ADMOB_APP_ID_IOS'),
      revenueCatApiKey: const String.fromEnvironment('REVENUECAT_API_KEY'),
    );
  }

  final AppEnv env;
  final String apiBaseUrl;

  final bool adsEnabled;
  final String admobAppIdAndroid;
  final String admobAppIdIos;

  final bool purchasesEnabled;
  final String revenueCatApiKey;

  /// Ads only run when explicitly enabled — never in the keyless default.
  bool get useRealAds => adsEnabled;

  /// Purchases only run when enabled and a key is present.
  bool get useRealPurchases => purchasesEnabled && revenueCatApiKey.isNotEmpty;

  bool get isProd => env.isProd;
}
