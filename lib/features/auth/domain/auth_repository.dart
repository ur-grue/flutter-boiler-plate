import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/features/auth/domain/user.dart';

/// Auth contract. Swap the implementation (mock → Firebase/Supabase) without
/// touching cubits, router, or UI.
abstract interface class AuthRepository {
  /// Restores any persisted session. Returns the user, or `null` if none.
  Future<Result<AppUser?>> restoreSession();

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();
}
