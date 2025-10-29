import 'package:sports_books/core/error/failures.dart';
import 'package:sports_books/core/result.dart';
import 'package:sports_books/features/auth/domain/entities/user.dart';
import 'package:sports_books/features/auth/domain/repositories/auth_repository.dart';

import '../datasources/auth_remote_ds.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDs remote;
  final UserMapper mapper;

  const AuthRepositoryImpl({required this.remote, required this.mapper});

  // Nếu AuthRemoteDs dùng GETTER `authState$`
  @override
  Stream<UserEntity?> get authState$ =>
      remote.authState$.map((ru) => ru == null ? null : mapper.fromRemote(ru));

  // Nếu AuthRemoteDs của bạn định nghĩa là METHOD `authState$()`,
  // hãy dùng đoạn này thay cho getter ở trên:
  // @override
  // Stream<UserEntity?> get authState$ =>
  //     remote.authState$().map((ru) => ru == null ? null : mapper.fromRemote(ru));

  @override
  Future<Result<UserEntity, Failure>> register({
    required String email,
    required String password,
  }) async {
    try {
      final ru = await remote.register(email: email, password: password);
      return Ok(mapper.fromRemote(ru));
    } on NetworkFailure catch (e) {
      return Err(e);
    } catch (_) {
      return Err(const UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity, Failure>> signInEmail({
    required String email,
    required String password,
  }) async {
    try {
      final ru = await remote.signInEmail(email: email, password: password);
      return Ok(mapper.fromRemote(ru));
    } on NetworkFailure catch (e) {
      return Err(e);
    } catch (_) {
      return Err(const UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity, Failure>> signInGoogle() async {
    try {
      final ru = await remote.signInGoogle();
      return Ok(mapper.fromRemote(ru));
    } on NetworkFailure catch (e) {
      return Err(e);
    } catch (_) {
      return Err(const UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    try {
      await remote.signOut();
      return Ok(null);
    } on NetworkFailure catch (e) {
      return Err(e);
    } catch (_) {
      return Err(const UnknownFailure());
    }
  }
}
