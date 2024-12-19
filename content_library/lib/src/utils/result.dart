final class Empty<T extends Object> extends Result<T> {
  const Empty();
}

final class Success<T extends Object> extends Result<T> {
  final T data;
  final String? description;
  const Success(this.data, {this.description});
}

final class Failure<T extends Object> extends Result<T> {
  final Exception error;
  const Failure(this.error);
}

final class Cancel<T extends Object> extends Result<T> {
  const Cancel();
}

sealed class Result<T extends Object> {
  const Result();
  const factory Result.success(T data, {String? description}) = Success<T>;
  const factory Result.failure(Exception error) = Failure<T>;
  const factory Result.empty() = Empty<T>;
  const factory Result.cancel() = Cancel<T>;

  S? fold<S>({
    S Function(T success)? onSuccess,
    S Function(Object error)? onError,
    S Function()? onCancel,
    S Function()? onEmpty,
    Map<Type, S? Function<O>(O data)>? map,
  }) {
    if (map != null) {
      final result = map[runtimeType]?.call(fold(
        onSuccess: (success) => success,
        onError: (error) => error,
        onCancel: () => this,
        onEmpty: () => this,
      ));
      if (result != null) return result;
    }

    return switch (this) {
      Cancel<T> _ => onCancel?.call(),
      Success<T> success => onSuccess?.call(success.data),
      Failure<T> failure => onError?.call(failure.error),
      Empty<T> _ => onEmpty?.call(),
    };
  }
}
