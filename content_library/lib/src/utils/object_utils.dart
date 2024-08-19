import 'package:content_library/content_library.dart';

mixin MergeClass<T extends Content> {
  T merge(T other) {
    if (identical(runtimeType, other.runtimeType)) {
      switch (this) {
        case Anime data when other is Anime:
          final Map<String, dynamic> map1 = data.toJson();
          final Map<String, dynamic> map2 = other.toJson();

          final merged = mergeMap([map1, map2], acceptNull: true);

          return Anime.fromMap(merged) as T;

        case Book data when other is Anime:
          final Map<String, dynamic> map1 = data.toJson();
          final Map<String, dynamic> map2 = other.toJson();

          final merged = mergeMap([map1, map2], acceptNull: true);

          return Book.fromMap(merged) as T;
        default:
          throw Exception('Precisar ser do mesmo tipo');
      }
    }
    return this as T;
  }
}
mixin MergeClassEntity<T extends ContentEntity> on Entity {
  Map<String, dynamic> toMap();

  T merge(T other) {
    if (identical(runtimeType, other.runtimeType)) {
      switch (this) {
        case AnimeEntity data when other is AnimeEntity:
          final Map<String, dynamic> map1 = data.toMap();
          final Map<String, dynamic> map2 = other.toMap();

          final merged = mergeMap([map1, map2], acceptNull: true);

          final obj = AnimeEntity(
            totalOfEpisodes: merged['totalOfEpisodes'],
            stringID: merged['stringID'],
            url: merged['url'],
            title: merged['title'],
            source: merged['source'],
            animeID: merged['animeID'],
            isDublado: merged['isDublado'],
            slugSerie: merged['slugSerie'],
            sinopse: merged['sinopse'],
            generateID: merged['generateID'],
            isFavorite: merged['isFavorite'],
            originalImage: merged['originalImage'],
            extraLarge: merged['extraLarge'],
            largeImage: merged['largeImage'],
            mediumImage: merged['mediumImage'],
            createdAt: DateTime.tryParse(merged['createdAt'] ?? ''),
            updatedAt: DateTime.tryParse(merged['updatedAt'] ?? ''),
          );

          if (merged['episodes'] != null) {
            obj.episodes = merged['episodes'];
          }

          return obj as T;

        case BookEntity data when other is BookEntity:
          final Map<String, dynamic> map1 = data.toMap();
          final Map<String, dynamic> map2 = other.toMap();

          final merged = mergeMap([map1, map2], acceptNull: true);

          final obj = BookEntity(
            stringID: merged['stringID'],
            url: merged['url'],
            title: merged['title'],
            source: merged['source'],
            sinopse: merged['sinopse'],
            isFavorite: merged['isFavorite'],
            originalImage: merged['originalImage'],
            extraLarge: merged['extraLarge'],
            largeImage: merged['largeImage'],
            alternativeTitle: merged['alternativeTitle'],
            mediumImage: merged['mediumImage'],
            createdAt: DateTime.parse(merged['createdAt']),
            updatedAt: DateTime.parse(merged['updatedAt']),
          );

          if (merged['chapters'] != null) {
            obj.chapters = merged['chapters'];
          }

          return Book.fromMap(merged) as T;
        default:
          throw Exception('Precisar ser do mesmo tipo');
      }
    }
    return this as T;
  }
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
