abstract class Failure {
  final String message;
  const Failure([this.message = ""]);
  @override
  String toString() => "$runtimeType: $message";
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = "Authentication failed"]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "Network error"]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = "Unknown error"]);
}

