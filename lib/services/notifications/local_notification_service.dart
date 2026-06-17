import 'dart:io';

import 'package:flutter_boilerplate/services/notifications/notification_models.dart';
import 'package:flutter_boilerplate/services/notifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// `flutter_local_notifications`-backed service with timezone-aware scheduling.
///
/// Native setup (Android 13+ POST_NOTIFICATIONS / exact-alarm permissions, iOS
/// capabilities) is documented in `docs/SECURITY.md` and the README.
class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationDetails(
    'default_channel',
    'General',
    channelDescription: 'General notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  static const _details = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return (granted ?? false)
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    final status = await Permission.notification.request();
    return _map(status);
  }

  @override
  Future<NotificationPermissionStatus> permissionStatus() async {
    if (Platform.isIOS) {
      // iOS doesn't expose a sync status here; treat as not-determined.
      return NotificationPermissionStatus.notDetermined;
    }
    return _map(await Permission.notification.status);
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) =>
      _plugin.show(id, title, body, _details);

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) =>
      _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  NotificationPermissionStatus _map(PermissionStatus status) {
    if (status.isGranted) return NotificationPermissionStatus.granted;
    if (status.isPermanentlyDenied || status.isDenied) {
      return NotificationPermissionStatus.denied;
    }
    return NotificationPermissionStatus.notDetermined;
  }
}
