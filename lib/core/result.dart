// lib/core/result.dart
// Result<T, E> với Ok/Err + match()

typedef OkFn<T> = void Function(T value);
typedef ErrFn<E> = void Function(E failure);

sealed class Result<T, E> {
  const Result();

  R when<R>({required R Function(T) ok, required R Function(E) err}) {
    final self = this;
    if (self is Ok<T, E>) return ok(self.value);
    if (self is Err<T, E>) return err(self.failure);
    throw StateError('Invalid Result state');
  }

  void match({required OkFn<T> ok, required ErrFn<E> err}) {
    final self = this;
    if (self is Ok<T, E>) {
      ok(self.value);
    } else if (self is Err<T, E>) {
      err((self as Err<T, E>).failure);
    }
  }

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E failure;
  const Err(this.failure);
}
