import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LibraryController extends ChangeNotifier {
  final IsarServiceImpl _isarService;
  late final LibraryService _libraryService;
  LibraryController(this._isarService) {
    _libraryService = LibraryService(this);
  }

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

  Future<Result<(bool, List<int>?)>> add({
    ContentEntity? contentEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    if (contentEntity != null) {
      _setDateTime(contentEntity);
    }

    final result = await _isarService.add(entity: contentEntity);

    result.fold(onSuccess: (data) {
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
        if (_libraryService.contains(contentEntity: data)) {
          data.updatedAt = DateTime.now();
          break;
        }
        data.createdAt = DateTime.now();
        break;
      case BookEntity data:
        if (_libraryService.contains(contentEntity: data)) {
          data.updatedAt = DateTime.now();
          break;
        }
        data.createdAt = DateTime.now();
        break;
    }
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

    result.fold(onSuccess: (data) {
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

    result.fold(onSuccess: (data) {
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

    result.fold(onSuccess: (data) {
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
}
