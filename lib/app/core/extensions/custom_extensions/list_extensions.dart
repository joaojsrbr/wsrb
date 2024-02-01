extension ListExtensions<E, Id> on List<E> {
  bool get isNull {
    for (final element in this) {
      if (element == null) return true;
    }
    return false;
  }

  List<E> reverse(bool reverse) {
    return reverse ? reversed.toList() : this;
  }
}
