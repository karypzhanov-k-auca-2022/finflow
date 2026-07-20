import 'failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
