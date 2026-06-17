import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness: wraps [widget] in a minimal `MaterialApp` so widgets that
/// need Material ancestors render. For pages that use `context.l10n`, add the
/// localization delegates from `L10n` (requires generated localizations).
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(MaterialApp(home: Scaffold(body: widget)));
  }
}
