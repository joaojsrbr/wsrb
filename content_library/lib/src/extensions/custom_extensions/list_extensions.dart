import 'package:content_library/content_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension CustomIterable<E, Id> on Iterable<E> {
  Iterable<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? toList() : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }

  List<E> getMax(int max) {
    return max > length
        ? toList().sublist(0, length)
        : toList().sublist(0, max);
  }
}

extension CustomListExtensions<E, Id> on List<E> {
  bool get isNull {
    return contains(null);
  }

  List<E> reverse(bool reverse) {
    return reverse ? reversed.toList() : this;
  }

  List<E> getMax(int max) {
    return max > length ? sublist(0, length) : sublist(0, max);
  }

  void addIfNoContains(E element, [bool Function(E)? test]) {
    final _ = any(test ?? (e) => contains(element));

    if (!_) add(element);
  }

  void addOrUpdateWhere(E element, bool Function(E) test) {
    final int indexOf = indexWhere(test);
    if (indexOf != -1) {
      this[indexOf] = element;
    } else {
      add(element);
    }
  }

  bool updateWhere(E element, bool Function(E) test) {
    final int indexOf = indexWhere(test);
    if (indexOf != -1) {
      this[indexOf] = element;
      return true;
    }
    return false;
  }

  bool containsOneElement(List elements) {
    return elements.any(contains);
  }

  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

extension EntityListExtensions on Iterable<Entity> {
  Iterable<Content> get getContent => map((entity) => switch (entity) {
        AnimeEntity data => data.toAnime(),
        BookEntity data => data.toBook,
        _ => null,
      }).nonNulls;

  Iterable<Entity> get getCotentEntity => map((entity) => switch (entity) {
        AnimeEntity data => data,
        BookEntity data => data,
        _ => null,
      }).nonNulls;

  Iterable<Iterable<Entity>> categoryByID(BuildContext context) {
    return context
        .read<CategoryController>()
        .categories
        .map((category) => where((entity) => switch (entity) {
              AnimeEntity data when data.isFavorite =>
                category.ids.contains(data.stringID),
              BookEntity data when data.isFavorite =>
                category.ids.contains(data.stringID),
              _ => false,
            }));
  }
}

// typedef MapIndexWhere<E>
//     = Map<E, bool Function(Entity element, Entity element1)>;

// extension CustomEntityListExtensions<Id> on List<Entity> {
//   int eIndexWhere<E, T extends Entity>(MapIndexWhere<E> map, T entity) {
//     for (final element in EnumerateIterable(this)) {
//       if (map.containsKey(element.value.runtimeType) &&
//           element.value.runtimeType == entity.runtimeType) {
//         final result = map[element.value.runtimeType]?.call(
//           entity,
//           element.value,
//         );
//         if (result == true) return element.index;
//       }
//     }
//     return -1;
//   }
// }
