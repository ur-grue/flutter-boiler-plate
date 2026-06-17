import 'package:flutter_boilerplate/core/storage/secure_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [SecureStore] backed by platform-secure storage.
///
/// Note: on web this falls back to a WebCrypto-based store which is best-effort
/// only — see `docs/SECURITY.md`. Native (iOS/Android) uses Keychain/Keystore.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
