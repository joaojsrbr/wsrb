import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/library_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LibraryController extends ChangeNotifier {
  final IsarServiceImpl _isarService;
  final Subscriptions _subscriptions = Subscriptions();
  // late final LibraryService _libraryService;

  late final InLibraryRepository _inLibraryRepository;

  InLibraryRepository get repo => _inLibraryRepository;

  LibraryController(this._isarService, AppConfigController appConfig) {
    _inLibraryRepository = InLibraryRepository(appConfig);
    // _libraryService = LibraryService(this, hiveController);
  }

  final Debouncer _updateDebouncer = Debouncer(
    duration: const Duration(milliseconds: 100),
  );

  @override
  void dispose() {
    _updateDebouncer.cancel();
    _subscriptions.cancelAll();
    super.dispose();
  }

  void _watchAll(data) async {
    final animeColetions = await _isarService.collection<AnimeEntity>();

    final bookColetions = await _isarService.collection<BookEntity>();

    // final episodeColetions = await _isarService.collection<EpisodeEntity>();

    final entities = [
      ...(await animeColetions.where().findAll()),
      ...(await bookColetions.where().findAll()),
    ];

    await Future.wait(
      entities
          .map(
            (entity) => switch (entity) {
              AnimeEntity data => [data.episodes.load(), data.animeSkip.load()],
              BookEntity data => [data.chapters.load()],
              _ => null,
            },
          )
          .nonNulls
          .flattened,
    );

    repo.updateRepository([entities]);
    _updateDebouncer.call(notifyListeners);
  }

  Future<void> start() async {
    final Elapsed elapsed = Elapsed()..start();

    final animeColetions = await _isarService.collection<AnimeEntity>();

    final bookColetions = await _isarService.collection<BookEntity>();

    final episodeColetions = await _isarService.collection<EpisodeEntity>();

    final entities = [
      ...(await animeColetions.where().findAll()),
      ...(await bookColetions.where().findAll()),
    ];

    await Future.wait(
      entities
          .map(
            (entity) => switch (entity) {
              AnimeEntity data => [data.episodes.load(), data.animeSkip.load()],
              BookEntity data => [data.chapters.load()],
              _ => null,
            },
          )
          .nonNulls
          .flattened,
    );

    repo.updateRepository([entities]);

    _subscriptions.addAll([
      animeColetions.watchLazy().listen(_watchAll),
      bookColetions.watchLazy().listen(_watchAll),
      episodeColetions.watchLazy().listen(_watchAll),
    ]);

    elapsed.printAndStop(runtimeType.toString());
  }

  Future<Result<(bool, List<int>?)>> add({
    required ContentEntity contentEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    // _setDateTime(contentEntity);

    final result = await _isarService.add(entity: contentEntity);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.add(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> addAll({
    required List<ContentEntity> contentEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = contentEntities.nonNulls.cast<ContentEntity>().toList();

    // entities.forEach(_setDateTime);

    final result = await _isarService.addAll(entities: entities);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> removeAll({
    List<ContentEntity>? contentEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = contentEntities?.nonNulls.cast<ContentEntity>().toList();

    final result = await _isarService.removeAll(entities: entities);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> remove({
    required ContentEntity contentEntity,
  }) async {
    final result = await _isarService.remove(entity: contentEntity);

    final record = result.fold<(bool, List<int>?)>(
      onSuccess: (data) {
        return (data.$1, [if (data.$2 != null) data.$2!]);
      },
    );

    return Result.success(record!);
  }
}
