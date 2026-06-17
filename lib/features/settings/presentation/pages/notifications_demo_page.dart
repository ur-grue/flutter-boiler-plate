import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/di/injector.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_spacing.dart';
import 'package:flutter_boilerplate/core/widgets/app_button.dart';
import 'package:flutter_boilerplate/services/notifications/notification_models.dart';
import 'package:flutter_boilerplate/services/notifications/notification_service.dart';

class NotificationsDemoPage extends StatefulWidget {
  const NotificationsDemoPage({super.key});

  @override
  State<NotificationsDemoPage> createState() => _NotificationsDemoPageState();
}

class _NotificationsDemoPageState extends State<NotificationsDemoPage> {
  final NotificationService _service = getIt<NotificationService>();

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _requestPermission() async {
    final status = await _service.requestPermission();
    if (!mounted) return;
    _snack(
      status == NotificationPermissionStatus.granted
          ? context.l10n.notificationPermissionGranted
          : context.l10n.notificationPermissionDenied,
    );
  }

  Future<void> _sendNow() => _service.showNow(
        id: 1,
        title: context.l10n.notificationSampleTitle,
        body: context.l10n.notificationSampleBody,
      );

  Future<void> _schedule() => _service.schedule(
        id: 2,
        title: context.l10n.notificationSampleTitle,
        body: context.l10n.notificationSampleBody,
        when: DateTime.now().add(const Duration(seconds: 5)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsDemoTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.lock_open_outlined),
                label: Text(l10n.notificationRequestPermission),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.notificationSendNow,
                icon: Icons.send_outlined,
                onPressed: _sendNow,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.notificationScheduled,
                icon: Icons.schedule_outlined,
                onPressed: _schedule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
