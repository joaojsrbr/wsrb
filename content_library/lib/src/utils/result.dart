/// Representa um resultado vazio.
final class Empty<T extends Object> extends Result<T> {
  const Empty();
}

/// Representa um resultado bem-sucedido com dados.
final class Success<T extends Object> extends Result<T> {
  final T data;
  final String? description;
  const Success(this.data, {this.description});
}

/// Representa uma falha com um erro específico.
final class Failure<T extends Object> extends Result<T> {
  final Exception error;
  const Failure(this.error);
}

/// Representa um resultado cancelado.
final class Cancel<T extends Object> extends Result<T> {
  const Cancel();
}

/// Uma classe selada que representa um resultado que pode ser de vários tipos.
sealed class Result<T extends Object> {
  /// Construtor da classe Result.
  const Result();

  /// Cria uma instância de `Success` com os dados fornecidos.
  const factory Result.success(T data, {String? description}) = Success<T>;

  /// Cria uma instância de `Failure` com o erro fornecido.
  const factory Result.failure(Exception error) = Failure<T>;

  /// Cria uma instância de `Empty`.
  const factory Result.empty() = Empty<T>;

  /// Cria uma instância de `Cancel`.
  const factory Result.cancel() = Cancel<T>;

  /// Dobra o resultado em um único valor com base em seu tipo.
  ///
  /// Retorna um valor do tipo `S` com base nas funções fornecidas para cada tipo de resultado.
  /// - `onSuccess`: Função chamada quando o resultado é `Success`.
  /// - `onError`: Função chamada quando o resultado é `Failure`.
  /// - `onCancel`: Função chamada quando o resultado é `Cancel`.
  /// - `onEmpty`: Função chamada quando o resultado é `Empty`.
  /// - `map`: Mapa de funções para tipos específicos.
  ///
  /// Retorna `null` se nenhuma função correspondente for fornecida.
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
