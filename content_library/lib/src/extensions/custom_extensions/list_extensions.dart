import 'package:content_library/content_library.dart';
import 'package:quiver/iterables.dart';

extension CustomListExtensions<E, Id> on List<E> {
  bool get isNull {
    for (final element in this) {
      if (element == null) return true;
    }
    return false;
  }

  List<E> reverse(bool reverse) {
    return reverse ? reversed.toList() : this;
  }

  void addIfNoContains(E element) {
    if (!contains(element)) add(element);
  }

  bool containsOneElement(List elements) {
    for (final element in elements) {
      if (contains(element)) return true;
    }

    return false;
  }

  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

typedef MapIndexWhere<E>
    = Map<E, bool Function(Entity element, Entity element1)>;

extension CustomEntityListExtensions<Id> on List<Entity> {
  int eIndexWhere<E, T extends Entity>(MapIndexWhere<E> map, T entity) {
    for (final element in EnumerateIterable(this)) {
      if (map.containsKey(element.value.runtimeType) &&
          element.value.runtimeType == entity.runtimeType) {
        final result = map[element.value.runtimeType]?.call(
          entity,
          element.value,
        );
        if (result == true) return element.index;
      }
    }
    return -1;
  }
}
