import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/error/exceptions.dart';

/// Converts a low-level [DioException] into a domain [AppException].
///
/// Repositories then turn these into `Failure`s via `guardAsync`.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException('Connection timed out.');
    case DioExceptionType.badCertificate:
      return const NetworkException('Bad server certificate.');
    case DioExceptionType.cancel:
      return const NetworkException('Request cancelled.');
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return const AuthException('Session expired. Please sign in again.');
      }
      if (code == 404) return const NotFoundException();
      return ServerException(
        'Server error (${code ?? 'unknown'}).',
        statusCode: code,
      );
    case DioExceptionType.unknown:
      return const NetworkException();
  }
}
