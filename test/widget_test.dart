// Real smoke test that intentionally OCCUPIES the `test/widget_test.dart` filename.
//
// `flutter create .` injects a default counter test here (referencing a non-existent
// `MyApp`) whenever this file is absent — which then breaks `flutter test`. By shipping a
// real test under this exact path, `flutter create .` can never re-introduce that broken
// default. Kept dependency-light (no get_it/DI, no plugins) so it's fast and reliable.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';
import 'package:flutter_boilerplate/core/theme/app_theme.dart';

void main() {
  const seed = Color(0xFF6750A4);

  test('app identity is set (no leftover template default counter app)', () {
    expect(AppInfo.appName, isNotEmpty);
  });

  testWidgets('app theme builds and a basic scaffold renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(seed),
        darkTheme: AppTheme.dark(seed),
        home: Scaffold(
          appBar: AppBar(title: const Text(AppInfo.appName)),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text(AppInfo.appName), findsOneWidget);
  });
}
