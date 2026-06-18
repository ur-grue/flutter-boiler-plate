// Screenshot sink for `flutter drive`.
//
// The on-device test (integration_test/screenshots_test.dart) calls
// `binding.takeScreenshot(name)`, which hands the bytes to this host-side driver.
// We write each one to build/screenshots/<name>.png — the standard place
// scripts/screenshots.sh collects from before copying into fastlane/screenshots/.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String name,
      List<int> bytes, [
      Map<String, Object?>? args,
    ]) async {
      final file = File('build/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
