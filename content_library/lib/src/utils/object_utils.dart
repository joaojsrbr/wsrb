import '../models/anime.dart';
import '../models/book.dart';
import '../models/content.dart';

mixin MergeClass<T extends Content> on Content {
  T merge(T other) {
    if (identical(runtimeType, other.runtimeType)) {
      switch (this) {
        case Anime data when other is Anime:
          final Map<String, dynamic> map1 = data.map;
          final Map<String, dynamic> map2 = other.map;

          final merged = mergeMap([map1, map2], acceptNull: true);

          return Anime.fromMap(merged) as T;

        case Book data when other is Anime:
          final Map<String, dynamic> map1 = data.map;
          final Map<String, dynamic> map2 = other.map;

          final merged = mergeMap([map1, map2], acceptNull: true);

          return Book.fromMap(merged) as T;
        default:
          throw Exception('Precisar ser do mesmo tipo');
      }
    }
    return this as T;
  }
}

abstract class MapObjectClass<T> {
  Map<String, dynamic> get map;
}

dynamic _copyValues<K, V>(
    Map<K, V> from, Map<K, V?> to, bool recursive, bool acceptNull) {
  for (var key in from.keys) {
    if (from[key] is Map<K, V> && recursive) {
      if (to[key] is! Map<K, V>) {
        to[key] = <K, V>{} as V;
      }
      _copyValues(from[key] as Map, to[key] as Map, recursive, acceptNull);
    } else {
      if (from[key] != null || acceptNull) {
        to[key] = from[key];
      }
    }
  }
}

Map<K, V> mergeMap<K, V>(Iterable<Map<K, V>> maps,
    {bool recursive = true, bool acceptNull = false}) {
  var result = <K, V>{};
  for (var map in maps) {
    _copyValues(map, result, recursive, acceptNull);
  }
  return result;
}
