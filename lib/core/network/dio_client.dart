import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/config/app_config.dart';
import 'package:flutter_boilerplate/core/network/auth_interceptor.dart';
import 'package:flutter_boilerplate/core/network/logging_interceptor.dart';

/// Builds a configured [Dio] with sane timeouts plus auth + logging
/// interceptors. Use this single instance everywhere via DI.
Dio buildDio(AppConfig config, AuthInterceptor authInterceptor) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    authInterceptor,
    const LoggingInterceptor(),
  ]);

  return dio;
}
