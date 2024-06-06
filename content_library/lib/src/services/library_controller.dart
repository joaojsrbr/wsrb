import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LibraryController extends ChangeNotifier {
  final IsarServiceImpl _isarService;

  LibraryController(this._isarService);

  final List<ContentEntity> _entities = [];

  Future<void> start() async {
    final animeColetions =
        await _isarService.collection<AnimeEntity>().where().findAll();
    final bookColetions =
        await _isarService.collection<BookEntity>().where().findAll();

    _entities.addAll(animeColetions);
    _entities.addAll(bookColetions);
  }

  UnmodifiableListView<ContentEntity> get entities =>
      UnmodifiableListView(_entities);

  UnmodifiableListView<String> get favoritesIDS =>
      UnmodifiableListView(_entities
          .where((entity) => switch (entity) {
                AnimeEntity data => data.isFavorite,
                BookEntity data => data.isFavorite,
                _ => false,
              })
          .map(_map)
          .nonNulls);

  UnmodifiableListView<String> get noFavoritesIDS =>
      UnmodifiableListView(_entities
          .where((entity) => switch (entity) {
                AnimeEntity data => !data.isFavorite,
                BookEntity data => !data.isFavorite,
                _ => false,
              })
          .map(_map)
          .nonNulls);

  String? _map(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.stringID,
      BookEntity data => data.stringID,
      _ => null,
    };
  }

  // Stream<dynamic> collectionChanged<T>() =>
  //     _isarService.collection<T>().watchLazy();

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

  // UnmodifiableListView<T> getByTypeEntities<T extends Entity>() {
  //   return UnmodifiableListView(entities.whereType<T>());
  // }

  Future<Result<(bool, List<int>?)>> add({
    ContentEntity? contentEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    if (contentEntity != null) {
      _setDateTime(contentEntity);
    }

    final result = await _isarService.add(entity: contentEntity);

    result.when(onSucess: (data) {
      if (data.$2 != null) ids.add(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    if (contentEntity != null) {
      _addOrUpdate(contentEntity);
    }

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  void _setDateTime(ContentEntity contentEntity) {
    switch (contentEntity) {
      case AnimeEntity data:
        if (contains(contentEntity: data)) {
          data.updatedAt = DateTime.now();
          break;
        }
        data.createdAt = DateTime.now();
        break;
      case BookEntity data:
        if (contains(contentEntity: data)) {
          data.updatedAt = DateTime.now();
          break;
        }
        data.createdAt = DateTime.now();
        break;
    }
  }

  String getStringID(ContentEntity contentEntity) {
    return switch (contentEntity) {
      AnimeEntity data => data.stringID.trim(),
      BookEntity data => data.stringID.trim(),
      _ => '',
    };
  }

  void _addOrUpdate(ContentEntity contentEntity) {
    final indexOf = _entities.indexWhere((element) => switch (element) {
          AnimeEntity data when contentEntity is AnimeEntity =>
            data.stringID.contains(contentEntity.stringID),
          BookEntity data when contentEntity is BookEntity =>
            data.stringID.contains(contentEntity.stringID),
          _ => false,
        });

    if (indexOf != -1) {
      _entities[indexOf] = contentEntity;
    } else {
      _entities.add(contentEntity);
    }
  }

  Future<Result<(bool, List<int>?)>> addAll({
    List<ContentEntity>? contentEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = contentEntities?.nonNulls.cast<ContentEntity>().toList();

    void setDateTimeAndAdd(ContentEntity element) {
      _setDateTime(element);
      _addOrUpdate(element);
    }

    entities?.forEach(setDateTimeAndAdd);

    final result = await _isarService.addAll(entities: entities);

    result.when(onSucess: (data) {
      if (data.$2 != null) ids.addAll(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> removeAll({
    List<ContentEntity>? contentEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = contentEntities?.nonNulls.cast<ContentEntity>().toList();

    // entities.forEach((entity) {
    //   // _entities.removeWhere((remove) => remove.id == element.id);
    // });

    entities?.forEach(_entities.remove);

    final result = await _isarService.removeAll(entities: entities);

    result.when(onSucess: (data) {
      if (data.$2 != null) ids.addAll(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> remove({
    ContentEntity? contentEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result = await _isarService.remove(entity: contentEntity);

    result.when(onSucess: (data) {
      if (data.$2 != null) ids.add(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    _entities.removeWhere((entity) => switch (entity) {
          AnimeEntity data when contentEntity is AnimeEntity =>
            data.stringID.contains(contentEntity.stringID),
          BookEntity data when contentEntity is BookEntity =>
            data.stringID.contains(contentEntity.stringID),
          _ => false,
        });

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  List<Entity> noCategories(CategoryController categoryController) {
    return entities
        .where((element) => switch (element) {
              AnimeEntity data when data.isFavorite => !categoryController
                  .categories
                  .any((element) => element.ids.contains(data.stringID)),
              BookEntity data when data.isFavorite => !categoryController
                  .categories
                  .any((element) => element.ids.contains(data.stringID)),
              _ => false
            })
        .toList();
  }
}
