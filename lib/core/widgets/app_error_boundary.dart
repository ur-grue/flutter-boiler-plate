import 'package:flutter/material.dart';

/// A friendly replacement for Flutter's default red error screen.
///
/// Install via `ErrorWidget.builder = AppErrorBoundary.builder;` in bootstrap.
abstract final class AppErrorBoundary {
  static Widget builder(FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF1C1B1F),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bug_report_outlined,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
