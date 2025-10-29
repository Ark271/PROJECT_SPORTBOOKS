import 'package:sports_books/core/result.dart';
import 'package:sports_books/core/error/failures.dart';
import 'package:sports_books/core/usecase/usecase.dart';
import 'package:sports_books/features/auth/domain/repositories/auth_repository.dart';

class SignOutUc implements UseCase<void, NoParams> {
  final AuthRepository _repo;
  const SignOutUc(this._repo);

  @override
  Future<Result<void, Failure>> call(NoParams p) => _repo.signOut();
}
