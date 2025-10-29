import 'package:sports_books/core/result.dart';
import 'package:sports_books/core/error/failures.dart';
import 'package:sports_books/core/usecase/usecase.dart';
import 'package:sports_books/features/auth/domain/entities/user.dart';
import 'package:sports_books/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  const RegisterParams(this.email, this.password);
}

class RegisterUc implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository _repo;
  const RegisterUc(this._repo);

  @override
  Future<Result<UserEntity, Failure>> call(RegisterParams p) {
    return _repo.register(email: p.email, password: p.password);
  }
}

