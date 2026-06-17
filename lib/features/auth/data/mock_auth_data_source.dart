import 'dart:convert';

import 'package:flutter_boilerplate/core/error/exceptions.dart';
import 'package:flutter_boilerplate/core/storage/secure_store.dart';
import 'package:flutter_boilerplate/core/storage/storage_keys.dart';
import 'package:flutter_boilerplate/core/utils/validators.dart';
import 'package:flutter_boilerplate/features/auth/data/auth_data_source.dart';
import 'package:flutter_boilerplate/features/auth/data/dto/user_dto.dart';

/// Default auth: accepts any valid email/password, fabricates a token, and
/// persists the session to secure storage. Replace with a real data source to
/// go live — the rest of the app is unaffected.
class MockAuthDataSource implements AuthDataSource {
  MockAuthDataSource(this._secureStore);

  final SecureStore _secureStore;

  @override
  Future<UserDto> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (Validators.email(email) != null) {
      throw const AuthException('Enter a valid email address.');
    }
    if (Validators.password(password) != null) {
      throw const AuthException('Password must be at least 6 characters.');
    }

    final user = UserDto(
      id: 'mock-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
    await _secureStore.write(StorageKeys.authToken, 'mock-token-${user.id}');
    await _secureStore.write(StorageKeys.authUserId, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> signOut() async {
    await _secureStore.delete(StorageKeys.authToken);
    await _secureStore.delete(StorageKeys.authUserId);
  }

  @override
  Future<UserDto?> currentUser() async {
    final token = await _secureStore.read(StorageKeys.authToken);
    final raw = await _secureStore.read(StorageKeys.authUserId);
    if (token == null || raw == null) return null;
    return UserDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
