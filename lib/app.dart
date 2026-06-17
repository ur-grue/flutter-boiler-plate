import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/di/injector.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/app_router.dart';
import 'package:flutter_boilerplate/core/storage/key_value_store.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_boilerplate/features/settings/domain/app_settings.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/subscription_cubit.dart';
import 'package:go_router/go_router.dart';

/// Root widget. Provides the global cubits and rebuilds `MaterialApp.router`
/// when settings (theme/locale/seed) change. The router itself is built once.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createRouter(
    authCubit: getIt<AuthCubit>(),
    store: getIt<KeyValueStore>(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<SettingsCubit>()),
        BlocProvider.value(value: getIt<SubscriptionCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settings = switch (state) {
            SettingsReady(:final settings) => settings,
            SettingsLoading() => AppSettings.fallback,
          };

          return MaterialApp.router(
            title: AppInfo.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(settings.seedColor),
            darkTheme: AppTheme.dark(settings.seedColor),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: L10n.supportedLocales,
            localizationsDelegates: L10n.delegates,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
