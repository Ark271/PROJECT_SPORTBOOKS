import "package:sports_books/core/result.dart";
import "package:sports_books/core/error/failures.dart";

abstract class UseCase<T, P> {
  Future<Result<T, Failure>> call(P params);
}

class NoParams {
  const NoParams();
}

