// Automated App Store / Play screenshots.
//
// Boots the REAL app (same path as main(): full DI → services → runApp(App()))
// on a simulator/emulator, then captures store-ready PNGs. Drive it with:
//
//   bash scripts/screenshots.sh
//
// which runs `flutter drive` against integration_test/test_driver/integration_test.dart,
// writes the bytes to build/screenshots/<name>.png, then copies them into
// fastlane/screenshots/<locale>/ for the ship pipeline.
//
// To add more marketing screens, follow the TODO block at the bottom of the test.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_env.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures store screenshots', (tester) async {
    // Full real startup path: global error hooks → DI → services.init() → runApp(App()).
    await bootstrap(AppEnv.dev);
    await tester.pumpAndSettle();

    await _takeScreenshot(binding, tester, '01_home');

    // TODO(/mvp): capture more marketing screens per app. Navigate the real app,
    // let it settle, then snap each one. Drive it via Keys you add to your widgets:
    //
    //   await tester.tap(find.byKey(const Key('cta_get_started')));
    //   await tester.pumpAndSettle();
    //   await _takeScreenshot(binding, tester, '02_onboarding');
    //
    //   await tester.tap(find.byKey(const Key('nav_settings')));
    //   await tester.pumpAndSettle();
    //   await _takeScreenshot(binding, tester, '03_settings');
    //
    // Name them NN_label so they sort in the store the way you list them here.
  });
}

/// Snaps the current frame to `<name>` (sink: build/screenshots/<name>.png).
///
/// iOS needs the Flutter surface converted to an image first; calling this on
/// every platform is safe because the conversion only runs on iOS.
Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(name);
}
