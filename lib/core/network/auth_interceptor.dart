import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/storage/secure_store.dart';
import 'package:flutter_boilerplate/core/storage/storage_keys.dart';

/// Attaches the bearer token to outgoing requests and reacts to `401`s.
///
/// [onUnauthorized] is wired in DI (after `AuthCubit` exists) so an expired
/// session is cleared instead of silently retrying with a dead token.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStore, {this.onUnauthorized});

  final SecureStore _secureStore;

  /// Called once when the server rejects the token. Set by DI.
  Future<void> Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStore.read(StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final code = err.response?.statusCode;
    if (code == 401) {
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
