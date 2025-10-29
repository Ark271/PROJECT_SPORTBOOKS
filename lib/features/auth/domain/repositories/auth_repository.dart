// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:sports_books/core/result.dart';
import 'package:sports_books/core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authState$;

  Future<Result<UserEntity, Failure>> register({
    required String email,
    required String password,
  });

  Future<Result<UserEntity, Failure>> signInEmail({
    required String email,
    required String password,
  });

  Future<Result<UserEntity, Failure>> signInGoogle();

  Future<Result<void, Failure>> signOut();
}
