import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/auth/domain/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/presentation/cubit/auth_state.dart';

/// Owns the global session. Always resolves to [Authenticated] or
/// [Unauthenticated] (never gets stuck on [AuthInitial]/[AuthLoading]), which
/// keeps the router's redirect guard loop-free.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  /// Restores any persisted session on startup.
  Future<void> bootstrap() async {
    emit(const AuthLoading());
    final result = await _repository.restoreSession();
    emit(
      result.fold(
        (user) => user == null ? const Unauthenticated() : Authenticated(user),
        (_) => const Unauthenticated(),
      ),
    );
  }

  /// Signs in; on failure returns the message and stays unauthenticated.
  ///
  /// Deliberately does NOT emit [AuthLoading] (that state routes to splash).
  /// The sign-in page shows its own submission spinner.
  Future<String?> signIn(String email, String password) async {
    final result = await _repository.signIn(email: email, password: password);
    return result.fold(
      (user) {
        emit(Authenticated(user));
        return null;
      },
      (failure) {
        emit(const Unauthenticated());
        return failure.message;
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const Unauthenticated());
  }
}
