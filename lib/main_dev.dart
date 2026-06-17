import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_env.dart';

/// Development entrypoint: `flutter run -t lib/main_dev.dart`.
Future<void> main() => bootstrap(AppEnv.dev);
