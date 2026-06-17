import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/widgets/app_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('AppButton shows label and fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpApp(
      AppButton(label: 'Go', onPressed: () => tapped = true),
    );

    expect(find.text('Go'), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    expect(tapped, isTrue);
  });

  testWidgets('AppButton shows spinner when loading', (tester) async {
    await tester.pumpApp(
      const AppButton(label: 'Go', onPressed: null, isLoading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Go'), findsNothing);
  });
}
