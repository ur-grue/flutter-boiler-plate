/// Build environment selected by the entrypoint (`main_dev`, `main_prod`, ...).
enum AppEnv {
  dev,
  staging,
  prod;

  static AppEnv fromName(String name) => switch (name) {
        'prod' => AppEnv.prod,
        'staging' => AppEnv.staging,
        _ => AppEnv.dev,
      };

  bool get isDev => this == AppEnv.dev;
  bool get isProd => this == AppEnv.prod;

  String get label => switch (this) {
        AppEnv.dev => 'DEV',
        AppEnv.staging => 'STAGING',
        AppEnv.prod => 'PROD',
      };
}
