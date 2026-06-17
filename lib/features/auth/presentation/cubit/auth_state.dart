import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/features/auth/domain/user.dart';

/// Global session state that the router listens to.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before the session has been resolved.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// While restoring/changing the session.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);
  final AppUser user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}
