// Real launch proof. Unlike the unit/cubit tests (which run on the host VM and never call
// runApp/bootstrap), this runs on a real device/simulator and boots the ACTUAL app the way
// `main()` does — full DI, services init, and `runApp(App())`. It is the first line of defence
// against crashes that green `flutter test` cannot see: DI/bootstrap failures, and — when run on
// a simulator — native plugin misconfiguration (e.g. a missing AdMob app id → SIGABRT at launch).
//
// Run it ON A SIMULATOR/DEVICE (not the host VM):
//   flutter test integration_test/app_boot_test.dart -d <device-id>
// `bash scripts/smoke-launch.sh` does this for you and is part of the /mvp definition-of-done.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots via bootstrap and renders its first screen',
      (tester) async {
    // Full real startup path: global error hooks → DI → services.init() → runApp(App()).
    await bootstrap(AppEnv.dev);
    await tester.pumpAndSettle();

    // If DI/bootstrap threw, runApp never ran and there is no MaterialApp → this fails.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
