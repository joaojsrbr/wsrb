import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LibraryController extends ChangeNotifier {
  final IsarServiceImpl _isarService;

  LibraryController(this._isarService);

  final List<Entity> _entities = [];

  Future<void> start() async {
    final animeColetions =
        await _isarService.collection<AnimeEntity>().where().findAll();
    final bookColetions =
        await _isarService.collection<BookEntity>().where().findAll();

    _entities.addAll(animeColetions);
    _entities.addAll(bookColetions);
  }

  UnmodifiableListView<Entity> get entities => UnmodifiableListView(_entities);
  UnmodifiableListView<String> get ids => UnmodifiableListView(_entities
      .map((e) => switch (e) {
            AnimeEntity data => data.stringID,
            BookEntity data => data.stringID,
            EpisodeEntity data => data.stringID,
            ChapterEntity data => data.stringID,
            _ => null,
          })
      .nonNulls);

  Stream<dynamic> collectionChanged<T>() =>
      _isarService.collection<T>().watchLazy();

  bool contains({Entity? entity, Content? content}) {
    bool result = false;
    if (content != null) {
      assert(entity == null);
      result = switch (content) {
        Anime data => ids.contains(data.id),
        Book data => ids.contains(data.id),
        _ => false,
      };
    } else if (entity != null) {
      assert(content == null);
      result = switch (entity) {
        AnimeEntity data => ids.contains(data.stringID),
        BookEntity data => ids.contains(data.stringID),
        EpisodeEntity data => ids.contains(data.stringID),
        ChapterEntity data => ids.contains(data.stringID),
        _ => false,
      };
    }
    return result;
  }

  UnmodifiableListView<T> getByTypeEntities<T extends Entity>() {
    return UnmodifiableListView(entities.whereType<T>());
  }

  Future<Result<(bool, List<int>?)>> add({
    Entity? entity,
    Entity? releaseEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    if (releaseEntity != null) {
      _setDateTime(releaseEntity);
    }
    if (entity != null) {
      _setDateTime(entity);
    }

    final result1 = await _isarService.add(entity: entity);
    final result2 = await _isarService.add(entity: releaseEntity);

    [result2, result1]
        .map((e) => e.when(onSucess: (data) => data))
        .nonNulls
        .forEach((element) {
      if (element.$2 != null) ids.add(element.$2!);
      if (element.$1) isSucess = element.$1;
    });

    if (entity != null) {
      _addOrUpdate(entity);
    }
    if (releaseEntity != null) {
      _addOrUpdate(releaseEntity);
    }

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  void _setDateTime(Entity entity) {
    switch (entity) {
      case AnimeEntity _:
        if (ids.contains(entity.stringID)) {
          entity.updatedAt = DateTime.now();
          break;
        }
        entity.createdAt = DateTime.now();
        break;
      case BookEntity _:
        if (ids.contains(entity.stringID)) {
          entity.updatedAt = DateTime.now();
          break;
        }
        entity.createdAt = DateTime.now();
        break;

      case EpisodeEntity _:
        if (ids.contains(entity.stringID)) {
          entity.updatedAt = DateTime.now();
          break;
        }
        entity.createdAt = DateTime.now();
        break;
      case ChapterEntity _:
        if (ids.contains(entity.stringID)) {
          entity.updatedAt = DateTime.now();
          break;
        }
        entity.createdAt = DateTime.now();
        break;
    }
  }

  String getStringID(Entity entity) {
    return switch (entity) {
      AnimeEntity data => data.stringID.trim(),
      BookEntity data => data.stringID.trim(),
      EpisodeEntity data => data.stringID.trim(),
      ChapterEntity data => data.stringID.trim(),
      _ => '',
    };
  }

  void _addOrUpdate(Entity entity) {
    final indexOf = _entities.indexWhere((element) => switch (element) {
          AnimeEntity data when entity is AnimeEntity =>
            data.stringID.contains(entity.stringID),
          BookEntity data when entity is BookEntity =>
            data.stringID.contains(entity.stringID),
          EpisodeEntity data when entity is EpisodeEntity =>
            data.stringID.contains(entity.stringID),
          ChapterEntity data when entity is ChapterEntity =>
            data.stringID.contains(entity.stringID),
          _ => false,
        });

    if (indexOf != -1) {
      _entities[indexOf] = entity;
    } else {
      _entities.add(entity);
    }
  }

  Future<Result<(bool, List<int>?)>> addAll({
    List<Entity>? entities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    entities?.nonNulls.cast<Entity>().forEach((element) {
      _setDateTime(element);
      _addOrUpdate(element);
      // customLog(element);
    });

    final result1 = await _isarService.addAll(entities: entities);

    [result1]
        .map((e) => e.when(onSucess: (data) => data))
        .nonNulls
        .forEach((element) {
      if (element.$2 != null) ids.addAll(element.$2!);
      if (element.$1) isSucess = element.$1;
    });

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> removeAll({
    List<Entity>? entities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    entities?.nonNulls.cast<Entity>().forEach((element) {
      _entities.removeWhere((remove) => remove.id == element.id);
      // customLog(element);
    });

    final result1 = await _isarService.removeAll(
      entities: entities?.cast(),
    );

    [result1]
        .map((e) => e.when(onSucess: (data) => data))
        .nonNulls
        .forEach((element) {
      if (element.$2 != null) ids.addAll(element.$2!);
      if (element.$1) isSucess = element.$1;
    });

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> remove({
    Entity? entity,
    Entity? releaseEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result1 = await _isarService.remove(entity: entity);
    final result2 = await _isarService.remove(entity: releaseEntity);

    [result2, result1]
        .map((e) => e.when(onSucess: (data) => data))
        .nonNulls
        .forEach((element) {
      if (element.$2 != null) ids.add(element.$2!);
      if (element.$1) isSucess = element.$1;
    });

    _entities.removeWhere((element) {
      if (element is EpisodeEntity && releaseEntity is EpisodeEntity) {
        return element.stringID == releaseEntity.stringID;
      } else if (element is ChapterEntity && releaseEntity is ChapterEntity) {
        return element.stringID == releaseEntity.stringID;
      } else if (element is AnimeEntity && releaseEntity is AnimeEntity) {
        return element.stringID == releaseEntity.stringID;
      } else if (element is BookEntity && releaseEntity is BookEntity) {
        return element.stringID == releaseEntity.stringID;
      }
      return false;
    });

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  List<Entity> noCategories(CategoryController categoryController) {
    return entities
        .where((element) => switch (element) {
              AnimeEntity data => !categoryController.categories
                  .any((element) => element.ids.contains(data.stringID)),
              BookEntity data => !categoryController.categories
                  .any((element) => element.ids.contains(data.stringID)),
              _ => false
            })
        .toList();
  }
}
