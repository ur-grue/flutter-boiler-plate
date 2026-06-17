# /swap-backend — Supabase instead of mocks
Implement AuthDataSource against supabase_flutter; register it in injector.dart
instead of MockAuthDataSource. Keep cubits/router/UI unchanged. Add in-app
account deletion (Apple requirement). Do NOT emit AuthLoading outside startup.
Secrets via --dart-define only. Repeat the DataSource swap for the main feature.
