import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/historic_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class HistoricController extends ChangeNotifier {
  final IsarServiceImpl _isarService;
  final Subscriptions _subscriptions = Subscriptions();
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  HistoricController(this._isarService) {
    _repository = InHistoricRepository();
  }

  late final InHistoricRepository _repository;

  InHistoricRepository get repo => _repository;

  @override
  void dispose() {
    _debouncer.cancel();
    _subscriptions.cancelAll();
    super.dispose();
  }

  Future<void> start() async {
    final Elapsed elapsed = Elapsed()..start();

    final episodeCollections = await _isarService.collection<EpisodeEntity>();
    final chaptersCollections = await _isarService.collection<ChapterEntity>();

    _subscriptions.addAll(
      [
        episodeCollections.watchLazy().listen(_watchCollections),
        chaptersCollections.watchLazy().listen(_watchCollections),
      ],
    );

    final episodes = await episodeCollections.where().findAll();
    final chapters = await chaptersCollections.where().findAll();

    repo.updateRepository([episodes, chapters]);

    elapsed.printAndStop(runtimeType.toString());
  }

  void _watchCollections(data) async {
    final episodeCollections = await _isarService.collection<EpisodeEntity>();
    final chaptersCollections = await _isarService.collection<ChapterEntity>();
    final episodes = await episodeCollections.where().findAll();
    final chapters = await chaptersCollections.where().findAll();
    repo.updateRepository([episodes, chapters]);

    _debouncer.call(notifyListeners);
  }

  Future<Result<(bool, List<int>?)>> add({
    required HistoryEntity historyEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result = await _isarService.add(entity: historyEntity);

    result.fold(onSuccess: (data) {
      if (data.$2 != null) ids.add(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    return Result.success((isSucess, ids));
  }

  String getStringID(Entity entity) {
    return switch (entity) {
      EpisodeEntity data => data.stringID.trim(),
      ChapterEntity data => data.stringID.trim(),
      _ => '',
    };
  }

  Future<Result<(bool, List<int>?)>> addAll({
    required List<HistoryEntity> historyEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = historyEntities.nonNulls.cast<HistoryEntity>().toList();

    final result = await _isarService.addAll(entities: entities);

    result.fold(onSuccess: (data) {
      if (data.$2 != null) ids.addAll(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> removeAll({
    required List<HistoryEntity> historyEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = historyEntities.nonNulls.cast<HistoryEntity>().toList();

    final result = await _isarService.removeAll(entities: entities);

    result.fold(onSuccess: (data) {
      if (data.$2 != null) ids.addAll(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> remove({
    required HistoryEntity historyEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result = await _isarService.remove(entity: historyEntity);

    result.fold(onSuccess: (data) {
      if (data.$2 != null) ids.add(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    return Result.success((isSucess, ids));
  }
}
