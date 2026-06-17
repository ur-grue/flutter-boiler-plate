/// Internal exceptions thrown by data sources.
///
/// These never reach the UI directly — repositories map them to [Failure]s via
/// `guardAsync`. Keeping them separate from [Failure] keeps the data layer free
/// of presentation concerns.
library;

class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Auth error']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']);
}
