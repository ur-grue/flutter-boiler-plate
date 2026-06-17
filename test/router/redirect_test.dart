import 'package:flutter_boilerplate/core/router/app_router.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/auth/domain/user.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = AppUser(id: '1', email: 'a@b.com');

  group('redirectGuard', () {
    test('unresolved auth stays on splash', () {
      expect(
        redirectGuard(
          location: Routes.notesPath,
          auth: const AuthInitial(),
          onboardingDone: true,
        ),
        Routes.splashPath,
      );
      expect(
        redirectGuard(
          location: Routes.splashPath,
          auth: const AuthLoading(),
          onboardingDone: true,
        ),
        isNull,
      );
    });

    test('onboarding gate precedes auth', () {
      expect(
        redirectGuard(
          location: Routes.notesPath,
          auth: const Unauthenticated(),
          onboardingDone: false,
        ),
        Routes.onboardingPath,
      );
    });

    test('unauthenticated forced to sign-in', () {
      expect(
        redirectGuard(
          location: Routes.notesPath,
          auth: const Unauthenticated(),
          onboardingDone: true,
        ),
        Routes.signInPath,
      );
    });

    test('authenticated bounced off transient screens to notes', () {
      expect(
        redirectGuard(
          location: Routes.signInPath,
          auth: const Authenticated(user),
          onboardingDone: true,
        ),
        Routes.notesPath,
      );
    });

    test('authenticated allowed on app screens', () {
      expect(
        redirectGuard(
          location: Routes.settingsPath,
          auth: const Authenticated(user),
          onboardingDone: true,
        ),
        isNull,
      );
    });

    test('no state maps a location to itself (loop-free)', () {
      const states = [
        AuthInitial(),
        AuthLoading(),
        Unauthenticated(),
        Authenticated(user),
      ];
      const locations = [
        Routes.splashPath,
        Routes.onboardingPath,
        Routes.signInPath,
        Routes.notesPath,
        Routes.settingsPath,
      ];
      for (final auth in states) {
        for (final onboarding in [true, false]) {
          for (final loc in locations) {
            final target = redirectGuard(
              location: loc,
              auth: auth,
              onboardingDone: onboarding,
            );
            // A redirect target must never equal the current location's
            // redirect again into a different place infinitely: a single
            // redirect should resolve to a stable allowed location.
            if (target != null) {
              final second = redirectGuard(
                location: target,
                auth: auth,
                onboardingDone: onboarding,
              );
              expect(
                second,
                isNull,
                reason: 'redirect $loc -> $target should be stable',
              );
            }
          }
        }
      }
    });
  });
}
