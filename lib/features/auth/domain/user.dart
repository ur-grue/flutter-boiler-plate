import 'package:equatable/equatable.dart';

/// Authenticated user entity (domain layer; no serialization concerns here).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
