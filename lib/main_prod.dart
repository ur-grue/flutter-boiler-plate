import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_env.dart';

/// Production entrypoint: `flutter run -t lib/main_prod.dart --release \
///   --dart-define-from-file=dart_define.prod.json`.
Future<void> main() => bootstrap(AppEnv.prod);
