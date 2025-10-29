import "package:sports_books/core/usecase/usecase.dart";
import "package:sports_books/core/result.dart";
import "package:sports_books/core/error/failures.dart";
import "../entities/user.dart";
import "../repositories/auth_repository.dart";

class SignInGoogleUc implements UseCase<UserEntity, NoParams> {
  final AuthRepository repo;
  const SignInGoogleUc(this.repo);

  @override
  Future<Result<UserEntity, Failure>> call(NoParams p) {
    return repo.signInGoogle();
  }
}
