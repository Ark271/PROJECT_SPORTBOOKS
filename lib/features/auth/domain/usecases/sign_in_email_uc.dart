import 'package:sports_books/core/result.dart';
import 'package:sports_books/core/error/failures.dart';
import 'package:sports_books/core/usecase/usecase.dart';
import 'package:sports_books/features/auth/domain/entities/user.dart';
import 'package:sports_books/features/auth/domain/repositories/auth_repository.dart';

class SignInEmailParams {
  final String email;
  final String password;
  const SignInEmailParams(this.email, this.password);
}

class SignInEmailUc implements UseCase<UserEntity, SignInEmailParams> {
  final AuthRepository _repo;
  const SignInEmailUc(this._repo);

  @override
  Future<Result<UserEntity, Failure>> call(SignInEmailParams p) {
    return _repo.signInEmail(email: p.email, password: p.password);
  }
}
