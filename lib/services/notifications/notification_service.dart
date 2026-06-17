import 'package:flutter_boilerplate/services/notifications/notification_models.dart';

/// Local notification abstraction (immediate + scheduled).
abstract interface class NotificationService {
  /// Initializes the plugin and timezone database. Call once in bootstrap.
  Future<void> init();

  Future<NotificationPermissionStatus> requestPermission();
  Future<NotificationPermissionStatus> permissionStatus();

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  });

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  });

  Future<void> cancel(int id);
  Future<void> cancelAll();
}
