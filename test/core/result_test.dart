import 'package:flutter_boilerplate/core/error/exceptions.dart';
import 'package:flutter_boilerplate/core/error/failure.dart';
import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok folds to value', () {
      const result = Ok<int>(42);
      expect(result.isOk, isTrue);
      expect(result.fold((v) => v, (_) => -1), 42);
      expect(result.valueOrNull, 42);
    });

    test('Err folds to failure', () {
      const result = Err<int>(NetworkFailure());
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.valueOrNull, isNull);
    });

    test('map transforms Ok, preserves Err', () {
      expect(const Ok<int>(2).map((v) => v * 2).valueOrNull, 4);
      expect(
        const Err<int>(CacheFailure()).map((v) => v * 2).failureOrNull,
        isA<CacheFailure>(),
      );
    });

    test('flatMap chains', () {
      final result = const Ok<int>(2).flatMap((v) => Ok(v + 1));
      expect(result.valueOrNull, 3);
    });
  });

  group('guardAsync', () {
    test('wraps return value in Ok', () async {
      final result = await guardAsync(() async => 'ok');
      expect(result.valueOrNull, 'ok');
    });

    test('maps AuthException to AuthFailure', () async {
      final result = await guardAsync<void>(
        () async => throw const AuthException('nope'),
      );
      expect(result.failureOrNull, isA<AuthFailure>());
    });

    test('maps unknown errors to UnknownFailure', () async {
      final result = await guardAsync<void>(() async => throw Exception('x'));
      expect(result.failureOrNull, isA<UnknownFailure>());
    });
  });
}
