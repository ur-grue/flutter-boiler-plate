import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/network/auth_interceptor.dart';
import 'package:flutter_boilerplate/core/network/dio_client.dart';
import 'package:flutter_boilerplate/core/storage/flutter_secure_store.dart';
import 'package:flutter_boilerplate/core/storage/key_value_store.dart';
import 'package:flutter_boilerplate/core/storage/secure_store.dart';
import 'package:flutter_boilerplate/core/storage/shared_prefs_store.dart';
import 'package:flutter_boilerplate/features/auth/data/auth_repository_impl.dart';
import 'package:flutter_boilerplate/features/auth/data/mock_auth_data_source.dart';
import 'package:flutter_boilerplate/features/auth/domain/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/data/mock_notes_data_source.dart';
import 'package:flutter_boilerplate/features/example_notes/data/notes_repository_impl.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/notes_repository.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:flutter_boilerplate/features/settings/data/settings_repository.dart';
import 'package:flutter_boilerplate/features/settings/data/settings_repository_impl.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/subscription_cubit.dart';
import 'package:flutter_boilerplate/services/ads/admob_ads_service.dart';
import 'package:flutter_boilerplate/services/ads/ads_service.dart';
import 'package:flutter_boilerplate/services/ads/noop_ads_service.dart';
import 'package:flutter_boilerplate/services/notifications/local_notification_service.dart';
import 'package:flutter_boilerplate/services/notifications/notification_service.dart';
import 'package:flutter_boilerplate/services/purchases/mock_purchase_service.dart';
import 'package:flutter_boilerplate/services/purchases/purchase_service.dart';
import 'package:flutter_boilerplate/services/purchases/revenuecat_purchase_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator.
final GetIt getIt = GetIt.instance;

/// Wires the whole object graph. Mock/no-op service impls are the default;
/// real impls are selected only when their `AppConfig` flag/key is present.
///
/// To register a new feature: add its data source, repository, and cubits here
/// following the existing pattern (see `AGENTS.md`).
Future<void> configureDependencies(AppConfig config) async {
  // --- config ---
  getIt.registerSingleton<AppConfig>(config);

  // --- storage ---
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<KeyValueStore>(SharedPrefsStore(prefs))
    ..registerSingleton<SecureStore>(FlutterSecureStore());

  // --- network (auth interceptor's 401 handler is wired after AuthCubit) ---
  final authInterceptor = AuthInterceptor(getIt<SecureStore>());
  getIt
    ..registerSingleton<AuthInterceptor>(authInterceptor)
    ..registerLazySingleton<Dio>(() => buildDio(config, authInterceptor));

  // --- services (gated; safe defaults) ---
  getIt
    ..registerSingleton<AdsService>(
      config.useRealAds ? AdMobAdsService() : const NoOpAdsService(),
    )
    ..registerSingleton<PurchaseService>(
      config.useRealPurchases
          ? RevenueCatPurchaseService(config.revenueCatApiKey)
          : MockPurchaseService(),
    )
    ..registerSingleton<NotificationService>(LocalNotificationService());

  // --- repositories ---
  getIt
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(MockAuthDataSource(getIt<SecureStore>())),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<KeyValueStore>()),
    )
    ..registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(MockNotesDataSource()),
    );

  // --- global cubits (singletons) ---
  getIt
    ..registerLazySingleton<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    ..registerLazySingleton<SettingsCubit>(
      () => SettingsCubit(getIt<SettingsRepository>()),
    )
    ..registerLazySingleton<SubscriptionCubit>(
      () => SubscriptionCubit(getIt<PurchaseService>()),
    );

  // --- per-screen cubits (factories) ---
  getIt
    ..registerFactory<OnboardingCubit>(
      () => OnboardingCubit(getIt<KeyValueStore>()),
    )
    ..registerFactory<NotesCubit>(() => NotesCubit(getIt<NotesRepository>()))
    ..registerFactory<NoteEditorCubit>(
      () => NoteEditorCubit(getIt<NotesRepository>()),
    );

  // Clear an expired session when the API rejects the token.
  authInterceptor.onUnauthorized = () => getIt<AuthCubit>().signOut();
}
