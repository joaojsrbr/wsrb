import 'dart:async';

import 'package:content_library/content_library.dart';
import 'package:content_library/src/repository/library_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LibraryController extends ChangeNotifier {
  final LibraryService _libraryService;

  // late final LibraryService _libraryService;

  InLibraryRepository get repo => _libraryService.repo;

  LibraryController(this._libraryService) {
    _libraryService.addNotifyListeners(notifyListeners);
    // _libraryService = LibraryService(this, hiveController);
  }

  Future<QueryBuilder<T, T, QWhere>> where<T extends ContentEntity>() async {
    return _libraryService.where<T>();
  }

  Future<QueryBuilder<T, T, QFilterCondition>> filter<T extends ContentEntity>() async {
    return _libraryService.filter<T>();
  }

  @override
  void dispose() {
    _libraryService.dispose();
    super.dispose();
  }

  Future<Result<(bool, List<int>?)>> add({required ContentEntity contentEntity}) async {
    bool isSucess = false;
    final List<int> ids = [];

    // _setDateTime(contentEntity);

    final result = await _libraryService.add(contentEntity: contentEntity);

    result.fold(
      onSuccess: (data) {
        if (data.$2 != null) ids.addAll(data.$2!);
        if (data.$1) isSucess = data.$1;
      },
    );

    return Result.success((isSucess, ids));
  }

  Future<Result<(bool, List<int>?)>> addAll({
    required List<ContentEntity> contentEntities,
  }) async {
    final entities = contentEntities.nonNulls.cast<ContentEntity>().toList();

    return await _libraryService.addAll(contentEntities: entities);
  }

  Future<Result<(bool, List<int>?)>> removeAll({
    List<ContentEntity>? contentEntities,
  }) async {
    bool isSucess = false;
    final List<int> ids = [];

    final entities = contentEntities?.nonNulls.cast<ContentEntity>().toList();

    final result = await _libraryService.removeAll(contentEntities: entities);

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
    final result = await _libraryService.remove(contentEntity: contentEntity);

    final record = result.fold<(bool, List<int>?)>(
      onSuccess: (data) {
        return (data.$1, [if (data.$2 != null) ...data.$2!]);
      },
    );

    return Result.success(record!);
  }
}
