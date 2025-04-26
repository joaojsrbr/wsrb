import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/in_repository.dart';

class InLibraryRepository extends InRepository<ContentEntity> {
  final HiveController _hiveController;

  InLibraryRepository(this._hiveController);

  UnmodifiableListView<String> get allDownIds =>
      UnmodifiableListView(entities.map(_map2).nonNulls);

  UnmodifiableListView<String> get favoritesIDS => UnmodifiableListView(entities
      .where((entity) => switch (entity) {
            AnimeEntity data => data.isFavorite,
            BookEntity data => data.isFavorite,
            _ => false,
          })
      .map(_map)
      .nonNulls);

  UnmodifiableListView<ContentEntity> get completed =>
      UnmodifiableListView(entities
          .where(
            (entity) => switch (entity) {
              AnimeEntity data =>
                data.episodes.any((episode) => episode.isComplete),
              BookEntity data =>
                data.chapters.any((episode) => episode.isComplete),
              _ => false,
            },
          )
          .nonNulls);

  UnmodifiableListView<ContentEntity> get notCompleted =>
      UnmodifiableListView(entities
          .where(
            (entity) => switch (entity) {
              AnimeEntity data => data.episodes.any((episode) =>
                  !episode.isComplete &&
                  (episode.percent > _hiveController.historicSavePercent)),
              BookEntity data => data.chapters.any((chapter) =>
                  !chapter.isComplete &&
                  (chapter.readPercent > _hiveController.historicSavePercent)),
              _ => false,
            },
          )
          .nonNulls);

  Iterable<HistoryEntity>? getIsarLinks(ContentEntity element) {
    return switch (element) {
      AnimeEntity data => data.episodes
          .where((episode) => !episode.isComplete && episode.percent > 0.0)
          .toList(),
      BookEntity data => data.chapters
          .where((episode) => !episode.isComplete && episode.percent > 0.0)
          .toList(),
      _ => null
    };
  }

  UnmodifiableListView<ContentEntity> get noFavorites =>
      UnmodifiableListView(entities
          .where((entity) => switch (entity) {
                AnimeEntity data => !data.isFavorite,
                BookEntity data => !data.isFavorite,
                _ => false,
              })
          .nonNulls);

  UnmodifiableListView<ContentEntity> get favorites =>
      UnmodifiableListView(entities
          .where((entity) => switch (entity) {
                AnimeEntity data => data.isFavorite,
                BookEntity data => data.isFavorite,
                _ => false,
              })
          .nonNulls);

  UnmodifiableListView<String> get noFavoritesIDS =>
      UnmodifiableListView(entities
          .where((entity) => switch (entity) {
                AnimeEntity data => !data.isFavorite,
                BookEntity data => !data.isFavorite,
                _ => false,
              })
          .map(_map)
          .nonNulls);

  CategoryEntity? getContentByStringId(
    CategoryController categoryController,
    Content? content,
  ) {
    return switch (content) {
      AnimeEntity data => categoryController.categories
          .firstWhereOrNull((category) => category.ids.contains(data.stringID)),
      BookEntity data => categoryController.categories
          .firstWhereOrNull((category) => category.ids.contains(data.stringID)),
      _ => null,
    };
  }

  List<Entity> byCategories(
    CategoryController categoryController, [
    bool noCategory = false,
  ]) {
    return entities
        .where((content) => switch (content) {
              AnimeEntity data
                  when favoritesIDS.contains(data.stringID) && noCategory =>
                !categoryController.categories
                    .any((element) => element.ids.contains(data.stringID)),
              BookEntity data
                  when favoritesIDS.contains(data.stringID) && noCategory =>
                !categoryController.categories
                    .any((element) => element.ids.contains(data.stringID)),
              AnimeEntity data
                  when favoritesIDS.contains(data.stringID) && !noCategory =>
                categoryController.categories
                    .any((element) => element.ids.contains(data.stringID)),
              BookEntity data
                  when favoritesIDS.contains(data.stringID) && !noCategory =>
                categoryController.categories
                    .any((element) => element.ids.contains(data.stringID)),
              _ => false
            })
        .toList();
  }

  String? getStringID(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.stringID,
      BookEntity data => data.stringID,
      _ => null,
    };
  }

  T getContentEntityByStringID<T extends ContentEntity>(
    String animeStringID, {
    T Function()? orElse,
  }) {
    if (orElse != null) {
      return entities.firstWhere(
        (content) => _byStringID(content, animeStringID),
        orElse: orElse,
      ) as T;
    }
    return entities.firstWhereOrNull(
      (content) => _byStringID(content, animeStringID),
    ) as T;
  }

  bool _byStringID(ContentEntity content, String animeStringID) {
    return switch (content) {
      AnimeEntity data => data.stringID.contains(animeStringID) ||
          data.animeID?.contains(animeStringID) == true,
      BookEntity data => data.stringID.contains(animeStringID),
      _ => false,
    };
  }

  Future<ContentEntity?> getContentEntityByStringIDAll(
      String animeStringID) async {
    final first = entities.firstWhereOrNull(
      (content) => _byStringID(content, animeStringID),
    );
    // switch (first) {
    //   case AnimeEntity data:
    //     await data.episodes.load();
    //   case BookEntity data:
    //     await data.chapters.load();
    // }

    return first;
  }

  bool contains({ContentEntity? contentEntity, Content? content}) {
    if (content != null) {
      assert(contentEntity == null);
      return switch (content) {
        Anime data => favoritesIDS.contains(data.stringID),
        Book data => favoritesIDS.contains(data.stringID),
        _ => false,
      };
    } else if (contentEntity != null) {
      assert(content == null);
      return switch (contentEntity) {
        EpisodeEntity data => favoritesIDS.contains(data.stringID),
        ChapterEntity data => favoritesIDS.contains(data.stringID),
        _ => false,
      };
    }
    return false;
  }

  String? _map(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.stringID,
      BookEntity data => data.stringID,
      _ => null,
    };
  }

  String? _map2(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.title.toID,
      BookEntity data => data.title.toID,
      _ => null,
    };
  }
}
