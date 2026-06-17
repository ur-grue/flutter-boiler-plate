import 'package:equatable/equatable.dart';

/// Base type for all recoverable, user-facing errors.
///
/// Data sources throw [Exception]s; repositories catch them and convert to a
/// [Failure] wrapped in a [Result]. The UI only ever deals with [Failure],
/// never a raw exception.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Human-readable message safe to surface to the user.
  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.field});

  final String? field;

  @override
  List<Object?> get props => [message, field];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
