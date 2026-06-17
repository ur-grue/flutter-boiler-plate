/// Abstraction over non-sensitive key/value persistence.
///
/// Backed by `shared_preferences` in production; trivially fakeable in tests.
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);

  bool? getBool(String key);
  Future<void> setBool(String key, {required bool value});

  int? getInt(String key);
  Future<void> setInt(String key, int value);

  Future<void> remove(String key);
  Future<void> clear();
}
