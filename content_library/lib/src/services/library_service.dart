import 'package:content_library/content_library.dart';

class LibraryService {
  final LibraryController _libraryController;
  final HiveController _hiveController;
  const LibraryService(this._libraryController, this._hiveController);

  UnmodifiableListView<ContentEntity> get entities =>
      _libraryController.entities;

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
                  (episode.videoPercent > _hiveController.historicSavePercent)),
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
          .where((episode) =>
              !episode.isComplete &&
              (episode.videoPercent > _hiveController.historicSavePercent))
          .toList(),
      BookEntity data => data.chapters
          .where((episode) =>
              !episode.isComplete &&
              (episode.readPercent > _hiveController.historicSavePercent))
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

  List<Entity> byCategories(
    CategoryController categoryController, [
    bool noCategory = false,
  ]) {
    return _libraryController.entities
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

  ContentEntity? getContentEntityByStringID(String animeStringID) {
    return entities.firstWhereOrNull((content) => switch (content) {
          AnimeEntity data => data.stringID.contains(animeStringID) ||
              data.animeID?.contains(animeStringID) == true,
          BookEntity data => data.stringID.contains(animeStringID),
          _ => false,
        });
  }

  bool contains({ContentEntity? contentEntity, Content? content}) {
    bool result = false;
    if (content != null) {
      assert(contentEntity == null);
      result = switch (content) {
        Anime data => favoritesIDS.contains(data.stringID),
        Book data => favoritesIDS.contains(data.stringID),
        _ => false,
      };
    } else if (contentEntity != null) {
      assert(content == null);
      result = switch (contentEntity) {
        EpisodeEntity data => favoritesIDS.contains(data.stringID),
        ChapterEntity data => favoritesIDS.contains(data.stringID),
        _ => false,
      };
    }
    return result;
  }

  String? _map(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.stringID,
      BookEntity data => data.stringID,
      _ => null,
    };
  }
}
