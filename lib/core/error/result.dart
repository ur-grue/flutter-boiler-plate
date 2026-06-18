import 'package:flutter_boilerplate/core/error/exceptions.dart';
import 'package:flutter_boilerplate/core/error/failure.dart';

/// A functional result type: either an [Ok] value or an [Err] [Failure].
///
/// Repositories return `Result<T>` so callers must handle failure explicitly;
/// the UI never sees a thrown exception.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final failure) => failure,
      };

  /// Collapses both branches into a single value.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };

  /// Transforms the success value, preserving any failure.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => Ok(transform(value)),
        Err<T>(:final failure) => Err(failure),
      };

  /// Chains another `Result`-returning operation.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => transform(value),
        Err<T>(:final failure) => Err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [body], converting known [AppException]s into the matching [Failure].
///
/// This is the single choke point where the data layer's exceptions become the
/// domain layer's failures.
Future<Result<T>> guardAsync<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on AuthException catch (e) {
    return Err(AuthFailure(e.message));
  } on NotFoundException catch (e) {
    return Err(NotFoundFailure(e.message));
  } on NetworkException catch (e) {
    return Err(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return Err(ServerFailure(e.message, statusCode: e.statusCode));
  } on CacheException catch (e) {
    return Err(CacheFailure(e.message));
  } on AppException catch (e) {
    return Err(UnknownFailure(e.message));
  } catch (_) {
    return const Err(UnknownFailure());
  }
}
