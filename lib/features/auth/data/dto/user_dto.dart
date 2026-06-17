import 'package:flutter_boilerplate/features/auth/domain/user.dart';

/// Wire/storage representation of a user. Hand-written (no codegen).
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
      );

  final String id;
  final String email;
  final String? displayName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };

  AppUser toEntity() =>
      AppUser(id: id, email: email, displayName: displayName);
}
