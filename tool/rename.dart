// Dart fallback for `scripts/rename.sh` (handy on Windows).
//
// Usage:
//   dart run tool/rename.dart "My App" com.acme.myapp
//
// Run AFTER `flutter create .`. Rewrites the Dart package name, app identity,
// and (if present) native bundle identifiers.
import 'dart:io';

const _oldPkg = 'flutter_boilerplate';
const _oldBundle = 'com.example.flutter_boilerplate';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Usage: dart run tool/rename.dart "App Name" com.acme.myapp');
    exit(1);
  }
  final appName = args[0];
  final bundleId = args[1];
  final newPkg = bundleId.split('.').last.toLowerCase().replaceAll(
        RegExp('[^a-z0-9_]'),
        '',
      );
  if (newPkg.isEmpty) {
    stderr.writeln("Could not derive a Dart package name from '$bundleId'.");
    exit(1);
  }

  stdout.writeln('→ App name: $appName / bundle: $bundleId / package: $newPkg');

  // 1. Dart imports.
  for (final dir in ['lib', 'test', 'tool']) {
    final root = Directory(dir);
    if (!root.existsSync()) continue;
    for (final entity in root.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        _replace(entity, {'package:$_oldPkg/': 'package:$newPkg/'});
      }
    }
  }

  // 2. pubspec + identity.
  _replace(File('pubspec.yaml'), {'name: $_oldPkg': 'name: $newPkg'});
  _replace(File('lib/core/config/app_info.dart'), {
    RegExp("appName = '.*'"): "appName = '$appName'",
    RegExp("bundleId = '.*'"): "bundleId = '$bundleId'",
  });

  // 3. Native ids (if generated).
  // Both Groovy and Kotlin-DSL gradle files (recent Flutter uses .kts).
  for (final path in const [
    'android/app/build.gradle',
    'android/app/build.gradle.kts',
  ]) {
    final gradle = File(path);
    if (gradle.existsSync()) {
      _replace(gradle, {_oldBundle: bundleId});
    }
  }
  final pbx = File('ios/Runner.xcodeproj/project.pbxproj');
  if (pbx.existsSync()) {
    _replace(pbx, {
      RegExp('PRODUCT_BUNDLE_IDENTIFIER = [^;]*;'):
          'PRODUCT_BUNDLE_IDENTIFIER = $bundleId;',
    });
  }

  stdout.writeln('✓ Done. Run: flutter pub get && flutter gen-l10n');
}

void _replace(File file, Map<Object, String> replacements) {
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  replacements.forEach((pattern, value) {
    if (pattern is RegExp) {
      content = content.replaceAll(pattern, value);
    } else {
      content = content.replaceAll(pattern as String, value);
    }
  });
  file.writeAsStringSync(content);
}
