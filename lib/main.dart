import 'package:flutter_boilerplate/bootstrap.dart';
import 'package:flutter_boilerplate/core/config/app_env.dart';

/// Default entrypoint. Reads `APP_ENV` from `--dart-define` (defaults to dev).
/// For explicit flavors use `main_dev.dart` / `main_prod.dart`.
Future<void> main() async {
  const envName = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  await bootstrap(AppEnv.fromName(envName));
}
