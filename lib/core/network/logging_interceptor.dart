import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/core/utils/logger.dart';

/// Debug-only request/response logger that **redacts** sensitive headers.
///
/// Disabled entirely in release builds so we never leak tokens to device logs.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  static const _redactedHeaders = {'authorization', 'cookie', 'set-cookie'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kReleaseMode) {
      AppLogger.debug(
        '→ ${options.method} ${options.uri}\n'
        'headers: ${_redact(options.headers)}',
        name: 'http',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kReleaseMode) {
      AppLogger.debug(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        name: 'http',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kReleaseMode) {
      AppLogger.error(
        '✗ ${err.requestOptions.uri} → ${err.response?.statusCode}',
        name: 'http',
        error: err.message,
      );
    }
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _redactedHeaders.contains(entry.key.toLowerCase())
            ? '***'
            : entry.value,
    };
  }
}
