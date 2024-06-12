final class Empty<T extends Object> extends Result<T> {
  const Empty();
}

final class Success<T extends Object> extends Result<T> {
  final T data;
  final String? description;
  const Success(this.data, {this.description});
}

final class Failure<T extends Object> extends Result<T> {
  final Object error;
  const Failure(this.error);
}

sealed class Result<T extends Object> {
  const Result();
  const factory Result.success(T data, {String? description}) = Success<T>;
  const factory Result.failure(Exception error) = Failure<T>;
  const factory Result.empty() = Empty<T>;

  S? fold<S>({
    S Function(T success)? onSucess,
    S Function(Object error)? onError,
    S Function()? onEmpty,
    Map<Type, S? Function<O>(O data)>? map,
  }) {
    if (map != null) {
      final result = map[runtimeType]?.call(fold(
        onSucess: (success) => success,
        onError: (error) => error,
        onEmpty: () => this,
      ));
      if (result != null) return result;
    }

    return switch (this) {
      Success<T> success => onSucess?.call(success.data),
      Failure<T> failure => onError?.call(failure.error),
      Empty<T> _ => onEmpty?.call(),
    };
  }

  // S? when<S>({
  //   S Function(T data)? onSucess,
  //   S Function(Object error)? onError,
  //   S Function()? onEmpty,
  // }) {
  //   switch (this) {
  //     case Success<T> success:
  //       return onSucess?.call(success.data);
  //     case Failure<T> except:
  //       return onError?.call(except.error);
  //     case Empty<T> _:
  //       return onEmpty?.call();
  //   }
  // }
}
