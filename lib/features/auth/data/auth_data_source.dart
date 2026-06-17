import 'package:flutter_boilerplate/features/auth/data/dto/user_dto.dart';

/// Low-level auth operations. Throws `AppException`s on failure; the repository
/// converts those to `Failure`s. Implement this to back auth with a real
/// provider (Firebase, Supabase, your own API).
abstract interface class AuthDataSource {
  Future<UserDto> signIn({required String email, required String password});
  Future<void> signOut();

  /// The currently persisted user, or `null` if signed out.
  Future<UserDto?> currentUser();
}
