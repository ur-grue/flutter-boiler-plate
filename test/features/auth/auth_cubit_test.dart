import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_boilerplate/core/error/failure.dart';
import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/features/auth/domain/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/domain/user.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;
  const user = AppUser(id: '1', email: 'a@b.com');

  setUp(() => repo = _MockAuthRepository());

  group('bootstrap', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Unauthenticated] when no session',
      setUp: () => when(repo.restoreSession)
          .thenAnswer((_) async => const Ok<AppUser?>(null)),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.bootstrap(),
      expect: () => [const AuthLoading(), const Unauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Authenticated] when session restored',
      setUp: () => when(repo.restoreSession)
          .thenAnswer((_) async => const Ok<AppUser?>(user)),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.bootstrap(),
      expect: () => [const AuthLoading(), const Authenticated(user)],
    );
  });

  group('signIn', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Authenticated] and returns null on success',
      setUp: () => when(() => repo.signIn(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => const Ok(user)),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.signIn('a@b.com', 'secret123'),
      expect: () => [const Authenticated(user)],
    );

    test('returns failure message on error', () async {
      when(() => repo.signIn(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => const Err<AppUser>(AuthFailure('bad')));
      final cubit = AuthCubit(repo);
      final message = await cubit.signIn('a@b.com', 'x');
      expect(message, 'bad');
      expect(cubit.state, const Unauthenticated());
    });
  });
}
