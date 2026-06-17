import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Thin logging wrapper. In release builds non-error logs are dropped so we
/// never leak diagnostics. Swap the body to wire Sentry/Crashlytics later.
abstract final class AppLogger {
  static void debug(String message, {String name = 'app'}) {
    if (kReleaseMode) return;
    developer.log(message, name: name, level: 500);
  }

  static void info(String message, {String name = 'app'}) {
    if (kReleaseMode) return;
    developer.log(message, name: name, level: 800);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'app',
  }) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
