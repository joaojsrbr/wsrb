import 'package:content_library/content_library.dart';
import 'package:content_library/src/utils/elapsed.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class HistoricController extends ChangeNotifier {
  final IsarServiceImpl _isarService;

  HistoricController(this._isarService);

  Future<void> start() async {
    final Elapsed elapsed = Elapsed()..start();

    final episodeCollections = await _isarService.collection<EpisodeEntity>();
    final chaptersCollections = await _isarService.collection<ChapterEntity>();

    final episodes = await episodeCollections.where().findAll();
    final chapters = await chaptersCollections.where().findAll();

    _entities.addAll(episodes);
    _entities.addAll(chapters);
    elapsed.printAndStop(runtimeType.toString());
  }

  T? getHistoryEntityByID<T extends HistoryEntity>(List<String> ids) {
    final entity = entities.firstWhereOrNull((entity) => switch (entity) {
          EpisodeEntity data =>
            ids.containsOneElement([data.stringID, data.animeStringID]),
          _ => false,
        });

    return entity is T ? entity : null;
  }

  final List<HistoryEntity> _entities = [];

  UnmodifiableListView<HistoryEntity> get entities =>
      UnmodifiableListView(_entities);

  UnmodifiableListView<String> get ids =>
      UnmodifiableListView(_entities.map(_map).nonNulls);

  String? _map(HistoryEntity entity) {
    return switch (entity) {
      EpisodeEntity data => data.stringID,
      ChapterEntity data => data.stringID,
      _ => null,
    };
  }

  bool contains({
    HistoryEntity? historyEntity,
    Release? release,
  }) {
    bool result = false;
    if (release != null) {
      assert(historyEntity == null);
      result = switch (release) {
        Episode data => ids.contains(data.stringID),
        Chapter data => ids.contains(data.stringID),
        _ => false,
      };
    } else if (historyEntity != null) {
      assert(release == null);
      result = switch (historyEntity) {
        EpisodeEntity data => ids.contains(data.stringID),
        ChapterEntity data => ids.contains(data.stringID),
        _ => false,
      };
    }
    return result;
  }

  Future<Result<(bool, List<int>?)>> add({
    required HistoryEntity historyEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    _setDateTime(historyEntity);

    final result = await _isarService.add(entity: historyEntity);

    result.fold(onSuccess: (data) {
      if (data.$2 != null) ids.add(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    _addOrUpdate(historyEntity);

    notifyListeners();
    return Result.success((isSucess, ids));
  }

  void _setDateTime(HistoryEntity historyEntity) {
    switch (historyEntity) {
      case EpisodeEntity data:
        if (contains(historyEntity: data)) {
          data.updatedAt = DateTime.now();
        }
        data.createdAt ??= DateTime.now();
        break;
      case ChapterEntity data:
        if (contains(historyEntity: data)) {
          data.updatedAt = DateTime.now();
        }
        data.createdAt ??= DateTime.now();
        break;
    }
  }

  String getStringID(Entity entity) {
    return switch (entity) {
      EpisodeEntity data => data.stringID.trim(),
      ChapterEntity data => data.stringID.trim(),
      _ => '',
    };
  }

  void _addOrUpdate(HistoryEntity historyEntity) {
    final indexOf = _entities.indexWhere((element) => switch (element) {
          EpisodeEntity data when historyEntity is EpisodeEntity =>
            data.stringID.contains(historyEntity.stringID),
          ChapterEntity data when historyEntity is ChapterEntity =>
            data.stringID.contains(historyEntity.stringID),
          _ => false,
        });

    if (indexOf != -1) {
      _entities[indexOf] = historyEntity;
    } else {
      _entities.add(historyEntity);
    }
  }

  void setDateTimeAndAdd(HistoryEntity element) {
    _setDateTime(element);
    _addOrUpdate(element);
  }

  Future<Result<(bool, List<int>?)>> addAll({
    List<HistoryEntity>? historyEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = historyEntities?.nonNulls.cast<HistoryEntity>().toList();

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
    List<HistoryEntity>? historyEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = historyEntities?.nonNulls.cast<HistoryEntity>().toList();

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
    HistoryEntity? historyEntity,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result = await _isarService.remove(entity: historyEntity);

    result.fold(onSuccess: (data) {
      if (data.$2 != null) ids.add(data.$2!);
      if (data.$1) isSucess = data.$1;
    });

    _entities.remove(historyEntity);

    notifyListeners();
    return Result.success((isSucess, ids));
  }
}
