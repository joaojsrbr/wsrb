import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/historic_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class HistoricController extends ChangeNotifier {
  final HistoricService _historicService;

  HistoricController(this._historicService) {
    _historicService.addNotifyListeners(notifyListeners);
  }

  InHistoricRepository get repo => _historicService.repo;

  @override
  void dispose() {
    _historicService.dispose();
    super.dispose();
  }

  Future<QueryBuilder<T, T, QWhere>> where<T extends HistoricEntity>() async {
    return _historicService.where<T>();
  }

  Future<QueryBuilder<T, T, QFilterCondition>> filter<T extends HistoricEntity>() async {
    return _historicService.filter<T>();
  }

  Future<Result<(bool, List<int>?)>> add({required HistoricEntity historic}) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result = await _historicService.add(historic: historic);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

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
    required List<HistoricEntity> historyEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = historyEntities.nonNulls.cast<HistoricEntity>().toList();

    final result = await _historicService.addAll(historyEntities: entities);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> removeAll({
    required List<HistoricEntity> historyEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = historyEntities.nonNulls.cast<HistoricEntity>().toList();

    final result = await _historicService.removeAll(historyEntities: entities);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> remove({required HistoricEntity historic}) async {
    bool isSucess = false;
    final List<int> ids = [];

    final result = await _historicService.remove(historic: historic);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }
}
