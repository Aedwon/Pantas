sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() => switch (this) {
        Ok<T, E>(:final value) => value,
        Err<T, E>() => throw StateError('unwrap on Err'),
      };

  E unwrapErr() => switch (this) {
        Err<T, E>(:final error) => error,
        Ok<T, E>() => throw StateError('unwrapErr on Ok'),
      };

  Result<U, E> map<U>(U Function(T) f) => switch (this) {
        Ok<T, E>(:final value) => Ok<U, E>(f(value)),
        Err<T, E>(:final error) => Err<U, E>(error),
      };

  Result<T, F> mapErr<F>(F Function(E) f) => switch (this) {
        Ok<T, E>(:final value) => Ok<T, F>(value),
        Err<T, E>(:final error) => Err<T, F>(f(error)),
      };
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
