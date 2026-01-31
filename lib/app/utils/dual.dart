class Dual<A extends Object, B extends Object> {
  final A first;
  final B second;

  const Dual(this.first, this.second);

  /// Retorna um dos dois valores baseado em [useFirst].
  Object getValue(bool useFirst) => useFirst ? first : second;

  /// Retorna A se for verdadeiro, B se for falso, com tipo inferido corretamente.
  T pick<T extends Object>(bool useFirst) {
    return (useFirst ? first : second) as T;
  }

  /// Cria uma cópia invertendo a ordem.
  Dual<B, A> swapped() => Dual(second, first);
}
