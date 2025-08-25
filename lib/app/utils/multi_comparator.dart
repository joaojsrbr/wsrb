/// Combina vários comparadores em um único
Comparator<T> multiComparator<T>(Set<Comparator<T>> comparators) {
  return (a, b) {
    for (final comparator in comparators) {
      final result = comparator(a, b);
      if (result != 0) return result;
    }
    return 0;
  };
}
