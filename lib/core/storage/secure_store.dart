/// Abstraction over sensitive storage (auth tokens, etc.).
///
/// Backed by the platform Keychain/Keystore via `flutter_secure_storage`.
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}
