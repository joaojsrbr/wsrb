import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/in_repository.dart';

class InLibraryRepository extends InRepository<ContentEntity> {
  // ignore: unused_field
  final AppConfigController _appConfigController;

  InLibraryRepository(this._appConfigController);

  UnmodifiableListView<String> get allDownIds =>
      UnmodifiableListView(entities.map(_map2).nonNulls);

  UnmodifiableListView<String> get favoritesIDS => UnmodifiableListView(
    entities
        .where(
          (entity) => switch (entity) {
            AnimeEntity data => data.isFavorite,
            BookEntity data => data.isFavorite,
            _ => false,
          },
        )
        .map(_map)
        .nonNulls,
  );

  UnmodifiableListView<ContentEntity> get completed => UnmodifiableListView(
    entities
        .where(
          (entity) => switch (entity) {
            AnimeEntity data => data.episodes.any(
              (episode) => episode.isComplete,
            ),
            BookEntity data => data.chapters.any(
              (episode) => episode.isComplete,
            ),
            _ => false,
          },
        )
        .nonNulls,
  );

  UnmodifiableListView<ContentEntity> get notCompleted => UnmodifiableListView(
    entities
        .where(
          (entity) => switch (entity) {
            AnimeEntity data => data.episodes.any(
              (episode) => !episode.isComplete,

              // &&
              // (episode.percent >
              //     _appConfigController.repo.config.historicSavePercent)
            ),
            BookEntity data => data.chapters.any(
              (chapter) => !chapter.isComplete,
              // &&
              // (chapter.readPercent > _hiveController.historicSavePercent)
            ),
            _ => false,
          },
        )
        .nonNulls,
  );

  List<HistoricEntity> getIsarLinks(ContentEntity element) {
    return switch (element) {
      AnimeEntity data =>
        data.episodes
            .where((episode) => !episode.isComplete && episode.percent > 0.0)
            .toList(),
      BookEntity data =>
        data.chapters
            .where((episode) => !episode.isComplete && episode.percent > 0.0)
            .toList(),
      _ => [],
    };
  }

  Iterable<HistoricEntity>? getAll(ContentEntity element) {
    return switch (element) {
      AnimeEntity data =>
        data.episodes
            .where((episode) => !episode.isComplete && episode.percent > 0.0)
            .toList(),
      BookEntity data =>
        data.chapters
            .where((episode) => !episode.isComplete && episode.percent > 0.0)
            .toList(),
      _ => null,
    };
  }

  UnmodifiableListView<ContentEntity> get noFavorites => UnmodifiableListView(
    entities.where((entity) => !entity.isFavorite).nonNulls,
  );

  UnmodifiableListView<ContentEntity> get favorites => UnmodifiableListView(
    entities.where((entity) => entity.isFavorite).nonNulls,
  );

  UnmodifiableListView<String> get noFavoritesIDS => UnmodifiableListView(
    entities.where((entity) => !entity.isFavorite).map(_map).nonNulls,
  );

  CategoryEntity? getContentByStringId(
    CategoryController categoryController,
    Content? content,
  ) {
    return switch (content) {
      AnimeEntity data => categoryController.categories.firstWhereOrNull(
        (category) => category.ids.contains(data.stringID),
      ),
      BookEntity data => categoryController.categories.firstWhereOrNull(
        (category) => category.ids.contains(data.stringID),
      ),
      _ => null,
    };
  }

  List<Entity> byCategories(
    CategoryController categoryController, [
    bool noCategory = false,
  ]) {
    return entities
        .where(
          (content) => switch (content) {
            AnimeEntity data
                when favoritesIDS.contains(data.stringID) && noCategory =>
              !categoryController.categories.any(
                (element) => element.ids.contains(data.stringID),
              ),
            BookEntity data
                when favoritesIDS.contains(data.stringID) && noCategory =>
              !categoryController.categories.any(
                (element) => element.ids.contains(data.stringID),
              ),
            AnimeEntity data
                when favoritesIDS.contains(data.stringID) && !noCategory =>
              categoryController.categories.any(
                (element) => element.ids.contains(data.stringID),
              ),
            BookEntity data
                when favoritesIDS.contains(data.stringID) && !noCategory =>
              categoryController.categories.any(
                (element) => element.ids.contains(data.stringID),
              ),
            _ => false,
          },
        )
        .toList();
  }

  String? getStringID(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.stringID,
      BookEntity data => data.stringID,
      _ => null,
    };
  }

  T? getContentEntityByStringID<T extends ContentEntity>(
    String animeStringID, {
    T Function()? orElse,
  }) {
    return (entities.firstWhereOrNull(
              (content) => _byStringID(content, animeStringID),
            ) ??
            orElse?.call())
        as T?;
  }

  bool _byStringID(ContentEntity content, String animeStringID) {
    return switch (content) {
      AnimeEntity data =>
        data.stringID.contains(animeStringID) ||
            data.animeID?.contains(animeStringID) == true,
      BookEntity data => data.stringID.contains(animeStringID),
      _ => false,
    };
  }

  ContentEntity? getContentEntityByStringIDAll(
    String animeStringID, {
    ContentEntity? Function()? orElse,
  }) {
    final first = entities.firstWhereOrNull(
      (content) => _byStringID(content, animeStringID),
    );

    return first ?? orElse?.call();
  }

  bool containsFav({ContentEntity? contentEntity, Content? content}) {
    return favoritesIDS.contains(
      contentEntity?.stringID ?? content?.stringID ?? "",
    );
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
