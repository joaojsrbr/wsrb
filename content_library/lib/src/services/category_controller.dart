import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class CategoryController extends ChangeNotifier {
  final List<CategoryEntity> _categories = [];

  final IsarServiceImpl _isarService;

  CategoryController(this._isarService);

  Future<Result<bool>> add(CategoryEntity entity) async {
    final result = await _isarService.add(entity: entity);
    bool dataResult = false;
    result.when(onSucess: (data) {
      dataResult = data.$1;

      _categories.addIfNoContains(entity);
    });
    notifyListeners();

    return Result.success(dataResult);
  }

  Future<Result<bool>> remove(CategoryEntity entity) async {
    final result = await _isarService.remove(entity: entity);
    bool dataResult = false;
    result.when(onSucess: (data) {
      _categories.remove(entity);
      dataResult = true;
    });
    notifyListeners();

    return Result.success(dataResult);
  }

  UnmodifiableListView<CategoryEntity> get categories =>
      UnmodifiableListView(_categories);

  // void _addOrUpdate(CategoryEntity entity) {
  //   final indexOf = _categories
  //       .indexWhere((element) => listEquals(entity.ids, element.ids));

  //   if (indexOf != -1) {
  //     _categories[indexOf] = entity;
  //   } else {
  //     _categories.add(entity);
  //   }
  // }

  UnmodifiableListView<String> get ids =>
      UnmodifiableListView(categories.map((e) => e.stringID).cast());

  Future<void> start() async {
    final categoryColetions =
        await _isarService.collection<CategoryEntity>().where().findAll();

    _categories.addAll(categoryColetions);
  }
}
