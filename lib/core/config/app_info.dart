/// Centralized app identity.
///
/// `scripts/rename.sh` rewrites these values (and the Dart package name) when
/// you spin up a new app from this template, so keep brand strings here rather
/// than scattering literals across the codebase.
abstract final class AppInfo {
  /// Human-facing product name.
  static const String appName = 'Flutter Boilerplate';

  /// Reverse-DNS identifier; mirror of Android applicationId / iOS bundle id.
  static const String bundleId = 'com.example.flutter_boilerplate';
}
