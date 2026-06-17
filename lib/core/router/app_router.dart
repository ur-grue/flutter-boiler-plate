import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/router/go_router_refresh_stream.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/storage/key_value_store.dart';
import 'package:flutter_boilerplate/core/storage/storage_keys.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_boilerplate/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_boilerplate/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/pages/note_editor_page.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/pages/notes_list_page.dart';
import 'package:flutter_boilerplate/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_boilerplate/features/settings/presentation/pages/notifications_demo_page.dart';
import 'package:flutter_boilerplate/features/settings/presentation/pages/paywall_page.dart';
import 'package:flutter_boilerplate/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

/// Pure redirect decision. Extracted so it can be unit-tested in isolation
/// (`test/router/redirect_test.dart`) and proven loop-free.
String? redirectGuard({
  required String location,
  required AuthState auth,
  required bool onboardingDone,
}) {
  // 1. Session not yet resolved → wait on splash.
  if (auth is AuthInitial || auth is AuthLoading) {
    return location == Routes.splashPath ? null : Routes.splashPath;
  }

  // 2. Onboarding gate (before auth) so fresh installs see the intro first.
  if (!onboardingDone) {
    return location == Routes.onboardingPath ? null : Routes.onboardingPath;
  }

  final authed = auth is Authenticated;
  const transientLocations = {
    Routes.splashPath,
    Routes.onboardingPath,
    Routes.signInPath,
  };

  // 3. Signed out → force sign-in.
  if (!authed) {
    return location == Routes.signInPath ? null : Routes.signInPath;
  }

  // 4. Signed in but sitting on splash/onboarding/sign-in → go home.
  if (transientLocations.contains(location)) return Routes.notesPath;

  // 5. Otherwise allow.
  return null;
}

GoRouter createRouter({
  required AuthCubit authCubit,
  required KeyValueStore store,
}) {
  return GoRouter(
    initialLocation: Routes.splashPath,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) => redirectGuard(
      location: state.matchedLocation,
      auth: authCubit.state,
      onboardingDone: store.getBool(StorageKeys.onboardingDone) ?? false,
    ),
    routes: [
      GoRoute(
        path: Routes.splashPath,
        name: Routes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.onboardingPath,
        name: Routes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.signInPath,
        name: Routes.signIn,
        builder: (_, __) => const SignInPage(),
      ),
      GoRoute(
        path: Routes.notesPath,
        name: Routes.notes,
        builder: (_, __) => const NotesListPage(),
        routes: [
          GoRoute(
            path: Routes.noteNewPath,
            name: Routes.noteNew,
            builder: (_, __) => const NoteEditorPage(),
          ),
          GoRoute(
            path: Routes.noteEditPath,
            name: Routes.noteEdit,
            builder: (_, state) =>
                NoteEditorPage(id: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settingsPath,
        name: Routes.settings,
        builder: (_, __) => const SettingsPage(),
        routes: [
          GoRoute(
            path: Routes.paywallPath,
            name: Routes.paywall,
            builder: (_, __) => const PaywallPage(),
          ),
          GoRoute(
            path: Routes.notificationsPath,
            name: Routes.notifications,
            builder: (_, __) => const NotificationsDemoPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
