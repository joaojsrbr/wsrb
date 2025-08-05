import 'package:content_library/content_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class CategoryController extends ChangeNotifier {
  List<CategoryEntity> _categories = [];
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 200),
  );

  final Subscriptions _subscriptions = Subscriptions();

  final IsarServiceImpl _isarService;

  CategoryController(this._isarService);

  UnmodifiableListView<CategoryEntity> get categories =>
      UnmodifiableListView(_categories);

  UnmodifiableListView<String> get ids =>
      UnmodifiableListView(categories.map((e) => e.stringID).cast());

  @override
  void dispose() {
    _subscriptions.cancelAll();
    super.dispose();
  }

  Future<Result<bool>> add(CategoryEntity entity) async {
    final result = await _isarService.add(entity: entity);
    bool dataResult = false;
    result.fold(
      onSuccess: (data) {
        dataResult = data.$1;
      },
    );

    return Result.success(dataResult);
  }

  Future<Result<bool>> remove(CategoryEntity entity) async {
    final result = await _isarService.remove(entity: entity);
    bool dataResult = false;
    result.fold(
      onSuccess: (data) {
        dataResult = true;
      },
    );

    return Result.success(dataResult);
  }

  void _watchCollection(data) async {
    final categoryColetions = await _isarService.collection<CategoryEntity>();
    _categories = await categoryColetions.where().findAll();
    _debouncer.call(notifyListeners);
  }

  Future<void> start() async {
    final Elapsed elapsed = Elapsed()..start();

    final categoryColetions = await _isarService.collection<CategoryEntity>();

    _subscriptions.addAll([
      categoryColetions.watchLazy().listen(_watchCollection),
    ]);

    _categories = await categoryColetions.where().findAll();
    elapsed.printAndStop(runtimeType.toString());
  }
}
