import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/app.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/config/app_env.dart';
import 'package:flutter_boilerplate/core/di/injector.dart';
import 'package:flutter_boilerplate/core/observers/app_bloc_observer.dart';
import 'package:flutter_boilerplate/core/utils/logger.dart';
import 'package:flutter_boilerplate/core/widgets/app_error_boundary.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/services/ads/ads_service.dart';
import 'package:flutter_boilerplate/services/notifications/notification_service.dart';
import 'package:flutter_boilerplate/services/purchases/purchase_service.dart';

/// Single entrypoint used by every `main_*.dart`. Installs global error
/// handling, initializes services + DI, then runs the app.
Future<void> bootstrap(AppEnv env) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      Bloc.observer = const AppBlocObserver();
      ErrorWidget.builder = AppErrorBoundary.builder;

      // Surface framework + platform errors through one logger/crash hook.
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLogger.error(
          'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.error('PlatformError', error: error, stackTrace: stack);
        return true;
      };

      final config = AppConfig.fromEnvironment(env);
      await configureDependencies(config);

      // Initialize services (mock/no-op impls are cheap and safe).
      await getIt<NotificationService>().init();
      await getIt<PurchaseService>().init();
      if (config.useRealAds) await getIt<AdsService>().init();

      // Resolve initial session + load persisted settings before first frame.
      getIt<SettingsCubit>().load();
      await getIt<AuthCubit>().bootstrap();

      runApp(const App());
    },
    (error, stack) =>
        AppLogger.error('Uncaught zone error', error: error, stackTrace: stack),
  );
}
