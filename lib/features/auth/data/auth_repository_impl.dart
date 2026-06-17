import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/features/auth/data/auth_data_source.dart';
import 'package:flutter_boilerplate/features/auth/domain/auth_repository.dart';
import 'package:flutter_boilerplate/features/auth/domain/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<Result<AppUser?>> restoreSession() =>
      guardAsync(() async => (await _dataSource.currentUser())?.toEntity());

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) =>
      guardAsync(() async {
        final dto = await _dataSource.signIn(email: email, password: password);
        return dto.toEntity();
      });

  @override
  Future<Result<void>> signOut() => guardAsync(_dataSource.signOut);
}
