import 'dart:async';

import 'package:content_library/content_library.dart';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LibraryController extends ChangeNotifier {
  final IsarServiceImpl _isarService;
  final Subscriptions _subscriptions = Subscriptions();
  late final LibraryService _libraryService;
  LibraryController(this._isarService, HiveController hiveController) {
    _libraryService = LibraryService(this, hiveController);
  }

  final Debouncer _updateDebouncer =
      Debouncer(duration: const Duration(milliseconds: 200));

  @override
  void dispose() {
    _updateDebouncer.cancel();
    _subscriptions.cancelAll();
    super.dispose();
  }

  Stream<dynamic> collectionChanged<T>() =>
      _isarService.collection<T>().watchLazy();

  void _updateBookIsarLinks(data) async {
    Timer(const Duration(milliseconds: 350), () async {
      final bookColetions =
          await _isarService.collection<BookEntity>().where().findAll();

      await Future.wait([
        ...bookColetions.map((element) => element.chapters.load()),
      ]);

      bool update = false;

      for (var contentEntity in bookColetions) {
        update = _entities.updateWhere(
            contentEntity,
            (element) => switch (element) {
                  BookEntity data =>
                    data.stringID.contains(contentEntity.stringID),
                  _ => false,
                });
      }

      if (update) {
        _updateDebouncer.cancel();
        _updateDebouncer.call(notifyListeners);
      }
    });
  }

  void _updateAnimeIsarLinks(data) async {
    Timer(const Duration(milliseconds: 350), () async {
      final animeColetions =
          await _isarService.collection<AnimeEntity>().where().findAll();

      await Future.wait([
        ...animeColetions.map((element) => element.episodes.load()),
      ]);

      bool update = false;

      for (var contentEntity in animeColetions) {
        update = _entities.updateWhere(
            contentEntity,
            (element) => switch (element) {
                  AnimeEntity data =>
                    data.stringID.contains(contentEntity.stringID),
                  _ => false,
                });
      }

      if (update) {
        _updateDebouncer.cancel();
        _updateDebouncer.call(notifyListeners);
      }
    });
  }

  final List<ContentEntity> _entities = [];

  Future<void> start() async {
    final animeColetions =
        await _isarService.collection<AnimeEntity>().where().findAll();

    final bookColetions =
        await _isarService.collection<BookEntity>().where().findAll();

    await Future.wait([
      ...animeColetions.map((element) => element.episodes.load()),
      ...bookColetions.map((element) => element.chapters.load()),
    ]);

    _entities.addAll(animeColetions);
    _entities.addAll(bookColetions);

    _subscriptions.addAll(
      [
        collectionChanged<AnimeEntity>().listen(_updateAnimeIsarLinks),
        collectionChanged<EpisodeEntity>().listen(_updateAnimeIsarLinks),
        collectionChanged<BookEntity>().listen(_updateBookIsarLinks),
      ],
    );
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
    _entities.addOrUpdateWhere(
      contentEntity,
      (element) => switch (element) {
        AnimeEntity data when contentEntity is AnimeEntity =>
          data.stringID.contains(contentEntity.stringID),
        BookEntity data when contentEntity is BookEntity =>
          data.stringID.contains(contentEntity.stringID),
        _ => false,
      },
    );
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
    final result = await _isarService.remove(entity: contentEntity);

    _entities.removeWhere((entity) => switch (entity) {
          AnimeEntity data when contentEntity is AnimeEntity =>
            data.stringID.contains(contentEntity.stringID),
          BookEntity data when contentEntity is BookEntity =>
            data.stringID.contains(contentEntity.stringID),
          _ => false,
        });

    notifyListeners();

    final record = result.fold<(bool, List<int>?)>(onSuccess: (data) {
      return (data.$1, [if (data.$2 != null) data.$2!]);
    });

    return Result.success(record!);
  }
}
